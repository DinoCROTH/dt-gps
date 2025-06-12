local QBCore = exports['qb-core']:GetCoreObject()

-- Temporary GPS data storage
local TempGPS = {}
-- Temporary GPS data storage

-- Ensure SQL table exists
CreateThread(function()
    local query = [[
        CREATE TABLE IF NOT EXISTS `dt_gps` (
            `plate` varchar(10) NOT NULL,
            `installed_by` varchar(64) NOT NULL,
            `installed_at` datetime NOT NULL,
            PRIMARY KEY (`plate`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8;
    ]]
    exports.oxmysql:execute(query, {})
end)

-- Register usable item for installing tracker
QBCore.Functions.CreateUseableItem(Config.Items.Tracker, function(source)
    TriggerClientEvent('dt-gps:client:installTracker', source)
end)
-- Save tracker
QBCore.Functions.CreateCallback('dt-gps:server:saveTracker', function(source, cb, plate)
    local xPlayer = QBCore.Functions.GetPlayer(source)
    if not xPlayer then cb(false) return end

    exports.oxmysql:fetch('SELECT plate FROM player_vehicles WHERE plate = ?', {plate}, function(result)
        if result and result[1] then
            -- Vehicle is owned, save to DB
            exports.oxmysql:insert(
                'INSERT INTO dt_gps (plate, installed_by, installed_at) VALUES (?, ?, NOW()) ON DUPLICATE KEY UPDATE installed_by = ?, installed_at = NOW()',
                {plate, xPlayer.PlayerData.citizenid, xPlayer.PlayerData.citizenid},
                function(rows) cb(rows and true or false) end
            )
        else
            -- Vehicle not owned, store in TempGPS
            TempGPS[plate] = {
                installed_by = xPlayer.PlayerData.citizenid,
                installed_at = os.time()
            }
            cb(true)
        end
    end)
end)
-- Remove tracker item from player
RegisterNetEvent('dt-gps:server:removeTrackerItem', function()
    local src = source
    local xPlayer = QBCore.Functions.GetPlayer(src)
    if xPlayer then
        local removed = xPlayer.Functions.RemoveItem(Config.Items.Tracker, 1)
        if removed then
            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Config.Items.Tracker], "remove")
        else
            print("[dt-gps] Failed to remove GPS tracker item from player " .. src)
        end
    end
end)
-- Remove tracker item from player
-- Register usable item for installing tracker

-- Register usable item for removing tracker
QBCore.Functions.CreateUseableItem(Config.Items.Remover, function(source)
    TriggerClientEvent('dt-gps:client:removeTracker', source)
end)

-- Delete tracker
QBCore.Functions.CreateCallback('dt-gps:server:deleteTracker', function(source, cb, plate)
    local xPlayer = QBCore.Functions.GetPlayer(source)
    if not xPlayer then cb(false) return end
    exports.oxmysql:execute(
        'DELETE FROM dt_gps WHERE plate = ? AND installed_by = ?',
        {plate, xPlayer.PlayerData.citizenid},
        function(rows) cb(rows and true or false) end
    )
end)
-- Register usable item for removing tracker

-- Fetch vehicle owner by plate
QBCore.Functions.CreateCallback('dt-gps:server:getTrackedPlates', function(source, cb)
    local xPlayer = QBCore.Functions.GetPlayer(source)
    if not xPlayer then cb({}) return end

    exports.oxmysql:fetch(
        'SELECT plate FROM dt_gps WHERE installed_by = ?',
        {xPlayer.PlayerData.citizenid},
        function(result)
            local plates = {}

            -- Add DB-tracked plates
            for _, v in ipairs(result or {}) do
                plates[v.plate] = true
            end

            -- Add temporary unowned vehicle plates
            for plate, data in pairs(TempGPS) do
                if data.installed_by == xPlayer.PlayerData.citizenid then
                    plates[plate] = true
                end
            end

            cb(plates)
        end
    )
end)
-- Fetch vehicle owner by plate


