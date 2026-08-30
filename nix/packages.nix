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
    { config, system, ... }:
    let
      pkgs = import inputs.nixpkgs { inherit system; };

      purs-nix = inputs.purs-nix { inherit system; };

      node_modules =
        pkgs.importNpmLock.buildNodeModules {
          npmRoot = ./../frontend;
          nodejs = pkgs.nodejs_24;
        }
        + /node_modules;

      with-react =
        package: modules:
        pkgs.lib.recursiveUpdate package {
          purs-nix-info.foreign = pkgs.lib.genAttrs modules (_: {
            inherit node_modules;
          });
        };

      ps = purs-nix.purs {
        dependencies = [
          "ursi.debug"
          "effect"
          "prelude"
          "affjax-web"

          (with-react purs-nix.ps-pkgs.react-basic [
            "React.Basic"
            "React.Basic.StrictMode"
          ])

          (with-react purs-nix.ps-pkgs.react-basic-dom [
            "React.Basic.DOM"
            "React.Basic.DOM.Client"
            "React.Basic.DOM.Components.GlobalEvents"
            "React.Basic.DOM.Components.Ref"
            "React.Basic.DOM.Events"
            "React.Basic.DOM.Internal"
            "React.Basic.DOM.Server"
          ])

          (with-react purs-nix.ps-pkgs.react-basic-hooks [
            "React.Basic.Hooks"
            "React.Basic.Hooks.Aff"
            "React.Basic.Hooks.ErrorBoundary"
            "React.Basic.Hooks.Suspense"
          ])
        ];

        test-dependencies = [
          "test-unit"
        ];

        dir = ./../frontend;
      };

      backendPackage = "backend";
      on = inputs.opam-nix.lib.${system};
      backendDevPackagesQuery = {
        ocaml-lsp-server = "*";
        utop = "*";
      };
      backendQuery = backendDevPackagesQuery // {
        ocaml-base-compiler = "*";
      };
      backendScope = on.buildOpamProject' { resolveArgs.with-test = true; } ./../backend backendQuery;
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
      _module.args = {
        inherit
          pkgs
          ps
          purs-nix
          backend
          backendDevPackages
          ;
        ps-tools = inputs.ps-tools.legacyPackages.${system};
      };

      ciPackages = with pkgs; [ nodejs_24 ];

      packages = {
        frontend = ps.output { };
        inherit backend;
        ci = pkgs.buildEnv {
          name = "ci";
          paths = config.ciPackages;
        };
      };
    };
}
