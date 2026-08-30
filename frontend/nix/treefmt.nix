_: {
  perSystem =
    { ps-tools, lib, ... }:
    {
      treefmt.settings.formatter.purs-tidy = {
        command = lib.getExe' ps-tools.for-0_15.purs-tidy "purs-tidy";
        options = [ "format-in-place" ];
        includes = [ "*.purs" ];
      };
    };
}
