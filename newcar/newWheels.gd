extends RayCast3D


@export var car : RigidBody3D


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

@export var springConst : float = 100
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

func setValues() -> void:
	carPos = car.global_position
	origin = global_position
	applyPos =  origin - carPos

	collisionPoint = get_collision_point()

	upDir = car.upDir
	forwardDir = car.forwardDir
	lateralDir = car.lateralDir


func getVelocityAtWheel() -> Vector3:
	return car.linear_velocity + car.angular_velocity.cross(applyPos)
	

func getSuspensionForce() -> Vector3:
	length = (origin - collisionPoint).length()
	extension = restLen - length

	var forceMag : float = extension * springConst

	var damping : float = getVelocityAtWheel().dot(upDir) * dampConst

	springForce = (forceMag - damping) * upDir

	return springForce
