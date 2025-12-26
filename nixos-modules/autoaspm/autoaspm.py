#!/usr/bin/env python3
"""ASPM (Active State Power Management) patcher for PCIe devices.

Original bash script by Luis R. Rodriguez
Re-written in Python by z8
Re-re-written to patch supported devices automatically by notthebee
Re-re-re-written to improve usability by hnjae
  - Added CLI arguments (--mode, --list, --run)
  - Changed default behavior to dry-run for safety
"""

from __future__ import annotations

import argparse
import logging
import os
import platform
import re
import shutil
import subprocess
import sys
from enum import Enum
from typing import TYPE_CHECKING, ClassVar, final, override

if TYPE_CHECKING:
    from collections.abc import Iterable
    from collections.abc import Set as AbstractSet


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

    @override
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
    formatter: logging.Formatter
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
    def from_string(cls, s: str) -> ASPM:
        """Parse ASPM mode from string."""
        mapping = {
            "disabled": cls.DISABLED,
            "l0s": cls.L0s,
            "l1": cls.L1,
            "l0sl1": cls.L0sL1,
        }
        return mapping[s.lower()]

    def supports(self, requested: ASPM) -> bool:
        """Check if this ASPM mode supports the requested mode.

        Example: L0sL1 supports L0s, L1, and L0sL1
                 L0s supports only L0s
                 L1 supports only L1
        """
        return (self.value & requested.value) == requested.value

    def includes(self, other: ASPM) -> bool:
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


@final
class PCIDevice:
    """Represents a PCI device with ASPM support."""

    def __init__(self, addr: str, supported_aspm: ASPM) -> None:
        """Initialize PCIDevice.

        Args:
            addr: PCI device address (e.g., "01:00.0")
            supported_aspm: ASPM mode supported by this device
        """
        self.addr = addr
        self.supported_aspm = supported_aspm
        self._config_bytes: bytearray | None = None
        self._pcie_cap_offset: int | None = None
        self._device_name: str | None = None
        self._vendor_device_id: str | None = None

    @override
    def __hash__(self) -> int:
        """Return hash based on PCI address."""
        return hash(self.addr)

    @override
    def __eq__(self, other: object) -> bool:
        """Check equality based on PCI address."""
        if not isinstance(other, PCIDevice):
            return NotImplemented
        return self.addr == other.addr

    def get_name(self) -> str:
        """Get device name from PCI address."""
        if self._device_name is None:
            self._device_name = self._fetch_device_name()
        return self._device_name

    def _fetch_device_name(self) -> str:
        """Fetch device name from lspci."""
        try:
            result = subprocess.run(
                ["lspci", "-s", self.addr],
                check=False,
                capture_output=True,
                text=True,
                timeout=10,
            )
            if result.returncode != 0:
                msg = f"Failed to get device name for {self.addr}: {result.stderr}"
                raise DeviceAccessError(msg)

            lines = result.stdout.strip().splitlines()
            if not lines:
                msg = f"No device found at {self.addr}"
                raise DeviceAccessError(msg)

            return lines[0]
        except subprocess.TimeoutExpired:
            msg = f"Timeout while getting device name for {self.addr}"
            raise DeviceAccessError(msg) from None

    def get_vendor_device_id(self) -> str:
        """Get vendor:device ID (e.g., '8086:15b8')."""
        if self._vendor_device_id is None:
            self._vendor_device_id = self._fetch_vendor_device_id()
        return self._vendor_device_id

    def _fetch_vendor_device_id(self) -> str:
        """Fetch vendor:device ID from lspci."""
        try:
            result = subprocess.run(
                ["lspci", "-n", "-s", self.addr],
                check=False,
                capture_output=True,
                text=True,
                timeout=10,
            )
            if result.returncode != 0:
                msg = f"Failed to get vendor:device ID for {self.addr}: {result.stderr}"
                raise DeviceAccessError(msg)

            lines = result.stdout.strip().splitlines()
            if not lines:
                msg = f"No device found at {self.addr}"
                raise DeviceAccessError(msg)

            # Parse output format: "01:00.0 0280: 8086:15b8 (rev 34)"
            # Extract vendor:device ID using regex
            match = re.search(r"\s([0-9a-f]{4}:[0-9a-f]{4})", lines[0])
            if not match:
                msg = f"Could not parse vendor:device ID from lspci output: {lines[0]}"
                raise DeviceAccessError(msg)

            return match.group(1)
        except subprocess.TimeoutExpired:
            msg = f"Timeout while getting vendor:device ID for {self.addr}"
            raise DeviceAccessError(msg) from None

    def read_config_space(self) -> bytearray:
        """Read PCI config space from device."""
        if self._config_bytes is not None:
            return self._config_bytes

        try:
            result = subprocess.run(
                ["lspci", "-s", self.addr, "-xxx"],
                check=False,
                capture_output=True,
                text=True,
                timeout=10,
            )

            if result.returncode != 0:
                msg = f"Failed to read config space for {self.addr}: {result.stderr}"
                raise DeviceAccessError(msg)

            all_bytes = bytearray()
            device_name = self.get_name()

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
                self._config_bytes = all_bytes
                return all_bytes

            msg = (
                f"Incomplete config space read for {self.addr}: "
                f"got {len(all_bytes)} bytes, expected at least {PCI_CONFIG_SPACE_SIZE}"
            )
            raise DeviceAccessError(msg)

        except subprocess.TimeoutExpired:
            msg = f"Timeout while reading config space for {self.addr}"
            raise DeviceAccessError(msg) from None

    def find_pcie_capability(self) -> int:
        """Find PCIe Capability location in PCI config space.

        Returns:
            Start offset of PCIe capability

        Raises:
            CapabilityNotFoundError: If PCIe capability cannot be found
        """
        if self._pcie_cap_offset is not None:
            return self._pcie_cap_offset

        config_bytes = self.read_config_space()

        # Read capabilities pointer
        cap_pointer = config_bytes[PCI_CAPABILITY_LIST_POINTER]

        # Validation: capability pointer must be 4-byte aligned
        if cap_pointer == 0 or cap_pointer % 4 != 0:
            msg = "Invalid or no capabilities pointer"
            raise CapabilityNotFoundError(msg)

        visited: set[int] = set()  # For detecting circular references
        iterations = 0

        while (
            cap_pointer != 0 and iterations < MAX_CAPABILITY_SEARCH_ITERATIONS
        ):
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
                self._pcie_cap_offset = cap_pointer
                return cap_pointer

            # Move to next capability
            cap_pointer = config_bytes[cap_pointer + 1]
            iterations += 1

        msg = "PCIe capability not found in capability list"
        raise CapabilityNotFoundError(msg)

    def get_link_control_offset(self) -> int:
        """Calculate Link Control Register offset within PCIe Capability."""
        pcie_cap_offset = self.find_pcie_capability()
        return pcie_cap_offset + PCIE_CAP_LINK_CONTROL_OFFSET

    def get_current_aspm(self) -> ASPM:
        """Get current ASPM state from device."""
        config_bytes = self.read_config_space()
        link_control_offset = self.get_link_control_offset()
        return ASPM(config_bytes[link_control_offset] & 0b11)

    def _patch_byte(self, position: int, value: int) -> None:
        """Patch a specific byte in PCI config space."""
        # Invalidate cache after patching
        self._config_bytes = None

        try:
            result = subprocess.run(
                ["setpci", "-s", self.addr, f"{position:#x}.B={value:#x}"],
                check=False,
                capture_output=True,
                text=True,
                timeout=10,
            )

            if result.returncode != 0:
                msg = f"Failed to patch {self.addr} at {position:#x}: {result.stderr}"
                raise DeviceAccessError(msg)
        except subprocess.TimeoutExpired:
            msg = f"Timeout while patching {self.addr}"
            raise DeviceAccessError(msg) from None

    def verify_patch(self, position: int, expected_value: int) -> bool:
        """Verify that the patch was applied correctly."""
        # Clear cache to re-read fresh config space
        self._config_bytes = None

        try:
            new_bytes = self.read_config_space()
        except DeviceAccessError:
            return False
        else:
            actual_value = new_bytes[position] & 0b11  # Check only ASPM bits
            return actual_value == expected_value

    # NOTE: C901: complex-structure, PLR0912: too-many-branches
    def patch_aspm(  # noqa: C901, PLR0912
        self,
        requested_mode: ASPM | None = None,
        *,
        dry_run: bool = False,
        strict: bool = False,
    ) -> bool:
        """Patch ASPM settings for this device.

        Args:
            requested_mode: ASPM mode requested by user (None = use maximum supported)
            dry_run: If True, simulate without actually patching (default: False)
            strict: If True, enforce exact mode and allow downgrade/disable (default: False)

        Returns:
            True if patched/would patch, False if already set or skipped

        Raises:
            ASPMPatcherError: When patching fails or device doesn't support requested mode in strict mode
        """
        try:
            # Determine target ASPM mode
            if requested_mode is None:
                # If no request, use maximum supported mode
                target_aspm = self.supported_aspm
            else:
                if strict:
                    # Strict mode: fail if device doesn't support exact mode
                    if not self.supported_aspm.supports(requested_mode):
                        msg = (
                            f"Device supports {self.supported_aspm.name} "
                            f"but {requested_mode.name} was requested"
                        )
                        raise ASPMPatcherError(msg)
                    target_aspm = requested_mode
                else:
                    # Safe mode: use intersection of requested and supported modes
                    # This enables partial support (e.g., L1 if L0sL1 requested but only L1 supported)
                    intersection = self.supported_aspm.value & requested_mode.value
                    if intersection == 0:
                        logger.info(
                            "%s: ASPM %s (skipped, not supported)",
                            self.addr,
                            self.supported_aspm.name,
                        )
                        return False
                    target_aspm = ASPM(intersection)

            # Read config space
            endpoint_bytes = self.read_config_space()

            # Calculate Link Control Register location
            link_control_offset = self.get_link_control_offset()

            # Boundary check
            if link_control_offset >= len(endpoint_bytes):
                msg = f"Link Control offset {link_control_offset:#x} out of bounds"
                raise ASPMPatcherError(msg)

            current_value = endpoint_bytes[link_control_offset]
            current_aspm = ASPM(current_value & 0b11)

            # If already in target state
            if current_aspm == target_aspm:
                logger.info(
                    "%s: ASPM %s (skipped, already enabled)",
                    self.addr,
                    current_aspm.name,
                )
                return False

            # If current state already includes requested mode (e.g., L0sL1 when only L1 requested)
            # Skip this check in strict mode to allow downgrade
            if (
                not strict
                and requested_mode is not None
                and current_aspm.includes(requested_mode)
            ):
                logger.info(
                    "%s: ASPM %s (skipped, includes %s)",
                    self.addr,
                    current_aspm.name,
                    requested_mode.name,
                )
                return False

            # Calculate new value: change only lower 2 bits
            patched_byte = (current_value & ~0b11) | target_aspm.value

            # Apply patch or simulate
            if not dry_run:
                self._patch_byte(link_control_offset, patched_byte)

        except CapabilityNotFoundError as e:
            logger.warning(
                "%s: %sSkipping - %s",
                self.addr,
                "Would " if dry_run else "",
                e,
            )
            return False
        except DeviceAccessError as e:
            log_func = logger.info if dry_run else logger.error
            log_func(
                "%s: %s%s",
                self.addr,
                "Would encounter error - " if dry_run else "",
                e,
            )
            return False
        else:
            # Verify patch (only if not dry_run)
            if dry_run:
                logger.info(
                    "%s: ASPM %s would be enabled (current: %s)",
                    self.addr,
                    target_aspm.name,
                    current_aspm.name,
                )
            else:
                if self.verify_patch(link_control_offset, target_aspm.value):
                    logger.info(
                        "%s: ASPM %s enabled (was %s)",
                        self.addr,
                        target_aspm.name,
                        current_aspm.name,
                    )
                else:
                    logger.warning(
                        "%s: Patch applied but verification failed", self.addr
                    )
            return True


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


def check_prerequisites() -> None:
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


def get_aspm_devices() -> AbstractSet[PCIDevice]:
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

    devices: set[PCIDevice] = set()

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
                devices.add(PCIDevice(device_addr, aspm_mode))
            except KeyError:
                logger.warning(
                    "%s: Unknown ASPM mode '%s', skipping",
                    device_addr,
                    aspm_support[0],
                )
                continue

    return devices


def parse_device_overrides(
    device_modes: list[str] | None,
    skip_devices: list[str] | None,
) -> tuple[dict[str, ASPM], set[str]]:
    """Parse device mode overrides and skip list.

    Args:
        device_modes: List of "vendor:device=mode" strings
        skip_devices: List of "vendor:device" strings

    Returns:
        Tuple of (device_mode_map, skip_set)

    Raises:
        ASPMPatcherError: If format is invalid
    """
    device_mode_map: dict[str, ASPM] = {}
    skip_set: set[str] = set()

    # Regex for vendor:device format (4-digit hex : 4-digit hex)
    vendor_device_pattern = re.compile(r"^[0-9a-f]{4}:[0-9a-f]{4}$")

    # Parse --device-mode arguments
    if device_modes:
        for entry in device_modes:
            if "=" not in entry:
                msg = f"Invalid --device-mode format: '{entry}' (expected VENDOR:DEVICE=MODE)"
                raise ASPMPatcherError(msg)

            vendor_device, mode_str = entry.split("=", 1)
            vendor_device = vendor_device.lower()

            # Validate vendor:device format
            if not vendor_device_pattern.match(vendor_device):
                msg = (
                    f"Invalid vendor:device format: '{vendor_device}' "
                    f"(expected format: 8086:15b8)"
                )
                raise ASPMPatcherError(msg)

            # Validate and parse ASPM mode
            try:
                aspm_mode = ASPM.from_string(mode_str)
            except KeyError:
                msg = (
                    f"Invalid ASPM mode: '{mode_str}' "
                    f"(valid modes: l0s, l1, l0sl1, disabled)"
                )
                raise ASPMPatcherError(msg) from None

            device_mode_map[vendor_device] = aspm_mode

    # Parse --skip arguments
    if skip_devices:
        for vendor_device in skip_devices:
            vendor_device = vendor_device.lower()

            # Validate vendor:device format
            if not vendor_device_pattern.match(vendor_device):
                msg = (
                    f"Invalid vendor:device format: '{vendor_device}' "
                    f"(expected format: 8086:15b8)"
                )
                raise ASPMPatcherError(msg)

            skip_set.add(vendor_device)

    return (device_mode_map, skip_set)


def handle_list_mode(
    devices: Iterable[PCIDevice], *, verbose: bool = False
) -> None:
    """Handle --list mode to display ASPM-capable devices."""
    for device in devices:
        # Read current ASPM state
        try:
            current_aspm = device.get_current_aspm()
            current_str = current_aspm.name
        except (CapabilityNotFoundError, DeviceAccessError):
            current_str = "unknown"

        # Get vendor:device ID
        try:
            vendor_device_id = device.get_vendor_device_id()
        except DeviceAccessError:
            vendor_device_id = "unknown"

        # Print device info with vendor:device ID
        print(  # noqa: T201
            f"{device.addr} ({vendor_device_id}): "
            f"current={current_str}, supports={device.supported_aspm.name}"
        )

        # Print detailed device name only in verbose mode
        if verbose:
            try:
                device_name = device.get_name()
                print(f"  {device_name}")  # noqa: T201
            except DeviceAccessError:
                pass


def handle_patch_mode(
    devices: Iterable[PCIDevice],
    requested_mode: ASPM | None,
    dry_run: bool,
    device_mode_map: dict[str, ASPM],
    skip_set: set[str],
) -> tuple[int, int, int]:
    """Handle patch mode to patch or simulate ASPM settings on devices.

    Args:
        devices: Iterable of PCIDevice objects to patch
        requested_mode: Requested ASPM mode (None = use maximum supported)
        dry_run: If True, simulate without actually patching
        device_mode_map: Device-specific mode overrides (vendor:device -> ASPM)
        skip_set: Set of vendor:device IDs to skip

    Returns:
        Tuple of (patched_count, skipped_count, error_count)
    """
    patched_count = 0
    skipped_count = 0
    error_count = 0

    for device in devices:
        try:
            vendor_device_id = device.get_vendor_device_id()
        except DeviceAccessError as e:
            logger.error("%s: Failed to get vendor:device ID - %s", device.addr, e)
            error_count += 1
            continue

        # Check skip list
        if vendor_device_id in skip_set:
            logger.info("%s (%s): Skipped by user", device.addr, vendor_device_id)
            skipped_count += 1
            continue

        # Determine mode and strictness
        if vendor_device_id in device_mode_map:
            # Device-specific override: use strict mode
            mode_to_apply = device_mode_map[vendor_device_id]
            strict = True
        else:
            # Default mode: use safe mode
            mode_to_apply = requested_mode
            strict = False

        # Patch with determined mode
        try:
            if device.patch_aspm(mode_to_apply, dry_run=dry_run, strict=strict):
                patched_count += 1
            else:
                skipped_count += 1
        except ASPMPatcherError as e:
            logger.error("%s: Failed - %s", device.addr, e)
            error_count += 1

    return (patched_count, skipped_count, error_count)


class ArgsNamespace(argparse.Namespace):
    """Typed Namespace for parsed command-line arguments."""

    mode: str | None = None
    list_only: bool = False
    run: bool = False
    verbose: bool = False
    device_modes: list[str] | None = None
    skip_devices: list[str] | None = None


def parse_args() -> ArgsNamespace:
    """Parse command-line arguments."""
    parser = argparse.ArgumentParser(
        description="Enable ASPM (Active State Power Management) on PCIe devices",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s --list           List ASPM-capable devices
  %(prog)s --mode l0s       Simulate enabling L0s (dry-run)
  %(prog)s --mode l1 --run  Actually enable L1 on devices that support it
  %(prog)s --mode l0sl1     Simulate enabling L0s+L1 (dry-run)
  %(prog)s --list --verbose List devices with detailed information

Notes:
  - By default, --mode performs a dry-run simulation. Use --run to actually patch.
  - If a device is already in L0sL1 state and you request L1 only,
    the device will be skipped (not downgraded).
  - Requesting a mode the device doesn't support will skip that device.
""",
    )

    # Create mutually exclusive group for --mode and --list
    mode_group = parser.add_mutually_exclusive_group()
    _ = mode_group.add_argument(
        "--mode",
        "-m",
        type=str,
        choices=["l0s", "l1", "l0sl1", "disabled"],
        default=None,
        help="ASPM mode to enable. If not specified, enables maximum supported mode for each device.",
    )

    _ = mode_group.add_argument(
        "--list",
        "-l",
        action="store_true",
        dest="list_only",
        help="List ASPM-capable devices and their supported modes without patching",
    )

    _ = parser.add_argument(
        "--run",
        action="store_true",
        help="Actually apply patches (default is dry-run when --mode is specified)",
    )

    _ = parser.add_argument(
        "--verbose",
        "-v",
        action="store_true",
        help="Show detailed device information",
    )

    _ = parser.add_argument(
        "--device-mode",
        action="append",
        dest="device_modes",
        metavar="VENDOR:DEVICE=MODE",
        help="Set ASPM mode for specific device (can be repeated). Format: 8086:15b8=l1",
    )

    _ = parser.add_argument(
        "--skip",
        action="append",
        dest="skip_devices",
        metavar="VENDOR:DEVICE",
        help="Skip patching for specific device (can be repeated). Format: 8086:15b8",
    )

    args = parser.parse_args(namespace=ArgsNamespace())

    # If no meaningful arguments provided, print help and exit
    if args.mode is None and not args.list_only:
        parser.print_help()
        sys.exit(0)

    return args


def main():
    """Run the ASPM patcher."""
    args = parse_args()

    try:
        check_prerequisites()
    except (OSError, PermissionError, ASPMPatcherError) as e:
        logger.error("%s", e)
        return 1

    try:
        devices = get_aspm_devices()
    except ASPMPatcherError as e:
        logger.error("Error listing devices: %s", e)
        return 1

    if not devices:
        logger.info("No ASPM-capable devices found")
        return 0

    # --list option: print list only
    if args.list_only:
        handle_list_mode(devices, verbose=args.verbose)
        return 0

    # Parse requested ASPM mode
    requested_mode: ASPM | None = None
    if args.mode:
        requested_mode = ASPM.from_string(args.mode)

    # Determine if this is a dry-run (default) or actual run
    dry_run = not args.run

    logger.info("Found %d ASPM-capable device(s)", len(devices))
    if requested_mode:
        logger.info("Requested mode: %s", requested_mode.name)
    else:
        logger.info("Mode: auto (maximum supported per device)")

    if dry_run:
        logger.info("Running in dry-run mode (use --run to actually patch)")

    # Handle patch mode
    patched_count, skipped_count, error_count = handle_patch_mode(
        devices, requested_mode, dry_run
    )

    action_word = "would patch" if dry_run else "patched"
    logger.info(
        "Summary: %s %d, skipped %d, errors %d",
        action_word,
        patched_count,
        skipped_count,
        error_count,
    )

    return 0 if error_count == 0 else 1


if __name__ == "__main__":
    sys.exit(main())
