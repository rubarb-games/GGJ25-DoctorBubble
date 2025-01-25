extends Control

enum UIState { START, TUTORIAL, GAME, END}
var uS:UIState = UIState.START

var bubbleResourceCounter:Array[ColorRect]

@export var resourceCounterParentHandle:Control

@export var startMenuHandle:Control
@export var tutorialMenuHandle:Control
@export var endMenuHandle:Control

@export var scoreboardHandle:Label

var scoreboardUpdateCounter:float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	SignalManager.bubbleResourceSpent.connect(OnResourceSpent)
	
	SignalManager.goingToStartMenu.connect(OnGoToStartMenu)
	SignalManager.goingToTutorialMenu.connect(OnGoToTutorial)
	SignalManager.goingToGame.connect(OnGoToGame)
	SignalManager.goingToEndMenu.connect(OnGoToEndMenu)
	SignalManager.restartingGame.connect(OnRestartGame)
	
	bubbleResourceCounter = []
	for obj in resourceCounterParentHandle.get_children():
		bubbleResourceCounter.append(obj)

	Globals.totalBubbleResources = bubbleResourceCounter.size()
	Globals.bubbleResources = Globals.totalBubbleResources
	scoreboardHandle.text = ""

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	scoreboardUpdateCounter += delta
	
	if (scoreboardUpdateCounter > 1.0):
		scoreboardUpdateCounter = 0
		scoreboardHandle.text = str(round(Globals.totalProgress))
		SignalManager.scoreboardUpdated.emit()

func updateResources():
	for i in range(bubbleResourceCounter.size()):
		if i < Globals.bubbleResources:
			bubbleResourceCounter[i].self_modulate = Color.WHITE
		else:
			bubbleResourceCounter[i].self_modulate = Color.WEB_GREEN
		

func OnResourceSpent(amount:int):
	updateResources()

func OnGoToTutorial():
	startMenuHandle.visible = false
	tutorialMenuHandle.visible = true
	
func OnGoToStartMenu():
	startMenuHandle.visible = true
	tutorialMenuHandle.visible = false
	endMenuHandle.visible = false
	
func OnGoToGame():
	tutorialMenuHandle.visible = false
	
func OnGoToEndMenu():
	endMenuHandle.visible = true
	
func OnRestartGame():
	endMenuHandle.visible = false

func OnMenuButtonPressed(butt):
	match butt:
		"start":
			SignalManager.goingToTutorialMenu.emit()
		"end":
			SignalManager.restartingGame.emit()
		"tutorial":
			SignalManager.goingToGame.emit()
