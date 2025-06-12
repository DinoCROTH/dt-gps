Config = {}
-- General settings

Config.RequireOwnershipForGPS = true

-- Blip settings
Config.Blip = {
    Sprite = 595,
    Colour = 0,
    Scale = 0.9,
    ShowName = true,
    NamePrefix = "GPS Na Vozilu: "
}

-- Tracker installation settings
Config.InstallDuration = 10000
Config.RemoveDuration = 60000

-- Texts for notifications and alerts
Config.Texts = {
    NotInVehicle = "Morate biti u vozilu.",
    NotInstalled = "Nema instaliranog tragača.",
    InstallStart = "Instalacija GPS tragača...",
    InstallSuccess = "GPS instaliran na %s.",
    InstallFail = "Neuspjela instalacija GPS-a.",
    InstallCancel = "Instalacija otkazana.",
    AlreadyInstalled = "Tragač je već instaliran na %s.",
    RemoveStart = "Uklanjanje GPS tragača...",
    RemoveSuccess = "GPS uklonjen s %s.",
    RemoveFail = "Neuspjelo uklanjanje GPS-a.",
    RemoveCancel = "Uklanjanje otkazano.",
}

-- Uncomment and modify the following lines to customize texts
--[[ Config.Texts = {
    NotInVehicle = "You must be in a vehicle.",
    NotInstalled = "No tracker installed.",
    InstallStart = "Installing GPS tracker...",
    InstallSuccess = "GPS installed on %s.",
    InstallFail = "GPS installation failed.",
    InstallCancel = "Installation canceled.",
    AlreadyInstalled = "Tracker is already installed on %s.",
    RemoveStart = "Removing GPS tracker...",
    RemoveSuccess = "GPS removed from %s.",
    RemoveFail = "GPS removal failed.",
    RemoveCancel = "Removal canceled.",
} ]]


-- Item names (must match your items in shared/items.lua)
Config.Items = {
    Tracker = "gps_tracker",
    Remover = "gps_tracker_remover"
}
