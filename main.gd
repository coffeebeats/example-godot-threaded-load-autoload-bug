extends Node

## load_on_ready controls whether this node will attempt a load within its `_ready`
## callback. Anecdotally, the bug is almost always observed when this is `true`, but
## rarely observed when `false` (and loads are instead triggered via button press).
@export var load_on_ready: bool = true

@export_subgroup("ResourceLoader settings")

## use_sub_threads is the primary trigger of this bug - when it's `false`, the bug is
## not observed.
@export var use_sub_threads: bool = true

## cache_mode does not meaningfully affect this bug, but this property can be changed to
## validate this.
@export var cache_mode: ResourceLoader.CacheMode = ResourceLoader.CACHE_MODE_IGNORE_DEEP

@export_subgroup("Example setup")

## scene_path is a filepath to a scene whose root node has an attached script that
## references an autoloaded scene.
@export_file var scene_path: String = ""


func _ready() -> void:
	if load_on_ready:
		# NOTE: This call is deferred to demonstrate that it has no affect on the bug.
		load_scene.call_deferred()


func load_scene():
	print("\nLoading packed scene and adding it as a child.")

	# This call does *not* trigger the error.
	print("	> Scene dependencies: ", ResourceLoader.get_dependencies(scene_path))

	# The error originates from this call, not when this
	var err := (
		ResourceLoader
		. load_threaded_request(
			scene_path,
			"PackedScene",
			use_sub_threads,
			cache_mode,
		)
	)
	assert(err == OK, "failed to request scene load")

	print("	> Submitted load request.")

	var scene: PackedScene = ResourceLoader.load_threaded_get(scene_path)
	assert(scene is PackedScene, "failed to load scene")

	print("	> Loaded scene.")

	var node := scene.instantiate()

	print("	> Instantiated scene.")

	add_child(node)

	print("	> Added node as child.")


func _on_button_pressed():
	load_scene()
