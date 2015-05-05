--- @module client
local m_client = {}

require "serpent"
require "enet"

local host = nil
local server = nil

local UPDATE_INTERVAL = 0.1 -- how long to wait, in seconds, before requesting an update

local t
local udp
local connected = false
local index_on_server = 0

-------------------------------------------------------------------------------
function m_client.is_connected()
	return connected
end

-------------------------------------------------------------------------------
function m_client.init( g_tanks )
	host = enet.host_create()
	server = host:connect("localhost:12345")
    t = 0
end

-------------------------------------------------------------------------------
function m_client.update( tank, dt )
	t = t + dt
	if connected and t > UPDATE_INTERVAL then
		local datagram = serpent.dump( { type = "tank", tank = localhost_tank } )
    	server:send( datagram )
    	--print( datagram )
    	t = t - UPDATE_INTERVAL
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
						--if msg.index ~= index_on_server then
							g_tanks[ msg.index ] = msg.tank
						--end
					elseif msg.type == "index" then
						index_on_server = msg.index
						connected = true
						g_tanks[ index_on_server ] = localhost_tank
						print( "index_on_server", index_on_server )
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
