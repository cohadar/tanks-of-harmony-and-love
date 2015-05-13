--- @module player
player = {}

-------------------------------------------------------------------------------
function player.new()
	self = {}
	self.kills = 0
	self.deaths = 0
	self.team = nil -- "red" or blue
	return self
end

-------------------------------------------------------------------------------
return player
