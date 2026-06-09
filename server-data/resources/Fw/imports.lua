-- Fw/imports.lua
if GetCurrentResourceName() == 'Fw' then return end

-- Récupération du Core
_Fw = exports['Fw']:GetCoreObject()

-- Injection de la suite Ox nativement dans l'objet Fw
_Fw.Inventory = exports.ox_inventory
_Fw.MySQL = exports.oxmysql

-- (Optionnel) Tu peux aussi ajouter ox_lib ici, 
-- bien qu'il soit souvent préférable de l'inclure via le @ox_lib/init.lua dans le fxmanifest.
_Fw.Lib = exports.ox_lib