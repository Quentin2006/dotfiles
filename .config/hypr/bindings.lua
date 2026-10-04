-- Keep only your personal keybinding overrides here. Add new bindings or
-- unbind defaults before replacing them.

-- See current bindings and descriptions:
--   omarchy menu keybindings --print

-- To disable every Omarchy default binding, set this in
-- ~/.config/hypr/hyprland.lua before require("default.hypr.omarchy"), then add
-- only the bindings you want below:
--   omarchy_default_bindings = false

-- To disable all preinstalled app/webapp bindings, set:
--   omarchy_preinstalled_bindings = false

-- Add a new binding.
-- o.bind("SUPER + SHIFT + R", "SSH", "alacritty -e ssh your-server")

-- Change an existing binding by unbinding it first, then binding the key again.
-- This example changes SUPER+SPACE from the launcher to the Omarchy root menu.
-- hl.unbind("SUPER + SPACE")
-- o.bind("SUPER + SPACE", "Omarchy menu", "omarchy-menu toggle root")

-- Disable a default binding without replacing it.
-- hl.unbind("SUPER + SHIFT + B")

o.bind("SUPER + H", nil, "voxtype record toggle")
o.bind("SUPER + PERIOD", nil, "omarchy-shell shell toggle omarchy.emojis")
o.bind("SUPER + SHIFT + S", "Move window to scratchpad",
  hl.dsp.window.move({ workspace = "special:scratchpad", follow = true }))
o.bind("SUPER + M", "Spotify workspace", function()
  hl.dispatch(hl.dsp.workspace.toggle_special("spotify"))
  hl.dispatch(hl.dsp.exec_cmd(
    "hyprctl clients -j | jq -e '.[] | select(.class | test(\"spotify\"; \"i\"))' >/dev/null 2>&1 || " ..
    o.launch("spotify")))
end)
o.bind("SUPER + D", "Discord workspace", function()
  hl.dispatch(hl.dsp.workspace.toggle_special("discord"))
  hl.dispatch(hl.dsp.exec_cmd(
    "hyprctl clients -j | jq -e '.[] | select((.class | test(\"discord\"; \"i\")) or (.title | test(\"discord\"; \"i\")))' >/dev/null 2>&1 || " ..
    o.launch_webapp("https://discord.com/channels/@me")))
end)

-- Hold SUPER+X to drag a window with the mouse, SUPER+Z to resize it.
-- SUPER+X was previously "Universal cut"; unbound below so the new action wins.
hl.unbind("SUPER + X")
o.bind("SUPER + Z", "Drag window with mouse", hl.dsp.window.drag(), { mouse = true })
o.bind("SUPER + X", "Resize window with mouse", hl.dsp.window.resize(), { mouse = true })


-- Add any other personal Hyprland configuration below.
-- o.window("qemu", { workspace = "5" })
-- Spotify / Discord windows open on their named special workspaces
-- (toggled by SUPER+M and SUPER+D).
o.window({ class = "^[Ss]potify$" }, { workspace = "special:spotify" })
o.window({ class = "^chrome-discord" }, { workspace = "special:discord" })

