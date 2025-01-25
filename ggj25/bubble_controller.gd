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

@export var bubbleVisualHandle:Control
@export var bubbleParticlesHandle:CPUParticles2D

@export var bubbleWobbleCurve:Curve
@export var bubbleGrowCurve:Curve
@export var bubbleExplodeCurve:Curve

# Called when the node enters the scene tree for the first time.
func _ready():
	SignalManager.hitByBullet.connect(OnHitByBullet)
	
	bubbleSink *= bubbleSize
	if (bubbleSize > 1):
		dieOnPlayerLeave = false
	if (bubbleSize > 2):
		bouncePlayer = true
		
	startBubble()

func wobbleBubble(fromZero:bool = false):
	if (!is_instance_valid(bubbleVisualHandle)):
		return
	var s = SimonTween.new()
	await s.createTween(bubbleVisualHandle,"scale",Vector2(1,1),1,bubbleWobbleCurve).tweenDone
	bubbleVisualHandle.scale = Vector2(1,1)

func startBubble(fromZero:bool = false):
	if (!is_instance_valid(bubbleVisualHandle)):
		return
		
	bubbleParticlesHandle.restart()
	var s = SimonTween.new()
	bubbleVisualHandle.scale = Vector2(0,0)
	await s.createTween(bubbleVisualHandle,"scale",Vector2(1,1),0.5,bubbleGrowCurve).tweenDone
	bubbleVisualHandle.scale = Vector2(1,1)
	s.createTween(bubbleVisualHandle,"rotation",deg_to_rad(360),200).setLoops(-1)

func explodeBubble(fromZero:bool = false):
	if (!is_instance_valid(bubbleVisualHandle)):
		return
	var s = SimonTween.new()
	bubbleVisualHandle.scale = Vector2(1,1)
	await s.createTween(bubbleVisualHandle,"scale",-Vector2(1,1),0.25,bubbleExplodeCurve).tweenDone
	bubbleParticlesHandle.restart()
	bubbleVisualHandle.scale = Vector2(0,0)

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
	if (bubbleSize <= 1 and !playerIsStandingOn):
		moveDirection += Vector2(0,-bubbleSink)
	else:
		moveDirection += Vector2(0,bubbleSink)
	self.position += moveDirection
	#move_and_collide(moveDirection)
	
	if (lifeTime > lifeTimeTotal):
		bubbleDie()

func bubbleDie():
	await explodeBubble()
	self.queue_free()

func OnPlayerLeave():
	playerIsStandingOn = false
	if (dieOnPlayerLeave):
		bubbleDie()

func OnPlayerTouch():
	bubbleWobbleCurve
	playerIsStandingOn = true

func OnHitByBullet(body,bullet:BulletController):
	if (body == self):
		bubbleDie()
