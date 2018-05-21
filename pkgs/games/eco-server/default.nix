{ stdenv, lib, unzip, fetchurl, mono58 }:

let
  mono = mono58;
in
  stdenv.mkDerivation rec {
    name = "eco-server";
    version = "0.7.4.5-beta";

    src = fetchurl {
      url = "https://s3-us-west-2.amazonaws.com/eco-releases/EcoServer_v${version}.zip";
      sha256 = "0y8r1q3kl2wwhmhd94p6pbs0sj0kham4m50mbfkx9afplmhw16m9";
    };

    nativeBuildInputs = [ unzip mono ];

    sourceRoot = ".";

    installPhase = ''
      mkdir -p $out/server
      cp -R * $out/server/

      mkdir -p $out/bin

      #!${stdenv.shell}
      [ "$1" != "" ] && echo 'Must specify data directory ("." is acceptable).' && exit 1

      cat <<EOF >$out/bin/EcoServer
      #!${stdenv.shell}
      [ "\$1" == "" ] && echo 'Must specify data directory ("." is acceptable).' && exit 1
      cd "\$1"
      [ ! -d Configs ] && cp -r --no-preserve=ownership,mode,xattr $out/server/Configs ./ && chmod -R 664 Configs
      [ ! -d WebClient ] && cp -r --no-preserve=ownership,mode,xattr $out/server/WebClient ./ && chmod -R 664 WebClient
      [ ! -d Mods ] && cp -r --no-preserve=ownership,mode,xattr $out/server/Mods ./ && chmod -R 664 Mods
      [ ! -d doc ] && cp -r --no-preserve=ownership,mode,xattr $out/server/doc ./ && chmod -R 664 doc

      exec ${mono}/bin/mono $out/server/EcoServer.exe -nogui
      EOF

      chmod +x $out/bin/EcoServer
    '';

    meta = with lib; {
      description = "Server for Eco Global Survival";
      homepage = "http://www.strangeloopgames.com/eco/";
      license = licenses.unfree;
      maintainers = [ maintainers.goertzenator ];
      platforms = platforms.linux;
    };
  }
