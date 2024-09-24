_: {
  programs.plasma.kwin.tiling = {
    padding = 4;
    layout = {
      id = "1149fce3-af8f-5c41-849f-30cea799ba45"; # 이거 내가 임의로 설정하면 작동 안됨.
      tiles = {
        layoutDirection = "horizontal";
        tiles = [
          {
            width = 0.6;
          }
          {
            width = 0.4;
          }
        ];
      };
    };
  };
}
