# BeltAudio.gd
extends Node
class_name BeltAudio

@export var sfx_on: AudioStream
@export var sfx_loop: AudioStream
@export var sfx_off: AudioStream
@export var vdb := -10.0
@export var pause_with_game := true

@onready var p_on:   AudioStreamPlayer3D = $On
@onready var p_loop: AudioStreamPlayer3D = $Loop
@onready var p_off:  AudioStreamPlayer3D = $Shutdown

var moving := false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	p_on.stream  = sfx_on
	p_loop.stream = sfx_loop
	p_off.stream  = sfx_off
	_apply_vdb()
	p_on.finished.connect(_on_on_finished)

func _apply_vdb() -> void:
	p_on.volume_db = vdb
	p_loop.volume_db = vdb
	p_off.volume_db = vdb

func set_drive(on: bool) -> void:
	if on == moving: return
	moving = on
	if on:
		# start clip only if not already playing
		if sfx_on and not p_on.playing:
			p_on.play()
		elif sfx_loop and not p_loop.playing:
			p_loop.play()
	else:
		if p_on.playing: p_on.stop()
		if p_loop.playing: p_loop.stop()
		if sfx_off: p_off.play()

func set_paused(paused: bool) -> void:
	if not pause_with_game: return
	# pause/unpause without restarting
	p_on.stream_paused   = paused
	p_loop.stream_paused = paused
	p_off.stream_paused  = paused

	# if resume happens after start already ended, ensure loop runs
	if not paused and moving and not p_on.playing and not p_loop.playing and sfx_loop:
		p_loop.play()

func _on_on_finished() -> void:
	if not moving: return
	if sfx_loop and not p_loop.playing:
		p_loop.play()
