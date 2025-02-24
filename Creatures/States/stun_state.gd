extends State

var stun_time: float
var time: float

func enter(vars):
	stun_time = vars["stun time"]

	time = 0
	locked = true

func tick(delta):
	time += delta

	if time > stun_time:
		locked = false

func exit():
	locked = false