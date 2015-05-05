--- @module text
local m_text = {}

local MAX_FLOATING = 100
floating = {}
local last_floating = 0
local FPS = 60
local last_y = 100

-------------------------------------------------------------------------------
function m_text.print( ... )
	local str = ""
	for n = 1, select( '#', ... ) do
  		local e = select( n, ... )
  		str = str .. e .. " "
  		last_floating = last_floating + 1
  		if last_floating > 100 then
  			last_floating = 1
  		end
  		if last_y > 88 then
  			last_y = last_y + 12
  		else
  			last_y = 100
  		end
  		floating[ last_floating ] = { text = str, duration = 5.0 * FPS, y = last_y }
	end
end

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
end


-------------------------------------------------------------------------------
return m_text
