TriggerServerEvent('TLdevtools:playerJoining')

RegisterNetEvent('TLdevtools:initialize', function(data)
    SetResourceKvpInt('TLdevtools_log_level', data.log_level)
end)

RegisterNetEvent('TLdevtools:updateclientKVP', function(key, value)
    SetResourceKvpInt(key, value)
end)