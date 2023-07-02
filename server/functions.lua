-- ACE Perms Check

exports('AceCheck', AceCheck)

function AceCheck(acepermission)
    local requestedby = GetInvokingResource()
    local allowed = false
    if IsPlayerAceAllowed(source, acepermission) then
        allowed = true
    else
        allowed = false
    end
    if requestedby == nil then
        requestedby = 'Unknown Resource'
    end
    --TriggerEvent('TLdevtools:server:log', 'info', 'ACE Permission ' .. acepermission .. ', was requested by ' .. requestedby .. ', for ' .. GetPlayerName(source) .. ' - ' .. tostring(allowed))
    NewLog('info', 'ACE Permission ' .. acepermission .. ', was requested by ' .. requestedby .. ', for ' .. GetPlayerName(source) .. ' - ' .. tostring(allowed))
    return allowed
end

RegisterNetEvent('TLdevtools:acecheck', function(acepermission)
    local ace = AceCheck(acepermission)
    TriggerClientEvent('TLdevtools:acecheckreturn', source, ace)
end)

RegisterCommand('saferestart', function(source, args, rawCommand)
    local player = source
    local name = GetPlayerName(player)
    local resource = args[1]
    if source == 0 then
        player = 'Console'
    end
    NewLog('info', 'Safe restart for ' .. resource .. ' requested by ' .. name .. ' (' .. player .. '), moving players to a safe location. Resource will restart in ' .. config.saferestart.warningtime + config.saferestart.lagtime .. ' seconds.')
    TriggerClientEvent('TLdevtools:saferestart', -1, player, name, resource)
    Wait((config.saferestart.warningtime * 1000) + (config.saferestart.lagtime * 1000))
    ExecuteCommand('restart ' .. resource)
end, true)

RegisterCommand('tabletest', function(source, args, rawCommand)
    local testtable = {
        insidetable = 'insidetable',
        'roottable',
    }
    TriggerEvent('TLdevtools:tabletest', testtable)
end)