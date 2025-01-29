{ 
  stdenv, 
  fetchFromGitHub, 
  substituteAll, 
  jovian-steam-protocol-handler, 
  systemd,
}:

stdenv.mkDerivation rec {
  pname = "jupiter-hw-support-source";
  version = "20250107.1";

  src = fetchFromGitHub {
    owner = "Jovian-Experiments";
    repo = "jupiter-hw-support";
    rev = "jupiter-${version}";
    hash = "sha256-qrHQyECBvfBF5CdBKIJq8wxR2YTsEgtlxEqQMhUH0Ps=";
  };

  patches = [
    (substituteAll {
      handler = jovian-steam-protocol-handler;
      systemd = systemd;
      src = ./automount-fix-system-paths.patch;
    })
    # Remove `deck` username assumption
    ./0001-Jovian-Ensure-automounting-works-for-any-UID-1000-us.patch
    # Minor fixes against silly environments
    ./0001-steamos-automount-Harden-against-missing-run-media.patch
    ./0001-format-device-Harden-against-mountpoint-being-listed.patch
  ];

  installPhase = ''
    cp -r . $out
  '';
}
