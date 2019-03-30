let
  pkgs = import ./default.nix { config = { allowUnfree = true; }; };
in {
  none = pkgs.mspdebug.override { enableMspds = false; };
  src = pkgs.mspdebug.override { mspds = pkgs.mspds; enableMspds = true; };
  bin = pkgs.mspdebug.override { mspds = pkgs.mspds-bin; enableMspds = true; };
}
