{...}: {
  programs.plasma.configFile."powermanagementprofilesrc" = {
    "LowBattery.BrightnessControl"."value".value = 60;
    "LowBattery.DimDisplay"."idleTime".value = 120000; # default 60000
  };

  programs.plasma.configFile."powerdevilrc" = {
    "BatteryManagement" = {
      "BatteryCriticalAction".value = 0;
      "BatteryCriticalLevel".value = 0;
      "BatteryLowLevel".value = 5;
      "PeripheralBatteryLowLevel".value = 5;
    };
  };
}
