extends Camera3D

class_name CameraFollow

@export var car : Car
var targetNode : Node3D
var targetPos : Vector3

@export var moveSpeed : float = 10

func _ready() -> void:
    pass