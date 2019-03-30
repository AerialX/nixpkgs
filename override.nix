let
  pkgs = import ./default.nix { config = { allowUnfree = true; }; };
in pkgs.mspdebug.override { mspds = pkgs.mspds-bin; }
