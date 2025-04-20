local wezterm = require("wezterm")
local config = wezterm.config_builder()
local launch_menu = {}
local keys = {}
local act = wezterm.action

function merge_tables(t1, t2)
  local merged = {}
  for _, v in ipairs(t1) do
    table.insert(merged, v)
  end
  for _, v in ipairs(t2) do
    table.insert(merged, v)
  end
  return merged
end

-- set LEADER key
config.leader = { key = "a", mods = "CTRL", timeout_milliseconds = 2000 }

-- Key Bindings
keys = {
  -- Split Horizontally with current pane
  { key = "%", mods = "LEADER|SHIFT", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
  -- Split Vertically with current pane
  { key = '"', mods = "LEADER|SHIFT", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
  -- Move to Tab
  { key = "1", mods = "LEADER", action = act.ActivateTab(0) },
  { key = "2", mods = "LEADER", action = act.ActivateTab(1) },
  { key = "3", mods = "LEADER", action = act.ActivateTab(2) },
  { key = "4", mods = "LEADER", action = act.ActivateTab(3) },
  { key = "5", mods = "LEADER", action = act.ActivateTab(4) },
  { key = "6", mods = "LEADER", action = act.ActivateTab(5) },
  { key = "7", mods = "LEADER", action = act.ActivateTab(6) },
  { key = "8", mods = "LEADER", action = act.ActivateTab(7) },
  { key = "9", mods = "LEADER", action = act.ActivateTab(8) },
  { key = "0", mods = "LEADER", action = act.ActivateTab(9) },
  -- Move Pane
  { key = "h", mods = "LEADER", action = act.ActivatePaneDirection("Left") },
  { key = "j", mods = "LEADER", action = act.ActivatePaneDirection("Down") },
  { key = "k", mods = "LEADER", action = act.ActivatePaneDirection("Down") },
  { key = "l", mods = "LEADER", action = act.ActivatePaneDirection("Right") },
  -- Move Tab
  { key = "h", mods = "LEADER|SHIFT", action = act.ActivateTabRelative(-1) },
  { key = "l", mods = "LEADER|SHIFT", action = act.ActivateTabRelative(1) },
  -- Create new tab
  { key = "c", mods = "LEADER", action = act.SpawnTab("CurrentPaneDomain") },
  -- Reload configuration
  { key = "r", mods = "LEADER", action = act.ReloadConfiguration },
}

-- If on Arch Linux
if wezterm.target_triple == "x86_64-unknown-linux-gnu" then
  config.background = {
    {
      source = {
        File = "/usr/share/backgrounds/default.png",
      },
      width = "100%",
      height = "Cover",
      repeat_y = "NoRepeat",
      repeat_x = "NoRepeat",
      hsb = { brightness = 0.05 },
    },
  }
end
-- If on macOS
if wezterm.target_triple == "aarch64-apple-darwin" then
  config.background = {
    {
      source = {
        File = os.getenv("HOME") .. "/Pictures/Wallpapers/laplus_darkness_wp.jpeg",
      },
      width = "100%",
      height = "Cover",
      repeat_y = "NoRepeat",
      repeat_x = "NoRepeat",
      hsb = { brightness = 0.015 },
    },
  }
end
-- If on Windows

if wezterm.target_triple == "x86_64-pc-windows-msvc" then
  local powershell = {
    label = "PowerShell",
    args = { "pwsh.exe", "-NoLogo" },
    domain = { DomainName = "local" },
  }
  -- Add PowerShell to the launch menu
  table.insert(launch_menu, powershell)
  local ubuntu = {
    label = "Ubuntu",
    args = { "/usr/bin/zsh" },
    domain = { DomainName = "WSL:Ubuntu" },
  }
  table.insert(launch_menu, ubuntu)
  -- Set WSL as default domain
  config.default_domain = "WSL:Ubuntu"
  config.default_prog = { "PowerShell" }
  -- Windows Specific Key Bindings
  keys = merge_tables(keys, {
    { key = "w", mods = "LEADER", action = act.SpawnCommandInNewTab(ubuntu) },
    { key = "e", mods = "LEADER", action = act.SpawnCommandInNewTab(powershell) },
  })
  -- set Background Image if image of path exists
  config.background = {
    -- This is the deepest/back-most layer. It will be rendered first
    {
      source = {
        -- TODO: use PATH instead of hardcode
        File = "C:\\Users\\jesse\\.background\\image.png",
      },
      -- The texture tiles vertically but not horizontally.
      -- When we repeat it, mirror it so that it appears "more seamless".
      -- An alternative to this is to set `width = "100%"` and have
      -- it stretch across the display
      width = "100%",
      height = "Cover",
      repeat_y = "NoRepeat",
      repeat_x = "NoRepeat",
      hsb = { brightness = 0.05 },
    },
  }
end

config.color_scheme = "GitHub Dark"
config.default_cwd = "~"
enable_scroll_bar = true

config.launch_menu = launch_menu
config.keys = keys

return config
