io.stdout:setvbuf("no")

SCREEN_WIDTH  = 0
SCREEN_HEIGHT = 0

-- camera uses terrain coordinate system
g_camera_x = 8 * 64
g_camera_y = 6 * 64

m_terrain = require "terrain"
m_tank = require "tank"
package.loaded["tank"] = nil

-------------------------------------------------------------------------------
function love.load()
	SCREEN_WIDTH  = love.graphics.getWidth()
	SCREEN_HEIGHT = love.graphics.getHeight()
	SCREEN_WIDTH_HALF  = math.floor( SCREEN_WIDTH / 2 )
	SCREEN_HEIGHT_HALF = math.floor( SCREEN_HEIGHT / 2 )

	--g_camera_x = -math.floor( SCREEN_WIDTH / 2 )
	--g_camera_y = -math.floor( SCREEN_HEIGHT / 2 )

	love.mouse.setVisible( false )

	g_tank_base = love.graphics.newImage("base.png")
	g_tank_turret = love.graphics.newImage("turret.png")
	m_terrain.init()
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
	love.graphics.push()
	love.graphics.translate(SCREEN_WIDTH_HALF - g_camera_x, SCREEN_HEIGHT_HALF - g_camera_y)	
	m_terrain.draw()
	m_tank.draw()
	love.graphics.pop()
end

-------------------------------------------------------------------------------
function love.quit()
	print("asta la vista baby")
end

