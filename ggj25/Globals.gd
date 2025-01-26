extends Node

var cellSize:float = 64.0
var maxBubbleSize:float = 256.0
var bubbleLifeTotal:float = 2.5

var totalBubbleResources:int
var bubbleResources:int

var bubbleRecoveryTime:float = 3.0

var levelMoveSpeed:float = 20.0
var timeBeforeLevelMoveStart:float = 10.0
var totalProgress = 0.0

var totalAmountScrolled:float = 0.0
var spawnNewLevelSegmentTreshold = 256.0
var spawnNewLevelSegmentStartingPoint = 192.0

var playerHandle:PlayerController
var cameraHandle:CameraController

var Enemy_arrowTrapFireRate:float = 2.0
var Bullet_lifetime:float = 5.0

func GetViewSize():
	return get_viewport().size

func GetViewHeight():
	return float(get_viewport().size.y)
	
func GetHalfViewHeight():
	return float(get_viewport().size.y)/2

func GetCamYPos():
	return cameraHandle.global_position.y
