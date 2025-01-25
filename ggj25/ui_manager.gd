extends Control

var bubbleResourceCounter:Array[ColorRect]

@export var resourceCounterParentHandle:Control

# Called when the node enters the scene tree for the first time.
func _ready():
	SignalManager.bubbleResourceSpent.connect(OnResourceSpent)
	
	bubbleResourceCounter = []
	for obj in resourceCounterParentHandle.get_children():
		bubbleResourceCounter.append(obj)

	Globals.totalBubbleResources = bubbleResourceCounter.size()
	Globals.bubbleResources

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func updateResources():
	for i in range(bubbleResourceCounter.size()):
		if i < Globals.bubbleResources:
			bubbleResourceCounter[i].self_modulate = Color.WHITE
		else:
			bubbleResourceCounter[i].self_modulate = Color.WEB_GREEN
		

func OnResourceSpent(amount:int):
	updateResources()
