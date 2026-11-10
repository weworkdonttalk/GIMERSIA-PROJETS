extends StaticBody2D
class_name StaticPlatform

@export var size: Vector2 = Vector2(96, 20)
@export var fill_color: Color = Color(0.82, 0.72, 0.45, 1.0)
@export var border_color: Color = Color(0.95, 0.85, 0.55, 1.0)

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var background: ColorRect = $Background
@onready var border: ReferenceRect = $Border

func _ready() -> void:
	collision_layer = 1 # World_Static
	collision_mask = 0

	var rect_shape: RectangleShape2D = RectangleShape2D.new()
	rect_shape.size = size
	collision_shape.shape = rect_shape
	collision_shape.position = Vector2.ZERO

	background.size = size
	background.position = -size / 2.0
	background.color = fill_color

	border.size = size
	border.position = -size / 2.0
	border.border_color = border_color
	border.border_width = 2.0
	border.editor_only = false
