extends Node
class_name Water

@export var maximum_water: float = 100
@export var starting_water: float = 100
@export var drying_coef: float = 0.2
@export var watered_drying_timeout: float = 1.0

var current_drying_timeout: float = 0
var current_water: float = starting_water
var dead: bool = false
	
var flower: Flower
var water_bar: ProgressBar

func _ready() -> void:
	await owner.ready
	
	flower = owner as Flower
	water_bar = owner.get_node("WaterBar") as ProgressBar
	assert(water_bar != null, "The owner of this node has to have a water bar (ProgressBar)")

func add_water(value: float) -> void:
	current_water = clamp(current_water + value, 0, maximum_water)
	
	dead = current_water == 0
	
func _process(delta: float) -> void:
	water_bar.value = current_water

func _physics_process(delta: float) -> void:
	current_drying_timeout = clamp(current_drying_timeout - delta, 0, watered_drying_timeout)
	
	if not dead and current_drying_timeout == 0:
		add_water(-drying_coef)
	else:
		print("dead")

func _on_flower_watered() -> void:
	current_drying_timeout = watered_drying_timeout
