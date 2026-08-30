_: {
  perSystem =
    {
      config,
      pkgs,
      main,
      devPackages,
      ...
    }:
    {
      devShells.default = pkgs.mkShell {
        inputsFrom = [ main ];
        buildInputs = config.ciPackages ++ config.pre-commit.settings.enabledPackages ++ devPackages;

        shellHook = ''
          ${config.pre-commit.shellHook}
        '';
      };
    };
}
