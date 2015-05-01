--- @module snake
local m_tank = {}

tank_x = 0.0
tank_y = 0.0
tank_angle = 0.0
turret_angle = 0.0

tank_x_velocity = 0.0
tank_y_velocity = 0.0
tank_angle_velocity = 0.0
turret_angle_velocity = 0.0

-------------------------------------------------------------------------------
function m_tank.up()
	print("up")
end

-------------------------------------------------------------------------------
function m_tank.down()
	print("down")
end

-------------------------------------------------------------------------------
function m_tank.left()
	print("left")
end

-------------------------------------------------------------------------------
function m_tank.right()
	print("right")
end

-------------------------------------------------------------------------------
function m_tank.update(dt)
	-- todo
end

-------------------------------------------------------------------------------
function m_tank.draw()
	local cx = 500
	local cy = 400
	local x = cx - math.floor(g_tank_base:getWidth() / 2)
	local y = cy - math.floor(g_tank_base:getHeight() / 2)
	love.graphics.draw(g_tank_base, x, y)
 	x = cx - math.floor(g_tank_turret:getWidth() / 2)
	y = cy - math.floor(g_tank_turret:getHeight() / 2)
	love.graphics.draw(g_tank_turret, x, y - 50)
end


-------------------------------------------------------------------------------
return m_tank
