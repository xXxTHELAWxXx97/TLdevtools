---@diagnostic disable: missing-parameter
local pool = MenuPool.New()
local perms = {}
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
    local eid = UIMenuItem.New('Entity ID', 'Entity ID')

    vehicleinfo:AddItem(vname)
    vehicleinfo:AddItem(plate)
    vehicleinfo:AddItem(class)
    vehicleinfo:AddItem(health)
    vehicleinfo:AddItem(fuel)
    vehicleinfo:AddItem(eid)

    vname:RightLabel('N/A')
    plate:RightLabel('N/A')
    class:RightLabel('N/A')
    health:RightLabel('N/A')
    fuel:RightLabel('N/A')
    eid:RightLabel('N/A')

    vehicleinfo.OnItemSelect = function(menu, item, index)
        if item == refreshmenu then
            --print(vehinfo.vname.data)
            vname:RightLabel(vehinfo.vname.data)
            plate:RightLabel(vehinfo.plate.data)
            class:RightLabel(vehinfo.class.data)
            health:RightLabel(vehinfo.health.data)
            fuel:RightLabel(vehinfo.fuel.data)
            eid:RightLabel(GetVehiclePedIsIn(PlayerPedId(), false))
            --vname:RightLabel('Changed')
        end
    end


    -- ENTITY VIEWER
    local eviewer = UIMenu.New('Entity Viewer', 'Entity Viewer', 5, 5)
    mainMenu:AddSubMenu(eviewer, 'Entity Viewer', 'Entity Viewer', nil, true)
    local eviewerdistance = UIMenuListItem.New('Set View Distance', 
    {'5', '10', '15', '20', '25', '30', '35', '40', '45', '50'}, 
    1, 
    'Set the distance to view entities')
    eviewer:AddItem(eviewerdistance)

    eviewerdistance.OnListChanged = function(sender, item, index)
        NewLog('info', 'Entity Viewer Distance Changed to ' .. tostring(index * 5))
        SetEntityViewDistance(tostring(index * 5))
    end

    local copyall = UIMenuItem.New('Copy All', 'Copy all entities to clipboard')
    local freeaim = UIMenuItem.New('Free Aim', 'Toggle Free Aim')
    local vehview = UIMenuItem.New('Vehicle View','Toggle Vehicle View')
    local pedview = UIMenuItem.New('Ped View', 'Toggle Ped View')
    local objectview = UIMenuItem.New('Object View', 'Toggle Object View')

    eviewer:AddItem(copyall)
    eviewer:AddItem(freeaim)
    eviewer:AddItem(vehview)
    eviewer:AddItem(pedview)
    eviewer:AddItem(objectview)

    eviewer.OnItemSelect = function(menu, item, index)
        if (item == freeaim) then
            ToggleEntityFreeView()
            NewLog('success', 'Free Aim Toggled')
        elseif (item == copyall) then
            CopyToClipboard('freeaimEntity')
            NewLog('success', 'Copied All Entity data to Clipboard')
        elseif (item == vehview) then
            ToggleEntityVehicleView()
            NewLog('success', 'Vehicle View Toggled')
        elseif (item == pedview) then
            ToggleEntityPedView()
            NewLog('success', 'Ped View Toggled')
        elseif (item == objectview) then
            ToggleEntityObjectView()
            NewLog('success', 'Object View Toggled')
        end
    end

    -- COPY COORDS
    local copycoords = UIMenu.New('Copy Coords', 'Copy Coordinates to Clipboard', 5, 5)
    mainMenu:AddSubMenu(copycoords, 'Copy Coords', 'Copy Coordinates to Clipboard', nil, true)
    local copyvec3 = UIMenuItem.New('Copy Vector3', 'Copy Vector3 to Clipboard')
    local copyvec4 = UIMenuItem.New('Copy Vector4', 'Copy Vector4 to Clipboard')
    local copyheading = UIMenuItem.New('Copy Heading', 'Copy Heading to Clipboard')

    copycoords:AddItem(copyvec3)
    copycoords:AddItem(copyvec4)
    copycoords:AddItem(copyheading)

    copycoords.OnItemSelect(function(menu, item, index)
        if (item == copyvec3) then
            CopyToClipboard('vector3')
            NewLog('success', 'Copied Vector3 to Clipboard')
        elseif (item == copyvec4) then
            CopyToClipboard('vector4')
            NewLog('success', 'Copied Vector4 to Clipboard')
        elseif (item == copyheading) then
            CopyToClipboard('heading')
            NewLog('success', 'Copied Heading to Clipboard')
        end
    end)

    mainMenu:Visible(true)
end


--ACE PERMISSIONS
CreateThread(function()
    NewLog('info', 'Checking ACE Permissions')
    TriggerServerEvent('TLdevtools:CheckPerms')
    --isallowed = IsAceAllowed('TLdevtools.menu')
    --NewLog('info', 'Menu Permissions: ' .. tostring(isallowed))
end)

--local permissions = {}
RegisterNetEvent('TLdevtools:ReturnPerms', function(permstable)
    for k, v in pairs(permstable) do
        perms[v.perm] = v.allowed
        NewLog('info', 'Permission ' .. v.perm .. ' is ' .. tostring(v.allowed))
    end
end)

--MENU KEYBIND
CreateThread(function()
    while true do
        local isallowed = perms.admin or perms.menu or false
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
        local heading = GetEntityHeading(PlayerPedId())
        hudelements.timer.element = 'Game Timer: ' .. GetGameTimer()
        hudelements.pos.element = 'X: ' .. Round(pos.x) .. ' Y: ' .. Round(pos.y) .. ' Z: ' .. Round(pos.z) .. ' H: ' .. Round(heading)
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





