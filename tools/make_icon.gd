extends SceneTree
## Draws the app icon (Zapkit in front of the sanctuary sky) into icon.png.
## godot --path . -s tools/make_icon.gd   (needs a display; use xvfb-run)

class Icon:
	extends Node2D
	func _draw() -> void:
		var c := Vector2(256, 256)
		var pts := PackedVector2Array()
		for i in 64:
			var a := TAU * i / 64.0
			pts.append(c + Vector2(cos(a), sin(a)) * 246)
		draw_colored_polygon(pts, Color("#1f2a5a"))
		# sky fading into a meadow
		for i in 40:
			var r := 236.0 - i * 5.5
			draw_circle(c + Vector2(0, -60 + i * 2.2), r, Color("#2f4f9a").lerp(Color("#8fd0ff"), i / 40.0))
		draw_rect(Rect2(10, 330, 492, 200), Color("#5fae4a"))
		# record the drawings at full size so curves stay smooth
		var pen := Pen.new()
		pen.clear()
		for b in [["red", 400.0, 360.0, .4, 3.4], ["blue", 112.0, 380.0, -.3, 3.0]]:
			pen.save(); pen.translate(b[1], b[2]); pen.rotate(b[3]); pen.scale(b[4], b[4])
			Art.draw_ball(pen, b[0])
			pen.restore()
		pen.save(); pen.translate(256, 300); pen.scale(7.2, 7.2)
		Art.draw_mon(pen, "zapkit", 0.3)
		pen.restore()
		Pen.draw_baked(self, Pen.bake(pen.cmds))
		draw_arc(c, 246, 0, TAU, 128, Color("#1b1b22"), 18, true)


func _initialize() -> void:
	var vp := SubViewport.new()
	vp.size = Vector2i(512, 512)
	vp.transparent_bg = true
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(vp)
	vp.add_child(Icon.new())
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	var img := vp.get_texture().get_image()
	# clear the corners outside the badge
	for y in 512:
		for x in 512:
			if Vector2(x - 255.5, y - 255.5).length() > 255:
				img.set_pixel(x, y, Color(0, 0, 0, 0))
	img.save_png("res://icon.png")
	quit()
