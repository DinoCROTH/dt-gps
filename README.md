# dt-gps
A fully-featured and immersive GPS tracking system for vehicles using the QBCore framework in FiveM.

**Author:** DinoCROTH  
**Version:** 1.0.0  
**Framework:** QBCore  
**Description:** A GPS Tracker system for QBCore-based FiveM servers.

## 📦 Features

- Install and remove GPS trackers on vehicles.
- Displays a blip on the map for tracked vehicles.
- Only shows blips when the player is not in the tracked vehicle.
- Tracker data is saved to a SQL database and is persistent across sessions.
- Temporary tracking for unowned vehicles.
- Notifications using `okokNotify`.

## 🛠️ Installation

1. **Download and extract** the resource into your `resources` folder.

2. **Add to your `server.cfg`:**
   ```
   ensure dt-gps
   ```

3. **Items Required (Add to `shared/items.lua`):**
   ```lua
   gps_tracker                  = { name = 'gps_tracker', label = 'GPS Tracker', weight = 100, type = 'item', image = 'gps_tracker.png', unique = true, useable = true, shouldClose = true, combinable = nil, description = 'Install this on your vehicle to track it remotely.' },
   gps_tracker_remover          = { name = 'gps_tracker_remover', label = 'GPS Tracker Remover', weight = 100, type = 'item', image = 'gps_tracker_remover.png', unique = true, useable = true, shouldClose = true, combinable = nil, description = 'Remove the GPS tracker from your vehicle.' },
   ```

4. **Dependencies:**
   - `oxmysql`(https://github.com/overextended/oxmysql)
   - `okokNotify`
   - QBCore Framework

5. **Database Setup:**
   Automatically creates the required `dt_gps` table on resource start.

## ⚙️ Configuration

Edit `config.lua` to customize behavior:
```lua
Config.RequireOwnershipForGPS = true

Config.Blip = {
    Sprite = 595,
    Colour = 0,
    Scale = 0.9,
    ShowName = true,
    NamePrefix = "GPS Na Vozilu: "
}

Config.InstallDuration = 4000
Config.RemoveDuration = 6000

Config.Texts = {
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
}
```

## 🔧 Usage

- **Install GPS:** Use the `gps_tracker` item inside a vehicle.
- **Remove GPS:** Use the `gps_tracker_remover` item inside the vehicle with a tracker.

## 🔐 Server Callbacks

- Saves and deletes tracker info with MySQL.
- Supports both owned and unowned vehicles.

## 📋 License

This resource is provided as-is for personal and community server use. Credit is appreciated.

---

> Developed by DinoCROTH
