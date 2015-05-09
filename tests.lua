--- @module tests
local tests = {}

local utils = require "utils"
local bullets = require "bullets"

-------------------------------------------------------------------------------
local function testSerialization()
	local text = utils.pack( { pi = math.pi } )
	t =  utils.unpack( text )
	assert( math.pi == t.pi )

end

-------------------------------------------------------------------------------
local function testBullets()
	bullets.fire( 1, 2, 3.3 )
	bullets.fire( 1, 2, 4.4 )
	local package = utils.pack( bullets.exportTable() )
	print( package )
	msg = utils.unpack( package )
	print( utils.pack( msg ) )
	bullets.importTable( msg )
	print( utils.pack( bullets.exportTable() ) )
end

-------------------------------------------------------------------------------
function tests.runAll()
	testSerialization()
	testBullets()
end

-------------------------------------------------------------------------------
return tests