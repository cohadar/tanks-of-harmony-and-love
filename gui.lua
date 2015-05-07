--- @module gui
local m_gui = {}

gui = require "libs.quickie"

local gui_on = true

local start_menu = true
local create_menu = false
local join_menu = false

-------------------------------------------------------------------------------
function m_gui.reset_menus()
	start_menu = true
	create_menu = false
	join_menu = false
end

-------------------------------------------------------------------------------
function m_gui.update( dt )
	if gui_on == false then
		return
	end

	gui.group.push{ grow = "down", pos = { 5, 150 } }

	if start_menu then
 		m_gui.start_menu( dt )
	end

    gui.group.pop{}    
end

-------------------------------------------------------------------------------
function m_gui.start_menu( dt )
	if gui.Button{id = "create", text = "Create Game"} then
		start_menu = false
		create_menu = true
    end

	if gui.Button{id = "join", text = "Join Game"} then
		start_menu = false
		join_menu = true
        gui_on = false
    end   

	if gui.Button{id = "exit", text = "Exit"} then
		love.event.quit()
    end      
end

-------------------------------------------------------------------------------
function m_gui.keyreleased( key )
	if key == "escape" then
		gui_on = not gui_on
		m_gui.reset_menus()
	end
	if gui_on then
		if start_menu then
			if key == "x" then
				love.event.quit()
			end
		end
	end
end

-------------------------------------------------------------------------------
return m_gui