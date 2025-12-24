RegisterCommand('ssn', function()
    local nearby = lib.getNearbyPlayers(
        GetEntityCoords(PlayerPedId()),
        Config.NearbyDistance,
        false
    )

    local ids = {}

    for _, player in ipairs(nearby) do
        ids[#ids + 1] = GetPlayerServerId(player.id)
    end

    local mySsn, list = lib.callback.await(
        'r_ssn:getNearby',
        false,
        ids
    )

    local msg = ('%s: %s\n\n%s\n'):format(
        _T('ssn_title'),
        mySsn or _T('ssn_none'),
        _T('ssn_nearby_title')
    )

    for _, v in ipairs(list) do
        msg = msg .. _T('ssn_entry', v.id, v.ssn) .. '\n'
    end

    Config.Notify(msg, _T('notify_info'))
end)
