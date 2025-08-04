---
date: 2025-08-02T23:26:03+0900
lastmod: 2025-08-03T23:31:13+0900
---

## 새 NixOS 인스톨 가이드

1. OS 를 설치할 디스크가 아닌 OS 로 부팅.
2. Disko 의 `disk-config.nix` 작성
    - <https://github.com/nix-community/disko/blob/master/docs/quickstart.md>
    - 위 문서에 나온 커맨드, `sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko/latest -- --mode destroy,format,mount /tmp/disk-config.nix` 를 실행해서 실제로 디스크를 포맷할 수 있다.
3. 다음 가이드를 따름
    - <https://github.com/nix-community/nixos-anywhere/blob/main/docs/quickstart.md>
    - `nix run github:nix-community/nixos-anywhere -- --flake <path to configuration>#<configuration name> --target-host root@<ip address>`

### 인스톨 후 가이드

- Secureboot (Lanzaboote) 설정
- 1Password 로그인
- `~/.ssh/id_ed25519` 복구
- GPG Key 임포트
- `sops` 키 (`secrets/home-age-private`) 복구
- `dotfiles` 리포 복사 후 설정.
- KDE/Gnome 설정 복구
- Firefox 로그인 및 설정 복구
- tailscale 로그인

<!--
vi:ft:sw=4
-->
