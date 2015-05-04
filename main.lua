io.stdout:setvbuf("no")

SCREEN_WIDTH  = 0
SCREEN_HEIGHT = 0

-- camera uses terrain coordinate system
g_camera_x = 8 * 64
g_camera_y = 6 * 64

m_terrain = require "terrain"
m_tank = require "tank"
m_client = require "client"
serpent = require "serpent"

g_tanks = {}
localhost_tank = m_tank.new()

-------------------------------------------------------------------------------
function love.load()
-- client.lua

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
	m_tank.update( localhost_tank, dt )
	m_client.update( localhost_tank, dt )
end

-------------------------------------------------------------------------------
function love.keypressed(key)
	if key == "escape" then
		love.event.push("quit")
		return
	end
	if key     == "up"    or key == "w" then
		m_tank.upPressed( localhost_tank )
	elseif key == "down"  or key == "s" then
		m_tank.downPressed( localhost_tank )
	elseif key == "left"  or key == "a" then
		m_tank.leftPressed( localhost_tank )
	elseif key == "right" or key == "d" then
		m_tank.rightPressed( localhost_tank )
	end
end

-------------------------------------------------------------------------------
function love.keyreleased(key)
	if key     == "up"    or key == "w" then
		m_tank.upReleased( localhost_tank )
	elseif key == "down"  or key == "s" then
		m_tank.downReleased( localhost_tank )
	elseif key == "left"  or key == "a" then
		m_tank.leftReleased( localhost_tank )
	elseif key == "right" or key == "d" then
		m_tank.rightReleased( localhost_tank )
	end
end

-------------------------------------------------------------------------------
function love.draw()
	love.graphics.push()
	love.graphics.translate(SCREEN_WIDTH_HALF - g_camera_x, SCREEN_HEIGHT_HALF - g_camera_y)	
	m_terrain.draw()
	love.graphics.setColor(0xFF, 0xFF, 0xFF, 0xFF)
	if m_client.is_connected() then
		for key, tank in pairs( g_tanks ) do 
			m_tank.draw( tank )
		end
	else
		m_tank.draw( localhost_tank )
	end
	love.graphics.pop()
end

-------------------------------------------------------------------------------
function love.quit()
	m_client.quit()
	print("asta la vista baby")
end

