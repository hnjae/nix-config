{ ... }:
{
  # disable wakeup from touchpad
  # services.udev.extraRules = ''
  #   KERNEL=="i2c-ELAN0676:00", SUBSYSTEM=="i2c", ATTR{power/wakeup}="disabled"
  # '';
}
