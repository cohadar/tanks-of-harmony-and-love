--- @module terrain
local m_terrain = {}

MAP_WIDTH  = 16 -- squares
MAP_HEIGHT = 12 -- squares
MAP_SQUARE = 64 -- pixels
VISIBLE_SQUARES_X = 0
VISIBLE_SQUARES_Y = 0

-------------------------------------------------------------------------------
function m_terrain.safe_x(x)
	if x < 0 then
		return 0
	end
	if x > MAP_WIDTH * MAP_SQUARE then
		return MAP_WIDTH * MAP_SQUARE
	end
	return x
end

-------------------------------------------------------------------------------
function m_terrain.safe_y(y)
	if y < 0 then
		return 0
	end
	if y > MAP_HEIGHT * MAP_SQUARE then
		return MAP_HEIGHT * MAP_SQUARE
	end
	return y
end

-------------------------------------------------------------------------------
function m_terrain.init()
	--love.graphics.setBackgroundColor(0x00, 0x00, 0x00, 0xFF)
	VISIBLE_SQUARES_X = MAP_WIDTH -- math.floor(SCREEN_WIDTH / MAP_SQUARE) + 2
	VISIBLE_SQUARES_Y = MAP_HEIGHT -- math.floor(SCREEN_HEIGHT / MAP_SQUARE) + 2
end

-------------------------------------------------------------------------------
local function out_of_map(mx, my) 
	if mx < 0 or my < 0 then
		return true
	end
	if mx >= MAP_WIDTH or my >= MAP_HEIGHT then
		return true
	end
	return false
end

-------------------------------------------------------------------------------
function m_terrain.draw()
	for x = -10, VISIBLE_SQUARES_X + 10 do
		for y = -10, VISIBLE_SQUARES_Y + 10 do
			local mx = x
			local my = y
			if out_of_map(mx, my) then
				love.graphics.setColor(0x00, 0x00, 0x00, 0xFF)
			elseif (mx + my) % 2 == 0 then
				love.graphics.setColor(0xBD, 0x71, 0x40, 0xFF)
			else
				love.graphics.setColor(0xAD, 0x81, 0x50, 0xFF)
			end
			love.graphics.rectangle("fill", mx*MAP_SQUARE, my*MAP_SQUARE, MAP_SQUARE, MAP_SQUARE)
		end
	end
end

-------------------------------------------------------------------------------
return m_terrain