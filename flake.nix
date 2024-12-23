{
  description = "Fireking personal Nix packages";

  # Nixpkgs / NixOS version to use.
  inputs.nixpkgs.url = "nixpkgs/nixos-24.11";

  outputs = { self, nixpkgs }:
    let
      pkgs = import nixpkgs { system = "x86_64-linux"; };
    in {
      packages."x86_64-linux" = {
        networkmanager-pptp = import ./networkmanager-pptp/networkmanager-pptp.nix {
          inherit (pkgs)
            stdenv
            lib
            substituteAll
            fetchFromGitHub
            autoreconfHook
            pkg-config
            gtk3
            gtk4
            networkmanager
            ppp
            pptp
            libsecret
            libnma
            libnma-gtk4
            glib
            openssl
            nss
          ;
        };
      };

      
    };
}
