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

RegisterNetEvent('TLdevtools:CheckPerms', function()
    local src = source
    local perms = {}
    for k, v in pairs(config.perms) do
        local permission = IsPlayerAceAllowed(src, v) or false
        table.insert(perms, {perm = k, allowed = permission})
    end
    TriggerClientEvent('TLdevtools:ReturnPerms', src, perms)
end)

RegisterCommand('saferestart', function(source, args, rawCommand)
    local player = source
    local resource = args[1]
    if player == 0 then
        SafeRestart(player, resource)
    else
        if IsPlayerAceAllowed(player, config.perms.admin) or IsPlayerAceAllowed(player, config.perms.functions) then
            TriggerEvent('TLdevtools:PrintToServer', 'info', 'Safe restart for ' .. resource .. ' requested by ' .. GetPlayerName(player) .. ' (' .. player .. '). Resource will restart in ' .. config.saferestart.warningtime + config.saferestart.lagtime .. ' seconds.')
            SafeRestart(player, resource)
        else
            NewLog('error', 'You do not have permission to use this command')
            TriggerEvent('TLdevtools:ReportToServer', 'error', player, rawCommand)
        end
    end
end, false)

function SafeRestart(player, resource)
    if player == 0 then
        name = 'Console'
    else
        name = GetPlayerName(player)
    end
    NewLog('info', 'Safe restart for ' .. resource .. ' requested by ' .. name .. ' (' .. player .. '). Resource will restart in ' .. config.saferestart.warningtime + config.saferestart.lagtime .. ' seconds.')
    TriggerClientEvent('TLdevtools:saferestart', -1, player, name, resource)
    Wait((config.saferestart.warningtime * 1000) + (config.saferestart.lagtime * 1000))
    ExecuteCommand('restart ' .. resource)
end

RegisterNetEvent('TLdevtools:PrintToServer', function(type, message)
    PrintToServer(type, message)
end)

RegisterNetEvent('TLdevtools:ReportToServer', function(type, src, command)
    ReportToServer(type, src, command)
end)

function PrintToServer(type, message)
    CreateThread(function()
        Wait(0)
        NewLog(type, message)
    end)
end
function ReportToServer(type, src, command)
    CreateThread(function()
        Wait(0)
        NewLog(type, 'Player ' .. GetPlayerName(src) .. ' (' .. src .. ') ran command ' .. command .. ' without permissions')
    end)
end