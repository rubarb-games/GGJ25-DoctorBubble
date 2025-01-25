extends Camera2D
class_name CameraController

enum cameraState { IDLE, FOLLOWING, OVERRIDE, STILL }
var cS:cameraState = cameraState.IDLE

var currentCamPos
var previousCamPos
var cameraDelta

var goalPosition:Vector2

# Called when the node enters the scene tree for the first time.
func _ready():
	Globals.cameraHandle = self
	
	currentCamPos = self.global_position
	previousCamPos = self.global_position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	currentCamPos = self.global_position
	cameraDelta = currentCamPos.y - previousCamPos.y
	
	match cS:
		cameraState.IDLE:
			pass
		cameraState.FOLLOWING:
			if (Globals.playerHandle.global_position.y < (Globals.GetCamYPos() - Globals.GetHalfViewHeight())+(Globals.cellSize*2)):
				self.global_position = lerp(self.global_position,Vector2(self.global_position.x,Globals.playerHandle.global_position.y),delta*3)			
			else:
				cS = cameraState.IDLE
		cameraState.OVERRIDE:
			self.global_position.y = lerp(self.global_position.y,goalPosition.y,delta*10)
			if (self.global_position.y - goalPosition.y < 10):
				self.global_position.y = goalPosition.y
				OnIdle()
				
	Globals.totalAmountScrolled += -cameraDelta
	previousCamPos = currentCamPos

func followPlayer():
	cS = cameraState.FOLLOWING

func OnOverrideCamera(gPos:Vector2 = Vector2.ZERO):
	goalPosition = gPos
	cS = cameraState.OVERRIDE
	
func OnIdle():
	SignalManager.cameraInPlaceForStart.emit()
	cS = cameraState.IDLE
