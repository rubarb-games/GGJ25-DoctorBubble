extends RigidBody2D
class_name PlayerController

enum pStatus { ON_GROUND, IN_AIR, IN_PROGRESS }
var pS:pStatus

@export var jumpForce = 150.0
@export var moveSpeed = 5.0

@export var cameraHandle:Camera2D

var currentBubble:BubbleController

# Called when the node enters the scene tree for the first time.
func _ready():
	Globals.playerHandle = self


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var moveDirection = Vector2.ZERO
	
	#Input
	var ax = Input.get_axis("Player Left","Player Right") * moveSpeed
	if (abs(ax)>0.2):
		moveDirection += Vector2(ax,0)

	match pS:
		pStatus.ON_GROUND:
				
			if (Input.is_action_just_pressed("Player Interact")):
				jump()
			
	if (moveDirection.length() > 0):
		move_and_collide(moveDirection)
		
	isPlayerWithinCameraBounds()


func isPlayerWithinCameraBounds():
	if (self.global_position.y < 250):
		Globals.cameraHandle.followPlayer()

func jump(f:float = jumpForce):
	leaveBubble()
	pS = pStatus.IN_AIR
	self.apply_impulse(Vector2(0,-f))

func leaveBubble():
	if (currentBubble):
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
