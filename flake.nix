{
  description = "GitHub Actions YAML Runner in Elixir";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        elixir = pkgs.beam.packages.erlang.elixir;

        runnerScript = pkgs.writeText "gh_runner.exs" ''
          #!/usr/bin/env elixir

          Mix.install([
            {:beam_action, "~> 0.1.0"}
          ])

          defmodule GhRunner do
            def main do
              case System.argv() do
                [yaml_path] -> BeamAction.run_workflow(yaml_path)
                _ -> IO.puts("Usage: ./gh_runner.exs <path_to_yaml>")
              end
            end
          end

          GhRunner.main()
        '';

        runScript = pkgs.writeShellScriptBin "gh-runner" ''
          mkdir -p .nix-mix .nix-hex
          export MIX_HOME=$PWD/.nix-mix
          export HEX_HOME=$PWD/.nix-hex
          export PATH=$MIX_HOME/bin:$HEX_HOME/bin:$PATH
          export ELIXIR_ERL_OPTIONS="+fnu"
          ${elixir}/bin/elixir ${runnerScript} "$@"
        '';
      in
      {
        packages.default = runScript;

        apps.default = {
          type = "app";
          program = "${runScript}/bin/gh-runner";
        };

        devShells.default = pkgs.mkShell {
          buildInputs = [ elixir ];
          shellHook = ''
            mkdir -p .nix-mix .nix-hex
            export MIX_HOME=$PWD/.nix-mix
            export HEX_HOME=$PWD/.nix-hex
            export PATH=$MIX_HOME/bin:$HEX_HOME/bin:$PATH
            export ELIXIR_ERL_OPTIONS="+fnu"
          '';
        };
      }
    );
}
