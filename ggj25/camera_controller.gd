extends Camera2D
class_name CameraController

enum cameraState { IDLE, FOLLOWING, STILL }
var cS:cameraState = cameraState.IDLE

# Called when the node enters the scene tree for the first time.
func _ready():
	Globals.cameraHandle = self
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	match cS:
		cameraState.IDLE:
			pass
		cameraState.FOLLOWING:
			if (Globals.playerHandle.global_position.y < (float(get_viewport().size.y)/2)-100):
				self.global_position = lerp(self.global_position,Vector2(self.global_position.x,Globals.playerHandle.global_position.y),delta*3)			
			else:
				cS = cameraState.IDLE

func followPlayer():
	cS = cameraState.FOLLOWING
