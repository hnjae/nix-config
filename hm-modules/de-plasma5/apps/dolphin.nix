{...}: {
  programs.plasma.configFile."dolphinrc"."General"."FilterBar".value = true;
  programs.plasma.configFile."dolphinrc"."DetailsMode" = {
    "UsePermissionsFormat".value = "NumericFormat";
    "UseSystemFont".value = false;
    "ViewFont".value = "Monospace,10,-1,5,50,0,0,0,0,0";
  };

  programs.plasma.configFile."kiorc"."Confirmations" = {
    "ConfirmDelete".value = true;
    "ConfirmEmptyTrash".value = true;
    "ConfirmTrash".value = false;
  };
}
