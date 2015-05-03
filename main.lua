io.stdout:setvbuf("no")

SCREEN_WIDTH  = 0
SCREEN_HEIGHT = 0

-- camera uses terrain coordinate system
g_camera_x = 8 * 64
g_camera_y = 6 * 64

m_terrain = require "terrain"
m_tank = require "tank"
m_client = require "client"
package.loaded["tank"] = nil

-------------------------------------------------------------------------------
function love.load()
	SCREEN_WIDTH  = love.graphics.getWidth()
	SCREEN_HEIGHT = love.graphics.getHeight()
	SCREEN_WIDTH_HALF  = math.floor( SCREEN_WIDTH / 2 )
	SCREEN_HEIGHT_HALF = math.floor( SCREEN_HEIGHT / 2 )

	--g_camera_x = -math.floor( SCREEN_WIDTH / 2 )
	--g_camera_y = -math.floor( SCREEN_HEIGHT / 2 )

	love.mouse.setVisible( true )

	g_tank_base = love.graphics.newImage("base.png")
	g_tank_turret = love.graphics.newImage("turret.png")
	m_terrain.init()
	m_client.init()
end

-------------------------------------------------------------------------------
function love.update( dt )
	m_tank.update( dt )
	m_client.update( dt )
end

-------------------------------------------------------------------------------
function love.keypressed(key)
	if key == "escape" then
		love.event.push("quit")
		return
	end
	if key     == "up"    or key == "w" then
		m_tank.upPressed()
	elseif key == "down"  or key == "s" then
		m_tank.downPressed()
	elseif key == "left"  or key == "a" then
		m_tank.leftPressed()
	elseif key == "right" or key == "d" then
		m_tank.rightPressed()
	end
end

-------------------------------------------------------------------------------
function love.keyreleased(key)
	if key     == "up"    or key == "w" then
		m_tank.upReleased()
	elseif key == "down"  or key == "s" then
		m_tank.downReleased()
	elseif key == "left"  or key == "a" then
		m_tank.leftReleased()
	elseif key == "right" or key == "d" then
		m_tank.rightReleased()
	end
end

-------------------------------------------------------------------------------
function love.draw()
	love.graphics.push()
	love.graphics.translate(SCREEN_WIDTH_HALF - g_camera_x, SCREEN_HEIGHT_HALF - g_camera_y)	
	m_terrain.draw()
	love.graphics.setColor(0xFF, 0xFF, 0xFF, 0xFF)
	m_tank.draw()
	love.graphics.pop()
	m_client.draw()
end

-------------------------------------------------------------------------------
function love.quit()
	print("asta la vista baby")
end

