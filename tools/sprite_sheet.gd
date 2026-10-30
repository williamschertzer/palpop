extends SceneTree
## Renders every critter drawing and every orb into one picture, for checking art.
## godot --path . -s tools/sprite_sheet.gd -- out.png   (needs a display; use xvfb-run)

class Sheet:
	extends Node2D
	func _draw() -> void:
		draw_rect(Rect2(0, 0, 1600, 1200), Color("#6f9a5a"))
		var keys: Array = Art.SPRITE_INFO.keys()
		var cols := 10
		for i in keys.size():
			var x := 80.0 + (i % cols) * 150
			var y: float = 90.0 + floor(i / float(cols)) * 150
			draw_rect(Rect2(x - 70, y - 80, 140, 140), Color(1, 1, 1, .08))
			Art.put_mon(self, keys[i], x, y, 1.8, false, 0.4)
			draw_string(Pen.font_body, Vector2(x - 66, y + 54), Art.SPRITE_INFO[keys[i]].name, HORIZONTAL_ALIGNMENT_LEFT, 132, 13)
		var oy: float = 90.0 + ceil(keys.size() / float(cols)) * 150 + 10
		for i in Data.ORDER.size():
			var t: String = Data.ORDER[i]
			var x := 80.0 + i * 130
			Art.put_ball(self, t, x, oy, 0.0, 1.0 if t == "blimp" else 2.2)
			draw_string(Pen.font_body, Vector2(x - 55, oy + 70), Data.BALLS[t].name, HORIZONTAL_ALIGNMENT_LEFT, 120, 13)


func _initialize() -> void:
	Pen.font_display = load("res://fonts/PixelifySans.ttf")
	Pen.font_body = load("res://fonts/Nunito.ttf")
	var vp := SubViewport.new()
	vp.size = Vector2i(1560, 1220)
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(vp)
	vp.add_child(Sheet.new())
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	var args := OS.get_cmdline_user_args()
	vp.get_texture().get_image().save_png(args[0] if args.size() > 0 else "user://sheet.png")
	quit()
