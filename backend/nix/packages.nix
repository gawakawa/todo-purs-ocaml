{ inputs, ... }:
{
  perSystem =
    { system, inputs', ... }:
    let
      pkgs = import inputs.nixpkgs { inherit system; };
      inherit (inputs'.nix2container.packages) nix2container;

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

      packages.container = nix2container.buildImage {
        name = "todo-backend";
        tag = "latest";
        copyToRoot = pkgs.buildEnv {
          name = "root";
          paths = [ backend ];
          pathsToLink = [ "/bin" ];
        };
        config = {
          Cmd = [ "${backend}/bin/backend" ];
          ExposedPorts = {
            "8080/tcp" = { };
          };
        };
      };
    };
}
