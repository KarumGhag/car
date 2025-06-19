extends RigidBody3D

class_name CarClass

@export var frontLeftWheel : Wheels
@export var frontRightWheel : Wheels
@export var backLeftWheel : Wheels
@export var backRightWheel : Wheels

var wheels : Array[Wheels]

var overallForce : Vector3

func _ready():
	wheels = [frontLeftWheel, frontRightWheel, backLeftWheel, backRightWheel]

func _physics_process(_delta) -> void:

	for wheel in wheels:
		if not wheel.is_colliding():
			continue
		wheel.applyForce()


func getForwardDir() -> Vector3:
	return -global_transform.basis.z.normalized()