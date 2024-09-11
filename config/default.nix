{ pkgs, lib, modulesPath, config, ... }:

let
  zed-fhs = pkgs.buildFHSUserEnv {
    name = "zed";
    targetPkgs = pkgs: with pkgs; [ zed-editor ];
    runScript = "zed";
  };

  zedNodeFixScript = pkgs.writeShellScriptBin "zedNodeFixScript" ''
    nodeVersion="node-v${pkgs.nodejs.version}-linux-x64"
    zedNodePath="${config.xdg.dataHome}/zed/node/$nodeVersion"

    # Eliminar la versión de node descargada por zed-editor
    rm -rf $zedNodePath

    # Crear el enlace simbólico a la versión de node de nixpkgs
    ln -sfn ${pkgs.nodejs} $zedNodePath
  '';

in {
  imports = [
    (modulesPath + "/installer/cd-dvd/installation-cd-base.nix")
  ];

  # Enable plymouth
  boot.plymouth.enable = true;

  environment.defaultPackages = with pkgs; [
    firefox
    git
    gparted
    nano
    rsync
    vim
    zed-fhs
    nodejs
    nixd
    zedNodeFixScript
  ];

  hardware.pulseaudio.enable = lib.mkForce false; # Pipewire complains if not force disabled.

  # Provide networkmanager for easy wireless configuration.
  networking = {
    networkmanager.enable = true;
    wireless.enable = lib.mkImageMediaOverride false;
  };

  nix.settings = {
    experimental-features = ["nix-command" "flakes"];
    substituters = ["https://cosmic.cachix.org/" "https://nix-community.cachix.org" "https://cache.nixos.org?priority=10"];
    trusted-public-keys = ["cosmic.cachix.org-1:Dya9IyXD4xdBehWjrkPv6rtxpmMdRel02smYzA85dPE=" "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="];
  };

  powerManagement.enable = true;

  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (subject.isInGroup("wheel")) {
        return polkit.Result.YES;
      }
    });
  '';

  services = {
    desktopManager.cosmic.enable = true;
    displayManager.cosmic-greeter.enable = true;
  };

  # Add XDG configuration for Zed
  environment.sessionVariables = {
    XDG_DATA_HOME = "$HOME/.local/share";
  };
}
