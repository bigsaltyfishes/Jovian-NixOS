{ gamescope'
, fetchFromGitHub
}:

# NOTE: vendoring gamescope for the time being since we want to match the
#       version shipped by the vendor, ensuring feature level is equivalent.

gamescope'.overrideAttrs(old: rec {
  version = "3.16.1";

  src = fetchFromGitHub {
    owner = "ValveSoftware";
    repo = "gamescope";
    rev = version;
    fetchSubmodules = true;
    hash = "sha256-+0QGt4UADJmZok2LzvL+GBad0t4vVL4HXq27399zH3Y=";
  };

  patches = old.patches or [] ++ [
    ./32bit-crash-fix.patch
  ];
})
