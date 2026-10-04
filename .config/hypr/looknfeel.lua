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
hl.config({
  decoration = {
    blur = {
      enabled = true,
      size = 4,
      passes = 3,
    },
  },
})


hl.env("HYPRCURSOR_THEME", "Bibata-Modern-Classic")
hl.env("HYPRCURSOR_SIZE", "18")
hl.env("XCURSOR_THEME", "Bibata-Modern-Classic")
hl.env("XCURSOR_SIZE", "18")
