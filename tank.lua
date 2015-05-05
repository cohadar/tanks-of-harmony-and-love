--- @module tank
local m_tank = {}

local m_terrain = require "terrain"

-- drawing properties 
TURRET_CENTER_X = 21.0
TURRET_CENTER_Y = 28.0
TURRET_BASE_OFFSET = 10
BASE_CENTER_X = 64
BASE_CENTER_Y = 38
TURRET_ANGLE_VELOCITY = math.pi / 64

-------------------------------------------------------------------------------
function m_tank.new()
	local self = {}
	self.x = 256.0
	self.y = 256.0
	self.angle = 0.0
	self.turret_angle = 0.0
	return self
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
	self.x = m_terrain.safe_x( self.x + tank_command.velocity * math.cos( self.angle ) )
	self.y = m_terrain.safe_y( self.y + tank_command.velocity * math.sin( self.angle ) )
	g_camera_x = self.x
	g_camera_y = self.y	
	self.angle = self.angle + tank_command.angle_velocity

	
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
