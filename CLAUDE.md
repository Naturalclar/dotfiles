# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands
- **Make commands**: `make list`, `make dotfiles`, `make config`, `make vscodeExtensions`, `make help`
- **PowerShell aliases**: `lint`, `format`, `type-check` for pnpm-based projects
- **Testing**: Navigate to test directories (e.g., `cd test/test-package-scripts`) and run `run-script` or its alias `rs`
- **Single test**: Run specific test by navigating to the test directory and executing the relevant script

## Repository Structure
- `configs/`: Configuration files for various tools
- `ahk/`: AutoHotKey scripts for Windows
- `osx/`: macOS specific configurations
- `windows/`: Windows specific configurations and PowerShell scripts
- `powershell/`: PowerShell scripts, including komorebi window manager scripts
- `keymaps/`: Custom keyboard mappings
- `test/`: Test cases for scripts and functions

## Code Style Guidelines
- Match existing formatting styles in each file
- Follow platform-specific conventions (PowerShell for Windows, Shell for Unix)
- Keep configurations simple and modular
- Document any non-obvious configuration changes in comments
- Use absolute paths when appropriate for cross-platform compatibility
- For shell scripts, prefer POSIX-compatible syntax when possible
- For PowerShell scripts, follow Microsoft's PowerShell best practices

## Common Tasks
- Use `make dotfiles` to apply dotfile configurations
- PowerShell scripts should be executed with appropriate execution policy
- Shell scripts may require executable permissions (`chmod +x`)
- For Windows setup: Install required dependencies (fzf, mingw, etc.) using scoop
- For testing npm scripts: Use the `run-script` function or its alias `rs`