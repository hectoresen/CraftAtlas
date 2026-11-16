local _, ns = ...

-- Pure grouping: the caller supplies already filtered, uniquely keyed material IDs.
function ns.BuildProfessionGroups(ids, materials, professionOrder)
    local allowed = {}
    for _, itemID in ipairs(ids or {}) do allowed[itemID] = true end
    local groups = {}
    for _, professionKey in ipairs(professionOrder or {}) do
        local members = {}
        for _, itemID in ipairs(ids or {}) do
            local professions = materials and materials[itemID]
            if allowed[itemID] and type(professions) == "table" then
                for _, key in ipairs(professions) do
                    if key == professionKey then
                        members[#members + 1] = itemID
                        break
                    end
                end
            end
        end
        if #members > 0 then
            groups[#groups + 1] = {key = professionKey, count = #members, items = members}
        end
    end
    return groups
end

function ns.NewProfessionTreeState()
    return {expanded = {}, searchOverrides = {}}
end

function ns.ToggleProfessionTreeGroup(state, professionKey, searching)
    local overrides = searching and state.searchOverrides or state.expanded
    local current = overrides[professionKey]
    if current == nil then current = true end
    overrides[professionKey] = not current
    return overrides[professionKey]
end

function ns.ClearProfessionTreeSearch(state)
    state.searchOverrides = {}
end

function ns.FlattenProfessionGroups(groups, state, searching)
    local entries = {}
    local overrides = searching and state.searchOverrides or state.expanded
    for _, group in ipairs(groups or {}) do
        entries[#entries + 1] = {group = group.key, count = group.count}
        if overrides[group.key] ~= false then
            for _, itemID in ipairs(group.items) do
                entries[#entries + 1] = {itemID = itemID, group = group.key}
            end
        end
    end
    return entries
end
