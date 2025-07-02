---
date: 2025-01-08
lastmod: 2025-07-02T15:48:59+0900
---

## 알아두어야 할 것

#### Desktop Entry Override

패키지가 제공하는 desktop entry 를 override 하기 위해 `xdg.desktopEntries` 를 사용하는 것은, KDE 에서는 작동이 되나, Gnome 에서는 작동되질 않는다. 우선 순위가 다른 것 같다. (NixOS 24.11; Gnome 47)

다음 스닛펫을 사용할 것.

```nix
(lib.hiPrio (
  pkgs.makeDesktopItem {
    name = "org.fcitx.fcitx5-migrator";
    desktopName = "This should not be displayed.";
    exec = ":";
    noDisplay = true;
  }
))
```

#### 특정 desktop entry 의 icon 설정

Desktop Entry 에서 `icon=/nix/store/<foo>.svg` 식으로 전체 경로를 지정하는것은 Gnome 에서는 잘 대응이 되나, KDE 에서는 대응이 안된다. (NixOS 25.05; Gnome 48; KDE 6.3.5)
