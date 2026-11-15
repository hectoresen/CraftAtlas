local _, ns = ...
ns.translations = {
    enUS = {
        TITLE = "CraftAtlas",
        GENERAL = "General",
        LANGUAGE = "Language",
        LANGUAGE_HELP = "Automatic follows your game language. Changes save immediately.",
        SEARCH_PLACEHOLDER = "Search items or professions...",
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
        NAME_RESULTS_INCOMPLETE = "Some item names are unavailable.",
        LOADING_ITEM_NAMES = "Loading item names from World of Warcraft...",
        LOADING_ITEMS = "Loading items... %d names available",
        RECIPES_HEADING = "Recipes",
        RECIPES_UNAVAILABLE = "Recipe information is not available yet.",
        RECIPE_USE_COUNT = "%d known recipes",
        RECIPE_QUANTITY = "x%d",
        RECIPE_ID = "Recipe",
        RECIPE_OUTPUT_UNKNOWN = "Output not identified",
        RECIPE_ENCHANT_ACTION = "Enchanting / non-item action",
        NO_VERIFIED_RECIPES = "No verified recipe uses in this catalog.",
        RECIPE_TOOLTIP_LIMITED = "Additional recipe details unavailable in this client.",
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
        SEARCH_PLACEHOLDER = "Buscar objetos o profesiones...",
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
        NAME_RESULTS_INCOMPLETE = "Algunos nombres de objetos no están disponibles.",
        LOADING_ITEM_NAMES = "Cargando nombres de objetos de World of Warcraft...",
        LOADING_ITEMS = "Cargando objetos... %d nombres disponibles",
        RECIPES_HEADING = "Recetas",
        RECIPES_UNAVAILABLE = "La información de recetas aún no está disponible.",
        RECIPE_USE_COUNT = "%d recetas conocidas",
        RECIPE_QUANTITY = "x%d",
        RECIPE_ID = "Receta",
        RECIPE_OUTPUT_UNKNOWN = "Resultado no identificado",
        RECIPE_ENCHANT_ACTION = "Encantamiento / acción sin objeto",
        NO_VERIFIED_RECIPES = "No hay usos de receta verificados en este catálogo.",
        RECIPE_TOOLTIP_LIMITED = "Información adicional de la receta no disponible en este cliente.",
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
