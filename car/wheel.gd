extends RayCast3D

class_name Wheels

@export var car : CarClass

var restLen: float = 1
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
var accerlation : float = 500
@export var isMotor : bool

var forwardsForceMag : float = 0
var forwardsForce : Vector3 = Vector3.ZERO

var targetDir : int = 0

var projectedForwardsForce : Vector3 = Vector3.ZERO

#------Turning------
var turnSpeed : float = 2
var maxTurnDegrees : float = 25

var turnInput : int

func setValues() -> void:
	origin = global_position
	applyPos = origin - car.global_position
	collisionPoint = get_collision_point()

	upDir = (origin - collisionPoint).normalized()
	forwardDir = car.getForwardDir()
	lateralDir = forwardDir.cross(upDir).normalized()
	
	wheelVelocity = car.linear_velocity + car.angular_velocity.cross(applyPos)

func getSpringForce() -> Vector3:
	length = (origin - collisionPoint).length()
	extension = restLen - length
	springSpeed = wheelVelocity.dot(upDir)

	springForce = springConst * extension
	dampForce = -springSpeed * damping

	springForce = clamp(springForce + dampForce, -maxSuspension, maxSuspension)

	return springForce * upDir

func getLateralFriction() -> Vector3:
	# Wheel velocity at this wheel
	
	lateralSpeed = wheelVelocity.dot(lateralDir)
	lateralFrictionForce = -lateralSpeed * grip * lateralDir

	return lateralFrictionForce

func getAccelForce() -> Vector3:
	targetDir = Input.get_axis("Decelerate", "Accelerate")
	forwardsForce = forwardDir * accerlation * targetDir

	if targetDir:
		var normal = get_collision_normal()
		projectedForwardsForce = forwardsForce - normal * forwardsForce.dot(normal)
	else:
		projectedForwardsForce *= 0
	
	return projectedForwardsForce

func applyForce() -> void:
	setValues()
	overallForce = getSpringForce() + getLateralFriction() 
	if isMotor:
		overallForce += getAccelForce()

	car.apply_force(overallForce, applyPos)

	print(upDir, forwardDir, lateralDir)