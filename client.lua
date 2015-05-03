--- @module client
local m_client = {}

local socket = require "socket"
local address, port = "localhost", 12345

local entity -- entity is what we'll be controlling
local updaterate = 0.1 -- how long to wait, in seconds, before requesting an update

local world = {} -- the empty world-state
local t
local udp

-------------------------------------------------------------------------------
function m_client.init()
	udp = socket.udp()
	udp:settimeout( 0 )
	udp:setpeername( address, port )
	math.randomseed( os.time() )
    entity = tostring( math.random( 99999 ) )
    t = 0
end

-------------------------------------------------------------------------------
function m_client.update( dt )
	t = t + dt
	if t > updaterate then
		local datagram = string.format( "%s %s %d %d", entity, 'at', m_tank.getX(), m_tank.getY() )
    	udp:send( datagram )
    	t = t - updaterate
	end
	repeat
		data, msg = udp:receive()
		if data then
			ent, cmd, parms = data:match( "^(%S*) (%S*) (.*)" )
			if cmd == 'at' then
                local x, y = parms:match( "^(%-?[%d.e]*) (%-?[%d.e]*)$" )
                assert( x and y )
                x, y = tonumber( x ), tonumber( y )
                world[ent] = {x=x, y=y}
                m_tank.setXY( x, y )
            else
                print( "unrecognised command:", cmd, "in: ", data )
            end
        elseif msg ~= 'timeout' then
            error( "Network error: " .. tostring( msg ) )
        end
	until not data
end

-------------------------------------------------------------------------------
function m_client.draw()
    -- pretty simple, we
    for k, v in pairs(world) do
        love.graphics.print(k, v.x, v.y)
    end
end

-------------------------------------------------------------------------------
return m_client
