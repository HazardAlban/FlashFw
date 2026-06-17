# fw_inventory

Inventaire standalone complet pour serveur FiveM — aucune dépendance framework.

---

## Fonctionnalités

| Fonctionnalité              | Détail                                                    |
|-----------------------------|-----------------------------------------------------------|
| **3 colonnes**              | Contexte (sol/glovebox) · Ped joueur · Inventaire         |
| **Drag & Drop**             | Entre tous les panneaux et la hotbar                      |
| **Hotbar (1–5)**            | Raccourcis clavier, drag depuis l'inventaire              |
| **Ped preview**             | Clone du joueur dans le menu pause natif GTA              |
| **Métadonnées**             | Numéro de série, canaux radio, uses, données doc…         |
| **Durabilité**              | Barre visuelle par slot, dégradation configurable         |
| **Armes en items**          | Munitions, équipement, usure par tir                      |
| **Items au sol**            | Persistants en BDD, marqueurs 3D, ramassage               |
| **Boîte à gants / coffre**  | Détection automatique selon position du joueur            |
| **Donner / Jeter / Utiliser** | Boutons + sélection de quantité                         |
| **Notifications**           | Système intégré (success / error / warning / info)        |
| **Exports publics**         | API pour les autres resources                             |

---

## Dépendances

- **mysql-async** — wrapper SQL uniquement
- Aucun framework (ESX, QBCore…)

---

## Installation

### 1. Base de données

```sql
-- Exécuter sql/migration.sql dans votre gestionnaire de BDD
```

### 2. Dossier resource

Placer `fw_inventory/` dans votre dossier `resources/`.

### 3. server.cfg

```cfg
ensure fw_inventory
```

### 4. Images des items

Placer les images PNG dans `ui/img/` avec le même nom que la clé `image` définie dans `shared/items.lua`.

Exemples :
```
ui/img/water.png
ui/img/bandage.png
ui/img/weapon_pistol.png
```

Taille recommandée : **128×128 px** ou **256×256 px**, fond transparent.

---

## Ajouter un item

Dans `shared/items.lua` :

```lua
Items['mon_item'] = {
    label       = 'Mon item',
    weight      = 500,          -- grammes
    stack       = true,         -- empilable
    usable      = true,         -- utilisable
    type        = 'item',       -- 'item' | 'weapon' | 'ammo'
    durability  = false,        -- soumis à l'usure
    unique      = false,        -- 1 seul par slot
    description = 'Description de l\'item.',
    image       = 'mon_item',   -- ui/img/mon_item.png
    metadata    = {},           -- métadonnées par défaut
}
```

---

## Enregistrer un item utilisable

Depuis une autre resource (côté serveur) :

```lua
exports.fw_inventory:RegisterUsable('mon_item', function(playerId, itemName, slotIndex, metadata)
    -- Retirer l'item
    exports.fw_inventory:RemoveItem(
        GetPlayerIdentifierByType(playerId, 'license'),
        itemName,
        1,
        function(ok)
            if ok then
                -- Votre logique ici
                TriggerClientEvent('mon_event', playerId)
            end
        end
    )
end)
```

---

## Exports serveur

```lua
-- Ajouter un item à un joueur
exports.fw_inventory:AddItem(identifier, itemName, amount, metadata, callback)

-- Retirer un item
exports.fw_inventory:RemoveItem(identifier, itemName, amount, callback)

-- Vérifier si un joueur possède un item
local hasIt = exports.fw_inventory:HasItem(identifier, itemName, amount)

-- Récupérer l'inventaire complet
local inv = exports.fw_inventory:GetInventory(identifier)

-- Enregistrer un usable
exports.fw_inventory:RegisterUsable(itemName, callback)
```

---

## Structure des fichiers

```
fw_inventory/
├── fxmanifest.lua
├── shared/
│   ├── config.lua          ← Configuration (slots, poids, touches…)
│   └── items.lua           ← Catalogue de tous les items
├── server/
│   ├── main.lua            ← Events réseau, exports
│   ├── inventory.lua       ← Logique cœur (add/remove/move)
│   ├── items.lua           ← Usable callbacks, drops
│   ├── weapons.lua         ← Armes, munitions, usure
│   └── database.lua        ← Toutes les requêtes SQL
├── client/
│   ├── main.lua            ← Point d'entrée client
│   ├── ped_preview.lua     ← Clone ped dans menu pause
│   ├── camera.lua          ← Caméra inventaire
│   └── controls.lua        ← Touches clavier, hotbar
├── ui/
│   ├── index.html
│   ├── css/
│   │   ├── global.css
│   │   └── inventory.css
│   ├── js/
│   │   ├── utils.js        ← Notifications, tooltip, modal
│   │   ├── dragdrop.js     ← Drag & Drop
│   │   ├── hotbar.js       ← Gestion hotbar
│   │   └── app.js          ← Logique principale UI
│   └── img/                ← Images des items (PNG)
└── sql/
    └── migration.sql       ← Script d'installation BDD
```

---

## Raccourcis

| Touche       | Action                       |
|--------------|------------------------------|
| `F2`         | Ouvrir / Fermer l'inventaire |
| `1` à `5`    | Utiliser le slot hotbar       |
| `Clic gauche`| Sélectionner un item          |
| `Double-clic`| Utiliser / Ramasser           |
| `Clic droit` | Utiliser rapidement           |
| `Echap`      | Fermer l'inventaire           |

---

## Configuration (shared/config.lua)

```lua
Config.PlayerSlots   = 40       -- Slots joueur
Config.MaxWeight     = 30000    -- Poids max en grammes (30 kg)
Config.HotbarSlots   = 5        -- Raccourcis hotbar
Config.PickupDistance = 3.0     -- Distance ramassage au sol
Config.OpenKey       = 166      -- F2
Config.WeaponDecayRate = 0.1    -- % usure par balle
```
