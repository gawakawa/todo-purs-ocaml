{ inputs, ... }:
{
  perSystem =
    { system, ... }:
    let
      pkgs = import inputs.nixpkgs { inherit system; };

      purs-nix = inputs.purs-nix { inherit system; };

      node_modules =
        pkgs.importNpmLock.buildNodeModules {
          npmRoot = ./..;
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

        dir = ./..;
      };

      ciPackages = with pkgs; [ nodejs_24 ];
    in
    {
      _module.args = {
        inherit
          pkgs
          ps
          purs-nix
          ciPackages
          ;
        ps-tools = inputs.ps-tools.legacyPackages.${system};
      };

      packages = {
        default = ps.output { };
        ci = pkgs.buildEnv {
          name = "ci";
          paths = ciPackages;
        };
      };
    };
}
