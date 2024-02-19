
      {
        config,
        pkgs,
        lib,
        ...
      }:
        with inputs;
        with lib; let
          # Shorter name to access final settings
          homeManagerModule = home-manager.nixosModules.home-manager;
          cfg = config.home-merger;
        in {

          # Set the module options
          options.home-merger = {
            enable = mkEnableOption ''
              Wether to enable thos modules for the specified users'.
            '';

            users = mkOption {
              type = with types; listOf str;
              default = [];
              example = literalExpression "[\"alice\",\"bob\"]";
              description = ''
                The name of users for whome to add this module.
              '';
            };
            extraSpecialArgs = mkOption {
              type = with types; attrs;
              default = {};
              example = literalExpression "{ inherit emacs-overlay; }";
              # type = with types; listOf inferred;
              description = ''
                Extra `specialArgs` passed to Home Manager. This
                option can be used to pass additional arguments to all modules.
              '';
            };
            modules = mkOption {
              type = with types; listOf raw;
              default = [];
              example = literalExpression "[ ./home.nix, otherModule ]";
              description = ''
                Modules to add to the user configuration.
              '';
            };
          };
          imports = [
            homeManagerModule
            {
              home-manager =
                {
                  useGlobalPkgs = false;
                  extraSpecialArgs = {inherit system;} // cfg.extraSpecialArgs;
                }
                // builtins.listToAttrs (
                  builtins.map (u: {
                    name = "users";
                    value = {
                      ${u} = {
                        home.stateVersion = "24.05";
                        imports = cfg.modules;
                      };
                    };
                  })
                  cfg.users
                );
            }
          ];
        }