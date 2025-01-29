{ stdenv, mesa, fetchFromGitHub }:
let
  version = "24.3.0";
  jupiterVersion = "steamos-24.11.4";
in stdenv.mkDerivation {
  pname = "mesa";
  version = "${version}.${jupiterVersion}";

  src = fetchFromGitHub {
    owner = "Jovian-Experiments";
    repo = "mesa";
    rev = jupiterVersion;
    hash = "sha256-wiVN8F8Itx+D73DwJ8wSV0/7lAWvypv+q1EwZZRdLaw=";
  };

  inherit (mesa) buildInputs nativeBuildInputs propagatedBuildInputs;

  separateDebugInfo = true;

  mesonAutoFeatures = "auto";

  # See https://github.com/Jovian-Experiments/PKGBUILDs-mirror/blob/jupiter-main/mesa-radv/PKGBUILD
  mesonFlags = [
    "-D b_ndebug=true"
    "-D b_lto=false"
    "-D platforms=x11,wayland"
    "-D gallium-drivers="
    "-D gallium-vdpau=disabled"
    "-D gallium-va=disabled"
    "-D gallium-xa=disabled"
    "-D android-libbacktrace=disabled"
    "-D vulkan-drivers=amd"
    "-D vulkan-layers="
    "-D egl=disabled"
    "-D gbm=disabled"
    "-D gles1=disabled"
    "-D gles2=disabled"
    "-D glvnd=disabled"
    "-D glx=disabled"
    "-D libunwind=enabled"
    "-D llvm=enabled"
    "-D lmsensors=disabled"
    "-D osmesa=false"
    "-D microsoft-clc=disabled"
    "-D video-codecs=vc1dec,h264dec,h264enc,h265dec,h265enc"
    "-D valgrind=enabled"
    "-D intel-rt=disabled"
    "-D radv-build-id=da39a3ee5e6b4b0d3255bfef95601890afd80709"
    "-D gpuvis=true"
  ];
}