extends Node
class_name SimonTween

enum tweenState { PLAYING, PAUSED, IDLE, STEPPED }
enum {NORMAL, PINGPONG, LOOPING, REVERSED, LOOPING_PINGPONG}
var ts:tweenState = tweenState.IDLE
var tt = SimonTween.NORMAL
var isRelative:bool = false
var isFullChainLooping:bool = false

var obj:Node
var pPath:NodePath
var endResult
var time:float = 1.0
var intCurve:Curve
var modDValue
var initialValue
var relativeOffset
var returnOnEndVal:bool = false
var loops:int = 0

var breakLoop:bool = false

var deltaValue:float
var totalTweenMovement:Variant
var sceneTreeHandle:SceneTree

var chainedTween:SimonTween
var waitingForTween: bool
var parentTween:SimonTween

signal tweenDone
signal tweenDoneFullChain
signal tweenResumed
signal tweenPaused
signal fullChainLoopDone

func createTween(objArg:Node, propPath:String, endResultArg, timeArg:float = 1, intCurveArg:Curve = null, typ = SimonTween.NORMAL):
	sceneTreeHandle = Engine.get_main_loop() as SceneTree
	Engine.get_physics_frames()

	if (time <= 0 or time > 100):
		return self
	
	if (!intCurveArg):
		intCurve = Curve.new()
		intCurve.add_point(Vector2(0,0))
		intCurve.add_point(Vector2(1,1))
	else:
		intCurve = intCurveArg
	
	tt = typ
	
	obj = objArg
	pPath = NodePath(propPath)
	time = timeArg
	endResult = endResultArg
	doTween()
		
	return self

func setMode(s:String):
	s.to_lower()
	match s:
		"normal":
			tt = SimonTween.NORMAL
		"pingpong":
			tt = SimonTween.PINGPONG
		"looping":
			tt = SimonTween.LOOPING
	
	return self

func setRelative(r:bool):
	isRelative = r
	
	return self

func pause():
	ts = tweenState.PAUSED
	
func resume():
	ts = tweenState.PLAYING

func doTween():
	
	await sceneTreeHandle.process_frame
	
	if (waitingForTween):
		await parentTween.tweenDone
	
	if (!obj):
		return
	
	deltaValue = 0
	#modDValue = 0
	var i = 0
	initialValue = obj.get_indexed(pPath)
	relativeOffset = initialValue
	match tt:
		SimonTween.NORMAL:
				while deltaValue < time and !breakLoop:
					if (ts == tweenState.PAUSED):
						await tweenResumed
					deltaValue += getDelta()
					await doTweenFunc(deltaValue)
		SimonTween.PINGPONG:
			while deltaValue < (time * 2) and !breakLoop:
					if (ts == tweenState.PAUSED):
						await tweenResumed
					deltaValue += getDelta()
					var actualDeltaValue = deltaValue - clamp(deltaValue-time,0,time)*2
					await doTweenFunc(actualDeltaValue)
		SimonTween.LOOPING:
			while (deltaValue/time <= loops or loops == -1) and !breakLoop:
				if (ts == tweenState.PAUSED):
					await tweenResumed
				deltaValue += getDelta()
				await doTweenFunc(fmod(deltaValue,time))
	
	done()

func doTweenFunc(delta):
	#Cache previous frame modified delta value
	var prevMod = modDValue
	#New var to be modified with offset
	var modDMod
	#Calculate new delta value
	modDValue = (intCurve.sample(delta/time) * endResult)
	modDMod = modDValue
	
	#Relative accounts for other transformations happening inbetween by offsetting the animation by previous frame's transform
	if (isRelative):
		modDMod += obj.get_indexed(pPath) - prevMod
	else:
		modDMod += initialValue

	if (!obj):
		return
	obj.set_indexed(pPath,modDMod)
	await sceneTreeHandle.process_frame
	return true
	
func stop():
	breakLoop = true

func setLoops(l = 1):
	loops = l
	
	return self

func done():
	#Looping
	if (!breakLoop):
		if (loops > 0):
			loops -= 1
			restart()
			return null
		elif (loops == -1):
			restart()
			return null
	
	if (returnOnEndVal):
		if (isRelative):
			obj.set_indexed(pPath,obj.get_indexed(pPath)-intCurve.sample(1)*endResult)
		else:
			obj.set_indexed(pPath,initialValue)
	#else:
			#obj.set_indexed(pPath,intCurve.sample(1) * endResult)
	
	tweenDone.emit()
	if (!chainedTween):
		if (isFullChainLooping):
			await fullChainLoopDone
		tweenDoneFullChain.emit()
	
	return self

func restart():
	doTween()

func rtrnOnEnd():
	returnOnEndVal = true
	return self

func getDelta():
	return Engine.get_main_loop().root.get_process_delta_time()

func another():
	chainedTween = SimonTween.new()
	chainedTween.waitingForTween = true
	chainedTween.parentTween = self
		
	return chainedTween
	
func anotherParallel():
	chainedTween = SimonTween.new()
	chainedTween.parentTween = self
		
	return chainedTween

func loopFullChain(l = 1):
	if (!parentTween):
		return self
		
	await loopFullChainFunc(l)
	
	isFullChainLooping = false
	fullChainLoopDone.emit()
	return self
	
func loopFullChainFunc(l):
	var pTween = parentTween
	isFullChainLooping = true
	var i = 0
	while i <= l:
		while pTween:
			pTween.restart()
			if (pTween.parentTween):
				pTween.waitingForTween = true
				
			pTween = pTween.parentTween
		#await parentTween.tweenDone
		i += 1
	return true
