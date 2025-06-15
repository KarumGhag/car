extends RigidBody3D

var forwardDir : Vector3 = global_transform.basis.x
var upDir : Vector3 = global_transform.basis.y
var lateralDir : Vector3 = forwardDir.cross(upDir).normalized()


@export var FL : RayCast3D
@export var FR : RayCast3D
@export var BL : RayCast3D
@export var BR : RayCast3D

var wheels : Array[RayCast3D]

func _ready():
	wheels = [FL, FR, BL, BR]
	print(forwardDir, upDir, lateralDir)

func _physics_process(delta):
	for wheel in wheels:
		if not wheel.is_colliding():
			continue
		
		wheel.setValues()

		apply_force(wheel.getSuspensionForce(), wheel.applyPos)

	print(linear_velocity)
