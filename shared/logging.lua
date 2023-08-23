

--- Logs Message to console and discord
---@alias msgtype
---|"'error'" # Logs message as error
---|"'warning'" # Logs message as warning
---|"'info'" # Logs message as info
---|"'success'" # Logs message as success
---|"'CUSTOM TYPE'" # Logs message as custom type (can be anything)
---@param type msgtype
---@param msg string

function NewLog(type, msg)
    local resource = GetInvokingResource()
    if resource == nil then
        resource = 'TLdevtools'
    end
    local logging = GetResourceKvpInt('TLdevtools_log_level')
    local messageType = ''
    local colorcode = GetColorCode(type)

    if type == 'error' and logging >= 1 then
        messageType = 'ERROR: '
    elseif type == 'warning' and logging >= 2 then
        messageType = 'WARNING: '
    elseif type == 'info' and logging >= 3 then
        messageType = 'INFO: '
    elseif type == 'success' and logging >= 4 then
        messageType = 'SUCCESS: '
    elseif logging == 5 then
        messageType = type .. ': '
    else
        return -- Skip printing the log message if the logging level doesn't match
    end

    local logMessage = '^1' .. TimeStampFilter() .. '[' .. resource .. '] ' .. colorcode .. messageType .. msg .. '^7'

    print(logMessage)
    TriggerEvent('TLdevtools:LogToDiscord', resource, 1, TimeStampFilter() .. messageType .. msg)
end

Citizen.CreateThread(function()
    for event, logtype in pairs(config.eventwatcher) do
        RegisterNetEvent(event, function(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10)
            local argtable = {arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10}
            PrintData(event, 'EVENT', logtype, argtable)
        end)
    end
end)

RegisterCommand('setexport', function(src, args, rawCommand)
    if IsAceAllowed(config.perms.admin) or IsAceAllowed(config.perms.functions) then
        local script = tostring(args[1])
        local export = tostring(args[2])
        local argstable = {args[3], args[4], args[5], args[6], args[7], args[8], args[9], args[10], args[11]}
        exports[script][export](src, table.unpack(argstable))
        NewLog('info', 'Set export ' .. export .. ' in script ' .. script .. ' with arguments ' .. table.concat(argstable, ', '))
        --PrintData(export, 'info', data)
    else
        NewLog('error', 'You do not have permission to use this command')
        local src = GetPlayerServerId(PlayerId())
        TriggerServerEvent('TLdevtools:ReportToServer', 'error', src, rawCommand)
    end
end, false)

RegisterCommand('getexport', function(src, args, rawCommand)
    if IsAceAllowed(config.perms.admin) or IsAceAllowed(config.perms.functions) then
        local script = tostring(args[1])
        local export = tostring(args[2])
        local argstable = {args[3], args[4], args[5], args[6], args[7], args[8], args[9], args[10], args[11]}
        local data = exports[script][export](src, table.unpack(argstable))
        PrintData(export, 'EXPORT', 'info', data)
    else
        NewLog('error', 'You do not have permission to use this command')
        local src = GetPlayerServerId(PlayerId())
        TriggerServerEvent('TLdevtools:ReportToServer', 'error', src, rawCommand)
    end
end, false)

function PrintData(event, trigger, logtype, data)
    local argtable = data
    local colorcode = GetColorCode(logtype)

    if type(argtable) == 'table' then
        for i, v in ipairs(argtable) do
            if type(v) == 'table' then
                argtable[i] = colorcode .. 'arg' .. (i - 1) .. ':\n' .. tableToString(v, 1, colorcode)
            else
                argtable[i] = colorcode .. 'arg' .. (i - 1) .. ': ' .. convertToString(v, 1, colorcode)
            end
        end
    else
        argtable = {colorcode .. 'arg0: ' .. convertToString(argtable, 1, colorcode)}
    end

    local argumentsString = table.concat(argtable, '\n')
    if #argumentsString > 0 then
        argumentsString = argumentsString .. '\n'
    end

    argumentsString = argumentsString .. colorcode .. 'END OF DATA FOR ' .. trigger .. ': ' .. event

    NewLog(logtype, trigger .. ': ' .. event .. ' ran with arguments:\n' .. argumentsString)
end
