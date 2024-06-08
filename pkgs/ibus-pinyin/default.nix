{ lib
, stdenv
, fetchFromGitHub
, autoreconfHook
, gettext
, intltool
, pkg-config
, wrapGAppsHook3
, sqlite
, pyzy
, ibus
, glib
, gtk3
, python3
, lua
}:
stdenv.mkDerivation {
  pname = "ibus-pinyin";
  version = "1.5.1";

  src = fetchFromGitHub {
    owner = "ibus";
    repo = "ibus-pinyin";
    rev = "998992d095ea71e456e8c4847e014237f3621f0f";
    sha256 = "8nM/dEjkNhQNv6Ikv4xtRkS3mALDT6OYC1EAKn1zNtI=";
  };

  nativeBuildInputs = [
    autoreconfHook
    gettext
    pkg-config
    wrapGAppsHook3
  ];

  buildInputs = [
    ibus
    pyzy
    intltool
    lua
    glib
    sqlite
    python3
    gtk3
    lua
  ];

  meta = with lib; {
    description = "Pinyin (Chinese) input method for the IBus framework";
    homepage = "https://github.com/openSUSE/pyzy";
    license = licenses.lgpl21;
    platforms = platforms.linux;
  };
}
