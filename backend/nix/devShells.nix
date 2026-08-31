_: {
  perSystem =
    {
      config,
      pkgs,
      self',
      backend,
      backendDevPackages,
      ...
    }:
    let
      devPackages =
        config.pre-commit.settings.enabledPackages
        ++ backendDevPackages
        ++ [
          pkgs.postgresql
          self'.packages.backend-services
        ];
    in
    {
      devShells.default = pkgs.mkShell {
        inputsFrom = [ backend ];
        buildInputs = devPackages;
        DATABASE_URL = config.process-compose."backend-services".services.postgres.pg1.connectionURI {
          dbName = "todo";
        };
        shellHook = ''
          ${config.pre-commit.shellHook}
        '';
      };
    };
}
