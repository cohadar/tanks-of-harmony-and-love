--- @module main
local m_main = {}

io.stdout:setvbuf("no")

m_gui = require "gui"
m_quickie = require "libs.quickie"
m_terrain = require "terrain"
m_tank = require "tank"
m_client = require "client"
m_tests = require "tests"
m_world = require "world"
m_bullets = require "bullets"
m_ticker = require "ticker"

local tank_command = m_tank.newCommand()

-------------------------------------------------------------------------------
function love.load()
-- client.lua

	m_conf.SCREEN_WIDTH  = love.graphics.getWidth() 
	m_conf.SCREEN_HEIGHT = love.graphics.getHeight() 
	m_conf.SCREEN_WIDTH_HALF  = math.floor( m_conf.SCREEN_WIDTH / 2 )
	m_conf.SCREEN_HEIGHT_HALF = math.floor( m_conf.SCREEN_HEIGHT / 2 )

	if m_conf.GAME_DEBUG then
		love.window.setMode( 
			m_conf.SCREEN_WIDTH * m_conf.SCALE_GRAPHICS, 
			m_conf.SCREEN_HEIGHT * m_conf.SCALE_GRAPHICS, 
			{vsync = true, resizable = false } 
		)
	end

	love.mouse.setVisible( true )

	g_tank_base = love.graphics.newImage( "resources/base.png" )
	g_tank_turret = love.graphics.newImage( "resources/turret.png" )
	m_text.init()
	m_terrain.init()
	m_client.init()
	m_tests.run_all()
	love.window.setTitle( "Not Connected" )
	m_bullets.init()
	m_ticker.init( love.timer.getTime() )
end

-------------------------------------------------------------------------------
function love.update( dt )
	m_gui.update( dt )
	local mark = love.timer.getTime()
	local count = 0
	while m_ticker.tick( mark ) and count < 10 do
		count = count + 1
		local tank = m_world.get_tank( 0 )
		tank_command.client_tick = m_client.incTick() 
		m_tank.update( tank, tank_command )
		m_world.update_tank( 0, tank )
		m_history.tank_record( tank_command.client_tick, tank )
	    m_bullets.update()
	end
	if count > 0 then
		m_client.update( tank, tank_command )
	end
	if count > 9 then
		-- TODO: proper disconnect here
		error "you lag too much"
	end
end

-------------------------------------------------------------------------------
function love.draw()
	love.graphics.push()
    love.graphics.scale( m_conf.SCALE_GRAPHICS )
	love.graphics.translate( 
		m_conf.SCREEN_WIDTH_HALF  - m_terrain.camera_x, 
		m_conf.SCREEN_HEIGHT_HALF - m_terrain.camera_y
	)	
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
	m_bullets.draw()
	love.graphics.pop()
	m_text.draw()

    m_quickie.core.draw()
end

-------------------------------------------------------------------------------
function love.keypressed( key, unicode )
	-- if key == "escape" then
	-- 	love.event.push("quit")
	-- 	return
	-- end
	if key     == "up"    or key == "w" then
		tank_command.up = true
	elseif key == "down"  or key == "s" then
		tank_command.down = true
	elseif key == "left"  or key == "a" then
		tank_command.left = true
	elseif key == "right" or key == "d" then
		tank_command.right = true
	end

    m_quickie.keyboard.pressed( key )
end

-------------------------------------------------------------------------------
function love.keyreleased( key )
	if key     == "up"    or key == "w" then
		tank_command.up = false
	elseif key == "down"  or key == "s" then
		tank_command.down = false
	elseif key == "left"  or key == "a" then
		tank_command.left = false
	elseif key == "right" or key == "d" then
		tank_command.right = false
	elseif key == " " then
		tank_command.fire = true
	end

    m_gui.keyreleased( key )
end

-------------------------------------------------------------------------------
function love.mousereleased( x, y, button )
	tank_command.fire = true
end

-------------------------------------------------------------------------------
function love.textinput( text )
    m_quickie.keyboard.textinput( text )
end

-------------------------------------------------------------------------------
function love.mousemoved( mouse_x, mouse_y, dx, dy )
	local mouse_angle = math.atan2( 
		mouse_y - m_conf.SCREEN_HEIGHT_HALF * m_conf.SCALE_GRAPHICS, 
		mouse_x - m_conf.SCREEN_WIDTH_HALF  * m_conf.SCALE_GRAPHICS 
	)
	tank_command.mouse_angle = m_utils.round_angle( mouse_angle ) 
end

-------------------------------------------------------------------------------
function love.threaderror( thread, errorstr )
	m_text.status( errorstr )
	print( errorstr )
end

-------------------------------------------------------------------------------
function love.quit()
	m_client.quit()
end

-------------------------------------------------------------------------------
return m_main

