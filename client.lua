local QBCore = exports['qb-core']:GetCoreObject()

-- Local state
local Tracked = {}    -- plates -> { entity, blip }
local BlipsEnabled = true

local function createBlipForVehicle(entity, plate)
    if not BlipsEnabled then return end
    if not entity or not DoesEntityExist(entity) then return end

    local data = Tracked[plate]
    if data and data.blip and DoesBlipExist(data.blip) then return end

    local blip = AddBlipForEntity(entity)
    if not blip or not DoesBlipExist(blip) then return end

    SetBlipSprite(blip, Config.Blip.Sprite or 595)
    SetBlipColour(blip, Config.Blip.Colour or 2)
    SetBlipScale(blip, Config.Blip.Scale or 0.9)
    SetBlipFlashes(blip, true)

    if Config.Blip.ShowName then
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString((Config.Blip.NamePrefix or "GPS: ") .. plate)
        EndTextCommandSetBlipName(blip)
    end

    Tracked[plate] = { entity = entity, blip = blip }
end


--- Remove blip when needed
local function removeBlip(plate)
    local data = Tracked[plate]
    if data and data.blip then
        RemoveBlip(data.blip)
        data.blip = nil  -- clear blip reference only
    end
    -- DO NOT clear Tracked[plate]
end


CreateThread(function()
    local lastVeh = 0
    local ped = PlayerPedId()
    while true do
        ped = PlayerPedId()
        local veh = GetVehiclePedIsIn(ped, false)

        if veh ~= lastVeh then
            -- Player entered a new vehicle
            if veh ~= 0 and GetPedInVehicleSeat(veh, -1) == ped then
                local plate = QBCore.Functions.GetPlate(veh)
                if Tracked[plate] then
                    -- Remove blip when player is driving
                    removeBlip(plate)
                end
            end

            -- Player exited a vehicle
            if veh == 0 and lastVeh ~= 0 then
                local plate = QBCore.Functions.GetPlate(lastVeh)
                if Tracked[plate] then
                    -- Re-add blip when player leaves vehicle
                    createBlipForVehicle(lastVeh, plate)
                end
            end

            lastVeh = veh
        end

        Wait(1000)
    end
end)


--- Scan world vehicles to bind entities
local function scanVehicles()
    local all = GetGamePool('CVehicle')
    for plate,data in pairs(Tracked) do
        if not data.entity or not DoesEntityExist(data.entity) then
            for _,veh in ipairs(all) do
                if QBCore.Functions.GetPlate(veh) == plate then
                    createBlipForVehicle(veh, plate)
                    break
                end
            end
        end
    end
end

--- Periodic update
CreateThread(function()
    while true do
        if BlipsEnabled then
            scanVehicles()
            for plate,data in pairs(Tracked) do
                if data.entity and data.blip and DoesEntityExist(data.entity) then
                    local coords = GetEntityCoords(data.entity)
                    SetBlipCoords(data.blip, coords.x, coords.y, coords.z)
                end
            end
        end
        Wait(5000)
    end
end)

-- Install tracker
RegisterNetEvent('dt-gps:client:installTracker', function()
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)
    if veh == 0 then 
        TriggerEvent('okokNotify:Alert', "GPS", Config.Texts.NotInVehicle, 5000, 'error')
        return 
    end

    local plate = QBCore.Functions.GetPlate(veh)
    if Tracked[plate] then
        TriggerEvent('okokNotify:Alert', "GPS", string.format(Config.Texts.AlreadyInstalled, plate), 5000, 'error')
        return
    end

    -- Start disabling WASD
    local disableKeys = true
    CreateThread(function()
        while disableKeys do
            DisableControlAction(0, 32, true) -- W
            DisableControlAction(0, 33, true) -- S
            DisableControlAction(0, 34, true) -- A
            DisableControlAction(0, 35, true) -- D
            Wait(0)
        end
    end)

    QBCore.Functions.Progressbar('install_gps', Config.Texts.InstallStart, Config.InstallDuration, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = true,
        disableCombat = true,
    }, {}, {}, {}, function()
        disableKeys = false
        QBCore.Functions.TriggerCallback('dt-gps:server:saveTracker', function(success)
            if success then
                TriggerServerEvent('dt-gps:server:removeTrackerItem') -- Remove tracker item from player
                createBlipForVehicle(veh, plate)
                TriggerEvent('okokNotify:Alert', "GPS", string.format(Config.Texts.InstallSuccess, plate), 10000, 'success')
            else
                TriggerEvent('okokNotify:Alert', "GPS", Config.Texts.InstallFail, 5000, 'error')
            end
        end, plate)
    end, function()
        disableKeys = false
        TriggerEvent('okokNotify:Alert', "GPS", Config.Texts.InstallCancel, 5000, 'error')
    end)
end)


RegisterNetEvent('dt-gps:client:removeTracker', function()
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)
    if veh == 0 then 
        return exports['okokNotify']:Alert("GPS Tracker", Config.Texts.NotInVehicle, 5000, 'error')
    end

    local plate = QBCore.Functions.GetPlate(veh)
    if not Tracked[plate] then 
        return exports['okokNotify']:Alert("GPS Tracker", Config.Texts.NotInstalled, 5000, 'error')
    end

    QBCore.Functions.Progressbar('remove_gps', Config.Texts.RemoveStart, Config.RemoveDuration, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = true,
        disableCombat = true,
    }, {}, {}, {}, function()
        QBCore.Functions.TriggerCallback('dt-gps:server:deleteTracker', function(success)
            if success then
                removeBlip(plate)
                exports['okokNotify']:Alert("GPS Tracker", string.format(Config.Texts.RemoveSuccess, plate), 10000, 'success')
            else
                exports['okokNotify']:Alert("GPS Tracker", Config.Texts.RemoveFail, 5000, 'error')
            end
        end, plate)
    end, function()
        exports['okokNotify']:Alert("GPS Tracker", Config.Texts.RemoveCancel, 5000, 'error')
    end)
end)

-- Initialize on resource start (or on player relog)
local function LoadTrackedPlates()
    QBCore.Functions.TriggerCallback('dt-gps:server:getTrackedPlates', function(plates)
        if not plates or next(plates) == nil then
            return
        end

        for plate, _ in pairs(plates) do
            Tracked[plate] = { entity = nil, blip = nil }
        end

        Wait(3000)

        local allVehs = GetGamePool('CVehicle')

        for plate, _ in pairs(Tracked) do
            for _, veh in ipairs(allVehs) do
                local vplate = QBCore.Functions.GetPlate(veh)
                if vplate == plate then
                    createBlipForVehicle(veh, plate)
                    break
                end
            end
        end
    end)
end

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    LoadTrackedPlates()
end)

CreateThread(function()
    while not LocalPlayer.state.isLoggedIn do
        Wait(100)
    end
    LoadTrackedPlates()
end)

-- Cleanup on stop
AddEventHandler('onClientResourceStop', function(res)
    if res == GetCurrentResourceName() then
        for plate,_ in pairs(Tracked) do removeBlip(plate) end
    end
end)