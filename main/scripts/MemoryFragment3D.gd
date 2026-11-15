extends Area3D
class_name MemoryFragment3D

@export var fragment_id: String = "toy_fragment"
var time_passed: float = 0.0

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	# Add a glowing mesh if none exists
	if get_child_count() == 0:
		var mi := MeshInstance3D.new()
		var box := BoxMesh.new()
		box.size = Vector3(0.5, 0.5, 0.5)
		var mat := StandardMaterial3D.new()
		mat.albedo_color = Color(0.28, 0.87, 0.5, 1.0)
		mat.emission_enabled = true
		mat.emission = Color(0.28, 0.87, 0.5, 1.0)
		mat.emission_energy_multiplier = 3.0
		box.material = mat
		mi.mesh = box
		add_child(mi)
		
		var cs := CollisionShape3D.new()
		var sphere := SphereShape3D.new()
		sphere.radius = 0.6
		cs.shape = sphere
		add_child(cs)

func _process(delta: float) -> void:
	time_passed += delta
	rotation.y += delta * 2.0
	position.y += sin(time_passed * 4.0) * delta * 0.5

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		GameState.add_fragment(fragment_id)
		queue_free()
