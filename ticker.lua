-------------------------------------------------------------------------------
-- time module firing tick events on even power two edges of os.clock()
-------------------------------------------------------------------------------
--- @module ticker
local m_ticker = {}

local t = 0
local DT = 1 / 32 -- MUST be power of 2 

-------------------------------------------------------------------------------
-- mark is time in seconds
-------------------------------------------------------------------------------
function m_ticker.init( mark )
	t = math.floor( mark ) 
	while t < mark do
		t = t + DT
	end
end

-------------------------------------------------------------------------------
-- returns true if time for another tick
-------------------------------------------------------------------------------
function m_ticker.tick( mark, p )
	if t + DT < mark then
		if p then
			print(mark - t)
		end
		t = t + DT
		return true
	end
	return false
end

-------------------------------------------------------------------------------
return m_ticker