isServer = IsDuplicityVersion()

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

function convertToString(value, indent, colorCode)
    if type(value) == 'table' then
        return tableToString(value, indent, colorCode)
    elseif type(value) == 'number' or type(value) == 'boolean' then
        return tostring(value)
    else
        return value
    end
end

function tableToString(t, indent, colorCode)
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

function Round(num, numDecimalPlaces)
    if numDecimalPlaces == nil then
        numDecimalPlaces = 2
    end
    local mult = 10^(numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

function CompareStrings(str1, str2)
    if str1 == str2 then
        return true
    else
        return false
    end
end