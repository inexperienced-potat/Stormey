extends Node2D
class_name DropletPool

const DROPLET_SPAWN_OFFSET_Y: float = 100.0

@export var droplet_spawn_cooldown: float = 0.08
@export var max_spawn_area_x: float = 30.0
@export var max_spawn_area_y: float = 25.0

var current_droplet_spawn_interval: float = 0
var droplet_tracker: int = 0
var droplet_splash_tracker: int = 0

var player: Node2D
var droplets_owner: Node
var droplet_splashes_owner: Node

func _ready() -> void:
	await owner.ready
	player = owner.get_node("Player") as Node2D
	droplets_owner = $Droplets as Node
	droplet_splashes_owner = $DropletSplashes as Node
	
	for droplet: Droplet in droplets_owner.get_children():
		if droplet.has_signal("hit_the_ground"):
			droplet.connect("hit_the_ground", spawn_droplet_splash.bind(droplet))

func spawn_droplet(delta: float) -> void:
	current_droplet_spawn_interval += delta
	
	if current_droplet_spawn_interval < droplet_spawn_cooldown:
		return
		
	current_droplet_spawn_interval = 0
	
	var droplet: Droplet = droplets_owner.get_child(droplet_tracker) as Droplet
	droplet_tracker = (droplet_tracker + 1) % droplets_owner.get_child_count()
	
	var random_x: float = randf_range(player.position.x - max_spawn_area_x, player.position.x + max_spawn_area_x)
	var random_y: float = randf_range(player.position.y - max_spawn_area_y, player.position.y + max_spawn_area_y)
	var spawn_position: Vector2 = Vector2(random_x, random_y - DROPLET_SPAWN_OFFSET_Y)
	
	droplet.set_physics_process(true)
	droplet.spawned.emit(spawn_position)
	
func spawn_droplet_splash(droplet: Droplet) -> void:
	var droplet_splash: DropletSplash = droplet_splashes_owner.get_child(droplet_splash_tracker) as DropletSplash
	droplet_splash_tracker = (droplet_splash_tracker + 1) % droplet_splashes_owner.get_child_count()
	
	droplet_splash.set_physics_process(true)
	droplet_splash.spawned.emit(droplet.position)
