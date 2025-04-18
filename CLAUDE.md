# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands
- **Make commands**: `make list`, `make dotfiles`, `make config`, `make vscodeExtensions`
- **PowerShell aliases**: `lint`, `format`, `type-check` for pnpm-based projects

## Repository Structure
- `configs/`: Configuration files for various tools
- `ahk/`: AutoHotKey scripts for Windows
- `osx/`: macOS specific configurations
- `windows/`: Windows specific configurations and PowerShell scripts
- `powershell/`: PowerShell scripts, including komorebi window manager scripts
- `keymaps/`: Custom keyboard mappings

## Guidelines
- Match existing formatting styles in each file
- Follow platform-specific conventions (PowerShell for Windows, Shell for Unix)
- Keep configurations simple and modular
- Document any non-obvious configuration changes in comments
- Use absolute paths when appropriate for cross-platform compatibility

## Common Tasks
- Use `make dotfiles` to apply dotfile configurations
- PowerShell scripts should be executed with appropriate execution policy
- Shell scripts may require executable permissions (`chmod +x`)