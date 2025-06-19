extends RayCast3D


@export var car : RigidBody3D
@export var isFront : bool = false



#-----Directions-----
var upDir : Vector3
var forwardDir : Vector3
var lateralDir : Vector3

#-----Coords-----
var origin : Vector3
var collisionPoint : Vector3
var applyPos : Vector3
var carPos : Vector3

#-----Suspension-----

#force = extension * constant
#damping = speed * damping
#overallForce = (force - damping) * upDir

@export var springConst : float = 150
@export var dampConst : float = 10

var restLen : float = 1
var extension : float = 0
var length : float = 0

var verticleSpeed : float = 0
var velocityHere : Vector3 = Vector3.ZERO

var springForce : Vector3

#-----Acceleration-----
@export var isMotor : bool = false
@export var acceleration : float
var projectedForce : Vector3 = Vector3.ZERO
@export var maxSpeed : float = 3000


#-----Friction-----
var lateralSpeed : float
@export var lateralGrip : float 
@export var forwardsGrip : float
var lateralFriction : Vector3

#----Turning----
var maxAngle : float = 35
var currentAngle : float = 0
var turnSpeed : float = 1.0 / 50

func setValues() -> void:
	carPos = car.global_position
	origin = global_position
	applyPos =  origin - carPos

	collisionPoint = get_collision_point()

	upDir = global_transform.basis.y
	forwardDir = global_transform.basis.x
	lateralDir = forwardDir.cross(upDir).normalized()


func getVelocityAtWheel() -> Vector3:
	return car.linear_velocity + car.angular_velocity.cross(applyPos)
	

func getSuspensionForce() -> Vector3:
	length = (origin - collisionPoint).length()
	extension = restLen - length

	var forceMag : float = extension * springConst

	var damping : float = getVelocityAtWheel().dot(upDir) * dampConst

	springForce = (forceMag - damping) * upDir

	return springForce

func getLateralFriction() -> Vector3:

	var grip : float = lateralGrip

	if car.handbrake and not isFront:
		grip *= 0.7
	elif car.handbrake:
		grip *= 1.2

	lateralSpeed = getVelocityAtWheel().dot(lateralDir)
	lateralFriction = (-lateralSpeed * grip) * lateralDir

	#print(lateralFriction + car.linear_velocity)

	return lateralFriction

func getForwardFriction() -> Vector3:
	var forwardSpeed = getVelocityAtWheel().dot(forwardDir)
	var forwardFriction = (-forwardSpeed * forwardsGrip / 5) * forwardDir

	return forwardFriction

func getAccelForce() -> Vector3:
	var input : int = Input.get_axis("Decelerate", "Accelerate")
	var forwardForce : Vector3 = move_toward(Vector3.ZERO.dot(forwardDir), maxSpeed * input, acceleration) * forwardDir.normalized()

	print(forwardForce)

	if input:
		projectedForce = forwardForce - get_collision_normal() * forwardForce.dot(get_collision_normal())

	elif projectedForce != Vector3.ZERO:
		projectedForce = move_toward(projectedForce.dot(forwardDir), Vector3.ZERO.dot(forwardDir), acceleration / 2) * forwardDir
		
	
	

	return projectedForce

func steer() -> void:

	var steerInput : float = Input.get_axis("Right", "Left")

	var currentSpeed : float = car.linear_velocity.dot(lateralDir) + car.linear_velocity.dot(forwardDir)

	var overallMax : float = int(car.handbrake) * 5

	if isFront:
		currentAngle = lerp(currentAngle, steerInput * (maxAngle + overallMax), turnSpeed + abs(currentSpeed / 1000))

		rotation.y = deg_to_rad(currentAngle)
