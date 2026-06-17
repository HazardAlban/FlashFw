-- ============================================================
--  fw_inventory | shared/config.lua
--  Configuration centrale — modifier selon vos besoins
-- ============================================================

Config = {}

-- Taille des inventaires
Config.PlayerSlots      = 40        -- Slots inventaire joueur
Config.DropSlots        = 20        -- Slots items au sol
Config.GloveboxSlots    = 15        -- Slots boîte à gants
Config.TrunkSlots       = 30        -- Slots coffre voiture

-- Poids maximum (en grammes)
Config.MaxWeight        = 30000     -- 30 kg max joueur

-- Distance pour ramasser / interagir avec le sol
Config.PickupDistance   = 3.0       -- mètres

-- Distance pour accéder à la boîte à gants / coffre
Config.VehicleDistance  = 2.5       -- mètres

-- Hotbar
Config.HotbarSlots      = 5         -- Nombre de slots raccourcis

-- Usure (durabilité)
Config.DurabilityDecay  = true      -- Activer l'usure
Config.WeaponDecayRate  = 0.1       -- % usure par balle tirée
Config.FoodDecayOnUse   = false     -- Les aliments ne s'usent pas

-- Armes — liste des hash connus (pour détection auto)
Config.WeaponList = {
    [`weapon_pistol`]           = true,
    [`weapon_combatpistol`]     = true,
    [`weapon_pistol50`]         = true,
    [`weapon_snspistol`]        = true,
    [`weapon_heavypistol`]      = true,
    [`weapon_vintagepistol`]    = true,
    [`weapon_appistol`]         = true,
    [`weapon_stungun`]          = true,
    [`weapon_flaregun`]         = true,
    [`weapon_marksmanpistol`]   = true,
    [`weapon_revolver`]         = true,
    [`weapon_microsmg`]         = true,
    [`weapon_smg`]              = true,
    [`weapon_assaultsmg`]       = true,
    [`weapon_combatpdw`]        = true,
    [`weapon_machinepistol`]    = true,
    [`weapon_minismg`]          = true,
    [`weapon_assaultrifle`]     = true,
    [`weapon_carbinerifle`]     = true,
    [`weapon_advancedrifle`]    = true,
    [`weapon_specialcarbine`]   = true,
    [`weapon_bullpuprifle`]     = true,
    [`weapon_compactrifle`]     = true,
    [`weapon_mg`]               = true,
    [`weapon_combatmg`]         = true,
    [`weapon_gusenberg`]        = true,
    [`weapon_pumpshotgun`]      = true,
    [`weapon_sawnoffshotgun`]   = true,
    [`weapon_bullpupshotgun`]   = true,
    [`weapon_assaultshotgun`]   = true,
    [`weapon_heavyshotgun`]     = true,
    [`weapon_dbshotgun`]        = true,
    [`weapon_autoshotgun`]      = true,
    [`weapon_sniperrifle`]      = true,
    [`weapon_heavysniper`]      = true,
    [`weapon_marksmanrifle`]    = true,
    [`weapon_rpg`]              = true,
    [`weapon_grenadelauncher`]  = true,
    [`weapon_minigun`]          = true,
    [`weapon_firework`]         = true,
    [`weapon_railgun`]          = true,
    [`weapon_hominglauncher`]   = true,
    [`weapon_knife`]            = true,
    [`weapon_bat`]              = true,
    [`weapon_hammer`]           = true,
    [`weapon_crowbar`]          = true,
    [`weapon_nightstick`]       = true,
    [`weapon_wrench`]           = true,
    [`weapon_poolcue`]          = true,
    [`weapon_knuckle`]          = true,
    [`weapon_grenade`]          = true,
    [`weapon_bzgas`]            = true,
    [`weapon_molotov`]          = true,
    [`weapon_stickybomb`]       = true,
    [`weapon_proxmine`]         = true,
    [`weapon_snowball`]         = true,
    [`weapon_pipebomb`]         = true,
    [`weapon_ball`]             = true,
    [`weapon_smokegrenade`]     = true,
    [`weapon_flare`]            = true,
    [`weapon_petrolcan`]        = true,
    [`weapon_fireextinguisher`] = true,
    [`weapon_hazardcan`]        = true,
    [`weapon_unarmed`]          = false,
}

-- Clé pour ouvrir l'inventaire (F2 = 166)
Config.OpenKey = 289
