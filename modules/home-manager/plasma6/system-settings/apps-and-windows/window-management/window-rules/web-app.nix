_: {
  plasma6.windowRules = [
    {
      uuid = "5b17fdb1-4db5-4bb3-926a-457b4fb2af90";
      description = "web-app-initial-size";
      Match = {
        "wmclass".value = ''[(chrome)|(brave)]-.+-Default'';
        "wmclassmatch".value = 3; # regex
      };
      Rule = {
        "size".value = "1000,750";
        "sizerule" = 3; # apply initially
      };
    }
  ];
}
