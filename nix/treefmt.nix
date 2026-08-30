_: {
  perSystem =
    { ps-tools, lib, ... }:
    {
      treefmt = {
        programs = {
          nixfmt = {
            enable = true;
            includes = [ "*.nix" ];
          };
          ocamlformat = {
            enable = true;
            configFile = ../backend/.ocamlformat;
          };
          oxfmt = {
            enable = true;
            includes = [
              "*.json"
              "*.jsonc"
              "*.json5"
              "*.md"
              "*.mdx"
              "*.yaml"
              "*.yml"
            ];
          };
        };
        settings.formatter.purs-tidy = {
          command = lib.getExe' ps-tools.for-0_15.purs-tidy "purs-tidy";
          options = [ "format-in-place" ];
          includes = [ "*.purs" ];
        };
      };
    };
}
