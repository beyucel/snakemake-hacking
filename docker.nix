# View DOCKER.md to see how to use this

{
  tag ? "22.05",
  pymksVersion ? "965cadb399a27fc8cc24297c5ac510aaf08e0909"
}:
let
  pkgs = import (builtins.fetchTarball "https://github.com/NixOS/nixpkgs/archive/${tag}.tar.gz") {};
  pypkgs = pkgs.python3Packages;

  nixes_src = builtins.fetchTarball "https://github.com/wd15/nixes/archive/9a757526887dfd56c6665290b902f93c422fd6b1.zip";
  jupyter_extra = pypkgs.callPackage "${nixes_src}/jupyter/default.nix" {
    jupyterlab=(if pkgs.stdenv.isDarwin then pypkgs.jupyter else pypkgs.jupyterlab);
  };

 pymkssrc = builtins.fetchTarball "https://github.com/materialsinnovation/pymks/archive/${pymksVersion}.tar.gz";
  sfepy = pypkgs.sfepy.overridePythonAttrs (old: rec {
    version = "2022.1";
    src = pkgs.fetchFromGitHub {
      owner = "sfepy";
       repo = "sfepy";
       rev = "release_${version}";
      sha256 = "sha256-OayULh/dGI5sEynYMc+JLwUd67zEGdIGEKo6CTOdZS8=";
    };
    meta = old.meta // { broken = false; };
  });
  pymks = pypkgs.callPackage "${pymkssrc}/default.nix" {
    sfepy=sfepy;
    graspi=null;
  };

  lib = pkgs.lib;
  USER = "main";

  from_directory = dir: (lib.mapAttrsToList (name: type:
    if type == "directory" || (lib.hasSuffix "~" name) then
      null
    else
      dir + "/${name}"
  ) (builtins.readDir dir));

  get_dir = x: lib.remove null (from_directory x);
  ## files to copy into the user's home area in container
  ##files_to_copy = builtins.filterSource (p: t: builtins.elem (/. + p) files) ./.;
  files_to_copy = ( get_dir ./Snakefiles ) ++ ( get_dir ./data ) ++ ( get_dir ./software );

  ## functions necessary to copy files to USER's home area
  ## is there an easier way???
  filetail = path: lib.last (builtins.split "(/)" (toString path));
  make_cmd = path: "cp ${path} ./home/${USER}/${filetail path}";
  copy_cmd = paths: builtins.concatStringsSep ";\n" (map make_cmd paths);

  python-env = pkgs.python3.buildEnv.override {
    ignoreCollisions = true;
    extraLibs = with pypkgs; [
      pkgs.snakemake
      jupyter
      matplotlib
      jupyter_extra
      pymks
    ] ++ pymks.propagatedBuildInputs;
  };
in
  pkgs.dockerTools.buildImage {
    name = "wd15/snakemake-hacking";
    tag = "latest";

    contents = [
      python-env
      pkgs.bash
      pkgs.busybox
      pkgs.coreutils
      pkgs.openssh
      pkgs.bashInteractive
    ];

    runAsRoot = ''
      #!${pkgs.stdenv.shell}
      ${pkgs.dockerTools.shadowSetup}
      groupadd --system --gid 65543 ${USER}
      useradd --system --uid 65543 --gid 65543 -d / -s /sbin/nologin ${USER}
    '';

    extraCommands = ''
      mkdir -m 1777 ./tmp
      mkdir -m 777 -p ./home/${USER}
      # echo 'extra commands'
      # pwd
    '' + copy_cmd files_to_copy;

    config = {
      Cmd = [ "bash" ];
      User = USER;
      Env = [
        "OMPI_MCA_plm_rsh_agent=${pkgs.openssh}/bin/ssh"
        "HOME=/home/${USER}"
      ];
      WorkingDir = "/home/${USER}";
      Expose = {
        "8888/tcp" = {};
      };
    };
  }
