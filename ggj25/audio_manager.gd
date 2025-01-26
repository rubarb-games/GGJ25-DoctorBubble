extends Node2D

@export var streamPlayer:AudioStreamPlayer2D

@export var popSounds:Array[AudioStream]

@export var music:AudioStreamPlayer2D
@export var jumpSound:AudioStreamPlayer2D
@export var dieSound:AudioStreamPlayer2D
@export var walkSound:AudioStreamPlayer2D

@export var buttonSound:AudioStream
@export var enemyOnScreen:AudioStream

@export var achievementSound:AudioStreamPlayer2D

@export var bubbleMake:AudioStreamPlayer2D
@export var bubbleDie:AudioStreamPlayer2D

@export var musicCurve:Curve
var audioTimer:float = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	SignalManager.playerJump.connect(OnPlayerJump)
	SignalManager.playerWalk.connect(OnPlayerWalk)
	SignalManager.playerDie.connect(OnPlayerDie)
	SignalManager.BubbleMake.connect(OnBubbleMake)
	SignalManager.BubbleDie.connect(OnBubbleDie)
	SignalManager.BulletFired.connect(OnBulletFired)
	SignalManager.EnemyOnScreen.connect(OnEnemyOnScreen)
	SignalManager.startingGame.connect(OnStartingGame)
	SignalManager.endGame.connect(OnEndGame)
	SignalManager.scoreMilestone.connect(OnScoreMilestone)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	audioTimer += delta*0.33
	var mAT = fmod(audioTimer,1)
	music.pitch_scale = lerp(0.95,1.05,musicCurve.sample(mAT))
	self.global_position = Globals.playerHandle.global_position
	
func OnPlayerJump():
	jumpSound.play()
	

func OnPlayerWalk():
	walkSound.pitch_scale = randf_range(0.5,1.5)
	walkSound.play()

func OnPlayerDie():
	dieSound.play()
	
func OnBubbleMake(size):
	bubbleMake.pitch_scale = (1 - (size/3))
	bubbleMake.play()
	
func OnBubbleDie(size):
	bubbleDie.pitch_scale = (1 - (size/3))
	bubbleDie.stream = popSounds.pick_random()
	bubbleDie.play()
	
func OnBulletFired():
	streamPlayer.stream = buttonSound
	streamPlayer.play()
	
func OnEnemyOnScreen():
	streamPlayer.stream = enemyOnScreen
	streamPlayer.play()
	
func OnStartingGame():
	music.play()
	
func OnEndGame():
	music.stop()
	
func OnScoreMilestone():
	achievementSound.play()
