--- @module text
local m_text = {}

local MAX_FLOATING = 100
floating = {}
local last_floating = 0
local FPS = 60
local last_y = 100
status = { text = "welcome", duration = 10 * FPS, active = true }
local FLOAT_START_Y = 100

-------------------------------------------------------------------------------
function m_text.print( ... )
	if not love then
		print( ... )
		return 
	end
	local str = ""
	for n = 1, select( '#', ... ) do
  		local e = select( n, ... )
  		str = str .. tostring( e ) .. " "
	end
	last_floating = last_floating + 1
	if last_floating > FLOAT_START_Y then
		last_floating = 1
	end
	if last_y > FLOAT_START_Y - 12 then
		last_y = last_y + 12
	else
		last_y = FLOAT_START_Y
	end
	floating[ last_floating ] = { text = str, duration = 5.0 * FPS, y = last_y }	
end

-------------------------------------------------------------------------------
function m_text.status( ... )
	if not love then
		print( ... )
		return 
	end
	local str = ""
	for n = 1, select( '#', ... ) do
  		local e = select( n, ... )
  		str = str .. tostring( e ) .. " "
	end
	status.text = str
	status.duration = 10 * FPS
	status.active = true
end

-------------------------------------------------------------------------------
-- called from love2d game 
-------------------------------------------------------------------------------
function m_text.init()
	FLOAT_START_Y = love.graphics.getHeight() - 100
end

-------------------------------------------------------------------------------
-- called from love2d game 
-------------------------------------------------------------------------------
function m_text.draw()
	local max_y = 0
	for i = 1, 100 do
		local ft = floating[ i ]
		if ft then
			ft.duration = ft.duration - 1
			if ft.duration < 0 then
				floating[ i ] = nil
			else
				love.graphics.print( ft.text, 50, ft.y )
				ft.y = ft.y - 1
				if ft.y > max_y then
					max_y = ft.y
				end
			end
		end
	end
	last_y = max_y
	if status.active then
		status.duration = status.duration - 1
		if status.duration < 0 then
			status.active = false
		end
		love.graphics.print( status.text, 50, love.graphics.getHeight() - 50 )
	end
end


-------------------------------------------------------------------------------
return m_text
