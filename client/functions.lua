exports('log', NewLog)

RegisterNetEvent('TLdevtools:saferestart', function(player, name, resource)
    TriggerEvent('chat:addMessage', { args = { '^1Safe restart for ^3' .. resource .. ' ^1requested by ^3' .. name .. ' ^1(' .. player .. '). Resource will restart in ' .. config.saferestart.warningtime + config.saferestart.lagtime .. ' seconds.' } })
    local pools = {'CPed','CObject','CVehicle','CPickup'}
    Wait(config.saferestart.warningtime * 1000)
    for _, v in pairs(pools) do
        local pool = GetGamePool(v)
        for i = 1, #pool do
            local obj = pool[i]
            if DoesEntityExist(obj) then
                if (GetEntityScript(obj) == resource) or (NetworkGetNetworkIdFromEntity(obj) == nil) then
                    DeleteEntity(obj)
                end
            end
        end
    end
end)

TriggerEvent('chat:addSuggestion', '/saferestart', 'Safely restart a resource, by removing all objects belonging to that resource.', {
    { name="resource", help="The resource to restart" }
})

TriggerEvent('chat:addSuggestion', '/triggerevent', 'Trigger any event', {
    { name="Direction", help="-1 (All Players), 0 (Server), or Player Server ID " },
    { name="Event Name", help="The event to trigger" },
    { name="args", help="The arguments to pass to the event (separated by spaces)" }
})

function DebugLog(info)
    if hudelements.loginfo.enabled == true then
        loginfo = true
    else
        loginfo = false
    end
    if loginfo == true then
        if lastlog[info.title] ~= nil and type(lastlog[info.title]) == 'table' then
            if CompareStrings(lastlog[info.title].data , info.data) then
                return
            else
                NewLog('info', info.data)
                lastlog[info.title] = info
            end
        else
            NewLog('info', info.data)
            lastlog[info.title] = info
        end
    end
end

function CopyToClipboard(dataType)
    local ped = PlayerPedId()
    if dataType == 'coords2' then
        local coords = GetEntityCoords(ped)
        local x = Round(coords.x)
        local y = Round(coords.y)
        SendNUIMessage({
            string = string.format('vector2(%s, %s)', x, y)
        })
        NewLog("success", 'Coords have been copied to your clipboard')
    elseif dataType == 'coords3' then
        local coords = GetEntityCoords(ped)
        local x = Round(coords.x)
        local y = Round(coords.y)
        local z = Round(coords.z)
        SendNUIMessage({
            string = string.format('vector3(%s, %s, %s)', x, y, z)
        })
        NewLog("success", 'Coords have been copied to your clipboard')
    elseif dataType == 'coords4' then
        local coords = GetEntityCoords(ped)
        local x = Round(coords.x)
        local y = Round(coords.y)
        local z = Round(coords.z)
        local heading = GetEntityHeading(ped)
        local h = Round(heading)
        SendNUIMessage({
            string = string.format('vector4(%s, %s, %s, %s)', x, y, z, h)
        })
        NewLog("success", 'Coords have been copied to your clipboard')
    elseif dataType == 'heading' then
        local heading = GetEntityHeading(ped)
        local h = Round(heading)
        SendNUIMessage({
            string = h
        })
        NewLog("success", 'Heading has been copied to your clipboard')
    elseif dataType == 'freeaimEntity' then
        local entity = GetFreeAimEntity()

        if entity then
            local entityHash = GetEntityModel(entity)
            local entityName = Entities[entityHash] or "Unknown"
            local entityCoords = GetEntityCoords(entity)
            local entityHeading = GetEntityHeading(entity)
            local entityRotation = GetEntityRotation(entity)
            local x = Round(entityCoords.x)
            local y = Round(entityCoords.y)
            local z = Round(entityCoords.z)
            local rotX = Round(entityRotation.x)
            local rotY = Round(entityRotation.y)
            local rotZ = Round(entityRotation.z)
            local h = Round(entityHeading)
            SendNUIMessage({
                string = string.format('Model Name:\t%s\nModel Hash:\t%s\n\nHeading:\t%s\nCoords:\t\tvector3(%s, %s, %s)\nRotation:\tvector3(%s, %s, %s)', entityName, entityHash, h, x, y, z, rotX, rotY, rotZ)
            })
            NewLog("success", 'Successfully copied entity data to clipboard')
        else
            NewLog("error", 'Entity copy failed')
        end
    end
end

RegisterNetEvent('TLdevtools:client:copyToClipboard', function(dataType)
    CopyToClipboard(dataType)
end)