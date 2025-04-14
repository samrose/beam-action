defmodule BeamActionTest do
  use ExUnit.Case
  import ExUnit.CaptureIO
  doctest BeamAction

  @test_workflow """
  name: Test Workflow
  on: push
  jobs:
    test-job:
      runs-on: ubuntu-latest
      steps:
        - name: Echo Hello
          run: echo "Hello World"
        - name: Echo Goodbye
          run: echo "Goodbye World"
  """

  setup do
    # Create a temporary directory for test files
    tmp_dir = System.tmp_dir!()
    workflow_path = Path.join(tmp_dir, "test_workflow.yml")
    File.write!(workflow_path, @test_workflow)

    on_exit(fn ->
      File.rm!(workflow_path)
    end)

    {:ok, workflow_path: workflow_path}
  end

  test "successfully parses and executes a simple workflow", %{workflow_path: workflow_path} do
    # Capture IO output
    output = capture_io(fn ->
      BeamAction.run_workflow(workflow_path)
    end)

    # Verify the output contains expected messages
    assert output =~ "Running job: test-job"
    assert output =~ "Executing: echo \"Hello World\""
    assert output =~ "Executing: echo \"Goodbye World\""
    assert output =~ "Command completed successfully"
  end

  test "handles non-existent file gracefully" do
    output = capture_io(fn ->
      assert catch_exit(BeamAction.run_workflow("nonexistent.yml")) == 1
    end)

    assert output =~ "Failed to read file"
  end

  test "handles invalid YAML gracefully" do
    tmp_dir = System.tmp_dir!()
    invalid_path = Path.join(tmp_dir, "invalid.yml")
    File.write!(invalid_path, "invalid: yaml: {")

    output = capture_io(fn ->
      assert catch_exit(BeamAction.run_workflow(invalid_path)) == 1
    end)

    assert output =~ "Failed to parse YAML"
    File.rm!(invalid_path)
  end

  test "handles workflow with no jobs" do
    tmp_dir = System.tmp_dir!()
    empty_path = Path.join(tmp_dir, "empty.yml")
    File.write!(empty_path, "name: Empty Workflow\non: push\njobs: {}")

    output = capture_io(fn ->
      assert catch_exit(BeamAction.run_workflow(empty_path)) == 1
    end)

    assert output =~ "No jobs found in workflow"
    File.rm!(empty_path)
  end

  test "handles job with no steps" do
    tmp_dir = System.tmp_dir!()
    no_steps_path = Path.join(tmp_dir, "no_steps.yml")
    File.write!(no_steps_path, """
    name: No Steps
    on: push
    jobs:
      empty-job:
        runs-on: ubuntu-latest
        steps: []
    """)

    output = capture_io(fn ->
      assert catch_exit(BeamAction.run_workflow(no_steps_path)) == 1
    end)

    assert output =~ "Running job: empty-job"
    assert output =~ "No steps found in job"
    File.rm!(no_steps_path)
  end

  test "handles step with no run command" do
    tmp_dir = System.tmp_dir!()
    no_run_path = Path.join(tmp_dir, "no_run.yml")
    File.write!(no_run_path, """
    name: No Run
    on: push
    jobs:
      no-run-job:
        runs-on: ubuntu-latest
        steps:
          - name: No Run Step
    """)

    output = capture_io(fn ->
      assert catch_exit(BeamAction.run_workflow(no_run_path)) == 1
    end)

    assert output =~ "Skipping step (no 'run' command)"
    File.rm!(no_run_path)
  end

  test "handles failing command" do
    tmp_dir = System.tmp_dir!()
    failing_path = Path.join(tmp_dir, "failing.yml")
    File.write!(failing_path, """
    name: Failing Command
    on: push
    jobs:
      failing-job:
        runs-on: ubuntu-latest
        steps:
          - name: Failing Step
            run: exit 1
    """)

    output = capture_io(fn ->
      assert catch_exit(BeamAction.run_workflow(failing_path)) == 1
    end)

    assert output =~ "Command failed with exit code: 1"
    File.rm!(failing_path)
  end
end
