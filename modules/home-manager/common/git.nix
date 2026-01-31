{ config, lib, pkgs, ... }:

let
  cfg = config.my.common.git;
in
{

  options.my.common.git.enable = lib.mkEnableOption "Enables git.";

  config = lib.mkIf cfg.enable {

    home.packages = with pkgs; [
      git-machete
      gibo
      tig
    ];

    programs.git = {
      enable = true;
      lfs.enable = true;

      settings = {
        user = {
          name = "Jana Förster";
          email = lib.mkDefault "jtraue@disturbed.systems";
        };
        alias = {
          lg = "log --oneline";
          st = "status -sb";
          sed = "! git grep -z --full-name -l '.' | xargs -0 sed -i -e";
          style = "!f() { branch=\${1-upstream/master}; echo $branch; git diff -z $branch --name-only | xargs -0 -n 1 style.sh; }; f";
          when = "for-each-ref --sort=committerdate --format='%(refname:short) * %(authorname) * %(committerdate:relative)' refs/remotes/";
          # Work-related aliases (filter by work email)
          standup = "log --pretty=format:'%Cred%h%Creset -%Creset %s %Cgreen(%cD) %C(bold blue)<%an>%Creset' --since yesterday --author jana.traue@cyberus-technology.de --all";
          wsr = "log --pretty=format:'%Cred%h%Creset -%Creset %s %Cgreen(%cD) %C(bold blue)<%an>%Creset' --since 'last Monday' --author jana.traue@cyberus-technology.de --all";
        };
        core.editor = "vim";
        diff.tool = "vimdiff";
        merge.tool = "vimdiff";
        rebase.autoSquash = true;
      };

      ignores = [
        ".ackrc"
        ".cache"
        ".ccls-cache"
        ".clangd"
        ".envrc"
        ".mypy_cache"
        ".pre-commit-config.yaml"
        "result"
      ];
    };

    home.file.".tigrc".text = ''
      # commands with user prompts
      bind main   ! !?git revert %(commit)
      bind status a !?git commit --amend

      bind main   R !git rebase -i %(commit)
      bind diff   R !git rebase -i %(commit)
    '';

  };
}
