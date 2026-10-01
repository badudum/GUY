-- GUY for Hyprland's Lua config (0.55+). Load it from hyprland.lua with:
--   dofile(os.getenv("HOME") .. "/.config/hypr/guy.lua")

-- the liquid-glass island: GUY animates itself, so Hyprland only blurs behind the glass
hl.layer_rule({
	name = "user_guy_blur",
	match = { namespace = "^(guy)$" },
	blur = true,
	ignore_alpha = 0.5,
	no_anim = true,
})
-- the invisible click-catcher behind Ask GUY: no blur, no animation
hl.layer_rule({
	name = "user_guy_catcher",
	match = { namespace = "^(guy-catcher)$" },
	no_anim = true,
})

hl.bind("ALT + SPACE", hl.dsp.exec_cmd(os.getenv("HOME") .. "/.local/bin/guy --ask"), {
	description = "Ask GUY",
})
hl.bind("SUPER + SPACE", hl.dsp.exec_cmd(os.getenv("HOME") .. "/.local/bin/guy --listen"), {
	description = "Talk to GUY",
})

-- start GUY (and its voice) as systemd user services, so `systemctl --user restart guy` works
hl.on("hyprland.start", function()
	hl.exec_cmd("systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP HYPRLAND_INSTANCE_SIGNATURE"
		.. " && systemctl --user start guy.service; systemctl --user start guy-voice.service")
end)
