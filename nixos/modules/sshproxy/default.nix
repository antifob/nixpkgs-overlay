{ config, lib, pkgs, ... }: with lib;
let
    cfg = config.pgregoire.sshproxy;

    #
    # The configuration file.
    #
    conf =
        let
            inherit (builtins) any attrNames concatStringsSep;

            # True if all named users have keys.
            usersExists = names:
                let
                    inherit (builtins) elem toString:

                    ku = attrNames cfg.keys;
                    nz = s: 0 != (builtins.stringLength s);
                in
                    all (u: (elem u ku) && (nz u)) names;

            mk = rule:
                assert ("" != rule.name);
                assert ("" != rule.host);
                assert ((1 <= rule.port) && (65535 >= rule.port));
                assert (usersExists rule.users);
                    concatStringsSep " " [
                        (concatStringsSep "," [ rule.name rule.host (toString rule.port) ])
                        (concatStringsSep " " rule.users)
                    ];

            rules = concatStringsSep "\n" (map (r: mk r) cfg.rules);
        in
            pkgs.writeText "sshproxy.conf" rules;


    #
    # Wrap sshproxy and the generated configuration under a new script.
    # Calls sshproxy with the generated configuration as an environment
    # variable.
    #
    wrap =
        let
            bin = pkgs.writeScriptBin "sshproxy-wrap" ''
                      #!${pkgs.stdenv.shell}
                      SSHPROXY_CONFIG=${conf} \
                      ${pkgs.pgregoire.sshproxy}/bin/sshproxy "$@"
                  '';
        in
            "${bin}/bin/sshproxy-wrap";


    #
    # Map keys to users and generate the required lines:
    #
    #  'command="user" key'
    #
    mkAuthorizedKeys = keys:
        let
            inherit (builtins) attrNames map;

            mk = u: k: ''command="${u}" ${k}'';
        in
            map (n: mk n keys."${n}") (attrNames keys);
in
{
    options.pgregoire.sshproxy = {
        enable = mkOption {
            type = types.bool;
            default = false;
            description = "Install an SSH proxy account.";
        };

        user = mkOption {
            type = types.str;
            default = "j";
            description = "Account users connect to.";
        };

        rules = mkOption {
            type = types.listOf (types.submodule {
                options = {
                    name = mkOption {
                        type = types.str;
                    };
                    host = mkOption {
                        type = types.str;
                    };
                    port = mkOption {
                        type = types.int;
                        default = 22;
                    };
                    users = mkOption {
                        type = types.listOf types.str;
                    };
                };
            });
            description = "Proxying rules.";
        };

        keys = mkOption {
            type = types.attrsOf types.str;
            description = "Users to public SSH key map.";
        };
    };

    config = mkIf cfg.enable {
        environment.shells = [ wrap ];

        users.users."${cfg.user}" = {
            shell = wrap;
            isSystemUser = true;
            openssh.authorizedKeys.keys = mkAuthorizedKeys cfg.keys;
        };
    };
}
