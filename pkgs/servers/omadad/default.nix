{ stdenv, fetchurl, dpkg }:

stdenv.mkDerivation rec {
  pname = "omadad";

  # version = "3.2.10";
  # src = fetchurl {
  #   url = "https://static.tp-link.com/2020/202004/20200420/Omada_Controller_v3.2.10_linux_x64.tar.gz";
  #   sha256 = "0y0kx00wgws918wz76ldpvz340aid0ay5nckkg8x38yclx929qgh";
  # };

  version = "4.1.5";
  src = fetchurl {
    url = "ftp://ftp.rent-a-guru.de/private/omada-sdn-controller_${version}-1_all.deb";
    sha256 = "190i3p9lysfdc6qppxvi12ypcxc31vzzkccj7qhmwpyvrh5fp5l3";
  };

  buildInputs = [ dpkg ];

  dontConfigure = true;
  dontBuild = true;
  unpackPhase = "dpkg-deb -x ${src} ./";


  installPhase = ''
    # Use heavily parameterized property files to support separate data dir and various NixOS option config
    mkdir -p $out/properties
    cp ${./omada.properties} $out/properties/omada.properties
    cp ${./log4j2.properties} $out/properties/log4j2.properties

    mv opt/tplink/OmadaController-${version}/lib $out/
    mv opt/tplink/OmadaController-${version}/webapps $out/
    mv opt/tplink/OmadaController-${version}/keystore $out/
  '';

  # Note, no start script included here.  See options in nixos/modules/services/networking/omadad.nix

  meta = with stdenv.lib; {
    description = "Controller for TP-Link wifi access points";
    homepage = "https://www.tp-link.com/us/support/download/omada-software-controller";
    license = licenses.publicDomain;  # no license specified
    maintainers = [ maintainers.goertzenator ];
    platforms = with platforms; linux;
  };
}
