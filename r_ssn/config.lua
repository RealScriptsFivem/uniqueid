Config = {}

Config.Debug = true

-- =========================
-- FRAMEWORK
-- =========================
-- 'esx' 'ox,' 'qb', 'nd', 'standalone', 'auto'
Config.Framework = 'auto' 
-- =========================
-- FORMAT SSN
-- =========================
-- numeric | year_numeric | custom
-- numeric: 1, 2, 3, 4, 5 etc.
-- year_numeric: 1989-000001, 1999-000014 etc.
Config.SsnFormat = 'numeric'
Config.IdLength = 6 -- for year_numeric and customformat
-- example: Config.CustomFormat = 'SSN/{YEAR}/{ID}' --> SSN/2025/000123
-- variables: {YEAR} ; {ID}
Config.CustomFormat = '{YEAR}-{ID}'

Config.Discord = {
    Enabled = true,
    Webhook = '',
    Username = 'Real Scripts SSN System',
    Avatar = '',
    Color = 3447003
}

Config.Notify = function(msg, type)
    lib.notify({
        description = msg,
        type = type or 'info'
    })
end

Config.NearbyDistance = 5.0 -- to check when using /ssn command

Config.Locale = 'en' -- 'en', 'pl'

Config.Translations = {
    ['en'] = {
        ssn_title = 'Your SSN',
        ssn_none = 'NONE',
        ssn_nearby_title = 'Nearby players:',
        ssn_entry = 'ID %s → %s',

        notify_info = 'info',

        -- debug
        console_generate_start = 'Console SSN generation started',
        console_generate_done = 'SSN generation finished',

        error_framework_missing = 'Framework "%s" selected but not running!',

        discord_generated_title = 'SSN Generated',
        discord_generated_desc = 'Identifier: `%s`\nSSN: **%s**'
    },

    ['pl'] = {
        ssn_title = 'Twój SSN',
        ssn_none = 'BRAK',
        ssn_nearby_title = 'Pobliskie osoby:',
        ssn_entry = 'ID %s → %s',

        notify_info = 'info',

        console_generate_start = 'Rozpoczęto generowanie SSN',
        console_generate_done = 'Generowanie SSN zakończone',

        error_framework_missing = 'Framework "%s" jest wybrany, ale nie jest uruchomiony!',

        discord_generated_title = 'Wygenerowano SSN',
        discord_generated_desc = 'Identifier: `%s`\nSSN: **%s**'
    }
}
