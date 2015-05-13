--- @module tank
local tank = {}

local terrain = require "terrain"
local utils = require "utils"
local bullets = require "bullets"
local effects = require "effects"

-- gameplay constants
local FPS = 32
local TANK_VELOCITY_MAX = 4.0 * 2
local TANK_VELOCITY_DELTA = TANK_VELOCITY_MAX / FPS / 2
local TANK_BREAKING_VELOCITY_DELTA = TANK_VELOCITY_DELTA * 2
local TANK_INERTION_VELOCITY_DELTA = TANK_VELOCITY_DELTA * 1.5
local TANK_ANGLE_VELOCITY = math.pi / 128 * 2
local TURRET_ANGLE_VELOCITY = math.pi / 64 * 2

-- drawing constants
local IMG_TANK_BASE = nil
local IMG_TANK_BASE_CX = 64
local IMG_TANK_BASE_CY = 38
local IMG_TANK_HP_W = 8
local IMG_TANK_HP_H = 65
local IMG_TANK_HP_DX = -44
local IMG_TANK_HP_DY = -32

local IMG_TANK_TURRET = nil
local IMG_TANK_TURRET_CX = 21.0
local IMG_TANK_TURRET_CY = 28.0
local IMG_TANK_RADIUS = 70
local COLOR_RED_TEAM = "pastel red"
local COLOR_BLUE_TEAM = "lightblue"
local COLOR_HP_BAR = "dark cream"

-- export
tank.IMG_TANK_RADIUS = IMG_TANK_RADIUS

local TURRET_BASE_OFFSET = 10
local MUZZLE_LENGTH = 120
local MUZZLE_SHIFT = -9

-------------------------------------------------------------------------------
function tank.init()
	IMG_TANK_BASE = love.graphics.newImage( "resources/base.png" )
	IMG_TANK_TURRET = love.graphics.newImage( "resources/turret.png" )
end

-------------------------------------------------------------------------------
function tank.newCommand()
	return {
		up = false,
		down = false,
		left = false,
		right = false,
		mouse_angle = 0.0,
		fire = false,
		client_tick = 0
	}
end

-------------------------------------------------------------------------------
function tank.new()
	local self = {}
	self.x = 256.0
	self.y = 256.0
	self.angle = 0.0
	self.turret_angle = 0.0
	self.velocity = 0.0
	self.angle_velocity = 0.0
	self.hp = 100
	self.team = "red" -- "blue"
	return self
end

-------------------------------------------------------------------------------
function tank.slurp( self, other )
	self.x = other.x
	self.y = other.y 
	self.angle = other.angle 
	self.turret_angle = other.turret_angle 
	self.velocity = other.velocity
	self.angle_velocity = other.angle_velocity
	self.hp = other.hp
	self.team = other.team
end

-------------------------------------------------------------------------------
function tank.neq( a, b )
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
local function calcVelocity( velocity, up, down )
	if up then
		if velocity < 0 then
			velocity = velocity + TANK_BREAKING_VELOCITY_DELTA
		else 
			velocity = velocity + TANK_VELOCITY_DELTA
		end
		if velocity > TANK_VELOCITY_MAX then
			velocity = TANK_VELOCITY_MAX
		end
	end
	if down and not up then
		if velocity > 0 then
			velocity = velocity - TANK_BREAKING_VELOCITY_DELTA
		else 
			velocity = velocity - TANK_VELOCITY_DELTA
		end
		if velocity < -TANK_VELOCITY_MAX then
			velocity = -TANK_VELOCITY_MAX
		end
	end
	if not up and not down then
		if math.abs(velocity) < TANK_INERTION_VELOCITY_DELTA then
			velocity = 0
		elseif velocity > 0 then
			velocity = velocity - TANK_INERTION_VELOCITY_DELTA
		else
			velocity = velocity + TANK_INERTION_VELOCITY_DELTA
		end
	end
	return velocity
end

-------------------------------------------------------------------------------
local function calcAngleVelocity( angle_velocity, left, right )
	angle_velocity = 0
	if left and not right then
		angle_velocity = -TANK_ANGLE_VELOCITY
	end
	if right and not left then
		angle_velocity = TANK_ANGLE_VELOCITY
	end			
	return angle_velocity
end

-------------------------------------------------------------------------------
local function calcTurretAngle( turret_angle, mouse_angle )
	if math.abs( mouse_angle - turret_angle ) < TURRET_ANGLE_VELOCITY then
		turret_angle = mouse_angle
	else
		local angle_diff = utils.cleanAngle( mouse_angle + math.pi - turret_angle )
		if angle_diff < 0 then
			turret_angle = turret_angle + TURRET_ANGLE_VELOCITY
		end
		if angle_diff > 0 then
			turret_angle = turret_angle - TURRET_ANGLE_VELOCITY
		end	
	end
	return utils.cleanAngle( turret_angle )	
end

-------------------------------------------------------------------------------
local function calcTurretXY( x, y, angle )
	local turret_x = x + TURRET_BASE_OFFSET * math.cos( angle )
	local turret_y = y + TURRET_BASE_OFFSET * math.sin( angle )
	return turret_x, turret_y
end

-------------------------------------------------------------------------------
function calcMuzzleXY( turret_x, turret_y, turret_angle )
	local muzzle_x = turret_x + MUZZLE_LENGTH * math.cos( turret_angle )
	local muzzle_y = turret_y + MUZZLE_LENGTH * math.sin( turret_angle )
	muzzle_x = muzzle_x + MUZZLE_SHIFT * math.cos( math.pi / 2 + turret_angle )
	muzzle_y = muzzle_y + MUZZLE_SHIFT * math.sin( math.pi / 2 + turret_angle )
	return muzzle_x, muzzle_y
end

-------------------------------------------------------------------------------
function tank.update( self, tank_command )
	-- update position
	self.x = self.x + self.velocity * math.cos( self.angle )
	self.y = self.y + self.velocity * math.sin( self.angle )
	self.x, self.y = terrain.safeXY( self.x, self.y )
	-- update angle
	self.angle = utils.cleanAngle( self.angle + self.angle_velocity )
	-- update turret angle
	self.turret_angle = calcTurretAngle( self.turret_angle, tank_command.mouse_angle )
	-- fire?
	if tank_command.fire then
		local turret_x, turret_y = calcTurretXY( self.x, self.y, self.angle )
		local muzzle_x, muzzle_y = calcMuzzleXY( turret_x, turret_y, self.turret_angle )
		bullets.fire( muzzle_x, muzzle_y, self.turret_angle )
		effects.addExplosion( muzzle_x, muzzle_y, 0.1 )
	end
	-- update velocities
	self.velocity = calcVelocity( self.velocity, tank_command.up, tank_command.down )
	self.angle_velocity = calcAngleVelocity( self.angle_velocity, tank_command.left, tank_command.right )
end

-------------------------------------------------------------------------------
function tank.draw( self )
	-- base
	if self.team == "red" then
		utils.setColor( COLOR_RED_TEAM )
	else
		utils.setColor( COLOR_BLUE_TEAM )
	end
	love.graphics.draw( IMG_TANK_BASE, self.x, self.y, self.angle, 1.0, 1.0, IMG_TANK_BASE_CX, IMG_TANK_BASE_CY )
	-- health bar
	love.graphics.push()
	love.graphics.translate( self.x, self.y )
	love.graphics.rotate( self.angle )
	utils.setColor( COLOR_HP_BAR )
	love.graphics.rectangle( "fill", IMG_TANK_HP_DX, IMG_TANK_HP_DY, IMG_TANK_HP_W, IMG_TANK_HP_H * self.hp / 100 )
	utils.setColor( "black" )
	love.graphics.setLineWidth( 2.0 )
	love.graphics.rectangle( "line", IMG_TANK_HP_DX, IMG_TANK_HP_DY, IMG_TANK_HP_W, IMG_TANK_HP_H )
	love.graphics.pop()
	utils.setColor( "white" )
	-- turret
	local turret_x, turret_y = calcTurretXY( self.x, self.y, self.angle )
	love.graphics.draw( IMG_TANK_TURRET, turret_x, turret_y, self.turret_angle, 1.0, 1.0, IMG_TANK_TURRET_CX, IMG_TANK_TURRET_CY )
end

-------------------------------------------------------------------------------
function tank.confirmHit( tnk, x, y )
	-- TODO: precise hit calculation based on tank angle
	return true
end

-------------------------------------------------------------------------------
return tank
