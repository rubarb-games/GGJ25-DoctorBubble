extends StaticBody2D
class_name EnemyController

enum enemyType { ARROW, PATROL }

@export var type:enemyType

enum enemyStatus { ACTIVE, IDLE, INACTIVE, IN_PROGRESS }
var eS:enemyStatus = enemyStatus.IDLE

@export var bulletSpawnPoint:Marker2D

var isActive:bool = false
var isEnemyOnScreen:bool = false

@export var bulletScene:PackedScene

var fireCounter:float = 0.0
var moveDiection:Vector2 = Vector2.RIGHT
var moveSpeed:float = 50.0
@export var groundCheckPoint:Marker2D

# Called when the node enters the scene tree for the first time.
func _ready():
	initialize()

func initialize():
	eS = enemyStatus.ACTIVE

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (!isEnemyOnScreen and global_position.y > 0):
		isEnemyOnScreen = true
		SignalManager.EnemyOnScreen.emit()
	
	
	match type:
		enemyType.ARROW:
			match eS:
				enemyStatus.ACTIVE:					
					fireCounter += delta
					
					if (fireCounter > Globals.Enemy_arrowTrapFireRate):
						fireCounter = 0
						fire()
				enemyStatus.IDLE:
					pass
				enemyStatus.INACTIVE:
					pass
				enemyStatus.IN_PROGRESS:
					pass
		enemyType.PATROL:
			match eS:
				enemyStatus.ACTIVE:
					var col = move_and_collide(moveDiection * moveSpeed * delta, true)
					evaluateCollision(col)
					self.global_position += moveDiection * moveSpeed * delta
					if (!raycast(groundCheckPoint.global_position,groundCheckPoint.global_position+Vector2(0,5))):
						moveDiection.x *= -1
					
		

func fire():
	var bullet:BulletController = bulletScene.instantiate()
	self.add_child(bullet)
	bullet.initialize()
	
	bullet.global_position = bulletSpawnPoint.global_position 
	var dir = Vector2.RIGHT
	bullet.direction = dir.rotated(deg_to_rad(bulletSpawnPoint.rotation))
	SignalManager.BulletFired.emit()
	
func raycast(origin,target):
	var originPos:Vector2 = origin
	var targetPos:Vector2 = target
	var collisionMask = (1 << 0) | (1 << 1)
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(originPos,targetPos,
	collisionMask)
	var result = space_state.intersect_ray(query)
	return query

func evaluateCollision(col:KinematicCollision2D):
	if (!col):
		return
		
	if (col.get_collider().is_in_group("player")):
		SignalManager.hitByEnemy.emit(col.get_collider())
