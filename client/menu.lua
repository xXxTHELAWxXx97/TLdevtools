---@diagnostic disable: missing-parameter
local pool = MenuPool.New()
local isallowed = false
local debugvalue = 0
lastlog = {}
local voffset = {}

hudelements = {
    timer = {enabled = false, title = 'Game Time', description = 'Show the game time in ms'},
    pos = {enabled = false, title = 'Player Position', description = 'Show the player position in Vector3'},
    serverid = {enabled = false, title = 'Server ID', description = 'Show the server ID of the player'},
    vehicleoffset = {enabled = false, title = 'Vehicle Offset', description = 'Show the offset of the player from the closest vehicle'},
    loginfo = {enabled = false, title = 'Log Info', description = 'Log all information (from selected hud options) in the console'},
}

vehinfo = {}

function CreateMenu()
    local mainMenu = UIMenu.New('TLdevtools', 'Main Menu', 5, 5)
    mainMenu:MaxItemsOnScreen(10)
    mainMenu:MouseControlsEnabled(false)
    pool:Add(mainMenu)

    -- GET DISTANCE MENU 
    local getdistance = UIMenu.New('Get Distance', 'Get distance between two points', 5, 5)
    mainMenu:AddSubMenu(getdistance, 'Get Distance', 'Get distance between two points', nil, true)
    local coord1 = UIMenuItem.New('Starting Coords', 'Starting Coords')
    local coord2 = UIMenuItem.New('Ending Coords', 'Ending Coords')
    local result = UIMenuItem.New('Result', 'Result')



    getdistance:AddItem(coord1)
    getdistance:AddItem(coord2)
    getdistance:AddItem(result)
    getdistance.OnItemSelect = function(sender, item, index)
        if item == coord1 then
            strcoords = GetEntityCoords(PlayerPedId())
            coord1:RightLabel(strcoords)
        elseif item == coord2 then
            endcoords = GetEntityCoords(PlayerPedId())
            coord2:RightLabel(endcoords)
        elseif item == result then
            local distance = GetDistanceBetweenCoords(strcoords, endcoords, true)
            result:RightLabel(distance)
        end
    end

    -- DEBUG STATS MENU
    local debugstats = UIMenu.New('Debug Stats', 'Show/Hide Hud Stats', 5, 5)
    mainMenu:AddSubMenu(debugstats, 'Debug Stats', 'Debug stats', nil, true)

    local debugtable = {}
    for i = 0, 10 do
        table.insert(debugtable, tostring(i * 100 .. 'ms'))
    end
    local debugtimer = UIMenuListItem.New('UpdateTimer', debugtable, 0, 'How Frequently will the stats update (Default is 0ms, each number will incriment by 100 ms)')
    debugstats:AddItem(debugtimer)
    debugtimer.OnListChanged = function(sender, item, index)
        debugvalue = index * 100
    end


    for _, element in pairs(hudelements) do
        local checkbox = UIMenuCheckboxItem.New(element.title, element.enabled, 1, element.description)
        debugstats:AddItem(checkbox)
        checkbox.OnCheckboxChanged = function(sender, item, checked)
            element.enabled = checked
        end
    end

    --VEHICLE STATS
    local vehicleinfo = UIMenu.New('Vehicle Info', 'Vehicle Info', 5, 5)
    mainMenu:AddSubMenu(vehicleinfo, 'Vehicle Details', 'Vehicle Details', nil, true)

    local refreshmenu = UIMenuItem.New('Refresh', 'Refresh the menu')
    vehicleinfo:AddItem(refreshmenu)


    local vname = UIMenuItem.New('Vehicle Name', 'Vehicle Name')
    local plate = UIMenuItem.New('Plate', 'Plate')
    local class = UIMenuItem.New('Class', 'Class')
    local health = UIMenuItem.New('Health', 'Health')
    local fuel = UIMenuItem.New('Fuel', 'Fuel')

    vehicleinfo:AddItem(vname)
    vehicleinfo:AddItem(plate)
    vehicleinfo:AddItem(class)
    vehicleinfo:AddItem(health)
    vehicleinfo:AddItem(fuel)

    vname:RightLabel('N/A')
    plate:RightLabel('N/A')
    class:RightLabel('N/A')
    health:RightLabel('N/A')
    fuel:RightLabel('N/A')

    vehicleinfo.OnItemSelect = function(menu, item, index)
        if item == refreshmenu then
            --print(vehinfo.vname.data)
            vname:RightLabel(vehinfo.vname.data)
            plate:RightLabel(vehinfo.plate.data)
            class:RightLabel(vehinfo.class.data)
            health:RightLabel(vehinfo.health.data)
            fuel:RightLabel(vehinfo.fuel.data)
            --vname:RightLabel('Changed')
        end
    end

    mainMenu:Visible(true)
end


--ACE PERMISSIONS
CreateThread(function()
    TriggerServerEvent('TLdevtools:acecheck', 'TLdevtools.menu')
end)

RegisterNetEvent('TLdevtools:acecheckreturn', function(allowed)
    NewLog('info', 'Menu Permissions: ' .. tostring(allowed))
    isallowed = allowed
end)

--MENU KEYBIND
CreateThread(function()
    while true do
        Wait(0)
        if config.menu.useaceperms then
            if isallowed then
                if IsControlJustPressed(0, config.keys[config.menu.keybind]) then
                    CreateMenu()
                end
            end
        else
            if IsControlJustPressed(0, config.keys[config.menu.keybind]) then
                CreateMenu()
            end
        end

        local vehicle = GetVehiclePedIsIn(PlayerPedId(), true)
        if vehicle == 0 then
            vehinfo = {
                vname = { title = 'Vehicle Name', data = 'N/A'} ,
                plate = { title = 'Plate', data = 'N/A'},
                class = { title = 'Class', data = 'N/A'},
                health = { title = 'Health', data = 'N/A'},
                fuel = { title = 'Fuel', data = 'N/A'},
            }
        else
            vehinfo = {
                vname = { title = 'Vehicle Name', data = GetLabelText(GetDisplayNameFromVehicleModel(GetEntityModel(vehicle)))} ,
                plate = { title = 'Plate', data = GetVehicleNumberPlateText(vehicle)},
                class = { title = 'Class', data = GetVehicleClass(vehicle)},
                health = { title = 'Health', data = Round(GetVehicleEngineHealth(vehicle))},
                fuel = { title = 'Fuel', data = Round(GetVehicleFuelLevel(vehicle))},
            }
            for _, info in pairs(vehinfo) do
                local data = {
                    title = info.title,
                    data = info.title .. ': ' .. info.data}
                DebugLog(data)
            end
        end

        local closestvehicle = GetClosestVehicle(GetEntityCoords(PlayerPedId()), 5.0, 0, 70)
        if closestvehicle == 0 then
            voffset = {
                x = 'N/A',
                y = 'N/A',
                z = 'N/A',
            }
        else
            local pos = GetEntityCoords(PlayerPedId())
            local vpos = GetEntityCoords(closestvehicle)
            voffset = {
                x = Round(pos.x - vpos.x),
                y = Round(pos.y - vpos.y),
                z = Round(pos.z - vpos.z),
            }
        end
    end
end)



--HUD UPDATES
local loginfo = false
CreateThread(function()
    while true do
        Wait(debugvalue)
        local pos = GetEntityCoords(PlayerPedId())
        hudelements.timer.element = 'Game Timer: ' .. GetGameTimer()
        hudelements.pos.element = 'X: ' .. Round(pos.x) .. ' Y: ' .. Round(pos.y) .. ' Z: ' .. Round(pos.z)
        hudelements.serverid.element = 'Server ID: ' .. GetPlayerServerId(PlayerId())
        hudelements.loginfo.element = 'Logging Active'
        hudelements.vehicleoffset.element = 'Vehicle Offset: X:' .. voffset.x .. ' Y:' .. voffset.y .. ' Z:' .. voffset.z
    end
end)


--SMART NOTIFICATION POSITIONING
CreateThread(function()
    while true do
        Wait(0)
        local activeelements = {}
        for _, element in pairs(hudelements) do
            if element.enabled then
                table.insert(activeelements, element)
                local data = {
                    title = element.title,
                    data = element.element}
                DebugLog(data)
            end
        end
        if activeelements[1] then
            ScaleformUI.Notifications:DrawText(0.3,0.9, activeelements[1].element)
        end
        if activeelements[2] then
            ScaleformUI.Notifications:DrawText(0.3,0.925, activeelements[2].element)
        end
        if activeelements[3] then
            ScaleformUI.Notifications:DrawText(0.3,0.95, activeelements[3].element)
        end
        if activeelements[4] then
            ScaleformUI.Notifications:DrawText(0.3,0.975, activeelements[4].element)
        end
    end
end)

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

function CompareStrings(str1, str2)
    if str1 == str2 then
        return true
    else
        return false
    end
end

function Round(num, numDecimalPlaces)
    if numDecimalPlaces == nil then
        numDecimalPlaces = 2
    end
    local mult = 10^(numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end