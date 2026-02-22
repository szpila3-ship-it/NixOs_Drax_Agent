{
  description = "NixOs_Drax_Agent";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        ./configuration.nix
        ./hardware-configuration.nix
        ({ config, pkgs, ... }: {
          networking.firewall.enable = false;
          services.openssh.enable = true;
          networking.networkmanager.enable = true;
          security.sudo.wheelNeedsPassword = false;
          users.users.drax.extraGroups = [ "wheel" "video" "input" "networkmanager" ];

          services.xserver.enable = true;
          services.xserver.desktopManager.xfce.enable = true;
          services.xserver.displayManager.lightdm.enable = true;
          services.xserver.xkb.layout = "pl";

          # Nvidia T400 Mobile
          hardware.nvidia = {
            modesetting.enable = true;
            powerManagement.enable = false;
            powerManagement.finegrained = false;
            open = false;
            nvidiaSettings = true;
            package = config.boot.kernelPackages.nvidiaPackages.stable;
          };
          services.xserver.videoDrivers = [ "nvidia" ];

          environment.systemPackages = with pkgs; [ git vim firefox xterm wget pciutils nvidia-settings ];
        })
      ];
    };
  };
}
