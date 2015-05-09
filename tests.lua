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
	local t = utils.unpack( package )
	bullets.importTable( t )
	package2 = utils.pack( bullets.exportTable() ) 
	assert( package == package2 ) 
end

-------------------------------------------------------------------------------
function tests.runAll()
	testSerialization()
	testBullets()
end

-------------------------------------------------------------------------------
return tests