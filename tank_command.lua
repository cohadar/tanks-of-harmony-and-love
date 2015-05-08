--- @module tank_command
local m_tank_command = {}

-------------------------------------------------------------------------------
function m_tank_command.new()
	local self = {}
	self.mouse_angle = 0.0
	self.fire = false
	self.up = false
	self.down = false
	self.left = false
	self.right = false
	self.changed = false
	return self
end

-------------------------------------------------------------------------------
function m_tank_command.update( self )
	self.fire = false
	self.changed = false
end

-------------------------------------------------------------------------------
function m_tank_command.upPressed( self )
	self.up = true
	self.changed = true
end

-------------------------------------------------------------------------------
function m_tank_command.downPressed( self )
	self.down = true
	self.changed = true
end

-------------------------------------------------------------------------------
function m_tank_command.leftPressed( self )
	self.left = true
	self.changed = true
end

-------------------------------------------------------------------------------
function m_tank_command.rightPressed( self )
	self.right = true
	self.changed = true
end

-------------------------------------------------------------------------------
function m_tank_command.upReleased( self )
	self.up = false
	self.changed = true
end

-------------------------------------------------------------------------------
function m_tank_command.downReleased( self )
	self.down = false
	self.changed = true
end

-------------------------------------------------------------------------------
function m_tank_command.leftReleased( self )
	self.left = false
	self.changed = true
end

-------------------------------------------------------------------------------
function m_tank_command.rightReleased( self )
	self.right = false
	self.changed = true
end

-------------------------------------------------------------------------------
function m_tank_command.setMouseAngle( self, mouse_angle )
	self.mouse_angle = mouse_angle
	self.changed = true
end

-------------------------------------------------------------------------------
function m_tank_command.fire( self )
	self.fire = true
	self.changed = true
end

-------------------------------------------------------------------------------
return m_tank_command
