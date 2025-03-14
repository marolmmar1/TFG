extends State


func tick(delta):
	controller.data.stamina += delta * controller.stamina_regen_rate

func check_conditions(vars) -> bool:
	return controller.check_is_on_floor()
