"""Tests for autoaspm module."""

import subprocess
from unittest.mock import Mock, patch

import pytest

from autoaspm import (
    ASPM,
    ASPMPatcherError,
    PCIDevice,
    CapabilityNotFoundError,
    DeviceAccessError,
    parse_device_overrides,
    handle_patch_mode,
)


# ============================================================================
# ASPM Enum Tests
# ============================================================================


class TestASPMEnum:
    """Test ASPM enum functionality."""

    def test_aspm_values(self):
        """Test ASPM enum values."""
        assert ASPM.DISABLED.value == 0b00
        assert ASPM.L0s.value == 0b01
        assert ASPM.L1.value == 0b10
        assert ASPM.L0sL1.value == 0b11

    def test_from_string_lowercase(self):
        """Test parsing ASPM mode from lowercase strings."""
        assert ASPM.from_string("disabled") == ASPM.DISABLED
        assert ASPM.from_string("l0s") == ASPM.L0s
        assert ASPM.from_string("l1") == ASPM.L1
        assert ASPM.from_string("l0sl1") == ASPM.L0sL1

    def test_from_string_mixed_case(self):
        """Test parsing ASPM mode from mixed case strings."""
        assert ASPM.from_string("DISABLED") == ASPM.DISABLED
        assert ASPM.from_string("L0S") == ASPM.L0s
        assert ASPM.from_string("L1") == ASPM.L1
        assert ASPM.from_string("L0SL1") == ASPM.L0sL1

    def test_from_string_invalid(self):
        """Test parsing invalid ASPM mode raises KeyError."""
        with pytest.raises(KeyError):
            ASPM.from_string("invalid")

    def test_supports_same_mode(self):
        """Test mode supports itself."""
        assert ASPM.L0s.supports(ASPM.L0s)
        assert ASPM.L1.supports(ASPM.L1)
        assert ASPM.L0sL1.supports(ASPM.L0sL1)

    def test_supports_combined_mode(self):
        """Test L0sL1 supports both L0s and L1."""
        assert ASPM.L0sL1.supports(ASPM.L0s)
        assert ASPM.L0sL1.supports(ASPM.L1)
        assert ASPM.L0sL1.supports(ASPM.L0sL1)

    def test_supports_single_modes(self):
        """Test single modes only support themselves."""
        assert not ASPM.L0s.supports(ASPM.L1)
        assert not ASPM.L0s.supports(ASPM.L0sL1)
        assert not ASPM.L1.supports(ASPM.L0s)
        assert not ASPM.L1.supports(ASPM.L0sL1)

    def test_includes(self):
        """Test includes method."""
        assert ASPM.L0sL1.includes(ASPM.L0s)
        assert ASPM.L0sL1.includes(ASPM.L1)
        assert ASPM.L0sL1.includes(ASPM.L0sL1)
        assert ASPM.L0s.includes(ASPM.L0s)
        assert not ASPM.L0s.includes(ASPM.L1)


# ============================================================================
# PCIDevice Tests
# ============================================================================


class TestPCIDeviceInit:
    """Test PCIDevice initialization."""

    def test_init(self):
        """Test PCIDevice initialization."""
        device = PCIDevice("01:00.0", ASPM.L0sL1)
        assert device.addr == "01:00.0"
        assert device.supported_aspm == ASPM.L0sL1
        assert device._config_bytes is None
        assert device._pcie_cap_offset is None
        assert device._device_name is None

    def test_init_with_different_aspm_mode(self):
        """Test PCIDevice initialization with different ASPM modes."""
        device_l0s = PCIDevice("02:00.0", ASPM.L0s)
        assert device_l0s.supported_aspm == ASPM.L0s

        device_l1 = PCIDevice("03:00.0", ASPM.L1)
        assert device_l1.supported_aspm == ASPM.L1

        device_disabled = PCIDevice("04:00.0", ASPM.DISABLED)
        assert device_disabled.supported_aspm == ASPM.DISABLED


class TestPCIDeviceGetName:
    """Test PCIDevice.get_name() method."""

    @patch("subprocess.run")
    def test_get_name_success(self, mock_run):
        """Test successful device name retrieval."""
        mock_run.return_value = Mock(
            returncode=0,
            stdout="01:00.0 Network controller: Intel Corporation...",
        )
        device = PCIDevice("01:00.0", ASPM.L0sL1)
        name = device.get_name()
        assert "Network controller" in name
        mock_run.assert_called_once()

    @patch("subprocess.run")
    def test_get_name_caching(self, mock_run):
        """Test that device name is cached."""
        mock_run.return_value = Mock(
            returncode=0,
            stdout="01:00.0 Network controller: Intel Corporation...",
        )
        device = PCIDevice("01:00.0", ASPM.L0sL1)
        name1 = device.get_name()
        name2 = device.get_name()
        assert name1 == name2
        # Should only be called once due to caching
        assert mock_run.call_count == 1

    @patch("subprocess.run")
    def test_get_name_command_failure(self, mock_run):
        """Test handling of lspci failure."""
        mock_run.return_value = Mock(returncode=1, stderr="Device not found")
        device = PCIDevice("01:00.0", ASPM.L0sL1)
        with pytest.raises(
            DeviceAccessError, match="Failed to get device name"
        ):
            device.get_name()

    @patch("subprocess.run")
    def test_get_name_no_output(self, mock_run):
        """Test handling of empty lspci output."""
        mock_run.return_value = Mock(returncode=0, stdout="")
        device = PCIDevice("01:00.0", ASPM.L0sL1)
        with pytest.raises(DeviceAccessError, match="No device found"):
            device.get_name()

    @patch("subprocess.run")
    def test_get_name_timeout(self, mock_run):
        """Test handling of subprocess timeout."""
        mock_run.side_effect = subprocess.TimeoutExpired("lspci", 10)
        device = PCIDevice("01:00.0", ASPM.L0sL1)
        with pytest.raises(DeviceAccessError, match="Timeout"):
            device.get_name()


class TestPCIDeviceReadConfigSpace:
    """Test PCIDevice.read_config_space() method."""

    @patch("subprocess.run")
    def test_read_config_space_success(self, mock_run):
        """Test successful config space reading."""
        # Simulate lspci -xxx output (256 bytes / 16 bytes per line = 16 lines)
        hex_lines = []
        for i in range(16):
            offset = i * 16
            # First line has the device name
            if i == 0:
                hex_lines.append(
                    "01:00.0 Network controller: Intel Corporation..."
                )
                hex_lines.append(
                    f"{offset:02x}: 86 80 24 43 07 04 10 00 10 00 80 02 00 00 00 00"
                )
            else:
                hex_lines.append(
                    f"{offset:02x}: " + " ".join(f"{j:02x}" for j in range(16))
                )

        lspci_output = "\n".join(hex_lines)
        mock_run.return_value = Mock(returncode=0, stdout=lspci_output)

        device = PCIDevice("01:00.0", ASPM.L0sL1)
        config = device.read_config_space()

        # Should have at least 256 bytes (PCI_CONFIG_SPACE_SIZE)
        assert len(config) >= 256
        assert isinstance(config, bytearray)
        # First byte should be 0x86
        assert config[0] == 0x86

    @patch.object(PCIDevice, "get_name")
    @patch("subprocess.run")
    def test_read_config_space_caching(self, mock_run, mock_get_name):
        """Test that config space is cached."""
        mock_get_name.return_value = "01:00.0 Network controller: Intel..."

        hex_lines = []
        for i in range(16):
            offset = i * 16
            if i == 0:
                hex_lines.append(
                    f"{offset:02x}: 86 80 24 43 07 04 10 00 10 00 80 02 00 00 00 00"
                )
            else:
                hex_lines.append(
                    f"{offset:02x}: " + " ".join(f"{j:02x}" for j in range(16))
                )

        lspci_output = "\n".join(hex_lines)
        mock_run.return_value = Mock(returncode=0, stdout=lspci_output)

        device = PCIDevice("01:00.0", ASPM.L0sL1)
        config1 = device.read_config_space()
        config2 = device.read_config_space()

        assert config1 is config2
        # lspci should only be called once due to caching
        assert mock_run.call_count == 1

    @patch("subprocess.run")
    def test_read_config_space_incomplete(self, mock_run):
        """Test handling of incomplete config space."""
        # Only 100 bytes instead of 256
        mock_run.return_value = Mock(
            returncode=0,
            stdout="01:00.0 Network controller...\n"
            "00: " + " ".join(f"{i:02x}" for i in range(100)),
        )
        device = PCIDevice("01:00.0", ASPM.L0sL1)
        with pytest.raises(DeviceAccessError, match="Incomplete config space"):
            device.read_config_space()

    @patch("subprocess.run")
    def test_read_config_space_command_failure(self, mock_run):
        """Test handling of lspci failure."""
        mock_run.return_value = Mock(returncode=1, stderr="Command failed")
        device = PCIDevice("01:00.0", ASPM.L0sL1)
        with pytest.raises(
            DeviceAccessError, match="Failed to read config space"
        ):
            device.read_config_space()


class TestPCIDeviceFindPCIeCapability:
    """Test PCIDevice.find_pcie_capability() method."""

    def _create_config_with_pcie_cap(
        self, cap_offset: int = 0x40
    ) -> bytearray:
        """Create a config space with PCIe capability."""
        config = bytearray(256)
        # Set capability list pointer (at offset 0x34)
        config[0x34] = cap_offset

        # Set PCIe capability at cap_offset
        # Capability ID (0x10 = PCIe) at offset
        config[cap_offset] = 0x10
        # Next capability pointer (0 = last)
        config[cap_offset + 1] = 0x00

        return config

    @patch.object(PCIDevice, "read_config_space")
    def test_find_pcie_capability_success(self, mock_read):
        """Test successful PCIe capability finding."""
        config = self._create_config_with_pcie_cap(0x40)
        mock_read.return_value = config

        device = PCIDevice("01:00.0", ASPM.L0sL1)
        offset = device.find_pcie_capability()

        assert offset == 0x40

    @patch.object(PCIDevice, "read_config_space")
    def test_find_pcie_capability_caching(self, mock_read):
        """Test that capability offset is cached."""
        config = self._create_config_with_pcie_cap(0x40)
        mock_read.return_value = config

        device = PCIDevice("01:00.0", ASPM.L0sL1)
        offset1 = device.find_pcie_capability()
        offset2 = device.find_pcie_capability()

        assert offset1 == offset2
        # read_config_space should only be called once
        assert mock_read.call_count == 1

    @patch.object(PCIDevice, "read_config_space")
    def test_find_pcie_capability_not_found(self, mock_read):
        """Test when PCIe capability is not found."""
        config = bytearray(256)
        # Set invalid capability pointer
        config[0x34] = 0

        mock_read.return_value = config

        device = PCIDevice("01:00.0", ASPM.L0sL1)
        with pytest.raises(CapabilityNotFoundError, match="Invalid or no"):
            device.find_pcie_capability()

    @patch.object(PCIDevice, "read_config_space")
    def test_find_pcie_capability_out_of_bounds(self, mock_read):
        """Test when capability pointer is out of bounds."""
        config = bytearray(256)
        # Set capability pointer to 0xFC (4-byte aligned, but out of bounds in loop)
        config[0x34] = 0xFC
        # Set capability ID at 0xFC to non-PCIe
        config[0xFC] = 0x01
        # Set next pointer to go out of bounds
        config[0xFD] = 0xFF

        mock_read.return_value = config

        device = PCIDevice("01:00.0", ASPM.L0sL1)
        with pytest.raises(CapabilityNotFoundError, match="out of bounds"):
            device.find_pcie_capability()


class TestPCIDeviceGetLinkControlOffset:
    """Test PCIDevice.get_link_control_offset() method."""

    @patch.object(PCIDevice, "find_pcie_capability")
    def test_get_link_control_offset(self, mock_find):
        """Test Link Control offset calculation."""
        mock_find.return_value = 0x40

        device = PCIDevice("01:00.0", ASPM.L0sL1)
        offset = device.get_link_control_offset()

        # PCIE_CAP_LINK_CONTROL_OFFSET = 0x10
        assert offset == 0x40 + 0x10


class TestPCIDeviceGetCurrentASPM:
    """Test PCIDevice.get_current_aspm() method."""

    @patch.object(PCIDevice, "get_link_control_offset")
    @patch.object(PCIDevice, "read_config_space")
    def test_get_current_aspm_l0s(self, mock_read, mock_offset):
        """Test reading L0s ASPM state."""
        config = bytearray(256)
        config[0x50] = 0b01  # L0s mode in lower 2 bits
        mock_read.return_value = config
        mock_offset.return_value = 0x50

        device = PCIDevice("01:00.0", ASPM.L0sL1)
        aspm = device.get_current_aspm()

        assert aspm == ASPM.L0s

    @patch.object(PCIDevice, "get_link_control_offset")
    @patch.object(PCIDevice, "read_config_space")
    def test_get_current_aspm_l0sl1(self, mock_read, mock_offset):
        """Test reading L0sL1 ASPM state."""
        config = bytearray(256)
        config[0x50] = 0b11  # L0sL1 mode
        mock_read.return_value = config
        mock_offset.return_value = 0x50

        device = PCIDevice("01:00.0", ASPM.L0sL1)
        aspm = device.get_current_aspm()

        assert aspm == ASPM.L0sL1

    @patch.object(PCIDevice, "get_link_control_offset")
    @patch.object(PCIDevice, "read_config_space")
    def test_get_current_aspm_masks_upper_bits(self, mock_read, mock_offset):
        """Test that upper bits are masked."""
        config = bytearray(256)
        # Set upper bits to 1, lower bits to L1 (0b10)
        config[0x50] = 0b11110010
        mock_read.return_value = config
        mock_offset.return_value = 0x50

        device = PCIDevice("01:00.0", ASPM.L0sL1)
        aspm = device.get_current_aspm()

        # Should only consider lower 2 bits
        assert aspm == ASPM.L1


class TestPCIDevicePatchByte:
    """Test PCIDevice._patch_byte() method."""

    @patch("subprocess.run")
    def test_patch_byte_success(self, mock_run):
        """Test successful byte patching."""
        mock_run.return_value = Mock(returncode=0, stderr="")

        device = PCIDevice("01:00.0", ASPM.L0sL1)
        device._config_bytes = bytearray(256)  # Set cache
        device._patch_byte(0x50, 0x03)

        # Cache should be invalidated
        assert device._config_bytes is None
        # setpci should be called
        mock_run.assert_called_once()
        call_args = mock_run.call_args
        assert "setpci" in call_args[0][0]

    @patch("subprocess.run")
    def test_patch_byte_failure(self, mock_run):
        """Test handling of patch failure."""
        mock_run.return_value = Mock(
            returncode=1, stderr="Operation not permitted"
        )

        device = PCIDevice("01:00.0", ASPM.L0sL1)
        with pytest.raises(DeviceAccessError, match="Failed to patch"):
            device._patch_byte(0x50, 0x03)

    @patch("subprocess.run")
    def test_patch_byte_timeout(self, mock_run):
        """Test handling of timeout."""
        mock_run.side_effect = subprocess.TimeoutExpired("setpci", 10)

        device = PCIDevice("01:00.0", ASPM.L0sL1)
        with pytest.raises(DeviceAccessError, match="Timeout"):
            device._patch_byte(0x50, 0x03)


class TestPCIDeviceVerifyPatch:
    """Test PCIDevice.verify_patch() method."""

    @patch.object(PCIDevice, "read_config_space")
    def test_verify_patch_success(self, mock_read):
        """Test successful patch verification."""
        config = bytearray(256)
        config[0x50] = 0b11
        mock_read.return_value = config

        device = PCIDevice("01:00.0", ASPM.L0sL1)
        result = device.verify_patch(0x50, 0b11)

        assert result is True

    @patch.object(PCIDevice, "read_config_space")
    def test_verify_patch_failure(self, mock_read):
        """Test patch verification failure."""
        config = bytearray(256)
        config[0x50] = 0b01  # Different value
        mock_read.return_value = config

        device = PCIDevice("01:00.0", ASPM.L0sL1)
        result = device.verify_patch(0x50, 0b11)

        assert result is False

    @patch.object(PCIDevice, "read_config_space")
    def test_verify_patch_error_handling(self, mock_read):
        """Test error handling in verify."""
        mock_read.side_effect = DeviceAccessError("Read failed")

        device = PCIDevice("01:00.0", ASPM.L0sL1)
        result = device.verify_patch(0x50, 0b11)

        assert result is False


class TestPCIDevicePatchASPM:
    """Test PCIDevice.patch_aspm() method."""

    @patch.object(PCIDevice, "verify_patch")
    @patch.object(PCIDevice, "_patch_byte")
    @patch.object(PCIDevice, "get_link_control_offset")
    @patch.object(PCIDevice, "read_config_space")
    def test_patch_aspm_no_change(
        self, mock_read, mock_offset, mock_patch, mock_verify
    ):
        """Test when device is already in target state."""
        config = bytearray(256)
        config[0x50] = ASPM.L0sL1.value  # Already L0sL1
        mock_read.return_value = config
        mock_offset.return_value = 0x50

        device = PCIDevice("01:00.0", ASPM.L0sL1)
        result = device.patch_aspm(ASPM.L0sL1)

        assert result is False
        mock_patch.assert_not_called()

    @patch.object(PCIDevice, "verify_patch")
    @patch.object(PCIDevice, "_patch_byte")
    @patch.object(PCIDevice, "get_link_control_offset")
    @patch.object(PCIDevice, "read_config_space")
    def test_patch_aspm_success(
        self, mock_read, mock_offset, mock_patch, mock_verify
    ):
        """Test successful ASPM patching."""
        config = bytearray(256)
        config[0x50] = ASPM.DISABLED.value  # Currently disabled
        mock_read.return_value = config
        mock_offset.return_value = 0x50
        mock_verify.return_value = True

        device = PCIDevice("01:00.0", ASPM.L0sL1)
        result = device.patch_aspm(ASPM.L0sL1)

        assert result is True
        mock_patch.assert_called_once()

    @patch.object(PCIDevice, "get_link_control_offset")
    @patch.object(PCIDevice, "read_config_space")
    def test_patch_aspm_unsupported_mode(self, mock_read, mock_offset):
        """Test when requested mode is not supported by device."""
        config = bytearray(256)
        config[0x50] = ASPM.L0s.value  # Currently L0s
        mock_read.return_value = config
        mock_offset.return_value = 0x50

        device = PCIDevice("01:00.0", ASPM.L0s)  # Device only supports L0s
        # Request L1 when device only supports L0s
        result = device.patch_aspm(ASPM.L1)

        assert result is False

    @patch.object(PCIDevice, "verify_patch")
    @patch.object(PCIDevice, "_patch_byte")
    @patch.object(PCIDevice, "get_link_control_offset")
    @patch.object(PCIDevice, "read_config_space")
    def test_patch_aspm_dry_run_would_patch(
        self, mock_read, mock_offset, mock_patch, mock_verify
    ):
        """Test dry_run=True reports would patch without actually patching."""
        config = bytearray(256)
        config[0x50] = ASPM.DISABLED.value  # Currently disabled
        mock_read.return_value = config
        mock_offset.return_value = 0x50

        device = PCIDevice("01:00.0", ASPM.L0sL1)
        result = device.patch_aspm(ASPM.L0sL1, dry_run=True)

        assert result is True
        mock_patch.assert_not_called()
        mock_verify.assert_not_called()

    @patch.object(PCIDevice, "get_link_control_offset")
    @patch.object(PCIDevice, "read_config_space")
    def test_patch_aspm_dry_run_would_skip(self, mock_read, mock_offset):
        """Test dry_run=True reports would skip when already set."""
        config = bytearray(256)
        config[0x50] = ASPM.L0sL1.value  # Already L0sL1
        mock_read.return_value = config
        mock_offset.return_value = 0x50

        device = PCIDevice("01:00.0", ASPM.L0sL1)
        result = device.patch_aspm(ASPM.L0sL1, dry_run=True)

        assert result is False

    @patch.object(PCIDevice, "verify_patch")
    @patch.object(PCIDevice, "_patch_byte")
    @patch.object(PCIDevice, "get_link_control_offset")
    @patch.object(PCIDevice, "read_config_space")
    def test_patch_aspm_actual_run_patches(
        self, mock_read, mock_offset, mock_patch, mock_verify
    ):
        """Test dry_run=False actually patches."""
        config = bytearray(256)
        config[0x50] = ASPM.DISABLED.value  # Currently disabled
        mock_read.return_value = config
        mock_offset.return_value = 0x50
        mock_verify.return_value = True

        device = PCIDevice("01:00.0", ASPM.L0sL1)
        result = device.patch_aspm(ASPM.L0sL1, dry_run=False)

        assert result is True
        mock_patch.assert_called_once()
        mock_verify.assert_called_once()


# ============================================================================
# Integration Tests
# ============================================================================


class TestIntegration:
    """Integration tests."""

    @patch("subprocess.run")
    def test_device_workflow(self, mock_run):
        """Test typical device workflow."""
        # Setup mock responses
        device_name_response = Mock(
            returncode=0, stdout="01:00.0 Network controller: Intel..."
        )
        config_response = Mock(
            returncode=0,
            stdout="""01:00.0 Network controller: Intel...
00: 86 80 24 43 07 04 10 00 10 00 80 02 00 00 00 00
"""
            + "\n".join(
                [
                    f"{i:02x}: " + " ".join(f"{j:02x}" for j in range(16))
                    for i in range(1, 16)
                ]
            ),
        )

        mock_run.side_effect = [device_name_response, config_response]

        device = PCIDevice("01:00.0", ASPM.L0sL1)
        name = device.get_name()
        config = device.read_config_space()

        assert "Network controller" in name
        assert len(config) >= 256


# ============================================================================
# Vendor:Device ID Tests
# ============================================================================


class TestPCIDeviceGetVendorDeviceId:
    """Test PCIDevice.get_vendor_device_id() method."""

    @patch("subprocess.run")
    def test_get_vendor_device_id_success(self, mock_run):
        """Test successful vendor:device ID retrieval."""
        mock_run.return_value = Mock(
            returncode=0,
            stdout="01:00.0 0280: 8086:15b8 (rev 34)\n",
        )
        device = PCIDevice("01:00.0", ASPM.L0sL1)
        vendor_device_id = device.get_vendor_device_id()
        assert vendor_device_id == "8086:15b8"
        mock_run.assert_called_once()

    @patch("subprocess.run")
    def test_get_vendor_device_id_caching(self, mock_run):
        """Test that vendor:device ID is cached."""
        mock_run.return_value = Mock(
            returncode=0,
            stdout="01:00.0 0280: 8086:15b8 (rev 34)\n",
        )
        device = PCIDevice("01:00.0", ASPM.L0sL1)
        id1 = device.get_vendor_device_id()
        id2 = device.get_vendor_device_id()
        assert id1 == id2 == "8086:15b8"
        # Should only be called once due to caching
        assert mock_run.call_count == 1

    @patch("subprocess.run")
    def test_get_vendor_device_id_command_failure(self, mock_run):
        """Test handling of lspci failure."""
        mock_run.return_value = Mock(returncode=1, stderr="Device not found")
        device = PCIDevice("01:00.0", ASPM.L0sL1)
        with pytest.raises(
            DeviceAccessError, match="Failed to get vendor:device ID"
        ):
            device.get_vendor_device_id()

    @patch("subprocess.run")
    def test_get_vendor_device_id_no_output(self, mock_run):
        """Test handling of empty lspci output."""
        mock_run.return_value = Mock(returncode=0, stdout="")
        device = PCIDevice("01:00.0", ASPM.L0sL1)
        with pytest.raises(DeviceAccessError, match="No device found"):
            device.get_vendor_device_id()

    @patch("subprocess.run")
    def test_get_vendor_device_id_parse_failure(self, mock_run):
        """Test handling of unparseable output."""
        mock_run.return_value = Mock(
            returncode=0,
            stdout="01:00.0 Invalid output format\n",
        )
        device = PCIDevice("01:00.0", ASPM.L0sL1)
        with pytest.raises(DeviceAccessError, match="Could not parse"):
            device.get_vendor_device_id()

    @patch("subprocess.run")
    def test_get_vendor_device_id_timeout(self, mock_run):
        """Test handling of subprocess timeout."""
        mock_run.side_effect = subprocess.TimeoutExpired("lspci", 10)
        device = PCIDevice("01:00.0", ASPM.L0sL1)
        with pytest.raises(DeviceAccessError, match="Timeout"):
            device.get_vendor_device_id()


# ============================================================================
# Device Override Parsing Tests
# ============================================================================


class TestParseDeviceOverrides:
    """Test parse_device_overrides() function."""

    def test_parse_device_modes_valid(self):
        """Test parsing valid device-mode arguments."""
        device_modes = [
            "8086:15b8=l1",
            "10de:1234=l0sl1",
            "1002:abcd=disabled",
        ]
        device_mode_map, skip_set = parse_device_overrides(device_modes, None)

        assert len(device_mode_map) == 3
        assert device_mode_map["8086:15b8"] == ASPM.L1
        assert device_mode_map["10de:1234"] == ASPM.L0sL1
        assert device_mode_map["1002:abcd"] == ASPM.DISABLED
        assert len(skip_set) == 0

    def test_parse_skip_devices_valid(self):
        """Test parsing valid skip arguments."""
        skip_devices = ["8086:15b8", "10de:1234"]
        device_mode_map, skip_set = parse_device_overrides(None, skip_devices)

        assert len(device_mode_map) == 0
        assert skip_set == {"8086:15b8", "10de:1234"}

    def test_parse_both_modes_and_skip(self):
        """Test parsing both device-mode and skip arguments."""
        device_modes = ["8086:15b8=l1"]
        skip_devices = ["10de:1234"]
        device_mode_map, skip_set = parse_device_overrides(
            device_modes, skip_devices
        )

        assert device_mode_map == {"8086:15b8": ASPM.L1}
        assert skip_set == {"10de:1234"}

    def test_parse_empty_arguments(self):
        """Test parsing empty arguments."""
        device_mode_map, skip_set = parse_device_overrides(None, None)

        assert len(device_mode_map) == 0
        assert len(skip_set) == 0

    def test_parse_uppercase_vendor_device(self):
        """Test that uppercase vendor:device is converted to lowercase."""
        device_modes = ["8086:15B8=l1"]
        device_mode_map, _ = parse_device_overrides(device_modes, None)

        assert "8086:15b8" in device_mode_map

    def test_invalid_device_mode_format_no_equals(self):
        """Test invalid device-mode format (missing =)."""
        device_modes = ["8086:15b8"]
        with pytest.raises(
            ASPMPatcherError, match="Invalid --device-mode format"
        ):
            parse_device_overrides(device_modes, None)

    def test_invalid_vendor_device_format_in_mode(self):
        """Test invalid vendor:device format in device-mode."""
        device_modes = ["invalid=l1"]
        with pytest.raises(
            ASPMPatcherError, match="Invalid vendor:device format"
        ):
            parse_device_overrides(device_modes, None)

    def test_invalid_vendor_device_format_in_skip(self):
        """Test invalid vendor:device format in skip."""
        skip_devices = ["invalid"]
        with pytest.raises(
            ASPMPatcherError, match="Invalid vendor:device format"
        ):
            parse_device_overrides(None, skip_devices)

    def test_invalid_aspm_mode(self):
        """Test invalid ASPM mode."""
        device_modes = ["8086:15b8=invalid"]
        with pytest.raises(ASPMPatcherError, match="Invalid ASPM mode"):
            parse_device_overrides(device_modes, None)

    def test_vendor_device_too_short(self):
        """Test vendor:device with too few hex digits."""
        device_modes = ["86:15b8=l1"]
        with pytest.raises(
            ASPMPatcherError, match="Invalid vendor:device format"
        ):
            parse_device_overrides(device_modes, None)

    def test_vendor_device_too_long(self):
        """Test vendor:device with too many hex digits."""
        device_modes = ["80860:15b8=l1"]
        with pytest.raises(
            ASPMPatcherError, match="Invalid vendor:device format"
        ):
            parse_device_overrides(device_modes, None)


# ============================================================================
# Strict Mode Tests
# ============================================================================


class TestPatchASPMStrictMode:
    """Test strict mode in patch_aspm() method."""

    @patch.object(PCIDevice, "verify_patch")
    @patch.object(PCIDevice, "_patch_byte")
    @patch.object(PCIDevice, "get_link_control_offset")
    @patch.object(PCIDevice, "read_config_space")
    def test_strict_mode_allows_downgrade(
        self, mock_read, mock_offset, mock_patch, mock_verify
    ):
        """Test strict mode allows downgrade (L0sL1 → L1)."""
        config = bytearray(256)
        config[0x50] = ASPM.L0sL1.value  # Currently L0sL1
        mock_read.return_value = config
        mock_offset.return_value = 0x50
        mock_verify.return_value = True

        device = PCIDevice("01:00.0", ASPM.L0sL1)
        # Request L1 only with strict mode
        result = device.patch_aspm(ASPM.L1, strict=True, dry_run=False)

        assert result is True
        mock_patch.assert_called_once()

    @patch.object(PCIDevice, "verify_patch")
    @patch.object(PCIDevice, "_patch_byte")
    @patch.object(PCIDevice, "get_link_control_offset")
    @patch.object(PCIDevice, "read_config_space")
    def test_strict_mode_allows_disable(
        self, mock_read, mock_offset, mock_patch, mock_verify
    ):
        """Test strict mode allows disable (L1 → DISABLED)."""
        config = bytearray(256)
        config[0x50] = ASPM.L1.value  # Currently L1
        mock_read.return_value = config
        mock_offset.return_value = 0x50
        mock_verify.return_value = True

        device = PCIDevice("01:00.0", ASPM.L1)
        # Request DISABLED with strict mode
        result = device.patch_aspm(ASPM.DISABLED, strict=True, dry_run=False)

        assert result is True
        mock_patch.assert_called_once()

    @patch.object(PCIDevice, "get_link_control_offset")
    @patch.object(PCIDevice, "read_config_space")
    def test_strict_mode_fails_on_unsupported(self, mock_read, mock_offset):
        """Test strict mode fails if device doesn't support requested mode."""
        config = bytearray(256)
        config[0x50] = ASPM.DISABLED.value
        mock_read.return_value = config
        mock_offset.return_value = 0x50

        device = PCIDevice("01:00.0", ASPM.L0s)  # Device only supports L0s
        # Request L1 when device only supports L0s
        with pytest.raises(
            ASPMPatcherError,
            match="Device supports L0s but L1 was requested",
        ):
            device.patch_aspm(ASPM.L1, strict=True)

    @patch.object(PCIDevice, "get_link_control_offset")
    @patch.object(PCIDevice, "read_config_space")
    def test_safe_mode_prevents_downgrade(self, mock_read, mock_offset):
        """Test safe mode prevents downgrade (L0sL1 → L1)."""
        config = bytearray(256)
        config[0x50] = ASPM.L0sL1.value  # Currently L0sL1
        mock_read.return_value = config
        mock_offset.return_value = 0x50

        device = PCIDevice("01:00.0", ASPM.L0sL1)
        # Request L1 only with safe mode (strict=False)
        result = device.patch_aspm(ASPM.L1, strict=False)

        assert result is False  # Should skip (no downgrade)

    @patch.object(PCIDevice, "verify_patch")
    @patch.object(PCIDevice, "_patch_byte")
    @patch.object(PCIDevice, "get_link_control_offset")
    @patch.object(PCIDevice, "read_config_space")
    def test_safe_mode_uses_intersection(
        self, mock_read, mock_offset, mock_patch, mock_verify
    ):
        """Test safe mode uses intersection (existing behavior)."""
        config = bytearray(256)
        config[0x50] = ASPM.DISABLED.value  # Currently disabled
        mock_read.return_value = config
        mock_offset.return_value = 0x50
        mock_verify.return_value = True

        device = PCIDevice("01:00.0", ASPM.L1)  # Device supports L1
        # Request L0sL1 but device only supports L1
        result = device.patch_aspm(ASPM.L0sL1, strict=False, dry_run=False)

        # Should patch with L1 (intersection of L1 and L0sL1)
        assert result is True
        mock_patch.assert_called_once()

    @patch.object(PCIDevice, "get_link_control_offset")
    @patch.object(PCIDevice, "read_config_space")
    def test_safe_mode_skips_when_no_intersection(
        self, mock_read, mock_offset
    ):
        """Test safe mode skips when intersection is zero."""
        config = bytearray(256)
        config[0x50] = ASPM.DISABLED.value  # Currently disabled
        mock_read.return_value = config
        mock_offset.return_value = 0x50

        device = PCIDevice("01:00.0", ASPM.L0s)  # Device supports L0s
        # Request L1 but device only supports L0s (no intersection)
        result = device.patch_aspm(ASPM.L1, strict=False)

        # Should skip because intersection is 0
        assert result is False


# ============================================================================
# Handle Patch Mode Tests (Device-Mode Only Behavior)
# ============================================================================


class TestHandlePatchModeDeviceModeOnly:
    """Test handle_patch_mode() when only device-mode is specified."""

    @patch.object(PCIDevice, "get_vendor_device_id")
    @patch.object(PCIDevice, "patch_aspm")
    def test_device_mode_only_patches_specified_device(
        self, mock_patch_aspm, mock_get_id
    ):
        """Test that only device with --device-mode is patched when no --mode specified."""
        # Create two devices
        device1 = PCIDevice("01:00.0", ASPM.L0sL1)
        device2 = PCIDevice("02:00.0", ASPM.L1)

        # Setup mocks
        mock_get_id.side_effect = ["1022:1668", "8086:15b8"]
        mock_patch_aspm.return_value = True

        # Call with no requested_mode, only device override for device1
        device_mode_map = {"1022:1668": ASPM.L0sL1}
        skip_set: set[str] = set()

        patched, skipped, errors = handle_patch_mode(
            devices=[device1, device2],
            requested_mode=None,  # No default mode
            dry_run=False,
            device_mode_map=device_mode_map,
            skip_set=skip_set,
        )

        # device1 should be patched with strict mode
        # device2 should be skipped (no override, no default mode)
        assert patched == 1
        assert skipped == 1
        assert errors == 0

        # Verify patch_aspm was called only once for device1
        assert mock_patch_aspm.call_count == 1
        # Verify it was called with strict=True for device1
        call_args = mock_patch_aspm.call_args_list[0]
        assert call_args[0][0] == ASPM.L0sL1  # requested_mode
        assert call_args[1]["strict"] is True

    @patch.object(PCIDevice, "get_vendor_device_id")
    @patch.object(PCIDevice, "patch_aspm")
    def test_device_mode_with_default_mode_patches_all(
        self, mock_patch_aspm, mock_get_id
    ):
        """Test that all devices are patched when both --mode and --device-mode specified."""
        # Create two devices
        device1 = PCIDevice("01:00.0", ASPM.L0sL1)
        device2 = PCIDevice("02:00.0", ASPM.L1)

        # Setup mocks
        mock_get_id.side_effect = ["1022:1668", "8086:15b8"]
        mock_patch_aspm.return_value = True

        # Call with requested_mode=L1 and device override for device1
        device_mode_map = {"1022:1668": ASPM.L0sL1}
        skip_set: set[str] = set()

        patched, skipped, errors = handle_patch_mode(
            devices=[device1, device2],
            requested_mode=ASPM.L1,  # Default mode for all devices
            dry_run=False,
            device_mode_map=device_mode_map,
            skip_set=skip_set,
        )

        # Both devices should be patched
        assert patched == 2
        assert skipped == 0
        assert errors == 0

        # Verify patch_aspm was called twice
        assert mock_patch_aspm.call_count == 2

        # First call (device1): strict mode with L0sL1
        call1 = mock_patch_aspm.call_args_list[0]
        assert call1[0][0] == ASPM.L0sL1
        assert call1[1]["strict"] is True

        # Second call (device2): safe mode with L1
        call2 = mock_patch_aspm.call_args_list[1]
        assert call2[0][0] == ASPM.L1
        assert call2[1]["strict"] is False

    @patch.object(PCIDevice, "get_vendor_device_id")
    @patch.object(PCIDevice, "patch_aspm")
    def test_multiple_device_modes_without_default(
        self, mock_patch_aspm, mock_get_id
    ):
        """Test multiple --device-mode without --mode only patches specified devices."""
        # Create three devices
        device1 = PCIDevice("01:00.0", ASPM.L0sL1)
        device2 = PCIDevice("02:00.0", ASPM.L1)
        device3 = PCIDevice("03:00.0", ASPM.L0s)

        # Setup mocks
        mock_get_id.side_effect = ["1022:1668", "8086:15b8", "10de:1234"]
        mock_patch_aspm.return_value = True

        # Call with no requested_mode, device overrides for device1 and device3
        device_mode_map = {"1022:1668": ASPM.L0sL1, "10de:1234": ASPM.DISABLED}
        skip_set: set[str] = set()

        patched, skipped, errors = handle_patch_mode(
            devices=[device1, device2, device3],
            requested_mode=None,  # No default mode
            dry_run=False,
            device_mode_map=device_mode_map,
            skip_set=skip_set,
        )

        # device1 and device3 should be patched, device2 should be skipped
        assert patched == 2
        assert skipped == 1
        assert errors == 0

        # Verify patch_aspm was called twice
        assert mock_patch_aspm.call_count == 2

    @patch.object(PCIDevice, "get_current_aspm")
    @patch.object(PCIDevice, "get_vendor_device_id")
    @patch.object(PCIDevice, "patch_aspm")
    def test_skip_device_shows_current_aspm(
        self, mock_patch_aspm, mock_get_id, mock_get_current_aspm
    ):
        """Test that skipped devices display their current ASPM state."""
        # Create two devices
        device1 = PCIDevice("01:00.0", ASPM.L0sL1)
        device2 = PCIDevice("02:00.0", ASPM.L1)

        # Setup mocks
        mock_get_id.side_effect = ["1022:1502", "8086:15b8"]
        mock_get_current_aspm.return_value = ASPM.L1
        mock_patch_aspm.return_value = True

        # Call with device1 in skip list
        device_mode_map: dict[str, ASPM] = {}
        skip_set = {"1022:1502"}

        patched, skipped, errors = handle_patch_mode(
            devices=[device1, device2],
            requested_mode=ASPM.L0sL1,
            dry_run=False,
            device_mode_map=device_mode_map,
            skip_set=skip_set,
        )

        # device1 should be skipped, device2 should be patched
        assert patched == 1
        assert skipped == 1
        assert errors == 0

        # Verify get_current_aspm was called for the skipped device
        assert mock_get_current_aspm.call_count == 1
