# GitHub Actions YAML Runner

A tool to run GitHub Actions workflow YAML files locally using Elixir. This allows you to test and debug your GitHub Actions workflows without pushing to GitHub.

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

[Add your license here] 