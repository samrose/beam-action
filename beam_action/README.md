# BeamAction

A GitHub Actions YAML Runner implemented in Elixir.

## Installation

The package can be installed by adding `beam_action` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:beam_action, "~> 0.1.0"}
  ]
end
```

## Usage

### As a Library

```elixir
BeamAction.run_workflow("path/to/workflow.yml")
```

### As a Mix Task

```bash
mix run_workflow path/to/workflow.yml
```

### As a CLI Tool

The package is also available as a CLI tool through the Nix flake in the parent directory:

```bash
nix run . -- path/to/workflow.yml
```

## Features

- Parses GitHub Actions workflow YAML files
- Executes jobs and steps in sequence
- Captures and displays command output
- Handles command success/failure states

## License

MIT

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/beam_action>.

