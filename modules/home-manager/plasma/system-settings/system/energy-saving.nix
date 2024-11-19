{...}: {
  # programs.plasma.configFile."powerdevilrc" = {
  # "AC/Display".TurnOffDisplayIdleTimeoutSec.value = 240; # seconds
  # };

  programs.plasma.powerdevil = {
    AC.turnOffDisplay = {idleTimeout = 240;};
  };
}
