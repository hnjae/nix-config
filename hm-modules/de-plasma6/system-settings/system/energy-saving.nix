{...}: {
  # programs.plasma.configFile."powerdevilrc" = {
  # "AC/Display".TurnOffDisplayIdleTimeoutSec.value = 240; # seconds
  # };

  programs.plasma.powerdevil = {turnOffDisplay = {idleTimeout = 240;};};
}
