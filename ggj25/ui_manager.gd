extends Control

enum UIState { START, TUTORIAL, GAME, END}
var uS:UIState = UIState.START

var bubbleResourceCounter:Array[ColorRect]

@export var resourceCounterParentHandle:Control

@export var startMenuHandle:Control
@export var tutorialMenuHandle:Control
@export var endMenuHandle:Control

@export var scoreboardHandle:Label
@export var scoreboardPopupHandle:Control
@export var scoreboardPopupLabelHandle:Label
@export var scoreboardPopupImageHandle:Sprite2D
@export var scoreboardPopupCurve:Curve
@export var scoreboardPopupRotateCurve:Curve

@export var backgroundImage:TextureRect
@export var backgroundRotationCurve:Curve

var scoreboardUpdateCounter:float = 0.0
@export var allAchiData:Array[AchiData]

@export var fadeToWhiteHandle:ColorRect
@export var fadeToBlackHandle:ColorRect

@export var ingamePopupTextHandle:Label
@export var ingamePopupTextSmallHandle:Label
@export var ingamePopupTextCurve:Curve

# Called when the node enters the scene tree for the first time.
func _ready():
	SignalManager.bubbleResourceSpent.connect(OnResourceSpent)
	
	SignalManager.goingToStartMenu.connect(OnGoToStartMenu)
	SignalManager.goingToTutorialMenu.connect(OnGoToTutorial)
	SignalManager.goingToGame.connect(OnGoToGame)
	SignalManager.goingToEndMenu.connect(OnGoToEndMenu)
	SignalManager.restartingGame.connect(OnRestartGame)
	SignalManager.textPopup.connect(PopupText)

	
	bubbleResourceCounter = []
	for obj in resourceCounterParentHandle.get_children():
		bubbleResourceCounter.append(obj)

	Globals.totalBubbleResources = bubbleResourceCounter.size()
	Globals.bubbleResources = Globals.totalBubbleResources
	scoreboardHandle.text = ""
	scoreboardPopupHandle.modulate.a = 0
	
	SignalManager.goingToStartMenu.emit()
	
	setupBackground()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	scoreboardUpdateCounter += delta
	
	if (scoreboardUpdateCounter > 1.0 and Globals.playerHandle.playerActive):
		scoreboardUpdateCounter = 0
		scoreboardHandle.text = str(round(Globals.totalProgress))
		checkAchievement()
		var s = SimonTween.new()
		s.createTween(scoreboardHandle,"scale",Vector2(1,1),0.25,null,SimonTween.PINGPONG)
		SignalManager.scoreboardUpdated.emit()
		
func checkAchievement():
	var data:AchiData
	for d in range(allAchiData.size()):
		if (!allAchiData[d].hasBeenActivated and Globals.totalProgress > allAchiData[d].scoreTreshold):
			allAchiData[d].hasBeenActivated = true
			ScoreboardPopup(allAchiData[d].rewardText,allAchiData[d].rewardSprite)
			fadeToWhite(1)

func setupBackground():
	var s = SimonTween.new()
	s.createTween(backgroundImage,"rotation",360,2000,backgroundRotationCurve).setLoops(-1)

func updateResources(amount:int):
	var lastReference
	for i in range(bubbleResourceCounter.size()):
		if i < Globals.bubbleResources:
			bubbleResourceCounter[i].modulate = Color.WHITE
		else:
			if (is_instance_valid(lastReference)):
				if (lastReference.modulate == Color.WHITE):
					var s = SimonTween.new()
					if (amount < 0):
						bubbleResourceCounter[i].scale = Vector2(1,1)
						s.createTween(bubbleResourceCounter[i],"scale",Vector2(0.5,0.5),0.075,null,SimonTween.PINGPONG)
					else:
						lastReference.scale = Vector2(1,1)
						s.createTween(lastReference,"scale",Vector2(0.5,0.5),0.075,null,SimonTween.PINGPONG)
			bubbleResourceCounter[i].modulate = Color.WEB_GREEN
		lastReference = bubbleResourceCounter[i]
		

func OnResourceSpent(amount:int):
	updateResources(amount)

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

func ScoreboardPopup(text:String,sp:Texture):
	var s = SimonTween.new()
	var a = SimonTween.new()
	scoreboardPopupLabelHandle.text = text
	scoreboardPopupImageHandle.texture = sp
	scoreboardPopupHandle.modulate.a = 0
	scoreboardPopupHandle.scale = Vector2(0.15,0.15)
	a.createTween(scoreboardPopupHandle,"scale",Vector2(0.5,0.5),1.5)
	await s.createTween(scoreboardPopupHandle,"modulate:a",1,2,scoreboardPopupCurve).anotherParallel().\
	createTween(scoreboardPopupImageHandle,"rotation",deg_to_rad(360),1,scoreboardPopupRotateCurve).tweenDone
	scoreboardPopupHandle.modulate.a = 0
	scoreboardPopupHandle.scale = Vector2(0.65,65)

func fadeToBlack(mode:int = 0):
	match mode:
		1:
			var s = SimonTween.new()
			fadeToBlackHandle.modulate.a = 0
			await s.createTween(fadeToBlackHandle,"modulate:a",1,0.25,null,SimonTween.PINGPONG).tweenDone
			fadeToBlackHandle.modulate.a = 0
		2:
			var s = SimonTween.new()
			fadeToBlackHandle.modulate.a = 0
			await s.createTween(fadeToBlackHandle,"modulate:a",1,1.25,null,SimonTween.NORMAL).tweenDone
			fadeToBlackHandle.modulate.a = 1
		3:
			var s = SimonTween.new()
			fadeToBlackHandle.modulate.a = 1
			await s.createTween(fadeToBlackHandle,"modulate:a",-1,1.25,null,SimonTween.NORMAL).tweenDone
			fadeToBlackHandle.modulate.a = 0
	
func fadeToWhite(mode:int = 0):
	match mode:
		1:
			var s = SimonTween.new()
			fadeToWhiteHandle.modulate.a = 0
			await s.createTween(fadeToWhiteHandle,"modulate:a",1,0.25,null,SimonTween.PINGPONG).tweenDone
			fadeToWhiteHandle.modulate.a = 0
		2:
			var s = SimonTween.new()
			fadeToWhiteHandle.modulate.a = 0
			await s.createTween(fadeToWhiteHandle,"modulate:a",1,1.25,null,SimonTween.NORMAL).tweenDone
			fadeToWhiteHandle.modulate.a = 1
		3:
			var s = SimonTween.new()
			fadeToWhiteHandle.modulate.a = 1
			await s.createTween(fadeToWhiteHandle,"modulate:a",-1,1.25,null,SimonTween.NORMAL).tweenDone
			fadeToWhiteHandle.modulate.a = 0

func PopupText(pos:Vector2, txt:String, uiSpace:bool = false, smallText:bool = false):
	var labelHandle = ingamePopupTextHandle
	if (smallText):
		labelHandle = ingamePopupTextSmallHandle
	
	if (!uiSpace):
		pos.y -= Globals.cameraHandle.global_position.y - Globals.GetHalfViewHeight()
	pos -= labelHandle.pivot_offset
	labelHandle.global_position = pos + Vector2(0,25)
	labelHandle.text = txt
	labelHandle.modulate.a = 0
	var s = SimonTween.new()
	await s.createTween(labelHandle,"modulate:a",1,1,ingamePopupTextCurve).anotherParallel().\
	createTween(labelHandle,"position:y",-25,0.5).tweenDone
	labelHandle.modulate.a = 0
	
