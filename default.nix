{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
with lib; let
  cfg = config.services.home-merger;
in {
  config = let
    homeManagerModule = inputs.home-manager.nixosModules.home-manager;
    # A Function to apply home.nix home-manager
    # configurations to multiple users
    # Args:
    # - home_modules; a list of home-manager modules "home.nix" files,
    # - apply_on_users; a list of usernames
    # Return
    # - a list of modules
    # Usage:
    # ```nix
    #  imports = [] ++ mkApplyHomes [(import ./a/home.nix)] ["anon"];
    # ```
    mkApplyHomes = home_modules: apply_on_users: [
      homeManagerModule
      {
        home-manager =
          {
            useGlobalPkgs = true;
            extraSpecialArgs = {inherit inputs;};
          }
          // builtins.listToAttrs (
            builtins.map (u: {
              name = "users";
              value = {
                ${u} = {
                  home.stateVersion = "24.05";
                  imports = home_modules;
                };
              };
            })
            apply_on_users
          );
      }
    ];
  in mkMerge [
    (mkIf
      cfg.enable
      (
        mkApplyHomes
        cfg.modules
        cfg.users
      ))
  ];
}
