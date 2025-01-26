extends Node

signal GameStart

#Args: int amount
signal bubbleResourceSpent

signal goingToStartMenu
signal goingToTutorialMenu
signal goingToEndMenu

signal goingToGame
signal restartingGame
signal startingGame
signal endGame

signal cameraInPlaceForStart

signal failedBubble
signal scoreboardUpdated

signal EnemyOnScreen
signal BulletFired
signal hitByBullet
signal hitByEnemy

#args: number
signal scoreMilestone

#args: position, text
signal textPopup

signal playerJump
signal playerDie
signal playerWalk
signal playerIdle
signal BubbleMake
signal BubbleDie
