extends Node2D
class_name Droplet

const FALLING_HEIGHT: float = 225

@export var falling_speed: float = 450

var init_height: float
var splat: bool = false

var animated_sprite: AnimatedSprite2D

signal spawned(spawn_position: Vector2)
signal hit_the_ground

func _ready() -> void:
	animated_sprite = $AnimatedSprite2D as AnimatedSprite2D
	
	hide()
	set_physics_process(false)

func _physics_process(delta: float) -> void:
	position += Vector2.DOWN.normalized() * falling_speed * delta
	
	if position.y >= init_height + FALLING_HEIGHT:
		hit_the_ground.emit()
		
		hide()
		set_physics_process(false)

func _on_spawned(spawn_position: Vector2) -> void:
	show()
	set_physics_process(true)
	
	animated_sprite.play("idle")
	position = spawn_position
	init_height = spawn_position.y
	
	
