"""Tests for autoaspm module."""

import subprocess
from unittest.mock import Mock, patch

import pytest

from autoaspm import (
    ASPM,
    PCIDevice,
    CapabilityNotFoundError,
    DeviceAccessError,
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
        device = PCIDevice("01:00.0")
        assert device.addr == "01:00.0"
        assert device._config_bytes is None
        assert device._pcie_cap_offset is None
        assert device._device_name is None


class TestPCIDeviceGetName:
    """Test PCIDevice.get_name() method."""

    @patch("subprocess.run")
    def test_get_name_success(self, mock_run):
        """Test successful device name retrieval."""
        mock_run.return_value = Mock(
            returncode=0,
            stdout="01:00.0 Network controller: Intel Corporation...",
        )
        device = PCIDevice("01:00.0")
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
        device = PCIDevice("01:00.0")
        name1 = device.get_name()
        name2 = device.get_name()
        assert name1 == name2
        # Should only be called once due to caching
        assert mock_run.call_count == 1

    @patch("subprocess.run")
    def test_get_name_command_failure(self, mock_run):
        """Test handling of lspci failure."""
        mock_run.return_value = Mock(returncode=1, stderr="Device not found")
        device = PCIDevice("01:00.0")
        with pytest.raises(
            DeviceAccessError, match="Failed to get device name"
        ):
            device.get_name()

    @patch("subprocess.run")
    def test_get_name_no_output(self, mock_run):
        """Test handling of empty lspci output."""
        mock_run.return_value = Mock(returncode=0, stdout="")
        device = PCIDevice("01:00.0")
        with pytest.raises(DeviceAccessError, match="No device found"):
            device.get_name()

    @patch("subprocess.run")
    def test_get_name_timeout(self, mock_run):
        """Test handling of subprocess timeout."""
        mock_run.side_effect = subprocess.TimeoutExpired("lspci", 10)
        device = PCIDevice("01:00.0")
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

        device = PCIDevice("01:00.0")
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

        device = PCIDevice("01:00.0")
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
        device = PCIDevice("01:00.0")
        with pytest.raises(DeviceAccessError, match="Incomplete config space"):
            device.read_config_space()

    @patch("subprocess.run")
    def test_read_config_space_command_failure(self, mock_run):
        """Test handling of lspci failure."""
        mock_run.return_value = Mock(returncode=1, stderr="Command failed")
        device = PCIDevice("01:00.0")
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

        device = PCIDevice("01:00.0")
        offset = device.find_pcie_capability()

        assert offset == 0x40

    @patch.object(PCIDevice, "read_config_space")
    def test_find_pcie_capability_caching(self, mock_read):
        """Test that capability offset is cached."""
        config = self._create_config_with_pcie_cap(0x40)
        mock_read.return_value = config

        device = PCIDevice("01:00.0")
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

        device = PCIDevice("01:00.0")
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

        device = PCIDevice("01:00.0")
        with pytest.raises(CapabilityNotFoundError, match="out of bounds"):
            device.find_pcie_capability()


class TestPCIDeviceGetLinkControlOffset:
    """Test PCIDevice.get_link_control_offset() method."""

    @patch.object(PCIDevice, "find_pcie_capability")
    def test_get_link_control_offset(self, mock_find):
        """Test Link Control offset calculation."""
        mock_find.return_value = 0x40

        device = PCIDevice("01:00.0")
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

        device = PCIDevice("01:00.0")
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

        device = PCIDevice("01:00.0")
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

        device = PCIDevice("01:00.0")
        aspm = device.get_current_aspm()

        # Should only consider lower 2 bits
        assert aspm == ASPM.L1


class TestPCIDevicePatchByte:
    """Test PCIDevice._patch_byte() method."""

    @patch("subprocess.run")
    def test_patch_byte_success(self, mock_run):
        """Test successful byte patching."""
        mock_run.return_value = Mock(returncode=0, stderr="")

        device = PCIDevice("01:00.0")
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

        device = PCIDevice("01:00.0")
        with pytest.raises(DeviceAccessError, match="Failed to patch"):
            device._patch_byte(0x50, 0x03)

    @patch("subprocess.run")
    def test_patch_byte_timeout(self, mock_run):
        """Test handling of timeout."""
        mock_run.side_effect = subprocess.TimeoutExpired("setpci", 10)

        device = PCIDevice("01:00.0")
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

        device = PCIDevice("01:00.0")
        result = device.verify_patch(0x50, 0b11)

        assert result is True

    @patch.object(PCIDevice, "read_config_space")
    def test_verify_patch_failure(self, mock_read):
        """Test patch verification failure."""
        config = bytearray(256)
        config[0x50] = 0b01  # Different value
        mock_read.return_value = config

        device = PCIDevice("01:00.0")
        result = device.verify_patch(0x50, 0b11)

        assert result is False

    @patch.object(PCIDevice, "read_config_space")
    def test_verify_patch_error_handling(self, mock_read):
        """Test error handling in verify."""
        mock_read.side_effect = DeviceAccessError("Read failed")

        device = PCIDevice("01:00.0")
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

        device = PCIDevice("01:00.0")
        result = device.patch_aspm(ASPM.L0sL1, None)

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

        device = PCIDevice("01:00.0")
        result = device.patch_aspm(ASPM.L0sL1, None)

        assert result is True
        mock_patch.assert_called_once()

    @patch.object(PCIDevice, "get_link_control_offset")
    @patch.object(PCIDevice, "read_config_space")
    def test_patch_aspm_unsupported_mode(self, mock_read, mock_offset):
        """Test when requested mode is not supported."""
        config = bytearray(256)
        config[0x50] = ASPM.L0s.value  # Only L0s supported
        mock_read.return_value = config
        mock_offset.return_value = 0x50

        device = PCIDevice("01:00.0")
        # Request L1 when only L0s supported
        result = device.patch_aspm(ASPM.L0s, ASPM.L1)

        assert result is False


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

        device = PCIDevice("01:00.0")
        name = device.get_name()
        config = device.read_config_space()

        assert "Network controller" in name
        assert len(config) >= 256
