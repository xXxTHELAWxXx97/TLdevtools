framework = nil
t = GetGameTimer()

Citizen.CreateThread(function()
    NewLog('info', 'Checking for framework')
    while (framework == nil) do
        if GetGameTimer() - t > 10000 then
            NewLog('info', 'Could not auto-detect framework')
            break
        end
        for k,v in pairs(config.frameworkchecker) do
            if (GetResourceState(v) == 'started') then
                NewLog('info', 'Found framework: ' .. k)
                framework = k
                break
            end
        end
        Citizen.Wait(5000)
    end
end)


exports('getFramework', function()
    return framework
end)

exports('isFramework', function(frameworkName)
    return framework == frameworkName
end)