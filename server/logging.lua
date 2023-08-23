RegisterCommand('changeloglevel', function(_,args,_)
    local logging = args[1]
    if logging == '0' or logging == 'disable' then
        SetResourceKvpInt('TLdevtools_log_level', 0)
        TriggerClientEvent('TLdevtools:updateclientKVP', -1, 'TLdevtools_log_level', 0)
        print('^5 INFO: Disabled logging^7')
    elseif logging == '1' or logging == 'error' then
        SetResourceKvpInt('TLdevtools_log_level', 1)
        TriggerClientEvent('TLdevtools:updateclientKVP', -1, 'TLdevtools_log_level', 1)
        print('^5 INFO: Changed log level to ' .. logging .. '^7')
    elseif logging == '2' or logging == 'warning' then
        SetResourceKvpInt('TLdevtools_log_level', 2)
        TriggerClientEvent('TLdevtools:updateclientKVP', -1, 'TLdevtools_log_level', 2)
        print('^5 INFO: Changed log level to ' .. logging .. '^7')
    elseif logging == '3' or logging == 'info' then
        SetResourceKvpInt('TLdevtools_log_level', 3)
        TriggerClientEvent('TLdevtools:updateclientKVP', -1, 'TLdevtools_log_level', 3)
        print('^5 INFO: Changed log level to ' .. logging .. '^7')
    elseif logging == '4' or logging == 'success' then
        SetResourceKvpInt('TLdevtools_log_level', 4)
        TriggerClientEvent('TLdevtools:updateclientKVP', -1, 'TLdevtools_log_level', 4)
        print('^5 INFO: Changed log level to ' .. logging .. '^7')
    elseif logging == '5' or logging == 'custom' then
        SetResourceKvpInt('TLdevtools_log_level', 5)
        TriggerClientEvent('TLdevtools:updateclientKVP', -1, 'TLdevtools_log_level', 5)
        print('^5 INFO: Changed log level to ' .. logging .. '^7')
    else
        print('^1 ERROR: Invalid log level^7')
    end
end, true)


RegisterCommand('triggerevent', function(src,args,rawCommand)
    print('command run')
    local direction = tonumber(args[1])
    local eventname = args[2]
    local arguments = {}
    local player = src
    for i=3, #args do
        table.insert(arguments, args[i])
    end
    if player == 0 then
        Trigger(player, direction, eventname, arguments)
    else
        if IsPlayerAceAllowed(player, config.perms.admin) or IsPlayerAceAllowed(player, config.perms.functions) then
            Trigger(player, direction, eventname, arguments)
        else
            NewLog('error', 'You do not have permission to use this command')
            TriggerEvent('TLdevtools:ReportToServer', 'error', player, rawCommand)
        end
    end
end, false)


function Trigger(player, direction, eventname, arguments)
    if player == 0 then
        player = 'Console'
    else
        player = GetPlayerName(player)
        print('isplayer')
    end
    if type(direction) ~= 'number' then
        NewLog('error', 'Direction argument must be a number')
        return
    end
    if eventname == nil then
        NewLog('error', 'No event name given')
    else
        if direction == nil then
            NewLog('error', 'No direction given')
        else
            if direction == 0 then
                TriggerEvent(eventname, table.unpack(arguments))
                NewLog('success', 'Triggered server event ' .. eventname .. ' with arguments ' .. table.concat(arguments, ', '))
                TriggerEvent('TLdevtools:PrintToServer', 'info', player .. ' triggered server event ' .. eventname .. ' with arguments ' .. table.concat(arguments, ', '))
            elseif direction >= 1 then
                TriggerClientEvent(eventname, direction, table.unpack(arguments))
                NewLog('success', player .. ' triggered client event ' .. eventname .. ' to ' .. direction .. ' with arguments ' .. table.concat(arguments, ', '))
                TriggerEvent('TLdevtools:PrintToServer', 'info', player .. ' triggered client event ' .. eventname .. ' to ' .. direction .. ' with arguments ' .. table.concat(arguments, ', '))
            elseif direction == -1 then
                TriggerClientEvent(eventname, -1, table.unpack(arguments))
                NewLog('success', player .. ' triggered client event ' .. eventname .. ' to all with arguments ' .. table.concat(arguments, ', '))
                TriggerEvent('TLdevtools:PrintToServer', 'info', player .. ' triggered client event ' .. eventname .. ' to all with arguments ' .. table.concat(arguments, ', '))
            end
        end
    end
end

RegisterNetEvent('TLdevtools:playerJoining', function()
    local data = {
        log_level = GetResourceKvpInt('TLdevtools_log_level')
    }
    TriggerClientEvent('TLdevtools:initialize', source, data)
end)


RegisterNetEvent('TLdevtools:LogToDiscord', LogToDiscord)

function LogToDiscord(resource, type, message)
    local conf = sconfig.discord
    if type <= conf.loglevel then
        local embed = {
            {
                ['color'] = conf.webhookcolor,
                ['title'] = resource,
                ['description'] = message,
                ['footer'] = {
                    ['text'] = 'TL Devtools',
                },
            }
        }
        PerformHttpRequest(conf.webhookurl, function(err, text, headers) end, 'POST', json.encode({username = conf.webhookname, embeds = embed, avatar_url = conf.webhookavatar}), { ['Content-Type'] = 'application/json' })
    end
end