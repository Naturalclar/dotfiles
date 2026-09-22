---
name: ui-screenshot
description: Capture screenshots of user-visible UI changes on the current local branch with agent-browser. Use after frontend or UI work, before opening or updating a PR, or when the user says "UI変更のスクリーンショットを撮って", "画面差分を撮って", "変更画面を見せて", "capture screenshots of this branch", or "get screenshots for the PR". First compare the branch and working tree with its base; when there is no visible UI change, report that and do not manufacture a screenshot.
---

# ui-screenshot

Capture evidence of what the current branch changed. The deliverable is the
smallest set of screenshots that makes the visible change clear, with the route,
state, and viewport for each one — not a tour of the application.

## Find the visible change

1. **Establish the base without hardcoding it.** Honour a base named by the
   user or PR. Otherwise use the current branch's upstream remote, or `origin`
   when it has none, and derive that remote's default branch from its symbolic
   `HEAD`. Fall back to an existing `main` or `master` ref on the same remote
   only when needed. Use the merge base with `HEAD`; a feature branch may be
   behind the default branch.

2. **Inspect the complete local result.** Review committed, staged, and
   unstaged changes against that merge base, plus untracked files:

   ```sh
   merge_base=$(git merge-base HEAD "$remote/$default")
   git diff --name-status "$merge_base"
   git diff --stat "$merge_base"
   git ls-files --others --exclude-standard
   ```

   Read the relevant hunks. Do not decide from extensions alone: components,
   styles, templates, assets, routes, and user-facing copy are obvious UI
   candidates, but a backend or configuration change can also create a visible
   loading, empty, error, or permission state.

3. **Stop when nothing visible changed.** Say which diff you checked and why it
   has no screenshotable UI effect. Do not take a generic home-page screenshot
   merely to produce a file.

4. **Map each change to a screen and state.** Trace the changed component to its
   route and use stories, browser tests, fixtures, or nearby callers to learn
   how to reach it. Group changes that appear together. Capture separate shots
   only when they show distinct states or breakpoints.

If the route or required state cannot be derived after reading the project,
ask for that one missing fact. Do not guess a plausible-looking screen.

## Prepare the app

- Read the repository instructions and package scripts. Reuse a suitable
  running local server when one is already available; otherwise start the
  documented development command, keep its PID and log, and wait until its URL
  responds. Do not install dependencies, rewrite configuration, or seed shared
  or production data merely to obtain a screenshot without permission.
- Use existing fixtures, demo accounts, or development controls to reach the
  changed state. Do not perform destructive submissions. If authentication is
  unavoidable, use an existing approved browser profile or agent-browser auth
  state; never put credentials in a command line or screenshot.
- Write the screenshots **inside the working directory**, into a path git
  ignores. Inside, because a viewer that renders the report can only reach
  files under the working directory (see "Show the screenshots"); ignored, so
  they do not silently become source changes. Prefer the project's existing
  artifact directory when it already has an ignored one. Otherwise create
  `.screenshots/` at the repository root, and confirm it is ignored:

  ```sh
  git check-ignore -q .screenshots || echo '.screenshots/' >> .git/info/exclude
  ```

  Use `.git/info/exclude` rather than `.gitignore`: the choice is local, so it
  does not change a tracked file. Use descriptive names such as
  `settings-empty-state-desktop.png`. Do not use `mktemp -d` or anywhere else
  outside the working directory — the image cannot be served from there.

## Capture with agent-browser

1. Confirm `agent-browser` is available, then read its version-matched guide
   before using it:

   ```sh
   agent-browser skills get core --full
   ```

2. Generate a session dedicated to this worktree and use it for every browser
   command. Pass `--session "$session"` explicitly when shell state does not
   persist:

   ```sh
   session=$(agent-browser session id --scope worktree --prefix ui-screenshot)
   agent-browser --session "$session" set viewport 1440 900
   agent-browser --session "$session" open "$url"
   ```

   Never use the unnamed shared session, and never close every session.

3. Wait for a meaningful ready signal rather than sleeping for an arbitrary
   duration. Take a snapshot, interact through fresh refs, and re-snapshot after
   navigation or re-rendering:

   ```sh
   agent-browser --session "$session" wait --load networkidle
   agent-browser --session "$session" snapshot -i
   ```

   Navigate to the changed route and reproduce the relevant state. Scroll the
   changed element into view. Make sure the screenshot is not showing a loading
   placeholder, error overlay, tooltip from automation, or unrelated open menu
   unless that is the state being documented.

4. Capture a clean PNG without annotations. Use an element screenshot when the
   change is isolated and the selector is stable; otherwise capture the
   viewport. Use `--full` only when the change genuinely spans the page.

   ```sh
   agent-browser --session "$session" screenshot "$output_path"
   # or: agent-browser --session "$session" screenshot "$selector" "$output_path"
   ```

   Default to 1440x900. Add a mobile or other breakpoint only when responsive
   behaviour changed or the request calls for it. Match dark/light mode to the
   changed behaviour rather than producing both automatically.

5. Verify the result before reporting it. Confirm the final URL and visible
   changed content, inspect the image when the environment supports image
   viewing, and check `agent-browser errors` and `agent-browser console` for
   failures that invalidate the shot. A saved PNG is not evidence if the app
   failed to render the change.

## Show the screenshots in the reply

A path on its own is only useful to someone sitting at this machine. Put each
screenshot in the reply itself as a Markdown image, so a viewer reading the
conversation in a browser renders the picture instead of a filename:

```markdown
![Settings, empty state, 1440x900](/abs/path/to/.screenshots/settings-empty-state-desktop.png)
```

Write it in the **final message of the turn**, the one that carries the report.
Paths named in progress updates, tool output, or a question mid-turn are not
picked up.

For the image to render rather than degrade to a filename, all of these must
hold — they are why the capture rules above are what they are:

- the file is **under the working directory**, by real path. A symlink or `../`
  that escapes it is refused, and so is anywhere outside it such as `/tmp`;
- the bytes really are **PNG, JPEG, GIF, or WebP** — the extension is not
  trusted, and SVG is never rendered;
- the file is **20MB or smaller**;
- the reference is a relative path from the working directory or an absolute
  path, never a `file:`, `data:`, or `http(s)` URL. A remote URL is left as a
  link rather than fetched.

When a screenshot cannot meet these, still report its path and say plainly that
it will not render inline. Do not move a file outside the working directory to
"clean up" after writing the report — that is what breaks the rendering.

The constraints above are the ones SAI's web UI applies when it serves an image
named in a turn's reply; a viewer that does not render images loses nothing,
since the alt text and the path are both still in the report.

## Finish

Close only the named browser session. Stop only the development server you
started; leave pre-existing processes alone.

Report:

- the UI change found and the base used for comparison;
- each screenshot as a Markdown image, with its route/state and viewport;
- each screenshot's absolute path, for anyone working from a terminal;
- any visible change not captured and the concrete blocker;
- whether the server was reused or started and then stopped.

Do not switch branches or overwrite a dirty working tree to create a baseline.
Before/after pairs or pixel diffs are separate work: make them only when the
user asks and use an isolated worktree for the base version. Do not commit the
screenshots unless requested.
