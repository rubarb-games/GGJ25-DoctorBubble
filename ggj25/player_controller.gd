extends RigidBody2D
class_name PlayerController

enum pStatus { ON_GROUND, IN_AIR, IN_PROGRESS, INTRO, INACTIVE }
var pS:pStatus = pStatus.INACTIVE

enum pAction { IDLE, JUMPING, FALLING, WALKING, DEAD }
var pA:pAction = pAction.IDLE

var playerActive:bool = false

@export var jumpForce = 150.0
@export var moveSpeed = 5.0

@export var playerVisualHandle:Control
@export var playerGroundParticlesHandle:CPUParticles2D

var currentBubble:BubbleController

var walkingAnimTween:SimonTween
@export var walkingAnimCurve:Curve
@export var jumpingAnimCurve:Curve

@export var animTreeHandle:AnimationTree

# Called when the node enters the scene tree for the first time.
func _ready():
	SignalManager.startingGame.connect(OnStartingGame)
	SignalManager.restartingGame.connect(OnStartingGame)
	SignalManager.endGame.connect(OnEndGame)
	SignalManager.cameraInPlaceForStart.connect(OnCameraInPlace)
	SignalManager.hitByBullet.connect(OnHitByBullet)
	
	Globals.playerHandle = self
	walkingAnimTween = SimonTween.new()

func initialize():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
		
	var moveDirection = Vector2.ZERO
	

	match pS:
		pStatus.ON_GROUND:
			moveDirection += takePlayerInput()
			if (Input.is_action_just_pressed("Player Interact")):
				OnAnimJumping()
				jump()
		pStatus.IN_AIR:
			moveDirection += takePlayerInput()
			if (linear_velocity.y > 0):
				OnAnimFalling()
		pStatus.INTRO:
			if (self.linear_velocity.y > 0):
				OnPlayerActive()
			
	if (moveDirection.length() > 0):
		move_and_collide(moveDirection)
	
	if (playerActive):
		isPlayerWithinCameraBounds()

func takePlayerInput():
	var moveVector:Vector2 = Vector2.ZERO
	var ax = Input.get_axis("Player Left","Player Right") * moveSpeed
	if (abs(ax)>0.2):
		if (pS == pStatus.ON_GROUND):
			OnAnimWalking()
		moveVector += Vector2(ax,0)
	else:
		if (pS == pStatus.ON_GROUND):
			OnAnimIdle()
			
	return moveVector
		
func isPlayerWithinCameraBounds():
	if (self.global_position.y < (Globals.cameraHandle.global_position.y-Globals.GetHalfViewHeight()+(Globals.cellSize*4))):
		Globals.cameraHandle.followPlayer()
		
	if (self.global_position.y > (Globals.cameraHandle.global_position.y+Globals.GetHalfViewHeight() + Globals.cellSize)):
		playerOffscreen()
		

func jump(f:float = jumpForce):
	leaveBubble()
	if (pS != pStatus.INTRO):
		pS = pStatus.IN_AIR
	self.linear_velocity.y = 0.0
	self.apply_impulse(Vector2(0,-f))

func leaveBubble():
	if (is_instance_valid(currentBubble)):
		currentBubble.OnPlayerLeave()
		currentBubble = null

func _on_body_entered(body):
	if (pS == pStatus.IN_AIR):
		pS = pStatus.ON_GROUND
		OnAnimIdle()
		playerGroundParticlesHandle.restart()
	
	if (body.is_in_group("bubble")):
		currentBubble = body
		currentBubble.OnPlayerTouch()
		if (currentBubble.bouncePlayer):
			jump(jumpForce*1.5)

func OnPlayerActive():
	pS = pStatus.IN_AIR
	collision_mask = (1 << 0) | (1 << 1) | (1 << 2)
	playerActive = true

func OnStartingGame():
	pass

func OnIntro():
	pS = pStatus.INTRO
	lock_rotation = true
	playerActive = false
	OnAnimIdle()
	self.rotation = 0
	collision_mask = (1 << 0) | (0 << 1) | (1 << 2)
	self.global_position.y = Globals.cameraHandle.global_position.y + Globals.GetHalfViewHeight() - (Globals.cellSize*2)
	self.global_position.x = Globals.cameraHandle.global_position.x
	jump(jumpForce*1.5)

func OnEndGame():
	playerActive = false
	pS = pStatus.INACTIVE

func OnCameraInPlace():
	OnIntro()

func playerOffscreen():
	playerDie()
	
func playerDie():
	setAnimCondition("animDeath",true, true)
	SignalManager.endGame.emit()
	
func OnAnimWalking():
	if (pA == pAction.WALKING or !walkingAnimTween):
		return
	pA = pAction.WALKING
	walkingAnimTween.stop()
	setAnimCondition("animWalk",true,true)
	playerVisualHandle.rotation = 0
		
	walkingAnimTween = SimonTween.new()
	walkingAnimTween.createTween(playerVisualHandle,"rotation",deg_to_rad(4),0.3,walkingAnimCurve).setLoops(-1)
	
func OnAnimIdle():
	if (pA == pAction.IDLE or !walkingAnimTween):
		return
	pA = pAction.IDLE
	setAnimCondition("animIdle",true,true)
	walkingAnimTween.stop()
	walkingAnimTween = SimonTween.new()
	playerVisualHandle.rotation = 0
	
func OnAnimFalling():
	if (pA == pAction.FALLING or !walkingAnimTween):
		return
	pA = pAction.FALLING
	walkingAnimTween.stop()
	playerVisualHandle.rotation = 0
		
	walkingAnimTween = SimonTween.new()
	walkingAnimTween.createTween(playerVisualHandle,"rotation",deg_to_rad(15),0.2,walkingAnimCurve).setLoops(-1)

	
func OnAnimJumping():
	if (pA == pAction.JUMPING or !walkingAnimTween):
		return
	pA = pAction.JUMPING
	setAnimCondition("animJump",true,true)
	walkingAnimTween.stop()
	playerVisualHandle.rotation = 0
	
	walkingAnimTween = SimonTween.new()
	walkingAnimTween.createTween(playerVisualHandle,"rotation",deg_to_rad(45),0.25,jumpingAnimCurve)

func setAnimCondition(cond:String,val:bool, resetAfter:bool = false):
	print("parameters/conditions/"+cond)
	animTreeHandle.set("parameters/conditions/"+cond,val)
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	if (resetAfter):
		animTreeHandle.set("parameters/conditions/"+cond,!val)
	
	return true

	
func OnHitByBullet(body,bullet:BulletController):
	if (body == self and playerActive):
		lock_rotation = false
		linear_velocity = Vector2.ZERO
		apply_impulse((bullet.direction * (jumpForce/5))+Vector2(0,randf_range(-2,0))*jumpForce,bullet.global_position)
		apply_torque(1500)
		
		if (playerActive):
			playerDie()
