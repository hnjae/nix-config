## 업데이트 방법

단지 nix flake update 를 해서는, 빌드가 안되는 패키지가 있기 쉽다. 다음의 방법을 사용하자.

### hydra-check 활용

```sh
hydra-check --channel=unstable zed-editor-fhs
```

- 위와 같은 커맨드로 latest hydra job 에서 빌드가 성공적으로 되었는지 확인.
- "latest successful build" 가 가리키는 revision 으로 수정.
    - link 의 input 탭에, revision 정보 있음.

```sh
nix flake lock --override-input nixpkgs-unstable github:nixos/nixpkgs/5912c1772a44e31bf1c63c0390b90501e5026886
```

위와 같은 커맨드로 특정 revision 을 가리키도록 할 수 있다.

다음의 패키지들이 자주 빌드에 실패하니 참고하자.

- zed-editor-fhs

### 같이보기

- <https://status.nixos.org/> 에서 이슈 확인 가능
    - ※ 여기서는 중요 패키지의 빌드 여부만 확인이 가능함.
- 만일 nixpkgs 를 고정할 필요가 있다면 다음 링크를 참고하여, hydra 빌드가 제공 되는 커밋을 사용할 것.
    - [nixos-unstable hydra build](https://hydra.nixos.org/job/nixos/trunk-combined/tested)
    - [nixos-unstable-small hydra build](https://hydra.nixos.org/job/nixos/unstable-small/tested)
    - [NixOS 25.05](https://hydra.nixos.org/job/nixos/release-25.05/tested#tabs-status)

### 메모

채널 별 차이점은 다음 링크 참고: <https://wiki.nixos.org/wiki/Channel_branches>

## 작성 가이드

### 이름 도식

`hosts`
: `homeConfigurations` 나 `nixosConfigurations` 의 이름에는 hostname을 사용할 것.

#### 모듈 內 디렉토리 이름 도식

`programs`
: 설치할 프로그램 및 그 설정

`packages`
: 위와 유사하나 설정 선언이 없음

`modules`
: 모듈 선언

`services`
: systemd 서비스

`timers`
: systemd-timers 유닛

`hardware`
: 하드웨어 관련
: `hardware-configuration.nix` 에 들어가는 내용.
: `bootloader`, `initrd`, `kernelModules`, `fstab` 등 포함

`config`
: 모듈의 옵션 설정 (위에 해당하지 않는 값)

`lib`
: 공용 함수

`resources`
: `nix` 파일이 아니거나, 단순 참조 파일

### home-manager 관련

- dotfiles 는 기본적으로 home-manger 에서 관리하지 않는다.
- `home-manager` 의 `xdg.desktopEntries` 는 Gnome 에서 패키지 자체의 desktop entry 보다 우선순위를 가지지 않는다. `lib.HiPrio (pkgs.makeDesktop Item {...})` 을 사용할 것.
