---
date: 2025-08-02T23:26:03+0900
lastmod: 2025-08-24T20:39:16+0900
---

## 새 NixOS 인스톨 가이드

1. OS 를 설치할 디스크가 아닌 OS 로 부팅.
2. Disko 의 `disk-config.nix` 작성
    - <https://github.com/nix-community/disko/blob/master/docs/quickstart.md>
    - 위 문서에 나온 커맨드, `sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko/latest -- --mode destroy,format,mount /tmp/disk-config.nix` 를 실행해서 실제로 디스크를 포맷할 수 있다.
3. `initrd.network.ssh.enable` 와 secureboot (lanzaboote) 끄기.
4. 인스톨
    - <https://github.com/nix-community/nixos-anywhere/blob/main/docs/quickstart.md>
    - `nix run github:nix-community/nixos-anywhere -- --flake <path to configuration>#<configuration name> --phases kexec,disko,install  --target-host root@<ip address>`
    - secrets 복사 (`/secrets/home-age-private`)
    - 재부팅
5. Post Install
    - `initrd.network.ssh.enable` 다시 키고 `nixos-rebuild switch`
    - Secureboot 설정
        - Lanzaboote: <https://github.com/nix-community/lanzaboote/blob/master/docs/QUICK_START.md>
        - Limine: <https://wiki.nixos.org/wiki/Limine>
            - Limine 는 NixOS 25.05 기준 initrd-secrets 에 버그가 있다.
    - tailscale 로그인
        - 일부 기기는 key expiry 끄기
        - IP 설정

### 인스톨 후 가이드

- `dotfiles` 리포 클론 후 `install.sh` 실행
- 1Password 로그인
  - `~/.ssh/id_ed25519` 복구
  - GPG Key 임포트
- KDE/Gnome 설정 복구
- 브라우저 로그인 및 설정 복구

<!--
vi:ft:sw=4
-->
