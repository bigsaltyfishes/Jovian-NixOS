{
  stdenv,
  resholve,
  writeText,
  fetchFromGitHub,
  python3,
  steamdeck-hw-theme,
  steam,
  steam-unwrapped,
  bash,
  coreutils,
  dbus,
  findutils,
  galileo-mura,
  gamescope,
  gnugrep,
  gnused,
  gnutar,
  ibus,
  kdePackages,
  mangohud,
  powerbuttond,
  procps,
  steam_notif_daemon,
  steamos-polkit-helpers,
  systemd,
  util-linux,
  xbindkeys,
}:

let
  gamescope-session-solution = {
    scripts = [ "bin/gamescope-session" ];
    interpreter = "${bash}/bin/bash";
    inputs = [
      coreutils
      dbus
      findutils
      galileo-mura
      gnugrep
      gnused
      gnutar
      ibus
      kdePackages.kconfig
      mangohud
      powerbuttond
      procps
      steam_notif_daemon
      "${steamos-polkit-helpers}/bin/steamos-polkit-helpers"
      steam
      util-linux
      xbindkeys
    ];
    execer = [
      "cannot:${ibus}/bin/ibus-daemon"
      "cannot:${kdePackages.kconfig}/bin/kwriteconfig6"
      "cannot:${steamos-polkit-helpers}/bin/steamos-polkit-helpers/steamos-poweroff-now"
      "cannot:${steamos-polkit-helpers}/bin/steamos-polkit-helpers/steamos-reboot-now"
      "cannot:${steamos-polkit-helpers}/bin/steamos-polkit-helpers/steamos-retrigger-automounts"
      "cannot:${steam}/bin/steam"
      "cannot:${util-linux}/bin/flock"
      "cannot:${xbindkeys}/bin/xbindkeys"
    ];
    fake = {
      # we're using wrappers for these
      external = [ "sudo" "gamescope" ];
      source = [
        "/etc/xdg/gamescope-session/environment"
      ];
    };
    fix = {
      "/usr/bin/ibus-daemon" = true;
      "/usr/bin/steamos-polkit-helpers/steamos-poweroff-now" = true;
      "/usr/bin/steamos-polkit-helpers/steamos-reboot-now" = true;
      "/usr/bin/steamos-polkit-helpers/steamos-retrigger-automounts" = true;
      "/usr/lib/hwsupport/powerbuttond" = true;
    };
    keep = {
      # if you've somehow managed to get devkit Steam on your NixOS,
      # everything that happens beyond this point is entirely your fault
      "$HOME/devkit-game/devkit-steam" = true;
      "source:/etc/xdg/gamescope-session/environment" = true;
    };

    prologue = "${writeText "gamescope-session-prologue" ''
      # Don't resholve gamescope so we can use the cap_sys_nice wrapper when available
      # mangohud is not picked up by resholve due to loop_background
      export PATH=/run/wrappers/bin:${gamescope}/bin:${mangohud}/bin:$PATH
  
      # Make gamescope discover the Steam cursor theme
      export XCURSOR_PATH=${kdePackages.breeze}/share/icons:${steamdeck-hw-theme}/share/icons
    ''}";
  };
  start-gamescope-session-solution = {
    scripts = [ "bin/start-gamescope-session" ];
    interpreter = "${bash}/bin/bash";
    inputs = [ coreutils dbus gnugrep systemd ];
    execer = [
      "cannot:${systemd}/bin/systemctl"
    ];

    # Import user PATH into the environment to be able to start third party tools
    prologue = "${writeText "start-gamescope-session-prologue" ''
      ${systemd}/bin/systemctl --user import-environment PATH
    ''}";
  };
in stdenv.mkDerivation(finalAttrs: {
  pname = "gamescope-session";
  version = "3.16.1-2";

  src = fetchFromGitHub {
    owner = "Jovian-Experiments";
    repo = "PKGBUILDs-mirror";
    rev = "jupiter-main/gamescope-${finalAttrs.version}";
    hash = "sha256-2WfNfD6Yyjlzfrce5ey3UGexveTrOvwPwdCswPkmEz4=";
  };

  patches = [
    ./0001-gamescope-session-Add-xdg-environment-overrides.patch
    ./0002-start-gamescope-session-do-not-set-XDG_DESKTOP_PORTA.patch
  ];

  postPatch = ''
    patchShebangs steam-http-loader

    # The powerbuttond stuff should be handled by resholve, but currently isn't
    substituteInPlace gamescope-session \
      --replace /usr/share ${steamdeck-hw-theme}/share \
      --replace /usr/lib/steam ${steam-unwrapped}/lib/steam \
      --replace /usr/lib/hwsupport/powerbuttond ${powerbuttond}/bin/powerbuttond

    substituteInPlace gamescope-session.service \
      --replace /usr/bin $out/bin
  '';

  nativeBuildInputs = [python3];

  # Largely copied from upstream
  installPhase = ''
    runHook preInstall

    install -D -m 755 gamescope-session $out/bin/gamescope-session
    install -D -m 755 start-gamescope-session $out/bin/start-gamescope-session
    install -D -m 644 gamescope-wayland.desktop $out/share/wayland-sessions/gamescope-wayland.desktop

    # url handling
    install -D -m 644 steam_http_loader.desktop $out/share/applications/steam_http_loader.desktop
    install -D -m 644 gamescope-mimeapps.list $out/share/applications/gamescope-mimeapps.list
    install -D -m 755 steam-http-loader $out/bin/steam-http-loader

    install -D -m 644 gamescope-session.service $out/share/systemd/user/gamescope-session.service

    # portals
    install -D -m 644 gamescope-portals.conf $out/share/xdg-desktop-portal/gamescope-portals.conf

    ${resholve.phraseSolution "gamescope-session" gamescope-session-solution}
    ${resholve.phraseSolution "start-gamescope-session" start-gamescope-session-solution}

    runHook postInstall
  '';

  passthru.providedSessions = ["gamescope-wayland"];
})
