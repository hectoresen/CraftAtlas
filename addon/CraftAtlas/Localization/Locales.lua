local _, ns = ...
ns.translations = {
    enUS = {
        TITLE = "CraftAtlas",
        GENERAL = "General",
        LANGUAGE = "Language",
        LANGUAGE_HELP = "Automatic follows your game language. Changes save immediately.",
        SEARCH_PLACEHOLDER = "Search materials or item IDs...",
        COMING_SOON = "Coming soon",
        MINIMAP_TOOLTIP = "Open CraftAtlas",
        AUTO = "Automatic",
        ENGLISH = "English",
        SPANISH = "Español",
        USED_BY = "Used by professions:",
        MATERIALS_HEADING = "Materials",
        ALL_PROFESSIONS = "All professions",
        RESULT_COUNT = "%d results",
        NO_RESULTS = "No matching materials",
        SELECT_MATERIAL = "Select a material",
        ITEM_ID = "Item ID",
        NAME_RESULTS_INCOMPLETE = "Some item names are not loaded; try an item ID.",
        RECIPES_HEADING = "Recipes",
        RECIPES_UNAVAILABLE = "Recipe information is not available yet.",
        ALCHEMY = "Alchemy",
        BLACKSMITHING = "Blacksmithing",
        COOKING = "Cooking",
        ENCHANTING = "Enchanting",
        ENGINEERING = "Engineering",
        FIRST_AID = "First Aid",
        FISHING = "Fishing",
        LEATHERWORKING = "Leatherworking",
        MINING = "Mining",
        TAILORING = "Tailoring",
    },
    esES = {
        TITLE = "CraftAtlas",
        GENERAL = "General",
        LANGUAGE = "Idioma",
        LANGUAGE_HELP = "Automático utiliza el idioma del juego. Los cambios se guardan al instante.",
        SEARCH_PLACEHOLDER = "Buscar materiales o ID...",
        COMING_SOON = "Próximamente",
        MINIMAP_TOOLTIP = "Abrir CraftAtlas",
        AUTO = "Automático",
        ENGLISH = "Inglés",
        SPANISH = "Español",
        USED_BY = "Utilizado por profesiones:",
        MATERIALS_HEADING = "Materiales",
        ALL_PROFESSIONS = "Todas las profesiones",
        RESULT_COUNT = "%d resultados",
        NO_RESULTS = "No hay materiales que coincidan",
        SELECT_MATERIAL = "Selecciona un material",
        ITEM_ID = "ID de objeto",
        NAME_RESULTS_INCOMPLETE = "Algunos nombres aún no se han cargado; prueba con el ID.",
        RECIPES_HEADING = "Recetas",
        RECIPES_UNAVAILABLE = "La información de recetas aún no está disponible.",
        ALCHEMY = "Alquimia",
        BLACKSMITHING = "Herrería",
        COOKING = "Cocina",
        ENCHANTING = "Encantamiento",
        ENGINEERING = "Ingeniería",
        FIRST_AID = "Primeros auxilios",
        FISHING = "Pesca",
        LEATHERWORKING = "Peletería",
        MINING = "Minería",
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
