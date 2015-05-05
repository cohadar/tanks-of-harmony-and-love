--- @module client
local m_client = {}

require "serpent"
require "enet"
m_tank_command = require "tank_command"
m_utils = require "utils"
m_world = require "world"
m_history = require "history"

local host = nil
local server = nil

local udp
local connected = false
local index_on_server = 0

-------------------------------------------------------------------------------
function m_client.is_connected()
	return connected
end

-------------------------------------------------------------------------------
function m_client.init()
	host = enet.host_create()
	server = host:connect("localhost:12345")
end

-------------------------------------------------------------------------------
function m_client.update( tank, tank_command )
	if connected then
		local tick = m_history.tank_record( m_utils.deepcopy( tank ) )
		local datagram = serpent.dump( { type = "tank_command", tank_command = tank_command } )
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
						if index_on_server == msg.index then							
							-- local old_tank = m_history.get_tank( msg.tick )
							-- if old_tank == nil then
							-- 	print("nil", msg.tick)
							-- 	m_world.update_tank( msg.index, msg.tank ) 
							-- else
							-- 	if m_tank.neq( old_tank, msg.tank ) then
							-- 		-- TODO: insted of resetting, replay modified from history
							-- 		m_world.update_tank( msg.index, msg.tank )
							-- 		print("server_force", msg.tick, old_tank.x, msg.tank.x)
							-- 	end
							-- 	m_history.clear_tank_record( msg.tick )
							-- end
							m_world.update_tank( msg.index, msg.tank )
						else
							m_world.update_tank( msg.index, msg.tank )

						end
					elseif msg.type == "index" then
						index_on_server = msg.index
						connected = true
						m_world.connect( index_on_server )
						print( "index_on_server", index_on_server )
					elseif msg.type == "player_gone" then
						m_world.player_gone( msg.index )
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
