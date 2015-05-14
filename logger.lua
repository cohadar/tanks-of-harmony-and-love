--- @module log
logger = {}

if love.filesystem == nil then
	require "love.filesystem"
end

-------------------------------------------------------------------------------
function logger.info( data )
	love.filesystem.append( "log.txt", "INFO[" .. os.date( "%X", os.time() ) .. "]" .. data .. "\r\n" )
end

-------------------------------------------------------------------------------
function logger.warn( data )
	love.filesystem.append( "log.txt", "WARN[" .. os.date( "%X", os.time() ) .. "]" .. data .. "\r\n" )
end

-------------------------------------------------------------------------------
function logger.error( data )
	love.filesystem.append( "log.txt", "ERROR[" .. os.date( "%X", os.time() ) .. "]" .. data .. "\r\n" )
end

-------------------------------------------------------------------------------
return logger
