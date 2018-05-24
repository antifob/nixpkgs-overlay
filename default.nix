self: super:
let
    inherit (super) recurseIntoAttrs;
    inherit (super.lib) callPackageWith;

    callPackage = callPackageWith (super // self.pgregoire);

    self = {
        pgregoire = recurseIntoAttrs {
            sshproxy = callPackage ./pkgs/sshproxy {};
        } // {
            lib = import ./lib;
        };
    };
in
    self
