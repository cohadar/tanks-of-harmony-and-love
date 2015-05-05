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
return m_utils