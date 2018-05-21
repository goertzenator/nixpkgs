{ stdenv, lib, unzip, fetchurl }:

stdenv.mkDerivation rec {
  name = "eco-server";
  version = "0.7.4.5-beta";

  src = fetchurl {
    url = "https://s3-us-west-2.amazonaws.com/eco-releases/EcoServer_v${version}.zip";
    sha256 = "0y8r1q3kl2wwhmhd94p6pbs0sj0kham4m50mbfkx9afplmhw16m9";
  };

  sourceRoot = ".";

  unpackCmd = ''
    unzip "$src"
  '';

  buildPhase = "";   

  installPhase = "";

  meta = with lib; {
    description = "Server for Eco Global Survival";
    homepage = "http://www.strangeloopgames.com/eco/";
    license = licenses.unfree;
    maintainers = [ maintainers.goertzenator ];
    platforms = platforms.linux;
  };
}
