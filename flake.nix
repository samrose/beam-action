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
            {:yaml_elixir, "~> 2.9"},
            {:erlexec, "~> 2.0"}
          ])

          defmodule GhRunner do
            def main do
              case System.argv() do
                [yaml_path] -> run_workflow(yaml_path)
                _ -> IO.puts("Usage: ./gh_runner.exs <path_to_yaml>")
              end
            end

            def run_workflow(yaml_path) do
              case File.read(yaml_path) do
                {:ok, yaml_content} ->
                  case YamlElixir.read_from_string(yaml_content) do
                    {:ok, workflow} ->
                      jobs = Map.get(workflow, "jobs", %{})
                      execute_jobs(jobs)
                    {:error, reason} ->
                      IO.puts("Failed to parse YAML: #{inspect(reason)}")
                  end
                {:error, reason} ->
                  IO.puts("Failed to read file: #{inspect(reason)}")
              end
            end

            defp execute_jobs(jobs) do
              Enum.each(jobs, fn {job_name, job_details} ->
                IO.puts("Running job: #{job_name}")
                execute_steps(job_details["steps"])
              end)
            end

            defp execute_steps(steps) do
              Enum.each(steps || [], fn step ->
                case Map.get(step, "run") do
                  nil -> IO.puts("Skipping step (no 'run' command)")
                  command ->
                    IO.puts("Executing: #{command}")
                    run_command(command)
                end
              end)
            end

            defp run_command(command) do
              {:ok, pid, os_pid} = :exec.run(command, [:stdout, :stderr, :monitor])
              handle_command_output(pid, os_pid)
            end

            defp handle_command_output(pid, os_pid) do
              receive do
                {:stdout, ^os_pid, output} ->
                  IO.write(output)
                  handle_command_output(pid, os_pid)
                {:stderr, ^os_pid, output} ->
                  IO.write("ERROR: #{output}")
                  handle_command_output(pid, os_pid)
                {:DOWN, _, :process, ^pid, status} ->
                  case status do
                    :normal ->
                      IO.puts("Command completed successfully")
                    {:exit_status, 0} ->
                      IO.puts("Command completed successfully")
                    {:exit_status, code} ->
                      IO.puts("Command failed with exit code: #{code}")
                    other ->
                      IO.puts("Command terminated with unexpected status: #{inspect(other)}")
                  end
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
