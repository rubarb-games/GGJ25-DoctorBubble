extends Node2D

enum mouseState { PRESSED, IDLE, IN_PROGRESS, UNAVAILABLE }
var mS:mouseState = mouseState.IDLE

@export var bubbleSmallHandle:PackedScene
@export var bubbleMediumHandle:PackedScene
@export var bubbleLargeHandle:PackedScene

@export var mouseIndicatorParticles:CPUParticles2D
@export var bubbleCreatorHandle:Line2D

@export var perfectLineJiggleCurve:Curve

var bubbleLineArray:Array
var bubbleLineSize:int = 128

var linePlots:int = 0
var linePlotTime:float = 0.0
var linePlotInverval:float = 0.25
var linePlotMouseDelta = 0
var linePlotMouseTreshold = 15.0
var lineCenterPoint = Vector2.ZERO
var lineBounds:Vector4
var lineGoalPositions:Array[LineGoalPosition]
var pointsAtGoal:int = 0
var currentBubbleRadius:float = 0.0

var currentMousePos 
var lastMousePos

# Called when the node enters the scene tree for the first time.
func _ready():
	initialize()
	
func initialize():
	bubbleLineArray.resize(bubbleLineSize)
	bubbleLineArray.fill(Vector2.ZERO)
	#--------------------------------
	#for a in range(bubbleLineSize):
	#	bubbleCreatorHandle.add_point(Vector2.ZERO)

	print(bubbleCreatorHandle.points.size())
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):

	if (mS == mouseState.IN_PROGRESS):
		for a in range(bubbleCreatorHandle.points.size()):	
			if (pointsAtGoal > bubbleCreatorHandle.points.size()-1):
				mS = mouseState.IDLE
				break
			if (!lineGoalPositions[a].isComplete):
				lineGoalPositions[a].progress += delta
				bubbleCreatorHandle.points[a] = lerp(lineGoalPositions[a].startingPoint, lineGoalPositions[a].position,perfectLineJiggleCurve.sample(lineGoalPositions[a].progress))
				if (lineGoalPositions[a].progress > 1):
					bubbleCreatorHandle.points[a] = lineGoalPositions[a].position
					lineGoalPositions[a].isComplete = true
					pointsAtGoal += 1
				

	if (Input.is_action_just_pressed("mouseInteract") and mS == mouseState.IDLE):
		linePlotTime = 0
		linePlots = 0
		currentMousePos = get_global_mouse_position()
		lastMousePos = currentMousePos
		mS = mouseState.PRESSED
		bubbleCreatorHandle.points = []

	if (Input.is_action_pressed("mouseInteract") and mS == mouseState.PRESSED):
		currentMousePos = get_global_mouse_position()
		linePlotTime += delta
		mouseIndicatorParticles.global_position = currentMousePos

		if (linePlotMouseDelta > linePlotMouseTreshold):
			if (linePlots < bubbleLineSize):
				bubbleCreatorHandle.closed = false
				bubbleCreatorHandle.add_point(currentMousePos,linePlots)
				#bubbleCreatorHandle.points[linePlots-1] = currentMousePos
				linePlotTime = 0
				linePlots += 1
				linePlotMouseDelta = 0
			else:
				mouseState.IDLE
		
		linePlotMouseDelta += currentMousePos.distance_to(lastMousePos)
		lastMousePos = currentMousePos
		lineCenterPoint = findCenterPoint(bubbleCreatorHandle)
	else:
		mouseIndicatorParticles.global_position = Vector2(-10,-10)
		if (mS == mouseState.PRESSED):
			if (bubbleCreatorHandle.points.size()>0):
				bubbleCreatorHandle.closed = true
				pointsAtGoal = 0
				if (findLineCircleGoalPositions(bubbleCreatorHandle,lineCenterPoint)):
					spawnBubbleOfRightSize()
					mS = mouseState.IN_PROGRESS
				else:
					mS = mouseState.IDLE
			else:
				mS = mouseState.IDLE
		
func spawnBubbleOfRightSize():
	if (Globals.bubbleResources <= 0):
		return
	
	match true:
		_ when currentBubbleRadius <= 64:
			spawnBubble(0) 
			Globals.bubbleResources -= 1
		_ when currentBubbleRadius <= 128:
			spawnBubble(1)
			Globals.bubbleResources -= 2
		_ when currentBubbleRadius <= 256:
			spawnBubble(2)
			Globals.bubbleResources -= 3
			
	SignalManager.bubbleResourceSpent.emit(0)
		
func findCenterPoint(line:Line2D, snapToGrid:bool = true):
	var centerPoint:Vector2 = Vector2.ZERO
	for a in line.points:
		centerPoint += a
		
	centerPoint = centerPoint / line.points.size()
	return centerPoint

func snapPointToGrid(p:Vector2):
	return Vector2(p.x - fmod(p.x,Globals.cellSize), p.y - fmod(p.y,Globals.cellSize))
		
func snapValueToGrid(v:float):
		var mod = fmod(v,Globals.cellSize)
		if (mod < Globals.cellSize/2):
			v = v - mod
		else:
			v = v - mod + Globals.cellSize
		return v
		
func findLineCircleGoalPositions(line:Line2D,center:Vector2):
	lineGoalPositions.resize(line.points.size())
	lineBounds = findBound(line,center)
	#Calc radius
	#var radius = (lineBounds.x - lineBounds.y) + (lineBounds.z - lineBounds.w) / 2
	var radius = (lineBounds.x - lineBounds.y)
	var rad2 = (lineBounds.z - lineBounds.w)
	if (rad2 > radius):
		radius = rad2
	radius = snapValueToGrid(radius)
	if (radius > Globals.maxBubbleSize):
		return false
	currentBubbleRadius = radius
	#lineCenterPoint = snapPointToGrid(lineCenterPoint)	
	
	for point in range(line.points.size()):
		lineGoalPositions[point] = LineGoalPosition.new()
		var goalPosition = Vector2(bubbleCreatorHandle.points[point] - lineCenterPoint).normalized()
		goalPosition *= radius / 2
		goalPosition += lineCenterPoint
		lineGoalPositions[point].position = goalPosition
		lineGoalPositions[point].startingPoint = bubbleCreatorHandle.points[point]
	return true

func findBound(line:Line2D,center:Vector2):
	var bounds:Vector4 = Vector4(center.x,center.x,center.y,center.y)
	#Bounds = (max x, min x, max y, min y)
	for point in line.points:
		if (point.x > bounds.x):
			bounds.x = point.x
		elif (point.x < bounds.y):
			bounds.y = point.x
		
		if (point.y > bounds.y):
			bounds.z = point.y
		elif (point.y < bounds.w):
			bounds.w = point.y
		
	return bounds

func spawnBubble(size:int = 0):
	var bubble
	if (size == 0):
		bubble = bubbleSmallHandle.instantiate()
	elif (size == 1):
		bubble = bubbleMediumHandle.instantiate()
	elif (size == 2):
		bubble = bubbleLargeHandle.instantiate()

	add_child(bubble)
	bubble.global_position = lineCenterPoint
