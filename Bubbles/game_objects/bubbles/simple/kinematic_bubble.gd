
extends KinematicBody2D

#const FRICTION = 0.1
export (bool) var is_heavy = false
export (bool) var is_anti = false
var G = 0.5 # Гравитационная постоянная (м^3/кг/с^2)
var DENCITY = 1 # Плотность (кг/м^2)
var velocity = Vector2( 0,0 )
var shape_radius = get_shape( 0 ).get_radius()
#var shape_radius = 30
var radius
var scale = 1
var mass = null
var creator = null
var in_creator = false
var parent
var is_collide_with_absorb = false
#var player = get_node("Player")

# Покадровая обработка
func _fixed_process( delta ):
	# Оптимизация: стоячие шары не обрабатываются, кроме гравишариков
	if velocity != Vector2( 0,0 ) or is_heavy:
		#Взаимодействие шаров
		for another_object in parent.get_children():
			if self == another_object:
				continue
			# Рассчёт дистанции
			var distance_sqr =  get_pos().distance_squared_to( another_object.get_pos() )
			var radius_summ = radius + another_object.radius
			#print( object.get_name(), " distance: ", distance, " and radius summ: ", radius_summ, " to ", another_object.get_name() )
			# Столконвение, обмен массой
			if distance_sqr <= radius_summ*radius_summ:
				if creator == another_object:
					in_creator = true
				elif another_object.creator == self:
					another_object.in_creator = true
				else:
					collide_bubbles( self, another_object, distance_sqr )
			# Притягивание всех шариков к себе, если ты тяжёлый
			if is_heavy:
				var vector = get_pos() - another_object.get_pos()
				another_object.velocity += G * vector.normalized() * mass / distance_sqr
			# Перекрашивание шариков в зависимости от их массы относительно массы игрока
			#if self != player:
				#get_node("sprite").set_modulate(red)
			#	pass
		
		# Кусок кода для корректного поглощения выстреливаемого шарика возле границы
		if in_creator:
			in_creator = false
		else:
			creator = null
		
		# Отражение от стенок посредством функций двмжка
		#if is_colliding():
		#	var n = get_collision_normal()
		#	var k = n.x * velocity.x + n.y * velocity.y
		#	if k < 0:
		#		velocity -= n * 2 * k
		#	creator = null
		# Создание вектора перемещения и его применение
		var motion = velocity * delta
		move( motion )
		
		# Сопротивление среды (жидкости) (не включать, дико баговано!)
		#velocity -=  velocity * FRICTION / mass

func  _enter_scene():
	# Единственный раз, при создании шарика, его масса вычисляется
	# из параметров радиуса шейпа и масштаба сцены. Если не была
	# задана до этого
	if mass == null:
		scale = get_scale().x
		radius = shape_radius * scale
		mass = PI * DENCITY * radius * radius
	parent = get_parent()
	# Дикое колдунство, стрелочки задают начальную скорость шариков и удаляются
	var pointer = get_node( "Pointer" )
	if pointer != null:
		velocity = 100 * pointer.get_scale().x * Vector2( cos( pointer.get_rot() - 45 ), - sin( pointer.get_rot() - 45 ) )
		remove_child( get_node( "Pointer" ) )
	#print(get_name(), " ", mass, " 1")
	set_collide_with_kinematic_bodies( false )
	set_collide_with_rigid_bodies( false )
	set_fixed_process( true )

# Функция передачи массы и скорости от меньшего объекта большему
func add_mass( delta_mass, delta_velocity = null ):
	set_mass( mass + delta_mass )
	if delta_velocity != null:
		velocity = ( mass * velocity + delta_mass * delta_velocity ) / ( delta_mass + mass )
	#print( get_name(), " new velocity: ", velocity )

# Установление всех параметров шарика
func set_params( new_pos, new_vel, new_mass ):
	set_pos( new_pos )
	velocity = new_vel
	set_mass( new_mass )

# Установление массы. При установлении нулевой массы, шарик удаляется
func set_mass( new_mass ):
	if new_mass == 0:
		if get_parent() != null:
			get_parent().remove_child( self )
			#print( get_name(), " was deleted" )
	else:
		mass = new_mass
		radius = sqrt( mass / ( PI * DENCITY ) )
		set_scale( Vector2( radius/shape_radius, radius/shape_radius ) )
	#	print( get_name(), " mass: ", mass )
#func collide_with_absorb():
	
	
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
		# что при передаче массы, сумма радиусов шариков должна сохраняться
		var dm = 0.5*(minus.mass - plus.mass + distance_sqr*PI*DENCITY-distance*PI*DENCITY*(distance-sqrt((2*plus.mass + 2*minus.mass - distance_sqr*PI*DENCITY)/(PI*DENCITY))))
		if dm < 0:
			dm = - dm
		if minus.mass < dm and minus.mass > 0:
			dm = minus.mass
		#print( get_name(), ": dm: ", dm, " self mass:  ", self.mass, " collider mass: ", collider.mass )
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
		plus.add_mass( - dm )
		minus.add_mass( - dm )
	# Скорость передаётся не вся, а только её проекция на
	# линию между центрами шаров в момент столконвения (отказались от этой идеи)
	#var line = plus.get_pos() - minus.get_pos()
	#var new_plus_velocity = ( line.x * minus.velocity.x + line.y * minus.velocity.y ) / minus.velocity.length() * line.normalized()
	#print( "minus.velocity: ", minus.velocity, " new_plus_velocity: ", new_plus_velocity )
