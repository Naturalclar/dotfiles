# Test Colon Scripts

This is a test package to demonstrate the `run-script` function with scripts that have colons in their names.

## How to Use

1. Source your .zshrc file to load the updated function:

   ```bash
   source ~/.zshrc
   ```

2. Navigate to this directory:

   ```bash
   cd test/test-colon-scripts
   ```

3. Run the `run-script` function:

   ```bash
   run-script
   ```

   Or use the alias:

   ```bash
   rs
   ```

   Or use the keyboard shortcut: `Ctrl+N`

4. You'll see a list of available scripts from package.json with a preview of what each script does.

5. Select a script using the arrow keys and press Enter to run it. Try selecting scripts with colons in their names like `build:dev`, `test:unit`, or `lint:fix`.

## What's Special About This Test?

This test demonstrates that the `run-script` function can properly handle script names that contain colons (`:`) such as:

- `build:dev`
- `build:prod`
- `test:unit`
- `test:e2e`
- `lint:fix`
- `dev:server`
- `prod:server`

The function uses a triple colon (`:::`) as a delimiter in the temporary file to avoid conflicts with script names that contain colons. This ensures that the entire script name, including any colons, is properly extracted and passed to the package manager.
