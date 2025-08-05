## 주의 사항

- nixpkgs 를 업데이트하기전에 <https://status.nixos.org/> 에서 이슈 확인할 것.
- 만일 nixpkgs 를 고정할 필요가 있다면 다음 링크를 참고하여, hydra 빌드가 제공 되는 커밋을 사용할 것.
  - [nixos-unstable hydra build](https://hydra.nixos.org/job/nixos/trunk-combined/tested)
  - [nixos-unstable-small hydra build](https://hydra.nixos.org/job/nixos/unstable-small/tested)

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
- `home-manager` 의 `xdg.desktopEntries` 는 Gnome 에서 패키지 자체의 desktop entry 보다 우선순위를 가지지 않는다. 때문에 `xdg.dataFile."applications/foo.desktop"` 식으로 직접 파일을 작성할 것. 이것이 DE 에 상관 없이 더 범용적으로 작동한다.
