{ inputs, ... }:
{
  perSystem =
    { system, ... }:
    let
      pkgs = import inputs.nixpkgs { inherit system; };

      backendPackage = "backend";
      on = inputs.opam-nix.lib.${system};
      backendDevPackagesQuery = {
        ocaml-lsp-server = "*";
        utop = "*";
      };
      backendQuery = backendDevPackagesQuery // {
        ocaml-base-compiler = "*";
      };
      backendScope = on.buildOpamProject' { resolveArgs.with-test = true; } ./.. backendQuery;
      backendOverlay = _final: prev: {
        ${backendPackage} = prev.${backendPackage}.overrideAttrs (_: {
          # Prevent the ocaml dependencies from leaking into dependent environments
          doNixSupport = false;
        });
      };
      backendScope' = backendScope.overrideScope backendOverlay;
      backend = backendScope'.${backendPackage};
      backendDevPackages = builtins.attrValues (
        pkgs.lib.getAttrs (builtins.attrNames backendDevPackagesQuery) backendScope'
      );
    in
    {
      _module.args = { inherit pkgs backend backendDevPackages; };

      packages.default = backend;
    };
}
