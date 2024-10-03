extends CharacterBody3D
class_name Player

@onready var healing_timer = $HealingTimer
@onready var recovering_timer = $RecoveringTimer
@onready var mana_bar=$UI/ManaBar
@onready var health_bar = $UI/HealthBar
@onready var stamina_bar = $UI/StaminaBar

@export_category("Provided")

@export_category("Main")

@export_category("DEBUG")

var exaustion = .30
var wound = .3
var recovering_speed = 5
var healing_speed = 3
var max_health = 100.
var max_stamina = 100.
var max_mana = 100.
var min_recoverable_stamina
var recoverable_health
var recoverable_stamina
var health
var stamina
var mana
var recovering = true
var healing = true



func _ready():
	health = max_health
	recoverable_health = max_health
	health_bar.init_health(health)
	stamina = max_stamina
	recoverable_stamina = max_stamina
	stamina_bar.init_health(stamina)
	min_recoverable_stamina=max_stamina*.25
	mana = max_mana
	mana_bar.init_health(mana)
	healing = true
	recovering = true
	healing_timer.timeout.connect(func(): recovering=true)
	recovering_timer.timeout.connect(func(): healing=true)


func get_damaged(damage: float):
	healing = false
	healing_timer.start()
	if health == recoverable_health:
		health = health -damage
		recoverable_health = recoverable_health - damage*wound
	else:
		recoverable_health = health 
		get_damaged(damage)
	if health <= 0:
		health = 0
		die()

func get_tired(effort: float):
	recovering = false
	recovering_timer.start()
	if stamina-effort >0:
		stamina = stamina -effort
		if recoverable_stamina - effort*exaustion> min_recoverable_stamina:
			recoverable_stamina = recoverable_stamina - effort*exaustion
		else:
			recoverable_stamina = min_recoverable_stamina
	else:
		stamina = 0
		get_damaged(effort-stamina)
	
func use_mana(effort: float):
	if mana -effort >0:
		mana = mana - effort
	else:
		mana=0
		get_damaged(effort-mana)

func recover_mana(new_mana):
	if mana + new_mana<max_mana:
		mana= mana+new_mana
	else:
		mana=max_mana

func heal(healed_health):
	if health + healed_health<max_health:
		health= health+healed_health
	else:
		health=max_health
	if health >recoverable_health:
			recoverable_health = health

func _process(delta):
	if healing:
		if health + delta*healing_speed< recoverable_health :
			health= health + delta*healing_speed
		else:
			health = recoverable_health
	if recovering and recoverable_stamina != max_stamina:
		if stamina < recoverable_stamina:
			if stamina + delta*recovering_speed<recoverable_stamina:
				stamina=stamina + delta*recovering_speed
			else:
				stamina = recoverable_stamina
		else:
			if recoverable_stamina + delta*recovering_speed<max_stamina:
				recoverable_stamina=recoverable_stamina + delta*recovering_speed
			else:
				recoverable_stamina = max_stamina
			stamina=recoverable_stamina
	health_bar._set_health(health)
	health_bar._set_recoverable_health(recoverable_health)
	mana_bar._set_health(mana)
	stamina_bar._set_health(stamina)
	stamina_bar._set_recoverable_health(recoverable_stamina)
	


func die():
	print("gameover")

func _unhandled_input(event):
	if event.is_action_pressed("harakiri"):
		get_damaged(10.)
		print("auch\n Health"+ str(health)+"\n R.Health" +str(recoverable_health))
		get_tired(10.)
		print("auch\n Stamina"+ str(stamina)+"\n R.stamina" +str(recoverable_stamina))
		use_mana(10.)
		print("auch\n mana"+ str(mana))
		#recover_mana(10.)
		print("cool\n mana"+ str(mana))
