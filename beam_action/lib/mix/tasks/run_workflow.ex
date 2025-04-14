defmodule Mix.Tasks.RunWorkflow do
  use Mix.Task

  @shortdoc "Runs a GitHub Actions workflow from a YAML file"
  @moduledoc """
  Runs a GitHub Actions workflow from a YAML file.

  ## Usage

      mix run_workflow path/to/workflow.yml
  """

  def run(args) do
    case args do
      [yaml_path] -> BeamAction.run_workflow(yaml_path)
      _ -> Mix.raise("Usage: mix run_workflow <path_to_yaml>")
    end
  end
end
