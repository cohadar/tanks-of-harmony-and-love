--- @module conf
local m_conf = {}

m_conf.GAME_DEBUG = true
m_conf.NETCODE_DEBUG = false

m_conf.SCREEN_WIDTH  = 0
m_conf.SCREEN_HEIGHT = 0
m_conf.SCREEN_WIDTH_HALF  = 0
m_conf.SCREEN_HEIGHT_HALF = 0

if m_conf.GAME_DEBUG then
	m_conf.SCALE_GRAPHICS = 0.75
else
	m_conf.SCALE_GRAPHICS = 1.00
end

-------------------------------------------------------------------------------
function love.conf( t )
	t.identity = "Mighty Cohadar's Tanks of Harmony and Love"
	t.window.width  = 16 * 64  
	t.window.height =  9 * 64 
	if m_conf.GAME_DEBUG then
		t.window.borderless = false
		t.window.fullscreen = false
	else
		t.window.borderless = true
		t.window.fullscreen = true
	end
end

-------------------------------------------------------------------------------
return m_conf
