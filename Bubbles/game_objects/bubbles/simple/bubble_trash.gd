
extends RigidBody2D

var type = "bubble"
#const FRICTION = 0.1
export (bool) var is_heavy = false
export (bool) var is_anti = false
var G = 0.5 # Гравитационная постоянная (м^3/кг/с^2)
var DENCITY = 1 # Плотность (кг/м^2)
var velocity = Vector2( 0,0 )
#var shape_radius = get_shape( 0 ).get_radius()
var shape_radius_0 = 30
var radius
var scale = 1
var mass = null
var creator = null
var in_creator = false
var parent
#var is_collide_with_absorb = false

# Обработака только при столкновениях
func _integrate_forces( state ):
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
			creator = null
		
		# Столкновение с другими шарами
		elif collider.type == "bubble":
			if creator == collider:
				in_creator = true
			elif collider.creator == self:
				collider.in_creator = true
			else:
				var distance_sqr =  get_pos().distance_squared_to( collider.get_pos() )
				collide_bubbles( self, collider, distance_sqr )
			
			# Кусок кода для корректного поглощения выстреливаемого шарика возле границы
			if in_creator:
				in_creator = false
			else:
				creator = null
			
	
# Покадровая обработка
func _fixed_process( delta ):
	# Притягивание всех шариков к себе, если ты тяжёлый
	if is_heavy:
		for another_object in parent.get_children():
			if self == another_object:
				continue
			
			# Рассчёт дистанции
			var distance_sqr =  get_pos().distance_squared_to( another_object.get_pos() )
			var radius_summ = radius + another_object.radius
			var vector = get_pos() - another_object.get_pos()
			another_object.velocity += G * vector.normalized() * mass / distance_sqr
			another_object.set_linear_velocity( another_object.velocity )
	
	# Перекрашивание шариков в зависимости от их массы относительно массы игрока
	#if self != player:
	#get_node("sprite").set_modulate(red)
	
	# Создание вектора перемещения и его применение
	var motion = velocity * delta
	set_pos( motion + get_pos() )
	#move( motion )
	
	# Сопротивление среды (жидкости) (не включать, дико баговано!)
	#velocity -=  velocity * FRICTION / mass
#func move( motion ):
	#var current_pos = get_pos()
	set_pos( motion + get_pos() )
func  _enter_scene():
	# Единственный раз, при создании шарика, его масса вычисляется
	# из параметров радиуса шейпа и масштаба сцены. Если не была
	# задана до этого
	if mass == null:
		scale = get_scale().x
		radius = shape_radius_0 * scale
		mass = PI * DENCITY * radius * radius
		custom_set_mass( mass )
	#	custom_set_scale( scale )
	#set_mass( mass )
	print( get_name(), " entered scene; mass = ", mass, "; radius = ", radius, "; scale = ", scale, "; shape_radius = ", get_shape( 0 ).get_radius() )
	parent = get_parent()
	
	# Дикое колдунство, стрелочки задают начальную скорость шариков и удаляются
	var pointer = get_node( "Pointer" )
	if pointer != null:
		velocity = 100 * pointer.get_scale().x * Vector2( cos( pointer.get_rot() - 45 ), - sin( pointer.get_rot() - 45 ) )
		set_linear_velocity( velocity )
		remove_child( get_node( "Pointer" ) )
	set_max_contacts_reported( 10 )
	#set_mode( MODE_KINEMATIC )
	set_use_custom_integrator( true )
	set_fixed_process( true )

# Функция передачи массы и скорости от меньшего объекта большему
func add_mass( delta_mass, delta_velocity = null ):
	custom_set_mass( mass + delta_mass )
	if delta_velocity != null:
		velocity = ( mass * velocity + delta_mass * delta_velocity ) / ( delta_mass + mass )
		set_linear_velocity( velocity )
	#print( get_name(), " new velocity: ", velocity )

# Установление массы. При установлении нулевой массы, шарик удаляется
func custom_set_mass( new_mass ):
	if new_mass <= 0:
		if get_parent() != null:
			#get_parent().remove_child( self )
			pass
			#print( get_name(), " was deleted" )
	else:
		mass = new_mass
		radius = sqrt( mass / ( PI * DENCITY ) )
		scale = radius / shape_radius_0
		var sprite = get_node( "Sprite" )
		var shape = get_shape( 0 )
		sprite.set_scale( Vector2( scale * 0.15, scale * 0.15 ) )
		shape.set_radius( 30 * scale )
		#custom_set_scale( radius/shape_radius )
		#print( get_name(), " mass: ", mass )
		#set_mass( mass )

# Установление всех параметров шарика при выстреливании
func set_params( new_pos, new_vel, new_mass ):
	set_pos( new_pos )
	velocity = new_vel
	set_linear_velocity( velocity )
	custom_set_mass( new_mass )
	#set_mass( mass )
	#custom_set_scale( radius/shape_radius_0 )
	#print( mass, ", ", radius, ", ", scale )

#func custom_set_scale( new_scale ):
#	var sprite = get_node( "Sprite" )
#	var shape = get_shape( 0 )
#	sprite.set_scale( Vector2( new_scale * 0.15, new_scale * 0.15 ) )
#	shape.set_radius( 30 * scale )
#	scale = new_scale
	
	
func collide_bubbles( b1, b2, distance_sqr ):
	var distance = sqrt( distance_sqr )
	
	# Определение поглащаемого и поглащателя
	var plus = null
	var minus = null
	if b1.mass >= b2.mass:
		plus = b1
		minus = b2
	else:
		plus = b2
		minus = b1
	
	# Высисление передаваемой массы в зависимости от 
	# массы шариков и расстояния между ними
	if plus.is_anti == minus.is_anti:
		# Формула была получена в Mathcad'е из предположения,
		# что при передаче массы, сумма радиусов и сумма масс шариков должна сохраняться
		var dm = 0.5*(minus.mass - plus.mass + distance_sqr*PI*DENCITY-distance*PI*DENCITY*(distance-sqrt((2*plus.mass + 2*minus.mass - distance_sqr*PI*DENCITY)/(PI*DENCITY))))
		if dm < 0:
			dm = - dm
		if minus.mass < dm and minus.mass > 0:
			dm = minus.mass
		print("2*plus.mass + 2*minus.mass - distance_sqr*PI*DENCITY = ", 2*plus.mass + 2*minus.mass - distance_sqr*PI*DENCITY)
		print( "dm: ", dm, "; ", plus.get_name()," mass:  ", plus.get_mass(), "; ", minus.get_name()," mass:  ", minus.get_mass())
		print( plus.get_name()," shape_radius:  ",plus.get_shape( 0 ).get_radius(), "; ",minus.get_name()," shape_radius:  ",minus.get_shape( 0 ).get_radius(),"; distance_sqr:  ", distance_sqr )
		# Передача массы и скорости
		plus.add_mass( dm, minus.velocity )
		minus.add_mass( - dm )
	# Если сталкивается антишарик и обычный шарик, то масса
	# отнимается у обоих, а скорость вообще не передаётся
	else:
		var dm = 0.25*(2*(b1.mass+b2.mass)-distance_sqr*PI*DENCITY-(b1.mass-b2.mass)*(b1.mass-b2.mass)/(distance_sqr*PI*DENCITY))
		if dm < 0:
			dm = - dm
		if minus.mass < dm and minus.mass > 0:
			dm = minus.mass
		print( "dm: ", dm, "; ", plus.get_name()," mass:  ", plus.mass, "; ", minus.get_name()," mass:  ", minus.mass )
		plus.add_mass( - dm )
		minus.add_mass( - dm )
	# Скорость передаётся не вся, а только её проекция на
	# линию между центрами шаров в момент столконвения (отказались от этой идеи)
	#var line = plus.get_pos() - minus.get_pos()
	#var new_plus_velocity = ( line.x * minus.velocity.x + line.y * minus.velocity.y ) / minus.velocity.length() * line.normalized()
	#print( "minus.velocity: ", minus.velocity, " new_plus_velocity: ", new_plus_velocity )
