extends RayCast3D

class_name WheelClass

@export var car : CarClass

var restLen: float = 1.5
var length : float
var extension : float
var collisionPoint : Vector3
var springConst : float = 300.0
var damping: float = 40.0
var maxForce: float = 1000.0

var upDir : Vector3 = Vector3.UP
var origin : Vector3 = Vector3.ZERO

var springForce : float
var dampForce : float
var overallForce : float
var forceVec : Vector3
var speed : float

var applyPos : Vector3

func _physics_process(_delta):
	if not is_colliding():
		return
	
	origin = global_position
	applyPos = origin - car.global_position
	collisionPoint = get_collision_point()

	length = (origin - collisionPoint).length()
	extension = restLen - length

	speed = car.linear_velocity.dot(upDir)

	springForce = springConst * extension
	dampForce = -speed * damping

	overallForce = clamp(springForce + dampForce, -maxForce, maxForce)
	forceVec = upDir * overallForce

	car.apply_force(forceVec, applyPos)

	
