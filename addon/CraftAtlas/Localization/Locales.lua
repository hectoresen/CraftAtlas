local _, ns = ...
ns.translations = {
    enUS = {
        TITLE = "CraftAtlas",
        GENERAL = "General",
        LANGUAGE = "Language",
        LANGUAGE_HELP = "Automatic follows your game language. Changes save immediately.",
        AUTO = "Automatic",
        ENGLISH = "English",
        SPANISH = "Español",
        USED_BY = "Used by professions:",
        ALCHEMY = "Alchemy",
        BLACKSMITHING = "Blacksmithing",
        COOKING = "Cooking",
        ENCHANTING = "Enchanting",
        ENGINEERING = "Engineering",
        FIRST_AID = "First Aid",
        LEATHERWORKING = "Leatherworking",
        TAILORING = "Tailoring",
    },
    esES = {
        TITLE = "CraftAtlas",
        GENERAL = "General",
        LANGUAGE = "Idioma",
        LANGUAGE_HELP = "Automático utiliza el idioma del juego. Los cambios se guardan al instante.",
        AUTO = "Automático",
        ENGLISH = "Inglés",
        SPANISH = "Español",
        USED_BY = "Utilizado por profesiones:",
        ALCHEMY = "Alquimia",
        BLACKSMITHING = "Herrería",
        COOKING = "Cocina",
        ENCHANTING = "Encantamiento",
        ENGINEERING = "Ingeniería",
        FIRST_AID = "Primeros auxilios",
        LEATHERWORKING = "Peletería",
        TAILORING = "Sastrería",
    },
}

function ns.ResolveLocale(preference, clientLocale)
    if preference == "enUS" or preference == "esES" then
        return preference
    end
    return clientLocale == "esES" and "esES" or "enUS"
end

function ns.Text(key, preference, clientLocale)
    local locale = ns.ResolveLocale(preference, clientLocale)
    return (ns.translations[locale] and ns.translations[locale][key])
        or ns.translations.enUS[key]
        or key
end
