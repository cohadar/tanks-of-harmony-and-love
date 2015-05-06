GAME_DEBUG = true
NETCODE_DEBUG = false

-------------------------------------------------------------------------------
function love.conf(t)
	t.identity = "Mighty Cohadar's Tanks of Harmony and Love"
	t.window.width  = 16 * 64  
	t.window.height =  9 * 64 
	if GAME_DEBUG then
		t.window.borderless = false
		t.window.fullscreen = false
	else
		t.window.borderless = true
		t.window.fullscreen = true
	end
end
