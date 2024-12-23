{
  stdenv,
  lib,
  substituteAll,
  fetchFromGitHub,
  autoreconfHook,
  pkg-config,
  gtk3,
  gtk4,
  networkmanager,
  ppp,
  pptp,
  libsecret,
  withGnome ? true,
  libnma,
  libnma-gtk4,
  glib,
  openssl,
  nss,
}:
stdenv.mkDerivation rec {
  name = "${pname}${lib.optionalString withGnome "-gnome"}-${version}";
  pname = "networkmanager-pptp";
  version = "1.2.13-dev";

  src = fetchFromGitHub {
    owner = "NetworkManager";
    repo = "NetworkManager-pptp";
    rev = version;
    hash = "sha256-q0+x2EqjTNSjChlqc9YhJTCKH09F9+gHDxgU3Wn3QKU=";
    # hash = "sha256-Bre8qJbpkjBKX5ODPHqF3w5WuyDYCV4fha9Fa5y4S4M=";
    # hash = "sha256-10sbp2f6nidghlgmw2fq42xmc3nzhmx3r0wkbx5314p9jslbrdq6";
  };

  patches = [
    (substituteAll {
      src = ./fix-paths.patch;
      inherit pptp ppp;
    })
  ];

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  buildInputs =
    [
      networkmanager
      ppp
      glib
      openssl
      nss
      pptp
    ]
    ++ lib.optionals withGnome [
      gtk3
      gtk4
      libsecret
      libnma
      libnma-gtk4
    ];

  configureFlags = [
    "--with-gnome=${if withGnome then "yes" else "no"}"
    "--with-gtk4=${if withGnome then "yes" else "no"}"
    "--localstatedir=/var"
    "--enable-absolute-paths"
  ];

  enableParallelBuilding = true;

  passthru = {
    networkManagerPlugin = "VPN/nm-pptp-service.name";
  };

  meta = with lib; {
    description = "PPTP plugin for NetworkManager";
    inherit (networkmanager.meta) platforms;
    homepage = "https://github.com/NetworkManager/NetworkManager-pptp";
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      karlfroldan
    ];
  };
}
