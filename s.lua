function getNextSSN()
    local lastSSN = MySQL.prepare.await('SELECT MAX(ssn) FROM users', {}) or 0
    return tonumber(lastSSN) + 1
end

if Config.mode == 'autoesx' then
    RegisterNetEvent('esx:playerLoaded', function(player, xPlayer, isNew)
        if not isNew then return end

        local playerSSN = MySQL.prepare.await('SELECT ssn FROM users WHERE identifier = ?', { xPlayer.identifier })
        if not playerSSN or not playerSSN.ssn then
            local newSSN = getNextSSN()
            MySQL.update('UPDATE users SET ssn = ? WHERE identifier = ?', { newSSN, xPlayer.identifier }, function(affectedRows)
            end)
        end
    end)
end

--[[ 
    Export: getPlayerSSN
    Usage:
    local ssn = exports['r_uid']:getPlayerSSN(identifier)
    print(ssn)
]]

function getPlayerSSN(identifier)
    local result = MySQL.prepare.await('SELECT ssn FROM users WHERE identifier = ?', { identifier })
    return result and result.ssn or nil
end

--[[ 
    Export: changePlayerSSN
    Usage:
    exports['r_uid']:changePlayerSSN(identifier, 12345)
]]

function changePlayerSSN(identifier, newSSN)
    MySQL.update('UPDATE users SET ssn = ? WHERE identifier = ?', { newSSN, identifier }, function(affectedRows)
    end)
end

--[[ 
    Export: setPlayerSSN
    For manual mode – will assign a new SSN only if the player doesn’t already have one.
    Usage:
    exports['r_uid']:setPlayerSSN(identifier)
]]

function setPlayerSSN(identifier)
    local currentSSN = MySQL.prepare.await('SELECT ssn FROM users WHERE identifier = ?', { identifier })
    if not currentSSN or not currentSSN.ssn then
        local newSSN = getNextSSN()
        MySQL.update('UPDATE users SET ssn = ? WHERE identifier = ?', { newSSN, identifier }, function(affectedRows)
        end)
    end
end

ESX.RegisterServerCallback('plrSSN', function(source, cb, targetServerId)
    local xPlayer = ESX.GetPlayerFromId(targetServerId)
    if xPlayer then
        local ssn = MySQL.prepare.await('SELECT ssn FROM users WHERE identifier = ?', { xPlayer.identifier }) or 'N/A'
        cb({ name = xPlayer.getName(), ssn = ssn, serverId = targetServerId })
    else
        cb(nil)
    end
end)


exports('getPlayerSSN', getPlayerSSN)
exports('changePlayerSSN', changePlayerSSN)
exports('setPlayerSSN', setPlayerSSN)
