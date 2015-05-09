--- @module gui
local gui = {}

gui = require "libs.quickie"
text = require "text"
client = require "client"

local _guiActive = true

local _menuStart = true
local _menuCreate = false
local _menuJoin = false

local _serverAddress = { text = "127.0.0.1" }
local _serverPort    = { text = "12345" }

-------------------------------------------------------------------------------
function gui.resetMenus()
	_menuStart = true
	_menuCreate = false
	_menuJoin = false
end

-------------------------------------------------------------------------------
function gui.update()
	if _guiActive == false then
		return
	end

	gui.group.push{ grow = "down", pos = { 10, 10 } }

	if _menuStart then
 		gui.menuStart()
 	elseif _menuCreate then
 		gui.menuCreate()
 	elseif _menuJoin then
 		gui.menuJoin()
	end

    gui.group.pop{}    
end

-------------------------------------------------------------------------------
function gui.menuStart()
	if gui.Button{ id = "create", text = "Create", hotkey="c" } then
		_menuStart = false
		_menuCreate = true
    end

	if gui.Button{ id = "join", text = "Join", hotkey="j" } then
		_menuStart = false
		_menuJoin = true
    end   

	if gui.Button{ id = "quit", text = "Quit", hotkey="q" } then
		love.event.quit()
    end      
end

-------------------------------------------------------------------------------
function gui.menuCreate()
	gui.group.push{ grow = "down" }
    gui.Input{ info = _serverAddress, size = { 200 } }
    gui.Input{ info = _serverPort, size = { 200 } }
    if gui.Button{ id = "start_server", text = "Start Server", hotkey="s" } then
		_menuStart = true
		_menuCreate = false
		text.status( "starting server", _serverAddress.text .. ":" .. _serverPort.text )
		thread = love.thread.newThread( "server.lua" )
		thread:start()
		channel = love.thread.getChannel( "server_channel" )
		channel:push{ host = _serverAddress.text, port = _serverPort.text }
		client.connect( _serverAddress.text, _serverPort.text )
		_guiActive = false			
	end
    gui.group.pop{}    
end

-------------------------------------------------------------------------------
function gui.menuJoin()
	gui.group.push{ grow = "down" }
    gui.Input{ info = _serverAddress, size = { 200 } }
    gui.Input{ info = _serverPort, size = { 200 } }
    if gui.Button{ id = "join_server", text = "Join Server", hotkey="j" } then
		_menuStart = true
		_menuCreate = false
		text.status( "connecting to server", _serverAddress.text .. ":" .. _serverPort.text )
		client.connect( _serverAddress.text, _serverPort.text )
		_guiActive = false
	end
    gui.group.pop{}    
end

-------------------------------------------------------------------------------
function gui.keyreleased( key )
	if key == "escape" then
		if _guiActive == false then
			gui.resetMenus()
			_guiActive = true
		else
			if _menuStart then
				_guiActive = false
			else
				gui.resetMenus()
			end
		end
	end
end

-------------------------------------------------------------------------------
return gui