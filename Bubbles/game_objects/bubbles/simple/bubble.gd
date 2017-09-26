
extends RigidBody2D

var type = "bubble"
export (bool) var is_heavy = false
export (bool) var is_anti = false
var G = 0.5 # Гравитационная постоянная (м^3/кг/с^2)
var DENCITY = 100 # Плотность (кг/м^2)
var PI_DENCITY = PI*DENCITY # Просто константа, часто вычисляется при передаче массы
var velocity = Vector2( 0,0 )
var shape_radius_0 = get_shape( 0 ).get_radius()
var sprite_scale_0
var sprite
var shape_transform
var scale
var radius
var mass
var creator
var in_creator = false
var parent
var mass_changed = true

# Обработака только при столкновениях
func _integrate_forces( state ):
	if mass <= 0:
		return
	var contact_count = state.get_contact_count()
	for i in range( contact_count ):
		var collider = state.get_contact_collider_object( i )
		# Отражение от стенок
		if collider.type == "wall":
			var n = state.get_contact_local_normal( i )
			var k = n.x * velocity.x + n.y * velocity.y
			if k < 0:
				velocity -= n * 2 * k
				set_linear_velocity( velocity )
			# Выталкиване шарика за границы стены если он каким то образом залез за неё
			# проверка именно на k <= 10 для того, чтобы при больших скоростях шарики не ускорялись до бесконечности
			elif k <= 10:
				velocity -= 0.5 * ( state.get_contact_local_pos( i ) - state.get_contact_collider_pos( i ) )
				set_linear_velocity( velocity )
			creator = null
			emit_signal( "collide", collider.get_name() )
		
		# Столкновение с другими шарами
		elif collider.type == "bubble" or collider.type == "player":
			if collider.mass == 0:
				continue
			# Кусок кода для корректного поглощения выстреливаемого шарика возле границы
			#if in_creator:
			#	in_creator = false
			#else:
			#	creator = null
			# Кусок кода для того, чтобы выстреливаемый шарик сначала вылетел из игрока
			if creator == collider:
				in_creator = true
			elif collider.creator == self:
				collider.in_creator = true
			else:
				var distance_sqr =  get_pos().distance_squared_to( collider.get_pos() )
				collide_bubbles( collider )
				#print( "Collide:\n",self.info(), "\n", collider.info(), "; distance: ", sqrt( distance_sqr ) )
			emit_signal( "collide", collider.get_name() )
	
# Покадровая обработка
func _fixed_process( delta ):
	if mass <= 0:
		if get_parent() != null:
			parent.remove_child( self )
			#queue_free()
			emit_signal( "delete" )
			return
	
	# Притягивание всех шариков к себе, если ты тяжёлый
	if is_heavy:
		for another_object in parent.get_children():
			if self == another_object:
				continue
			
			# Рассчёт дистанции
			var distance_sqr =  get_pos().distance_squared_to( another_object.get_pos() )
			var vector = get_pos() - another_object.get_pos()
			another_object.velocity += G * vector.normalized() * mass / distance_sqr
			another_object.set_linear_velocity( another_object.velocity )
	
	# Перекрашивание шариков в зависимости от их опасности для игрока
	if type != "player" and Globals.player != null: #and ( mass_changed or Globals.player.mass_changed ) :
		if mass > Globals.player.mass:
			get_node("Sprite").set_modulate(Color(1.2,0.8,0.8,1))
		else:
			get_node("Sprite").set_modulate(Color(1.2,1.2,1.2,1))
		#mass_changed = false
		#Globals.player.mass_changed = false
	
	# Сопротивление среды (жидкости) (не включать, дико баговано!)
	#velocity -=  velocity * FRICTION / mass


func  _enter_scene():
	# Единственный раз, при создании шарика, его масса вычисляется
	# из параметров радиуса шейпа и масштаба сцены. Если не была
	# задана до этого
	if mass == null:
		sprite_scale_0 = get_node( "Sprite" ).get_scale()
		shape_transform = PS2D.body_get_shape_transform( get_rid(), 0 )
		sprite = get_node( "Sprite" )
		scale = get_scale().x
		radius = shape_radius_0 * scale
		mass = PI * DENCITY * radius * radius
		custom_set_mass( mass )
	
	#print("Created: ", info())
	parent = get_parent()
	
	# Дикое колдунство, стрелочки задают начальную скорость шариков и удаляются
	if has_node( "Pointer" ):
		var pointer = get_node( "Pointer" )
		velocity = 100 * pointer.get_scale().x * Vector2( cos( pointer.get_rot() - 45 ), - sin( pointer.get_rot() - 45 ) )
		set_linear_velocity( velocity )
		remove_child( get_node( "Pointer" ) )
	set_max_contacts_reported( 10 )
	#set_mode( MODE_KINEMATIC )
	add_user_signal( "collide" )
	add_user_signal( "delete" )
	add_user_signal( "change_mass" )
	set_use_custom_integrator( true )
	set_fixed_process( true )

# Функция передачи массы и скорости от меньшего объекта большему
func add_mass( delta_mass, delta_velocity = null ):
	custom_set_mass( mass + delta_mass )
	if delta_velocity != null:
		velocity = ( mass * velocity + delta_mass * delta_velocity ) / ( delta_mass + mass )
		set_linear_velocity( velocity )
	mass_changed = true
	#print( get_name(), " new velocity: ", velocity )

# Установление массы. При установлении нулевой массы, шарик удаляется
func custom_set_mass( new_mass ):
	#if new_mass > 0.0001:
	emit_signal( "change_mass", mass, new_mass )
	if new_mass > 0:
		sprite = get_node( "Sprite" )
		mass = new_mass
		radius = sqrt( mass / ( PI * DENCITY ) )
		scale = radius / shape_radius_0
		sprite.set_scale( sprite_scale_0 * scale )
		
		# Дичайшее колдунство, скейлим шейп
		PS2D.body_set_shape_transform( get_rid(), 0, shape_transform.scaled( Vector2 (scale, scale) ) )
		#print( get_name(), " mass: ", mass )
	else:
		mass = 0

# Установление всех параметров шарика при выстреливании
func set_params( new_pos, new_vel, new_mass ):
	set_pos( new_pos )
	velocity = new_vel
	set_linear_velocity( velocity )
	shape_transform = PS2D.body_get_shape_transform( get_rid(), 0 )
	sprite_scale_0 = get_node( "Sprite" ).get_scale()
	custom_set_mass( new_mass )
	#print( mass, ", ", radius, ", ", scale )

func collide_bubbles( collider ):
	#var distance_sqr =  get_pos().distance_squared_to( collider.get_pos() )
	var distance = get_pos().distance_to( collider.get_pos() )
	var distance_sqr = distance*distance
	
	# Определение поглащаемого и поглащателя
	var plus = null
	var minus = null
	if mass >= collider.mass:
		plus = self
		minus = collider
	else:
		plus = collider
		minus = self
	
	# Высисление передаваемой массы в зависимости от 
	# массы шариков и расстояния между ними
	if plus.is_anti == minus.is_anti:
		
		# Формула была получена в Mathcad'е из предположения,
		# что при передаче массы, сумма радиусов и сумма масс шариков должна сохраняться
		var fucking_variable = 2*plus.mass + 2*minus.mass - distance_sqr*PI*DENCITY
		if fucking_variable < 0:
			return
		var dm = 0.5*(minus.mass - plus.mass + distance*sqrt(fucking_variable*PI_DENCITY))
		#	print(dm,"; ", "plus.mass = ", mass, ", plus.radius = ", radius, "; minus.mass = ", minus.mass, ", minus.radius = ", minus.radius, ", distance_sqr = ", distance_sqr )
		#	dm = 1
		if dm < 0:
			dm = - dm
		if minus.mass < dm and minus.mass > 0:
			dm = minus.mass
		#print("Collide: \nminus - ", minus.info(), "\nplus - ", plus.info())
		#print("dm: ", dm)
		plus.add_mass( dm, minus.velocity )
		minus.add_mass( - dm )
	
	# Если сталкивается антишарик и обычный шарик, то масса
	# отнимается у обоих, а скорость вообще не передаётся
	else:
		var dm = 0.25*(2*(mass+collider.mass)-distance_sqr*PI_DENCITY-(mass-collider.mass)*(mass-collider.mass)/(distance_sqr*PI_DENCITY))
		if dm < 0:
			dm = - dm
		if minus.mass < dm and minus.mass > 0:
			dm = minus.mass
		plus.add_mass( - dm )
		minus.add_mass( - dm )
		#print("Anticollide: \nminus - ", minus.info(), "; \nplus - ", plus.info())
	# Скорость передаётся не вся, а только её проекция на
	# линию между центрами шаров в момент столконвения (отказались от этой идеи)
	#var line = plus.get_pos() - minus.get_pos()
	#var new_plus_velocity = ( line.x * minus.velocity.x + line.y * minus.velocity.y ) / minus.velocity.length() * line.normalized()
	#print( "minus.velocity: ", minus.velocity, " new_plus_velocity: ", new_plus_velocity )

func info():
	return str( get_name(), ": mass = ", mass, ", radius = ", radius, ", scale = ", scale)
