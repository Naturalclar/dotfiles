---
name: tailscale-serve
description: Expose a locally-running dev server to the rest of the tailnet with Tailscale Serve, so a browser on another machine can reach it. Detects what is listening, serves it over HTTPS, reports the URL, and tears it down again. Use when the user says "tailscale serve", "このサービスを他のマシンから見たい", "SSH先のlocalhostにアクセスしたい", "serve this port", or similar.
---

# tailscale-serve

Dev servers bind to `127.0.0.1`, so a server started over SSH is invisible from
the machine you are sitting at. `tailscale serve` proxies from the tailnet to
that same loopback address — **the dev server does not have to be restarted or
rebound to `0.0.0.0`**, which is the whole appeal.

Scope: **tailnet only**. Publishing to the internet is `tailscale funnel`, which
this skill does not run — see Constraints.

## Steps

1. **Find what to serve.** If the user named a port, use it. Otherwise list what
   is listening:

   ```bash
   lsof -nP -iTCP -sTCP:LISTEN    # macOS
   ss -ltnp                       # Linux
   ```

   Report only the plausible dev ports (3000/4321/5173/8000/8080 …) with their
   process names, not the whole table. If exactly one dev server is up, say
   which one you picked instead of asking.

2. **Check Tailscale is usable.**

   ```bash
   tailscale status
   ```

   If the CLI is missing or the node is logged out, say so and stop — nothing
   else here works.

3. **Serve it.**

   ```bash
   tailscale serve --bg 3000
   ```

   `--bg` keeps it up after the command returns; without it the command runs in
   the foreground and the mapping dies with Ctrl+C. Background is what you want
   for a session you will come back to.

   Run it with a short timeout (~30s). On success it returns in a couple of
   seconds; anything longer means it is sitting on an enablement prompt (see
   "When it does not work") and waiting the full default timeout teaches you
   nothing.

   The target can also be `localhost:3000`, a full URL with a path
   (`http://localhost:3000/foo`), `https+insecure://localhost:8443` for a dev
   server with a self-signed cert, or `unix:/var/run/app.sock`.

4. **Verify it before reporting it.** One curl catches both proxy problems and
   the Vite host-check block, and is cheaper than letting the user find them in
   a browser:

   ```bash
   curl -sS -o /dev/null -w "%{http_code}" -m 15 https://mbp.tailnet-name.ts.net/
   ```

   Expect 200. (The very first request may be slow while the TLS cert is
   issued.) A 403-ish body mentioning "Blocked request" is the host check —
   see below.

5. **Report the URL — it is in the output already.** The command prints it,
   along with the exact teardown command:

   ```
   Available within your tailnet:

   https://mbp.tailnet-name.ts.net/
   |-- proxy http://127.0.0.1:3000

   Serve started and running in the background.
   To disable the proxy, run: tailscale serve --https=443 off
   ```

   Give the user the full URL, not instructions for assembling one. For a
   mapping made earlier, `tailscale serve status` lists them:

   ```
   https://mbp.tailnet-name.ts.net (tailnet only)
   |-- /  proxy http://127.0.0.1:3000
   ```

   It prints `No serve config` when nothing is served. `--json` is available on
   `status` if you would rather parse than scrape.

6. **Pass on the teardown line** in the same message:

   ```bash
   tailscale serve --https=443 off    # this one mapping
   tailscale serve reset              # every mapping on this machine
   ```

## Multi-service apps: one port is rarely enough

Serving the frontend is the finish line only for a static page. An SPA's
JavaScript makes **browser-side** calls to other services — an API, an auth
emulator, a CDN stub — and from the remote machine every `localhost` URL in
those calls points at the wrong computer. Symptoms arrive one layer at a time
(page loads → login fails → API calls fail), so find them all up front instead:

- **Grep the frontend's env files and config for `localhost:`** (`.env*`,
  `vite.config.*`, hardcoded URLs in `src/`). Each hit that the *browser* uses
  is a service that must also be served — or the feature breaks remotely.
  Server-to-server localhost calls are fine; only what the browser fetches
  matters.

- **Serve has exactly three HTTPS ports: 443, 8443, 10000.** That is the whole
  budget — e.g. frontend on 443, API on 8443, auth emulator on 10000
  (`tailscale serve --bg --https=8443 8080`). More than three services means
  path-mounting or rethinking.

- **Mixed content forces HTTPS for every one of them.** The page is now
  `https://`, so a browser call to `http://localhost:9099` is blocked even on
  the machine itself. Any URL the remote browser uses must go through a Serve
  HTTPS mapping.

- **Rewire the URLs.** Env-file entries (`BACKEND_URL` etc.) can simply point
  at the ts.net URL — the serving machine can reach its own ts.net name, so
  local browsing keeps working. For URLs hardcoded in client code, derive from
  the page instead of editing in a constant, so both origins work at once:

  ```js
  const apiUrl = window.location.hostname === "localhost"
    ? "http://localhost:9099"
    : `https://${window.location.hostname}:10000`;
  ```

- **CORS: the API sees a new origin.** If the backend allowlists origins, add
  `https://<machine>.<tailnet>.ts.net` (no port for 443) alongside the existing
  localhost entry. Verify with a preflight before blaming anything else:

  ```bash
  curl -s -D - -o /dev/null -X OPTIONS http://127.0.0.1:8080/some/path \
    -H "Origin: https://mbp.tailnet-name.ts.net" \
    -H "Access-Control-Request-Method: GET" | grep -i access-control
  ```

  No `access-control-allow-origin` in the response → the server does not have
  the origin yet.

- **The frozen-env restart trap.** A server launched as
  `dotenv -c -- node --watch server.js` snapshots its env at launch: editing
  `.env.local` does nothing, and `--watch` restarts inherit the stale env. Only
  restarting the whole script picks up the change — usually something the user
  must do in their own terminal. Compare the listening PID's start time
  (`ps -o pid,lstart -p <pid>`) against when the env was edited to prove this
  is the problem before hunting elsewhere.

## When it does not work

- **The tailnet does not have HTTPS Certificates enabled.** Serve needs them.
  The CLI does not just fail: it prints an admin-console URL and then **blocks,
  waiting for someone to flip the setting**, so a non-interactive run will hang
  there. If you see that prompt, stop the command, pass the URL to the user, and
  let them enable it before retrying — do not sit on a blocked command. The
  first request after enabling can be slow while the cert is issued.

- **The page loads but the dev server rejects the request.** Vite checks the
  `Host` header, which now arrives as `<machine>.<tailnet>.ts.net`:

  ```
  Blocked request. This host ("mbp.tailnet-name.ts.net") is not allowed.
  To allow this host, add "mbp.tailnet-name.ts.net" to `server.allowedHosts` in vite.config.js.
  ```

  A leading dot matches the domain and all of its subdomains, so one entry
  covers every machine in the tailnet and survives a rename:

  ```js
  // vite.config.js
  export default {
    server: { allowedHosts: ['.ts.net'] },
  }
  ```

  Use `preview.allowedHosts` for `vite preview`. Other frameworks with a host
  check (webpack-dev-server's `allowedHosts`, Next.js `allowedDevOrigins`) need
  the equivalent entry.

- **You need it working right now and HTTPS certs are not an option.** Forward
  from the client side instead — it needs nothing on the remote:

  ```bash
  ssh -L 3000:127.0.0.1:3000 <host>
  ```

  Then open `http://localhost:3000` locally. This is the fallback, not the
  default: it dies with the SSH session and serves only that one client.

- **Binding to `0.0.0.0` and using the raw Tailscale IP** (`http://100.x.y.z:3000`)
  also works, but means restarting the dev server with a different bind address.
  Prefer Serve.

- **An older Tailscale rejects the argument form above.** The positional target
  and `--bg` come from the current serve CLI; older releases used

  ```bash
  tailscale serve https:443 / http://127.0.0.1:3000
  ```

  Check `tailscale serve --help` rather than guessing which form applies.

## Constraints

- **Never run `tailscale funnel`** unless the user asks for public exposure in
  that turn. Funnel publishes to the open internet, and an unauthenticated dev
  server is exactly what should not be published. If they do ask, say plainly
  what it exposes before running it.
- Do not restart or reconfigure the user's dev server to make Serve work. Serve
  proxies to loopback; if something fails, fix the Serve side or report it.
- `tailscale serve reset` clears **all** mappings on the machine, including ones
  this skill did not create. Prefer the targeted `off` form unless the user asks
  to clear everything.
- Read-only on the repository: this skill runs commands, it does not edit files
  or commit. The one exception is the `allowedHosts` fix above, which is an edit
  to the user's project — propose it, do not slip it in.
