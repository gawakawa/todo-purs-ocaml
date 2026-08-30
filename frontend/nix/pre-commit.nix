_: {
  perSystem = {
    pre-commit.settings.hooks = {
      treefmt = {
        enable = true;
        excludes = [ ".*\\.purs$" ]; # purs-tidy の mtime 問題を回避
      };
    };
  };
}
