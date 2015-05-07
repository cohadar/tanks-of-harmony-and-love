--- @module client
local m_client = {}

require "libs.serpent"
require "enet"
m_tank = require "tank"
m_tank_command = require "tank_command"
m_utils = require "utils"
m_world = require "world"
m_history = require "history"
m_text = require "text"

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
	-- nothing
end

-------------------------------------------------------------------------------
function m_client.connect( address, port )
	m_client.quit()
	host = enet.host_create()
	server = host:connect( address .. ":" .. port )
end

-------------------------------------------------------------------------------
local function tank_sync( msg )
	if NETCODE_DEBUG then
		m_world.update_tank( msg.index, msg.tank )
	end
	local old_tank = m_history.get_tank( msg.client_tick )
	if old_tank == nil then
		m_text.print("nil_sync", msg.client_tick, msg.server_tick)
		-- TODO: insted of resetting, replay modified from history
		m_history.reset()
		g_tick = msg.server_tick + 1
		m_world.update_tank( 0, msg.tank )
		m_history.tank_record( msg.client_tick, msg.tank )
		m_history.tank_record( g_tick, msg.tank )
	else		
		if m_tank.neq( old_tank, msg.tank ) then
			m_text.print("forced_sync", msg.client_tick, msg.server_tick)
			-- TODO: insted of resetting, replay modified from history
			m_history.reset()
			g_tick = msg.server_tick + 1
			m_world.update_tank( 0, msg.tank )
			m_history.tank_record( msg.client_tick, msg.tank )
			m_history.tank_record( g_tick, msg.tank )
		end
	end
end

-------------------------------------------------------------------------------
function m_client.update( tank, tank_command )
	if connected then
		m_history.tank_record( g_tick, tank )
		--print("rec_tank", g_tick, serpent.line(tank))
		local datagram = serpent.dump( { type = "tank_command", tank_command = tank_command, client_tick = g_tick } )
    	server:send( datagram, 0, "unsequenced" )
	end
	if not server then 
		return 
	end
	repeat
		event = host:service(0)
		if event then
			if event.type == "connect" then
				m_text.status( "Connected to", event.peer )
			elseif event.type == "receive" then
				-- print( "Got message: ", event.data, event.peer )
				local ok, msg = serpent.load( event.data )
				if ok then
					if msg.type == "tank" then 
						if index_on_server == msg.index then
							tank_sync( msg )
						else
							m_world.update_tank( msg.index, msg.tank )
						end
					elseif msg.type == "index" then
						index_on_server = msg.index
						love.window.setTitle( "Connected as Player #" .. index_on_server )
						connected = true
						m_world.connect( index_on_server )
						m_text.print( "index on server: ", index_on_server )
					elseif msg.type == "player_gone" then
						m_world.player_gone( msg.index )
						-- TODO: display disconnected tanks in gray for a short time
					else
						m_text.print("ERROR: unknown msg.type: ", msg.type, event.data )
					end
				end
			elseif event.type == "disconnect" then
				m_text.status( "disconnect" )
				love.window.setTitle( "Not Connected" )
				m_client.quit()
				-- TODO: handle disconnect gracefully
			else 
				m_text.print( "ERROR: unknown event.type: ", event.type, event.data )
			end
		end
	until not event
end

-------------------------------------------------------------------------------
function m_client.quit()
	if server ~= nil then
		server:disconnect()
		host:flush()
	end
	server = nil
	connected = false
end

-------------------------------------------------------------------------------
return m_client
