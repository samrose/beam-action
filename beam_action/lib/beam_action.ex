defmodule BeamAction do
  @moduledoc """
  GitHub Actions YAML Runner in Elixir
  """

  @doc """
  Main entry point for running a GitHub Actions workflow from a YAML file.
  """
  def run_workflow(yaml_path) do
    case File.read(yaml_path) do
      {:ok, yaml_content} ->
        case YamlElixir.read_from_string(yaml_content) do
          {:ok, workflow} ->
            jobs = Map.get(workflow, "jobs", %{})
            if map_size(jobs) == 0 do
              IO.puts("No jobs found in workflow")
            else
              execute_jobs(jobs)
            end
          {:error, reason} ->
            IO.puts("Failed to parse YAML: #{inspect(reason)}")
        end
      {:error, reason} ->
        IO.puts("Failed to read file: #{inspect(reason)}")
    end
  end

  @doc """
  Executes all jobs in the workflow.
  """
  def execute_jobs(jobs) do
    Enum.each(jobs, fn {job_name, job_details} ->
      IO.puts("Running job: #{job_name}")
      steps = Map.get(job_details, "steps", [])
      if Enum.empty?(steps) do
        IO.puts("No steps found in job")
      else
        execute_steps(steps)
      end
    end)
  end

  @doc """
  Executes all steps in a job.
  """
  def execute_steps(steps) do
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
