-- ============================================================
--  fw_inventory | sql/migration.sql
--  Exécuter UNE SEULE FOIS lors de l'installation
-- ============================================================

-- Table principale des inventaires (joueurs + véhicules)
CREATE TABLE IF NOT EXISTS `fw_inventories` (
    `id`         INT UNSIGNED    NOT NULL AUTO_INCREMENT,
    `owner`      VARCHAR(60)     NOT NULL COMMENT 'identifier joueur ou vehicle_PLATE',
    `type`       VARCHAR(30)     NOT NULL DEFAULT 'player' COMMENT 'player | glovebox | trunk',
    `label`      VARCHAR(60)     NULL,
    `slots`      SMALLINT        NOT NULL DEFAULT 40,
    `data`       LONGTEXT        NOT NULL DEFAULT '{}' COMMENT 'JSON des slots',
    `created_at` TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uniq_owner_type` (`owner`, `type`),
    INDEX `idx_owner` (`owner`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Inventaires joueurs et véhicules — fw_inventory';

-- Table des drops persistants (items au sol)
CREATE TABLE IF NOT EXISTS `fw_drops` (
    `id`         INT UNSIGNED    NOT NULL AUTO_INCREMENT,
    `items`      LONGTEXT        NOT NULL DEFAULT '{}' COMMENT 'JSON des items droppés',
    `coords`     TEXT            NOT NULL COMMENT 'JSON {x,y,z}',
    `created_at` TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Items jetés au sol persistants — fw_inventory';

-- Colonne cash dans players (si elle n'existe pas déjà)
-- À commenter si votre table players a déjà une colonne cash
-- ALTER TABLE `players` ADD COLUMN `cash` INT UNSIGNED NOT NULL DEFAULT 0;

-- ── EXEMPLE DE FORMAT D'UN INVENTAIRE EN BDD ───────────────
-- {
--   "1": { "name": "water",  "amount": 3,  "slot": 1, "metadata": {} },
--   "2": { "name": "bandage","amount": 1,  "slot": 2, "metadata": { "durability": 100 } },
--   "5": { "name": "weapon_pistol","amount": 1,"slot": 5,
--           "metadata": { "durability": 85, "ammo": 12, "serial": "AB3X9K2R7Q" } }
-- }
