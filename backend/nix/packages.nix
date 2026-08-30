{ inputs, flake-parts-lib, ... }:
{
  options.perSystem = flake-parts-lib.mkPerSystemOption (
    { lib, ... }:
    {
      options.ciPackages = lib.mkOption {
        type = lib.types.listOf lib.types.package;
        default = [ ];
        description = "Packages for CI environment";
      };
    }
  );

  config.perSystem =
    {
      config,
      pkgs,
      system,
      ...
    }:
    let
      package = "hello";
      on = inputs.opam-nix.lib.${system};
      devPackagesQuery = {
        ocaml-lsp-server = "*";
        utop = "*";
      };
      query = devPackagesQuery // {
        ocaml-base-compiler = "*";
      };
      scope = on.buildOpamProject' { resolveArgs.with-test = true; } ./.. query;
      overlay = _final: prev: {
        ${package} = prev.${package}.overrideAttrs (_: {
          # Prevent the ocaml dependencies from leaking into dependent environments
          doNixSupport = false;
        });
      };
      scope' = scope.overrideScope overlay;
      main = scope'.${package};
      devPackages = builtins.attrValues (pkgs.lib.getAttrs (builtins.attrNames devPackagesQuery) scope');
    in
    {
      ciPackages = with pkgs; [ ];

      packages = {
        default = main;
        ci = pkgs.buildEnv {
          name = "ci";
          paths = config.ciPackages;
        };
      };

      _module.args = {
        inherit main devPackages;
      };
    };
}
