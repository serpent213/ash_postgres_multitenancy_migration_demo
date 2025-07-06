{
  pkgs,
  lib,
  inputs,
  ...
}: let
  pkgs-unstable = import inputs.nixpkgs-unstable {system = pkgs.stdenv.system;};
in {
  # https://devenv.sh/packages/
  packages = with pkgs; [
    git
    # Nix code formatter
    alejandra
  ];

  # https://devenv.sh/languages/
  languages = {
    elixir = {
      enable = true;
      package = pkgs.elixir_1_18;
    };
  };

  # https://devenv.sh/services/
  services.postgres = {
    enable = true;
    package = pkgs.postgresql_17;
    initialScript = ''
      CREATE USER postgres SUPERUSER;
    '';
  };

  # https://devenv.sh/pre-commit-hooks/
  # pre-commit.hooks.shellcheck.enable = true;

  devenv.warnOnNewVersion = false;

  # See full reference at https://devenv.sh/reference/options/
}
