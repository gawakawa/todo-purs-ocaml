_: {
  perSystem = {
    treefmt.programs = {
      nixfmt = {
        enable = true;
        includes = [ "*.nix" ];
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
  };
}
