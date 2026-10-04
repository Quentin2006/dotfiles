-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- List current monitors and supported resolutions with: hyprctl monitors all

local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1.25

hl.env("GDK_SCALE", tostring(omarchy_gdk_scale))

hl.monitor({ output = "DP-1", mode = "highres@highrr", position = "auto", scale = 1, vrr = 1, bitdepth = 10, supports_wide_color = 1, supports_hdr = 1 })
hl.monitor({ output = "eDP-1", mode = "highres@highrr", position = "auto", scale = 2, vrr = 1, bitdepth = 10, supports_wide_color = 1, supports_hdr = 1 })
