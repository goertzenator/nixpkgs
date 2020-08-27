{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.omadad;
  defaultUser = "omadad";
in {
  options.services.omadad = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Enable TP-Link Omada Controller (wifi access point controller).
      '';
    };

    user = mkOption {
      default = defaultUser;
      example = "john";
      type = types.str;
      description = ''
        The name of an existing user account to use to own the omadad server
        process. If not specified, a default user will be created.
      '';
    };

    group = mkOption {
      default = defaultUser;
      example = "john";
      type = types.str;
      description = ''
        Group to own the omadad server process.
      '';
    };

    dataDir = mkOption {
      default = "/var/lib/omadad/";
      example = "/home/john/.omadad/";
      type = types.path;
      description = ''
        The state directory for omadad.
      '';
    };

    httpPort = mkOption {
      type = types.int;
      default = 8088;
      description = "http listening port";
    };

    httpsPort = mkOption {
      type = types.int;
      default = 8043;
      description = "https listening port";
    };

    mongoPort = mkOption {
      type = types.int;
      default = 27212;
      description = "Mongo database connection port.  Specify alternate if running multiple instances.";
    };

    openFirewall = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Whether to open ports in the firewall for omadad.
      '';
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.omadad pkgs.jre ];

    systemd.services.omadad = {
      description = "Wifi access point controller";
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];
      path = [ pkgs.bash pkgs.mongodb pkgs.nettools pkgs.curl ];

      serviceConfig = let
        java_opts = "-classpath '${pkgs.omadad}/lib/*' -server -Xms128m -Xmx1024m -XX:MaxHeapFreeRatio=60 -XX:MinHeapFreeRatio=30 -XX:+HeapDumpOnOutOfMemoryError -DhttpPort=${toString cfg.httpPort} -DhttpsPort=${toString cfg.httpsPort} -DmongoPort=${toString cfg.mongoPort} -DdataDir=${cfg.dataDir} -Deap.home=${pkgs.omadad}";
        main_class = "com.tplink.omada.start.OmadaLinuxMain";
      in {
        Type = "simple";
        User = cfg.user;
        Group = cfg.group;
        ExecStart = "${pkgs.jre}/bin/java ${java_opts} ${main_class}";
        WorkingDirectory = "${cfg.dataDir}";
      };

      preStart = ''
          mkdir -p ${cfg.dataDir}/data/db
          mkdir -p ${cfg.dataDir}/data/portal
          mkdir -p ${cfg.dataDir}/data/map
          mkdir -p ${cfg.dataDir}/logs
          mkdir -p ${cfg.dataDir}/work
      '';
    };

    networking.firewall.allowedTCPPorts = mkIf cfg.openFirewall [cfg.httpPort cfg.httpsPort];

    users.users = optionalAttrs (cfg.user == defaultUser) {
      ${defaultUser} =
        { description = "omadad server daemon owner";
          group = defaultUser;
          # uid = config.ids.uids.omadad;
          home = cfg.dataDir;
          createHome = true;
        };
    };

    users.groups = optionalAttrs (cfg.user == defaultUser) {
      ${defaultUser} =
        { # gid = config.ids.gids.omadad;
          members = [ defaultUser ];
        };
    };
  };
}
