_: {
  perSystem =
    {
      config,
      pkgs,
      ps,
      purs-nix,
      backend,
      backendDevPackages,
      ...
    }:
    let
      devPackages =
        config.ciPackages
        ++ config.pre-commit.settings.enabledPackages
        ++ [
          (ps.command { })
          purs-nix.purescript
        ]
        ++ backendDevPackages;
    in
    {
      devShells.default = pkgs.mkShell {
        inputsFrom = [ backend ];
        buildInputs = devPackages;
        shellHook = ''
          ${config.pre-commit.shellHook}
        '';
      };
    };
}
