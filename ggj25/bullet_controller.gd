extends RigidBody2D
class_name BulletController

enum bulletState { ACTIVE, FROZEN, INACTIVE }
var bS:bulletState = bulletState.INACTIVE

var isActive:bool = false
var direction:Vector2 = Vector2.RIGHT
var moveSpeed:float = 200.0

var lifeCounter:float = 0.0
var deathForce:float = 180

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func initialize():
	direction = Vector2.RIGHT
	OnActive()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if isActive:
		match bS:
			bulletState.ACTIVE:
				var movement = direction * delta * moveSpeed
				evaluateCollision(move_and_collide(movement,true))
				self.position += movement
				incrementLife(delta)
			bulletState.FROZEN:
				pass
			bulletState.INACTIVE:
				pass

func incrementLife(delta):
	lifeCounter += delta
	if (lifeCounter > Globals.Bullet_lifetime):
		startDie()
		pass

func OnActive():
	bS = bulletState.ACTIVE
	isActive = true
	collision_mask = (1 << 0) | (1 << 2) | (1 << 3) | (1 << 4)
	
func OnFrozen():
	bS = bulletState.FROZEN
	collision_mask = (0 << 0) | (1 << 2) | (1 << 3) | (1 << 4)
	
func OnInactive():
	bS = bulletState.INACTIVE
	isActive = false
	collision_mask = (0 << 0) | (0 << 2) | (0 << 3) | (0 << 4)

func startDie():
	OnInactive()
	custom_integrator = false
	var reboundDirection = Vector2(direction * -1).normalized()
	reboundDirection += Vector2(0,randf_range(-1,0))
	reboundDirection *= deathForce
	apply_impulse(reboundDirection)
	var s = SimonTween.new()
	modulate.a = 1
	await s.createTween(self,"modulate:a",-1,0.5).tweenDone
	modulate.a = 0
	die()
	
func die():
	self.queue_free()

func evaluateCollision(col:KinematicCollision2D):
	if (!col):
		return
	
	if (col.get_collider().is_in_group("player")): #If collision is with player
		SignalManager.hitByBullet.emit(col.get_collider(),self)
		startDie()
		
	if (col.get_collider().is_in_group("bubble")):
		SignalManager.hitByBullet.emit(col.get_collider(),self)
		startDie()
	

func OnBulletCollision(body):
	print("Colliding with!!!"+body.name)
