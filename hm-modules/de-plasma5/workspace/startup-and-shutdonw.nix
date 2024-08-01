{...}: {
  # NOTE: 23.11 기준 `startupScript` 이 비어 있으면 `failed` unit 이 생성.
  # 따로 설정을 안해도,
  # autostart/plasma-manager-apply-themes.desktop 를 자동생성하기 때문.
  programs.plasma.startup.startupScript = {empty = {text = ":";};};
}
