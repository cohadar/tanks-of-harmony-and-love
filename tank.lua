--- @module tank
local m_tank = {}

local m_terrain = require "terrain"
local m_utils = require "utils"
local m_bullets = require "bullets"

-- drawing properties 
local TURRET_CENTER_X = 21.0
local TURRET_CENTER_Y = 28.0
local TURRET_BASE_OFFSET = 10
local BASE_CENTER_X = 64
local BASE_CENTER_Y = 38
local MUZZLE_LENGTH = 120
local MUZZLE_SHIFT = -9

-- gameplay properties
local FPS = 32
local TANK_VELOCITY_MAX = 4.0 * 2
local TANK_VELOCITY_DELTA = TANK_VELOCITY_MAX / FPS / 2
local TANK_BREAKING_VELOCITY_DELTA = TANK_VELOCITY_DELTA * 2
local TANK_INERTION_VELOCITY_DELTA = TANK_VELOCITY_DELTA * 1.5
local TANK_ANGLE_VELOCITY = math.pi / 128 * 2
local TURRET_ANGLE_VELOCITY = math.pi / 64 * 2

local img_tank_base = nil
local img_tank_turret = nil

-------------------------------------------------------------------------------
function m_tank.init()
	img_tank_base = love.graphics.newImage( "resources/base.png" )
	img_tank_turret = love.graphics.newImage( "resources/turret.png" )
end

-------------------------------------------------------------------------------
function m_tank.newCommand()
	return {
		up = false,
		down = false,
		left = false,
		right = false,
		mouse_angle = 0.0,
		client_tick = 0
	}
end

-------------------------------------------------------------------------------
function m_tank.new()
	local self = {}
	self.x = 256.0
	self.y = 256.0
	self.angle = 0.0
	self.turret_angle = 0.0
	self.velocity = 0.0
	self.angle_velocity = 0.0
	return self
end

-------------------------------------------------------------------------------
function m_tank.slurp( self, other )
	self.x = other.x
	self.y = other.y 
	self.angle = other.angle 
	self.turret_angle = other.turret_angle 
	self.velocity = other.velocity
	self.angle_velocity = other.angle_velocity
end

-------------------------------------------------------------------------------
function m_tank.neq( a, b )
	if a.x ~= b.x then
		return true
	end
	if a.y ~= b.y then
		return true
	end
	if a.angle ~= b.angle then
		return true
	end
	if a.turret_angle ~= b.turret_angle then
		return true
	end
	return false
end

-------------------------------------------------------------------------------
function m_tank.getX( self )
	return self.x
end

-------------------------------------------------------------------------------
function m_tank.getY( self )
	return self.y
end

-------------------------------------------------------------------------------
function m_tank.setXY( self, x, y )
	self.x = m_terrain.safe_x( x )
	self.y = m_terrain.safe_y( y )
end

-------------------------------------------------------------------------------
function m_tank.update( self, tank_command )

	-- update position
	self.x = self.x + self.velocity * math.cos( self.angle )
	self.y = self.y + self.velocity * math.sin( self.angle )
	self.x, self.y = m_terrain.safeXY( self.x, self.y )
	m_terrain.camera_x = self.x
	m_terrain.camera_y = self.y
	self.angle = m_utils.round_angle( self.angle + self.angle_velocity )

	-- update turret angle
	local mouse_angle = tank_command.mouse_angle
	self.turret_angle = math.atan2( math.sin( self.turret_angle ), math.cos( self.turret_angle ) )
	
	if math.abs(mouse_angle - self.turret_angle) < 0.1 then
		self.turret_angle = mouse_angle
	else
		mouse_angle = mouse_angle + math.pi
		local angle_diff = mouse_angle - self.turret_angle
		angle_diff = math.atan2(math.sin(angle_diff), math.cos(angle_diff))
		if angle_diff < 0 then
			self.turret_angle = self.turret_angle + TURRET_ANGLE_VELOCITY
		end
		if angle_diff > 0 then
			self.turret_angle = self.turret_angle - TURRET_ANGLE_VELOCITY
		end	
	end
	self.turret_angle = m_utils.round_angle( self.turret_angle )
	if tank_command.fire then
		tank_command.fire = false
		local turret_x, turret_y = m_tank.turretXY( self )
		local muzzle_x, muzzle_y = m_tank.muzzleXY( self, turret_x, turret_y )
		m_bullets.fire( muzzle_x, muzzle_y, self.turret_angle )
	end

	-- update velocities
	if tank_command.up then
		if self.velocity < 0 then
			self.velocity = self.velocity + TANK_BREAKING_VELOCITY_DELTA
		else 
			self.velocity = self.velocity + TANK_VELOCITY_DELTA
		end
		if self.velocity > TANK_VELOCITY_MAX then
			self.velocity = TANK_VELOCITY_MAX
		end
	end
	if tank_command.down and not tank_command.up then
		if self.velocity > 0 then
			self.velocity = self.velocity - TANK_BREAKING_VELOCITY_DELTA
		else 
			self.velocity = self.velocity - TANK_VELOCITY_DELTA
		end
		if self.velocity < -TANK_VELOCITY_MAX then
			self.velocity = -TANK_VELOCITY_MAX
		end
	end
	if not tank_command.up and not tank_command.down then
		if math.abs(self.velocity) < TANK_INERTION_VELOCITY_DELTA then
			self.velocity = 0
		elseif self.velocity > 0 then
			self.velocity = self.velocity - TANK_INERTION_VELOCITY_DELTA
		else
			self.velocity = self.velocity + TANK_INERTION_VELOCITY_DELTA
		end
	end
	self.angle_velocity = 0
	if tank_command.left and not tank_command.right then
		self.angle_velocity = -TANK_ANGLE_VELOCITY
	end
	if tank_command.right and not tank_command.left then
		self.angle_velocity = TANK_ANGLE_VELOCITY
	end	
end

-------------------------------------------------------------------------------
function m_tank.turretXY( self )
	local turret_x = self.x + TURRET_BASE_OFFSET * math.cos( self.angle )
	local turret_y = self.y + TURRET_BASE_OFFSET * math.sin( self.angle )
	return turret_x, turret_y
end

-------------------------------------------------------------------------------
function m_tank.muzzleXY( self, turret_x, turret_y )
	local muzzle_x = turret_x + MUZZLE_LENGTH * math.cos( self.turret_angle )
	local muzzle_y = turret_y + MUZZLE_LENGTH * math.sin( self.turret_angle )
	muzzle_x = muzzle_x + MUZZLE_SHIFT * math.cos( math.pi / 2 + self.turret_angle )
	muzzle_y = muzzle_y + MUZZLE_SHIFT * math.sin( math.pi / 2 + self.turret_angle )
	return muzzle_x, muzzle_y
end

-------------------------------------------------------------------------------
function m_tank.draw( self )
	local turret_x, turret_y = m_tank.turretXY( self )
	--local muzzle_x, muzzle_y = m_tank.muzzleXY( self, turret_x, turret_y )
	love.graphics.draw( img_tank_base, self.x, self.y, self.angle, 1.0, 1.0, BASE_CENTER_X, BASE_CENTER_Y )
	love.graphics.draw( img_tank_turret, turret_x, turret_y, self.turret_angle, 1.0, 1.0, TURRET_CENTER_X, TURRET_CENTER_Y )
	--love.graphics.circle( "fill", muzzle_x, muzzle_y, 10 )
end

-------------------------------------------------------------------------------
return m_tank
