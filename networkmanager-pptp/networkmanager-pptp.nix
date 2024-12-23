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
  pname = "NetworkManager-pptp";
  version = "1.2.13-dev";

  src = fetchFromGitHub {
    owner = "NetworkManager";
    repo = "NetworkManager-pptp";
    rev = version;
    hash = "sha256-10sbp2f6nidghlgmw2fq42xmc3nzhmx3r0wkbx5314p9jslbrdq6";
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
    networkManagerPlugin = "VPN/nm-l2tp-service.name";
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
