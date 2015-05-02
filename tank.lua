--- @module snake
local m_tank = {}

-- movement properties
tank_x = 256.0
tank_y = 256.0
tank_angle = 0.0
turret_angle = 0.0

tank_velocity = 0.0
tank_angle_velocity = 0.0
turret_angle_velocity = 0.0

-- drawing properties
turret_center_x = 21.0
turret_center_y = 28.0
turret_base_offset = 10
base_center_x = 64
base_center_y = 38

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
	tank_x = tank_x + tank_velocity * math.cos( tank_angle )
	tank_y = tank_y + tank_velocity * math.sin( tank_angle )
	g_camera_x = tank_x
	g_camera_y = tank_y	
	turret_angle = ( turret_angle + dt ) % ( 2 * math.pi )
	tank_angle = tank_angle + tank_angle_velocity
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
