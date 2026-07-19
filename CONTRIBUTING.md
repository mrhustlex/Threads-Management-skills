# Contributing to Threads API CLI Skills

Thanks for considering contributing! Here's how to get started.

## Getting Started

1. Fork the repository
2. Clone your fork
3. Create a feature branch: `git checkout -b feature/my-feature`
4. Make your changes
5. Test thoroughly
6. Commit with a clear message
7. Push and open a Pull Request

## Development

```bash
# Run setup
./scripts/setup.sh

# Test a command
./scripts/threads.sh profile

# Dry run (skip actual API call)
./scripts/threads.sh posts 5 --dry-run
```

## Adding Commands

1. Add a new `case` block in `scripts/threads.sh`
2. Update the `help` section at the top
3. Update `README.md` command table
4. Test with `--dry-run` first

## Guidelines

- **No tokens in code** — never commit `.env` or access tokens
- **Shellcheck clean** — run `shellcheck scripts/threads.sh` before submitting
- **No dependencies** — keep it pure Bash + curl + jq
- **One command, one job** — each subcommand should do exactly one thing

## Reporting Issues

Open an issue with:
- What you expected
- What happened
- Steps to reproduce
- OS and Bash version (`bash --version`)

## License

By contributing, you agree your code is licensed under MIT.
