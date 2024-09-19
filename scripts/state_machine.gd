extends Node
class_name StateMachine

enum MovementStates {IDLE, MOVE, SHIFT}
enum ActionStates {WATER, ATTACK, INTERACT, NO_ACTION}

@export var movement_speed: float = 400
@export var watering_movement_speed_multiplier: float = 0.75
@export var shifting_movement_speed_multiplier: float = 1.6
@export var water_duration: float = 0.1
@export var interact_duration: float = 0.8
@export var attack_duration: float = 0.33

var current_state_duration: float = 0
var current_state_maximum: float = 0
var direction: Vector2 = Vector2(0, 0)
var movement_state: MovementStates = MovementStates.IDLE
var action_state: ActionStates = ActionStates.NO_ACTION
var state_inputs: Array = [action_state, movement_state]

var player: Node2D
var animated_sprite: AnimatedSprite2D
var droplet_pool: DropletPool

func _ready() -> void:
	await owner.ready
	
	player = owner as Node2D
	animated_sprite = owner.get_node("AnimatedSprite2D") as AnimatedSprite2D
	droplet_pool = get_tree().root.get_children()[0].get_node("DropletPool") as DropletPool
	
	assert(droplet_pool != null, "Map has to be the root scene")

func get_input() -> void:
	var new_movement_state: MovementStates = MovementStates.IDLE
	
	direction = Input.get_vector("move_left", "move_right", "move_up", "move_down").normalized()
	if direction != Vector2.ZERO:
		new_movement_state = MovementStates.MOVE
		if Input.is_action_pressed("shift"):
			new_movement_state = MovementStates.SHIFT
	
	var new_action_state: ActionStates = ActionStates.NO_ACTION
	
	if Input.is_action_pressed("water"):
		new_action_state = ActionStates.WATER
	if Input.is_action_pressed("attack"):
		new_action_state = ActionStates.ATTACK
		new_movement_state = MovementStates.IDLE
	if Input.is_action_pressed("interact"):
		new_action_state = ActionStates.INTERACT
		new_movement_state = MovementStates.IDLE

	state_inputs = [new_action_state, new_movement_state]

func decide_state() -> void:
	if action_state in [ActionStates.ATTACK, ActionStates.INTERACT]:
		return
	
	match state_inputs[0]:
		ActionStates.WATER:
			current_state_maximum = water_duration
		ActionStates.ATTACK:
			current_state_maximum = attack_duration
		ActionStates.INTERACT:
			current_state_maximum = interact_duration
			
	action_state = state_inputs[0]
	movement_state = state_inputs[1]
	
func process_state(delta: float) -> void:
	if current_state_duration >= current_state_maximum:
		if state_inputs[0] != action_state:
			action_state = ActionStates.NO_ACTION
			current_state_maximum = 0
			
		current_state_duration = 0
		
	match action_state:
		ActionStates.ATTACK:
			attack()
		ActionStates.WATER:
			water(delta)
		ActionStates.INTERACT:
			interact()
		ActionStates.NO_ACTION:
			no_action()
			
	if movement_state != MovementStates.IDLE:
		if action_state == ActionStates.WATER:
			move(delta, movement_speed * watering_movement_speed_multiplier)
		else:
			if movement_state == MovementStates.SHIFT:
				move(delta, movement_speed * shifting_movement_speed_multiplier)
			else:
				move(delta)

func move(delta: float, new_movement_speed: float = movement_speed):
	player.position += direction * new_movement_speed * delta
	
func attack() -> void:
	pass

func water(delta: float) -> void:
	droplet_pool.spawn_droplet(delta)
	pass

func interact() -> void:
	pass

func no_action() -> void:
	pass

func _process(delta: float) -> void:
	get_input()
	
	match action_state:
		ActionStates.ATTACK:
			if not "attack" in animated_sprite.animation:
				animated_sprite.play("attack" + str(randi_range(1, 2)))
			else:
				await animated_sprite.animation_finished
				animated_sprite.play("attack2" if "1" in animated_sprite.animation else "attack1")
					
		ActionStates.WATER:
			animated_sprite.play("water")
		ActionStates.INTERACT:
			animated_sprite.play("interact")
		ActionStates.NO_ACTION:
			animated_sprite.play("idle")

func _physics_process(delta: float) -> void:
	current_state_duration += delta
	
	decide_state()
	process_state(delta)
