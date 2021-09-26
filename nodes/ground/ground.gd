extends TileMap


const FireNode := preload("res://nodes/fire/fire.tscn")
const SmokeNode := preload("res://nodes/smoke/smoke.tscn")
var on_fire_tiles := [] #PoolVector2Array()

export(String) var tile_name := "Ground Tiles" # Atlas Tile name used for generation
export(int) var max_tries := 4


func _ready():
	Main.connect("burnt",self,"burnt")
	Main.connect("fire_spread",self,"fire_spread")
	var viewport_size := get_viewport().get_visible_rect().size
	generate_ground(viewport_size)


func burnt(pos : Vector2) -> void:
	set_cellv(world_to_map(pos),-1)
	on_fire_tiles.erase(world_to_map(pos))
	
	#var NewNode = SmokeNode.instance() # Spawn Smoke
	#get_parent().add_child(NewNode)
	#NewNode.position = to_global(pos)


func fire_spread(pos : Vector2) -> void:
	var map_pos := world_to_map(pos)
	var placeholder_pos := map_pos
	
	var tries = 0
	
	for _i in range(0,Main.rng.randi_range(1,4)): # Check if already on fire
		
		while get_cellv(placeholder_pos) == -1 or on_fire_tiles.has(placeholder_pos):
			if tries > max_tries: # Stop if this takes too long
				return
			
			placeholder_pos = map_pos
			
			if Main.rng.randi_range(0,1):
				placeholder_pos.x += pow(-1,Main.rng.randi_range(0,1))
			else:
				placeholder_pos.y += pow(-1,Main.rng.randi_range(0,1))
				
			tries += 1
		
		on_fire_tiles.append(placeholder_pos)
		var new_pos := map_to_world(placeholder_pos)
		
		var NewNode = FireNode.instance()
		get_parent().add_child(NewNode)
		NewNode.position = to_global(new_pos)


func generate_ground(var viewport_rect : Vector2 = Vector2.ZERO) -> void:
	var camera_pos : Vector2 = get_node("../Camera2D").get_position()
	var start := camera_pos - viewport_rect / 2
	
	var map_start := world_to_map(start)
	var map_end := world_to_map(start + viewport_rect) + Vector2(1,1)
	
	var tile_id : int = tile_set.find_tile_by_name(tile_name)
	var tile_number := tile_set.tile_get_region(tile_id).size/tile_set.autotile_get_size(tile_id) - Vector2(1,1)
	
	for x in range(map_start.x,map_end.x):
		for y in range(map_start.y,map_end.y):
			var random_tile : Vector2 = Vector2(Main.rng.randi_range(0,int(tile_number.x)),Main.rng.randi_range(0,int(tile_number.y)))
			set_cell(x,y,tile_id,false,false,false,random_tile)