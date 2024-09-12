extends Node
class_name StateMachine

enum MovementStates {IDLE, MOVE}
enum ActionStates {NO_ACTION, ATTACK, WATER, INTERACT}

@export var movement_speed: float = 500
@export var attack_duration: float = 0.33
@export var interact_duration: float = 0.8
@export var water_duration: float = 0.1

var current_state_duration: float = 0
var direction: Vector2 = Vector2(0, 0)
var movement_state: MovementStates = MovementStates.IDLE
var action_state: ActionStates = ActionStates.NO_ACTION

var player_body: CharacterBody2D
var animation_player: AnimationPlayer

func _ready() -> void:
	await owner.ready
	player_body = owner as CharacterBody2D
	animation_player = owner.get_node("AnimationPlayer") as AnimationPlayer

func get_input() -> void:
	direction = Input.get_vector("move_left", "move_right", "move_up", "move_down").normalized()
	var new_movement_state = MovementStates.IDLE if direction == Vector2.ZERO else MovementStates.MOVE
	
	if action_state == ActionStates.NO_ACTION:
		if Input.is_action_pressed("attack"):
			# cannot move when attacking
			change_state(ActionStates.ATTACK, MovementStates.IDLE)
		elif Input.is_action_pressed("interact"):
			# cannot move when interacting
			change_state(ActionStates.INTERACT, MovementStates.IDLE)
		elif Input.is_action_pressed("water"):
			# can but does not have to move when watering
			change_state(ActionStates.WATER, new_movement_state)
		else:
			change_state(ActionStates.NO_ACTION, new_movement_state)

func change_state(new_action_state: ActionStates, new_movement_state: MovementStates) -> void:
	if new_action_state == ActionStates.NO_ACTION:
		current_state_duration = 0
	
	action_state = new_action_state
	movement_state = new_movement_state

func move(new_movement_speed: float = movement_speed):
	player_body.velocity = direction * new_movement_speed
	player_body.move_and_slide()
	
func attack() -> void:
	pass

func water() -> void:
	pass

func interact() -> void:
	pass

func no_action() -> void:
	pass

func process_state() -> void:
	if movement_state == MovementStates.MOVE:
		if action_state == ActionStates.WATER:
			move(movement_speed / 2.5)
			print("halved")
		else:
			move(movement_speed)
			print("full")
	
	match action_state:
		ActionStates.ATTACK:
			attack()
		ActionStates.WATER:
			water()
		ActionStates.INTERACT:
			interact()
		ActionStates.NO_ACTION:
			no_action()

func _process(delta: float) -> void:
	get_input()
	
	match action_state:
		ActionStates.ATTACK:
			if animation_player.current_animation != "attack":
				animation_player.play(&"RESET")
				animation_player.advance(0)
				animation_player.play("attack")
			else:
				await animation_player.animation_finished
		ActionStates.WATER:
			if animation_player.current_animation != "water":
				animation_player.play(&"RESET")
				animation_player.advance(0)
				animation_player.play("water")
			else:
				await animation_player.animation_finished
		ActionStates.INTERACT:
			if animation_player.current_animation != "interact":
				animation_player.play(&"RESET")
				animation_player.advance(0)
				animation_player.play("interact")
			else:
				await animation_player.animation_finished
		ActionStates.NO_ACTION:
			if animation_player.current_animation != "idle":
				animation_player.play(&"RESET")
				animation_player.advance(0)
				animation_player.play("idle")
			else:
				await animation_player.animation_finished

func _physics_process(delta: float) -> void:
	if action_state != ActionStates.NO_ACTION:
		current_state_duration += delta
		
	match action_state:
		ActionStates.ATTACK:
			if current_state_duration >= attack_duration:
				change_state(ActionStates.NO_ACTION, movement_state)
		ActionStates.INTERACT:
			if current_state_duration >= interact_duration:
				change_state(ActionStates.NO_ACTION, movement_state)
		ActionStates.WATER:
			if current_state_duration >= water_duration:
				change_state(ActionStates.NO_ACTION, movement_state)
	
	process_state()
