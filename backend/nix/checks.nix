_: {
  perSystem =
    { backend, ... }:
    {
      checks.default = backend.overrideAttrs (_: {
        buildPhase = ''
          runHook preBuild
          dune build -p "$OPAM_PACKAGE_NAME" -j "$NIX_BUILD_CORES" @check @runtest
          runHook postBuild
        '';
        installPhase = ''
          runHook preInstall
          mkdir -p $out
          runHook postInstall
        '';
      });
    };
}
