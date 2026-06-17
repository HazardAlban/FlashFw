-- ============================================================
--  fw_inventory | shared/items.lua
--  Catalogue d'items — ajouter vos items ici
-- ============================================================

Items = {}

-- ─────────────────────────────────────────────
--  FORMAT D'UN ITEM :
--  [name] = {
--      label       = "Nom affiché",
--      weight      = 100,          -- grammes
--      stack       = true,         -- empilable ?
--      usable      = true,         -- utilisable ?
--      description = "Description",
--      image       = "item_name",  -- nom du fichier dans ui/img/
--      type        = "item",       -- "item" | "weapon" | "ammo"
--      durability  = true,         -- soumis à l'usure ?
--      unique      = false,        -- 1 seul par stack (armes, docs...)
--      metadata    = {},           -- métadonnées par défaut
--  }
-- ─────────────────────────────────────────────

-- ══════════════════════════════════════
--  CONSOMMABLES & SURVIE
-- ══════════════════════════════════════
Items['water']          = { label = 'Eau',              weight = 500,   stack = true,   usable = true,  type = 'item',   durability = false, unique = false, description = 'Bouteille d\'eau fraîche.',           image = 'water' }
Items['sandwich']       = { label = 'Sandwich',         weight = 300,   stack = true,   usable = true,  type = 'item',   durability = false, unique = false, description = 'Un sandwich maison.',                 image = 'sandwich' }
Items['donut']          = { label = 'Donut',            weight = 150,   stack = true,   usable = true,  type = 'item',   durability = false, unique = false, description = 'Donut glacé.',                        image = 'donut' }
Items['juice']          = { label = 'Jus de fruit',     weight = 400,   stack = true,   usable = true,  type = 'item',   durability = false, unique = false, description = 'Jus d\'orange pressé.',               image = 'juice' }
Items['energydrink']    = { label = 'Energy Drink',     weight = 350,   stack = true,   usable = true,  type = 'item',   durability = false, unique = false, description = 'Boisson énergisante.',                image = 'energydrink' }

-- ══════════════════════════════════════
--  MÉDICAL
-- ══════════════════════════════════════
Items['bandage']        = { label = 'Bandage',          weight = 100,   stack = true,   usable = true,  type = 'item',   durability = false, unique = false, description = 'Bandage stérile.',                    image = 'bandage' }
Items['medikit']        = { label = 'Kit médical',      weight = 800,   stack = false,  usable = true,  type = 'item',   durability = true,  unique = true,  description = 'Kit de premiers secours complet.',    image = 'medikit',   metadata = { uses = 3 } }
Items['painkiller']     = { label = 'Analgésique',      weight = 50,    stack = true,   usable = true,  type = 'item',   durability = false, unique = false, description = 'Réduit la douleur.',                  image = 'painkiller' }
Items['morphine']       = { label = 'Morphine',         weight = 80,    stack = true,   usable = true,  type = 'item',   durability = false, unique = false, description = 'Opioïde puissant. Usage médical.',    image = 'morphine' }

-- ══════════════════════════════════════
--  OUTILS & DIVERS
-- ══════════════════════════════════════
Items['lockpick']       = { label = 'Crochet',          weight = 200,   stack = false,  usable = true,  type = 'item',   durability = true,  unique = true,  description = 'Pour crocheter des serrures.',        image = 'lockpick',  metadata = { durability = 100 } }
Items['repairkit']      = { label = 'Kit de réparation',weight = 1500,  stack = false,  usable = true,  type = 'item',   durability = true,  unique = true,  description = 'Répare les véhicules.',               image = 'repairkit', metadata = { uses = 5 } }
Items['screwdriver']    = { label = 'Tournevis',        weight = 300,   stack = false,  usable = true,  type = 'item',   durability = false, unique = false, description = 'Outil de base.',                      image = 'screwdriver' }
Items['phone']          = { label = 'Téléphone',        weight = 200,   stack = false,  usable = true,  type = 'item',   durability = false, unique = true,  description = 'Smartphone.',                         image = 'phone',     metadata = { number = '000-0000' } }
Items['radio']          = { label = 'Radio',            weight = 400,   stack = false,  usable = true,  type = 'item',   durability = true,  unique = true,  description = 'Radio de communication.',             image = 'radio',     metadata = { channel = 1, durability = 100 } }

-- ══════════════════════════════════════
--  DOCUMENTS & IDENTITÉ
-- ══════════════════════════════════════
Items['id_card']        = { label = 'Carte d\'identité',weight = 20,    stack = false,  usable = true,  type = 'item',   durability = false, unique = true,  description = 'Pièce d\'identité officielle.',       image = 'id_card',   metadata = { firstname = '', lastname = '', dob = '' } }
Items['driver_license'] = { label = 'Permis de conduire',weight= 20,    stack = false,  usable = true,  type = 'item',   durability = false, unique = true,  description = 'Permis de conduire.',                 image = 'driver_license', metadata = { category = 'B' } }
Items['cash']           = { label = 'Argent liquide',   weight = 0,     stack = true,   usable = false, type = 'item',   durability = false, unique = false, description = 'Billets de banque.',                  image = 'cash' }

-- ══════════════════════════════════════
--  MATIÈRES PREMIÈRES & CRAFT
-- ══════════════════════════════════════
Items['iron_ore']       = { label = 'Minerai de fer',   weight = 2000,  stack = true,   usable = false, type = 'item',   durability = false, unique = false, description = 'Minerai brut.',                       image = 'iron_ore' }
Items['iron_ingot']     = { label = 'Lingot de fer',    weight = 1500,  stack = true,   usable = false, type = 'item',   durability = false, unique = false, description = 'Lingot fondu.',                       image = 'iron_ingot' }
Items['cloth']          = { label = 'Tissu',            weight = 200,   stack = true,   usable = false, type = 'item',   durability = false, unique = false, description = 'Tissu de base.',                      image = 'cloth' }

-- ══════════════════════════════════════
--  ARMES (items de type weapon)
-- ══════════════════════════════════════
Items['weapon_pistol']  = {
    label       = 'Pistolet',
    weight      = 1200,
    stack       = false,
    usable      = true,
    type        = 'weapon',
    durability  = true,
    unique      = true,
    description = 'Pistolet semi-automatique standard.',
    image       = 'weapon_pistol',
    metadata    = {
        durability  = 100,
        ammo        = 0,
        serial      = '',
        attachments = {},
    }
}

Items['weapon_combatpistol'] = {
    label       = 'Pistolet de combat',
    weight      = 1400,
    stack       = false,
    usable      = true,
    type        = 'weapon',
    durability  = true,
    unique      = true,
    description = 'Pistolet de combat haute cadence.',
    image       = 'weapon_combatpistol',
    metadata    = {
        durability  = 100,
        ammo        = 0,
        serial      = '',
        attachments = {},
    }
}

Items['weapon_assaultrifle'] = {
    label       = 'Fusil d\'assaut',
    weight      = 3800,
    stack       = false,
    usable      = true,
    type        = 'weapon',
    durability  = true,
    unique      = true,
    description = 'Fusil d\'assaut militaire.',
    image       = 'weapon_assaultrifle',
    metadata    = {
        durability  = 100,
        ammo        = 0,
        serial      = '',
        attachments = {},
    }
}

Items['weapon_pumpshotgun'] = {
    label       = 'Fusil à pompe',
    weight      = 3200,
    stack       = false,
    usable      = true,
    type        = 'weapon',
    durability  = true,
    unique      = true,
    description = 'Fusil à pompe redoutable à courte portée.',
    image       = 'weapon_pumpshotgun',
    metadata    = {
        durability  = 100,
        ammo        = 0,
        serial      = '',
        attachments = {},
    }
}

Items['weapon_sniperrifle'] = {
    label       = 'Sniper',
    weight      = 5500,
    stack       = false,
    usable      = true,
    type        = 'weapon',
    durability  = true,
    unique      = true,
    description = 'Fusil de précision longue portée.',
    image       = 'weapon_sniperrifle',
    metadata    = {
        durability  = 100,
        ammo        = 0,
        serial      = '',
        attachments = {},
    }
}

Items['weapon_knife'] = {
    label       = 'Couteau',
    weight      = 400,
    stack       = false,
    usable      = true,
    type        = 'weapon',
    durability  = true,
    unique      = true,
    description = 'Couteau de combat tranchant.',
    image       = 'weapon_knife',
    metadata    = {
        durability  = 100,
        serial      = '',
    }
}

-- ══════════════════════════════════════
--  MUNITIONS
-- ══════════════════════════════════════
Items['ammo_pistol']    = { label = 'Munitions 9mm',    weight = 30,    stack = true,   usable = false, type = 'ammo',  durability = false, unique = false, description = 'Cartouches 9mm standard.',             image = 'ammo_pistol' }
Items['ammo_rifle']     = { label = 'Munitions 5.56',   weight = 40,    stack = true,   usable = false, type = 'ammo',  durability = false, unique = false, description = 'Cartouches 5.56mm OTAN.',              image = 'ammo_rifle' }
Items['ammo_shotgun']   = { label = 'Cartouches',       weight = 80,    stack = true,   usable = false, type = 'ammo',  durability = false, unique = false, description = 'Cartouches de chevrotine.',            image = 'ammo_shotgun' }
Items['ammo_sniper']    = { label = 'Munitions .50',    weight = 100,   stack = true,   usable = false, type = 'ammo',  durability = false, unique = false, description = 'Cartouches .50 BMG.',                 image = 'ammo_sniper' }

-- Helper : récupère un item par son nom
function GetItemData(itemName)
    return Items[itemName] or nil
end

-- Helper : vérifie si un item est une arme
function IsWeaponItem(itemName)
    local item = Items[itemName]
    return item and item.type == 'weapon'
end
