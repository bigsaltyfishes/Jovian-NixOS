{
  lib,
  rustPlatform,
  fetchFromGitHub,
  replaceVars,
  pkg-config,
  steam-run,
  libevdev,
  udev
}:
let
  valve-powerbuttond = fetchFromGitHub {
    owner = "Jovian-Experiments";
    repo = "powerbuttond";
    rev = "v4.2";
    hash = "sha256-ahdWiCFid+wk2db0TvOEKfUxkJ+Yo5oBbrZ0ZqkUalE=";
  };
in
rustPlatform.buildRustPackage rec {
  pname = "powerbuttond";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "bigsaltyfishes";
    repo = "steamos-powernuttond-rs";
    rev = "1ef345e082102df2b5c7626bb937b05afe0f3ac5";
    hash = "sha256-tei5Ogyzq++auvNVV5H62P3K9BVe7oF+lcBkPOpK4+w=";
  };

  patches = [
    (replaceVars ./0001-nixos-handler.patch {
      handler = "${steam-run}/bin/steam-run";
    })
  ];

  cargoLock.lockFile = "${src}/Cargo.lock";

  postInstall = ''
    mv $out/bin/powerbuttond-rs $out/bin/steamos-powerbuttond
    install -D -m 644 LICENSE $out/share/licenses/steamos-powerbuttond
    install -D -m 644 ${valve-powerbuttond}/LICENSE $out/share/licenses/steamos-powerbuttond.valve
    install -D -m 644 ${valve-powerbuttond}/steamos-powerbuttond.service $out/lib/systemd/user/steamos-powerbuttond.service
    install -D -m 644 ${valve-powerbuttond}/steamos-power-button.rules $out/lib/udev/rules.d/80-steamos-power-button.rules
    install -D -m 644 ${valve-powerbuttond}/steamos-power-button.hwdb $out/lib/udev/hwdb.d/80-steamos-power-button.hwdb
    install -d -m 755 $out/lib/systemd/user/gamescope-session.service.wants
    ln -s ../steamos-powerbuttond.service $out/lib/systemd/user/gamescope-session.service.wants/
  '';

  fixupPhase = ''
    substituteInPlace $out/lib/systemd/user/steamos-powerbuttond.service \
      --replace-fail /usr/lib/hwsupport/steamos-powerbuttond $out/bin/steamos-powerbuttond
  '';

  nativeBuildInputs = [pkg-config];
  buildInputs = [libevdev udev];

  meta = with lib; {
    description = "Steam Deck power button daemon in Rust";
    license = with licenses; [ mit bsd2 ];
  };
}