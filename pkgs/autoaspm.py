#!/usr/bin/env python3
"""ASPM (Active State Power Management) patcher for PCIe devices.

Original bash script by Luis R. Rodriguez
Re-written in Python by z8
Re-re-written to patch supported devices automatically by notthebee
Re-re-re-written to improve usability by hnjae
  - Added CLI arguments (--mode, --list, --dry-run)
"""

import argparse
import logging
import os
import platform
import re
import shutil
import subprocess
from enum import Enum
from typing import ClassVar


class SystemdFormatter(logging.Formatter):
    """Formatter for systemd journal with syslog priority prefixes."""

    # Map Python logging levels to syslog priorities
    LEVEL_MAP: ClassVar[dict[int, int]] = {
        logging.CRITICAL: 3,  # Error
        logging.ERROR: 3,  # Error
        logging.WARNING: 4,  # Warning
        logging.INFO: 6,  # Informational
        logging.DEBUG: 7,  # Debug
    }

    def format(self, record: logging.LogRecord) -> str:
        """Format log record with syslog priority prefix."""
        priority = self.LEVEL_MAP.get(record.levelno, 6)
        return f"<{priority}>{record.getMessage()}"


def setup_logger() -> logging.Logger:
    """Set up logger with systemd support."""
    logger = logging.getLogger(__name__)
    logger.setLevel(logging.INFO)

    # Detect systemd environment
    is_systemd = "JOURNAL_STREAM" in os.environ

    # Create custom formatter
    if is_systemd:
        formatter = SystemdFormatter()
    else:
        formatter = logging.Formatter("%(levelname)s: %(message)s")

    handler = logging.StreamHandler()
    handler.setFormatter(formatter)
    logger.addHandler(handler)

    return logger


# Initialize logger
logger = setup_logger()


class ASPM(Enum):
    """ASPM (Active State Power Management) modes."""

    DISABLED = 0b00
    L0s = 0b01
    L1 = 0b10
    L0sL1 = 0b11

    @classmethod
    def from_string(cls, s: str) -> "ASPM":
        """Parse ASPM mode from string."""
        mapping = {
            "disabled": cls.DISABLED,
            "l0s": cls.L0s,
            "l1": cls.L1,
            "l0sl1": cls.L0sL1,
        }
        return mapping[s.lower()]

    def supports(self, requested: "ASPM") -> bool:
        """Check if this ASPM mode supports the requested mode.

        Example: L0sL1 supports L0s, L1, and L0sL1
                 L0s supports only L0s
                 L1 supports only L1
        """
        return (self.value & requested.value) == requested.value

    def includes(self, other: "ASPM") -> bool:
        """Check if current mode includes another mode.

        Example: L0sL1.includes(L1) -> True (L0sL1 includes L1)
        """
        return (self.value & other.value) == other.value


class ASPMPatcherError(Exception):
    """Error related to ASPM patcher."""


class CapabilityNotFoundError(ASPMPatcherError):
    """When PCIe Capability cannot be found."""


class DeviceAccessError(ASPMPatcherError):
    """When device access fails."""


# PCI Capability IDs
PCI_CAP_ID_PCIE = 0x10  # PCI Express Capability

# PCIe Capability internal offset
PCIE_CAP_LINK_CONTROL_OFFSET = (
    0x10  # Link Control Register offset within PCIe capability
)

# PCI Configuration Space
PCI_CAPABILITY_LIST_POINTER = 0x34  # Capabilities Pointer location
PCI_CONFIG_SPACE_SIZE = 256

# Maximum search iterations for safety
MAX_CAPABILITY_SEARCH_ITERATIONS = (
    48  # 256 / minimum capability size (~4-8 bytes)
)


def run_prerequisites():
    """Check requirements before running."""
    if platform.system() != "Linux":
        msg = "This script only runs on Linux-based systems"
        raise OSError(msg)

    if not os.environ.get("SUDO_UID") and os.geteuid() != 0:
        msg = "This script needs root privileges to run"
        raise PermissionError(msg)

    for tool in ["lspci", "setpci"]:
        if not shutil.which(tool):
            msg = f"{tool} not detected. Please install pciutils"
            raise ASPMPatcherError(msg)


def get_device_name(addr: str) -> str:
    """Get device name from PCI address."""
    try:
        result = subprocess.run(
            ["lspci", "-s", addr],
            check=False,
            capture_output=True,
            text=True,
            timeout=10,
        )
        if result.returncode != 0:
            msg = f"Failed to get device name for {addr}: {result.stderr}"
            raise DeviceAccessError(msg)

        lines = result.stdout.strip().splitlines()
        if not lines:
            msg = f"No device found at {addr}"
            raise DeviceAccessError(msg)

        return lines[0]
    except subprocess.TimeoutExpired:
        msg = f"Timeout while getting device name for {addr}"
        raise DeviceAccessError(msg) from None


def read_all_bytes(device: str) -> bytearray:
    """Read PCI config space from device."""
    try:
        result = subprocess.run(
            ["lspci", "-s", device, "-xxx"],
            check=False,
            capture_output=True,
            text=True,
            timeout=10,
        )

        if result.returncode != 0:
            msg = f"Failed to read config space for {device}: {result.stderr}"
            raise DeviceAccessError(msg)

        all_bytes = bytearray()
        device_name = get_device_name(device)

        for line in result.stdout.splitlines():
            # Skip device name line, parse only hex dump lines
            if device_name not in line and ": " in line:
                hex_part = line.split(": ", 1)[1]
                # Parse hex values separated by spaces
                hex_values = hex_part.split()
                for hex_val in hex_values:
                    if len(hex_val) == 2:  # Valid hex byte
                        try:
                            all_bytes.append(int(hex_val, 16))
                        except ValueError:
                            continue

        if len(all_bytes) >= PCI_CONFIG_SPACE_SIZE:
            return all_bytes

        msg = (
            f"Incomplete config space read for {device}: "
            f"got {len(all_bytes)} bytes, expected at least {PCI_CONFIG_SPACE_SIZE}"
        )
        raise DeviceAccessError(msg)

    except subprocess.TimeoutExpired:
        msg = f"Timeout while reading config space for {device}"
        raise DeviceAccessError(msg) from None


def find_pcie_capability(config_bytes: bytearray) -> int:
    """Find PCIe Capability location in PCI config space.

    PCI Capability List structure:
    - config_bytes[0x34]: Pointer to first capability
    - Each capability structure:
      - [offset + 0]: Capability ID
      - [offset + 1]: Pointer to next capability (0 if end)
      - [offset + 2...]: Capability-specific data

    Returns:
        Start offset of PCIe capability

    Raises:
        CapabilityNotFoundError: If PCIe capability cannot be found
    """
    # Read capabilities pointer
    cap_pointer = config_bytes[PCI_CAPABILITY_LIST_POINTER]

    # Validation: capability pointer must be 4-byte aligned
    if cap_pointer == 0 or cap_pointer % 4 != 0:
        msg = "Invalid or no capabilities pointer"
        raise CapabilityNotFoundError(msg)

    visited: set[int] = set()  # For detecting circular references
    iterations = 0

    while cap_pointer != 0 and iterations < MAX_CAPABILITY_SEARCH_ITERATIONS:
        # Boundary check
        if cap_pointer >= len(config_bytes) - 1:
            msg = f"Capability pointer {cap_pointer:#x} out of bounds"
            raise CapabilityNotFoundError(msg)

        # Check for circular reference
        if cap_pointer in visited:
            msg = f"Circular reference detected at {cap_pointer:#x}"
            raise CapabilityNotFoundError(msg)
        visited.add(cap_pointer)

        # Check Capability ID
        cap_id = config_bytes[cap_pointer]

        if cap_id == PCI_CAP_ID_PCIE:
            return cap_pointer

        # Move to next capability
        cap_pointer = config_bytes[cap_pointer + 1]
        iterations += 1

    msg = "PCIe capability not found in capability list"
    raise CapabilityNotFoundError(msg)


def get_link_control_offset(pcie_cap_offset: int) -> int:
    """Calculate Link Control Register offset within PCIe Capability."""
    return pcie_cap_offset + PCIE_CAP_LINK_CONTROL_OFFSET


def patch_byte(device: str, position: int, value: int) -> None:
    """Patch a specific byte in PCI config space."""
    try:
        result = subprocess.run(
            ["setpci", "-s", device, f"{position:#x}.B={value:#x}"],
            check=False,
            capture_output=True,
            text=True,
            timeout=10,
        )

        if result.returncode != 0:
            msg = f"Failed to patch {device} at {position:#x}: {result.stderr}"
            raise DeviceAccessError(msg)
    except subprocess.TimeoutExpired:
        msg = f"Timeout while patching {device}"
        raise DeviceAccessError(msg) from None


def verify_patch(device: str, position: int, expected_value: int) -> bool:
    """Verify that the patch was applied correctly."""
    try:
        new_bytes = read_all_bytes(device)
    except DeviceAccessError:
        return False
    else:
        actual_value = new_bytes[position] & 0b11  # Check only ASPM bits
        return actual_value == expected_value


def patch_device(
    addr: str, supported_aspm: ASPM, requested_mode: ASPM | None = None
) -> bool:
    """Patch ASPM settings for a device.

    Args:
        addr: PCI address
        supported_aspm: ASPM mode that the device supports
        requested_mode: ASPM mode requested by user (None = use maximum supported)

    Returns:
        True if patched successfully, False if already set or skipped

    Raises:
        ASPMPatcherError: When patching fails
    """
    try:
        # Determine target ASPM mode
        if requested_mode is None:
            # If no request, use maximum supported mode
            target_aspm = supported_aspm
        else:
            # Check if device supports the requested mode
            if not supported_aspm.supports(requested_mode):
                logger.warning(
                    "%s: Skipping - Device supports %s, but %s was requested",
                    addr,
                    supported_aspm.name,
                    requested_mode.name,
                )
                return False
            target_aspm = requested_mode

        # Read config space
        endpoint_bytes = read_all_bytes(addr)

        # Find PCIe capability
        pcie_cap_offset = find_pcie_capability(endpoint_bytes)

        # Calculate Link Control Register location
        link_control_offset = get_link_control_offset(pcie_cap_offset)

        # Boundary check
        if link_control_offset >= len(endpoint_bytes):
            msg = f"Link Control offset {link_control_offset:#x} out of bounds"
            raise ASPMPatcherError(msg)

        current_value = endpoint_bytes[link_control_offset]
        current_aspm = ASPM(current_value & 0b11)

        # If already in target state
        if current_aspm == target_aspm:
            logger.info("%s: Already has ASPM %s enabled", addr, target_aspm.name)
            return False

        # If current state already includes requested mode (e.g., L0sL1 when only L1 requested)
        if requested_mode is not None and current_aspm.includes(
            requested_mode
        ):
            logger.info(
                "%s: Skipping - Current %s already includes %s",
                addr,
                current_aspm.name,
                requested_mode.name,
            )
            return False

        # Calculate new value: change only lower 2 bits
        patched_byte = (current_value & ~0b11) | target_aspm.value

        # Apply patch
        patch_byte(addr, link_control_offset, patched_byte)

    except CapabilityNotFoundError as e:
        logger.warning("%s: Skipping - %s", addr, e)
        return False
    except DeviceAccessError as e:
        logger.error("%s: Error - %s", addr, e)  # noqa: TRY400
        return False
    else:
        # Verify patch
        if verify_patch(addr, link_control_offset, target_aspm.value):
            logger.info("%s: Enabled ASPM %s", addr, target_aspm.name)
        else:
            logger.warning("%s: WARNING - Patch applied but verification failed", addr)
        return True


def list_supported_devices() -> dict[str, ASPM]:
    """Get list of PCI devices that support ASPM."""
    pcie_addr_regex = r"([0-9a-f]{2}:[0-9a-f]{2}\.[0-9a-f])"

    try:
        result = subprocess.run(
            ["lspci", "-vv"],
            check=False,
            capture_output=True,
            text=True,
            timeout=30,
        )

        if result.returncode != 0:
            msg = f"lspci failed: {result.stderr}"
            raise ASPMPatcherError(msg)

        lspci_output = result.stdout
    except subprocess.TimeoutExpired:
        msg = "lspci timed out"
        raise ASPMPatcherError(msg) from None

    # Split by device
    lspci_arr = re.split(pcie_addr_regex, lspci_output)[1:]
    lspci_arr = [
        x + y for x, y in zip(lspci_arr[0::2], lspci_arr[1::2], strict=True)
    ]

    aspm_devices: dict[str, ASPM] = {}

    for dev in lspci_arr:
        addr_match = re.search(pcie_addr_regex, dev)
        if not addr_match:
            continue

        device_addr = addr_match.group(1)

        # Check if ASPM is supported
        if "ASPM" not in dev or "ASPM not supported" in dev:
            continue

        # Parse supported ASPM modes
        aspm_support: list[str] = re.findall(r"ASPM (L[L0-1s ]*),", dev)
        if aspm_support:
            try:
                aspm_mode_str = aspm_support[0].replace(" ", "")
                aspm_mode = ASPM[aspm_mode_str]
                aspm_devices[device_addr] = aspm_mode
            except KeyError:
                logger.warning(
                    "%s: Unknown ASPM mode '%s', skipping",
                    device_addr,
                    aspm_support[0],
                )
                continue

    return aspm_devices


def handle_list_mode(devices: dict[str, ASPM]) -> None:
    """Handle --list mode to display ASPM-capable devices."""
    for device, supported_aspm in devices.items():
        device_name = get_device_name(device)
        logger.info("%s: supports %s", device, supported_aspm.name)
        logger.info("  %s", device_name)


def process_device_in_dry_run(
    device: str, supported_aspm: ASPM, requested_mode: ASPM | None
) -> tuple[bool, bool]:
    """Process a device in dry-run mode.

    Args:
        device: PCI device address
        supported_aspm: ASPM mode the device supports
        requested_mode: Requested ASPM mode (None = auto)

    Returns:
        Tuple of (would_patch, would_skip) booleans
    """
    # Determine target mode
    if requested_mode is None:
        target = supported_aspm
    elif not supported_aspm.supports(requested_mode):
        logger.info("%s: would skip - doesn't support %s", device, requested_mode.name)
        return (False, True)
    else:
        target = requested_mode

    # Read config space to check current state
    try:
        endpoint_bytes = read_all_bytes(device)
        pcie_cap_offset = find_pcie_capability(endpoint_bytes)
        link_control_offset = get_link_control_offset(pcie_cap_offset)
        current_aspm = ASPM(endpoint_bytes[link_control_offset] & 0b11)

        if current_aspm == target:
            logger.info("%s: would skip - already %s", device, target.name)
            return (False, True)
        if requested_mode and current_aspm.includes(requested_mode):
            logger.info(
                "%s: would skip - %s already includes %s",
                device,
                current_aspm.name,
                requested_mode.name,
            )
            return (False, True)
    except (CapabilityNotFoundError, DeviceAccessError) as e:
        logger.info("%s: would skip - %s", device, e)
        return (False, True)
    else:
        logger.info(
            "%s: would enable %s (current: %s)",
            device,
            target.name,
            current_aspm.name,
        )
        return (True, False)


def process_devices(
    devices: dict[str, ASPM],
    requested_mode: ASPM | None,
    dry_run: bool,
) -> tuple[int, int, int]:
    """Process devices for patching.

    Args:
        devices: Dictionary of device addresses to supported ASPM modes
        requested_mode: Requested ASPM mode (None = auto)
        dry_run: Whether this is a dry-run

    Returns:
        Tuple of (patched_count, skipped_count, error_count)
    """
    patched_count = 0
    skipped_count = 0
    error_count = 0

    for device, supported_aspm in devices.items():
        try:
            if dry_run:
                would_patch, would_skip = process_device_in_dry_run(
                    device, supported_aspm, requested_mode
                )
                if would_patch:
                    patched_count += 1
                elif would_skip:
                    skipped_count += 1
            else:
                # Actually patch
                if patch_device(device, supported_aspm, requested_mode):
                    patched_count += 1
                else:
                    skipped_count += 1
        except ASPMPatcherError as e:
            logger.error("%s: Failed - %s", device, e)  # noqa: TRY400
            error_count += 1

    return (patched_count, skipped_count, error_count)


class ArgsNamespace(argparse.Namespace):
    """Typed Namespace for parsed command-line arguments."""

    mode: str | None = None
    list_only: bool = False
    dry_run: bool = False


def parse_args() -> ArgsNamespace:
    """Parse command-line arguments."""
    parser = argparse.ArgumentParser(
        description="Enable ASPM (Active State Power Management) on PCIe devices",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s                  Enable maximum supported ASPM on all devices
  %(prog)s --mode l0s       Enable L0s only on devices that support it
  %(prog)s --mode l1        Enable L1 only on devices that support it
  %(prog)s --mode l0sl1     Enable L0s+L1 on devices that support both
  %(prog)s --list           List ASPM-capable devices without patching

Notes:
  - If a device is already in L0sL1 state and you request L1 only,
    the device will be skipped (not downgraded).
  - Requesting a mode the device doesn't support will skip that device.
""",
    )

    _ = parser.add_argument(
        "--mode",
        "-m",
        type=str,
        choices=["l0s", "l1", "l0sl1", "disabled"],
        default=None,
        help="ASPM mode to enable. If not specified, enables maximum supported mode for each device.",
    )

    _ = parser.add_argument(
        "--list",
        "-l",
        action="store_true",
        dest="list_only",
        help="List ASPM-capable devices and their supported modes without patching",
    )

    _ = parser.add_argument(
        "--dry-run",
        "-n",
        action="store_true",
        help="Show what would be done without actually patching",
    )

    return parser.parse_args(namespace=ArgsNamespace())


def main():
    """Run the ASPM patcher."""
    args = parse_args()

    try:
        run_prerequisites()
    except (OSError, PermissionError, ASPMPatcherError) as e:
        logger.error("%s", e)  # noqa: TRY400
        return 1

    try:
        devices = list_supported_devices()
    except ASPMPatcherError as e:
        logger.error("Error listing devices: %s", e)  # noqa: TRY400
        return 1

    if not devices:
        logger.info("No ASPM-capable devices found")
        return 0

    # Parse requested ASPM mode
    requested_mode: ASPM | None = None
    if args.mode:
        requested_mode = ASPM.from_string(args.mode)

    logger.info("Found %d ASPM-capable device(s)", len(devices))
    if requested_mode:
        logger.info("Requested mode: %s", requested_mode.name)
    else:
        logger.info("Mode: auto (maximum supported per device)")
    logger.info("-" * 60)

    # --list option: print list only
    if args.list_only:
        handle_list_mode(devices)
        return 0

    # Process devices
    patched_count, skipped_count, error_count = process_devices(
        devices, requested_mode, args.dry_run
    )

    logger.info("-" * 60)
    action_word = "Would patch" if args.dry_run else "Patched"
    logger.info(
        "Summary: %s %d, skipped %d, errors %d",
        action_word,
        patched_count,
        skipped_count,
        error_count,
    )

    return 0 if error_count == 0 else 1


if __name__ == "__main__":
    import sys

    sys.exit(main())
