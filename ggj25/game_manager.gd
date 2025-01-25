extends Node2D
class_name GameManager

enum gameState { ACTIVE, PAUSED, IN_PROGRESS, IDLE, INACTIVE }
var gS:gameState

var bubbleResourceCounter:float = 0.0
var spawnNewlevelSegmentTimer:float = 0.0

var timeBeforeLevelMoveCounter:float = 0.0

var levelSegmentArr:Array[PackedScene]
var lastLevelSegment:LevelSegmentController

@export var levelHandle:Node2D

@export var startingPlatform:PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	SignalManager.goingToGame.connect(OnGoingToGame)
	SignalManager.startingGame.connect(OnStartingGame)
	SignalManager.endGame.connect(OnEndGame)
	SignalManager.restartingGame.connect(OnStartingGame)
	
	initialize()
	populateLevelSegmentArr()
	
func initialize():
	gS = gameState.INACTIVE
	Globals.totalAmountScrolled = Globals.spawnNewLevelSegmentStartingPoint
	Globals.bubbleResources = Globals.totalBubbleResources
	manageBubbleResources()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (Globals.bubbleResources < Globals.bubbleLifeTotal):
		bubbleResourceCounter += delta
		
	match gS:
		gameState.IDLE:
			manageBubbleResources()
			timeBeforeLevelMoveCounter += delta
			if (timeBeforeLevelMoveCounter > Globals.timeBeforeLevelMoveStart):
				gS = gameState.ACTIVE
		gameState.ACTIVE:
			manageBubbleResources()
			levelHandle.global_position.y += Globals.levelMoveSpeed*delta
			Globals.totalAmountScrolled += Globals.levelMoveSpeed*delta
			Globals.totalProgress += Globals.levelMoveSpeed*delta
			if (Globals.totalAmountScrolled > Globals.spawnNewLevelSegmentTreshold):
				Globals.totalAmountScrolled = 0
				loadRandomSegment()
				
				

func manageBubbleResources():
	if (bubbleResourceCounter > Globals.bubbleRecoveryTime):
		if (Globals.bubbleResources < Globals.bubbleLifeTotal):
			Globals.bubbleResources += 1
			SignalManager.bubbleResourceSpent.emit(0)
		bubbleResourceCounter = 0

func loadRandomSegment(offset:float = 0.0):
	if (levelSegmentArr.size() <= 0):
		print("NO LEVEL SEGMENTS TO CHOOSE FROM!")
		return
	var element = levelSegmentArr.pick_random()
	var node = element.instantiate()
	levelHandle.add_child(node)
	if (lastLevelSegment):
		node.global_position.y = lastLevelSegment.global_position.y - lastLevelSegment.sizeHandle.size.y 
	else:
		node.global_position = Vector2(0,round(Globals.GetCamYPos()-Globals.GetHalfViewHeight()+offset))#Vector2(randf_range(0,float(get_viewport().size.x)),Globals.cameraHandle.global_position.y-(get_viewport().size.y/2)-150)
	lastLevelSegment = node
	
func populateLevelSegmentArr():
	var fileArr = []
	var path = "res://assets/levelSegments/"
	var dir = DirAccess.open(path)
	if dir:
		print("DIR IS FOUND!")
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				pass
			else:
				fileArr.append(file_name)
				print("FOuND FILE: "+file_name)
			file_name = dir.get_next()

	for file in fileArr:
		var result = ResourceLoader.load(path+file)
		if (result):
			levelSegmentArr.append(result)

func OnGoingToGame():
	SignalManager.startingGame.emit()

func OnStartingGame():
	var plat = startingPlatform.instantiate()
	levelHandle.add_child(plat)
	plat.global_position.y = Globals.GetCamYPos()-Globals.GetHalfViewHeight()
	Globals.cameraHandle.OnOverrideCamera(Vector2(0,Globals.GetCamYPos()-Globals.GetViewHeight()+(Globals.cellSize*2)))
	Globals.totalProgress = 0
	timeBeforeLevelMoveCounter = 0
	gS = gameState.IDLE
	
	loadRandomSegment(-Globals.cellSize * 2)
	loadRandomSegment()
	loadRandomSegment()
	
func OnEndGame():
	SignalManager.goingToEndMenu.emit()
