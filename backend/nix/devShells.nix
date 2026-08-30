_: {
  perSystem =
    {
      config,
      pkgs,
      backend,
      backendDevPackages,
      ...
    }:
    let
      devPackages = config.pre-commit.settings.enabledPackages ++ backendDevPackages ++ [ pkgs.sqlite ];
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
