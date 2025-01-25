extends StaticBody2D
class_name BubbleController

@export var bubbleSize = 1.0

@export var playerTouchCurve:Curve
var playerTouchCurveProgress = 0.0
var dieOnPlayerLeave:bool = true
var bouncePlayer:bool = false
var absorb:bool = false

var currentlyAbsorbed:Node2D

var playerIsStandingOn:bool = false
var lifeTime:float = 0
var lifeTimeTotal:float = Globals.bubbleLifeTotal
var bubbleSink:float = 0.5

# Called when the node enters the scene tree for the first time.
func _ready():
	bubbleSink *= bubbleSize
	if (bubbleSize > 1):
		dieOnPlayerLeave = false
	if (bubbleSize > 2):
		bouncePlayer = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	lifeTime += delta
	
	var moveDirection = Vector2.ZERO
	
	if (playerIsStandingOn and playerTouchCurveProgress < 1 ):
		playerTouchCurveProgress += delta * 2
		#moveDirection += Vector2(0,playerTouchCurve.sample(playerTouchCurveProgress))
		#
		self.position += Vector2(0,playerTouchCurve.sample(playerTouchCurveProgress)*2)
		return
		
		
	#Make bubble sink
	if (bubbleSize <= 1):
		moveDirection += Vector2(0,-bubbleSink)
	else:
		moveDirection += Vector2(0,bubbleSink)
	self.position += moveDirection
	#move_and_collide(moveDirection)
	
	if (lifeTime > lifeTimeTotal):
		bubbleDie()

func bubbleDie():
	self.queue_free()

func OnPlayerLeave():
	playerIsStandingOn = false
	if (dieOnPlayerLeave):
		bubbleDie()

func OnPlayerTouch():
	playerIsStandingOn = true
