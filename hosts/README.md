---
date: 2025-08-02T23:26:03+0900
lastmod: 2025-12-28T14:22:40+0900
---

## 새 NixOS 인스톨 가이드

※ sops 사용하는 코드 comment out 하기.

### `disko` 를 활용한 방법

1. OS 를 설치할 디스크가 아닌 OS 로 부팅.
2. Disko 의 `disk-config.nix` 작성
    - <https://github.com/nix-community/disko/blob/master/docs/quickstart.md>
    - **만일 원한다면** 위 문서에 나온 커맨드, `sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko/latest -- --mode destroy,format,mount /tmp/disk-config.nix` 를 실행해서 실제로 디스크를 포맷할 수 있다.
3. `initrd.network.ssh.enable` 와 secureboot (lanzaboote) 끄기.
4. 인스톨
    - <https://github.com/nix-community/nixos-anywhere/blob/main/docs/quickstart.md>
    - run nixos-anywhere
    - secrets 복사 (e.g. `/secrets/home-age-private`)
    - 재부팅

```sh
nix run github:nix-community/nixos-anywhere -- --flake ".#<hostname> --phases kexec,disko,install  --target-host root@<ip address>
```

### 수동 인스톨

1. liveos 로 부트.
2. 파일 시스템 포맷 후, `/mnt` 에 마운트
3. `nixos-generate-config` 실행 후 `/etc/nixos/hardware-configuration.nix` 참조.
4. 인스톨

    ```sh
    nixos-install --root /mnt --flake '<path>#hostname'
    nixos-install --root /mnt --flake '.#eris'
    ```

5. secrets 복사 (e.g. `/secrets/home-age-private` or `/zlocal/home-age-private`)

### 인스톨 후 가이드

- `initrd.network.ssh.enable` 다시 키고 `nixos-rebuild switch`
- Secureboot 설정
    - Lanzaboote: <https://github.com/nix-community/lanzaboote/blob/master/docs/QUICK_START.md>
    - Limine: <https://wiki.nixos.org/wiki/Limine>
        - Limine 는 NixOS 25.05 기준 initrd-secrets 에 버그가 있다.
- tailscale 로그인
    - 일부 기기는 key expiry 끄기
    - IP 설정
- `dotfiles` 리포 클론 후 `install.sh` 실행
- 1Password 로그인
    - `~/.ssh/id_ed25519` 복구
    - GPG Key 임포트
- KDE/Gnome 설정 복구
- 브라우저 로그인 및 설정 복구

<!--
vi:ft:sw=4
-->
