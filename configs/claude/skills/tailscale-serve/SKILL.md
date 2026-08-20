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

   The target can also be `localhost:3000`, a full URL with a path
   (`http://localhost:3000/foo`), `https+insecure://localhost:8443` for a dev
   server with a self-signed cert, or `unix:/var/run/app.sock`.

4. **Report the URL — it is in the output already.** The command prints it,
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

5. **Pass on the teardown line** in the same message:

   ```bash
   tailscale serve --https=443 off    # this one mapping
   tailscale serve reset              # every mapping on this machine
   ```

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
