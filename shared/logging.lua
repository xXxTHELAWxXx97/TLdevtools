isServer = IsDuplicityVersion()

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

function TimeStampFilter()
    if config.logging.showtimestamp == true then
        return '[' .. GetTimeStamp() .. '] '
    else
        return ''
    end
end

function GetTimeStamp()
    if isServer then
        local time = os.date('*t')
        local timestamp = time.year .. '-' .. time.month .. '-' .. time.day .. ' ' .. time.hour .. ':' .. time.min .. ':' .. time.sec
        return timestamp
    else
        local years, months, days, hours, minutes, seconds = Citizen.InvokeNative(0x50C7A99057A69748, Citizen.PointerValueInt(), Citizen.PointerValueInt(), Citizen.PointerValueInt(), Citizen.PointerValueInt(), Citizen.PointerValueInt(), Citizen.PointerValueInt())
        local timestamp = years .. '-' .. months .. '-' .. days .. ' ' .. hours .. ':' .. minutes .. ':' .. seconds
        return timestamp
    end
end

function GetColorCode(type)
    local colorCode = ''

    if type == 'error' then
        colorCode = '^1'
    elseif type == 'warning' then
        colorCode = '^3'
    elseif type == 'info' then
        colorCode = '^5'
    elseif type == 'success' then
        colorCode = '^2'
    else
        colorCode = '^7'
    end

    return colorCode
end

local function convertToString(value, indent, colorCode)
    if type(value) == 'table' then
        return tableToString(value, indent, colorCode)
    elseif type(value) == 'number' then
        return tostring(value)
    else
        return value
    end
end

local function tableToString(t, indent, colorCode)
    local result = {}

    for k, v in pairs(t) do
        local prefix = string.rep('  ', indent) .. colorCode .. k .. ': '
        if type(v) == 'table' then
            table.insert(result, prefix .. tableToString(v, indent + 1, colorCode))
        else
            table.insert(result, prefix .. convertToString(v, indent + 1, colorCode))
        end
    end

    return table.concat(result, '\n')
end

Citizen.CreateThread(function()
    for event, logtype in pairs(config.eventwatcher) do
        RegisterNetEvent(event, function(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10)
            local argtable = {arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10}
            local colorcode = GetColorCode(logtype)

            for i, v in ipairs(argtable) do
                if type(v) == 'table' then
                    argtable[i] = colorcode .. 'arg' .. (i - 1) .. ':\n' .. tableToString(v, 1, colorcode)
                else
                    argtable[i] = colorcode .. 'arg' .. (i - 1) .. ': ' .. convertToString(v, 1, colorcode)
                end
            end

            local argumentsString = table.concat(argtable, '\n')
            if #argumentsString > 0 then
                argumentsString = argumentsString .. '\n'
            end

            argumentsString = argumentsString .. colorcode .. 'END OF DATA FOR EVENT: ' .. event

            NewLog(logtype, 'EVENT: ' .. event .. ' ran with arguments:\n' .. argumentsString)
        end)
    end
end)
