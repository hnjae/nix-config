{
  my.services.autoaspm = {
    enable = true;
    mode = "l0s"; # l0sl1 은 이 장비에서 불가능.
    deviceModes = {
      "1022:14ef" = "l1"; # Advanced Micro Devices, Inc. [AMD] Family 19h USB4/Thunderbolt PCIe tunnel
      # "1022:14eb" = "l0sl1"; # Advanced Micro Devices, Inc. [AMD] Phoenix Internal GPP Bridge to Bus [C:A]

      # l0sl1 을 설정하면 강제 종료되는 장비들:
      # "17cb:1103" = "l0s"; # Network controller: Qualcomm Technologies, Inc QCNFA765 Wireless Network Adapter (rev 01)
    };
  };
}
