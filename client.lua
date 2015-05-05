--- @module client
local m_client = {}

require "serpent"
require "enet"
m_tank_command = require "tank_command"
m_utils = require "utils"

local host = nil
local server = nil

local udp
local connected = false
local index_on_server = 0
local previous_tank_command = m_tank_command.new()

-------------------------------------------------------------------------------
function m_client.is_connected()
	return connected
end

-------------------------------------------------------------------------------
function m_client.init( g_tanks )
	host = enet.host_create()
	server = host:connect("localhost:12345")
end

-------------------------------------------------------------------------------
function m_client.update( tank, tank_command )
	if connected and m_tank_command.neq( tank_command, previous_tank_command ) then
		previous_tank_command = m_utils.deepcopy( tank_command )
		local datagram = serpent.dump( { type = "tank_command", tank_command = tank_command, timestamp = os.time() } )
    	server:send( datagram )
	end
	repeat
		event = host:service(0)
		if event then
			if event.type == "connect" then
				print( "Connected to", event.peer, os.time() )
			elseif event.type == "receive" then
				-- print( "Got message: ", event.data, event.peer )
				local ok, msg = serpent.load( event.data )
				if ok then
					if msg.type == "tank" then 
						g_tanks[ msg.index ] = msg.tank
					elseif msg.type == "index" then
						index_on_server = msg.index
						connected = true
						g_tanks[ index_on_server ] = localhost_tank
						print( "index_on_server", index_on_server )
					elseif msg.type == "player_gone" then
						g_tanks[ msg.index ] = nil
						-- TODO: display disconnected tanks in gray for a short time
					else
						print( "unknown msg.type: ", msg.type, event.data )
					end
				end
			elseif event.type == "disconnect" then
				print( "disconnect" )
				connected = false
				-- TODO: handle disconnect gracefully
			else 
				print( "unknown event.type: ", event.type, event.data )
			end
		end
	until not event
end

-------------------------------------------------------------------------------
function m_client.quit()
	server:disconnect()
	host:flush()
end

-------------------------------------------------------------------------------
return m_client
