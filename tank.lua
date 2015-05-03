--- @module tank
local m_tank = {}

-- movement properties
tank_x = 256.0
tank_y = 256.0
tank_angle = 0.0
turret_angle = 0.0

tank_velocity = 0.0
tank_angle_velocity = 0.0
turret_angle_velocity = math.pi / 64

-- drawing properties
turret_center_x = 21.0
turret_center_y = 28.0
turret_base_offset = 10
base_center_x = 64
base_center_y = 38

-------------------------------------------------------------------------------
function m_tank.getX()
	return tank_x
end

-------------------------------------------------------------------------------
function m_tank.getY()
	return tank_y
end

-------------------------------------------------------------------------------
function m_tank.setXY(x, y)
	tank_x, tank_y = x, y
end

-------------------------------------------------------------------------------
function m_tank.upPressed()
	tank_velocity = 4.0 
end

-------------------------------------------------------------------------------
function m_tank.downPressed()
	tank_velocity = -4.0
end

-------------------------------------------------------------------------------
function m_tank.leftPressed()
	tank_angle_velocity = -math.pi / 128
end

-------------------------------------------------------------------------------
function m_tank.rightPressed()
	tank_angle_velocity = math.pi / 128
end

-------------------------------------------------------------------------------
function m_tank.upReleased()
	if tank_velocity > 0 then
		tank_velocity = 0.0 
	end
end

-------------------------------------------------------------------------------
function m_tank.downReleased()
	if tank_velocity < 0 then
		tank_velocity = 0.0
	end
end

-------------------------------------------------------------------------------
function m_tank.leftReleased()
	if tank_angle_velocity < 0 then
		tank_angle_velocity = 0
	end
end

-------------------------------------------------------------------------------
function m_tank.rightReleased()
	if tank_angle_velocity > 0 then
		tank_angle_velocity = 0
	end
end


-------------------------------------------------------------------------------
function m_tank.update(dt)
	tank_x = m_terrain.safe_x( tank_x + tank_velocity * math.cos( tank_angle ) )
	tank_y = m_terrain.safe_y( tank_y + tank_velocity * math.sin( tank_angle ) )
	g_camera_x = tank_x
	g_camera_y = tank_y	
	tank_angle = tank_angle + tank_angle_velocity

	
	local mouse_angle = math.atan2( love.mouse.getY() - SCREEN_HEIGHT_HALF, love.mouse.getX() - SCREEN_WIDTH_HALF )
	turret_angle = math.atan2( math.sin( turret_angle ), math.cos( turret_angle ) )
	
	if math.abs(mouse_angle - turret_angle) < 0.1 then
		turret_angle = mouse_angle
	else
		mouse_angle = mouse_angle + math.pi
		local angle_diff = mouse_angle - turret_angle
		angle_diff = math.atan2(math.sin(angle_diff), math.cos(angle_diff))
		if angle_diff < 0 then
			turret_angle = turret_angle + turret_angle_velocity
		end
		if angle_diff > 0 then
			turret_angle = turret_angle - turret_angle_velocity
		end	
	end
end

-------------------------------------------------------------------------------
function m_tank.draw()
	love.graphics.draw( g_tank_base, tank_x, tank_y, tank_angle, 1.0, 1.0, base_center_x, base_center_y )
	local turret_x = tank_x + turret_base_offset * math.cos( tank_angle )
	local turret_y = tank_y + turret_base_offset * math.sin( tank_angle )
	love.graphics.draw( g_tank_turret, turret_x, turret_y, turret_angle, 1.0, 1.0, turret_center_x, turret_center_y )
end

-------------------------------------------------------------------------------
return m_tank
