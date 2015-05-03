--- @module client
local m_client = {}

serpent = require "serpent"
require "enet"
local host = nil
local server = nil

local entity -- entity is what we'll be controlling
local updaterate = 0.1 -- how long to wait, in seconds, before requesting an update

local world = {} -- the empty world-state
local t
local udp

-------------------------------------------------------------------------------
function m_client.init()
	host = enet.host_create()
	server = host:connect("localhost:12345")

	math.randomseed( os.time() )
    entity = tostring( math.random( 99999 ) )
    t = 0
end

-------------------------------------------------------------------------------
function m_client.update( dt )
	t = t + dt
	if t > updaterate then
		local datagram = serpent.dump( { entity = entity, x = m_tank.getX(), y = m_tank.getY(), timestamp = os:clock() } )
    	host:broadcast( datagram )
    	--print( datagram )
    	t = t - updaterate
	end
	repeat
		event = host:service(0)
		if event then
			if event.type == "connect" then
				print( "Connected to", event.peer )
			elseif event.type == "receive" then
				-- print( "Got message: ", event.data, event.peer )
				local ok, res = serpent.load( event.data )
				if ok then
					print( os:clock() - res.timestamp, res.timestamp  )
					m_tank.setXY( res.x, res.y )
				end
			elseif event.type == "disconnect" then
				print( "disconnect" )
				-- TODO: handle disconnect gracefully
			else 
				print( "unknown event.type: ", event.type )
			end
		end
	until not event
end

-------------------------------------------------------------------------------
function m_client.draw()
    -- pretty simple, we
    for k, v in pairs(world) do
        love.graphics.print(k, v.x, v.y)
    end
end

-------------------------------------------------------------------------------
function m_client.quit()
	server:disconnect()
	host:flush()
end

-------------------------------------------------------------------------------
return m_client
