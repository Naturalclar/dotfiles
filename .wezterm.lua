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
end

config.color_scheme = "GitHub Dark"
config.default_cwd = "~"
enable_scroll_bar = true

config.launch_menu = launch_menu
config.keys = keys

return config