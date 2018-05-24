path: cfg:
let
    #
    # The top layer can use our overlay if it defines it, but we
    # cannot since it does not propagate. Install it here.
    #
    c = {
        nixpkgs = {
            overlays = [(import ./..)] ++ (cfg.nixpkgs.overlays or []);
        } // (builtins.removeAttrs (cfg.nixpkgs or {}) [ "overlays" ]);
    } // builtins.removeAttrs cfg [ "nixpkgs" ];
in
rec {
    build = eval.config.system.build.toplevel;

    config = {
        imports = [ path c ] ++ import ../nixos/modules/module-list.nix;
    };

    eval = import <nixpkgs/nixos/lib/eval-config.nix> {
        modules = [ path c ] ++ import ../nixos/modules/module-list.nix;
    };
}
