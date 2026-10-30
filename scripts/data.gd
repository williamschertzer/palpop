class_name Data
extends RefCounted
## Game data: orb tiers, critter towers and their upgrades, maps and waves.
## Numbers match the web version (index.html) so balance is the same.

const W := 960.0
const H := 600.0

const BALLS := {
	"red":   {"name": "Red Orb",  "tier": 0, "spd": 1.00, "hp": 1, "kids": [], "r": 11.0, "top": "#e0483a", "note": "The basic orb."},
	"blue":  {"name": "Blue Orb", "tier": 1, "spd": 1.35, "hp": 1, "kids": ["red"], "r": 11.5, "top": "#3a7ae0", "note": "Faster. Pops into a Red Orb."},
	"gold":  {"name": "Gold Orb", "tier": 2, "spd": 1.75, "hp": 1, "kids": ["blue"], "r": 12.0, "top": "#e8b030", "note": "Pops into a Blue Orb."},
	"dart":  {"name": "Dart Orb", "tier": 3, "spd": 2.8,  "hp": 1, "kids": ["gold"], "r": 12.0, "top": "#38c0e0", "note": "Very fast. Pops into a Gold Orb."},
	"clock":  {"name": "Clock Orb", "tier": 3, "spd": 1.0,  "hp": 1, "kids": ["gold"], "r": 12.0, "top": "#c8c4b8", "accel": true, "note": "Starts slow and speeds up the longer it rolls."},
	"mesh":    {"name": "Mesh Orb",   "tier": 4, "spd": 1.25, "hp": 2, "kids": ["gold", "gold"], "r": 12.5, "top": "#2fa6b4", "note": "Takes 2 hits. Water does half damage, Electric and Grass double."},
	"mend":   {"name": "Mending Orb",  "tier": 4, "spd": 1.15, "hp": 4, "kids": ["blue", "blue"], "r": 12.5, "top": "#f28ab4", "regen": true, "note": "Takes 4 hits and heals itself if you stop hitting it."},
	"shade":   {"name": "Shade Orb",  "tier": 4, "spd": 1.80, "hp": 1, "kids": ["dart", "dart"], "r": 12.5, "top": "#1f3d2a", "hidden": true, "note": "Hidden. Only ghosts, a Zapkit with a Lightning Rod and a Magmoloss can see it."},
	"iron":  {"name": "Iron Orb", "tier": 5, "spd": 0.95, "hp": 3, "kids": ["dart", "dart"], "r": 13.5, "top": "#8f9aaa", "armored": true, "note": "Takes 3 hits and shrugs off Electric attacks."},
	"titan": {"name": "Titan Orb", "tier": 6, "spd": 0.55, "hp": 400, "kids": ["iron", "iron", "shade", "shade"], "r": 24.0, "top": "#7b3fb4", "boss": true, "note": "Huge health. Immune to sleep."},
	"blimp": {"name": "Snatcher Blimp", "tier": 7, "spd": 0.38, "hp": 1500, "kids": ["titan", "titan"], "r": 30.0, "top": "#8a8f9a", "boss": true, "note": "The Snatchers' airship. Pops into two Titan Orbs."},
}
const ORDER := ["red", "blue", "gold", "dart", "clock", "mesh", "mend", "shade", "iron", "titan", "blimp"]

## Type matchups: damage multipliers for an attack type against an orb.
const TYPE_EFFECT := {
	"Fighting": {"iron": 2.0},
	"Rock": {"iron": 1.5},
	"Electric": {"mesh": 2.0},
	"Grass": {"mesh": 2.0},
	"Water": {"mesh": 0.5},
	"Dragon": {"titan": 1.5, "blimp": 1.5},
}

## Easy / Normal / Hard: starting money, Nest HP and orb speed.
const DIFFS := {
	"easy": {"name": "Easy", "cash": 1.3, "lives": 1.5, "speed": .9},
	"normal": {"name": "Normal", "cash": 1.0, "lives": 1.0, "speed": 1.0},
	"hard": {"name": "Hard", "cash": .85, "lives": .6, "speed": 1.12},
}

## Items bought from the side panel. The Tonic gets pricier each use in a game.
const ITEMS := {
	"tonic": {"short": "Tonic", "name": "Tonic", "cost": 250, "step": 150, "desc": "Restores 25 Nest HP."},
	"mist": {"short": "Mist", "name": "Sticky Mist", "cost": 400, "step": 0, "desc": "Every orb moves at half speed for 5 seconds. Use it during a wave."},
	"acorn": {"short": "Acorn", "name": "Gold Acorn", "cost": 300, "step": 0, "desc": "Your next upgrade costs 30% less."},
}

## New critters unlock by reaching a wave on enough different maps, on Normal
## or harder ("diff": "hard" means Hard only). Easy runs never unlock anything.
## A plain number means {"wave": n}.
const UNLOCK := {
	"puddlesnail": {"wave": 15},
	"galefinch": {"wave": 25},
	"pebbit": {"wave": 40},
	"knuckaroo": {"wave": 40, "maps": 2},
	"frostray": {"wave": 40, "diff": "hard"},
	"hootling": {"wave": 40, "maps": 3},
	"slumbear": {"wave": 40, "maps": 4},
	"wyrmlet": {"wave": 40, "maps": 3, "diff": "hard"},
	"bunbalm": {"wave": 20},
	"prismkit": {"wave": 40, "maps": 2},
	"mimoth": {"wave": 40, "maps": 2, "diff": "hard"},
}
const DIFF_RANK := {"easy": 0, "normal": 1, "hard": 2}


static func unlock_req(kind: String) -> Dictionary:
	var r = UNLOCK[kind]
	if r is int:
		r = {"wave": r}
	return {"wave": int(r.wave), "maps": int(r.get("maps", 1)), "diff": r.get("diff", "normal")}


## How many different maps already meet this critter's unlock goal.
static func unlock_progress(kind: String, best: Dictionary) -> int:
	var r := unlock_req(kind)
	var maps := {}
	for key in best:
		var parts: PackedStringArray = String(key).split(":")
		var diff: String = parts[1] if parts.size() > 1 else "normal"
		if DIFF_RANK.get(diff, 0) >= DIFF_RANK[r.diff] and int(best[key]) >= r.wave:
			maps[parts[0]] = true
	return maps.size()


static func is_unlocked(kind: String, best: Dictionary) -> bool:
	return not UNLOCK.has(kind) or unlock_progress(kind, best) >= unlock_req(kind).maps


## "Beat 2 maps on Hard", "Reach wave 25 on any map" and so on.
static func unlock_text(kind: String) -> String:
	var r := unlock_req(kind)
	var on: String = " on Hard" if r.diff == "hard" else " on Normal or Hard"
	var goal: String = ("Beat " if r.wave >= 40 else "Reach wave %d on " % r.wave)
	var where: String = ("any map" if r.wave < 40 else "a map") if r.maps == 1 else "%d different maps" % r.maps
	return goal + where + on


## A few characters for the Party button.
static func unlock_short(kind: String) -> String:
	var r := unlock_req(kind)
	if r.wave < 40:
		return "Wave %d" % r.wave
	return ("Hard ×%d" if r.diff == "hard" else "Win ×%d") % r.maps

## Prismkit and its three growth forms share their starting stats and second path.
const PRISM_BASE := {"range": 115, "rate": 0.8, "dmg": 1, "targets": 2, "soak": false, "muddy": 0, "muddyDmg": 4, "volt": 0, "burn": 0, "burnMul": 1, "area": 0, "resort": 0, "detect": false}
const PRISM_B := [
	{"name": "Quick Dash", "cost": 300, "desc": "Attacks 25% faster.", "fx": [["*", "rate", 0.75]]},
	{"name": "Prism Spark", "cost": 700, "desc": "Hits 1 more orb and spots Shade Orbs.", "fx": [["+", "targets", 1], ["=", "detect", true]]},
	{"name": "Final Flash", "cost": 2600, "desc": "Every 5s, hits the toughest orb in range for 25.", "fx": [["=", "resort", 5]]}]

## Upgrade effects are lists of [op, stat, value]: "+" adds, "*" multiplies, "=" sets.
const TOWERS := {
	"zapkit": {"name": "Zapkit", "role": "Chain lightning", "type": "Electric", "cost": 250,
		"blurb": "Fast static zaps that chain to nearby orbs. Iron Orbs ignore Electric attacks.",
		"base": {"range": 120, "rate": 0.6, "dmg": 1, "chain": 1, "detect": false},
		"A": [
			{"name": "Grow: Stormstoat", "cost": 500, "desc": "+1 damage, +15 range, chains to 1 more orb.", "fx": [["+", "dmg", 1], ["+", "range", 15], ["+", "chain", 1]]},
			{"name": "Lightning Rod", "cost": 900, "desc": "Attacks 40% faster and can see Shade Orbs.", "fx": [["*", "rate", 0.6], ["=", "detect", true]]},
			{"name": "Ascend: Tempest Stoat", "cost": 4200, "desc": "Tempest Crash every 7s hits every orb on the map for 3.", "fx": [["=", "tempest", 7]]}],
		"B": [
			{"name": "Quick Dash", "cost": 300, "desc": "Attacks 30% faster.", "fx": [["*", "rate", 0.7]]},
			{"name": "Arc Bolt", "cost": 750, "desc": "+1 damage and chains to 2 more orbs.", "fx": [["+", "dmg", 1], ["+", "chain", 2]]},
			{"name": "Thunderhead", "cost": 2600, "desc": "Every 3rd attack is a Thunderhead strike: 8 damage in an area, even to Iron Orbs.", "fx": [["=", "thunder", true]]}]},
	"cindermole": {"name": "Cindermole", "role": "Crowd burner", "type": "Fire", "cost": 375,
		"blurb": "Short-range flame bursts that scorch a whole cluster of orbs.",
		"base": {"range": 88, "rate": 1.0, "dmg": 1, "pierce": 5, "cone": 0.5, "burn": 0, "burnMul": 1, "detect": false},
		"A": [
			{"name": "Grow: Kilnmole", "cost": 550, "desc": "+1 damage, +10 range, flames hit 4 more orbs.", "fx": [["+", "dmg", 1], ["+", "range", 10], ["+", "pierce", 4]]},
			{"name": "Grow: Magmoloss", "cost": 1600, "desc": "+25 range, wider flames, hits 6 more. Its heat haze shows Shade Orbs.", "fx": [["+", "range", 25], ["+", "pierce", 6], ["=", "cone", 0.8], ["=", "detect", true]]},
			{"name": "Ascend: Magmoloss", "cost": 5000, "desc": "+3 damage, 40% faster, burns do double damage.", "fx": [["+", "dmg", 3], ["*", "rate", 0.6], ["=", "burnMul", 2]]}],
		"B": [
			{"name": "Fire Jet", "cost": 400, "desc": "+20 range and flames hit 3 more orbs.", "fx": [["+", "range", 20], ["+", "pierce", 3]]},
			{"name": "Cinder Cloud", "cost": 900, "desc": "Burns orbs for 1 damage every 0.75s, 4 times.", "fx": [["=", "burn", 4]]},
			{"name": "Eruption", "cost": 3500, "desc": "Every 6s, a blast deals 10 damage to everything within 150.", "fx": [["=", "blast", 6]]}]},
	"spoutling": {"name": "Spoutling", "role": "Pusher", "type": "Water", "cost": 325,
		"blurb": "Water jets knock orbs back down the path.",
		"base": {"range": 110, "rate": 0.85, "dmg": 1, "jets": 1, "push": 10, "bubble": false, "detect": false},
		"A": [
			{"name": "Grow: Spoutseal", "cost": 450, "desc": "+1 damage and pushes orbs back twice as far.", "fx": [["+", "dmg", 1], ["+", "push", 10]]},
			{"name": "Grow: Geyserwal", "cost": 1400, "desc": "Geyser tusks fire at 2 orbs at once. +20 range.", "fx": [["=", "jets", 2], ["+", "range", 20]]},
			{"name": "Ascend: Geyserwal", "cost": 4500, "desc": "Triple geysers fire 3 jets, +2 damage, 30% faster.", "fx": [["=", "jets", 3], ["+", "dmg", 2], ["*", "rate", 0.7]]}],
		"B": [
			{"name": "Bubble Spray", "cost": 350, "desc": "Soaked orbs move 40% slower for 1.5s.", "fx": [["=", "bubble", true]]},
			{"name": "Cool Shades", "cost": 700, "desc": "+25 range and spots Shade Orbs. Also looks very cool.", "fx": [["+", "range", 25], ["=", "detect", true]]},
			{"name": "Tidal Burst", "cost": 3000, "desc": "Every 5s, a huge blast deals 8 damage to every orb in range and pushes them back.", "fx": [["=", "hydro", 5]]}]},
	"thornhog": {"name": "Thornhog", "role": "Line slicer", "type": "Grass", "cost": 350,
		"blurb": "Throws spinning leaf quills that slice through a line of orbs.",
		"base": {"range": 115, "rate": 1.1, "dmg": 1, "leaves": 2, "pierce": 2, "detect": false},
		"A": [
			{"name": "Grow: Bramblehog", "cost": 500, "desc": "+1 damage and throws 3 leaves.", "fx": [["+", "dmg", 1], ["=", "leaves", 3]]},
			{"name": "Grow: Grovehog", "cost": 1500, "desc": "Throws 5 leaves that each slice 1 more orb. +15 range.", "fx": [["=", "leaves", 5], ["+", "pierce", 1], ["+", "range", 15]]},
			{"name": "Ascend: Grovehog", "cost": 4800, "desc": "+2 damage. Leaf Storm hits every orb in range for 4 every 4s.", "fx": [["+", "dmg", 2], ["=", "blizzard", 4]]}],
		"B": [
			{"name": "Sap Seed", "cost": 400, "desc": "Seeded orbs take 1 damage a second for 4s, and each drain earns $1.", "fx": [["=", "seed", true]]},
			{"name": "Drowsy Pollen", "cost": 900, "desc": "Every 5s, puts every orb in range to sleep for 1.2s. Titan Orbs resist.", "fx": [["=", "powder", 5]]},
			{"name": "Sunbeam", "cost": 3200, "desc": "Every 4s, fires a beam across the whole map, aimed to hit as many orbs as possible. 12 damage to every orb it touches.", "fx": [["=", "solar", 4]]}]},
	"lanternwisp": {"name": "Lanternwisp", "role": "Hidden-orb finder", "type": "Ghost", "cost": 450,
		"blurb": "Spirit flames explode on impact. Ghosts see hidden Shade Orbs.",
		"base": {"range": 132, "rate": 1.3, "dmg": 1, "radius": 32, "detect": true, "sleep": 0, "dream": 0, "pspeed": 420},
		"A": [
			{"name": "Grow: Lanternshade", "cost": 600, "desc": "+1 damage, bigger blasts, 15% faster.", "fx": [["+", "dmg", 1], ["+", "radius", 10], ["*", "rate", 0.85]]},
			{"name": "Grow: Lanternlord", "cost": 1500, "desc": "+2 damage, even bigger blasts, +20 range.", "fx": [["+", "dmg", 2], ["+", "radius", 12], ["+", "range", 20]]},
			{"name": "Ascend: Lantern Wraith", "cost": 4800, "desc": "+3 damage, 30% faster. Its gloom slows every orb in range by half.", "fx": [["+", "dmg", 3], ["*", "rate", 0.7], ["=", "tag", true]]}],
		"B": [
			{"name": "Lull", "cost": 350, "desc": "Orbs hit fall asleep for 0.8s. Titan Orbs never sleep.", "fx": [["=", "sleep", 0.8]]},
			{"name": "Dream Feast", "cost": 800, "desc": "+2 damage to sleeping orbs and $1 extra per pop.", "fx": [["=", "dream", 2]]},
			{"name": "Night Terror", "cost": 2800, "desc": "Sleep lasts 1.4s. Sleeping orbs in range take 2 damage every 0.5s.", "fx": [["=", "sleep", 1.4], ["=", "nightmare", true]]}]},
	"coinpie": {"name": "Coinpie", "role": "Money maker", "type": "Normal", "cost": 400,
		"blurb": "Used to work for the Snatchers. It collects coins at the end of every wave, and it pecks orbs that get close.",
		"base": {"range": 72, "rate": 0.7, "dmg": 1, "swipes": 1, "pay": 40, "detect": false},
		"A": [
			{"name": "Grow: Goldpie", "cost": 700, "desc": "+1 damage. Collects $80 a wave.", "fx": [["+", "dmg", 1], ["=", "pay", 80]]},
			{"name": "Lucky Charm", "cost": 1500, "desc": "Doubles its coins to $160 a wave.", "fx": [["*", "pay", 2]]},
			{"name": "Gold Rush", "cost": 5000, "desc": "+$40 a wave. Every 6s, coins rain on up to 30 orbs for 4 damage each, and every coin that lands pays $1.", "fx": [["=", "goldRush", 6], ["+", "pay", 40]]}],
		"B": [
			{"name": "Flurry Pecks", "cost": 300, "desc": "Pecks up to 3 orbs per attack.", "fx": [["=", "swipes", 3]]},
			{"name": "Sharp Beak", "cost": 750, "desc": "+2 damage, 35% faster, +15 range.", "fx": [["+", "dmg", 2], ["*", "rate", 0.65], ["+", "range", 15]]},
			{"name": "Thief", "cost": 2200, "desc": "Old habits. Every orb Coinpie pops pays $3 extra.", "fx": [["=", "thief", true]]}]},
	"wobblob": {"name": "Wobblob", "role": "Slows and counters", "type": "Psychic", "cost": 200, "pathNames": ["Abilities", "Counters"],
		"blurb": "Never attacks. It just keeps bonking itself. Its upgrades make that useful.",
		"base": {"range": 95, "rate": 0, "dmg": 0, "confuse": 3, "counter": 0, "bossMul": 1, "detect": true},
		"A": [
			{"name": "Sticky Goo", "cost": 350, "desc": "Orbs in range move 35% slower.", "fx": [["=", "shadowTag", 0.65]]},
			{"name": "Stare Down", "cost": 800, "desc": "Orbs in range move 55% slower, and Shade Orbs near it become visible to every critter around.", "fx": [["=", "shadowTag", 0.45], ["=", "reveal", true]]},
			{"name": "Rewind", "cost": 2500, "desc": "Every 8s, sends every orb in range 150 steps back down the path.", "fx": [["=", "encore", 8]]}],
		"B": [
			{"name": "Rebound", "cost": 400, "desc": "Each time it hurts itself, a shockwave deals 2 damage to orbs in range.", "fx": [["=", "counter", 2]]},
			{"name": "Mirror Jelly", "cost": 1000, "desc": "Shockwaves deal 5, and it gets confused every 2s.", "fx": [["=", "counter", 5], ["=", "confuse", 2]]},
			{"name": "Big Comeback", "cost": 3000, "desc": "Shockwaves deal 12, and triple damage to Titan Orbs and the blimp.", "fx": [["=", "counter", 12], ["=", "bossMul", 3]]}]},
	"astralion": {"name": "Astralion", "role": "Legendary powerhouse", "type": "Psychic", "cost": 3000,
		"blurb": "Expensive and extremely strong. Psychic blasts hit 3 orbs at once, including hidden and Heavy ones.",
		"base": {"range": 170, "rate": 0.5, "dmg": 3, "targets": 3, "bossMul": 1, "detect": true},
		"A": [
			{"name": "Mind Link", "cost": 1200, "desc": "+30 range and 20% faster.", "fx": [["+", "range", 30], ["*", "rate", 0.8]]},
			{"name": "Star Armor", "cost": 3500, "desc": "+3 damage and triple damage to Titan Orbs and the blimp.", "fx": [["+", "dmg", 3], ["=", "bossMul", 3]]},
			{"name": "Ascend: Nova Astralion", "cost": 9000, "desc": "Attacks twice as fast and hits 3 more orbs.", "fx": [["*", "rate", 0.5], ["+", "targets", 3]]}],
		"B": [
			{"name": "Mind Blast", "cost": 1500, "desc": "+1 damage and hits 2 more orbs.", "fx": [["+", "dmg", 1], ["+", "targets", 2]]},
			{"name": "Starfall", "cost": 4000, "desc": "Every 5s, deals 10 damage to every orb in range.", "fx": [["=", "starfall", 5]]},
			{"name": "Foresight Strike", "cost": 7500, "desc": "Every 6s, marks the strongest orb on the map. 2s later it takes 150 damage.", "fx": [["=", "future", 6]]}]},
	"puddlesnail": {"name": "Puddlesnail", "type": "Water", "cost": 150, "role": "Joke that pays off",
		"blurb": "It just sits there thinking about it. Grow it into a Krakenshell and it becomes a monster.",
		"base": {"range": 90, "rate": 1.5, "dmg": 0, "area": 0, "splash": true, "detect": false},
		"A": [
			{"name": "Grow: Krakenshell", "cost": 800, "desc": "Huge water blasts: 3 damage to every orb near the target.", "fx": [["+", "dmg", 3], ["=", "range", 140], ["=", "rate", 0.75], ["=", "area", 40], ["=", "splash", false]]},
			{"name": "Menace", "cost": 1100, "desc": "Orbs in range move 30% slower.", "fx": [["=", "shadowTag", 0.7]]},
			{"name": "Ascend: Krakenshell", "cost": 4500, "desc": "+3 damage, 30% faster, bigger blasts, and sees Shade Orbs.", "fx": [["+", "dmg", 3], ["*", "rate", 0.7], ["+", "area", 20], ["=", "detect", true]]}],
		"B": [
			{"name": "Nudge", "cost": 100, "desc": "Finally does 1 damage.", "fx": [["+", "dmg", 1], ["=", "splash", false]]},
			{"name": "Desperation", "cost": 600, "desc": "Up to +4 damage the lower the Nest's HP is.", "fx": [["=", "flail", true]]},
			{"name": "Belly Flop", "cost": 2200, "desc": "Every 4s, lands on the toughest orb in range for 20 damage, and 6 to orbs next to it.", "fx": [["=", "bounce", 4]]}]},
	"galefinch": {"name": "Galefinch", "type": "Flying", "cost": 300, "role": "Long-range sniper",
		"blurb": "Gusts of wind from very far away. Great for covering a long stretch of path.",
		"base": {"range": 230, "rate": 1.1, "dmg": 2, "pierce": 1, "push": 0, "brave": 0, "hurricane": 0, "detect": false},
		"A": [
			{"name": "Grow: Galehawk", "cost": 450, "desc": "+40 range and sharp eyes that spot Shade Orbs.", "fx": [["+", "range", 40], ["=", "detect", true]]},
			{"name": "Grow: Galeroc", "cost": 1300, "desc": "+1 damage, and each gust slices through 3 orbs.", "fx": [["+", "dmg", 1], ["=", "pierce", 3]]},
			{"name": "Ascend: Galeroc", "cost": 4400, "desc": "+1 damage. Every 5s, a Cyclone hits every orb in range for 6 and blows them back.", "fx": [["+", "dmg", 1], ["=", "hurricane", 5]]}],
		"B": [
			{"name": "Gust", "cost": 300, "desc": "Each hit knocks the orb back a little.", "fx": [["=", "push", 12]]},
			{"name": "Tailwind", "cost": 800, "desc": "Attacks 45% faster.", "fx": [["*", "rate", 0.55]]},
			{"name": "Dive Bomb", "cost": 2800, "desc": "Every 3rd attack is a dive for 30 damage.", "fx": [["=", "brave", 30]]}]},
	"pebbit": {"name": "Pebbit", "type": "Rock", "cost": 400, "role": "Path trapper",
		"blurb": "Drops rocks on the path. Orbs that roll over a rock take damage until it crumbles.",
		"base": {"range": 110, "rate": 1.8, "dmg": 1, "rocks": 1, "rockUses": 5, "throw": 0, "quake": 0, "explode": 0, "armorBreak": false, "detect": true},
		"A": [
			{"name": "Grow: Bouldillo", "cost": 550, "desc": "Drops 2 rocks at a time, and they last longer.", "fx": [["=", "rocks", 2], ["+", "rockUses", 2]]},
			{"name": "Grow: Mountadillo", "cost": 1500, "desc": "+2 damage, and rocks crack Iron Orb armour so Electric attacks work on them.", "fx": [["+", "dmg", 2], ["=", "armorBreak", true]]},
			{"name": "Rockburst", "cost": 4000, "desc": "Every 8s, all its rocks blow up for 10 damage around them.", "fx": [["=", "explode", 8]]}],
		"B": [
			{"name": "Stone Toss", "cost": 400, "desc": "Also throws a rock at an orb for 2 damage.", "fx": [["=", "throw", 2]]},
			{"name": "Hidden Spikes", "cost": 900, "desc": "+1 damage and rocks last 6 orbs longer.", "fx": [["+", "dmg", 1], ["+", "rockUses", 6]]},
			{"name": "Tremor", "cost": 2800, "desc": "Every 6s, 8 damage to every orb in a wide area.", "fx": [["=", "quake", 6]]}]},
	"knuckaroo": {"name": "Knuckaroo", "type": "Fighting", "cost": 425, "role": "Armour breaker",
		"blurb": "Close-range punches. Double damage to Iron Orbs, and knocks their armour off so Electric attacks work.",
		"base": {"range": 90, "rate": 0.7, "dmg": 2, "targets": 1, "push": 0, "chi": 0, "armorBreak": true, "detect": false},
		"A": [
			{"name": "Grow: Brawlaroo", "cost": 550, "desc": "+1 damage and +10 range.", "fx": [["+", "dmg", 1], ["+", "range", 10]]},
			{"name": "Grow: Champaroo", "cost": 1500, "desc": "+1 damage. Its two joeys pop out to help: punches 4 orbs at once.", "fx": [["+", "dmg", 1], ["=", "targets", 4]]},
			{"name": "Ascend: Titan Champaroo", "cost": 4600, "desc": "+2 damage. Every 10s, nearby critters attack twice as fast for 4s.", "fx": [["+", "dmg", 2], ["=", "chi", 10]]}],
		"B": [
			{"name": "Jab", "cost": 350, "desc": "Attacks 25% faster.", "fx": [["*", "rate", 0.75]]},
			{"name": "Haymaker", "cost": 900, "desc": "+2 damage.", "fx": [["+", "dmg", 2]]},
			{"name": "Uppercut", "cost": 2500, "desc": "+2 damage, and punched orbs fly back down the path.", "fx": [["+", "dmg", 2], ["=", "push", 35]]}]},
	"hootling": {"name": "Hootling", "type": "Psychic", "cost": 500, "role": "Supporter",
		"blurb": "Barely attacks. Instead it makes the critter around it stronger.",
		"base": {"range": 120, "rate": 1.4, "dmg": 1, "auraRate": 1.0, "auraDmg": 0, "auraRange": 1.0, "auraDetect": false, "trick": 0, "detect": true},
		"A": [
			{"name": "Grow: Hootsage", "cost": 600, "desc": "Critters in its range attack 15% faster.", "fx": [["=", "auraRate", 1.15]]},
			{"name": "Grow: Hootarch", "cost": 1800, "desc": "Critters in its range also deal +1 damage.", "fx": [["=", "auraDmg", 1]]},
			{"name": "Ascend: Elder Hootarch", "cost": 5000, "desc": "Critters in its range attack 30% faster, get 15% more range and see Shade Orbs.", "fx": [["=", "auraRate", 1.3], ["=", "auraRange", 1.15], ["=", "auraDetect", true]]}],
		"B": [
			{"name": "Focus", "cost": 400, "desc": "Its own attack is twice as fast and +1 damage.", "fx": [["*", "rate", 0.5], ["+", "dmg", 1]]},
			{"name": "Hush Field", "cost": 900, "desc": "Orbs in range move 30% slower.", "fx": [["=", "shadowTag", 0.7]]},
			{"name": "Time Warp", "cost": 3000, "desc": "Every 10s, every orb on the map moves at half speed for 3s.", "fx": [["=", "trick", 10]]}]},
	"frostray": {"name": "Frostray", "type": "Ice", "cost": 600, "role": "Freezer",
		"blurb": "Icy blasts freeze a small group of orbs solid for a moment. Big orbs thaw faster.",
		"base": {"range": 125, "rate": 0.9, "dmg": 1, "freeze": .5, "area": 30, "gfreeze": 0, "surf": 0, "brittle": false, "cold": 0, "detect": false},
		"A": [
			{"name": "Frost Beam", "cost": 500, "desc": "+1 damage and freezes for twice as long.", "fx": [["+", "dmg", 1], ["=", "freeze", 1.0]]},
			{"name": "Snow Squall", "cost": 1400, "desc": "+1 damage and freezes a much wider area around the target.", "fx": [["=", "area", 65], ["+", "dmg", 1]]},
			{"name": "Ascend: Glacier Frostray", "cost": 5200, "desc": "Every 12s, freezes every orb on the map for 2s.", "fx": [["=", "gfreeze", 12]]}],
		"B": [
			{"name": "Wave Ride", "cost": 500, "desc": "Every 5s, a wave hits orbs in range for 2 and pushes them back.", "fx": [["=", "surf", 5]]},
			{"name": "Brittle Frost", "cost": 1100, "desc": "Frozen orbs take +2 damage from every attack.", "fx": [["=", "brittle", true]]},
			{"name": "Deep Freeze", "cost": 3200, "desc": "Every 8s, instantly pops the toughest normal orb in range, all its layers at once.", "fx": [["=", "cold", 8]]}]},
	"slumbear": {"name": "Slumbear", "type": "Normal", "cost": 800, "role": "Roadblock", "onPath": true,
		"blurb": "Goes ON the path and blocks it. Orbs pile up until they push it aside, then it naps and comes back.",
		"base": {"range": 55, "hold": 30, "recover": 6, "slam": 0, "slamDmg": 2, "yawn": 0, "detect": true},
		"A": [
			{"name": "Thick Fur", "cost": 600, "desc": "Holds back orbs more than twice as long.", "fx": [["=", "hold", 70]]},
			{"name": "Power Nap", "cost": 1200, "desc": "Wakes back up in 3s instead of 6.", "fx": [["=", "recover", 3]]},
			{"name": "Ascend: Mountain Slumbear", "cost": 5000, "desc": "Holds 3 times longer still, and orbs near it move 40% slower.", "fx": [["=", "hold", 200], ["=", "shadowTag", 0.6], ["=", "range", 80]]}],
		"B": [
			{"name": "Belly Bump", "cost": 500, "desc": "Every 1.2s, 2 damage to every orb next to it.", "fx": [["=", "slam", 1.2]]},
			{"name": "Yawn", "cost": 900, "desc": "Every 3s, orbs next to it fall asleep for 1s.", "fx": [["=", "yawn", 3]]},
			{"name": "Big Breakfast", "cost": 2600, "desc": "Belly Bump does triple damage.", "fx": [["=", "slamDmg", 6]]}]},
	"wyrmlet": {"name": "Wyrmlet", "type": "Dragon", "cost": 750, "role": "Boss hunter",
		"blurb": "Cloud breath that hits Titan Orbs and the Snatcher Blimp twice as hard.",
		"base": {"range": 140, "rate": 0.8, "dmg": 3, "bossMul": 2, "rage": 0, "dance": false, "outrage": 0, "hyper": 0, "detect": false},
		"A": [
			{"name": "Grow: Cloudwyrm", "cost": 700, "desc": "+2 damage and +20 range.", "fx": [["+", "dmg", 2], ["+", "range", 20]]},
			{"name": "Grow: Skywyrm", "cost": 2000, "desc": "+2 damage, +30 range, and flies high enough to see Shade Orbs.", "fx": [["+", "dmg", 2], ["+", "range", 30], ["=", "detect", true]]},
			{"name": "Frenzy", "cost": 5500, "desc": "Every 15s, attacks 3 times as fast for 5s.", "fx": [["=", "outrage", 15]]}],
		"B": [
			{"name": "Wyrm Fury", "cost": 800, "desc": "Every hit on a Titan Orb or the blimp deals 20 extra.", "fx": [["=", "rage", 20]]},
			{"name": "Sky Dance", "cost": 1500, "desc": "Attacks 10% faster for every wave it survives, up to 60%.", "fx": [["=", "dance", true]]},
			{"name": "Wyrm Beam", "cost": 4200, "desc": "Every 6s, a beam through the toughest orb deals 30 to everything in its line.", "fx": [["=", "hyper", 6]]}]},
	"prismkit": {"name": "Prismkit", "type": "Normal", "cost": 450, "role": "Evolves your way", "branches": ["tidefox", "sparkfox", "blazefox"],
		"blurb": "Prism sparks hit 2 orbs at once. Its first growth is your choice: Tidefox, Sparkfox or Blazefox.",
		"base": PRISM_BASE,
		"A": [
			{"name": "Grow: your choice", "cost": 650, "desc": "Pick Tidefox, Sparkfox or Blazefox. Each one plays differently.", "fx": []},
			{"name": "Second growth move", "cost": 1500, "desc": "Depends on which form you picked.", "fx": []},
			{"name": "Final growth move", "cost": 4700, "desc": "Depends on which form you picked.", "fx": []}],
		"B": PRISM_B},
	"tidefox": {"name": "Tidefox", "type": "Water", "cost": 450, "role": "Soaks and washes back", "evolvesFrom": "prismkit",
		"blurb": "Water sparks soak orbs so they roll slower, and Mud Wave washes them back.",
		"base": PRISM_BASE,
		"A": [
			{"name": "Grow: Tidefox", "cost": 650, "desc": "Water type. +1 damage, and orbs hit move 40% slower for 1.5s.", "fx": [["+", "dmg", 1], ["=", "soak", true]]},
			{"name": "Mud Wave", "cost": 1500, "desc": "Every 4s, a wave hits every orb in range for 4 and pushes them back.", "fx": [["=", "muddy", 4]]},
			{"name": "Steam Surge", "cost": 4600, "desc": "+2 damage, hits 2 more orbs, and Mud Wave hits for 8 more.", "fx": [["+", "dmg", 2], ["+", "targets", 2], ["+", "muddyDmg", 8]]}],
		"B": PRISM_B},
	"sparkfox": {"name": "Sparkfox", "type": "Electric", "cost": 450, "role": "Rapid fire", "evolvesFrom": "prismkit",
		"blurb": "Needle-fast Electric attacks. Iron Orbs ignore Electric unless their armour is knocked off.",
		"base": PRISM_BASE,
		"A": [
			{"name": "Grow: Sparkfox", "cost": 650, "desc": "Electric type. Attacks twice as fast, but can't hurt Iron Orbs.", "fx": [["*", "rate", 0.5]]},
			{"name": "Needle Storm", "cost": 1400, "desc": "Each attack hits 3 more orbs.", "fx": [["+", "targets", 3]]},
			{"name": "Storm Fang", "cost": 4800, "desc": "+2 damage. Every 6s, a bolt hits every orb in range for 8, even Iron Orbs.", "fx": [["+", "dmg", 2], ["=", "volt", 6]]}],
		"B": PRISM_B},
	"blazefox": {"name": "Blazefox", "type": "Fire", "cost": 450, "role": "Big hits and burns", "evolvesFrom": "prismkit",
		"blurb": "Hard-hitting fire that burns, and later splashes onto orbs next to the target.",
		"base": PRISM_BASE,
		"A": [
			{"name": "Grow: Blazefox", "cost": 650, "desc": "Fire type. +2 damage, and hits burn for 1 damage 3 times.", "fx": [["+", "dmg", 2], ["=", "burn", 3]]},
			{"name": "Lava Splash", "cost": 1500, "desc": "Each hit also scorches orbs next to the target.", "fx": [["+", "area", 35]]},
			{"name": "Blaze Rush", "cost": 4800, "desc": "+3 damage, and burns do double damage.", "fx": [["+", "dmg", 3], ["*", "burnMul", 2]]}],
		"B": PRISM_B},
	"mimoth": {"name": "Mimoth", "type": "Normal", "cost": 400, "role": "Copycat", "pathNames": ["Mimic", "Mirror"],
		"blurb": "Copies the closest critter in its range and fights like it. Its upgrades let it copy that critter's upgrades too. Can't copy Astralion, Slumbear, Hootling or Bunbalm.",
		"base": {"range": 120, "rate": 1.2, "dmg": 1, "copyA": 0, "copyB": 0, "detect": false},
		"A": [
			{"name": "Mimic", "cost": 500, "desc": "Also copies the first upgrade on the other critter's first path, once it has it.", "fx": [["+", "copyA", 1]]},
			{"name": "Mimic II", "cost": 1500, "desc": "Copies up to 2 upgrades on the first path.", "fx": [["+", "copyA", 1]]},
			{"name": "Perfect Copy", "cost": 4200, "desc": "Copies all 3 upgrades on the first path.", "fx": [["+", "copyA", 1]]}],
		"B": [
			{"name": "Mirror", "cost": 500, "desc": "Also copies the first upgrade on the other critter's second path, once it has it.", "fx": [["+", "copyB", 1]]},
			{"name": "Mirror II", "cost": 1500, "desc": "Copies up to 2 upgrades on the second path.", "fx": [["+", "copyB", 1]]},
			{"name": "Mirror Image", "cost": 4200, "desc": "Copies all 3 upgrades on the second path.", "fx": [["+", "copyB", 1]]}]},
	"bunbalm": {"name": "Bunbalm", "type": "Normal", "cost": 550, "role": "Healer",
		"blurb": "Herbal Remedy heals the Nest after every wave, and it throws seed pods at orbs that come close.",
		"base": {"range": 100, "rate": 1.3, "dmg": 1, "heal": 3, "podArea": 0, "safeguard": 0, "toss": 0, "lucky": false, "detect": false},
		"A": [
			{"name": "Grow: Grand Bunbalm", "cost": 900, "desc": "+1 damage, and heals 5 more HP after every wave.", "fx": [["+", "dmg", 1], ["+", "heal", 5]]},
			{"name": "Safeguard", "cost": 1800, "desc": "Every 12s, the next orb that reaches the Nest bounces back to the start instead. Titan Orbs and the blimp can't be bounced.", "fx": [["=", "safeguard", 12]]},
			{"name": "Healing Song", "cost": 4500, "desc": "Heals 12 more HP after every wave, and Safeguard recharges twice as fast.", "fx": [["+", "heal", 12], ["*", "safeguard", 0.5]]}],
		"B": [
			{"name": "Pod Bomb", "cost": 400, "desc": "+1 damage, and pods burst onto orbs next to the target.", "fx": [["+", "dmg", 1], ["+", "podArea", 35]]},
			{"name": "Big Toss", "cost": 1100, "desc": "Every 3s, throws the toughest orb in range for 15 damage.", "fx": [["=", "toss", 3]]},
			{"name": "Lucky Clover", "cost": 2600, "desc": "Every orb popped by a critter in Bunbalm's range pays $1 extra.", "fx": [["=", "lucky", true]]}]},
}
const KINDS := ["zapkit", "cindermole", "spoutling", "thornhog", "lanternwisp", "coinpie", "wobblob", "puddlesnail", "galefinch", "pebbit", "knuckaroo", "hootling", "frostray", "slumbear", "wyrmlet", "prismkit", "mimoth", "bunbalm", "astralion"]

const TYPE_COLORS := {
	"Electric": "#f7d02c", "Fire": "#f08030", "Ghost": "#9a7ad6", "Water": "#5aa8f0",
	"Grass": "#78c850", "Normal": "#d8cfa8", "Psychic": "#f37ab0", "Flying": "#a99cf0",
	"Fighting": "#e0603c", "Ice": "#98d8e0", "Rock": "#c8b060", "Dragon": "#8a68f8",
}

## Every stat a tower can have, so missing ones read as "off".
const STAT_DEFAULTS := {
	"range": 0.0, "rate": 0.0, "dmg": 0.0, "detect": false, "chain": 0, "tempest": 0.0, "thunder": false,
	"pierce": 0, "cone": 0.0, "burn": 0, "burnMul": 1.0, "blast": 0.0, "radius": 0.0, "sleep": 0.0,
	"dream": 0.0, "pspeed": 0.0, "tag": false, "nightmare": false, "jets": 0, "push": 0.0, "bubble": false,
	"hydro": 0.0, "leaves": 0, "blizzard": 0.0, "seed": false, "powder": 0.0, "solar": 0.0, "swipes": 0,
	"pay": 0, "goldRush": 0.0, "thief": false, "confuse": 0.0, "counter": 0.0, "bossMul": 1.0,
	"shadowTag": 0.0, "reveal": false, "encore": 0.0, "targets": 0, "starfall": 0.0, "future": 0.0,
	"area": 0.0, "splash": false, "flail": false, "bounce": 0.0, "brave": 0, "hurricane": 0.0,
	"rocks": 0, "rockUses": 0, "throw": 0, "quake": 0.0, "explode": 0.0, "armorBreak": false, "chi": 0.0,
	"auraRate": 1.0, "auraDmg": 0, "auraRange": 1.0, "auraDetect": false, "trick": 0.0, "freeze": 0.0,
	"gfreeze": 0.0, "surf": 0.0, "brittle": false, "cold": 0.0, "hold": 0.0, "recover": 0.0, "slam": 0.0,
	"slamDmg": 0.0, "yawn": 0.0, "rage": 0.0, "dance": false, "outrage": 0.0, "hyper": 0.0,
	"soak": false, "muddy": 0.0, "muddyDmg": 0.0, "volt": 0.0, "resort": 0.0, "copyA": 0, "copyB": 0,
	"heal": 0, "podArea": 0.0, "safeguard": 0.0, "toss": 0.0, "lucky": false,
}

const MAPS := [
	{"id": "meadow", "name": "Mossy Meadow", "sub": "Where the trail begins", "diff": "Easy", "lives": 150, "cash": 750, "theme": "route",
		"path": [[120, 640], [120, 430], [360, 430], [360, 540], [620, 540], [620, 360], [820, 360], [820, 180], [560, 180], [560, 300], [300, 300], [300, 90], [680, 90], [680, -40]]},
	{"id": "forest", "name": "Whisperwood", "sub": "Mind the roots", "diff": "Medium", "lives": 100, "cash": 750, "theme": "forest",
		"path": [[-40, 110], [200, 110], [200, 490], [420, 490], [420, 210], [640, 210], [640, 480], [850, 480], [850, -40]]},
	{"id": "hollow", "name": "Hollow Hill", "sub": "In the shadow of the old bell tower", "diff": "Hard", "lives": 75, "cash": 750, "theme": "hollow",
		"path": [[480, -40], [480, 140], [190, 140], [190, 460], [760, 460], [760, 270], [1000, 270]]},
	{"id": "caves", "name": "Glowcap Caves", "sub": "Short tunnels, no room for error", "diff": "Expert", "lives": 50, "cash": 750, "theme": "cave",
		"path": [[-40, 300], [290, 300], [290, 120], [630, 120], [630, 470], [1000, 470]]},
	{"id": "pier", "name": "Driftwood Pier", "sub": "A sleepy Slumbear is blocking the way", "diff": "Medium", "lives": 100, "cash": 750, "theme": "coast",
		"path": [[-40, 520], [260, 520], [260, 300], [120, 300], [120, 90], [520, 90], [520, 410], [700, 410], [700, 160], [1000, 160]],
		"water": [["rect", 780, -10, 200, 620], ["ell", 400, 515, 92, 50]]},
	{"id": "mine", "name": "Pitch Mine", "sub": "Pitch dark and packed with boulders", "diff": "Hard", "lives": 75, "cash": 750, "theme": "tunnel",
		"path": [[-40, 80], [840, 80], [840, 240], [140, 240], [140, 400], [840, 400], [840, 540], [-40, 540]]},
	{"id": "isles", "name": "Rime Isles", "sub": "Ice blocks and freezing currents", "diff": "Expert", "lives": 50, "cash": 750, "theme": "ice",
		"path": [[-40, 150], [330, 150], [330, 470], [630, 470], [630, 130], [1000, 130]],
		"water": [["ell", 480, 300, 96, 118], ["ell", 830, 400, 120, 105], ["ell", 120, 420, 105, 85]]},
	{"id": "summit", "name": "Summit Pass", "sub": "The last climb before the peak", "diff": "Expert", "lives": 40, "cash": 750, "theme": "summit",
		"path": [[-40, 460], [220, 460], [220, 160], [480, 160], [480, 440], [740, 440], [740, 140], [1000, 140]]},
]

## Things on a map that a critter can clear away, freeing the spot for another
## critter. "by" lists who can do it (any growth) and the move they use; one of
## them has to be on the field. "find" is money sometimes found underneath.
const OBSTACLES := {
	"tree": {"name": "Tree", "cost": 60, "by": {"knuckaroo": "Shove", "thornhog": "Slice"}},
	"pine": {"name": "Pine tree", "cost": 60, "by": {"knuckaroo": "Shove", "thornhog": "Slice"}},
	"deadtree": {"name": "Dead tree", "cost": 40, "by": {"cindermole": "Scorch", "knuckaroo": "Shove", "thornhog": "Slice"}},
	"rock": {"name": "Rock", "cost": 50, "by": {"pebbit": "Smash", "knuckaroo": "Smash"}, "find": 150, "chance": .15, "note": "Sometimes hides a gold nugget worth $150."},
	"boulder": {"name": "Boulder", "cost": 120, "by": {"knuckaroo": "Shove"}, "note": "Too big to smash. Only a Shove moves it."},
	"ice": {"name": "Ice block", "cost": 80, "by": {"cindermole": "Fire Jet"}, "note": "Only fire melts it."},
	"sleeper": {"name": "Sleeping Slumbear", "cost": 200, "by": {"zapkit": "Jolt"}, "find": 100, "chance": 1.0, "note": "A jolt wakes it up and it wanders off, dropping a snack stash worth $100."},
}

## critter that can stand in water. Everyone else needs dry land.
const SWIMMERS := ["spoutling", "puddlesnail", "frostray"]

const DIFF_COLORS := {"Easy": "#5fd38a", "Medium": "#ffd23f", "Hard": "#ff9a4a", "Expert": "#ff6b6b"}

const WAVES := [null,
	[["red", 20, .8]],
	[["red", 32, .6]],
	[["red", 22, .5], ["blue", 8, .9]],
	[["red", 26, .42], ["blue", 16, .7]],
	[["blue", 26, .55], ["red", 12, .35]],
	[["red", 16, .4], ["blue", 18, .55], ["gold", 6, 1]],
	[["blue", 26, .45], ["gold", 12, .75]],
	[["red", 24, .3], ["blue", 22, .38], ["gold", 15, .6]],
	[["gold", 32, .48]],
	[["blue", 70, .22]],
	[["gold", 24, .45], ["dart", 6, .9], ["clock", 4, 1.0]],
	[["blue", 32, .28], ["gold", 22, .38], ["dart", 10, .7]],
	[["dart", 22, .55], ["gold", 26, .36]],
	[["shade", 6, 1.2], ["gold", 32, .32]],
	[["dart", 36, .38], ["shade", 8, 1], ["clock", 8, .7]],
	[["gold", 64, .18], ["shade", 12, .7]],
	[["iron", 6, 1.4], ["dart", 32, .33]],
	[["shade", 20, .5], ["iron", 8, 1.1], ["mesh", 6, .9]],
	[["dart", 64, .18], ["iron", 12, .8]],
	[["shade", 26, .4], ["iron", 15, .7], ["gold", 44, .18]],
	[["iron", 26, .55], ["dart", 44, .22], ["mend", 5, 1.0]],
	[["shade", 44, .32]],
	[["iron", 32, .42], ["shade", 22, .48], ["mesh", 12, .5]],
	[["dart", 110, .11], ["iron", 22, .48]],
	[["titan", 1, 1], ["shade", 22, .5]],
	[["iron", 46, .33], ["shade", 32, .38], ["mend", 10, .7]],
	[["shade", 64, .24], ["dart", 64, .14]],
	[["titan", 1, 1], ["iron", 36, .4]],
	[["iron", 64, .23], ["shade", 44, .28], ["clock", 24, .3]],
	[["titan", 2, 5], ["shade", 44, .28]],
]

## Red-orb equivalents: how many lives an orb costs if it leaks.
static var RBE := {}


static func rbe(t: String) -> int:
	if RBE.has(t):
		return RBE[t]
	var b: Dictionary = BALLS[t]
	var n := 20 if b.get("boss", false) else 1
	for k in b.kids:
		n += rbe(k)
	RBE[t] = n
	return n


static func wave_groups(n: int) -> Array:
	if n < WAVES.size():
		return WAVES[n]
	if n == 40:
		return [["iron", 40, .3], ["shade", 40, .3], ["titan", 1, 1], ["blimp", 1, 1]]
	var k := n - 30
	var gap := maxf(.1, .26 - k * .012)
	var masters: int = 2 + int(floor((n - 40) / 2.0)) if n > 40 else 1 + int(floor(k / 4.0))
	var g: Array = [["iron", 50 + k * 6, gap], ["shade", 50 + k * 6, gap], ["mesh", 6 + k * 2, gap * 2], ["mend", 4 + k, gap * 3], ["titan", masters, maxf(1.5, 4 - k * .2)]]
	if n > 40 and n % 5 == 0:
		g.append(["blimp", int(floor((n - 40) / 5.0)), 8])
	return g


static func make_wave(n: int) -> Array:
	var ev: Array = []
	var start := 0.0
	for grp in wave_groups(n):
		var count: int = grp[1]
		var gap: float = grp[2]
		for i in count:
			ev.append({"t": start + i * gap, "type": grp[0]})
		start += count * gap * .55
	return stable_sort(ev, func(a, b): return a.t < b.t)


## Sorts like JavaScript's Array.sort: items that compare equal keep their order.
static func stable_sort(arr: Array, less: Callable) -> Array:
	var dec: Array = []
	for i in arr.size():
		dec.append([arr[i], i])
	dec.sort_custom(func(a, b):
		if less.call(a[0], b[0]):
			return true
		if less.call(b[0], a[0]):
			return false
		return a[1] < b[1])
	var out: Array = []
	for e in dec:
		out.append(e[0])
	return out


static func titan_hp(n: int) -> int:
	return int(round(260 * (1 + maxf(0, n - 25) * .08)))


static func blimp_hp(n: int) -> int:
	return int(round(1500 * (1 + maxf(0, n - 40) * .12)))


static func compute_stats(kind: String, a: int, b: int) -> Dictionary:
	var d: Dictionary = TOWERS[kind]
	var s := STAT_DEFAULTS.duplicate()
	for k in d.base:
		s[k] = d.base[k]
	for i in a:
		_apply(s, d.A[i].fx)
	for i in b:
		_apply(s, d.B[i].fx)
	return s


## Stats where a smaller number is stronger: attack delay, slow factors and
## cooldowns. For cooldowns 0 means the move isn't learned yet.
const LOWER_BETTER := ["rate", "confuse", "recover", "shadowTag", "tempest", "blast", "hydro", "blizzard",
	"powder", "solar", "goldRush", "encore", "starfall", "future", "bounce", "hurricane", "explode",
	"quake", "chi", "trick", "gfreeze", "surf", "cold", "slam", "yawn", "outrage", "hyper",
	"muddy", "volt", "resort", "safeguard", "toss"]


## "=" never makes a stat worse, so growth forms and moves stack in any order
## and nothing you buy can undo something you already bought.
static func _apply(s: Dictionary, fx: Array) -> void:
	for e in fx:
		var st: String = e[1]
		match e[0]:
			"+": s[st] += e[2]
			"*": s[st] *= e[2]
			"=":
				var v = e[2]
				var cur = s[st]
				if v is bool or cur is bool:
					s[st] = v
				elif st in LOWER_BETTER:
					if cur == 0 or v < cur:
						s[st] = v
				elif v > cur:
					s[st] = v


static func sprite_for(kind: String, a: int) -> String:
	match kind:
		"zapkit": return "tempeststoat" if a >= 3 else ("stormstoat" if a >= 1 else "zapkit")
		"cindermole": return ["cindermole", "kilnmole", "magmoloss", "ascmagmoloss"][a]
		"lanternwisp": return ["lanternwisp", "lanternshade", "lanternlord", "lanternwraith"][a]
		"spoutling": return ["spoutling", "spoutseal", "geyserwal", "ascgeyserwal"][a]
		"thornhog": return ["thornhog", "bramblehog", "grovehog", "ascgrovehog"][a]
		"coinpie": return "goldpie" if a >= 1 else "coinpie"
		"wobblob": return "wobblob"
		"astralion": return "novaastralion" if a >= 3 else ("armorastralion" if a >= 2 else "astralion")
		"puddlesnail": return "asckrakenshell" if a >= 3 else ("krakenshell" if a >= 1 else "puddlesnail")
		"galefinch": return ["galefinch", "galehawk", "galeroc", "ascgaleroc"][a]
		"pebbit": return ["pebbit", "bouldillo", "mountadillo", "mountadillo"][a]
		"knuckaroo": return ["knuckaroo", "brawlaroo", "champaroo", "titanchamparoo"][a]
		"hootling": return ["hootling", "hootsage", "hootarch", "elderhootarch"][a]
		"frostray": return "glacierfrostray" if a >= 3 else "frostray"
		"slumbear": return "mountainslumbear" if a >= 3 else "slumbear"
		"wyrmlet": return ["wyrmlet", "cloudwyrm", "skywyrm", "skywyrm"][a]
		"bunbalm": return "grandbunbalm" if a >= 1 else "bunbalm"
	return kind


## Damage multiplier for an attack of this type against this orb.
static func type_mul(type: String, ball: String) -> float:
	return TYPE_EFFECT.get(type, {}).get(ball, 1.0)


static func best_key(map_id: String, diff: String) -> String:
	return map_id if diff == "normal" else "%s:%s" % [map_id, diff]


## Prismkit's growth forms count as their own kinds; this gives the kind you buy.
static func base_kind(kind: String) -> String:
	return TOWERS[kind].get("evolvesFrom", kind)


static func path_names(kind: String) -> Array:
	return TOWERS[kind].get("pathNames", ["Growth", "Moves"])


# ---------- seeded random (same sequence as the web version) ----------
const M32 := 0xFFFFFFFF


static func imul(x: int, y: int) -> int:
	x &= M32
	y &= M32
	return ((x * (y & 0xFFFF)) + (((x * (y >> 16)) & 0xFFFF) << 16)) & M32


static func hash_str(s: String) -> int:
	var h := 2166136261
	for i in s.length():
		h ^= s.unicode_at(i)
		h = imul(h, 16777619)
	return h & M32


class Rng:
	var a: int

	func _init(seed_value: int) -> void:
		a = seed_value & Data.M32

	func next() -> float:
		a = (a + 0x6D2B79F5) & Data.M32
		var t := Data.imul(a ^ (a >> 15), a | 1)
		t = ((t + Data.imul(t ^ (t >> 7), t | 61)) & Data.M32) ^ t
		return float((t ^ (t >> 14)) & Data.M32) / 4294967296.0
