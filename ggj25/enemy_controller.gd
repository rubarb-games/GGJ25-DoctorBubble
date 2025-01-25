extends StaticBody2D
class_name EnemyController

enum enemyStatus { ACTIVE, IDLE, INACTIVE, IN_PROGRESS }
var eS:enemyStatus

@export var bulletSpawnPoint:Marker2D

var isActive:bool = false

@export var bulletScene:PackedScene

var fireCounter:float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func initialize():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
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
		

func fire():
	var bullet:BulletController = bulletScene.instantiate()
	self.add_child(bullet)
	bullet.initialize()
	
	bullet.global_position = bulletSpawnPoint.global_position 
	var dir = Vector2.RIGHT
	bullet.direction = dir.rotated(deg_to_rad(bulletSpawnPoint.rotation))
	
