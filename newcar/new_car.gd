extends RigidBody3D

var upDir : Vector3 = global_transform.basis.y
var forwardDir : Vector3 = global_transform.basis.x
var lateralDir : Vector3 = forwardDir.cross(upDir).normalized()


@export var FL : RayCast3D
@export var FR : RayCast3D
@export var BL : RayCast3D
@export var BR : RayCast3D

var wheels : Array[RayCast3D]

var handbrake : bool = false

@export var particles : Array[GPUParticles3D]

@export var drawForces : bool = true

func _ready():
	wheels = [FL, FR, BL, BR]

	

func _physics_process(delta):

	forwardDir = global_transform.basis.x
	upDir = global_transform.basis.y
	lateralDir = forwardDir.cross(upDir).normalized()
		

	if Input.is_action_pressed("Handbrake"):
		handbrake = true


	else:
		handbrake = false

	if handbrake and wheels[2].is_colliding() and wheels[3].is_colliding():
		for particle in particles:
			particle.emitting = true
	else:
		for particle in particles:
			particle.emitting = false


	for wheel in wheels:
		wheel.force_raycast_update()
		if not wheel.is_colliding():
			continue

		wheel.target_position.y = -(wheel.restLen + (wheel.restLen / 2) + 1)
		
		wheel.setValues()

		apply_force(wheel.getSuspensionForce(), wheel.applyPos)
		apply_force(wheel.getLateralFriction(), wheel.applyPos)
		apply_force(wheel.getForwardFriction(), wheel.applyPos)
		wheel.steer()
		if wheel.isMotor:
			apply_force(wheel.getAccelForce(), wheel.applyPos)


#FUN BUT NOT AS DRIFT	
#	if handbrake:
#		var drift_torque = Vector3.UP * -15 * Input.get_axis("Left", "Right") * (linear_velocity.dot(forwardDir))
#		print(drift_torque)
#		apply_torque_impulse(drift_torque)
