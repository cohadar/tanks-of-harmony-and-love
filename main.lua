io.stdout:setvbuf("no")

EPSILON = 0.000001

SCREEN_WIDTH  = 0
SCREEN_HEIGHT = 0

-- camera uses terrain coordinate system
g_camera_x = 8 * 64
g_camera_y = 6 * 64

m_terrain = require "terrain"
m_tank = require "tank"
m_tank_command = require "tank_command"
m_client = require "client"
m_tests = require "tests"
serpent = require "serpent"

m_world = require "world"
local tank_command = m_tank_command.new()
local old_mouse_x = 0
local old_mouse_y = 0
local command_changed = false

g_tick = 0

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
	m_tests.run_all()
end

-------------------------------------------------------------------------------
function love.update( dt )
	g_tick = g_tick + 1
	local mouse_y = love.mouse.getY()
	local mouse_x = love.mouse.getX()
	if old_mouse_x ~= mouse_x or old_mouse_y ~= mouse_y then 
		local mouse_angle = math.atan2( mouse_y - SCREEN_HEIGHT_HALF, mouse_x - SCREEN_WIDTH_HALF )
		m_tank_command.setMouseAngle( tank_command, m_utils.round_angle( mouse_angle ) ) 
		old_mouse_x = mouse_x
		old_mouse_y = mouse_y
		command_changed = true -- unused !
	end
	local tank = m_world.get_tank( 0 )
	m_tank.update( tank, tank_command )
	m_world.update_tank( 0, tank )
	m_client.update( tank, tank_command )
end

-------------------------------------------------------------------------------
function love.keypressed(key)
	if key == "escape" then
		love.event.push("quit")
		return
	end
	if key     == "up"    or key == "w" then
		m_tank_command.upPressed( tank_command )
		command_changed = true
	elseif key == "down"  or key == "s" then
		m_tank_command.downPressed( tank_command )
		command_changed = true
	elseif key == "left"  or key == "a" then
		m_tank_command.leftPressed( tank_command )
		command_changed = true
	elseif key == "right" or key == "d" then
		m_tank_command.rightPressed( tank_command )
		command_changed = true
	end
end

-------------------------------------------------------------------------------
function love.keyreleased(key)
	if key     == "up"    or key == "w" then
		m_tank_command.upReleased( tank_command )
		command_changed = true
	elseif key == "down"  or key == "s" then
		m_tank_command.downReleased( tank_command )
		command_changed = true
	elseif key == "left"  or key == "a" then
		m_tank_command.leftReleased( tank_command )
		command_changed = true
	elseif key == "right" or key == "d" then
		m_tank_command.rightReleased( tank_command )
		command_changed = true
	end
end

-------------------------------------------------------------------------------
function love.draw()
	love.graphics.push()
	love.graphics.translate(SCREEN_WIDTH_HALF - g_camera_x, SCREEN_HEIGHT_HALF - g_camera_y)	
	m_terrain.draw()
	love.graphics.setColor(0xFF, 0xFF, 0xFF, 0xFF)
	if m_client.is_connected() then
		for key, tank in m_world.tank_pairs() do 
			if key == 0 then
				love.graphics.setColor(0xFF, 0xFF, 0x00, 0xFF)
			else
				love.graphics.setColor(0xFF, 0xFF, 0xFF, 0xFF)
			end
			m_tank.draw( tank )
		end
	else
		m_tank.draw( m_world.get_tank( 0 ) )
	end
	love.graphics.pop()
	command_changed = false
	m_text.draw()
end

-------------------------------------------------------------------------------
function love.quit()
	m_client.quit()
	print("asta la vista baby")
end

