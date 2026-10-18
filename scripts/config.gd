extends Object

# Square decks, 50 m across and 2.5 m high.
const PLAYER_HEIGHT := 1.7
const EYE_HEIGHT := 1.58
const PLAYER_RADIUS := 0.32
const MOVE_SPEED := 3.4
const VERTICAL_SPEED := 2.3

const HALF := 25.0
const BRIDGE_HALF := 6.5
const MAIN_RADIUS := HALF
const BRIDGE_RADIUS := BRIDGE_HALF
const DECK_HEIGHT := 2.5
const DOME_RISE := 0.0
const SHAFT_INNER := 1.25
const SHAFT_OUTER := 1.55
const WALL_THICK := 0.18

const INDUSTRIAL_FLOOR := 0.0
const OPERATIONS_FLOOR := 3.15
const CIVILIAN_FLOOR := 6.3

const BRIDGE_CZ := 34.5
const CORRIDOR_HALF_X := 0.8
const CORRIDOR_Z0 := 24.55
const CORRIDOR_Z1 := 28.45

# Avoca: one cabin the size of Shannon's bridge, 50% wider.
const AVOCA_HALF_X := BRIDGE_HALF * 1.5
const AVOCA_HALF_Z := BRIDGE_HALF
const AVOCA_FLOOR := 0.0
const AVOCA_ORRERY_Z := -1.2

const STATIONS := [
	{"name": "HELM", "x": -3.15, "z": 2.55},
	{"name": "TACTICAL", "x": -1.55, "z": 3.05},
	{"name": "SENSORS", "x": 0.0, "z": 3.25},
	{"name": "ENGINEERING", "x": 1.55, "z": 3.05},
	{"name": "COMMS", "x": 3.15, "z": 2.55},
	{"name": "COMMAND", "x": 0.0, "z": 0.35},
]

# Station X spread scaled with Avoca's wider cabin.
const AVOCA_STATIONS := [
	{"name": "HELM", "x": -4.725, "z": 2.55},
	{"name": "TACTICAL", "x": -2.325, "z": 3.05},
	{"name": "SENSORS", "x": 0.0, "z": 3.25},
	{"name": "ENGINEERING", "x": 2.325, "z": 3.05},
	{"name": "COMMS", "x": 4.725, "z": 2.55},
	{"name": "COMMAND", "x": 0.0, "z": 0.35},
]
