--- @module text
local text = {}

local MAX_FLOATING = 20
local FPS = 60
local FLOAT_START_Y = 100
local FLOAT_SPACING = 12

local _floating = {}
local _lastFloating = 0
local _lastY = 100
local _status = { text = "welcome", duration = 10 * FPS, active = true }

-------------------------------------------------------------------------------
local function argsToStr( ... )
	local str = ""
	for n = 1, select( '#', ... ) do
  		local e = select( n, ... )
  		str = str .. tostring( e ) .. " "
	end
	return str	
end

-------------------------------------------------------------------------------
function text.print( ... )
	if not love then
		print( ... )
		return 
	end
	local str = argsToStr( ... )
	_lastFloating = _lastFloating + 1
	if _lastFloating > MAX_FLOATING then
		_lastFloating = 1
	end
	if _lastY > FLOAT_START_Y - FLOAT_SPACING then
		_lastY = _lastY + FLOAT_SPACING
	else
		_lastY = FLOAT_START_Y
	end
	_floating[ _lastFloating ] = { text = str, duration = 5.0 * FPS, y = _lastY }	
end

-------------------------------------------------------------------------------
function text.status( ... )
	if not love then
		print( ... )
		return 
	end
	local str = argsToStr( ... )
	_status.text = str
	_status.duration = 10 * FPS
	_status.active = true
end

-------------------------------------------------------------------------------
-- called from love2d game 
-------------------------------------------------------------------------------
function text.init()
	FLOAT_START_Y = love.graphics.getHeight() - 100
end

-------------------------------------------------------------------------------
-- called from love2d game 
-------------------------------------------------------------------------------
function text.draw()
	local max_y = 0
	for i = 1, MAX_FLOATING do
		local ft = _floating[ i ]
		if ft then
			ft.duration = ft.duration - 1
			if ft.duration < 0 then
				_floating[ i ] = nil
			else
				love.graphics.print( ft.text, 50, ft.y )
				ft.y = ft.y - 1
				if ft.y > max_y then
					max_y = ft.y
				end
			end
		end
	end
	_lastY = max_y
	if _status.active then
		_status.duration = _status.duration - 1
		if _status.duration < 0 then
			_status.active = false
		end
		love.graphics.print( _status.text, 50, love.graphics.getHeight() - 50 )
	end
end


-------------------------------------------------------------------------------
return text
