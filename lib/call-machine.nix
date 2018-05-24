path: cfg:
rec {
    build = eval.config.system.build.toplevel;

    config = {
        imports = [ path cfg ] ++ import ../nixos/modules/module-list.nix;
    };

    eval = import <nixpkgs/nixos/lib/eval-config.nix> {
        modules = [ path cfg ] ++ import ../nixos/modules/module-list.nix;
    };
}
