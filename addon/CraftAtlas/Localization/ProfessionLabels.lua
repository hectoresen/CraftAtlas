local _, ns = ...

function ns.ProfessionLabel(key)
    local entry = ns.professionNames and ns.professionNames[key]
    if not entry then return ns.L(key) end
    local locale = ns.ResolveLocale(ns.GetLanguage(), ns.GetClientLocale())
    return entry[locale] or entry.enUS or key
end
