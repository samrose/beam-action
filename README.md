# GitHub Actions YAML Runner

A framework to run GitHub Actions workflow YAML files locally or in CI using Elixir and Nix. This allows you to test and debug your GitHub Actions workflows without pushing to GitHub. At the same time you can run the same program in any CI (incuding GH Actions).


## Rationale

### Why Nix?
- **Reproducible environments**: Nix ensures that the runner and its dependencies are identical across all systems
- **Zero system pollution**: All dependencies are isolated and don't interfere with system packages
- **Easy distribution**: Users can run the tool directly (`nix run`) without installation or dependency management
- **Development consistency**: `nix develop` provides the exact same environment for all contributors
- **Self-contained**: The Elixir runtime, dependencies, and runner script are all bundled together

### Why Elixir/BEAM?
- **Excellent concurrency**: The BEAM VM is ideal for running multiple CI jobs and handling parallel execution
- **Fault tolerance**: Elixir's supervisor patterns help manage long-running processes reliably
- **Real-time output**: BEAM's message passing makes it natural to stream command output in real-time
- **Cross-platform**: Elixir runs consistently across different operating systems
- **Resource efficient**: BEAM's lightweight processes are perfect for managing multiple CI tasks
- **Pattern matching**: Makes parsing and handling YAML structures clean and maintainable

### Process Management with erlexec

The runner uses `erlexec` for process management, which provides several key advantages:

- **OS Process Monitoring**: erlexec maintains a direct link to OS processes, allowing immediate detection of crashes or termination
- **Signal Handling**: Can send and handle OS signals (SIGTERM, SIGKILL, etc.) gracefully
- **Stream Control**: Provides fine-grained control over stdout/stderr streams, enabling:
  - Real-time output monitoring
  - Buffer management
  - Encoding handling
- **Resource Cleanup**: Automatically handles process cleanup, preventing zombie processes
- **Error Recovery**: Enables sophisticated error handling:
  - Capture and respond to specific exit codes
  - Handle process timeouts
  - Manage process termination gracefully
- **Process Tree Management**: Can manage entire process trees, useful for complex CI commands that spawn child processes

This robust process management ensures that CI jobs run reliably and can be properly monitored and controlled throughout their lifecycle.



## Features

- Parse and execute GitHub Actions workflow YAML files
- Run jobs and steps defined in the workflow
- Real-time output of command execution
- Error handling and status reporting
- Nix-based installation and dependency management

## Installation

This project uses Nix for dependency management. You can install it using:

```bash
nix profile install github:samrose/beam-action
```

## Usage

You can run the tool in several ways:

### Direct from source
If you have the source code locally:
```bash
nix run . -- workflow.yml
```

### Direct from GitHub
Run it directly without installation:
```bash
nix run github:samrose/beam-action -- workflow.yml
```

### Using installed binary
If you've installed it to your profile:
```bash
gh-runner path/to/workflow.yml
```

The runner will:
1. Parse the YAML file
2. Extract all jobs and their steps
3. Execute each step's commands
4. Display real-time output and status

## Development

To set up a development environment:

```bash
nix develop
```

This will provide you with:
- Elixir and its dependencies
- Properly configured MIX_HOME and HEX_HOME
- All necessary environment variables

## How It Works

The runner:
1. Uses `yaml_elixir` to parse the workflow YAML
2. Extracts jobs and their steps
3. Executes each step's commands using `erlexec`
4. Captures and displays stdout/stderr in real-time
5. Reports command completion status

## Requirements

- Nix package manager
- Elixir (automatically provided by Nix)

## License

MIT

