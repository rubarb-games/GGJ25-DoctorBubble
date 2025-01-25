extends Node

var cellSize:float = 64.0
var maxBubbleSize:float = 256.0
var bubbleLifeTotal:float = 10.0

var totalBubbleResources:int
var bubbleResources:int

var bubbleRecoveryTime:float = 2.0

var levelMoveSpeed:float = 50.0
var spawnNewLevelSegmentTreshold = 256.0

var playerHandle:PlayerController
var cameraHandle:CameraController
