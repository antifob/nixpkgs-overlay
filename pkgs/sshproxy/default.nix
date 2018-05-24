{ coreutils
, fetchFromGitLab
, gawk
, gnugrep
, makeWrapper
, netcat-openbsd
, stdenv
, which
}:
stdenv.mkDerivation {
    name = "sshproxy";
    src  = fetchFromGitLab {
        owner  = "pgregoire";
        repo   = "sshproxy";
        rev    = "386e9d8aa9bbaf5355b31c5f2232ef8b54965928";
        sha256 = "0i03jg7fs04s281rl74km8qbb9ipdx07gpam96r6i863ky1ai8yx";
    };

    buildInputs = [ makeWrapper ];
    installFlags = [ "PREFIX=$(out)" ];

    postInstall = ''
        wrapProgram "$out/bin/sshproxy" \
            --prefix PATH : "${coreutils}/bin" \
            --prefix PATH : "${gnugrep}/bin" \
            --prefix PATH : "${gawk}/bin" \
            --prefix PATH : "${netcat-openbsd}/bin" \
            --prefix PATH : "${which}/bin"
    '';
}
