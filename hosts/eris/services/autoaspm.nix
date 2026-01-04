{
  my.services.autoaspm = {
    enable = true;
    mode = "l0sl1";
    deviceModes = {
      "1000:0072" = "disabled"; # HBA Card
    };
  };
}
