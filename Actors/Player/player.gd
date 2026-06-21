class_name Player
extends CharacterBody2D

#region variables

enum State {
	IDLE,
	RUN,
	JUMP,
	FALL,
	WALL_SLIDE,
	ROLL,
	GROUND_ATTACK,
	AIR_ATTACK,
	HURT,
	DEAD,
	REST,
	SHOW_ITEM
}
var current_state: State = State.IDLE

const ATTACK_PUSH_FORCE: float = 100.0

@export var stats: Stats

@export_group("Speed")
@export var acceleration: float = 600.0
@export var friction: float = 800.0
@export var air_roll_friction: float = 1200.0
@export var roll_friction: float = 5000.0
@export var roll_speed: float = 200.0
@export var air_roll_speed_multiplier: float = 0.85

@export_group("Jump")
@export var jump_cutoff: float = 0.4 

@export_group("Wall Slide and Jump")
@export var wall_slide_speed: float = 10.0
@export var wall_jump_pushback: float = 175.0
@export var wall_jump_lift: float = -250.0

@onready var visuals: Node2D = $Visuals
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var coyote_jump_timer: Timer = $Timers/CoyoteJumpTimer
@onready var buffer_jump_timer: Timer = $Timers/BufferJumpTimer
@onready var sprite: Sprite2D = %Sprite2D
@onready var dust_animated_sprite: AnimatedSprite2D = %DustAnimatedSprite
@onready var health_component: HealthComponent = %HealthComponent
@onready var hitbox_component: HitboxComponent = %Hitbox
@onready var flash_animation_player: AnimationPlayer = $FlashAnimationPlayer
@onready var looted_item_sprite: Sprite2D = %LootedItemSprite
@onready var wall_coyote_timer: Timer = $Timers/WallCoyoteTimer
@onready var pogo_particles: GPUParticles2D = $PogoParticles

var is_dead: bool = false
var _was_on_floor: bool = false
var _was_on_wall: bool = false
var last_wall_normal: Vector2 = Vector2.ZERO
var can_air_roll: bool = true

var tween: Tween

#endregion

#region switch / update states
func switch_state(new_state: State) -> void:
	if current_state == new_state:
		return
	
	var previous_state: State = current_state
	current_state = new_state
	
	match current_state:
		State.IDLE:
			animation_player.play("idle")
			looted_item_sprite.hide()
			if previous_state == State.FALL:
				apply_squish(1.3, 0.8)
				play_landing_dust_animation()
		
		State.RUN:
			animation_player.play("run")
			if previous_state == State.FALL:
				apply_squish(1.3, 0.6)
				play_landing_dust_animation()
		
		State.JUMP:
			animation_player.play("jump")
			if previous_state == State.FALL:
				return
			if previous_state != State.WALL_SLIDE:
				play_jumping_dust_animation()
		
		State.FALL:
			animation_player.play("fall")
		
		State.WALL_SLIDE:
			animation_player.play("wall_slide")
			
		State.GROUND_ATTACK:
				animation_player.play("ground_attack")
		
		State.AIR_ATTACK:
			animation_player.play("air_attack")
		
		State.ROLL:
			if is_on_floor():
				animation_player.play("roll")
			else:
				velocity.y = stats.jump_velocity * 0.5
				animation_player.play("air_dash")
				play_jumping_dust_animation()
			apply_squish(1.3, 0.7)
		
		State.HURT:
			animation_player.play("hurt")
			velocity = Vector2.ZERO
			GameEvents.emit_camera_shake(0.5)
		
		State.DEAD:
			is_dead = true
			animation_player.play("death")
		
		State.REST:
			velocity = Vector2.ZERO
			animation_player.play("campfire")
		
		State.SHOW_ITEM:
			animation_player.play("item_chest")
			velocity = Vector2.ZERO

func _get_post_action_state() -> State:
	if not is_on_floor():
		if is_on_wall_only() and velocity.y > 0.0:
			return State.WALL_SLIDE
		if velocity.y < 0.0:
			return State.JUMP
		return State.FALL

	if velocity.x != 0.0:
		return State.RUN

	return State.IDLE

func _update_state() -> void:
	match current_state:
		State.GROUND_ATTACK: return
		State.AIR_ATTACK: return
		State.ROLL: return
		State.HURT: return
		State.DEAD: return
		State.REST: return
		State.SHOW_ITEM: return
	
	var next_state: State = _get_post_action_state()
	if next_state == State.WALL_SLIDE:
		visuals.scale.x = -sign(get_wall_normal().x)

	switch_state(next_state)

#endregion


#region _handle

func _handle_oneway_drop_through() -> void:
	if current_state == State.IDLE or current_state == State.RUN:
		if Input.is_action_pressed("down") and Input.is_action_just_pressed("jump"):
			global_position.y += 1
	else:
		return


func _handle_horizontal_movement(delta: float) -> void:
	match current_state:
		State.HURT: return
		State.REST: return
		State.SHOW_ITEM: return
		State.ROLL:
			if is_on_floor():
				velocity.x = visuals.scale.x * roll_speed
			else:
				velocity.x = visuals.scale.x * (roll_speed * air_roll_speed_multiplier)
			return
	
	var direction: float = Input.get_axis("move_left", "move_right")
	
	var active_speed: float = stats.speed
	if current_state == State.GROUND_ATTACK and is_on_floor():
		active_speed = stats.speed * 0.6
	
	if direction != 0.0:
		velocity.x = move_toward(velocity.x, direction * active_speed, acceleration * delta)
		_update_facing_direction(direction)
	else:
		velocity.x = move_toward(velocity.x, 0, friction * delta)


func _handle_jump() -> void:
	match current_state:
		State.HURT: return
		State.REST: return
		State.SHOW_ITEM: return
	
	if current_state == State.IDLE or current_state == State.RUN:
		if Input.is_action_pressed("down"):
			return
	
	_check_wall_coyote()
	_check_wall_jump()
	_check_buffer_jump()
	_check_coyote_jump()
	
	var can_jump: bool = is_on_floor() or not coyote_jump_timer.is_stopped()
	var requested_jump: bool = (Input.is_action_just_pressed("jump") or not buffer_jump_timer.is_stopped())
	
	if requested_jump and can_jump:
		velocity.y = stats.jump_velocity
		buffer_jump_timer.stop()
		coyote_jump_timer.stop()
		
		apply_squish(0.5, 1.5)
	
	if Input.is_action_just_released("jump") and velocity.y < 0.0:
		velocity.y *= jump_cutoff


func _handle_attack() -> void:
	if current_state == State.HURT or current_state == State.REST:
		return
	
	if Input.is_action_just_pressed("attack"):
		if is_on_floor() and current_state != State.GROUND_ATTACK:
			switch_state(State.GROUND_ATTACK)
		elif not is_on_floor() and current_state != State.AIR_ATTACK:
			switch_state(State.AIR_ATTACK)


func _handle_roll() -> void:
	if check_common_conditions():
		return
	
	if Input.is_action_just_pressed("roll") and current_state != State.ROLL and current_state != State.GROUND_ATTACK and current_state != State.AIR_ATTACK:
		if is_on_floor() or can_air_roll:
			if not is_on_floor():
				can_air_roll = false
			switch_state(State.ROLL)

#endregion

func _ready() -> void:
	switch_state(State.IDLE)
	animation_player.animation_finished.connect(_on_animation_finished)
	
	health_component.health_changed.connect(func(current_health, max_health): GameEvents.emit_player_health_changed(current_health, max_health))
	health_component.damaged.connect(func(): switch_state(State.HURT))
	health_component.died.connect(func(): switch_state(State.DEAD))
	health_component.set_max_health(GameState.unlocked_max_health, false)
	
	hitbox_component.hit_hurtbox.connect(_on_hitbox_hit)
	
	if GameState.saved_player_pos != Vector2.ZERO:
		global_position = GameState.saved_player_pos
	
	if GameState.saved_player_health != -1:
		health_component.current_health = GameState.saved_player_health
	else:
		# New game
		health_component.current_health = health_component.max_health
	
	GameEvents.player_health_changed.emit(health_component.current_health, health_component.max_health)
	
	GameState.rebuild_player_stats()


func _physics_process(delta: float) -> void:
	_apply_gravity(delta)
	
	if is_dead:
		return
	
	_handle_horizontal_movement(delta)
	_handle_jump()
	_handle_attack()
	_handle_roll()
	_handle_oneway_drop_through()
	
	if is_on_floor():
		can_air_roll = true
	_was_on_floor = is_on_floor()
	
	move_and_slide()
	
	_update_state()


func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		if is_on_wall_only() and velocity.y > 0:
			velocity.y = min(velocity.y + stats.fall_gravity * delta, wall_slide_speed)
		else:
			if velocity.y < 0.0:
				velocity.y += stats.jump_gravity * delta
			else:
				velocity.y += stats.fall_gravity * delta


func check_common_conditions() -> bool:
	return current_state == State.HURT or \
		current_state == State.REST or \
		current_state == State.WALL_SLIDE or \
		current_state == State.SHOW_ITEM


func _apply_pogo() -> void:
	can_air_roll = true
	velocity.y = stats.jump_velocity * 0.9
	pogo_particles.restart()
	apply_squish(0.6, 1.5)
	GameEvents.emit_camera_shake(0.2)


func _check_wall_coyote() -> void:
	if is_on_wall_only():
		_was_on_wall = true
		last_wall_normal = get_wall_normal()
	elif _was_on_wall and not is_on_floor():
		_was_on_wall = false
		wall_coyote_timer.start()


func _check_wall_jump() -> void:
	if Input.is_action_just_pressed("jump"):
		if is_on_wall_only() or not wall_coyote_timer.is_stopped():
			var wall_normal: Vector2 = get_wall_normal()
			
			if not is_on_wall_only():
				wall_normal = last_wall_normal
			
			wall_coyote_timer.stop()
		
			velocity.x = wall_normal.x * wall_jump_pushback
			velocity.y = wall_jump_lift
			
			visuals.scale.x = sign(velocity.x)
			
			apply_squish(0.6, 1.4)


func _check_coyote_jump() -> void:
	if _was_on_floor and not is_on_floor() and velocity.y >= 0.0:
		coyote_jump_timer.start()


func _check_buffer_jump() -> void:
	if (not is_on_floor() and velocity.y > 0.0 and
		Input.is_action_just_pressed("jump") and buffer_jump_timer.is_stopped()):
			buffer_jump_timer.start()

func apply_squish(squish_x: float, squish_y: float) -> void:
	sprite.scale = Vector2(squish_x, squish_y)
	
	if tween != null and tween.is_running():
		tween.kill()
	tween = create_tween().set_parallel(true)
	tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(sprite, "scale", Vector2.ONE, 0.35)


func receive_item(item: ItemData) -> void:
	if item != null and item.icon != null:
		looted_item_sprite.texture = item.icon
		looted_item_sprite.show()
	switch_state(State.SHOW_ITEM)


func play_landing_dust_animation() -> void:
	dust_animated_sprite.show() 
	dust_animated_sprite.global_position = global_position
	dust_animated_sprite.global_position.y -= 2
	dust_animated_sprite.reset_physics_interpolation()
	dust_animated_sprite.play("landing")


func play_jumping_dust_animation() -> void:
	dust_animated_sprite.stop()
	dust_animated_sprite.show() 
	dust_animated_sprite.global_position = global_position
	dust_animated_sprite.global_position.y += 2
	dust_animated_sprite.reset_physics_interpolation()
	dust_animated_sprite.play("jump")


func _update_facing_direction(direction: float) -> void:
	if current_state == State.GROUND_ATTACK or current_state == State.AIR_ATTACK:
		return
	
	visuals.scale.x = sign(direction)


# ------------------------------------------ GETTERS -------------------------------------------------------

func get_facing_direction() -> int:
	return visuals.scale.x

func get_current_health() -> int:
	return health_component.current_health

func get_total_gold() -> int:
	return GameState.total_gold

# ------------------------------------------ _ON_ -------------------------------------------------------

func _on_hitbox_hit(hurtbox: HurtboxComponent) -> void:
	if current_state == State.AIR_ATTACK:
		_apply_pogo()
	elif current_state == State.GROUND_ATTACK:
		var push_dir = sign(global_position.x - hurtbox.global_position.x)
		if push_dir == 0.0:
			push_dir = 1.0
		
		velocity.x = push_dir * ATTACK_PUSH_FORCE


func _on_animation_finished(animation_name: StringName) -> void:
	match current_state:
		State.GROUND_ATTACK:
			if animation_name == &"ground_attack":
				switch_state(State.IDLE)
		State.AIR_ATTACK:
			if animation_name == &"air_attack":
				switch_state(State.FALL)
		State.ROLL:
			if animation_name == &"roll" or animation_name == &"air_dash":
				var input_dir := Input.get_axis("move_left", "move_right")
				
				if input_dir == 0.0:
					if not is_on_floor():
						velocity.x = move_toward(velocity.x, 0, air_roll_friction * get_process_delta_time())
					else:
						velocity.x = move_toward(velocity.x, 0, roll_friction * get_process_delta_time()) 
				else:
					velocity.x = clamp(velocity.x, -stats.speed, stats.speed)
				
				switch_state(_get_post_action_state())
		State.HURT:
			if animation_name == &"hurt":
				switch_state(_get_post_action_state())
		State.SHOW_ITEM:
			if animation_name == &"item_chest":
				looted_item_sprite.hide()
				switch_state(State.IDLE)
