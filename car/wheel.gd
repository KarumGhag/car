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

var maxForce: float = 1000.0
var springForce : float
var dampForce : float
var overallForce : Vector3
var forceVec : Vector3
var speed : float

var applyPos : Vector3


#------LateralFriction------
var wheelVelocity : Vector3
var lateralSpeed : float

var grip : float = 500

var lateralFrictionForce : Vector3


func _physics_process(_delta):
	if not is_colliding():
		return
	
	#------Suspension------

	upDir = global_transform.basis.y.normalized()

	#Vector3(0, 1, 0).cross(Vector(1, 0 ,0 )) returns Vector3(0, 0, -1)
	wheelVelocity = car.linear_velocity + car.angular_velocity.cross(applyPos)

	lateralSpeed = wheelVelocity.dot(lateralDir)

	lateralFrictionForce = -lateralSpeed * grip * lateralDir



	#gets positon of the wheel and the position relative to the car
	origin = global_position
	applyPos = origin - car.global_position
	#where the ray cast collided
	collisionPoint = get_collision_point()




	#gets the length of the raycast
	length = (origin - collisionPoint).length()
	#gets how far off the extension the length of the spring is
	extension = restLen - length

	#gets how fast the car is moving vertically
	speed = car.linear_velocity.dot(upDir)

	#hookes law, Force = constant * extension
	springForce = springConst * extension
	#makes it bouce less depending on how much its moving
	dampForce = -speed * damping

	#calculates overall force and limits it, turns it into a vector 3
	springForce = clamp(springForce + dampForce, -maxForce, maxForce)
	overallForce = (upDir * springForce) + lateralFrictionForce



	#applies it, applyPos is needed bc apply_force() second param takes it relative to the location of the rigidbody not at a specific point in world
	car.apply_force(overallForce, applyPos)


	#print(overallForce)
	
