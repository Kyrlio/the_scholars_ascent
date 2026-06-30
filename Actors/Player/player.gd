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
	UP_ATTACK,
	AIR_ATTACK,
	HURT,
	DEAD,
	REST,
	SHOW_ITEM,
	CAST_SPELL
}
var current_state: State = State.IDLE
@export var state_locked: bool = false

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

@export_group("Debug Abilities")
@export var debug_sword: bool = false:
	set(value):
		debug_sword = value
		_toggle_ability("sword", value)

@export var debug_pogo: bool = false:
	set(value):
		debug_pogo = value
		_toggle_ability("pogo", value)

@export var debug_wall_slide: bool = false:
	set(value):
		debug_wall_slide = value
		_toggle_ability("wall_slide", value)

@export var debug_wall_jump: bool = false:
	set(value):
		debug_wall_jump = value
		_toggle_ability("wall_jump", value)

@export var debug_roll: bool = false:
	set(value):
		debug_roll = value
		_toggle_ability("roll", value)

@export var debug_double_jump: bool = false:
	set(value):
		debug_double_jump = value
		_toggle_ability("double_jump", value)

@export var debug_air_roll: bool = false:
	set(value):
		debug_air_roll = value
		_toggle_ability("air_roll", value)

@export var debug_water_ball: bool = false:
	set(value):
		debug_water_ball = value
		_toggle_ability("water_ball", value)

func _toggle_ability(ability_name: String, is_unlocked: bool) -> void:
	if not is_inside_tree() or Engine.is_editor_hint():
		return
	
	if is_unlocked and not GameState.has_ability(ability_name):
		GameState.unlocked_abitilities.append(ability_name)
		GameEvents.emit_ability_unlocked(ability_name)
		print("DEBUG: Compétence ajoutée -> ", ability_name)
	elif not is_unlocked and GameState.has_ability(ability_name):
		GameState.unlocked_abitilities.erase(ability_name)
		print("DEBUG: Compétence retirée -> ", ability_name)

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
@onready var ammo_regen_timer: Timer = $Timers/AmmoRegenTimer
@onready var object_pool_projectile: Node = $ObjectPool_Projectile
@onready var hurtbox: HurtboxComponent = %Hurtbox
@onready var run_animated_sprite: AnimatedSprite2D = %RunAnimatedSprite


var is_dead: bool = false
var _was_on_floor: bool = false
var _was_on_wall: bool = false
var last_wall_normal: Vector2 = Vector2.ZERO
var can_air_roll: bool = true
var jump_count: int = 0
var current_water_ammo: int = 0

var tween: Tween
var run_dust_cooldown: float = 0.0

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
			hurtbox.set_deferred("monitoring", true)
			hurtbox.set_deferred("monitorable", true)
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
		
		State.UP_ATTACK:
			animation_player.play("up_attack")
		
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
			GameEvents.emit_player_died()
		
		State.REST:
			velocity = Vector2.ZERO
			animation_player.play("campfire")
		
		State.SHOW_ITEM:
			animation_player.play("item_chest")
			velocity = Vector2.ZERO
		
		State.CAST_SPELL:
			animation_player.play("cast_spell")
			velocity = Vector2.ZERO

func _get_post_action_state() -> State:
	if not is_on_floor():
		if is_on_wall_only() and velocity.y > 0.0 and GameState.has_ability("wall_slide"):
			return State.WALL_SLIDE
		if velocity.y < 0.0:
			return State.JUMP
		return State.FALL
	
	if velocity.x != 0.0:
		return State.RUN
	
	return State.IDLE

func _update_state() -> void:
	if state_locked or GameState.is_gameplay_frozen():
		return
	
	match current_state:
		State.GROUND_ATTACK: return
		State.AIR_ATTACK: return
		State.UP_ATTACK: return
		State.ROLL: return
		State.HURT: return
		State.DEAD: return
		State.REST: return
		State.SHOW_ITEM: return
		State.CAST_SPELL: return
	
	var next_state: State = _get_post_action_state()
	if next_state == State.WALL_SLIDE:
		visuals.scale.x = -sign(get_wall_normal().x)
	
	switch_state(next_state)


func _update_facing_direction(direction: float) -> void:
	if current_state == State.GROUND_ATTACK or current_state == State.AIR_ATTACK or current_state == State.UP_ATTACK:
		return
	
	visuals.scale.x = sign(direction)

#endregion

#region _handle

func _is_on_one_way_platform() -> bool:
	if not is_on_floor():
		return false
	
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		if collision.get_normal().y < -0.7:
			var collider = collision.get_collider()
			if not collider:
				continue
			
			var local_point = collider.to_local(collision.get_position() - collision.get_normal() * 2)
			
			if collider is TileMapLayer:
				var coords = collider.local_to_map(local_point)
				var tile_data = collider.get_cell_tile_data(coords)
				if tile_data:
					for p in tile_data.get_collision_polygons_count(0):
						if tile_data.is_collision_polygon_one_way(0, p):
							return true
	
	return false


func _handle_oneway_drop_through() -> void:
	if current_state == State.IDLE or current_state == State.RUN:
		if Input.is_action_pressed("down") and Input.is_action_just_pressed("jump"):
			if _is_on_one_way_platform():
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
	if (current_state == State.GROUND_ATTACK or current_state == State.UP_ATTACK) and is_on_floor():
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
		if Input.is_action_pressed("down") and _is_on_one_way_platform():
			return
	
	_check_wall_coyote()
	if _check_wall_jump():
		return
	_check_buffer_jump()
	_check_coyote_jump()
	
	var can_jump: bool = is_on_floor() or not coyote_jump_timer.is_stopped()
	var requested_jump: bool = (Input.is_action_just_pressed("jump") or not buffer_jump_timer.is_stopped())
	
	var max_jumps: int = 1
	if GameState.has_ability("double_jump"):
		max_jumps = 2
	max_jumps += stats.extra_jumps
	
	if requested_jump:
		if can_jump:
			velocity.y = stats.jump_velocity
			jump_count = 1
			buffer_jump_timer.stop()
			coyote_jump_timer.stop()
			apply_squish(0.5, 1.5)
			if current_state != State.JUMP:
				switch_state(State.JUMP)
		elif GameState.has_ability("double_jump"):
			var can_double_jump: bool = false
			if jump_count > 0 and jump_count < max_jumps:
				jump_count += 1
				can_double_jump = true
			elif jump_count == 0 and not is_on_floor() and coyote_jump_timer.is_stopped():
				jump_count = 2
				can_double_jump = true
			
			if can_double_jump:
				velocity.y = stats.jump_velocity * 0.85
				buffer_jump_timer.stop()
				apply_squish(0.6, 1.4)
				if current_state != State.JUMP:
					switch_state(State.JUMP)
				
				play_jumping_dust_animation()
	
	if Input.is_action_just_released("jump") and velocity.y < 0.0:
		velocity.y *= jump_cutoff

func _handle_attack() -> void:
	if current_state == State.HURT or current_state == State.REST:
		return
	
	if Input.is_action_just_pressed("attack") and GameState.has_ability("sword"):
		var is_up_pressed: bool = Input.is_action_pressed("up")
		
		if is_on_floor():
			if is_up_pressed and current_state != State.UP_ATTACK:
				switch_state(State.UP_ATTACK)
			elif not is_up_pressed and current_state != State.GROUND_ATTACK:
				switch_state(State.GROUND_ATTACK)
		else:
			if is_up_pressed and current_state != State.UP_ATTACK:
				switch_state(State.UP_ATTACK)
			elif not is_up_pressed and current_state != State.AIR_ATTACK:
				if GameState.has_ability("pogo"):
					switch_state(State.AIR_ATTACK)

func _handle_roll() -> void:
	if check_common_conditions():
		return
	
	if Input.is_action_just_pressed("roll") and current_state != State.ROLL and current_state != State.GROUND_ATTACK and current_state != State.AIR_ATTACK and GameState.has_ability("roll"):
		if is_on_floor():
			switch_state(State.ROLL)
		else:
			if GameState.has_ability("air_roll") and can_air_roll:
				if not is_on_floor():
					can_air_roll = false
				switch_state(State.ROLL)

func _handle_spell() -> void:
	if current_state == State.HURT or current_state == State.REST:
		return
	
	if Input.is_action_just_pressed("cast_spell") and GameState.has_ability("water_ball") and current_water_ammo > 0:
		var aim_dir := Vector2.ZERO
		
		if Input.is_action_pressed("up"):
			aim_dir = Vector2.UP
		elif Input.is_action_pressed("down") and not is_on_floor():
			aim_dir = Vector2.DOWN
		elif Input.is_action_pressed("move_right"):
			aim_dir = Vector2.RIGHT
		elif Input.is_action_pressed("move_left"):
			aim_dir = Vector2.LEFT
		else:
			aim_dir = Vector2.RIGHT if visuals.scale.x > 0 else Vector2.LEFT
		
		consume_ammo()
		
		if current_state != State.CAST_SPELL and current_state != State.ROLL:
			switch_state(State.CAST_SPELL)
		
		_fire_projectile(aim_dir)
		if not is_on_floor():
			_apply_pogo()

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
	
	ammo_regen_timer.timeout.connect(_on_ammo_regen_timeout)
	current_water_ammo = stats.max_water_ammo
	
	
	GameState.rebuild_player_stats()
	
	# Debug synchronisation
	debug_sword = GameState.has_ability("sword")
	debug_pogo = GameState.has_ability("pogo")
	debug_wall_slide = GameState.has_ability("wall_slide")
	debug_wall_jump = GameState.has_ability("wall_jump")
	debug_roll = GameState.has_ability("roll")
	debug_air_roll = GameState.has_ability("air_roll")
	
	run_animated_sprite.sprite_frames.set_animation_loop("run", false)
	run_animated_sprite.animation_finished.connect(func(): run_animated_sprite.hide())


func _physics_process(delta: float) -> void:
	_apply_gravity(delta)
	
	if is_dead:
		return
	
	if not state_locked and not GameState.is_gameplay_frozen():
		_handle_horizontal_movement(delta)
		_handle_jump()
		_handle_attack()
		_handle_spell()
		_handle_roll()
		_handle_oneway_drop_through()
	else:
		velocity.x = move_toward(velocity.x, 0, friction * delta)
	
	_was_on_floor = is_on_floor()
	move_and_slide()
	
	if is_on_floor():
		can_air_roll = true
		jump_count = 0
	
	_update_state()
	
	if current_state == State.RUN and is_on_floor():
		if abs(velocity.x) > 0.0:
			if run_dust_cooldown < 0.0:
				run_dust_cooldown = 0.15
			
			run_dust_cooldown -= delta
			if run_dust_cooldown <= 0.0:
				play_run_dust()
				run_dust_cooldown = 0.45
		else:
			run_dust_cooldown = -1.0
	else:
		run_dust_cooldown = -1.0


func receive_item(item: ItemData) -> void:
	if item != null and item.icon != null:
		looted_item_sprite.texture = item.icon
		looted_item_sprite.show()
	switch_state(State.SHOW_ITEM)


func consume_ammo() -> void:
	current_water_ammo -= 1
	GameEvents.water_ammo_changed.emit(current_water_ammo, stats.max_water_ammo)
	ammo_regen_timer.start(stats.ammo_regen_time)


func _fire_projectile(direction: Vector2) -> void:
	GameEvents.emit_engine_freeze()
	GameEvents.emit_camera_shake(0.6)
	var projectile: WaterBall = object_pool_projectile.spawn()
	projectile.start(global_position, direction)


func play_landing_dust_animation() -> void:
	dust_animated_sprite.show() 
	dust_animated_sprite.global_position = global_position
	#dust_animated_sprite.global_position.y -= 2
	dust_animated_sprite.reset_physics_interpolation()
	dust_animated_sprite.play("landing")


func play_jumping_dust_animation() -> void:
	dust_animated_sprite.stop()
	dust_animated_sprite.show() 
	dust_animated_sprite.global_position = global_position
	#dust_animated_sprite.global_position.y += 2
	dust_animated_sprite.reset_physics_interpolation()
	dust_animated_sprite.play("jump")


func play_run_dust() -> void:
	run_animated_sprite.show()
	run_animated_sprite.global_position = global_position
	run_animated_sprite.offset.x = -15 * visuals.scale.x
	run_animated_sprite.flip_h = (visuals.scale.x < 0)
	run_animated_sprite.reset_physics_interpolation()
	run_animated_sprite.frame = 0
	run_animated_sprite.play("run")


#region cutscene

func lock_state() -> void:
	state_locked = true

func unlock_state() -> void:
	state_locked = false

func sleep() -> void:
	lock_state()
	animation_player.play("sleeping")
	await get_tree().create_timer(3.5).timeout

func wake_up() -> void:
	animation_player.play("wake_up")

#endregion

#region _apply

func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		if is_on_wall_only() and velocity.y > 0 and GameState.has_ability("wall_slide"):
			velocity.y = min(velocity.y + stats.fall_gravity * delta, wall_slide_speed)
		else:
			if velocity.y < 0.0:
				velocity.y += stats.jump_gravity * delta
			else:
				velocity.y += stats.fall_gravity * delta


func _apply_pogo() -> void:
	if not GameState.has_ability("pogo"):
		return
	can_air_roll = true
	velocity.y = stats.jump_velocity * 0.9
	pogo_particles.restart()
	jump_count = 0
	apply_squish(0.6, 1.5)
	GameEvents.emit_camera_shake(0.2)


func apply_squish(squish_x: float, squish_y: float) -> void:
	sprite.scale = Vector2(squish_x, squish_y)
	
	if tween != null and tween.is_running():
		tween.kill()
	tween = create_tween().set_parallel(true)
	tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(sprite, "scale", Vector2.ONE, 0.35)

#endregion

#region _check

func check_common_conditions() -> bool:
	return current_state == State.HURT or \
		current_state == State.REST or \
		current_state == State.WALL_SLIDE or \
		current_state == State.SHOW_ITEM


func _check_wall_coyote() -> void:
	if is_on_wall_only():
		_was_on_wall = true
		last_wall_normal = get_wall_normal()
	elif _was_on_wall and not is_on_floor():
		_was_on_wall = false
		wall_coyote_timer.start()


func _check_wall_jump() -> bool:
	if Input.is_action_just_pressed("jump") and GameState.has_ability("wall_jump"):
		if is_on_wall_only() or not wall_coyote_timer.is_stopped():
			var wall_normal: Vector2 = get_wall_normal()
			
			if not is_on_wall_only():
				wall_normal = last_wall_normal
			
			wall_coyote_timer.stop()
			velocity.x = wall_normal.x * wall_jump_pushback
			velocity.y = wall_jump_lift
			jump_count = 1
			visuals.scale.x = sign(velocity.x)
			apply_squish(0.6, 1.4)
			
			return true
		
	return false


func _check_coyote_jump() -> void:
	if _was_on_floor and not is_on_floor() and velocity.y >= 0.0:
		coyote_jump_timer.start()


func _check_buffer_jump() -> void:
	if (not is_on_floor() and velocity.y > 0.0 and
		Input.is_action_just_pressed("jump") and buffer_jump_timer.is_stopped()):
			buffer_jump_timer.start()

#endregion

#region getters

func get_facing_direction() -> int:
	return visuals.scale.x

func get_current_health() -> int:
	return health_component.current_health

func get_total_gold() -> int:
	return GameState.total_gold

#endregion

#region _ON

func _on_hitbox_hit(hurtbox: HurtboxComponent) -> void:
	if current_state == State.AIR_ATTACK:
		_apply_pogo()
	elif current_state == State.GROUND_ATTACK:
		var push_dir = sign(global_position.x - hurtbox.global_position.x)
		if push_dir == 0.0:
			push_dir = 1.0
		
		velocity.x = push_dir * ATTACK_PUSH_FORCE


func _on_ammo_regen_timeout() -> void:
	if current_water_ammo < stats.max_water_ammo:
		current_water_ammo += 1
		GameEvents.water_ammo_changed.emit(current_water_ammo, stats.max_water_ammo)
		if current_water_ammo < stats.max_water_ammo:
			ammo_regen_timer.start(stats.ammo_regen_time)


func _on_animation_finished(animation_name: StringName) -> void:
	if animation_name == &"wake_up":
		unlock_state()
	
	match current_state:
		State.GROUND_ATTACK:
			if animation_name == &"ground_attack":
				switch_state(State.IDLE)
		State.AIR_ATTACK:
			if animation_name == &"air_attack":
				switch_state(State.FALL)
		State.UP_ATTACK:
			if animation_name == &"up_attack":
				if not is_on_floor():
					switch_state(State.FALL)
				else:
					switch_state(State.IDLE)
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
		State.CAST_SPELL:
			if animation_name == &"cast_spell":
				switch_state(State.IDLE)

#endregion
