--- @module tank_command
local m_tank_command = {}

-------------------------------------------------------------------------------
function m_tank_command.new()
	local self = {}
	self.velocity = 0.0
	self.angle_velocity = 0.0
	self.mouse_angle = 0.0
	return self
end

-------------------------------------------------------------------------------
function m_tank_command.neq( a, b )
	if b == nil then
		return true
	end
	if a.mouse_angle ~= b.mouse_angle then
		return true
	end
	if a.velocity ~= b.velocity then
		return true
	end
	if a.angle_velocity ~= b.angle_velocity then
		return true
	end
	return false
end

-------------------------------------------------------------------------------
function m_tank_command.upPressed( self )
	self.velocity = 4.0 
end

-------------------------------------------------------------------------------
function m_tank_command.downPressed( self )
	self.velocity = -4.0
end

-------------------------------------------------------------------------------
function m_tank_command.leftPressed( self )
	self.angle_velocity = -math.pi / 128
end

-------------------------------------------------------------------------------
function m_tank_command.rightPressed( self )
	self.angle_velocity = math.pi / 128
end

-------------------------------------------------------------------------------
function m_tank_command.upReleased( self )
	if self.velocity > 0 then
		self.velocity = 0.0 
	end
end

-------------------------------------------------------------------------------
function m_tank_command.downReleased( self )
	if self.velocity < 0 then
		self.velocity = 0.0
	end
end

-------------------------------------------------------------------------------
function m_tank_command.leftReleased( self )
	if self.angle_velocity < 0 then
		self.angle_velocity = 0
	end
end

-------------------------------------------------------------------------------
function m_tank_command.rightReleased( self )
	if self.angle_velocity > 0 then
		self.angle_velocity = 0
	end
end

-------------------------------------------------------------------------------
function m_tank_command.setMouseAngle( self, mouse_angle )
	self.mouse_angle = mouse_angle
end

-------------------------------------------------------------------------------
return m_tank_command