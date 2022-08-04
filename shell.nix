#
# $ nix-shell --pure --arg withBoost false --argstr tag 20.09
#

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
in
  pkgs.mkShell rec {
    pname = "snakemake-tutorial";
    nativeBuildInputs = with pypkgs; [
      pkgs.snakemake
      jupyter
      matplotlib
      jupyter_extra
      pymks
    ];
    shellHook = ''
      # export NIX_SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt
      # export OMPI_MCA_plm_rsh_agent=${pkgs.openssh}/bin/ssh

      SOURCE_DATE_EPOCH=$(date +%s)
      export PYTHONUSERBASE=$PWD/.local
      export USER_SITE=`python -c "import site; print(site.USER_SITE)"`
      export PYTHONPATH=$PYTHONPATH:$USER_SITE
      export PATH=$PATH:$PYTHONUSERBASE/bin

    '';
  }
