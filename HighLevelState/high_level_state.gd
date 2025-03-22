class_name HighLevelState

#definir estado de alto nivel acorde a la documentación (mirar low level state)

class Zone:
	var id: ZoneClass
	var type: ZoneClass.ZoneType
	var threat_level: int
	var food_amount: int
	var distance: int

	func _init(zone: ZoneClass, _threat_level: int, _food_amount: int, distance: int):  
		id = zone
		type = zone.type
		threat_level = _threat_level
		food_amount = _food_amount
		distance = distance
		
	func _get_distance(current_zone: Zone, other_zone: Zone) -> int:
		return 2

	func _get_zone_value() -> int:
		if threat_level>= food_amount:
			return 1
		else:
			return 1 + food_amount-threat_level

	func _to_string():
		return "Type: " +ZoneClass.ZoneType.keys()[type] + "\nThreat Level: " + str(threat_level) + "\nFood Amount: " + str(food_amount)+ "\nDistance: " + str(distance)+ "\nID: " + str(id.name)


var health: int
var food: int
var stamina: int
var current_zone: Zone
var zones: Array

func _init(_max_health, _max_food, _max_stamina, _health: int, _food: int, _stamina: int, _current_zone: Zone, zones: Array):
	health = quantize_creature_state(_health, _max_health)
	food = quantize_creature_state(_food, _max_food)
	stamina = quantize_creature_state(_stamina, _max_stamina)
	current_zone = _current_zone
	zones = zones

func quantize_creature_state(value, max_value)->int:
	var quantized_value = 1
	var threshold = max_value/3
	if value > 2*threshold:
		quantized_value = 3
	elif value > threshold:
		quantized_value = 2
	return quantized_value

func _to_string():
	var zones_string = "["
	for zone in zones:
		zones_string += zone._to_string()+","
	zones_string += "]"
	return "Health: " + str(health) + "\nFood: " + str(food) + "\nStamina: " + str(stamina)+"\nCurrent Zone: " + str(current_zone) + "\nZones: " + zones_string
