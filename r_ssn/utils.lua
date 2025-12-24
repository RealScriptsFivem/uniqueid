function _T(key, ...)
    local lang = Config.Translations[Config.Locale]
        or Config.Translations['en']

    local value = lang[key] or key

    if select('#', ...) > 0 then
        return value:format(...)
    end

    return value
end
