-- App-specific touchpad scroll speeds.
-- o.window("(Alacritty|kitty|foot)", { scroll_touchpad = 1.5 })All VoiceThread
-- o.window("com.mitchellh.ghostty", { scroll_touchpad = 0.2 })

-- Enable touchpad gestures for changing workspaces.
-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/
hl.gesture({ fingers = 4, direction = "horizontal", action = "workspace" })

-- Enable touchpad gestures for moving focus (helpful on scrolling layout).
hl.gesture({ fingers = 3, direction = "left", action = function() hl.dispatch(hl.dsp.focus({ direction = "left" })) end })
hl.gesture({ fingers = 3, direction = "right", action = function() hl.dispatch(hl.dsp.focus({ direction = "right" })) end })
hl.gesture({ fingers = 3, direction = "up", action = function() hl.dispatch(hl.dsp.focus({ direction = "up" })) end })
hl.gesture({ fingers = 3, direction = "down", action = function() hl.dispatch(hl.dsp.focus({ direction = "down" })) end })

-- Two-finger pinch resizes the focused tile, mirroring the SUPER + LEFT/RIGHT
-- resize binds: pinch in (fingers together) expands, pinch out (fingers apart)
-- shrinks. Same dispatcher calls, so it behaves exactly like those keys.
--
-- NOTE: Hyprland's pinch direction names are inverted relative to the physical
-- motion -- "pinchout" is what fires when the fingers move toward each other.
-- hl.gesture({
--   fingers = 2,
--   direction = "pinchout", -- fingers together
--   action = function() hl.dispatch(hl.dsp.window.resize({ x = -500, y = 0, relative = true })) end
-- })
--
-- hl.gesture({
--   fingers = 2,
--   direction = "pinchin", -- fingers apart
--   action = function() hl.dispatch(hl.dsp.window.resize({ x = 500, y = 0, relative = true })) end
-- })
