exports('log', NewLog)

RegisterNetEvent('TLdevtools:saferestart', function(player, name, resource)
    TriggerEvent('chat:addMessage', { args = { '^1Safe restart for ^3' .. resource .. ' ^1requested by ^3' .. name .. ' ^1(' .. player .. '), moving players to a safe location. Resource will restart in ' .. config.saferestart.warningtime + config.saferestart.lagtime .. ' seconds.' } })
    local pools = {'CPed','CObject','CVehicle','CPickup'}
    Wait(config.saferestart.warningtime * 1000)
    for _, v in pairs(pools) do
        local pool = GetGamePool(v)
        for i = 1, #pool do
            local obj = pool[i]
            if DoesEntityExist(obj) then
                if GetEntityScript(obj) == resource then
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