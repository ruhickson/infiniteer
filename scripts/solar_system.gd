extends RefCounted

# Keplerian planets from J2000 elements, advanced to the ship clock.
# The Shannon starts off Ganymede. A course is a straight cruise to where
# the destination will be, plus a burn to leave and a burn to arrive.

const AU_KM := 149597870.7
const YEAR_DAYS := 365.256363
const EPOCH_DAY := 9786.5
const CRUISE_AU_PER_DAY := 0.02
const CRUISE_T_PER_DAY := 0.16
const TANK_T := 250.0
const WATCH_RATE := 1.5
const SHIP_LEAD_DEG := 18.0
const SHIP_EXTRA_AU := 0.0004

var day: float = EPOCH_DAY
var rate: float = 0.0
var planet_ids: Array[String] = []
var moon_ids: Array[String] = []
var bodies := {}
var _cached_id := ""
var _cached_day := -1.0
var _cached: Dictionary = {}

func _init() -> void:
	_add_planet("Mercury", 0.38709843, 0.20563661, 7.00559432, 252.25166724, 77.45771895, 48.33961819, 0.0553, 0.72, 0.62, 0.48, 0.014)
	_add_planet("Venus", 0.72332102, 0.00676399, 3.39777545, 181.97970850, 131.76755713, 76.67261496, 0.815, 0.90, 0.82, 0.58, 0.018)
	_add_planet("Earth", 1.00000018, 0.01673163, -0.00054346, 100.46691572, 102.93005885, -5.11260389, 1.0, 0.28, 0.52, 0.78, 0.018)
	_add_planet("Mars", 1.52371243, 0.09336511, 1.85181869, -4.56813164, -23.91744784, 49.71320984, 0.107, 0.76, 0.36, 0.22, 0.015)
	_add_planet("Jupiter", 5.20248019, 0.04853590, 1.29861416, 34.33479152, 14.27495244, 100.29282654, 317.8, 0.82, 0.68, 0.48, 0.040)
	_add_planet("Saturn", 9.54149883, 0.05550825, 2.49424102, 50.07571329, 92.86136063, 113.63998702, 95.16, 0.86, 0.78, 0.52, 0.034)
	_add_planet("Uranus", 19.18797948, 0.04685740, 0.77298127, 314.20276625, 172.43404441, 73.96250215, 14.54, 0.55, 0.82, 0.80, 0.024)
	_add_planet("Neptune", 30.06952752, 0.00895439, 1.77005520, 304.22289287, 46.68158724, 131.78635853, 17.15, 0.25, 0.38, 0.82, 0.024)
	_add_moon("Io", 421700.0 / AU_KM, 1.769138, 20.0, 0.015, 0.90, 0.82, 0.45)
	_add_moon("Europa", 671100.0 / AU_KM, 3.551181, 110.0, 0.008, 0.78, 0.74, 0.62)
	_add_moon("Ganymede", 1070400.0 / AU_KM, 7.154553, 200.0, 0.025, 0.62, 0.58, 0.50)
	_add_moon("Callisto", 1882700.0 / AU_KM, 16.689018, 310.0, 0.018, 0.48, 0.44, 0.40)

func advance(delta: float) -> void:
	day += rate * clampf(delta, 0.0, 0.1)

func is_moon(id: String) -> bool:
	if not bodies.has(id):
		return false
	return String(bodies[id]["kind"]) == "moon"

func marker_radius(id: String) -> float:
	return float(bodies[id]["marker"])

func body_color(id: String) -> Color:
	return bodies[id]["color"]

func ship_position(at_day: float) -> Vector3:
	var moon: Dictionary = bodies["Ganymede"]
	var ang := deg_to_rad(float(moon["phase"]) + SHIP_LEAD_DEG + 360.0 * at_day / float(moon["period"]))
	var radius := float(moon["a"]) + SHIP_EXTRA_AU
	return body_position("Jupiter", at_day) + Vector3(cos(ang) * radius, sin(ang) * radius, 0.0)

func body_position(id: String, at_day: float) -> Vector3:
	var row: Dictionary = bodies[id]
	if String(row["kind"]) == "moon":
		return body_position("Jupiter", at_day) + _moon_offset(row, at_day)
	var mean := deg_to_rad(float(row["M0"]) + float(row["n"]) * at_day)
	return _heliocentric(row, mean)

func orbit_point(id: String, mean_rad: float) -> Vector3:
	return _heliocentric(bodies[id], mean_rad)

func to_table(ecliptic: Vector3) -> Vector3:
	var radial := Vector2(ecliptic.x, ecliptic.y)
	var au := radial.length()
	if au < 0.0000001:
		return Vector3(0.0, ecliptic.z, 0.0)
	var scaled := pow(au, 0.42) * 0.26
	var flat := radial * (scaled / au)
	var north := ecliptic.z * (scaled / au)
	return Vector3(flat.x, north, flat.y)

func plot(id: String) -> Dictionary:
	var key := snapped(day, 0.01)
	if id == _cached_id and absf(key - _cached_day) < 0.0001 and not _cached.is_empty():
		return _cached
	var result := _plot_at(id, day)
	_cached_id = id
	_cached_day = key
	_cached = result
	return result

func page(selected_id: String) -> String:
	var lines := PackedStringArray()
	var ship := ship_position(day)
	var ganymede := body_position("Ganymede", day)
	lines.append(_clock(day))
	lines.append("S.F. Shannon off Ganymede")
	lines.append("Sun distance     %s" % _dist_full(ship.length()))
	lines.append("Ganymede         %s" % _dist_full(ship.distance_to(ganymede)))
	lines.append(_rate_line())
	lines.append("")
	if selected_id == "":
		lines.append("Select a planet or a Jovian moon.")
		lines.append("")
		lines.append("The table is the ecliptic, viewed from the north.")
		lines.append("Facing the bow, starboard is longitude 0° and ahead is 90°.")
		lines.append("Height off the glass is true inclination.")
		lines.append("Radius is compressed so Neptune fits on the glass.")
		lines.append("The Shannon marker sits on Jupiter at this scale.")
		lines.append("")
		lines.append("A course is a straight cruise at %s AU/day (%.0f km/s)" % [CRUISE_AU_PER_DAY, _cruise_km_s()])
		lines.append("to where the body will be, plus a burn to leave and a burn to arrive.")
		lines.append("Tank %s t." % _tonnes(TANK_T))
	else:
		_append_course(lines, selected_id)
	return "\n".join(lines)

func _plot_at(id: String, day0: float) -> Dictionary:
	var origin := ship_position(day0)
	var now := body_position(id, day0)
	var range_now := origin.distance_to(now)
	var blank := {
		"dest": id,
		"solvable": false,
		"fits": false,
		"range_now": range_now,
		"intercept": 0.0,
		"days": 0.0,
		"depart": 0.0,
		"arrive": 0.0,
		"cruise": 0.0,
		"fuel": 0.0,
		"direction": Vector3.ZERO,
		"longitude": 0.0,
		"latitude": 0.0,
		"outward": 0.0,
		"prograde": 0.0,
		"north": 0.0,
		"origin": origin,
		"arrive_pos": now,
		"note": "",
	}
	if id == "Jupiter":
		blank["note"] = "on_station"
		return blank
	var step := 1.0
	if range_now < 0.08:
		step = 0.02
	var prev_t := 0.0
	var prev_f := range_now
	var t := step
	var hit := -1.0
	while t <= 6000.0:
		var f := origin.distance_to(body_position(id, day0 + t)) - CRUISE_AU_PER_DAY * t
		if prev_f > 0.0 and f <= 0.0:
			hit = _bisect(id, origin, day0, prev_t, t)
			break
		prev_f = f
		prev_t = t
		t += step
	if hit < 0.0:
		blank["note"] = "no_intercept"
		return blank
	var arrive_pos := body_position(id, day0 + hit)
	var aim := arrive_pos - origin
	var direction := aim.normalized()
	var row: Dictionary = bodies[id]
	var burns := _burns(hit, float(row["mass"]), String(row["kind"]))
	var radial := Vector3(origin.x, origin.y, 0.0)
	if radial.length() < 0.000001:
		radial = Vector3(1.0, 0.0, 0.0)
	radial = radial.normalized()
	var prograde := Vector3(-radial.y, radial.x, 0.0)
	var lon := rad_to_deg(atan2(direction.y, direction.x))
	if lon < 0.0:
		lon += 360.0
	blank["solvable"] = true
	blank["range_now"] = range_now
	blank["intercept"] = aim.length()
	blank["days"] = hit
	blank["depart"] = float(burns["depart"])
	blank["arrive"] = float(burns["arrive"])
	blank["cruise"] = float(burns["cruise"])
	blank["fuel"] = float(burns["fuel"])
	blank["fits"] = float(burns["fuel"]) <= TANK_T
	blank["direction"] = direction
	blank["longitude"] = lon
	blank["latitude"] = rad_to_deg(asin(clampf(direction.z, -1.0, 1.0)))
	blank["outward"] = direction.dot(radial)
	blank["prograde"] = direction.dot(prograde)
	blank["north"] = direction.z
	blank["origin"] = origin
	blank["arrive_pos"] = arrive_pos
	blank["note"] = "ok"
	return blank

func _append_course(lines: PackedStringArray, id: String) -> void:
	var course := plot(id)
	lines.append("DESTINATION  %s" % id)
	lines.append("Range now    %s" % _dist_full(float(course["range_now"])))
	if String(course["note"]) == "on_station":
		lines.append("Shannon is already off Ganymede, in the Jovian system.")
		lines.append("Choose a moon, or another planet.")
		return
	if not bool(course["solvable"]):
		lines.append("No intercept inside the plotted window.")
		return
	var days := float(course["days"])
	lines.append("Intercept    %s in %s" % [_dist_full(float(course["intercept"])), _span(days)])
	lines.append("Arrive       %s" % _clock(day + days))
	lines.append("Bearing      %.1f° longitude, %s latitude" % [float(course["longitude"]), _signed_deg(float(course["latitude"]))])
	lines.append("Direction    outward %s   prograde %s   north %s" % [_signed(float(course["outward"])), _signed(float(course["prograde"])), _signed(float(course["north"]))])
	lines.append("Heading      %s" % _heading_words(float(course["outward"]), float(course["prograde"]), float(course["north"])))
	var fuel := float(course["fuel"])
	var pct := int(round(fuel / TANK_T * 100.0))
	var tank_word := "fits the tank"
	if not bool(course["fits"]):
		tank_word = "short of fuel"
	lines.append("Fuel         %s t of %s t  (%d%%)  — %s" % [_tonnes(fuel), _tonnes(TANK_T), pct, tank_word])
	lines.append("Leave %s t · arrive %s t · cruise %s t" % [_tonnes(float(course["depart"])), _tonnes(float(course["arrive"])), _tonnes(float(course["cruise"]))])
	lines.append("")
	if bool(course["fits"]):
		lines.append("This window fits the tank.")
	else:
		lines.append("Sweep the clock. A closer alignment uses less fuel.")
	lines.append("Straight cruise, %s AU/day. Tank %s t." % [CRUISE_AU_PER_DAY, _tonnes(TANK_T)])

func _burns(days: float, mass: float, kind: String) -> Dictionary:
	var depart := 16.0
	var arrive := 10.0 + 3.2 * log(1.0 + mass)
	if kind == "moon":
		depart = 6.0
		arrive = 4.0
	var cruise := days * CRUISE_T_PER_DAY
	return {
		"depart": depart,
		"arrive": arrive,
		"cruise": cruise,
		"fuel": depart + arrive + cruise,
	}

func _bisect(id: String, origin: Vector3, day0: float, lo: float, hi: float) -> float:
	var left := lo
	var right := hi
	for _i in 30:
		var mid := (left + right) * 0.5
		var gap := origin.distance_to(body_position(id, day0 + mid)) - CRUISE_AU_PER_DAY * mid
		if gap > 0.0:
			left = mid
		else:
			right = mid
	return (left + right) * 0.5

func _heliocentric(row: Dictionary, mean_anom: float) -> Vector3:
	var ecc := float(row["e"])
	var ecc_anom := _kepler(mean_anom, ecc)
	var denom := 1.0 - ecc * cos(ecc_anom)
	var cos_nu := (cos(ecc_anom) - ecc) / denom
	var sin_nu := sqrt(1.0 - ecc * ecc) * sin(ecc_anom) / denom
	var radius := float(row["a"]) * denom
	var nu := atan2(sin_nu, cos_nu)
	var arg := deg_to_rad(float(row["w"])) + nu
	var inc := deg_to_rad(float(row["i"]))
	var node := deg_to_rad(float(row["node"]))
	var x := radius * (cos(node) * cos(arg) - sin(node) * sin(arg) * cos(inc))
	var y := radius * (sin(node) * cos(arg) + cos(node) * sin(arg) * cos(inc))
	var z := radius * (sin(arg) * sin(inc))
	return Vector3(x, y, z)

func _kepler(mean_anom: float, ecc: float) -> float:
	var mean := wrapf(mean_anom + PI, 0.0, TAU) - PI
	var ecc_anom := mean
	for _i in 12:
		var denom := 1.0 - ecc * cos(ecc_anom)
		if absf(denom) < 0.00000001:
			break
		ecc_anom -= (ecc_anom - ecc * sin(ecc_anom) - mean) / denom
	return ecc_anom

func _moon_offset(row: Dictionary, at_day: float) -> Vector3:
	var ang := deg_to_rad(float(row["phase"]) + 360.0 * at_day / float(row["period"]))
	var radius := float(row["a"])
	return Vector3(cos(ang) * radius, sin(ang) * radius, 0.0)

func _add_planet(id: String, axis: float, ecc: float, inc: float, mean_lon: float, peri: float, node: float, mass: float, red: float, green: float, blue: float, marker: float) -> void:
	bodies[id] = {
		"kind": "planet",
		"a": axis,
		"e": ecc,
		"i": inc,
		"node": node,
		"w": peri - node,
		"M0": mean_lon - peri,
		"n": 360.0 / (YEAR_DAYS * pow(axis, 1.5)),
		"mass": mass,
		"color": Color(red, green, blue),
		"marker": marker,
	}
	planet_ids.append(id)

func _add_moon(id: String, axis: float, period: float, phase: float, mass: float, red: float, green: float, blue: float) -> void:
	bodies[id] = {
		"kind": "moon",
		"a": axis,
		"period": period,
		"phase": phase,
		"mass": mass,
		"color": Color(red, green, blue),
		"marker": 0.01,
	}
	moon_ids.append(id)

func _clock(at_day: float) -> String:
	var jd := 2451545.0 + at_day
	var q := jd + 0.5
	var z := int(floor(q))
	var w := int(floor((float(z) - 1867216.25) / 36524.25))
	var x := int(floor(float(w) / 4.0))
	var a := z + 1 + w - x
	var b := a + 1524
	var c := int(floor((float(b) - 122.1) / 365.25))
	var d := int(floor(365.25 * float(c)))
	var e := int(floor(float(b - d) / 30.6001))
	var f := int(floor(30.6001 * float(e)))
	var day_float := float(b - d - f) + (q - float(z))
	var day_n := int(floor(day_float + 0.000001))
	var frac := day_float - float(day_n)
	var month := e - 1
	if e >= 14:
		month = e - 13
	var year := c - 4716
	if month <= 2:
		year = c - 4715
	var names := PackedStringArray(["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"])
	var minute_total := int(floor(frac * 1440.0 + 0.0001))
	var hour := int(minute_total / 60) % 24
	var minute := minute_total % 60
	return "%02d %s %d  %02d:%02d UTC" % [day_n, names[month - 1], year, hour, minute]

func _rate_line() -> String:
	if rate <= 0.0:
		return "Clock held"
	if rate >= 10.0:
		return "Clock running · %d days/s" % int(round(rate))
	return "Clock running · %.1f days/s" % rate

func _span(days: float) -> String:
	if days < 1.0:
		var hours := int(floor(days * 24.0))
		var mins := int(round(days * 1440.0)) % 60
		return "%dh %dm" % [hours, mins]
	if days < YEAR_DAYS:
		return "%.1f days" % days
	var years := int(floor(days / YEAR_DAYS))
	var rest := int(round(days - float(years) * YEAR_DAYS))
	return "%dy %dd" % [years, rest]

func _dist_full(au: float) -> String:
	var km := au * AU_KM
	if km < 2000000.0:
		return "%s km" % _grouped(km)
	return "%.2f AU  ·  %.1f million km" % [au, km / 1000000.0]

func _grouped(km: float) -> String:
	var n := int(round(absf(km)))
	var digits := str(n)
	var out := ""
	var count := 0
	for i in range(digits.length() - 1, -1, -1):
		if count == 3:
			out = " " + out
			count = 0
		out = digits.substr(i, 1) + out
		count += 1
	return out

func _tonnes(value: float) -> String:
	return "%.1f" % value

func _signed(value: float) -> String:
	if value >= 0.0:
		return "+%.2f" % value
	return "%.2f" % value

func _signed_deg(value: float) -> String:
	if value >= 0.0:
		return "+%.1f°" % value
	return "%.1f°" % value

func _heading_words(outward: float, prograde: float, north: float) -> String:
	var parts: PackedStringArray = PackedStringArray()
	if outward >= 0.2:
		parts.append("outward")
	elif outward <= -0.2:
		parts.append("sunward")
	if prograde >= 0.2:
		parts.append("prograde")
	elif prograde <= -0.2:
		parts.append("retrograde")
	if north >= 0.05:
		parts.append("north of the ecliptic")
	elif north <= -0.05:
		parts.append("south of the ecliptic")
	if parts.is_empty():
		return "nearly in the ecliptic, little radial change"
	return ", ".join(parts)

func _cruise_km_s() -> float:
	return CRUISE_AU_PER_DAY * AU_KM / 86400.0
