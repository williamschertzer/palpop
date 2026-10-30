class_name Art
extends RefCounted
## Caches and places the critter drawings (see Mons) and draws the orbs.
## Drawings are recorded once per animation frame and cached, so the game only
## replays them.

const OUT := Pen.OUT
const ANIM_FPS := 12.0
const ANIM_FRAMES := 72

const SPRITE_INFO := {
	"zapkit": {"name": "Zapkit", "scale": .86}, "stormstoat": {"name": "Stormstoat", "scale": .9}, "tempeststoat": {"name": "Tempest Stoat", "scale": 1.0},
	"cindermole": {"name": "Cindermole", "scale": .86}, "kilnmole": {"name": "Kilnmole", "scale": .9}, "magmoloss": {"name": "Magmoloss", "scale": .96}, "ascmagmoloss": {"name": "Ascended Magmoloss", "scale": 1.02},
	"lanternwisp": {"name": "Lanternwisp", "scale": .92, "float": true}, "lanternshade": {"name": "Lanternshade", "scale": .92, "float": true}, "lanternlord": {"name": "Lanternlord", "scale": .98, "float": true}, "lanternwraith": {"name": "Lantern Wraith", "scale": 1.04, "float": true},
	"spoutling": {"name": "Spoutling", "scale": .86}, "spoutseal": {"name": "Spoutseal", "scale": .9}, "geyserwal": {"name": "Geyserwal", "scale": .96}, "ascgeyserwal": {"name": "Ascended Geyserwal", "scale": 1.0},
	"thornhog": {"name": "Thornhog", "scale": .9}, "bramblehog": {"name": "Bramblehog", "scale": .94}, "grovehog": {"name": "Grovehog", "scale": .98}, "ascgrovehog": {"name": "Ascended Grovehog", "scale": 1.0},
	"coinpie": {"name": "Coinpie", "scale": .88}, "goldpie": {"name": "Goldpie", "scale": .92}, "wobblob": {"name": "Wobblob", "scale": .9},
	"astralion": {"name": "Astralion", "scale": .98}, "armorastralion": {"name": "Armored Astralion", "scale": 1.0}, "novaastralion": {"name": "Nova Astralion", "scale": 1.04},
	"nest": {"name": "The Nest Egg", "scale": .95},
	"puddlesnail": {"name": "Puddlesnail", "scale": .9}, "krakenshell": {"name": "Krakenshell", "scale": 1.0}, "asckrakenshell": {"name": "Ascended Krakenshell", "scale": 1.04},
	"galefinch": {"name": "Galefinch", "scale": .86}, "galehawk": {"name": "Galehawk", "scale": .9}, "galeroc": {"name": "Galeroc", "scale": .96}, "ascgaleroc": {"name": "Ascended Galeroc", "scale": 1.0},
	"pebbit": {"name": "Pebbit", "scale": .9}, "bouldillo": {"name": "Bouldillo", "scale": .94}, "mountadillo": {"name": "Mountadillo", "scale": .98},
	"knuckaroo": {"name": "Knuckaroo", "scale": .86}, "brawlaroo": {"name": "Brawlaroo", "scale": .92}, "champaroo": {"name": "Champaroo", "scale": .98}, "titanchamparoo": {"name": "Titan Champaroo", "scale": 1.02},
	"hootling": {"name": "Hootling", "scale": .88}, "hootsage": {"name": "Hootsage", "scale": .92}, "hootarch": {"name": "Hootarch", "scale": .96}, "elderhootarch": {"name": "Elder Hootarch", "scale": 1.0, "float": true},
	"frostray": {"name": "Frostray", "scale": .96}, "glacierfrostray": {"name": "Glacier Frostray", "scale": 1.0},
	"slumbear": {"name": "Slumbear", "scale": 1.0}, "mountainslumbear": {"name": "Mountain Slumbear", "scale": 1.04},
	"wyrmlet": {"name": "Wyrmlet", "scale": .9}, "cloudwyrm": {"name": "Cloudwyrm", "scale": .96}, "skywyrm": {"name": "Skywyrm", "scale": 1.0},
	"prismkit": {"name": "Prismkit", "scale": .86}, "tidefox": {"name": "Tidefox", "scale": .92}, "sparkfox": {"name": "Sparkfox", "scale": .92}, "blazefox": {"name": "Blazefox", "scale": .92},
	"mimoth": {"name": "Mimoth", "scale": .9},
	"bunbalm": {"name": "Bunbalm", "scale": .92}, "grandbunbalm": {"name": "Grand Bunbalm", "scale": .98},
}

static var _mon_cache := {}
static var _ball_cache := {}
static var _pen := Pen.new()


# ---------- cached access ----------
## Returns the recorded drawing of a critter at time t, centred on its feet area.
const ANIMATED := ["zapkit", "stormstoat", "tempeststoat", "nest", "cindermole", "kilnmole", "magmoloss", "ascmagmoloss",
	"lanternwisp", "lanternshade", "lanternlord", "lanternwraith", "spoutling", "spoutseal", "geyserwal", "ascgeyserwal",
	"thornhog", "bramblehog", "grovehog", "ascgrovehog", "coinpie", "goldpie", "wobblob", "astralion", "armorastralion", "novaastralion",
	"puddlesnail", "krakenshell", "asckrakenshell", "galefinch", "galehawk", "galeroc", "ascgaleroc", "pebbit", "bouldillo", "mountadillo",
	"knuckaroo", "brawlaroo", "champaroo", "titanchamparoo", "hootling", "hootsage", "hootarch", "elderhootarch",
	"frostray", "glacierfrostray", "slumbear", "mountainslumbear", "wyrmlet", "cloudwyrm", "skywyrm",
	"prismkit", "tidefox", "sparkfox", "blazefox", "mimoth", "bunbalm", "grandbunbalm"]


static func mon(sp: String, t: float, opt := {}, alpha := 1.0) -> Array:
	var frame := posmod(int(floor(t * ANIM_FPS)), ANIM_FRAMES) if ANIMATED.has(sp) else 18
	alpha = snappedf(alpha, 0.05)
	var key := "%s|%d|%s|%s|%s|%s|%s" % [sp, frame, opt.get("shades", false), opt.get("conf", 0.0) > 0.0, opt.get("amulet", false), opt.get("sleep", false), alpha]
	if _mon_cache.has(key):
		return _mon_cache[key]
	var c := _pen
	c.clear()
	draw_mon(c, sp, frame / ANIM_FPS, opt)
	var out := Pen.bake(c.cmds, alpha)
	c.cmds = []
	_mon_cache[key] = out
	return out


## Draws a critter onto a CanvasItem at (x, y).
static func put_mon(ci: CanvasItem, sp: String, x: float, y: float, scale: float, flip: bool, t: float, alpha := 1.0, opt := {}) -> void:
	ci.draw_set_transform(Vector2(x, y), 0.0, Vector2(-scale if flip else scale, scale))
	Pen.draw_baked(ci, mon(sp, t, opt, alpha))
	ci.draw_set_transform_matrix(Transform2D.IDENTITY)


static func ball(type: String, alpha := 1.0) -> Array:
	alpha = snappedf(alpha, 0.05)
	var key := "%s|%s" % [type, alpha]
	if _ball_cache.has(key):
		return _ball_cache[key]
	var c := _pen
	c.clear()
	if type == "blimp":
		draw_blimp(c)
	else:
		draw_ball(c, type)
	var out := Pen.bake(c.cmds, alpha)
	c.cmds = []
	_ball_cache[key] = out
	return out


static func put_ball(ci: CanvasItem, type: String, x: float, y: float, rot := 0.0, scale := 1.0, alpha := 1.0) -> void:
	ci.draw_set_transform(Vector2(x, y), rot, Vector2(scale, scale))
	Pen.draw_baked(ci, ball(type, alpha))
	ci.draw_set_transform_matrix(Transform2D.IDENTITY)


# ---------- critter ----------
static func draw_mon(c: Pen, sp: String, t: float, opt := {}) -> void:
	var info: Dictionary = SPRITE_INFO[sp]
	var sc: float = info.scale
	var fl: bool = info.get("float", false)
	c.ell(0, 18 * sc, (9.0 if fl else 12.0) * sc, 3.4 * sc)
	c.fill(Color(0, 0, 0, .16 if fl else .26))
	c.save()
	c.scale(sc, sc)
	Mons.draw(c, sp, t, opt)
	c.restore()


# ---------- orbs ----------
## A capture orb: a glossy sphere held in a metal cage with a glowing core.
static func draw_ball(c: Pen, type: String) -> void:
	var d: Dictionary = Data.BALLS[type]
	var r: float = d.r
	var base := Color(d.top)
	var metal := "#2e3440"
	var core := base.lightened(.55)
	c.begin(); c.arc(0, 0, r); c.fill(base)
	c.begin(); c.arc(0, 0, r); c.fill_fan(-r * .35, -r * .4, r * 1.5, Color(1, 1, 1, .45), Color(0, 0, 0, .25))
	c.save()
	c.begin(); c.arc(0, 0, r); c.clip()
	match type:
		"blue":
			for s: int in [-1, 1]:
				var a0 := -1.2 if s > 0 else PI - 1.2
				c.begin(); c.arc(s * r * .62, 0, r * .52, a0, a0 + 2.4); c.stroke("#bfe0ff", r * .12)
		"gold":
			for k in 6:
				var a := k * TAU / 6
				c.poly([[cos(a) * r * .5, sin(a) * r * .5], [cos(a + .5) * r * 1.1, sin(a + .5) * r * 1.1], [cos(a - .5) * r * 1.1, sin(a - .5) * r * 1.1]]); c.fill(Color("#fff2b0", .35))
		"dart":
			for s: int in [-1, 1]:
				c.poly([[-r * .9, s * r * .25], [-r * .2, s * r * .55], [-r * .9, s * r * .85]]); c.fill("#ffffff")
		"clock":
			for k in 12:
				var a := k * TAU / 12
				c.begin(); c.move_to(cos(a) * r * .72, sin(a) * r * .72); c.line_to(cos(a) * r * .86, sin(a) * r * .86); c.stroke("#3a3a40", 1)
		"mesh":
			c.begin()
			for x in [-.6, -.2, .2, .6]:
				c.move_to(r * x, -r); c.line_to(r * x, r)
				c.move_to(-r, r * x); c.line_to(r, r * x)
			c.stroke("#123c44", r * .07)
		"mend":
			c.fill_rect(-r * .62, -r * .14, r * .3, r * .28, Color.WHITE); c.fill_rect(-r * .61, -r * .3, r * .28, r * .6, Color.WHITE)
			c.fill_rect(r * .32, -r * .14, r * .3, r * .28, Color.WHITE); c.fill_rect(r * .33, -r * .3, r * .28, r * .6, Color.WHITE)
		"shade":
			c.begin(); c.arc(0, 0, r * .75, PI * 1.15, PI * 1.85); c.stroke("#7affb0", r * .08)
			c.begin(); c.arc(0, 0, r * .75, PI * .15, PI * .85); c.stroke("#7affb0", r * .08)
		"iron":
			c.fill_rect(-r, -r, 2 * r, r * .5, Color("#6d7888")); c.fill_rect(-r, r * .5, 2 * r, r * .5, Color("#6d7888"))
			for x in [-.7, -.35, 0.35, .7]:
				c.begin(); c.arc(r * x, -r * .65, r * .07); c.fill("#d8dee8")
				c.begin(); c.arc(r * x, r * .65, r * .07); c.fill("#d8dee8")
		"titan":
			for k in 8:
				var a := k * TAU / 8 + .2
				c.begin(); c.arc(cos(a) * r * .72, sin(a) * r * .72, r * .09); c.fill("#ffd23f")
	c.restore()
	# the cage: an equator band and a meridian band
	c.begin(); c.move_to(-r, 0); c.line_to(r, 0); c.stroke(metal, r * .2)
	c.begin(); c.move_to(0, -r); c.line_to(0, r); c.stroke(metal, r * .14)
	c.begin(); c.move_to(-r, -r * .05); c.line_to(r, -r * .05); c.stroke(Color(1, 1, 1, .25), r * .05)
	# glowing core
	var cr := r * (.34 if type != "titan" else .4)
	c.glow(0, 0, cr * 2.4, Color(core, .7))
	c.begin(); c.arc(0, 0, cr + r * .08); c.fill(metal)
	c.begin(); c.arc(0, 0, cr); c.fill(core)
	match type:
		"clock":
			c.begin(); c.move_to(0, 0); c.line_to(0, -cr * .8); c.move_to(0, 0); c.line_to(cr * .6, 0); c.stroke("#3a3a40", 1.1)
		"shade":
			c.begin(); c.arc(0, 0, cr * .45); c.fill("#0a1a10")
		"mend":
			c.fill_rect(-cr * .15, -cr * .6, cr * .3, cr * 1.2, Color("#f25a8a")); c.fill_rect(-cr * .6, -cr * .15, cr * 1.2, cr * .3, Color("#f25a8a"))
		"titan":
			c.poly([[-cr * .6, cr * .3], [-cr * .6, -cr * .3], [-cr * .3, 0], [0, -cr * .5], [cr * .3, 0], [cr * .6, -cr * .3], [cr * .6, cr * .3]]); c.fill("#7b3fb4")
	c.begin(); c.arc(-cr * .3, -cr * .35, cr * .3); c.fill(Color(1, 1, 1, .8))
	c.begin(); c.arc(0, 0, r); c.stroke("#16161a", 1.6)


## The Snatchers' airship: a patched blimp with a cage hanging underneath.
static func draw_blimp(c: Pen) -> void:
	var r: float = Data.BALLS.blimp.r
	# cage on chains
	c.begin(); c.move_to(-r * .45, r * .55); c.line_to(-10, r + 14); c.move_to(r * .45, r * .55); c.line_to(10, r + 14); c.stroke("#4a4a50", 1.2)
	c.begin(); c.round_rect(-12, r + 12, 24, 18, 3); c.fill(Color(0, 0, 0, .25))
	c.begin(); c.round_rect(-12, r + 12, 24, 18, 3); c.stroke("#3a3a40", 1.6)
	c.begin()
	for i in 5:
		var x := -8.0 + i * 4
		c.move_to(x, r + 12); c.line_to(x, r + 30)
	c.stroke("#5a5a60", 1.2)
	# tail fins
	for s: int in [-1, 1]:
		c.poly([[-r * .9, s * r * .1], [-r * 1.35, s * r * .55], [-r * 1.2, s * r * .05]]); c.sh("#c84a3a")
	# envelope
	c.ell(0, 0, r * 1.15, r * .72); c.sh("#8a8f9a", OUT, 1.8)
	c.begin(); c.move_to(-r * 1.1, 0); c.quad_to(0, r * .25, r * 1.1, 0); c.stroke(Color(OUT, .4), 1)
	for x in [-.5, 0.0, .5]:
		c.begin(); c.move_to(r * x, -r * .7 + absf(x) * r * .2); c.quad_to(r * x * 1.15, 0, r * x, r * .7 - absf(x) * r * .2); c.stroke(Color(OUT, .3), 1)
	# patches
	c.begin(); c.round_rect(-r * .75, -r * .4, r * .32, r * .26, 2); c.sh("#b8a070", Color(OUT, .6), 1)
	c.begin(); c.move_to(-r * .72, -r * .34); c.line_to(-r * .48, -r * .2); c.stroke(Color(OUT, .5), .8)
	c.ell(-r * .5, -r * .45, r * .3, r * .12, -.2); c.fill(Color(1, 1, 1, .3))
	# the Snatchers' emblem: a grabbing claw
	c.ell(r * .3, -r * .05, r * .3, r * .3); c.fs("#f4e3b0", OUT, 1.4)
	c.begin(); c.move_to(r * .3, -r * .25); c.line_to(r * .3, -r * .02); c.stroke(OUT, 1.6, true)
	for s: int in [-1, 1]:
		c.begin(); c.move_to(r * .3, -r * .02); c.quad_to(r * (.3 + s * .16), r * .02, r * (.3 + s * .12), r * .16); c.stroke(OUT, 1.6, true)
	# propeller
	c.begin(); c.move_to(-r * 1.15, 0); c.line_to(-r * 1.3, 0); c.stroke("#3a3a40", 2)
	c.ell(-r * 1.32, 0, 2, r * .3); c.fill(Color(.2, .2, .25, .6))


static func coin(c: CanvasItem, x: float, y: float, r: float, ph: float, a := 1.0) -> void:
	var sx := maxf(.15, absf(cos(ph)))
	c.draw_set_transform(Vector2(x, y), 0, Vector2(sx, 1))
	var pts := PackedVector2Array()
	for i in 16:
		var ang := TAU * i / 16.0
		pts.append(Vector2(cos(ang) * r, sin(ang) * r * 1.2))
	c.draw_colored_polygon(pts, Color(1, .81, .2, a))
	pts.append(pts[0])
	c.draw_polyline(pts, Color(.66, .48, .07, a), 1.2, true)
	c.draw_rect(Rect2(-r * .5, -r * .6, r * .25, r * .5), Color(1, 1, 1, .6 * a))
	c.draw_set_transform_matrix(Transform2D.IDENTITY)
