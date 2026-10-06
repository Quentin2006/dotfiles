-- Look & feel: macOS-inspired -- rounded squircle corners, soft shadows,
-- translucent blur, and quick, settled motion.
--
-- Only geometry and motion live here; window/border colors still come from the
-- active Omarchy theme, so `omarchy theme set ...` keeps working.

-- Hide the cursor while typing, then fade it back in.
hl.config({ cursor = { inactive_timeout = 1 } })

-- https://wiki.hypr.land/Configuring/Basics/Variables/#general
hl.config({
  general = {
    border_size = 1,
    resize_on_border = true,

    layout = "dwindle",
  },
})

-- https://wiki.hypr.land/Configuring/Basics/Variables/#decoration
-- Rounded, translucent windows with the same frosted-glass feel as the desktop
-- widget cards: a 16px radius (matching `cardRadius`), a soft shadow for depth,
-- and a little transparency so the blur behind reads through.
hl.config({
  decoration = {
    rounding = 16,
    active_opacity = 1.0,
    inactive_opacity = 0.82,
    shadow = {
      enabled = true,
      range = 20,
      render_power = 3,
      color = "rgba(00000055)",
    },
    blur = {
      enabled = true,
      size = 4,
      passes = 3,
      new_optimizations = true,
      ignore_opacity = true,
      popups = true,
    },
  },
})

-- Desktop widget cards (the omarchy-desktop-widgets layer surface) blur the
-- wallpaper behind themselves, so their translucent material reads as frosted
-- glass rather than a flat panel. `ignore_alpha` keeps the transparent rounded
-- corners out of the blur, which would otherwise blur as a rectangle.
hl.layer_rule({
  match = { namespace = "omarchy-desktop-widgets" },
  blur = true,
  ignore_alpha = 0.1,
})


hl.env("HYPRCURSOR_THEME", "Bibata-Modern-Classic")
hl.env("HYPRCURSOR_SIZE", "18")
hl.env("XCURSOR_THEME", "Bibata-Modern-Classic")
hl.env("XCURSOR_SIZE", "18")
