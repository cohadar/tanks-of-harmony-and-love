--- @module bullet
local bullets = {}

terrain = require "terrain"

local IMG_BULLET = nil
local IMG_BULLET_CX = 83 - 4.5
local IMG_BULLET_CY = 4.5

local BULLET_SPEED = 30
local MAX__bullets = 100

local _lastBullet = 0
local _bullets = {}

-- TODO: bullet owners and networking optimization on export/import

-------------------------------------------------------------------------------
function bullets.init()
	IMG_BULLET = love.graphics.newImage "resources/bullet.png"
end

-------------------------------------------------------------------------------
function bullets.fire( x, y, direction )
	local self = {}
	self.x = x
	self.y = y
	self.dx = BULLET_SPEED * math.cos( direction )
	self.dy = BULLET_SPEED * math.sin( direction )
	self.direction = direction
	_lastBullet = _lastBullet + 1
	if _lastBullet > MAX__bullets then
		_lastBullet = 1
	end
	_bullets[ _lastBullet ] = self
end

-------------------------------------------------------------------------------
function bullets.exportTable()
	local ret = {}
	for _, self in pairs( _bullets ) do
		table.insert( ret, { x = self.x, y = self.y, direction = self.direction } )
	end	
	return ret
end

-------------------------------------------------------------------------------
function bullets.importTable( exported_table )
	_bullets = {}
	_lastBullet = 0
	for _, self in pairs( exported_table ) do
		bullets.fire( self.x, self.y, self.direction )
	end	
end

-------------------------------------------------------------------------------
function bullets.update()
	for index, self in pairs( _bullets ) do
		self.x = self.x + self.dx
		self.y = self.y + self.dy
		if terrain.isInside( self.x, self.y, -3 * terrain.MAP_SQUARE )  == false then
			_bullets[ index ] = nil
		end	
	end
end

-------------------------------------------------------------------------------
function bullets.draw()
	for index, self in pairs( _bullets ) do
		love.graphics.draw( IMG_BULLET, self.x, self.y, self.direction, 1.0, 1.0, IMG_BULLET_CX, IMG_BULLET_CY )
	end
end

-------------------------------------------------------------------------------
function bullets.collider( x, y, radius )
	for index, self in pairs( _bullets ) do
		local dx = self.x - x
		local dy = self.y - y
		if dx * dx + dy * dy < radius * radius then
			return self.x, self.y
		end
	end
	return nil, nil	
end

-------------------------------------------------------------------------------
return bullets

