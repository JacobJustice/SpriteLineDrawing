@tool
extends Line2D

## Should contain the string of a directory of scene files
@export var sprite_directory = ""

## Base distance between sprites
@export var spacing : float = 20

## Set > 0 if you want there to be a little bit of jitter between sprites. \nA random number in the range [-jitter, jitter] is selected and added to the spacing value
@export var jitter : float = 0

## Set to false if you would like the selected sprites to be random every single time or not\nShould be used if you want consistent results.
@export var use_random_seed : bool = true

## Seed used for selecting sprites
@export var random_seed : int = 0

var sprites = []
var child_sprites = []
var sprite_scene_files = []

var old_points
var old_spacing
var old_sprite_directory
var old_jitter
var old_use_random_seed
var old_random_seed

func load_scene_files(verbose = false):
	var dir = DirAccess.open(sprite_directory)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir():
				if verbose:
					print("found file " + file_name)
				sprite_scene_files.append(sprite_directory + file_name)
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")
		
	for fn in sprite_scene_files:
		sprites.append(load(fn))
	

# Called when the node enters the scene tree for the first time.
func _ready():
	load_scene_files()

	if sprites.size() > 0:
		place_sprites_along_line()
	old_points = points.duplicate()

func has_array_changed(old_array: PackedVector2Array, new_array: PackedVector2Array) -> bool:
	if old_array.size() != new_array.size():
		return true
	
	for i in range(old_array.size()):
		if old_array[i] != new_array[i]:
			return true
	
	return false

func _process(_delta):
	if Engine.is_editor_hint():
		if has_array_changed(old_points, points) or old_spacing != spacing or old_jitter != jitter or old_random_seed != random_seed or old_use_random_seed != use_random_seed:
			place_sprites_along_line()
		if old_sprite_directory != sprite_directory:
			load_scene_files()
			place_sprites_along_line()
		old_points = points.duplicate()
		old_spacing = spacing
		old_jitter = jitter
		old_use_random_seed = use_random_seed
		old_random_seed = random_seed
		old_sprite_directory = sprite_directory
	

func place_sprites_along_line():
	var rng = RandomNumberGenerator.new()
	if use_random_seed:
		rng.seed = random_seed
	else:
		rng.seed = randi()

	var previous_point = null 
	for child in get_children():
		child.queue_free()
	
	for point in points:
		if previous_point != null:
			var step_size = spacing/previous_point.distance_to(point)
			var t = 0
			while t != 1:
				step_size = (spacing + rng.randf_range(-jitter,jitter))/previous_point.distance_to(point)
				t = move_toward(t, 1, step_size)
				var sprite_pos = previous_point + (point - previous_point) * t
				var new_sprite = sprites[rng.randi() % sprites.size()].instantiate()
				new_sprite.flip_h = rng.randi() %2
				new_sprite.position = sprite_pos
				add_child(new_sprite)
		else:
			var new_sprite = sprites[rng.randi() % sprites.size()].instantiate()
			new_sprite.flip_h = rng.randi() %2
			new_sprite.position = point
			add_child(new_sprite)
			

			#previous_point -> point forms a line




		previous_point = point

		
