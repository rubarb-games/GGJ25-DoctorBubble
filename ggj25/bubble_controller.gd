extends StaticBody2D
class_name BubbleController

@export var bubbleSize = 1.0

@export var playerTouchCurve:Curve
var playerTouchCurveProgress = 0.0
var dieOnPlayerLeave:bool = true
var bouncePlayer:bool = false
var absorb:bool = false

var currentlyAbsorbed:Node2D

var isActive:bool = true
var playerIsStandingOn:bool = false
var lifeTime:float = 0
var lifeTimeTotal:float = Globals.bubbleLifeTotal
var bubbleSink:float = 0.5

@export var bubbleVisualHandle:Control
@export var bubbleParticlesHandle:CPUParticles2D

@export var bubbleWobbleCurve:Curve
@export var bubbleGrowCurve:Curve
@export var bubbleExplodeCurve:Curve

@export var bubbleSmallReference:PackedScene
@export var bubbleMediumReference:PackedScene
@export var bubbleLargeReference:PackedScene
@export var colorSizeRef:ColorRect

var wobbleTime:float = 0
@export var manualWobbleCurve:Curve
@export var exponentialCurve:Curve
var wobbleIntensity:float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	bubbleSmallReference = load("res://bubble_small.tscn")
	bubbleMediumReference = load("res://bubble_medium.tscn")
	bubbleLargeReference = load("res://bubble_large.tscn")
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

func manualWobble(delta:float):
	wobbleTime += delta*10
	var mWT = fmod(wobbleTime,1)
	bubbleVisualHandle.position.x = bubbleWobbleCurve.sample(mWT)*wobbleIntensity
	wobbleIntensity = lerp(0,20,exponentialCurve.sample(lifeTime / lifeTimeTotal))
	

func startBubble(fromZero:bool = false):
	if (!is_instance_valid(bubbleVisualHandle)):
		return
	isActive = true
	bubbleParticlesHandle.restart()
	var s = SimonTween.new()
	bubbleVisualHandle.scale = Vector2(0,0)
	await s.createTween(bubbleVisualHandle,"scale",Vector2(1,1),0.5,bubbleGrowCurve).tweenDone
	bubbleVisualHandle.scale = Vector2(1,1)
	s.createTween(bubbleVisualHandle,"rotation",deg_to_rad(360),200).setLoops(-1)
	
	SignalManager.BubbleMake.emit(bubbleSize)

func explodeBubble(fromZero:bool = false):
	if (!is_instance_valid(bubbleVisualHandle)):
		return
	
	SignalManager.BubbleDie.emit(bubbleSize)
	var s = SimonTween.new()
	bubbleVisualHandle.scale = Vector2(1,1)
	await s.createTween(bubbleVisualHandle,"scale",-Vector2(1,1),0.1,bubbleExplodeCurve).tweenDone
	bubbleParticlesHandle.restart()
	bubbleVisualHandle.scale = Vector2(0,0)
	bubbleVisualHandle.visible = false
	await get_tree().create_timer(1).timeout
	return true

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
		moveDirection += Vector2(0,bubbleSink/2)
	self.position += moveDirection
	#move_and_collide(moveDirection)
	
	manualWobble(delta)
	if (lifeTime > lifeTimeTotal and isActive):
		bubbleDie()

func bubbleDie():
	isActive = false
	if (bubbleSize == 2):
		spawnBubble(1)
		spawnBubble(1)
	elif (bubbleSize == 3):
		spawnBubble(2)
		spawnBubble(2)
		
	await explodeBubble()
	self.queue_free()

func spawnBubble(size:int):
	var bubbleToInstance
	match size:
		1:
			bubbleToInstance = bubbleSmallReference
		2:
			bubbleToInstance = bubbleMediumReference
		3:
			bubbleToInstance = bubbleLargeReference
			
	if (bubbleToInstance == self):
		print("Trying to instance same object")
		return
	if (!bubbleToInstance):
		return
			
	var inst = bubbleToInstance.instantiate()
	get_parent().add_child(inst)
	var sw = colorSizeRef.size.x/2
	var sh = colorSizeRef.size.y/2
	inst.global_position = self.global_position + Vector2(randf_range(-sw,sw),randf_range(-sh,sh))

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
