--- @module bullet
local m_bullets = {}

m_terrain = require "terrain"

local img_bullet = nil

local BULLET_SPEED = 30

local MAX_BULLETS = 100
local last_bullet = 0
local bullets = {}

-- image center of gravity
local GRAVITY_CENTER_X = 83 - 4.5
local GRAVITY_CENTER_Y = 4.5

-------------------------------------------------------------------------------
function m_bullets.init()
	img_bullet = love.graphics.newImage "resources/bullet.png"
end

-------------------------------------------------------------------------------
function m_bullets.fire( x, y, direction )
	local self = {}
	self.x = x
	self.y = y
	self.dx = BULLET_SPEED * math.cos( direction )
	self.dy = BULLET_SPEED * math.sin( direction )
	self.angle = direction
	last_bullet = last_bullet + 1
	if last_bullet > MAX_BULLETS then
		last_bullet = 1
	end
	bullets[ last_bullet ] = self
end

-------------------------------------------------------------------------------
-- explicitly NOT a function of dt
-------------------------------------------------------------------------------
function m_bullets.update()
	for index, self in pairs( bullets ) do
		self.x = self.x + self.dx
		self.y = self.y + self.dy
		if m_terrain.is_inside( self.x, self.y, -3 * MAP_SQUARE )  == false then
			bullets[ index ] = nil
		end	
	end
end

-------------------------------------------------------------------------------
function m_bullets.draw()
	for index, self in pairs( bullets ) do
		love.graphics.draw( img_bullet, self.x, self.y, self.angle, 1.0, 1.0, GRAVITY_CENTER_X, GRAVITY_CENTER_Y )
	end
end

-------------------------------------------------------------------------------
return m_bullets

