extends Node2D
class_name GameManager

enum gameState { ACTIVE, PAUSED, IN_PROGRESS, IDLE }
var gS:gameState

var bubbleResourceCounter:float = 0.0
var spawnNewlevelSegmentTimer:float = 0.0

var levelSegmentArr:Array[PackedScene]

@export var levelHandle:Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	gS = gameState.ACTIVE
	
	populateLevelSegmentArr()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (Globals.bubbleResources < Globals.bubbleLifeTotal):
		bubbleResourceCounter += delta
		
	if (bubbleResourceCounter > Globals.bubbleRecoveryTime):
		if (Globals.bubbleResources < Globals.bubbleLifeTotal):
			Globals.bubbleResources += 1
			SignalManager.bubbleResourceSpent.emit(0)
		bubbleResourceCounter = 0
		
	match gS:
		gameState.ACTIVE:
			levelHandle.global_position.y += Globals.levelMoveSpeed*delta
			spawnNewlevelSegmentTimer += Globals.levelMoveSpeed*delta
			if (spawnNewlevelSegmentTimer > Globals.spawnNewLevelSegmentTreshold):
				spawnNewlevelSegmentTimer = 0
				loadRandomSegment()
				

func loadRandomSegment():
	if (levelSegmentArr.size() <= 0):
		print("NO LEVEL SEGMENTS TO CHOOSE FROM!")
		return
	var element = levelSegmentArr.pick_random()
	print(element)
	var node = element.instantiate()
	levelHandle.add_child(node)
	node.global_position = Vector2(randf_range(0,float(get_viewport().size.x)),Globals.cameraHandle.global_position.y-(get_viewport().size.y/2)-150)
	
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
