io.stdout:setvbuf("no")

MAP_WIDTH  = 1024 -- squares
MAP_HEIGHT = 1024 -- squares
MAP_SQUARE = 64 -- pixels

SCREEN_WIDTH  = 0
SCREEN_HEIGHT = 0

g_camera_x = 0.0
g_camera_y = 0.0

m_tank = require "tank"
package.loaded["tank"] = nil

-------------------------------------------------------------------------------
function love.load()
	SCREEN_WIDTH  = love.graphics.getWidth()
	SCREEN_HEIGHT = love.graphics.getHeight()

	g_camera_x = -math.floor( SCREEN_WIDTH / 2 )
	g_camera_y = -math.floor( SCREEN_HEIGHT / 2 )

	love.mouse.setVisible( false )

	g_tank_base = love.graphics.newImage("base.png")
	g_tank_turret = love.graphics.newImage("turret.png")
	love.graphics.setBackgroundColor(0xAD, 0x81, 0x50, 0xFF)
end

-------------------------------------------------------------------------------
function love.update(dt)
	m_tank.update(dt)
end

-------------------------------------------------------------------------------
function love.keypressed(key)
	if key == "escape" then
		love.event.push("quit")
		return
	end
	if key == "up" then
		m_tank.up()
	elseif key == "down" then
		m_tank.down()
	elseif key == "left" then
		m_tank.left()
	elseif key == "right" then
		m_tank.right()
	elseif key == "w" then
		m_tank.up()
	elseif key == "s" then
		m_tank.down()
	elseif key == "a" then
		m_tank.left()
	elseif key == "d" then
		m_tank.right()		
	end
end

-------------------------------------------------------------------------------
function love.draw()
	m_tank.draw()
end

-------------------------------------------------------------------------------
function love.quit()
	print("asta la vista baby")
end

