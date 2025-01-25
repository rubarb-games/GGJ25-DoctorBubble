extends RigidBody2D
class_name PlayerController

enum pStatus { ON_GROUND, IN_AIR, IN_PROGRESS, INTRO, INACTIVE }
var pS:pStatus = pStatus.INACTIVE

var playerActive:bool = false

@export var jumpForce = 150.0
@export var moveSpeed = 5.0

@export var cameraHandle:Camera2D

var currentBubble:BubbleController

# Called when the node enters the scene tree for the first time.
func _ready():
	SignalManager.startingGame.connect(OnStartingGame)
	SignalManager.restartingGame.connect(OnStartingGame)
	SignalManager.endGame.connect(OnEndGame)
	SignalManager.cameraInPlaceForStart.connect(OnCameraInPlace)
	SignalManager.hitByBullet.connect(OnHitByBullet)
	
	Globals.playerHandle = self

func initialize():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
		
	var moveDirection = Vector2.ZERO
	

	match pS:
		pStatus.ON_GROUND:
			moveDirection += takePlayerInput()
			if (Input.is_action_just_pressed("Player Interact")):
				jump()
		pStatus.IN_AIR:
			moveDirection += takePlayerInput()
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
		moveVector += Vector2(ax,0)
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
	playerActive = false
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
	SignalManager.endGame.emit()
	
func OnHitByBullet(body):
	if (body == self):
		if (playerActive):
			playerDie()
