class_name PowerUp extends Area2D

var paused := false
var pause_time_accumulated := 0
var time_at_start := 0

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		body.get_powerup()
		body.powerup_get_sound.play()
		queue_free()
	pass # Replace with function body.


func pause(pausing:=true) -> void:
	paused = pausing
	if pausing:
		$AnimatedSprite2D.pause()
		time_at_start = Time.get_ticks_msec()
	if not pausing:
		$AnimatedSprite2D.play()
		pause_time_accumulated += Time.get_ticks_msec() - time_at_start


func _physics_process(delta: float) -> void:
	if not paused:
		self.rotation = 0.5*sin((Time.get_ticks_msec() - pause_time_accumulated) / (2*PI*100))
	pass
