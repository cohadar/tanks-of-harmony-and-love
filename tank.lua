--- @module snake
local m_tank = {}

tank_x = 300.0
tank_y = 300.0
tank_angle = 0.0
turret_angle = 0.0
turret_center_x = 27.0
turret_center_y = 107.0
base_center_x = 38
base_center_y = 64

tank_x_velocity = 0.0
tank_y_velocity = 0.0
tank_angle_velocity = 0.0
turret_angle_velocity = 0.0

-------------------------------------------------------------------------------
function m_tank.up()
	tank_y = tank_y - 32 
end

-------------------------------------------------------------------------------
function m_tank.down()
	tank_y = tank_y + 32
end

-------------------------------------------------------------------------------
function m_tank.left()
	tank_x = tank_x - 32
end

-------------------------------------------------------------------------------
function m_tank.right()
	tank_x = tank_x + 32
end

-------------------------------------------------------------------------------
function m_tank.update(dt)
	g_camera_x = tank_x
	g_camera_y = tank_y	
	turret_angle = (turret_angle + dt) % ( 2 * math.pi)
	tank_angle = (tank_angle - dt/3 + math.pi) % ( 2 * math.pi)
end

-------------------------------------------------------------------------------
function m_tank.draw()
	local x = tank_x - math.floor(g_tank_base:getWidth() / 2)
	local y = tank_y - math.floor(g_tank_base:getHeight() / 2)
	love.graphics.draw(g_tank_base, x+base_center_x, y+base_center_y, tank_angle, 1.0, 1.0, base_center_x, base_center_y)
 	x = tank_x - math.floor(g_tank_turret:getWidth() / 2)
	y = tank_y - math.floor(g_tank_turret:getHeight() / 2)
	love.graphics.draw(g_tank_turret, x+turret_center_x, y+turret_center_y-50, turret_angle, 1.0, 1.0, turret_center_x, turret_center_y)
end

-------------------------------------------------------------------------------
return m_tank
