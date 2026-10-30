class_name Mons
extends RefCounted
## Hand-drawn critters. Every critter is an original design; each family is one
## function whose `k` argument picks the growth stage (0 = base, up to 3 =
## Ascended). Parts are shaded with Pen.sh (fill, shadow, rim light, outline).
## Sprites mostly face the viewer, stand with their feet around y = 18 and fit
## roughly in ±30 × -40..20.

const OUT := Pen.OUT
const CREAM := "#f6e3b4"
const INK := "#1b1b22"

const DRAW := {
	"zapkit": ["zapkit", 0], "stormstoat": ["zapkit", 1], "tempeststoat": ["zapkit", 3], "nest": ["nest", 0],
	"cindermole": ["cindermole", 0], "kilnmole": ["cindermole", 1], "magmoloss": ["cindermole", 2], "ascmagmoloss": ["cindermole", 3],
	"lanternwisp": ["lantern", 0], "lanternshade": ["lantern", 1], "lanternlord": ["lantern", 2], "lanternwraith": ["lantern", 3],
	"spoutling": ["spout", 0], "spoutseal": ["spout", 1], "geyserwal": ["spout", 2], "ascgeyserwal": ["spout", 3],
	"thornhog": ["thornhog", 0], "bramblehog": ["thornhog", 1], "grovehog": ["thornhog", 2], "ascgrovehog": ["thornhog", 3],
	"coinpie": ["coinpie", 0], "goldpie": ["coinpie", 1], "wobblob": ["wobblob", 0],
	"astralion": ["astralion", 0], "armorastralion": ["astralion", 2], "novaastralion": ["astralion", 3],
	"puddlesnail": ["snail", 0], "krakenshell": ["snail", 1], "asckrakenshell": ["snail", 3],
	"galefinch": ["gale", 0], "galehawk": ["gale", 1], "galeroc": ["gale", 2], "ascgaleroc": ["gale", 3],
	"pebbit": ["dillo", 0], "bouldillo": ["dillo", 1], "mountadillo": ["dillo", 2],
	"knuckaroo": ["roo", 0], "brawlaroo": ["roo", 1], "champaroo": ["roo", 2], "titanchamparoo": ["roo", 3],
	"hootling": ["owl", 0], "hootsage": ["owl", 1], "hootarch": ["owl", 2], "elderhootarch": ["owl", 3],
	"frostray": ["ray", 0], "glacierfrostray": ["ray", 3], "slumbear": ["bear", 0], "mountainslumbear": ["bear", 3],
	"wyrmlet": ["wyrm", 0], "cloudwyrm": ["wyrm", 1], "skywyrm": ["wyrm", 2],
	"prismkit": ["fox", 0], "tidefox": ["fox", 1], "sparkfox": ["fox", 2], "blazefox": ["fox", 3],
	"mimoth": ["mimoth", 0], "bunbalm": ["bunny", 0], "grandbunbalm": ["bunny", 1],
}


static func draw(c: Pen, sp: String, t: float, opt: Dictionary) -> void:
	var d: Array = DRAW[sp]
	Callable(Mons, d[0]).call(c, t, d[1], opt)


# ---------- helpers ----------
## Glossy round eye with one catchlight.
static func eye(c: Pen, x: float, y: float, rx: float, ry: float, col := INK) -> void:
	c.ell(x, y, rx, ry); c.fill(col)
	c.ell(x + rx * .3, y - ry * .38, rx * .42, ry * .36); c.fill("#fff")
	c.ell(x - rx * .3, y + ry * .45, rx * .2, ry * .16); c.fill(Color(1, 1, 1, .55))


## A closed, happy or sleepy eye: a little arc.
static func eye_shut(c: Pen, x: float, y: float, w: float, up := true, col := INK) -> void:
	c.begin(); c.move_to(x - w, y); c.quad_to(x, y + (-w * .9 if up else w * .9), x + w, y); c.stroke(col, 1.3, true)


## A glowing eye with no pupil.
static func eye_glow(c: Pen, x: float, y: float, rx: float, ry: float, col) -> void:
	c.glow(x, y, rx * 3, Color(col))
	c.ell(x, y, rx, ry); c.fill(col)
	c.ell(x - rx * .25, y - ry * .3, rx * .4, ry * .35); c.fill(Color(1, 1, 1, .8))


## A limb or tail drawn as a thick outlined stroke along the current path.
static func limb(c: Pen, col, w: float) -> void:
	c.stroke(OUT, w + 2.6, true); c.stroke(col, w, true)


static func blush(c: Pen, x: float, y: float, r: float, col) -> void:
	c.ell(x, y, r, r * .7); c.fill(Color(col, .55))


static func flame(c: Pen, x: float, y: float, s: float, t: float, blue := false) -> void:
	var f := 1 + .16 * sin(t * 19 + x) + .07 * sin(t * 31)
	var lean := sin(t * 11 + y) * 1.5 * s
	var cols := ["#3db5ff", "#9fe2ff", "#ffffff"] if blue else ["#ff6a1a", "#ffc23a", "#fff6b8"]
	c.glow(x, y - 3 * s, 13 * s, Color(cols[0]))
	for i in 3:
		var k: float = [1.0, .68, .38][i]
		c.begin(); c.move_to(x + lean * k, y - 13 * s * f * k)
		c.bez_to(x + 8 * s * k, y - 4 * s * k, x + 7 * s * k, y + 6 * s * k, x, y + 6 * s * k)
		c.bez_to(x - 7 * s * k, y + 6 * s * k, x - 8 * s * k, y - 4 * s * k, x + lean * k, y - 13 * s * f * k)
		if i == 0:
			c.fs(cols[i], Color(OUT, .7), 1)
		else:
			c.fill(cols[i])


static func star(c: Pen, x: float, y: float, r: float, col) -> void:
	c.begin()
	for i in 10:
		var a := -PI / 2 + i * PI / 5
		var rr := r * .45 if i % 2 else r
		c.line_to(x + cos(a) * rr, y + sin(a) * rr)
	c.close()
	c.fs(col, Color(OUT, .5), .6)


static func bolt(c: Pen, pts: Array, col, base := "") -> void:
	c.poly(pts); c.sh(col)
	if base != "":
		c.save(); c.poly(pts); c.clip()
		c.ell(pts[0][0], pts[0][1], 5, 5); c.fill(base)
		c.restore()
		c.poly(pts); c.stroke(OUT, 1.4)


## Leaf shape pointing along `rot` from (x, y).
static func leaf(c: Pen, x: float, y: float, len: float, w: float, rot: float, col, vein := true) -> void:
	c.save(); c.translate(x, y); c.rotate(rot)
	c.begin(); c.move_to(0, 0); c.quad_to(w, -len * .45, 0, -len); c.quad_to(-w, -len * .45, 0, 0); c.close(); c.sh(col)
	if vein:
		c.begin(); c.move_to(0, -1); c.line_to(0, -len * .8); c.stroke(Color(OUT, .35), .8)
	c.restore()


## Soft cloud puff made of overlapping circles.
static func puff(c: Pen, x: float, y: float, r: float, col, line = OUT) -> void:
	for p in [[-.8, .2, .6], [0.0, -.25, .8], [.8, .15, .62], [0.0, .35, .7]]:
		c.ell(x + p[0] * r, y + p[1] * r, p[2] * r, p[2] * r); c.fill(col)
	if line != null:
		for p in [[-.8, .2, .6], [0.0, -.25, .8], [.8, .15, .62]]:
			c.begin(); c.arc(x + p[0] * r, y + p[1] * r, p[2] * r, PI * .95, PI * 2.05); c.stroke(Color(line, .6), 1)


## Two little feet.
static func feet(c: Pen, w: float, rx: float, col, line = OUT) -> void:
	c.ell(-w, 17.6, rx, rx * .55); c.sh(col, line, 1.2)
	c.ell(w, 17.6, rx, rx * .55); c.sh(col, line, 1.2)


static func _spiral(c: Pen, x: float, y: float, n: int, r0: float, dr: float, step: float, ph: float) -> void:
	c.begin()
	for i in n:
		var a := i * step + ph
		var r := r0 + i * dr
		c.line_to(x + cos(a) * r, y + sin(a) * r)


# ---------- Zapkit line: blue storm ferrets with a copper coil tail ----------
static func zapkit(c: Pen, t: float, k: int, _o := {}) -> void:
	var big := 1.0 + k * .1
	var body := "#4f86e0" if k == 0 else "#3b66c8"
	var belly := "#eef4ff"
	var sw := sin(t * 3) * 1.2
	c.save(); c.scale(big, big)
	if k >= 3:
		c.glow(0, -6, 30, Color("#9fd4ff", .5))
	# long tail sweeping up behind, ending in a copper coil
	c.begin(); c.move_to(-4, 12); c.bez_to(-22, 16, -26, 0, -20 + sw, -14); limb(c, body, 5.5)
	_spiral(c, -20 + sw, -18, 22, 1.2, .2, .62, t * 4); c.stroke("#7a3d16", 2.6, true)
	_spiral(c, -20 + sw, -18, 22, 1.2, .2, .62, t * 4); c.stroke("#e0904a", 1.4, true)
	c.glow(-20 + sw, -18, 7, Color("#bfe6ff"))
	# body
	feet(c, 6, 4.4, body)
	c.begin(); c.move_to(-9, 0); c.bez_to(-12, 9, -9, 17.5, 0, 17.5); c.bez_to(9, 17.5, 12, 9, 9, 0); c.close(); c.sh(body)
	c.begin(); c.move_to(-5, 3); c.bez_to(-6, 10, -4, 15.5, 0, 15.5); c.bez_to(4, 15.5, 6, 10, 5, 3); c.close(); c.fill(belly)
	if k >= 1:
		bolt(c, [[-2, 5], [2, 4], [-.5, 9], [2.5, 9], [-2.5, 15], [-.5, 10], [-3, 10]], "#ffe36a")
	for s: int in [-1, 1]:
		c.ell(s * 7, 7, 2.4, 3.6, s * .4); c.sh(body)
	# head: little round ears, white mask stripe
	for s: int in [-1, 1]:
		c.ell(s * 8.5, -16, 3.6, 3.8); c.sh(body)
		c.ell(s * 8.5, -15.6, 1.8, 2); c.fill("#ffb6c8")
	c.ell(0, -7, 11.5, 9); c.sh(body)
	c.ell(0, -3.5, 7, 4.8); c.fill(belly)
	c.begin(); c.move_to(-10, -9); c.quad_to(0, -14, 10, -9); c.quad_to(0, -11, -10, -9); c.fill(belly)
	if k >= 3:
		eye_glow(c, -4.6, -8.5, 2, 2.2, "#dff4ff")
		eye_glow(c, 4.6, -8.5, 2, 2.2, "#dff4ff")
	else:
		eye(c, -4.6, -8.5, 2.1, 2.5); eye(c, 4.6, -8.5, 2.1, 2.5)
	c.ell(0, -4.6, 1.5, 1); c.fill(OUT)
	c.begin(); c.move_to(-2.2, -2.6); c.quad_to(0, -1, 2.2, -2.6); c.stroke(OUT, 1)
	blush(c, -8, -4, 2, "#8fd0ff"); blush(c, 8, -4, 2, "#8fd0ff")
	if k >= 1:
		# static tufts on the cheeks
		for s: int in [-1, 1]:
			c.poly([[s * 11, -8], [s * 15, -6], [s * 11.5, -5], [s * 14, -2], [s * 10, -3]]); c.sh(body)
	if k >= 3:
		# storm-cloud mane with sparks
		for i in 5:
			var a := PI * (1.05 + i * .225)
			puff(c, cos(a) * 15, -8 + sin(a) * 12, 4.6, "#e8eef8", "#7a88a8")
		for i in 3:
			var a := t * 5 + i * TAU / 3
			var bx := cos(a) * 18
			var by := -10 + sin(a) * 14
			bolt(c, [[bx, by], [bx + 3, by + 2], [bx + 1, by + 3], [bx + 4, by + 6], [bx - 1, by + 2.4], [bx + 1, by + 1.6]], "#fff07a")
	c.restore()


# ---------- the Nest Egg the critters protect ----------
static func nest(c: Pen, t: float, _k: int, _o := {}) -> void:
	c.glow(0, -4, 26, Color("#fff4c0", .45 + .15 * sin(t * 2)))
	c.save(); c.rotate(sin(t * 1.5) * .04)
	c.begin(); c.move_to(0, -24); c.bez_to(10, -24, 14, -6, 13, 4); c.bez_to(12, 12, 6, 14, 0, 14); c.bez_to(-6, 14, -12, 12, -13, 4); c.bez_to(-14, -6, -10, -24, 0, -24); c.close()
	c.sh("#fbf1d8", "#6a4a2a", 1.4)
	for sp in [[-5, -12, 2.6], [4, -16, 1.8], [6, -5, 2.8], [-6, -1, 1.6], [1, 4, 2.2], [-2, -19, 1.2]]:
		c.ell(sp[0], sp[1], sp[2], sp[2] * .8); c.fill("#7cc4a8")
	c.ell(-5, -16, 2.6, 4, -.3); c.fill(Color(1, 1, 1, .5))
	c.restore()
	# woven nest
	c.begin(); c.move_to(-20, 4); c.bez_to(-18, 18, 18, 18, 20, 4); c.bez_to(10, 9, -10, 9, -20, 4); c.close(); c.sh("#a5743e", "#4a3018", 1.4)
	c.begin()
	for i in 7:
		var x := -16 + i * 5.4
		c.move_to(x - 3, 6 + absf(x) * .05); c.quad_to(x, 12, x + 4, 14 - absf(x) * .2)
	c.stroke("#6a4622", 1.1)
	for s: int in [-1, 1]:
		c.begin(); c.move_to(s * 18, 3); c.line_to(s * 23, 0); c.stroke("#6a4622", 1.4, true)
		leaf(c, s * 17, 6, 8, 3.4, s * 1.2, "#6fbf5a")


# ---------- Cindermole line: moles with glowing coal claws ----------
static func cindermole(c: Pen, t: float, k: int, _o := {}) -> void:
	var big := 1.0 + k * .09
	var fur := "#5a3b2e" if k < 2 else "#3e2a24"
	var blue := k >= 3
	c.save(); c.scale(big, big)
	# back vents with flames
	if k == 0:
		flame(c, 0, -17, .55, t, blue)
	else:
		for s: int in [-1, 1]:
			c.begin(); c.round_rect(s * 7 - 3, -22, 6, 9, 2); c.sh("#5e5650")
			flame(c, s * 7, -24, .5 + k * .1, t + s, blue)
	if k >= 2:
		flame(c, 0, -27, .8, t + 2, blue)
	feet(c, 7, 4.6, "#f0a8a0")
	# round body
	c.begin(); c.move_to(0, -18); c.bez_to(13, -18, 16, -4, 16, 4); c.bez_to(16, 14, 9, 18, 0, 18); c.bez_to(-9, 18, -16, 14, -16, 4); c.bez_to(-16, -4, -13, -18, 0, -18); c.close(); c.sh(fur)
	# lava cracks
	var lava := "#7fd8ff" if blue else "#ffb03a"
	c.begin(); c.move_to(-10, -12); c.line_to(-7, -9); c.line_to(-9, -5); c.move_to(9, -13); c.line_to(7, -9); c.line_to(10, -6)
	if k >= 2:
		c.move_to(-13, 2); c.line_to(-10, 5); c.move_to(13, 1); c.line_to(10, 5)
	c.stroke(lava, 1.4, true)
	c.ell(0, 5, 9.5, 10); c.fill("#7a5242")
	if k >= 2:
		# magma armour plates on the belly
		for i in 3:
			c.begin(); c.round_rect(-6, -1 + i * 5, 12, 4, 1.5); c.sh("#5a4038", null)
	# face: tiny squinting eyes, big pink nose
	eye_shut(c, -5, -8, 2.2, false, "#f4e0d0")
	eye_shut(c, 5, -8, 2.2, false, "#f4e0d0")
	c.ell(0, -3.2, 3.6, 2.8); c.sh("#f28a9a")
	c.begin(); c.move_to(-2, .5); c.quad_to(0, 2, 2, .5); c.stroke("#f4e0d0", 1)
	# shovel claws glowing at the tips
	for s: int in [-1, 1]:
		c.save(); c.translate(s * 14, 6); c.rotate(s * -.3)
		c.ell(0, 0, 5.4, 4.2); c.sh("#f0a8a0")
		for i in 3:
			c.begin(); c.move_to(s * 2 + (i - 1) * 2.6, 2.6); c.line_to(s * 3 + (i - 1) * 3, 6.4); c.stroke(OUT, 2.8, true)
			c.begin(); c.move_to(s * 2 + (i - 1) * 2.6, 2.6); c.line_to(s * 3 + (i - 1) * 3, 6.4); c.stroke(lava, 1.4, true)
		c.restore()
	if k >= 2:
		# crown of horns
		for s: int in [-1, 0, 1]:
			c.poly([[s * 6 - 2.4, -16.5], [s * 6 + 2.4, -16.5], [s * 7, -22 - (2 if s == 0 else 0)]]); c.sh("#c8b8a8")
	c.restore()


# ---------- Lanternwisp line: floating paper-lantern spirits ----------
static func _lantern_shape(c: Pen) -> void:
	c.begin(); c.move_to(-6, -15); c.bez_to(-15, -13, -15, 7, -6, 9); c.line_to(6, 9); c.bez_to(15, 7, 15, -13, 6, -15); c.close()


static func lantern(c: Pen, t: float, k: int, _o := {}) -> void:
	var big := 1.0 + k * .08
	var paper: String = ["#f0803c", "#9a6ad8", "#6a44b8", "#2e2448"][k]
	var glowc: String = ["#ffd27a", "#f4c8ff", "#ffe0a0", "#7fd8ff"][k]
	c.translate(0, sin(t * 2.2) * 2 - 4)
	c.save(); c.scale(big, big)
	c.glow(0, -2, 22, Color(glowc, .5))
	# wispy trail underneath
	for i in 3:
		var x := (i - 1) * 5.0
		c.begin(); c.move_to(x, 10); c.bez_to(x + 3 * sin(t * 3 + i), 15, x - 3 * sin(t * 3 + i), 18, x + sin(t * 4 + i) * 2, 22); c.stroke(Color(glowc, .7), 2.6 - absf(i - 1), true)
	if k >= 1:
		# shadowy arms
		for s: int in [-1, 1]:
			c.begin(); c.move_to(s * 10, -2); c.bez_to(s * 17, -6 + sin(t * 3) * 2, s * 19, 2, s * 16 + sin(t * 2 + s) * 2, 6); limb(c, "#3a2a5a", 3)
	# cap and base
	c.begin(); c.round_rect(-6, -19, 12, 4, 1.5); c.sh("#3a2a24")
	c.begin(); c.round_rect(-6, 9, 12, 4, 1.5); c.sh("#3a2a24")
	c.begin(); c.move_to(0, -19); c.line_to(0, -24); c.stroke("#3a2a24", 1.4)
	# paper body lit from inside
	_lantern_shape(c); c.fill(paper)
	_lantern_shape(c); c.fill_fan(0, -2, 14, Color(glowc, .85), Color(glowc, 0))
	_lantern_shape(c); c.stroke(OUT, 1.4)
	c.begin()
	for y in [-10.0, -5.0, 0.0, 5.0]:
		var w := 12.5 - absf(y + 3) * .25
		c.move_to(-w, y); c.quad_to(0, y + 1.4, w, y)
	c.stroke(Color(OUT, .35), .8)
	# spooky face glowing through the paper
	var ec := "#2a1030" if k < 3 else "#e8fbff"
	for s: int in [-1, 1]:
		c.begin(); c.move_to(s * 1.6, -6); c.quad_to(s * 7, -9, s * 6.4, -3); c.quad_to(s * 3.6, -2.4, s * 1.6, -6); c.fill(ec)
	c.begin(); c.move_to(-4.5, 1); c.quad_to(0, 6, 4.5, 1); c.quad_to(0, 3, -4.5, 1); c.fill(ec)
	if k >= 2:
		# little crown of flames on top
		for s: int in [-1, 0, 1]:
			flame(c, s * 4, -21 - (2 if s == 0 else 0), .32, t + s, k >= 3)
	c.restore()


# ---------- Spoutling line: seal pups that grow into geyser walruses ----------
static func spout(c: Pen, t: float, k: int, o := {}) -> void:
	var big := 1.0 + k * .1
	var skin: String = ["#a8cfe6", "#86b6d8", "#7c8fb0", "#6a7ea8"][k]
	var belly := "#eef6fb"
	c.save(); c.scale(big, big)
	# water spout from the blowhole
	var jets := 3 if k >= 3 else 1
	for j in jets:
		var x := (j - (jets - 1) / 2.0) * 6
		var h := 12 + 3 * sin(t * 6 + j)
		c.begin(); c.move_to(x - 1.6, -15); c.quad_to(x - 2, -15 - h, x, -17 - h); c.quad_to(x + 2, -15 - h, x + 1.6, -15); c.close(); c.fs("#7cc8ff", "#2a6aa8", 1)
		for s: int in [-1, 1]:
			c.ell(x + s * 4, -16 - h + 2, 2.2, 1.8); c.fs("#bfe6ff", "#2a6aa8", .8)
	# tail flippers
	c.begin(); c.move_to(-4, 16); c.quad_to(-14, 22, -16, 14); c.quad_to(-10, 15, -4, 12); c.close(); c.sh(skin)
	c.begin(); c.move_to(4, 16); c.quad_to(14, 22, 16, 14); c.quad_to(10, 15, 4, 12); c.close(); c.sh(skin)
	# teardrop body
	c.begin(); c.move_to(0, -17); c.bez_to(12, -17, 15, -2, 14, 8); c.bez_to(13, 16, 7, 18, 0, 18); c.bez_to(-7, 18, -13, 16, -14, 8); c.bez_to(-15, -2, -12, -17, 0, -17); c.close(); c.sh(skin)
	c.ell(0, 7, 8.5, 9.5); c.fill(belly)
	# front flippers
	for s: int in [-1, 1]:
		c.save(); c.translate(s * 13, 6); c.rotate(s * .7)
		c.ell(0, 0, 3.2, 6.5); c.sh(skin)
		c.restore()
	c.ell(0, -15.5, 1.4, .8); c.fill("#2a4a6a")
	# face
	eye(c, -5, -7, 2.2, 2.6); eye(c, 5, -7, 2.2, 2.6)
	for s: int in [-1, 1]:
		c.ell(s * 2.6, -1.8, 3, 2.4); c.sh(belly, Color(OUT, .5), 1)
		c.begin(); c.move_to(s * 4, -2); c.line_to(s * 10, -3.6); c.move_to(s * 4, -1); c.line_to(s * 10, -.4); c.stroke(Color(OUT, .6), .7)
	c.ell(0, -3.6, 1.6, 1.1); c.fill(OUT)
	if k >= 2:
		# geyser tusks
		for s: int in [-1, 1]:
			c.begin(); c.move_to(s * 2, 0); c.quad_to(s * 3.4, 8, s * 1.6, 11); c.quad_to(s * 1, 6, s * .4, .4); c.close()
			c.sh("#fffaf0" if k < 3 else "#cff4ff")
			if k >= 3:
				c.glow(s * 1.6, 11, 5, Color("#7fd8ff"))
	blush(c, -8, -3.5, 2, "#ff9ab0"); blush(c, 8, -3.5, 2, "#ff9ab0")
	if o.get("shades", false):
		c.begin(); c.round_rect(-9, -9.6, 7.6, 4.4, 1.6); c.round_rect(1.4, -9.6, 7.6, 4.4, 1.6); c.fill("#16161a")
		c.begin(); c.move_to(-1.4, -8); c.line_to(1.4, -8); c.stroke("#16161a", 1.2)
		c.begin(); c.move_to(-7.5, -8.6); c.line_to(-5, -8.6); c.stroke(Color(1, 1, 1, .6), .8)
	c.restore()


# ---------- Thornhog line: hedgehogs with leaf quills ----------
static func thornhog(c: Pen, t: float, k: int, _o := {}) -> void:
	var big := 1.0 + k * .1
	var lc: String = ["#6cc04a", "#4fa83a", "#3d8f34", "#e8c03a"][k]
	var lc2: String = ["#9be06a", "#78c850", "#5aae44", "#fff07a"][k]
	c.save(); c.scale(big, big)
	if k >= 3:
		c.glow(0, -8, 28, Color("#fff4a0", .45))
	# fan of leaf quills behind the head
	var n := 7 + k * 2
	for i in n:
		var a := (i - (n - 1) / 2.0) * (2.8 / n)
		var sway := sin(t * 2 + i) * .04
		leaf(c, sin(a) * 6, -2 - cos(a) * 3, 14 + k * 2 + (i % 2) * 3, 4.4, a + sway, lc if i % 2 else lc2)
	if k >= 2:
		# a little sapling growing on its back
		c.begin(); c.move_to(0, -12); c.line_to(0, -26); c.stroke("#7a5030", 2.4, true)
		for s: int in [-1, 1]:
			leaf(c, 0, -22, 9, 4, s * 1.0, lc2)
		leaf(c, 0, -26, 8, 3.6, 0.0, lc)
	feet(c, 6.5, 4.2, "#c08860")
	# round tan body and face
	c.ell(0, 6, 12, 12); c.sh("#d8a878")
	c.ell(0, 9, 7.5, 7.5); c.fill("#f2d8b4")
	c.begin(); c.move_to(-11, -6); c.bez_to(-12, -16, 12, -16, 11, -6); c.bez_to(11, 2, 5, 4, 0, 4); c.bez_to(-5, 4, -11, 2, -11, -6); c.close(); c.sh("#d8a878")
	# pointy snout
	c.begin(); c.move_to(-4, -4); c.quad_to(0, 3, 4, -4); c.close(); c.fill("#f2d8b4")
	c.ell(0, -.6, 1.8, 1.4); c.fill(OUT)
	eye(c, -4.6, -7, 2, 2.4); eye(c, 4.6, -7, 2, 2.4)
	if k >= 1:
		# determined brows
		c.begin(); c.move_to(-7, -10.5); c.line_to(-3, -9.4); c.move_to(7, -10.5); c.line_to(3, -9.4); c.stroke(OUT, 1.1, true)
	blush(c, -7.5, -3.5, 1.8, "#ff8a7a"); blush(c, 7.5, -3.5, 1.8, "#ff8a7a")
	for s: int in [-1, 1]:
		c.ell(s * 10, 8, 2.6, 3.6, s * .5); c.sh("#c08860")
	c.restore()


# ---------- Coinpie line: coin-hoarding magpies ----------
static func coinpie(c: Pen, t: float, k: int, o := {}) -> void:
	var big := 1.0 + k * .12
	var black := "#26262e" if k == 0 else "#3a3020"
	var sheen := "#4a7ad8" if k == 0 else "#e0b030"
	c.save(); c.scale(big, big)
	# long tail
	var sw := sin(t * 2) * .06
	for i in 3:
		c.save(); c.translate(-5, 11); c.rotate(.75 + (i - 1) * .32 + sw)
		c.begin(); c.move_to(-2.4, 0); c.quad_to(-3, 8, 0, 12); c.quad_to(3, 8, 2.4, 0); c.close(); c.sh(black)
		c.begin(); c.move_to(0, 2); c.line_to(0, 10); c.stroke(sheen, 1)
		c.restore()
	c.begin(); c.move_to(-2, 15); c.line_to(-2, 18.5); c.move_to(3, 15); c.line_to(3, 18.5); c.stroke("#3a3a40", 1.6)
	c.begin(); c.move_to(-4.5, 18.5); c.line_to(0, 18.5); c.move_to(1, 18.5); c.line_to(5.5, 18.5); c.stroke("#3a3a40", 1.4, true)
	# body: black back, white belly
	c.ell(0, 4, 10, 12); c.sh(black)
	c.ell(1.5, 7, 6.5, 8); c.fill("#f6f6f2")
	# wing with a coloured sheen
	c.begin(); c.move_to(-9, -2); c.bez_to(-14, 4, -12, 12, -4, 14); c.bez_to(-6, 6, -6, 1, -9, -2); c.close(); c.sh(black)
	c.begin(); c.move_to(-10, 2); c.bez_to(-12, 6, -10, 10, -6, 12); c.stroke(sheen, 1.6)
	c.ell(-9, 10, 2, 3, .4); c.fill("#f6f6f2")
	# head
	c.ell(1, -10, 8, 7.5); c.sh(black)
	eye(c, -1.6, -11, 1.8, 2.2); eye(c, 4.6, -11, 1.8, 2.2)
	# beak holding a coin
	c.poly([[4, -8], [13, -7], [4, -5]]); c.sh("#3a3a40")
	var sx := maxf(.2, absf(cos(t * 3)))
	c.save(); c.translate(12, -4); c.scale(sx, 1)
	c.ell(0, 0, 3.6, 3.6); c.sh("#ffd23f", "#9a7414", 1)
	c.begin(); c.move_to(0, -1.6); c.line_to(0, 1.6); c.stroke("#9a7414", .9)
	c.restore()
	if k >= 1:
		# coin pouch
		c.ell(-3, 13, 4.4, 4); c.sh("#a0703a")
		c.begin(); c.move_to(-6, 10.5); c.quad_to(-3, 12, 0, 10.5); c.stroke("#5a3a1a", 1)
		c.ell(-3, 9.4, 1.6, 1.2); c.fill("#ffd23f")
		# crest
		for i in 3:
			c.poly([[-3 + i * 2.4, -16], [-1 + i * 2.4, -16], [-3.5 + i * 2.6, -21 + i]]); c.sh("#e0b030")
	if o.get("amulet", false):
		c.begin(); c.move_to(-5, -4); c.quad_to(1, 0, 6, -4); c.stroke("#d8b040", 1.2)
		c.ell(1, -1, 2.2, 2.2); c.sh("#7be3a2", "#2a6a4a", 1)
	c.restore()


# ---------- Wobblob: a jelly that keeps bonking itself ----------
static func _blob_shape(c: Pen) -> void:
	c.begin(); c.move_to(-15, 18); c.bez_to(-18, 4, -12, -18, 0, -18); c.bez_to(12, -18, 18, 4, 15, 18); c.close()


static func wobblob(c: Pen, t: float, _k: int, o := {}) -> void:
	var conf: bool = o.get("conf", 0.0) > 0.0
	if conf:
		c.rotate(sin(t * 14) * .16)
	var w := 1 + sin(t * 3.2) * .07
	c.save(); c.scale(w, 1 / w)
	_blob_shape(c); c.fill(Color("#6fd6a0", .92))
	_blob_shape(c); c.rim(Color("#3a9a6a", .9), -1.6, -2)
	_blob_shape(c); c.stroke("#2a6a4a", 1.5)
	# bubbles inside the jelly
	for b in [[-6, 8, 1.6], [7, 11, 1.2], [3, 2, .9], [-9, -2, 1]]:
		c.ell(b[0], b[1], b[2], b[2]); c.stroke(Color(1, 1, 1, .6), .7)
	c.ell(-6, -10, 4, 2.4, -.5); c.fill(Color(1, 1, 1, .45))
	# a bump with a bandage on top
	c.ell(5, -16, 4, 3); c.fill(Color("#6fd6a0"))
	c.begin(); c.move_to(1, -18); c.line_to(9, -14); c.stroke("#f4e0c0", 3, true)
	c.begin(); c.move_to(4, -18); c.line_to(6, -14); c.stroke("#d8b890", 1)
	if conf:
		for s: int in [-1, 1]:
			_spiral(c, s * 5, -4, 14, .3, .17, .7, t * 10); c.stroke("#1f3a2a", 1.3)
	else:
		eye(c, -5, -4, 2.2, 2.8, "#1f3a2a"); eye(c, 5, -4, 2.2, 2.8, "#1f3a2a")
	c.begin(); c.move_to(-3, 4); c.quad_to(0, 6.5, 3, 4); c.stroke("#1f3a2a", 1.2)
	blush(c, -9, 1, 2.2, "#ff8aa0"); blush(c, 9, 1, 2.2, "#ff8aa0")
	c.restore()
	if conf:
		for i in 3:
			var a := t * 6 + i * TAU / 3
			star(c, cos(a) * 13, -26 + sin(a) * 3, 3.4, "#ffd23f")


# ---------- Astralion: a celestial lion with a starry mane ----------
static func _mane(c: Pen, t: float, rr: float) -> void:
	c.begin()
	for i in 24:
		var a := i * TAU / 24
		var r := rr + (3.0 if i % 2 else 0.0) + sin(t * 2 + i) * .6
		c.line_to(cos(a) * r, -12 + sin(a) * r * .92)
	c.close()


static func astralion(c: Pen, t: float, k: int, _o := {}) -> void:
	var mane := "#26305e" if k < 3 else "#3a2a7a"
	var fur := "#e8dcc0"
	var gold := "#e8b83a"
	if k >= 3:
		c.glow(0, -10, 36, Color("#b8a0ff", .55))
	# tail with a star tip
	c.begin(); c.move_to(8, 12); c.bez_to(22, 16, 26, 2, 22, -6); limb(c, fur, 2.4)
	star(c, 22, -8, 4.4, "#fff4a0")
	feet(c, 7, 5, fur)
	# body
	c.begin(); c.move_to(-10, -4); c.bez_to(-14, 8, -10, 18, 0, 18); c.bez_to(10, 18, 14, 8, 10, -4); c.close(); c.sh(fur)
	if k >= 2:
		# golden armour
		c.begin(); c.move_to(-9, 0); c.quad_to(0, 6, 9, 0); c.line_to(8, 10); c.quad_to(0, 14, -8, 10); c.close(); c.sh(gold, "#7a5a14")
		c.ell(0, 6, 2.4, 2.4); c.sh("#7fd8ff", "#1a4a7a", 1)
	for s: int in [-1, 1]:
		c.ell(s * 9, 9, 3, 5, s * .3); c.sh(fur)
	# starry mane
	var rr := 17.0 + k * 1.5
	_mane(c, t, rr); c.fill(mane)
	_mane(c, t, rr); c.stroke(OUT, 1.4)
	for i in 9:
		var a := i * 2.4 + 1
		var r := 11 + (i % 3) * 2.6
		var tw := .6 + .4 * sin(t * 4 + i * 1.7)
		c.ell(cos(a) * r, -12 + sin(a) * r * .9, .9 * tw + .4, .9 * tw + .4); c.fill(Color(1, 1, .85, tw))
	# face
	c.ell(0, -11, 10, 9.5); c.sh(fur)
	for s: int in [-1, 1]:
		c.ell(s * 7, -19, 2.6, 2.8); c.sh(fur)
	c.ell(0, -6.5, 5, 3.6); c.fill("#fff6e4")
	c.poly([[-1.8, -8.6], [1.8, -8.6], [0, -6.6]]); c.fill("#7a4a5a")
	c.begin(); c.move_to(0, -6.6); c.line_to(0, -5); c.move_to(-2.4, -4.4); c.quad_to(0, -3.4, 0, -5); c.quad_to(0, -3.4, 2.4, -4.4); c.stroke(OUT, 1)
	var ec := "#8fd8ff" if k < 3 else "#ffffff"
	eye_glow(c, -4, -12, 1.8, 1.6, ec); eye_glow(c, 4, -12, 1.8, 1.6, ec)
	# star mark on the brow
	star(c, 0, -17, 2.4, gold)
	if k >= 3:
		for i in 3:
			var a := t * 2 + i * TAU / 3
			star(c, cos(a) * 26, -14 + sin(a) * 6, 2.6, "#fff4a0")


# ---------- Puddlesnail line: a lazy snail that grows into a hermit kraken ----------
static func snail(c: Pen, t: float, k: int, _o := {}) -> void:
	if k == 0:
		# tiny snail that just sits there
		c.begin(); c.move_to(-14, 18); c.line_to(14, 18); c.quad_to(17, 14, 14, 9); c.quad_to(12, 6, 9, 9); c.line_to(6, 13); c.line_to(-12, 14); c.quad_to(-15, 16, -14, 18); c.close(); c.sh("#c8d8a0")
		for s: int in [-1, 1]:
			c.begin(); c.move_to(11 + s * 1.5, 8); c.line_to(11 + s * 3.4, 1); c.stroke("#8a9a60", 1.6, true)
			c.ell(11 + s * 3.4, .4, 1.8, 1.8); c.sh("#c8d8a0", OUT, 1)
			eye_shut(c, 11 + s * 3.4, .6, 1, false)
		c.ell(-1, 4, 10, 9.5); c.sh("#5a9ad8")
		_spiral(c, -1, 4, 26, 8, -.29, .5, 0.0); c.stroke("#2a5a9a", 1.4, true)
		c.ell(-4, -1, 3, 1.6, -.5); c.fill(Color(1, 1, 1, .4))
		# a thought bubble, because it's thinking about it
		var bob := sin(t * 1.5) * 1.2
		c.ell(16, -4 + bob, 1.2, 1.2); c.fs("#fff", Color(OUT, .5), .6)
		c.ell(19, -9 + bob, 2, 2); c.fs("#fff", Color(OUT, .5), .6)
		c.ell(23, -16 + bob, 4.4, 3.4); c.fs("#fff", Color(OUT, .5), .6)
		for i in 3:
			c.ell(21 + i * 2, -16 + bob, .6, .6); c.fill(OUT)
		return
	var big := 1.0 if k < 3 else 1.1
	c.save(); c.scale(big, big)
	var tent := "#c84a6a" if k < 3 else "#7a3ac8"
	if k >= 3:
		c.glow(0, -6, 30, Color("#c8a0ff", .5))
	# tentacles curling out of the shell
	for i in 6:
		var a := PI * (.15 + i * .14)
		var ph := t * 3 + i
		var x0 := cos(a) * 12
		c.begin(); c.move_to(x0 * .6, 8); c.bez_to(x0 * 1.3, 14, x0 * 1.6 + sin(ph) * 3, 18, x0 * 1.9 + sin(ph) * 4, 13 + cos(ph) * 2); limb(c, tent, 3.4)
	# big spiral shell with spikes
	for i in 5:
		var a := -PI * .9 + i * PI * .2
		c.poly([[cos(a) * 15, -6 + sin(a) * 15], [cos(a + .18) * 15, -6 + sin(a + .18) * 15], [cos(a + .09) * 22, -6 + sin(a + .09) * 22]]); c.sh("#e8d8b8")
	c.ell(0, -6, 17, 16); c.sh("#5a9ad8" if k < 3 else "#3a4aa8")
	_spiral(c, 0, -6, 30, 14, -.44, .5, 1.0); c.stroke("#1a3a7a", 1.8, true)
	c.ell(-6, -14, 4, 2.4, -.5); c.fill(Color(1, 1, 1, .35))
	# face peeking out at the bottom
	c.ell(0, 9, 10, 7); c.sh(tent)
	var ec := "#ffe36a" if k < 3 else "#e8fbff"
	for s: int in [-1, 1]:
		c.begin(); c.move_to(s * 1.5, 6); c.quad_to(s * 7, 3, s * 7, 8); c.quad_to(s * 4, 9.4, s * 1.5, 6); c.fs(ec, OUT, 1)
		c.ell(s * 4.6, 7, .9, 1.4); c.fill(OUT)
	c.begin(); c.move_to(-4, 12); c.quad_to(0, 10, 4, 12); c.stroke(OUT, 1.2)
	c.restore()


# ---------- Galefinch line: wind birds ----------
static func gale(c: Pen, t: float, k: int, _o := {}) -> void:
	var big := 1.0 + k * .1
	var body: String = ["#5ac0b0", "#3a9aa0", "#2a7a94", "#2a5a8a"][k]
	var pale := "#eaf8f4"
	var flap := sin(t * (6.0 if k < 2 else 3.5))
	c.save(); c.scale(big, big)
	if k >= 3:
		for i in 3:
			c.begin(); c.arc(0, -4, 22 + i * 4, t * 3 + i * 2, t * 3 + i * 2 + 2.2); c.stroke(Color(1, 1, 1, .5 - i * .12), 1.6)
	c.begin(); c.move_to(-2, 15); c.line_to(-2, 18.5); c.move_to(2, 15); c.line_to(2, 18.5); c.stroke("#e0a040", 1.6)
	c.begin(); c.move_to(-4.5, 18.5); c.line_to(-.5, 18.5); c.move_to(.5, 18.5); c.line_to(4.5, 18.5); c.stroke("#e0a040", 1.4, true)
	# wings
	var span := 10.0 + k * 5
	for s: int in [-1, 1]:
		c.save(); c.translate(s * 8, 0); c.rotate(s * (.2 + flap * .25))
		c.begin(); c.move_to(0, -3); c.bez_to(s * span * .6, -6 - k, s * span, -2, s * span, 3)
		for f in 3:
			c.line_to(s * (span - 2 - f * span * .25), 4 + f * 2.2)
			c.line_to(s * (span - 4 - f * span * .25), 2.2 + f * 2.2)
		c.line_to(0, 6); c.close(); c.sh(body)
		c.restore()
	# tail feathers
	for i in 3:
		c.save(); c.translate(0, 13); c.rotate((i - 1) * .35)
		c.begin(); c.move_to(-1.8, 0); c.line_to(0, 6 + k); c.line_to(1.8, 0); c.close(); c.sh(body)
		c.restore()
	# round body
	c.ell(0, 4, 9 + k, 11); c.sh(body)
	c.ell(0, 7, 6 + k * .5, 7.5); c.fill(pale)
	# head with a swirl crest
	c.ell(0, -9, 8, 7.5); c.sh(body)
	_spiral(c, -1, -18 - k, 14, 1, .32, .45, -PI / 2); c.stroke(OUT, 3, true)
	_spiral(c, -1, -18 - k, 14, 1, .32, .45, -PI / 2); c.stroke(pale, 1.4, true)
	if k >= 1:
		c.begin(); c.move_to(-6, -12.5); c.line_to(-1.5, -11); c.move_to(6, -12.5); c.line_to(1.5, -11); c.stroke(OUT, 1.2, true)
		eye(c, -3.4, -9.6, 1.4, 1.6); eye(c, 3.4, -9.6, 1.4, 1.6)
	else:
		eye(c, -3.4, -9.6, 1.8, 2.2); eye(c, 3.4, -9.6, 1.8, 2.2)
	var bl := 3.0 + k * 1.2
	c.poly([[-2.2, -7], [2.2, -7], [0, -7 + bl]]); c.sh("#f0b040")
	c.restore()


# ---------- Pebbit line: rock armadillos ----------
static func dillo(c: Pen, t: float, k: int, _o := {}) -> void:
	var big := 1.0 + k * .1
	var shell: String = ["#9a9aa4", "#868a8a", "#76706a"][k]
	var skin := "#e0c4a8"
	c.save(); c.scale(big, big)
	c.translate(0, sin(t * 4) * .5)
	feet(c, 7.5, 4.2, skin)
	# tail
	c.begin(); c.move_to(-10, 12); c.quad_to(-20, 14, -22, 8); limb(c, shell, 3)
	# domed banded shell
	c.begin(); c.move_to(-16, 14); c.bez_to(-17, -12, 17, -12, 16, 14); c.close(); c.sh(shell)
	c.begin()
	for i in 4:
		var x := -9.0 + i * 6
		c.move_to(x, -6 + absf(x) * .3); c.quad_to(x * 1.15, 4, x * 1.2, 13)
	c.stroke(Color(OUT, .55), 1.2)
	for p in [[-9, -1], [-3, -5], [3, -5], [9, -1], [-6, 7], [6, 7], [0, 2]]:
		c.ell(p[0], p[1], 1.4, 1); c.fill(Color(1, 1, 1, .25))
	if k >= 1:
		# moss patches
		for p in [[-6, -6, 4], [8, -2, 3.4]]:
			puff(c, p[0], p[1], p[2], "#6aa84a", null)
	if k >= 2:
		# crystal peaks
		for p in [[-7, -8, 6, -.3], [0, -11, 9, 0.0], [7, -8, 6, .3]]:
			c.save(); c.translate(p[0], p[1]); c.rotate(p[3])
			c.poly([[-2.6, 0], [0, -p[2]], [2.6, 0]]); c.sh("#9fe0ff", "#2a5a7a")
			c.restore()
	# face peeking out of the front
	c.ell(0, 9, 8, 7); c.sh(skin)
	for s: int in [-1, 1]:
		c.ell(s * 6, 2.5, 2, 2.6, s * .3); c.sh(skin)
	eye(c, -3, 8, 1.6, 2); eye(c, 3, 8, 1.6, 2)
	c.ell(0, 12, 2, 1.4); c.fill("#7a4a3a")
	if k >= 1:
		c.begin(); c.move_to(-5, 5.5); c.line_to(-1.5, 6.4); c.move_to(5, 5.5); c.line_to(1.5, 6.4); c.stroke(OUT, 1, true)
	c.restore()


# ---------- Knuckaroo line: boxing kangaroos ----------
static func roo(c: Pen, t: float, k: int, _o := {}) -> void:
	var big := 1.0 + k * .08
	var fur: String = ["#d89a5a", "#c8844a", "#b8703a", "#a8603a"][k]
	var pale := "#f4dcb8"
	var glove := "#e03a3a" if k < 3 else "#f0c030"
	var bounce := absf(sin(t * 4)) * 1.5
	c.save(); c.scale(big, big); c.translate(0, -bounce)
	if k >= 3:
		c.glow(0, -4, 30, Color("#ffd27a", .45))
	# thick tail
	c.begin(); c.move_to(-4, 12); c.bez_to(-14, 14, -20, 18, -24, 16); limb(c, fur, 4.4)
	# big feet
	for s: int in [-1, 1]:
		c.ell(s * 6 + 2, 17.6 + bounce, 6.6, 2.4); c.sh(fur)
	# body
	c.begin(); c.move_to(-8, -6); c.bez_to(-13, 4, -10, 17, 0, 17); c.bez_to(10, 17, 13, 4, 8, -6); c.close(); c.sh(fur)
	c.ell(0, 6, 6.5, 9); c.fill(pale)
	# pouch, with a joey for Champaroo
	c.begin(); c.move_to(-5.5, 6); c.quad_to(0, 9, 5.5, 6); c.stroke(Color(OUT, .5), 1)
	if k >= 2:
		c.ell(0, 4, 3.6, 3.2); c.sh(fur)
		c.ell(-1.4, 3.6, .7, .9); c.fill(OUT); c.ell(1.4, 3.6, .7, .9); c.fill(OUT)
		for s: int in [-1, 1]:
			c.ell(s * 4.6, 5, 1.8, 1.6); c.sh(glove, OUT, 1)
		# champion belt
		c.begin(); c.round_rect(-9, 9, 18, 3.4, 1.2); c.sh("#3a2a6a")
		c.ell(0, 10.7, 3, 2.2); c.sh("#ffd23f", "#8a6a14", 1)
	# long ears
	for s: int in [-1, 1]:
		c.save(); c.translate(s * 4.5, -20); c.rotate(s * .25)
		c.begin(); c.move_to(-2.6, 2); c.bez_to(-3.4, -5, -1, -10, 0, -11); c.bez_to(1, -10, 3.4, -5, 2.6, 2); c.close(); c.sh(fur)
		c.begin(); c.move_to(-1.2, 1); c.bez_to(-1.6, -4, -.4, -7, 0, -8); c.bez_to(.4, -7, 1.6, -4, 1.2, 1); c.close(); c.fill("#f0b0a0")
		c.restore()
	# head
	c.ell(0, -13, 7.5, 7); c.sh(fur)
	c.ell(0, -9.6, 4.4, 3.4); c.fill(pale)
	c.ell(0, -11, 1.6, 1.1); c.fill(OUT)
	c.begin(); c.move_to(-1.8, -8.6); c.quad_to(0, -7.4, 1.8, -8.6); c.stroke(OUT, 1)
	eye(c, -3.2, -14.4, 1.5, 1.9); eye(c, 3.2, -14.4, 1.5, 1.9)
	c.begin(); c.move_to(-5, -17); c.line_to(-1.6, -16); c.move_to(5, -17); c.line_to(1.6, -16); c.stroke(OUT, 1.1, true)
	if k >= 1:
		# headband
		var band := "#e03a3a" if k < 3 else "#f0c030"
		c.begin(); c.move_to(-7.4, -16.4); c.quad_to(0, -19.6, 7.4, -16.4); c.stroke(band, 2.2)
		c.begin(); c.move_to(-7, -16); c.line_to(-11, -13 + sin(t * 6)); c.move_to(-7, -16); c.line_to(-11.5, -16 + sin(t * 6 + 1)); c.stroke(band, 1.6, true)
	# boxing gloves up in guard
	var jab := maxf(0, sin(t * 4)) * 2
	for s: int in [-1, 1]:
		var gx := s * 8 + (jab if s > 0 else 0.0)
		c.begin(); c.move_to(s * 7, -3); c.quad_to(s * 11, 0, s * 8, -6); limb(c, fur, 2.6)
		c.ell(gx, -7, 4.6, 4.2); c.sh(glove)
		c.ell(gx - 1.4, -8.6, 1.6, 1); c.fill(Color(1, 1, 1, .5))
	c.restore()


# ---------- Hootling line: owl sages ----------
static func owl(c: Pen, t: float, k: int, _o := {}) -> void:
	var big := 1.0 + k * .08
	var body: String = ["#b8a0d8", "#9a80c8", "#7a60b0", "#5a4898"][k]
	var pale := "#f0e8fa"
	var floaty := k >= 3
	if floaty:
		c.translate(0, sin(t * 2) * 2 - 4)
	c.save(); c.scale(big, big)
	if k >= 1:
		var a := .35 + .15 * sin(t * 2)
		c.begin(); c.arc(0, -4, 20 + k * 2, 0, TAU); c.stroke(Color("#f4b8ff", a), 1.2)
	if k >= 3:
		for i in 6:
			var ang := t * .8 + i * TAU / 6
			star(c, cos(ang) * 22, -6 + sin(ang) * 8, 2, "#ffe6ff")
	if k >= 2:
		# staff
		c.begin(); c.move_to(14, 18); c.line_to(16, -14); limb(c, "#8a6040", 1.8)
		c.ell(16, -16, 3, 3); c.sh("#f4b8ff", "#6a2a8a", 1)
		c.glow(16, -16, 7, Color("#f4b8ff"))
	if not floaty:
		c.begin(); c.move_to(-3, 15); c.line_to(-3, 18.5); c.move_to(3, 15); c.line_to(3, 18.5); c.stroke("#e0a040", 1.8)
	# round body with wing cloak
	c.ell(0, 4, 12, 13); c.sh(body)
	c.ell(0, 7, 7.5, 9); c.fill(pale)
	c.begin()
	for r in 3:
		for i in 3:
			var x := -4.0 + i * 4
			var y := 2.0 + r * 4
			c.move_to(x - 1.4, y); c.quad_to(x, y + 1.6, x + 1.4, y)
	c.stroke(Color(OUT, .3), .8)
	for s: int in [-1, 1]:
		c.begin(); c.move_to(s * 10, -4); c.bez_to(s * 16, 2, s * 15, 12, s * 9, 16); c.bez_to(s * 10, 8, s * 9, 0, s * 10, -4); c.close(); c.sh(body)
	if k >= 1:
		# scarf
		c.begin(); c.move_to(-9, -5); c.quad_to(0, -1, 9, -5); c.stroke("#f0a040", 3.4, true)
		c.begin(); c.move_to(5, -4); c.line_to(7, 4); c.stroke("#f0a040", 2.6, true)
	# head with ear tufts
	for s: int in [-1, 1]:
		c.poly([[s * 4, -18], [s * 11, -24], [s * 10, -14]]); c.sh(body)
	c.ell(0, -12, 11, 8.5); c.sh(body)
	for s: int in [-1, 1]:
		c.ell(s * 4.6, -12, 4.4, 4.4); c.fill(pale)
	if k == 0:
		eye_shut(c, -4.6, -12, 2.4, false)
		eye_shut(c, 4.6, -12, 2.4, false)
	else:
		var ec := "#ffcf5a" if k < 3 else "#fff6c0"
		eye_glow(c, -4.6, -12, 2.2, 2.4, ec)
		eye_glow(c, 4.6, -12, 2.2, 2.4, ec)
		c.ell(-4.6, -12, .8, 1.2); c.fill(INK); c.ell(4.6, -12, .8, 1.2); c.fill(INK)
	c.poly([[-1.6, -9.6], [1.6, -9.6], [0, -6.6]]); c.sh("#f0b040")
	if k >= 2:
		# a wise little tuft under the beak
		c.poly([[-2.4, -6.6], [2.4, -6.6], [0, -2.4]]); c.sh("#ffffff", Color(OUT, .6), 1)
	c.restore()


# ---------- Frostray: an ice manta ----------
static func _ray_shape(c: Pen, flap: float) -> void:
	c.begin(); c.move_to(0, -12); c.bez_to(10, -10, 18, -4 + flap, 26, 2 + flap); c.bez_to(16, 6, 8, 10, 0, 12)
	c.bez_to(-8, 10, -16, 6, -26, 2 + flap); c.bez_to(-18, -4 + flap, -10, -10, 0, -12); c.close()


static func ray(c: Pen, t: float, k: int, _o := {}) -> void:
	var big := 1.0 if k < 3 else 1.1
	var flap := sin(t * 2.4) * 3
	c.save(); c.scale(big, big)
	if k >= 3:
		c.glow(0, 0, 32, Color("#bff0ff", .55))
	# whip tail
	c.begin(); c.move_to(0, 10); c.bez_to(2, 16, -6, 18, -2 + sin(t * 3) * 3, 22); c.stroke(OUT, 3.4, true)
	c.begin(); c.move_to(0, 10); c.bez_to(2, 16, -6, 18, -2 + sin(t * 3) * 3, 22); c.stroke("#9ad8f0", 1.6, true)
	# diamond wings
	_ray_shape(c, flap); c.sh("#bfe8f8", "#2a6a8a", 1.4)
	_ray_shape(c, flap); c.fill_fan(0, -2, 24, Color(1, 1, 1, .5), Color(1, 1, 1, 0))
	# frost crystal pattern
	c.begin()
	for s: int in [-1, 1]:
		c.move_to(s * 4, -2); c.line_to(s * 20, 1 + flap * .8)
		c.move_to(s * 12, -1); c.line_to(s * 14, -5)
		c.move_to(s * 12, 0); c.line_to(s * 14, 4)
	c.stroke(Color("#ffffff", .8), 1)
	if k >= 3:
		for s: int in [-1, 1]:
			for i in 3:
				var x := s * (8 + i * 6)
				var dy := flap * (i / 3.0)
				c.poly([[x - 1.6, -4 + dy], [x, -11 - i + dy], [x + 1.6, -4 + dy]]); c.sh("#e8fbff", "#2a6a8a", 1)
	# head lobes and face
	for s: int in [-1, 1]:
		c.ell(s * 5, -12, 2.4, 3.6, s * .4); c.sh("#9ad8f0", "#2a6a8a", 1.2)
	eye(c, -4, -5, 1.8, 2.2, "#1a3a5a"); eye(c, 4, -5, 1.8, 2.2, "#1a3a5a")
	c.begin(); c.move_to(-3, 0); c.quad_to(0, 2.4, 3, 0); c.stroke("#1a3a5a", 1.1)
	blush(c, -7, -1.6, 1.8, "#8fb8ff"); blush(c, 7, -1.6, 1.8, "#8fb8ff")
	c.restore()


# ---------- Slumbear: a giant sleepy moss bear ----------
static func bear(c: Pen, t: float, k: int, _o := {}) -> void:
	var big := 1.0 if k < 3 else 1.1
	var fur := "#7a8a52" if k < 3 else "#6a7a8a"
	var breath := sin(t * 1.4) * .6
	c.save(); c.scale(big, big)
	feet(c, 10, 5.4, "#5a4a3a")
	for s: int in [-1, 1]:
		c.ell(s * 10, 17.4, 2.4, 1.4); c.fill("#e8d0b0")
	if k >= 3:
		# snowy mountain on its back
		c.poly([[-14, -8], [-4, -26], [2, -16], [8, -24], [16, -8]]); c.sh("#8a92a8", "#2a3040")
		c.poly([[-7.5, -20], [-4, -26], [-1, -21], [-3, -19.6], [-5, -21]]); c.fill("#ffffff")
		c.poly([[5.5, -20.5], [8, -24], [10.6, -20], [8, -19]]); c.fill("#ffffff")
	# big round body
	c.ell(0, 3 + breath * .3, 18 + breath, 15 + breath); c.sh(fur)
	c.ell(0, 7, 11, 9.5); c.fill("#d8c8a0")
	if k < 3:
		# moss and mushrooms on its back
		puff(c, -10, -9, 5, "#5a8a3a", null)
		puff(c, 9, -10, 4.4, "#5a8a3a", null)
		for m in [[-7, -13, 3.4], [11, -13, 2.6]]:
			c.begin(); c.move_to(m[0] - .8, m[1] + 3); c.line_to(m[0] - .8, m[1]); c.line_to(m[0] + .8, m[1]); c.line_to(m[0] + .8, m[1] + 3); c.close(); c.fill("#f4ead8")
			c.begin(); c.ellipse(m[0], m[1], m[2], m[2] * .7, 0, PI, TAU); c.close(); c.sh("#e05a3a", OUT, 1)
	for s: int in [-1, 1]:
		c.ell(s * 16, 6, 4.4, 6.4, s * .3); c.sh(fur)
	# head
	for s: int in [-1, 1]:
		c.ell(s * 8, -12, 3.4, 3.4); c.sh(fur)
		c.ell(s * 8, -12, 1.6, 1.6); c.fill("#5a4a3a")
	c.ell(0, -5, 11, 8.5); c.sh(fur)
	c.ell(0, -2, 5.4, 3.8); c.fill("#d8c8a0")
	c.ell(0, -3.4, 1.8, 1.2); c.fill(OUT)
	eye_shut(c, -4.6, -6.4, 2.2, false)
	eye_shut(c, 4.6, -6.4, 2.2, false)
	c.begin(); c.move_to(-1.6, -.6); c.quad_to(0, .6, 1.6, -.6); c.stroke(OUT, 1)
	blush(c, -7.6, -3, 2, "#ff8a7a"); blush(c, 7.6, -3, 2, "#ff8a7a")
	c.restore()


# ---------- Wyrmlet line: cloud dragons ----------
static func wyrm(c: Pen, t: float, k: int, _o := {}) -> void:
	var skin: String = ["#7ad8b0", "#5ac0a8", "#f0dca8"][k]
	var belly: String = ["#e8fff4", "#e0fff4", "#fff8e8"][k]
	if k < 2:
		# serpent body coiled on the ground, head raised
		var len := 1.0 + k * .25
		var w := 5.5 + k * 1.5
		c.begin(); c.move_to(-16 * len, 14); c.bez_to(-18 * len, 20, 10 * len, 20, 14 * len, 14); c.bez_to(18 * len, 8, 4, 6, 0, 4); c.bez_to(-4, 0, -2, -8, 2, -12)
		limb(c, skin, w)
		c.begin(); c.move_to(-16 * len, 14); c.bez_to(-18 * len, 20, 10 * len, 20, 14 * len, 14); c.stroke(Color(belly, .9), w * .35, true)
		# cloud-puff fins along the back
		for p in [[-12 * len, 13], [10 * len, 12], [4, 4]]:
			puff(c, p[0], p[1] - w * .6, 2.6 + k, "#ffffff", "#8aa8c8")
		c.translate(2, -14)
	else:
		# Skywyrm stands on two legs with wings
		var flap := sin(t * 3) * .2
		for s: int in [-1, 1]:
			c.save(); c.translate(s * 7, -4); c.rotate(s * (.3 + flap))
			c.begin(); c.move_to(0, 0); c.bez_to(s * 10, -14, s * 20, -12, s * 22, -6); c.line_to(s * 17, -3); c.line_to(s * 19, 1); c.line_to(s * 13, 1); c.line_to(s * 12, 5); c.close(); c.sh("#8ad8f0", "#2a5a7a")
			c.restore()
		c.begin(); c.move_to(-4, 12); c.bez_to(-16, 14, -20, 8, -22, 2); limb(c, skin, 4)
		feet(c, 6, 4.4, skin)
		c.begin(); c.move_to(-9, -6); c.bez_to(-13, 6, -10, 17.5, 0, 17.5); c.bez_to(10, 17.5, 13, 6, 9, -6); c.close(); c.sh(skin)
		c.ell(0, 6, 6, 9); c.fill(belly)
		for s: int in [-1, 1]:
			c.ell(s * 9, 4, 2.4, 4, s * .4); c.sh(skin)
		c.translate(0, -12)
	# head
	var hr := 7.0 + k
	for s: int in [-1, 1]:
		# cloud horns
		puff(c, s * (hr * .7), -hr * .9, 2.4 + k * .4, "#ffffff", "#8aa8c8")
	c.ell(0, 0, hr, hr * .9); c.sh(skin)
	c.ell(0, hr * .35, hr * .6, hr * .4); c.fill(belly)
	eye(c, -hr * .42, -hr * .15, 1.6 + k * .2, 2 + k * .2); eye(c, hr * .42, -hr * .15, 1.6 + k * .2, 2 + k * .2)
	c.ell(-1.4, hr * .3, .6, .5); c.fill(OUT); c.ell(1.4, hr * .3, .6, .5); c.fill(OUT)
	c.begin(); c.move_to(-2, hr * .55); c.quad_to(0, hr * .7, 2, hr * .55); c.stroke(OUT, 1)
	if k >= 1:
		# whiskers trailing like mist
		for s: int in [-1, 1]:
			c.begin(); c.move_to(s * hr * .55, hr * .45); c.bez_to(s * hr * .9, hr * .8, s * hr * 1.1, hr * 1.1 + sin(t * 3) * .8, s * hr * 1.35, hr * 1.2); c.stroke(Color("#7a9ab8"), 1.8, true)
			c.begin(); c.move_to(s * hr * .55, hr * .45); c.bez_to(s * hr * .9, hr * .8, s * hr * 1.1, hr * 1.1 + sin(t * 3) * .8, s * hr * 1.35, hr * 1.2); c.stroke(Color("#ffffff"), .9, true)


# ---------- Prismkit line: crystal fox kits and their three grown forms ----------
static func fox(c: Pen, t: float, k: int, _o := {}) -> void:
	var fur: String = ["#d8c8ec", "#5ab8d8", "#9a6ae0", "#e8603a"][k]
	var tip: String = ["#ffffff", "#e8fbff", "#ffe36a", "#ffd23f"][k]
	var gem: String = ["#f4a0e0", "#7fe0ff", "#fff07a", "#ffb03a"][k]
	var big := 1.0 if k == 0 else 1.1
	c.save(); c.scale(big, big)
	# fluffy tail
	var sw := sin(t * 2.5) * .1
	c.save(); c.translate(-6, 12); c.rotate(-.7 + sw)
	c.begin(); c.move_to(0, 0); c.bez_to(-8, -4, -12, -14, -6, -22); c.bez_to(2, -18, 6, -8, 3, 0); c.close(); c.sh(fur)
	if k == 1:
		# fin-shaped tail tip
		c.poly([[-6, -22], [-12, -26], [-3, -20]]); c.sh(tip)
	elif k == 2:
		bolt(c, [[-6, -22], [-10, -16], [-6, -16], [-9, -10], [-3, -17], [-6, -17], [-2, -21]], tip)
	elif k == 3:
		flame(c, -6, -20, .55, t, false)
	else:
		c.begin(); c.move_to(-6, -22); c.bez_to(-2, -20, 0, -17, -.6, -14); c.bez_to(-4, -15, -6, -18, -6, -22); c.close(); c.fill(tip)
	c.restore()
	feet(c, 5.5, 3.8, fur)
	c.begin(); c.move_to(-8, -2); c.bez_to(-11, 8, -8, 17.5, 0, 17.5); c.bez_to(8, 17.5, 11, 8, 8, -2); c.close(); c.sh(fur)
	c.ell(0, 7, 5, 8); c.fill(Color(1, 1, 1, .6))
	if k == 1:
		c.begin(); c.move_to(-5, 0); c.quad_to(0, 3, 5, 0); c.quad_to(0, 6, -5, 0); c.close(); c.fs("#e8fbff", Color(OUT, .6), 1)
	# tall pointed ears
	for s: int in [-1, 1]:
		c.save(); c.translate(s * 6, -13); c.rotate(s * .35)
		c.poly([[-3.6, 1], [0, -12 - k], [3.6, 1]]); c.sh(fur)
		c.poly([[-1.8, 0], [0, -8 - k], [1.8, 0]]); c.fill(tip if k > 0 else "#f4c0e0")
		c.restore()
	# head with a pointed muzzle
	c.begin(); c.move_to(-10, -7); c.bez_to(-10, -16, 10, -16, 10, -7); c.bez_to(10, -2, 4, 0, 0, 1.4); c.bez_to(-4, 0, -10, -2, -10, -7); c.close(); c.sh(fur)
	c.begin(); c.move_to(-5, -4); c.quad_to(0, 2, 5, -4); c.quad_to(0, -2, -5, -4); c.fill(Color(1, 1, 1, .75))
	c.ell(0, -.4, 1.4, 1); c.fill(OUT)
	eye(c, -4.4, -7, 2, 2.4); eye(c, 4.4, -7, 2, 2.4)
	# forehead crystal
	c.glow(0, -12, 5, Color(gem, .8))
	c.poly([[0, -15], [2.2, -12], [0, -9.6], [-2.2, -12]]); c.sh(gem, OUT, 1)
	if k == 2:
		# spiky static ruff
		for s: int in [-1, 1]:
			c.poly([[s * 8, -4], [s * 13, -2], [s * 9, 0], [s * 12, 3], [s * 7, 2]]); c.sh(fur)
	c.restore()


# ---------- Mimoth: a moth whose wings copy its neighbours ----------
static func mimoth(c: Pen, t: float, _k: int, _o := {}) -> void:
	var flap := sin(t * 5) * .25
	c.translate(0, sin(t * 2.4) * 1.5 - 2)
	for s: int in [-1, 1]:
		c.save(); c.translate(s * 2, -2); c.scale(1 - absf(flap) * .5, 1)
		# upper and lower wings
		c.begin(); c.move_to(0, 0); c.bez_to(s * 6, -18, s * 22, -18, s * 20, -4); c.bez_to(s * 18, 2, s * 6, 2, 0, 0); c.close(); c.sh("#c89af0", "#5a3a8a")
		c.begin(); c.move_to(0, 2); c.bez_to(s * 8, 2, s * 18, 6, s * 14, 14); c.bez_to(s * 8, 16, s * 2, 10, 0, 2); c.close(); c.sh("#f0a8d8", "#5a3a8a")
		# eye spots that shift colour
		var hue := fmod(t * .2 + (0.0 if s < 0 else .5), 1.0)
		c.ell(s * 13, -8, 4, 3.4); c.fill(Color.from_hsv(hue, .5, 1))
		c.ell(s * 13, -8, 2, 1.7); c.fill(Color.from_hsv(fmod(hue + .4, 1.0), .7, .7))
		c.ell(s * 10, 8, 2.2, 2); c.fill(Color.from_hsv(fmod(hue + .2, 1.0), .5, 1))
		c.restore()
	# fluffy body
	c.ell(0, 6, 5, 9); c.sh("#f4ecd8", "#7a6a4a")
	for i in 3:
		c.begin(); c.move_to(-4, 6 + i * 3.4); c.quad_to(0, 7.6 + i * 3.4, 4, 6 + i * 3.4); c.stroke(Color("#b8a888"), 1)
	puff(c, 0, -3, 5, "#fffaf0", "#b8a888")
	# head and feathery antennae
	c.ell(0, -8, 5, 4.6); c.sh("#f4ecd8", "#7a6a4a")
	for s: int in [-1, 1]:
		c.begin(); c.move_to(s * 2, -12); c.quad_to(s * 5, -20, s * 9, -21); c.stroke("#7a6a4a", 1.2, true)
		for i in 4:
			var px := s * (3 + i * 1.6)
			var py := -15 - i * 1.5
			c.begin(); c.move_to(px, py); c.line_to(px + s * 1.4, py - 2.2); c.stroke("#7a6a4a", .8)
	eye(c, -2.2, -8.4, 1.6, 1.9, "#3a1a5a"); eye(c, 2.2, -8.4, 1.6, 1.9, "#3a1a5a")


# ---------- Bunbalm line: rabbit nurses ----------
static func _ear(c: Pen, x: float, y: float, rot: float, len: float, fur: String, line: String) -> void:
	c.save(); c.translate(x, y); c.rotate(rot)
	c.begin(); c.move_to(-3.4, 2); c.bez_to(-4.6, -8, -2, -len, 0, -len); c.bez_to(2, -len, 4.6, -8, 3.4, 2); c.close(); c.sh(fur, line)
	c.begin(); c.move_to(-1.6, 0); c.bez_to(-2.4, -7, -1, -len + 4, 0, -len + 4); c.bez_to(1, -len + 4, 2.4, -7, 1.6, 0); c.close(); c.fill("#f8b8c8")
	c.restore()


static func bunny(c: Pen, t: float, k: int, _o := {}) -> void:
	var big := 1.0 + k * .1
	var fur := "#fbf6f2"
	var line := "#a07a8a"
	c.save(); c.scale(big, big)
	# long ears, one flopped
	var ew := sin(t * 2) * .05
	_ear(c, -5, -16, -.2 + ew, 18, fur, line)
	_ear(c, 5, -16, .9 + ew, 16, fur, line)
	feet(c, 6, 4.6, fur, line)
	# round fluffy body
	c.ell(0, 5, 12.5, 13); c.sh(fur, line)
	c.ell(-12, 12, 3.6, 3.6); c.sh(fur, line)
	# satchel with a leaf cross
	c.begin(); c.move_to(-9, -4); c.line_to(7, 9); c.stroke("#8a6a4a", 1.6)
	c.begin(); c.round_rect(3, 6, 10, 8, 2); c.sh("#e8d8b0", "#7a5a3a")
	c.fill_rect(7.2, 7.2, 1.6, 5.6, Color("#4fb050")); c.fill_rect(5.2, 9.2, 5.6, 1.6, Color("#4fb050"))
	for s: int in [-1, 1]:
		c.ell(s * 10, 4, 2.6, 3.4, s * .5); c.sh(fur, line)
	# face
	c.ell(0, -9, 9.5, 8.5); c.sh(fur, line)
	eye(c, -4, -10, 1.8, 2.2, "#4a1a2a"); eye(c, 4, -10, 1.8, 2.2, "#4a1a2a")
	c.poly([[-1.2, -6.8], [1.2, -6.8], [0, -5.6]]); c.fill("#e07a90")
	c.begin(); c.move_to(0, -5.6); c.line_to(0, -4.6); c.move_to(-2, -4); c.quad_to(0, -3, 0, -4.6); c.quad_to(0, -3, 2, -4); c.stroke(line, 1)
	blush(c, -6.4, -6.4, 2, "#ff8aa8"); blush(c, 6.4, -6.4, 2, "#ff8aa8")
	if k >= 1:
		# flower crown
		for i in 5:
			var x := -7.0 + i * 3.5
			var y := -16.4 + absf(x) * .14
			for p in 5:
				var a := p * TAU / 5
				c.ell(x + cos(a) * 1.3, y + sin(a) * 1.3, 1.1, 1.1); c.fill(["#ff9ac0", "#ffd23f", "#9ad8ff"][i % 3])
			c.ell(x, y, .8, .8); c.fill("#fff6c0")
	c.restore()
