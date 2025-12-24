Framework = {
    name = 'standalone',
    object = nil
}

local function Debug(msg)
    if Config.Debug then
        print(('^3[DEBUG]^7 %s'):format(msg))
    end
end

local function _T(key, ...)
    local lang = Config.Translations[Config.Locale]
        or Config.Translations['en']

    local value = lang[key] or key

    if select('#', ...) > 0 then
        return value:format(...)
    end

    return value
end

local function LoadFramework(name)
    if name == 'esx' and GetResourceState('es_extended') == 'started' then
        Framework.name = 'esx'
        Framework.object = exports.es_extended:getSharedObject()
        return true

    elseif name == 'qb' and GetResourceState('qb-core') == 'started' then
        Framework.name = 'qb'
        Framework.object = exports['qb-core']:GetCoreObject()
        return true

    elseif name == 'ox' and GetResourceState('ox_core') == 'started' then
        Framework.name = 'ox'
        Framework.object = exports.ox_core
        return true

    elseif name == 'nd' and GetResourceState('nd-core') == 'started' then
        Framework.name = 'nd'
        Framework.object = exports['nd-core']
        return true
    end

    return false
end

CreateThread(function()
    if Config.Framework == 'auto' then
        Debug('Framework mode: auto')

        if LoadFramework('esx')
        or LoadFramework('qb')
        or LoadFramework('ox')
        or LoadFramework('nd') then
            Debug('Framework detected: ' .. Framework.name)
        else
            Framework.name = 'standalone'
            Debug('No framework detected, using standalone')
        end

    elseif Config.Framework ~= 'standalone' then
        Debug('Framework: ' .. Config.Framework)

        if not LoadFramework(Config.Framework) then
            print(('^1[ERROR]^7 ' .. _T('error_framework_missing'))
                :format(Config.Framework))
            Framework.name = 'standalone'
        end
    else
        Debug('Framework set to standalone')
    end

    MySQL.query([[
        ALTER TABLE users
        ADD COLUMN IF NOT EXISTS ssn VARCHAR(32) UNIQUE
    ]])

    Debug('Using framework: ' .. Framework.name)
end)

local function DiscordLog(title, desc)
    if not Config.Discord.Enabled then return end

    PerformHttpRequest(Config.Discord.Webhook, function() end, 'POST',
        json.encode({
            username = Config.Discord.Username,
            avatar_url = Config.Discord.Avatar,
            embeds = {{
                title = title,
                description = desc,
                color = Config.Discord.Color,
                footer = { text = os.date('%d.%m.%Y %H:%M:%S') }
            }}
        }),
        { ['Content-Type'] = 'application/json' }
    )
end

local function Dob(src)
    if Framework.name == 'esx' then
        local xPlayer = Framework.object.GetPlayerFromId(src)
        local dob = xPlayer and xPlayer.get('dateofbirth')
        if dob then return tostring(dob):sub(1, 4) end

    elseif Framework.name == 'qb' then
        local Player = Framework.object.Functions.GetPlayer(src)
        local dob = Player
            and Player.PlayerData
            and Player.PlayerData.charinfo
            and Player.PlayerData.charinfo.birthdate
        if dob then return tostring(dob):sub(1, 4) end

    elseif Framework.name == 'ox' then
        local player = Framework.object:GetPlayer(src)
        local dob = player and (player.dateofbirth or player.dob)
        if dob then return tostring(dob):sub(1, 4) end

    elseif Framework.name == 'nd' then
        local player = Framework.object.GetPlayer(src)
        local dob = player and player.dob
        if dob then return tostring(dob):sub(1, 4) end
    end

    return os.date('%Y')
end

local function Pad(num)
    return string.format('%0' .. Config.IdLength .. 'd', num)
end

local function BuildSsn(id, src)
    local year = Dob(src)

    if Config.SsnFormat == 'numeric' then
        return tostring(id)

    elseif Config.SsnFormat == 'year_numeric' then
        return ('%s-%s'):format(year, Pad(id))

    else
        return Config.CustomFormat
            :gsub('{YEAR}', year)
            :gsub('{ID}', Pad(id))
    end
end

local function LastNum()
    local ssn = MySQL.scalar.await(
        'SELECT ssn FROM users WHERE ssn IS NOT NULL ORDER BY id DESC LIMIT 1'
    )
    local num = ssn and tonumber(ssn:match('(%d+)$')) or 0
    Debug('Last numeric SSN ID: ' .. num)
    return num
end

local function GetIdentifier(src)
    if Framework.name == 'esx' then
        return Framework.object.GetPlayerFromId(src)?.identifier

    elseif Framework.name == 'qb' then
        return Framework.object.Functions.GetPlayer(src)?.PlayerData.citizenid

    elseif Framework.name == 'ox' then
        return Framework.object:GetPlayer(src)?.charid

    elseif Framework.name == 'nd' then
        return Framework.object.GetPlayer(src)?.id

    else
        return GetPlayerIdentifier(src, 0)
    end
end

function GenerateSsn(identifier, src)
    Debug('GenerateSsn called for ' .. tostring(identifier))

    local existing = MySQL.scalar.await(
        'SELECT ssn FROM users WHERE identifier = ?',
        { identifier }
    )

    if existing then
        Debug('SSN already exists: ' .. existing)
        return existing
    end

    local id = LastNum() + 1
    local ssn = BuildSsn(id, src)

    MySQL.update.await(
        'UPDATE users SET ssn = ? WHERE identifier = ?',
        { ssn, identifier }
    )

    Debug('SSN generated: ' .. ssn)

    DiscordLog(
        _T('discord_generated_title'),
        _T('discord_generated_desc', identifier, ssn)
    )

    return ssn
end

exports('GenerateSsn', GenerateSsn)

exports('GetSsnFromIdentifier', function(identifier)
    return MySQL.scalar.await(
        'SELECT ssn FROM users WHERE identifier = ?',
        { identifier }
    )
end)

exports('GetSsnFromServerId', function(src)
    local id = GetIdentifier(src)
    return id and exports.r_ssn:GetSsnFromIdentifier(id)
end)

exports('GetIdFromSsn', function(ssn)
    return MySQL.scalar.await(
        'SELECT identifier FROM users WHERE ssn = ?',
        { ssn }
    )
end)

exports('GetServerIdFromSsn', function(ssn)
    local identifier = exports.r_ssn:GetIdFromSsn(ssn)
    if not identifier then return nil end

    for _, src in ipairs(GetPlayers()) do
        if GetIdentifier(tonumber(src)) == identifier then
            return tonumber(src)
        end
    end

    return nil
end)

AddEventHandler('esx:playerLoaded', function(_, xPlayer, isNew)
    if Framework.name == 'esx' and isNew then
        GenerateSsn(xPlayer.identifier, xPlayer.source)
    end
end)

RegisterNetEvent('QBCore:Server:PlayerLoaded', function(Player)
    if Framework.name == 'qb' and Player.PlayerData.metadata.isnew then
        GenerateSsn(Player.PlayerData.citizenid, source)
    end
end)

AddEventHandler('ox:playerLoaded', function(player)
    if Framework.name == 'ox' and player.isNew then
        GenerateSsn(player.charid, player.source)
    end
end)

AddEventHandler('ND:characterLoaded', function(player, isNew)
    if Framework.name == 'nd' and isNew then
        GenerateSsn(player.id, player.source)
    end
end)

lib.callback.register('r_ssn:getNearby', function(src, players)
    Debug('/ssn callback from ' .. src)

    local list = {}

    for _, id in ipairs(players or {}) do
        local ssn = exports.r_ssn:GetSsnFromServerId(id)
        if ssn then
            list[#list + 1] = {
                id = id,
                ssn = ssn
            }
        end
    end

    return exports.r_ssn:GetSsnFromServerId(src), list
end)
