--- @module snake
local m_tank = {}

tank_x = 100.0
tank_y = 100.0
tank_angle = 0.0
turret_angle = 0.0

tank_x_velocity = 0.0
tank_y_velocity = 0.0
tank_angle_velocity = 0.0
turret_angle_velocity = 0.0

-------------------------------------------------------------------------------
function m_tank.up()
	tank_y = tank_y - 32 
	g_camera_x = tank_x
	g_camera_y = tank_y
end

-------------------------------------------------------------------------------
function m_tank.down()
	tank_y = tank_y + 32
	g_camera_x = tank_x
	g_camera_y = tank_y	
end

-------------------------------------------------------------------------------
function m_tank.left()
	tank_x = tank_x - 32
	g_camera_x = tank_x
	g_camera_y = tank_y	
end

-------------------------------------------------------------------------------
function m_tank.right()
	tank_x = tank_x + 32
	g_camera_x = tank_x
	g_camera_y = tank_y	
end

-------------------------------------------------------------------------------
function m_tank.update(dt)
	-- todo
end

-------------------------------------------------------------------------------
function m_tank.draw()
	local x = tank_x - math.floor(g_tank_base:getWidth() / 2)
	local y = tank_y - math.floor(g_tank_base:getHeight() / 2)
	love.graphics.draw(g_tank_base, x, y)
 	x = tank_x - math.floor(g_tank_turret:getWidth() / 2)
	y = tank_y - math.floor(g_tank_turret:getHeight() / 2)
	love.graphics.draw(g_tank_turret, x, y - 50)
end

-------------------------------------------------------------------------------
return m_tank
