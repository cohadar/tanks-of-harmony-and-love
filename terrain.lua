--- @module terrain
local terrain = {}

local conf = require "conf"
local utils = require "utils"

-- camera uses terrain coordinate system
terrain.camera_x = 0
terrain.camera_y = 0

local MAP_WIDTH  = 22 -- squares
local MAP_HEIGHT = 12 -- squares
local MAP_SQUARE = 64 -- pixels

local RED_TEAM_SPAWN = { x = 4 * MAP_SQUARE, y = MAP_HEIGHT / 2 * MAP_SQUARE }
local BLUE_TEAM_SPAWN = { x = ( MAP_WIDTH - 4 ) * MAP_SQUARE, y = MAP_HEIGHT / 2 * MAP_SQUARE }

terrain.MAP_SQUARE = MAP_SQUARE

-------------------------------------------------------------------------------
function terrain.respawn( tnk )
	if tnk.team == "red" then
		tnk.x = RED_TEAM_SPAWN.x
		tnk.y = RED_TEAM_SPAWN.y
		tnk.angle = 0
	else
		tnk.x = BLUE_TEAM_SPAWN.x
		tnk.y = BLUE_TEAM_SPAWN.y
		tnk.angle = utils.cleanAngle( math.pi )
	end
	tnk.hp = 100
end

-------------------------------------------------------------------------------
function terrain.safeXY( x, y )
	local safe_x = x
	local safe_y = y
	if x < 0 then
		safe_x = 0
	end
	if y < 0 then
		safe_y = 0
	end
	if x > MAP_WIDTH * MAP_SQUARE then
		safe_x = MAP_WIDTH * MAP_SQUARE
	end
	if y > MAP_HEIGHT * MAP_SQUARE then
		safe_y = MAP_HEIGHT * MAP_SQUARE
	end
	return math.floor( safe_x + 0.5 ), math.floor( safe_y + 0.5 )
end

-------------------------------------------------------------------------------
function terrain.isInside( x, y, padding )
	if x < padding or y < padding then
		return false
	end
	if y > MAP_HEIGHT * MAP_SQUARE - padding then
		return false
	end
	if x > MAP_WIDTH * MAP_SQUARE - padding then
		return false
	end
	return true
end

-------------------------------------------------------------------------------
local function outOfMap( mx, my ) 
	if mx < 0 or my < 0 then
		return true
	end
	if mx >= MAP_WIDTH or my >= MAP_HEIGHT then
		return true
	end
	return false
end

-------------------------------------------------------------------------------
function terrain.draw()
	local top    = math.floor( ( -conf.SCREEN_HEIGHT_HALF + terrain.camera_y ) / MAP_SQUARE ) - 1
	local bottom = math.floor( (  conf.SCREEN_HEIGHT_HALF + terrain.camera_y ) / MAP_SQUARE ) + 1
	local left   = math.floor( ( -conf.SCREEN_WIDTH_HALF  + terrain.camera_x ) / MAP_SQUARE ) - 1
	local right  = math.floor( (  conf.SCREEN_WIDTH_HALF  + terrain.camera_x ) / MAP_SQUARE ) + 1
	for my = top, bottom do
		for mx = left, right do
			if outOfMap(mx, my) then
				love.graphics.setColor(0x00, 0x00, 0x00, 0xFF)
			elseif (mx + my) % 2 == 0 then
				love.graphics.setColor(0xBD, 0x71, 0x40, 0xFF)
			else
				love.graphics.setColor(0xAD, 0x81, 0x50, 0xFF)
			end
			love.graphics.rectangle( 
				"fill", 
				mx * MAP_SQUARE, 
				my * MAP_SQUARE, 
				MAP_SQUARE, 
				MAP_SQUARE 
			)
		end
	end
end

-------------------------------------------------------------------------------
return terrain
