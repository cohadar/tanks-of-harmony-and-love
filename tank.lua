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

-- gameplay properties
local FPS = 32
local TANK_VELOCITY_MAX = 4.0 * 2
local TANK_VELOCITY_DELTA = TANK_VELOCITY_MAX / FPS / 2
local TANK_BREAKING_VELOCITY_DELTA = TANK_VELOCITY_DELTA * 2
local TANK_INERTION_VELOCITY_DELTA = TANK_VELOCITY_DELTA * 1.5
local TANK_ANGLE_VELOCITY = math.pi / 128 * 2
local TURRET_ANGLE_VELOCITY = math.pi / 64 * 2

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
	self.x = math.floor( m_terrain.safe_x( self.x + self.velocity * math.cos( self.angle ) ) )
	self.y = math.floor( m_terrain.safe_y( self.y + self.velocity * math.sin( self.angle ) ) )
	g_camera_x = self.x
	g_camera_y = self.y	
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
		m_bullets.fire( self.x, self.y, self.turret_angle )
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
function m_tank.draw( self )
	love.graphics.draw( g_tank_base, self.x, self.y, self.angle, 1.0, 1.0, BASE_CENTER_X, BASE_CENTER_Y )
	local turret_x = self.x + TURRET_BASE_OFFSET * math.cos( self.angle )
	local turret_y = self.y + TURRET_BASE_OFFSET * math.sin( self.angle )
	love.graphics.draw( g_tank_turret, turret_x, turret_y, self.turret_angle, 1.0, 1.0, TURRET_CENTER_X, TURRET_CENTER_Y )
end

-------------------------------------------------------------------------------
return m_tank
