--- @module gui
local m_gui = {}

gui = require "libs.quickie"
m_text = require "text"
m_client = require "client"

local gui_on = true

local start_menu = true
local create_menu = false
local join_menu = false

local server_address = { text = "127.0.0.1" }
local server_port    = { text = "12345" }

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

	gui.group.push{ grow = "down", pos = { 10, 10 } }

	if start_menu then
 		m_gui.start_menu( dt )
 	elseif create_menu then
 		m_gui.create_menu( dt )
 	elseif join_menu then
 		m_gui.join_menu( dt )
	end

    gui.group.pop{}    
end

-------------------------------------------------------------------------------
function m_gui.start_menu( dt )
	if gui.Button{id = "create", text = "Create", hotkey="c" } then
		start_menu = false
		create_menu = true
    end

	if gui.Button{id = "join", text = "Join", hotkey="j" } then
		start_menu = false
		join_menu = true
    end   

	if gui.Button{id = "quit", text = "Quit", hotkey="q" } then
		love.event.quit()
    end      
end

-------------------------------------------------------------------------------
function m_gui.create_menu( dt )
    gui.group{grow = "down", function()
        gui.Input{info = server_address, size = { 200 } }
        gui.Input{info = server_port, size = { 200 } }
        if gui.Button{id = "start_server", text = "Start Server", hotkey="s" } then
			start_menu = true
			create_menu = false
			m_text.status("starting server", server_address.text .. ":" .. server_port.text )
			thread = love.thread.newThread( "server.lua" )
			thread:start()
			channel = love.thread.getChannel( "server_channel" )
			channel:push{ host = server_address.text, port = server_port.text }
			m_client.connect( server_address.text, server_port.text )
			gui_on = false			
    	end
    end}	
end

-------------------------------------------------------------------------------
function m_gui.join_menu( dt )
    gui.group{grow = "down", function()
        gui.Input{info = server_address, size = { 200 } }
        gui.Input{info = server_port, size = { 200 } }
        if gui.Button{id = "join_server", text = "Join Server", hotkey="j" } then
			start_menu = true
			create_menu = false
			m_text.status("connecting to server", server_address.text .. ":" .. server_port.text )
			m_client.connect( server_address.text, server_port.text )
			gui_on = false
    	end
    end}	
end

-------------------------------------------------------------------------------
function m_gui.keyreleased( key )
	if key == "escape" then
		if gui_on == false then
			m_gui.reset_menus()
			gui_on = true
		else
			if start_menu then
				gui_on = false
			else
				m_gui.reset_menus()
			end
		end
	end
end

-------------------------------------------------------------------------------
return m_gui