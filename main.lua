--- @module main
local main = {}

io.stdout:setvbuf("no")

local conf = require "conf"
local text = require "text"
local utils = require "utils"
local history = require "history"
local gui = require "gui"
local quickie = require "libs.quickie"
local terrain = require "terrain"
local tank = require "tank"
local client = require "client"
local tests = require "tests"
local world = require "world"
local bullets = require "bullets"
local ticker = require "ticker"
local effects = require "effects"

local _tankCommand = tank.newCommand()

-------------------------------------------------------------------------------
function love.load()
	conf.SCREEN_WIDTH  = love.graphics.getWidth() 
	conf.SCREEN_HEIGHT = love.graphics.getHeight() 
	conf.SCREEN_WIDTH_HALF  = math.floor( conf.SCREEN_WIDTH / 2 )
	conf.SCREEN_HEIGHT_HALF = math.floor( conf.SCREEN_HEIGHT / 2 )
	if conf.GAME_DEBUG then
		love.window.setMode( 
			conf.SCREEN_WIDTH * conf.SCALE_GRAPHICS, 
			conf.SCREEN_HEIGHT * conf.SCALE_GRAPHICS, 
			{ vsync = true, resizable = false } 
		)
	end
	text.init()
	tank.init()
	client.init()
	bullets.init()
	ticker.init( love.timer.getTime() )
	love.mouse.setVisible( true )
	love.window.setTitle( "Not Connected" )
	tests.runAll()
end

-------------------------------------------------------------------------------
function love.update( dt )
	gui.update()
	local mark = love.timer.getTime()
	local count = 0
	while ticker.tick( mark ) and count < 10 do
		count = count + 1
		local localhost_tank = world.getTank( 0 )
		_tankCommand.client_tick = client.incTick() 
		tank.update( localhost_tank, _tankCommand )
		terrain.camera_x, terrain.camera_y = localhost_tank.x, localhost_tank.y
		world.updateTank( 0, localhost_tank )
		history.set( _tankCommand.client_tick, localhost_tank )
	    bullets.update()
	    effects.update()
	end
	if count > 0 then
		client.update( _tankCommand )
		_tankCommand.fire = false
	end
	if count > 9 then
		-- TODO: proper disconnect here
		error "you lag too much"
	end
end

-------------------------------------------------------------------------------
function love.draw()
	love.graphics.push()
    love.graphics.scale( conf.SCALE_GRAPHICS )
	love.graphics.translate( 
		conf.SCREEN_WIDTH_HALF  - terrain.camera_x, 
		conf.SCREEN_HEIGHT_HALF - terrain.camera_y
	)	
	terrain.draw()
	love.graphics.setColor(0xFF, 0xFF, 0xFF, 0xFF)
	if client.isConnected() then
		for key, tnk in world.tankPairs() do 
			if key == 0 then
				love.graphics.setColor(0xFF, 0xFF, 0x00, 0xFF)
			else
				love.graphics.setColor(0xFF, 0xFF, 0xFF, 0xFF)
			end
			tank.draw( tnk )
		end
	else
		tank.draw( world.getTank( 0 ) )
	end
	bullets.draw()
	effects.draw()
	love.graphics.pop()
	text.draw()
    quickie.core.draw()
end

-------------------------------------------------------------------------------
function love.keypressed( key, unicode )
	if key     == "up"    or key == "w" then
		_tankCommand.up = true
	elseif key == "down"  or key == "s" then
		_tankCommand.down = true
	elseif key == "left"  or key == "a" then
		_tankCommand.left = true
	elseif key == "right" or key == "d" then
		_tankCommand.right = true
	end
    quickie.keyboard.pressed( key )
end

-------------------------------------------------------------------------------
function love.keyreleased( key )
	if key     == "up"    or key == "w" then
		_tankCommand.up = false
	elseif key == "down"  or key == "s" then
		_tankCommand.down = false
	elseif key == "left"  or key == "a" then
		_tankCommand.left = false
	elseif key == "right" or key == "d" then
		_tankCommand.right = false
	elseif key == " " then
		_tankCommand.fire = true
	end
    gui.keyreleased( key )
end

-------------------------------------------------------------------------------
function love.mousereleased( x, y, button )
	_tankCommand.fire = true
end

-------------------------------------------------------------------------------
function love.textinput( text )
    quickie.keyboard.textinput( text )
end

-------------------------------------------------------------------------------
function love.mousemoved( mouse_x, mouse_y, dx, dy )
	local mouse_angle = math.atan2( 
		mouse_y - conf.SCREEN_HEIGHT_HALF * conf.SCALE_GRAPHICS, 
		mouse_x - conf.SCREEN_WIDTH_HALF  * conf.SCALE_GRAPHICS 
	)
	_tankCommand.mouse_angle = utils.cleanAngle( mouse_angle ) 
end

-------------------------------------------------------------------------------
function love.threaderror( thread, errorstr )
	text.status( errorstr )
	print( errorstr )
end

-------------------------------------------------------------------------------
function love.quit()
	client.quit()
end

-------------------------------------------------------------------------------
return main

