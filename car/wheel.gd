extends RayCast3D

class_name Wheels

@export var car : CarClass

var restLen: float = 1.5
var length : float
var extension : float
var collisionPoint : Vector3

var springConst : float = 300.0
var damping: float = 30.0

var upDir : Vector3 = global_transform.basis.y.normalized()
var forwardDir = global_transform.basis.z.normalized()   # Assuming Z is forward
var lateralDir = upDir.cross(forwardDir).normalized() 


var origin : Vector3 = Vector3.ZERO

var maxSuspension: float = 1000.0
var springForce : float
var dampForce : float
var overallForce : Vector3
var forceVec : Vector3
var springSpeed : float

var applyPos : Vector3


#------LateralFriction------
var wheelVelocity : Vector3
var lateralSpeed : float

var grip : float = 500

var lateralFrictionForce : Vector3


#-----Acceleration---------
var accerlation : float = 100
@export var isMotor : bool

var forwardsForceMag : float = 0
var forwardsForce : Vector3 = Vector3.ZERO

var targetDir : int = 0

func _physics_process(_delta):
	if not is_colliding():
		return
	
	origin = global_position
	applyPos = origin - car.global_position
	collisionPoint = get_collision_point()

	# Get updated spring direction
	upDir = (origin - collisionPoint).normalized()
	forwardDir = -global_transform.basis.z.normalized()
	lateralDir = upDir.cross(-forwardDir).normalized()

	#-----Lateral friction-----

	# Wheel velocity at this wheel
	wheelVelocity = car.linear_velocity + car.angular_velocity.cross(applyPos)
	lateralSpeed = wheelVelocity.dot(lateralDir)
	lateralFrictionForce = -lateralSpeed * grip * lateralDir


	#------Suspension--------

	length = (origin - collisionPoint).length()
	extension = restLen - length
	springSpeed = wheelVelocity.dot(upDir)

	springForce = springConst * extension
	dampForce = -springSpeed * damping

	springForce = clamp(springForce + dampForce, -maxSuspension, maxSuspension)

	#-----Acceleration------

	if isMotor:
		targetDir = Input.get_axis("Decelerate", "Accelerate")
		forwardsForce = forwardDir * accerlation * targetDir


	overallForce = (upDir * springForce) + lateralFrictionForce + forwardsForce
	car.apply_force(overallForce, applyPos)


	#print(overallForce)
	
