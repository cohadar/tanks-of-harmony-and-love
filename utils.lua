--- @module utils
local m_utils = {}

-------------------------------------------------------------------------------
function m_utils.deepcopy( orig )
    local copy = orig
    if type(orig) == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[ m_utils.deepcopy(orig_key) ] = m_utils.deepcopy( orig_value )
        end
        --setmetatable(copy, m_utils.deepcopy(getmetatable(orig)))
    end
    return copy
end

-------------------------------------------------------------------------------
function m_utils.round( num, idp )
  local mult = 10 ^ ( idp or 0 )
  return math.floor( num * mult + 0.5 ) / mult
end

-------------------------------------------------------------------------------
function m_utils.round_angle( num )
  return math.floor( num * 1000000 + 0.5 ) / 1000000
end

-------------------------------------------------------------------------------
return m_utils