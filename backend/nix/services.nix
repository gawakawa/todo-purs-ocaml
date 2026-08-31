{ inputs, ... }:
{
  perSystem = _: {
    process-compose."db" = {
      imports = [ inputs.services-flake.processComposeModules.default ];
      services.postgres."pg1" = {
        enable = true;
        listen_addresses = "127.0.0.1";
        port = 5432;
        initialDatabases = [
          {
            name = "todo";
            schemas = [ ../schema.sql ];
          }
        ];
      };
    };
  };
}
