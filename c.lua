RegisterCommand('ssn', function()
    local myServerId = GetPlayerServerId(PlayerId())
    ESX.TriggerServerCallback('plrSSN', function(data)
        if data then
            ESX.ShowNotification(("Your SSN: %s"):format(data.ssn))

        else
            ESX.ShowNotification(`Your SSN couldn\'t be loaded`)
        end
    end, myServerId)
end, false)

RegisterCommand('gssn', function() -- TODO: fix opti
    local localPed = PlayerPedId()
    local localCoords = GetEntityCoords(localPed)
    local nearbyServerIds = {}

    for _, playerId in ipairs(GetActivePlayers()) do -- this is very poor optimization for bigger servers, I will rewrite it soon
        if playerId ~= PlayerId() then
            local ped = GetPlayerPed(playerId)
            if DoesEntityExist(ped) then
                local pedCoords = GetEntityCoords(ped)
                local distance = #(localCoords - pedCoords)
                if distance <= 10.0 then 
                    local serverId = GetPlayerServerId(playerId)
                    table.insert(nearbyServerIds, serverId)
                end
            end
        end
    end

    for _, serverId in ipairs(nearbyServerIds) do
        ESX.TriggerServerCallback('plrSSN', function(data)
            if data then
                ESX.ShowNotification(("[%s] %s - %s"):format(data.serverId, data.name, data.ssn))
            end
        end, serverId)
    end
end, false)
