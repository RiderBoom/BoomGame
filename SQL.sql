-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Server version:               10.7.3-MariaDB - mariadb.org binary distribution
-- Server OS:                    Win64
-- HeidiSQL Version:             11.3.0.6295
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Dumping database structure for es_extended
CREATE DATABASE IF NOT EXISTS `es_extended` /*!40100 DEFAULT CHARACTER SET latin1 */;
USE `es_extended`;

-- Dumping structure for table es_extended.account_player
CREATE TABLE IF NOT EXISTS `account_player` (
  `identifier` varchar(255) COLLATE utf8mb3_bin NOT NULL,
  `steamname` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `ic_name` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
  `money` int(11) DEFAULT 0,
  `black_money` int(11) DEFAULT 0,
  `bank` int(11) DEFAULT 0,
  PRIMARY KEY (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

-- Dumping data for table es_extended.account_player: ~0 rows (approximately)
/*!40000 ALTER TABLE `account_player` DISABLE KEYS */;
/*!40000 ALTER TABLE `account_player` ENABLE KEYS */;

-- Dumping structure for table es_extended.addon_account
CREATE TABLE IF NOT EXISTS `addon_account` (
  `name` varchar(60) COLLATE utf8mb4_bin NOT NULL,
  `label` varchar(255) COLLATE utf8mb4_bin NOT NULL,
  `shared` int(11) NOT NULL,
  PRIMARY KEY (`name`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=COMPACT;

-- Dumping data for table es_extended.addon_account: ~4 rows (approximately)
/*!40000 ALTER TABLE `addon_account` DISABLE KEYS */;
INSERT INTO `addon_account` (`name`, `label`, `shared`) VALUES
	('society_mod', 'Mod', 0),
	('society_police', 'Police', 0),
	('vault', 'Vault', 0),
	('vault_black_money', 'Money Vault', 0);
/*!40000 ALTER TABLE `addon_account` ENABLE KEYS */;

-- Dumping structure for table es_extended.addon_account_data
CREATE TABLE IF NOT EXISTS `addon_account_data` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_name` varchar(255) COLLATE utf8mb4_bin DEFAULT NULL,
  `money` double NOT NULL,
  `owner` varchar(255) COLLATE utf8mb4_bin DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

-- Dumping data for table es_extended.addon_account_data: ~0 rows (approximately)
/*!40000 ALTER TABLE `addon_account_data` DISABLE KEYS */;
/*!40000 ALTER TABLE `addon_account_data` ENABLE KEYS */;

-- Dumping structure for table es_extended.addon_inventory
CREATE TABLE IF NOT EXISTS `addon_inventory` (
  `name` varchar(60) COLLATE utf8mb4_bin NOT NULL,
  `label` varchar(100) COLLATE utf8mb4_bin NOT NULL,
  `shared` int(11) NOT NULL,
  PRIMARY KEY (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

-- Dumping data for table es_extended.addon_inventory: ~0 rows (approximately)
/*!40000 ALTER TABLE `addon_inventory` DISABLE KEYS */;
/*!40000 ALTER TABLE `addon_inventory` ENABLE KEYS */;

-- Dumping structure for table es_extended.addon_inventory_items
CREATE TABLE IF NOT EXISTS `addon_inventory_items` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `inventory_name` varchar(100) COLLATE utf8mb4_bin NOT NULL,
  `name` varchar(100) COLLATE utf8mb4_bin NOT NULL,
  `count` int(11) NOT NULL,
  `owner` varchar(40) COLLATE utf8mb4_bin DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_addon_inventory_items_inventory_name_name` (`inventory_name`,`name`),
  KEY `index_addon_inventory_items_inventory_name_name_owner` (`inventory_name`,`name`,`owner`),
  KEY `index_addon_inventory_inventory_name` (`inventory_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=COMPACT;

-- Dumping data for table es_extended.addon_inventory_items: ~0 rows (approximately)
/*!40000 ALTER TABLE `addon_inventory_items` DISABLE KEYS */;
/*!40000 ALTER TABLE `addon_inventory_items` ENABLE KEYS */;

-- Dumping structure for table es_extended.azael_dc_whitelisted
CREATE TABLE IF NOT EXISTS `azael_dc_whitelisted` (
  `discord` varchar(50) NOT NULL,
  `identifier` varchar(50) NOT NULL,
  `date_exp` int(11) NOT NULL DEFAULT 0,
  `point` int(11) NOT NULL DEFAULT 0,
  `point_exp` int(11) DEFAULT NULL,
  `connect` int(11) DEFAULT NULL,
  `banned` tinyint(1) NOT NULL DEFAULT 0,
  `banned_reason` longtext DEFAULT NULL,
  `remove` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`discord`,`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Dumping data for table es_extended.azael_dc_whitelisted: ~0 rows (approximately)
/*!40000 ALTER TABLE `azael_dc_whitelisted` DISABLE KEYS */;
/*!40000 ALTER TABLE `azael_dc_whitelisted` ENABLE KEYS */;

-- Dumping structure for table es_extended.bans
CREATE TABLE IF NOT EXISTS `bans` (
  `license` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `time` int(20) NOT NULL,
  `reason` varchar(255) NOT NULL,
  PRIMARY KEY (`license`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- Dumping data for table es_extended.bans: 0 rows
/*!40000 ALTER TABLE `bans` DISABLE KEYS */;
/*!40000 ALTER TABLE `bans` ENABLE KEYS */;

-- Dumping structure for table es_extended.billing
CREATE TABLE IF NOT EXISTS `billing` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `identifier` varchar(255) COLLATE utf8mb4_bin NOT NULL,
  `sender` varchar(255) COLLATE utf8mb4_bin NOT NULL,
  `target_type` varchar(50) COLLATE utf8mb4_bin NOT NULL,
  `target` varchar(255) COLLATE utf8mb4_bin NOT NULL,
  `label` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `amount` int(11) NOT NULL,
  `time` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=COMPACT;

-- Dumping data for table es_extended.billing: ~0 rows (approximately)
/*!40000 ALTER TABLE `billing` DISABLE KEYS */;
/*!40000 ALTER TABLE `billing` ENABLE KEYS */;

-- Dumping structure for table es_extended.communityservice
CREATE TABLE IF NOT EXISTS `communityservice` (
  `identifier` varchar(100) NOT NULL,
  `actions_remaining` int(10) NOT NULL,
  PRIMARY KEY (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Dumping data for table es_extended.communityservice: ~0 rows (approximately)
/*!40000 ALTER TABLE `communityservice` DISABLE KEYS */;
/*!40000 ALTER TABLE `communityservice` ENABLE KEYS */;

-- Dumping structure for table es_extended.crew_phone_bank
CREATE TABLE IF NOT EXISTS `crew_phone_bank` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `type` int(11) NOT NULL DEFAULT 1,
  `identifier` varchar(50) COLLATE utf8mb4_bin NOT NULL,
  `name` varchar(50) COLLATE utf8mb4_bin NOT NULL,
  `price` int(11) NOT NULL,
  `time` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

-- Dumping data for table es_extended.crew_phone_bank: ~0 rows (approximately)
/*!40000 ALTER TABLE `crew_phone_bank` DISABLE KEYS */;
/*!40000 ALTER TABLE `crew_phone_bank` ENABLE KEYS */;

-- Dumping structure for table es_extended.crew_phone_news
CREATE TABLE IF NOT EXISTS `crew_phone_news` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `data` longtext DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb3;

-- Dumping data for table es_extended.crew_phone_news: ~0 rows (approximately)
/*!40000 ALTER TABLE `crew_phone_news` DISABLE KEYS */;
/*!40000 ALTER TABLE `crew_phone_news` ENABLE KEYS */;

-- Dumping structure for table es_extended.datastore
CREATE TABLE IF NOT EXISTS `datastore` (
  `name` varchar(60) COLLATE utf8mb4_bin NOT NULL,
  `label` varchar(255) COLLATE utf8mb4_bin NOT NULL,
  `shared` int(11) NOT NULL,
  PRIMARY KEY (`name`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=COMPACT;

-- Dumping data for table es_extended.datastore: ~4 rows (approximately)
/*!40000 ALTER TABLE `datastore` DISABLE KEYS */;
INSERT INTO `datastore` (`name`, `label`, `shared`) VALUES
	('society_ambulance', 'Ambulance', 1),
	('society_council', 'Council', 1),
	('society_mechanic', 'Mechanic', 1),
	('society_police', 'Police', 1);
/*!40000 ALTER TABLE `datastore` ENABLE KEYS */;

-- Dumping structure for table es_extended.datastore_data
CREATE TABLE IF NOT EXISTS `datastore_data` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(60) COLLATE utf8mb4_bin NOT NULL,
  `owner` varchar(60) COLLATE utf8mb4_bin DEFAULT NULL,
  `data` longtext CHARACTER SET latin1 DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `unique_datastore_owner_name` (`owner`,`name`) USING BTREE,
  KEY `index_datastore_name` (`name`) USING BTREE,
  KEY `owner` (`owner`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=COMPACT;

-- Dumping data for table es_extended.datastore_data: ~4 rows (approximately)
/*!40000 ALTER TABLE `datastore_data` DISABLE KEYS */;
INSERT INTO `datastore_data` (`id`, `name`, `owner`, `data`) VALUES
	(1, 'society_ambulance', NULL, '{}'),
	(2, 'society_mechanic', NULL, '{}'),
	(3, 'society_council', NULL, '{}'),
	(4, 'society_police', NULL, '{"weapons":[]}');
/*!40000 ALTER TABLE `datastore_data` ENABLE KEYS */;

-- Dumping structure for table es_extended.dpkeybinds
CREATE TABLE IF NOT EXISTS `dpkeybinds` (
  `id` varchar(50) DEFAULT NULL,
  `keybind1` varchar(50) DEFAULT 'num4',
  `emote1` varchar(255) DEFAULT '',
  `keybind2` varchar(50) DEFAULT 'num5',
  `emote2` varchar(255) DEFAULT '',
  `keybind3` varchar(50) DEFAULT 'num6',
  `emote3` varchar(255) DEFAULT '',
  `keybind4` varchar(50) DEFAULT 'num7',
  `emote4` varchar(255) DEFAULT '',
  `keybind5` varchar(50) DEFAULT 'num8',
  `emote5` varchar(255) DEFAULT '',
  `keybind6` varchar(50) DEFAULT 'num9',
  `emote6` varchar(255) DEFAULT ''
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Dumping data for table es_extended.dpkeybinds: ~0 rows (approximately)
/*!40000 ALTER TABLE `dpkeybinds` DISABLE KEYS */;
/*!40000 ALTER TABLE `dpkeybinds` ENABLE KEYS */;

-- Dumping structure for table es_extended.esx_manager_bans
CREATE TABLE IF NOT EXISTS `esx_manager_bans` (
  `identifier` varchar(60) COLLATE utf8mb4_bin NOT NULL,
  `name` text COLLATE utf8mb4_bin NOT NULL,
  `reason` longtext COLLATE utf8mb4_bin NOT NULL,
  PRIMARY KEY (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

-- Dumping data for table es_extended.esx_manager_bans: ~0 rows (approximately)
/*!40000 ALTER TABLE `esx_manager_bans` DISABLE KEYS */;
/*!40000 ALTER TABLE `esx_manager_bans` ENABLE KEYS */;

-- Dumping structure for table es_extended.esx_manager_warns
CREATE TABLE IF NOT EXISTS `esx_manager_warns` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `warned` text COLLATE utf8mb4_bin NOT NULL,
  `reason` text COLLATE utf8mb4_bin NOT NULL,
  `date` text COLLATE utf8mb4_bin DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

-- Dumping data for table es_extended.esx_manager_warns: ~0 rows (approximately)
/*!40000 ALTER TABLE `esx_manager_warns` DISABLE KEYS */;
/*!40000 ALTER TABLE `esx_manager_warns` ENABLE KEYS */;

-- Dumping structure for table es_extended.fine_types
CREATE TABLE IF NOT EXISTS `fine_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `label` varchar(255) COLLATE utf8mb4_bin DEFAULT NULL,
  `amount` int(11) DEFAULT NULL,
  `category` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=COMPACT;

-- Dumping data for table es_extended.fine_types: ~0 rows (approximately)
/*!40000 ALTER TABLE `fine_types` DISABLE KEYS */;
/*!40000 ALTER TABLE `fine_types` ENABLE KEYS */;

-- Dumping structure for table es_extended.items
CREATE TABLE IF NOT EXISTS `items` (
  `name` varchar(50) COLLATE utf8mb4_bin NOT NULL,
  `label` varchar(50) COLLATE utf8mb4_bin NOT NULL,
  `weight` int(11) DEFAULT 1,
  `limit` int(11) DEFAULT -1,
  `rare` int(11) NOT NULL DEFAULT 0,
  `can_remove` int(11) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

-- Dumping data for table es_extended.items: ~211 rows (approximately)
/*!40000 ALTER TABLE `items` DISABLE KEYS */;
INSERT INTO `items` (`name`, `label`, `weight`, `limit`, `rare`, `can_remove`) VALUES
	('reskin_card', 'RESKIN CARD', 0, -1, 0, 1),
	('AED', 'AED', 500, -1, 0, 1),
	('bandage', 'ผ้าพันแผล', 100, -1, 0, 1),
	('bread', 'เบอร์เกอร์', 200, -1, 0, 1),
	('card_locker', 'กุญแจตู้เซฟ', 0, -1, 1, 0),
	('hifi', 'Marshall', 500, -1, 0, 1),
	('new_player', 'NEW PLAYER', 0, -1, 0, 0),
	('oxygen_mask', 'Oxygen Mask', 1000, -1, 0, 1),
	('oxygen_maskOfficer', 'ชุดดำน้ำพิเศษ', 0, -1, 0, 0),
	('phone', 'โทรศัพท์', 0, -1, 0, 1),
	('radio', 'วิทยุหน่วยงาน', 0, -1, 0, 1),
	('silver_coin', 'เหรียญเงิน', 0, -1, 0, 1),
	('unluckycoin', 'Unlucky coin', 0, -1, 0, 0),
	('fixkit', 'ชุดกล่องซ่อม', 1000, -1, 0, 1),
	('medikit', 'Medikit', 100, -1, 0, 1),
	('bandage_p', 'ผ้าก๊อซพันแผล', 100, -1, 0, 1),
	('radio_p', 'วิทยุสื่อสาร', 0, -1, 0, 1),
	('water', 'โคล่า', 200, -1, 0, 1),
	('beer', 'เบียร์ช้าง', 200, -1, 0, 1),
	('regency', 'Regency', 500, -1, 0, 1),
	('miller_coin', 'MILLER COIN', 0, -1, 0, 0),
	('tool_work', 'อุปกรณ์ทำงาน', 100, -1, 0, 1),
	('stone', 'แร่ดิบ', 500, -1, 0, 1),
	('stone_pro', 'หิน', 500, -1, 0, 1),
	('copper_scrap', 'เศษทองแดง', 100, -1, 0, 1),
	('copper', 'ทองแดง', 200, -1, 0, 1),
	('steel_bar', 'เหล็กแท่ง', 100, -1, 0, 1),
	('diamond', 'เพชร', 200, -1, 0, 1),
	('mango', 'มะม่วงดิบ', 500, -1, 0, 1),
	('mango_pro', 'มะม่วงสุก', 1000, -1, 0, 1),
	('straw', 'สตอเบอรี่', 500, -1, 0, 1),
	('straw_pro', 'สตอเบอรี่แพ็ค', 1000, -1, 0, 1),
	('crab', 'ปูม้า', 500, -1, 0, 1),
	('crab_pro', 'ปูแพ็ค', 1000, -1, 0, 1),
	('shell', 'หอย', 500, -1, 0, 1),
	('shell_pro', 'หอยแพ็ค', 1000, -1, 0, 1),
	('rice', 'รวงข้าว', 500, -1, 0, 1),
	('rice_pro', 'ข้าวสาร', 1000, -1, 0, 1),
	('carrot', 'แครอทสกปรก', 500, -1, 0, 1),
	('carrot_pro', 'แครอท', 1000, -1, 0, 1),
	('cabbage', 'กะหล่ำสกปรก', 500, -1, 0, 1),
	('cabbage_pro', 'กะหล่ำ', 1000, -1, 0, 1),
	('mushroom', 'เห็ด', 500, -1, 0, 1),
	('mushroom_pro', 'เห็ดขี้ควาย', 1000, -1, 0, 1),
	('wood', 'ไม้', 500, -1, 0, 1),
	('wood_pro', 'แพ็คไม้', 1000, -1, 0, 1),
	('steel', 'เศษเหล็ก', 500, -1, 0, 1),
	('iron', 'เหล็ก', 200, -1, 0, 1),
	('fishing_rod', 'เบ็ดตกปลา LV.1', 200, -1, 0, 1),
	('fish', 'ปลาทู', 300, -1, 0, 1),
	('pork_a', 'หมูพันธุ์', 500, -1, 0, 1),
	('pork_feed', 'อาหารหมู', 500, -1, 0, 1),
	('pork', 'เนื้อหมู', 500, -1, 0, 1),
	('repairkit', 'กล่องซ่อม 50%', 500, -1, 0, 1),
	('box_newplayer', 'กล่องผู้เล่นใหม่', 0, -1, 0, 0),
	('gold_coin', 'เหรียญทอง', 0, -1, 0, 1),
	('cement', 'ปูน', 500, -1, 0, 1),
	('newbie_car', 'NEWBIE CAR', 0, -1, 0, 0),
	('rag', 'ผ้าเช็ดรถ', 10, -1, 0, 1),
	('wire', 'สายไฟ', 100, -1, 0, 1),
	('electrical_board', 'แผงวงจร', 100, -1, 0, 1),
	('scrap_coin', 'เศษเหรียญ', 100, -1, 0, 1),
	('pig_poop', 'ขี้หมู', 100, -1, 0, 1),
	('coupon_bonus', 'คูปองโบนัส', 100, -1, 0, 1),
	('pearl', 'ไข่มุก', 500, 20, 0, 1),
	('battery', 'แบตเตอรี่', 100, -1, 0, 1),
	('spring', 'สปริง', 100, -1, 0, 1),
	('vibranium', 'ไวเบรเนี่ยม', 200, -1, 0, 1),
	('gold_scrap', 'เศษทอง', 500, -1, 0, 1),
	('gold', 'ทอง', 200, -1, 0, 1),
	('pickaxe', 'Pickaxe', 100, -1, 0, 1),
	('bread_s', 'ข้าวเหนียวมะม่วง', 500, -1, 0, 1),
	('bread_m', 'ข้าวหมูกระเทียม', 500, -1, 0, 1),
	('bread_full', 'กะเพราทะเล', 500, -1, 0, 1),
	('bottle', 'ขวดพลาสติก', 10, -1, 0, 1),
	('herb', 'สมุนไพร', 200, -1, 0, 1),
	('gem_ruby_green', 'GREEN RUBY', 200, -1, 0, 1),
	('fish2', 'ปลากะพง', 300, -1, 0, 1),
	('fishing_bait', 'เหยื่อปลา LV.1', 100, -1, 0, 1),
	('fishing_bait2', 'เหยื่อปลา LV.2', 100, -1, 0, 1),
	('fishing_rod2', 'เบ็ดตกปลา LV.2', 200, -1, 0, 1),
	('fish3', 'ม้าน้ำ', 300, -1, 0, 1),
	('fish4', 'ปลาแซลมอน', 300, -1, 0, 1),
	('fishing_gold', 'รางวัลตกปลา', 0, -1, 0, 0),
	('MRE', 'MRE', 1000, -1, 0, 1),
	('card_5m', '5MINS UNJAIL', 200, -1, 0, 1),
	('time_coin', 'TIME COIN', 0, -1, 0, 0),
	('ice_pooch', 'ยาไอซ์', 500, -1, 0, 1),
	('key_police', 'ตู้เซฟกลาง', 0, -1, 0, 0),
	('box_wrenchset', 'กล่องชุดตีประแจ', 500, -1, 0, 1),
	('fashion_01', 'STARS LEON', 0, -1, 0, 1),
	('fashion_02', 'ดอกกุหลาบ', 0, -1, 0, 1),
	('fashion_03', 'Unicorn', 0, -1, 0, 1),
	('fashion_04', 'กระเป๋าหมา', 0, -1, 0, 1),
	('fashion_05', 'กระเป๋าหน้าหมี', 0, -1, 0, 1),
	('fashion_06', 'กระเป๋าหมี', 0, -1, 0, 1),
	('fashion_07', 'หมาชิบะ', 0, -1, 0, 1),
	('fashion_08', 'กระต่ายขาว', 0, -1, 0, 1),
	('fashion_09', 'หมวกลูฟี่', 0, -1, 0, 1),
	('fashion_10', 'ปิกาจู', 0, -1, 0, 1),
	('exp', 'EXP', 0, -1, 0, 0),
	('level_1', 'LEVEL 1', 0, -1, 0, 0),
	('level_2', 'LEVEL 2', 0, -1, 0, 0),
	('level_3', 'LEVEL 3', 0, -1, 0, 0),
	('pearl_neck', 'สร้อยไข่มุก', 1000, -1, 0, 1),
	('shark', 'ฉลาม', 500, -1, 0, 1),
	('ray', 'กระเบน', 500, -1, 0, 1),
	('clip', 'กระสุนปืน', 100, -1, 0, 1),
	('bat_card', 'บัตรไม้เบสบอล', 0, -1, 0, 0),
	('golf_card', 'บัตรไม้กอล์ฟ', 0, -1, 0, 0),
	('knuckle_card', 'บัตรสนับมือ', 0, -1, 0, 0),
	('machete_card', 'บัตรมีดมาเชเต้', 0, -1, 0, 0),
	('bottle_card', 'บัตรปากฉลาม', 0, -1, 0, 0),
	('poolcue_card', 'บัตรไม้พลู', 0, -1, 0, 0),
	('wanted_card', 'WANTED CARD', 0, -1, 0, 0),
	('crown_boxwork', 'กล่องราชางานขาว', 0, -1, 0, 0),
	('crown_boxwork2', 'กล่องราชางานดำ', 0, -1, 0, 0),
	('fashion_crown1', 'มงกุฏงานขาว', 0, -1, 0, 0),
	('fashion_crown2', 'มงกุฏงานดำ', 0, -1, 0, 0),
	('gacha_exp', 'กล่องสุ่ม EXP', 0, -1, 0, 0),
	('ninja_card', 'NINJA CARD', 0, -1, 0, 0),
	('fashion_11', 'SECOND BEAR', 0, -1, 0, 1),
	('fashion_12', 'Chubby Cat', 0, -1, 0, 1),
	('fashion_13', 'Candy', 0, -1, 0, 1),
	('fashion_14', 'Samar', 0, -1, 0, 1),
	('gacha_01', 'Gachapon #01', 0, -1, 0, 1),
	('miller_card', 'MILLER CARD', 0, -1, 0, 1),
	('boxset_vault', 'กล่องตีตู้เซฟ', 0, -1, 0, 1),
	('skateboard', 'Skateboard', 0, -1, 0, 1),
	('turbo', 'TURBO', 1000, -1, 0, 1),
	('key_economy', 'Economy', 0, -1, 0, 1),
	('coin_event1', 'RED COIN', 0, -1, 0, 1),
	('coin_event2', 'GOKART COIN', 0, -1, 0, 1),
	('coin_event3', 'GREEN COIN', 0, -1, 0, 1),
	('coin_event4', 'ORANGE COIN', 0, -1, 0, 1),
	('lockpick', 'lockpick', 300, -1, 0, 1),
	('share', 'SHARE BOX', 0, -1, 0, 0),
	('vape', 'Relx Infinity', 100, -1, 0, 1),
	('gacha_02', 'Gacha Extra', 0, -1, 0, 1),
	('fashion_15', 'Sage', 0, -1, 0, 1),
	('fashion_16', 'Reyna', 0, -1, 0, 1),
	('fashion_17', 'Killjoy', 0, -1, 0, 1),
	('fashion_18', 'Jett', 0, -1, 0, 1),
	('gacha_box', 'เติมครบ 500 ลูก', 0, -1, 0, 1),
	('electric_box', 'กล่องซ่อมไฟ', 200, -1, 0, 1),
	('gem_ruby_yellow', 'YELLOW RUBY', 200, -1, 0, 1),
	('harf_ruby_yellow', 'เศษรูบี้เหลือง', 100, -1, 0, 1),
	('neck_black', 'สร้อยไข่มุกปลอม', 500, -1, 0, 1),
	('level_4', 'LEVEL 4', 0, -1, 0, 0),
	('box_batgolf', 'ชุดตีไม้เบส/กอล์ฟ', 500, -1, 0, 1),
	('weed', 'ใบกัญชา', 300, -1, 0, 1),
	('weed_pooch', 'แพ็คกัญชา', 500, -1, 0, 1),
	('seed_weed', 'เมล็ดกัญชา', 100, -1, 0, 1),
	('ninja_award', 'บัตรรางวัลนินจา', 0, -1, 0, 0),
	('card_openvault', 'กุญแจคราฟของสภา', 0, -1, 0, 0),
	('max_potion', 'First Aid', 0, -1, 0, 0),
	('AED_C', 'AED COUNCIL', 0, -1, 0, 0),
	('armorlv2', 'ชุดเกราะหน่วยงาน', 0, -1, 0, 0),
	('animal_feed', 'อาหารสัตว์', 10, -1, 0, 1),
	('fashion_19', 'กระเป๋าเพนกวิ้น', 0, -1, 0, 1),
	('fashion_20', 'หมาติดหัว', 0, -1, 0, 1),
	('fashion_21', 'จิ้งจอกบนหัว', 0, -1, 0, 1),
	('cement_event', 'ปูนกิจกรรม', 0, -1, 0, 1),
	('gang_coin', 'เหรียญแก๊ง', 0, -1, 0, 1),
	('gang_member', 'บัตรแก๊งสภา', 0, -1, 0, 1),
	('gang_carfcard', 'บัตรคราฟของ', 0, -1, 0, 1),
	('radio_event', 'วิทยุกิจกรรม', 0, -1, 0, 1),
	('fashion_council', 'เข็มกลัดสภาชาย', 0, -1, 0, 0),
	('fashion_council2', 'เข็มกลัดสภาหญิง', 0, -1, 0, 0),
	('box_firstaid', 'กล่องพยาบาล', 500, -1, 0, 1),
	('fixkit_s', 'กล่องซ่อมสตอรี่', 1000, -1, 0, 1),
	('fashion_22', 'Cypher', 0, -1, 0, 1),
	('card_phonenumber', 'บัตรเปลี่ยนเบอร์', 0, -1, 0, 1),
	('car_redshop', 'บัตรรถ Zentorno', 0, -1, 0, 1),
	('bag_5kg', 'กระเป๋า 5 KG.', 0, -1, 0, 0),
	('gacha_03', 'Gachapon #03', 0, -1, 0, 1),
	('fashion_23', 'แฟชั่นชินจัง', 0, -1, 0, 1),
	('fashion_24', 'กระเป๋าหมีพู', 0, -1, 0, 1),
	('fashion_25', 'Stitch', 0, -1, 0, 1),
	('bp_machete', 'Machete Blueprint', 0, -1, 0, 0),
	('bp_hatchet', 'Hatchet Blueprint', 0, -1, 0, 0),
	('lead', 'ตะกั่ว', 200, -1, 0, 1),
	('beryllium', 'เบริลเลียม', 200, -1, 0, 1),
	('platinum', 'แพลทินัม', 200, -1, 0, 1),
	('AED_Z', 'AED ZONE', 0, -1, 0, 0),
	('firstaid', 'Bandage Z.', 0, -1, 0, 0),
	('work_card', 'บัตรทำงานเร็ว', 0, -1, 0, 0),
	('box_work_card', 'กล่องบัตรงาน 1 วัน', 0, -1, 0, 1),
	('fashion_26', 'กระเป๋าผึ้ง', 0, -1, 0, 1),
	('fashion_27', 'หมวกผึ้ง', 0, -1, 0, 1),
	('fashion_28', 'MiniZilla', 0, -1, 0, 1),
	('armor', 'ชุดเกราะ', 500, -1, 0, 1),
	('money_gacha', 'MONEY BOX', 0, -1, 0, 0),
	('redmoney_gacha', 'RED MONEY BOX', 0, -1, 0, 0),
	('mtl_gacha', 'MATERIAL BOX', 0, -1, 0, 0),
	('wp_gacha', 'WEAPON BOX SET', 0, -1, 0, 0),
	('coin_gacha', 'COIN BOX', 0, -1, 0, 0),
	('card_gacha', 'CARD BOX', 0, -1, 0, 0),
	('top_gacha', 'TOPTIER BOX', 0, -1, 0, 0),
	('mix_gacha', 'MIX BOX', 0, -1, 0, 0),
	('chick', 'ไก่', 0, -1, 0, 1),
	('tuna', 'ปลาทูน่า', 0, -1, 0, 1),
	('crab', 'ปู', 0, -1, 0, 1),
	('lobster', 'กุ้งล็อบสเตอร์', 0, -1, 0, 1),
	('salmon', 'ปลาแซลมอน', 0, -1, 0, 1),
	('squid', 'ปลาหมึก', 0, -1, 0, 1),
	('seaweed_green', 'สาหร่ายเขียว', 0, -1, 0, 1),
	('seaweed_red', 'สาหร่ายแดง', 0, -1, 0, 1),
	('bags_cloth', 'กระเป๋าเสื้อผ้า', 0, -1, 0, 1),
	('suit_1', 'ชุดสูทดำ', 0, -1, 0, 1),
	('suit_2', 'ชุดสูทน้ำเงิน', 0, -1, 0, 1);
/*!40000 ALTER TABLE `items` ENABLE KEYS */;

-- Dumping structure for table es_extended.jobs
CREATE TABLE IF NOT EXISTS `jobs` (
  `name` varchar(50) COLLATE utf8mb4_bin NOT NULL,
  `label` varchar(50) COLLATE utf8mb4_bin DEFAULT NULL,
  `whitelisted` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`name`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=COMPACT;

-- Dumping data for table es_extended.jobs: ~10 rows (approximately)
/*!40000 ALTER TABLE `jobs` DISABLE KEYS */;
INSERT INTO `jobs` (`name`, `label`, `whitelisted`) VALUES
	('admin', 'ADMIN', 1),
	('ambulance', 'แพทย์', 1),
	('council', 'สภา', 1),
	('mechanic', 'ช่าง', 1),
	('offambulance', 'แพทย์ออกเวร', 1),
	('offcouncil', 'สภาออกเวร', 1),
	('offmechanic', 'ช่างออกเวร', 1),
	('offpolice', 'ตำรวจออกเวร', 1),
	('police', 'ตำรวจ', 1),
	('unemployed', 'ประชาชน', 1);
/*!40000 ALTER TABLE `jobs` ENABLE KEYS */;

-- Dumping structure for table es_extended.job_grades
CREATE TABLE IF NOT EXISTS `job_grades` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `job_name` varchar(50) COLLATE utf8mb4_bin DEFAULT NULL,
  `grade` int(11) NOT NULL,
  `name` varchar(50) COLLATE utf8mb4_bin NOT NULL,
  `label` varchar(50) COLLATE utf8mb4_bin NOT NULL,
  `salary` int(11) NOT NULL,
  `skin_male` longtext COLLATE utf8mb4_bin NOT NULL,
  `skin_female` longtext COLLATE utf8mb4_bin NOT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1000 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=COMPACT;

-- Dumping data for table es_extended.job_grades: ~70 rows (approximately)
/*!40000 ALTER TABLE `job_grades` DISABLE KEYS */;
INSERT INTO `job_grades` (`id`, `job_name`, `grade`, `name`, `label`, `salary`, `skin_male`, `skin_female`) VALUES
	(0, 'offmechanic', 3, 'expert', 'Off - ช่างชำนาญการ', 0, '', ''),
	(1, 'unemployed', 0, 'unemployed', 'ประชาชน', 0, '', ''),
	(3, 'ambulance', 0, 'ambulance', 'อาสาช่วยเหลือ', 2000, '', ''),
	(4, 'ambulance', 3, 'head_doctor', 'แพทย์ผู้เชี่ยวชาญ', 4000, '', ''),
	(5, 'ambulance', 4, 'chief_doctor', 'หัวหน้าแพทย์', 4500, '', ''),
	(18, 'police', 0, 'recruit', 'นักเรียนตำรวจ', 2000, '', ''),
	(19, 'police', 1, 'officer', 'หมู่', 2300, '', ''),
	(20, 'police', 8, 'sergeant', 'รองผู้กำกับ', 7200, '', ''),
	(36, 'mechanic', 0, 'apprentice', 'ช่างฝึกหัด', 900, '', ''),
	(37, 'mechanic', 1, 'assistan', 'ช่างผู้ช่วย', 950, '', ''),
	(38, 'mechanic', 2, 'professional', 'ช่างมืออาชีพ', 1000, '', ''),
	(39, 'mechanic', 4, 'deputychief', 'รองหัวหน้าช่าง', 1500, '', ''),
	(40, 'mechanic', 5, 'boss', 'หัวหน้างาน', 2000, '', ''),
	(43, 'offpolice', 0, 'recruit', 'Off - นักเรียนตำรวจ', 0, '', ''),
	(44, 'offpolice', 1, 'officer', 'Off - หมู', 0, '', ''),
	(45, 'offpolice', 2, 'officer1', 'Off - จ่า', 0, '', ''),
	(46, 'offpolice', 3, 'officer2', 'Off - ดาบ', 0, '', ''),
	(47, 'offpolice', 8, 'sergeant', 'Off - รองผู้กำกับ', 0, '', ''),
	(49, 'offambulance', 0, 'ambulance', 'Off - อาสาช่วยเหลือ', 0, '', ''),
	(50, 'offambulance', 1, 'doctor', 'Off - แพทย์ฝึกหัด', 0, '', ''),
	(51, 'offambulance', 3, 'head_doctor', 'Off - แพทย์ผู้เชี่ยวชาญ', 0, '', ''),
	(62, 'ambulance', 7, 'bosssub', 'รอง ผอ.', 8000, '', ''),
	(63, 'offpolice', 9, 'sergeant1', 'Off - ผู้กำกับ', 0, '', ''),
	(64, 'offpolice', 10, 'chef', 'Off - รองผู้บัญชาการ', 0, '', ''),
	(65, 'offpolice', 11, 'boss', 'Off - ผู้บัญชาการ', 0, '', ''),
	(66, 'offmechanic', 0, 'apprentice', 'Off - ช่างฝึกหัด', 0, '', ''),
	(67, 'offmechanic', 1, 'assistan', 'Off - ช่างผู้ช่วย', 0, '', ''),
	(68, 'offmechanic', 2, 'professional', 'Off - ช่างมืออาชีพ', 0, '', ''),
	(69, 'offmechanic', 4, 'deputychief', 'Off - รองหัวหน้าช่าง', 0, '', ''),
	(70, 'offmechanic', 5, 'supervisor', 'Off - หัวหน้างาน', 0, '', ''),
	(87, 'police', 11, 'boss', 'ผู้บัญชาการ', 8700, '', ''),
	(96, 'ambulance', 6, 'old_doctor', 'แพทย์อาวุโส', 7000, '', ''),
	(97, 'ambulance', 5, 'chiefp_doctor', 'แพทย์ชำนาญ', 6500, '', ''),
	(98, 'ambulance', 1, 'doctor', 'แพทย์ฝึกหัด', 3000, '', ''),
	(99, 'offambulance', 4, 'chief_doctor', 'Off - หัวหน้าแพทย์', 0, '', ''),
	(100, 'offambulance', 5, 'chiefp_doctor', 'Off - แพทย์ชำนาญ', 0, '', ''),
	(101, 'offambulance', 6, 'old_doctor', 'Off - แพทย์อาวุโส', 0, '', ''),
	(102, 'offambulance', 7, 'bosssub', 'Off - รอง ผอ.', 0, '', ''),
	(103, 'police', 2, 'officer1', 'จ่า', 2700, '', ''),
	(104, 'police', 3, 'officer2', 'ดาบ', 3300, '', ''),
	(105, 'police', 9, 'sergeant1', 'ผู้กำกับ', 7700, '', ''),
	(106, 'police', 10, 'chef', 'รองผู้บัญชาการ', 8200, '', ''),
	(128, 'police', 4, 'polofficer', 'หมวด', 3700, '', ''),
	(129, 'police', 7, 'proofficer', 'สารวัตร', 6700, '', ''),
	(131, 'offpolice', 7, 'offproofficer', 'Off - สารวัตร', 0, '', ''),
	(132, 'offpolice', 4, 'offpolofficer', 'Off - หมวด', 0, '', ''),
	(136, 'ambulance', 8, 'boss', 'ผอ. แพทย์', 8700, '', ''),
	(137, 'offambulance', 8, 'boss', 'Off - ผอ. แพทย์', 0, '', ''),
	(138, 'police', 5, 'polofficer1', 'ผู้กอง', 4200, '', ''),
	(139, 'police', 6, 'polofficer2', 'รองสารวัตร', 6200, '', ''),
	(140, 'offpolice', 5, 'offpolofficer1', 'Off - ผู้กอง', 0, '', ''),
	(141, 'offpolice', 6, 'offpolofficer2', 'Off - รองสารวัตร', 0, '', ''),
	(142, 'council', 1, 'council', 'สมาชิกสภาฝึกหัด', 1500, '', ''),
	(143, 'council', 2, 'council', 'สมาชิกรัฐสภา', 1700, '', ''),
	(144, 'council', 4, 'chef', 'คณะกรรมการสภาระดับสูง', 2200, '', ''),
	(145, 'mechanic', 3, 'expert', 'ช่างชำนาญการ', 1050, '', ''),
	(147, 'offcouncil', 0, 'council', 'Off - ทดลองงานสภา', 0, '', ''),
	(148, 'offcouncil', 1, 'chef', 'Off - สมาชิกสภาฝึกหัด', 0, '', ''),
	(149, 'offcouncil', 2, 'boss', 'Off - สมาชิกรัฐสภา', 0, '', ''),
	(150, 'council', 0, 'council', 'ทดลองงานสภา', 900, '', ''),
	(152, 'ambulance', 2, 'doctorpro', 'แพทย์ประจำ', 3500, '', ''),
	(153, 'offambulance', 2, 'doctorpro', 'off - แพทย์ประจำ', 0, '', ''),
	(154, 'council', 6, 'boss', 'ประธานสภา', 3200, '', ''),
	(155, 'council', 5, 'cboss', 'รองประธานสภา', 2700, '', ''),
	(156, 'council', 3, 'Hcouncil', 'คณะกรรมการสภา', 2000, '', ''),
	(157, 'offcouncil', 3, 'offcouncil', 'Off - คณะกรรมการสภา', 0, '', ''),
	(158, 'offcouncil', 4, 'offcouncil', 'Off - คณะกรรมการสภาระดับสูง', 0, '', ''),
	(159, 'offcouncil', 5, 'offcouncil', 'Off - รองประธานสภา', 0, '', ''),
	(160, 'offcouncil', 6, 'offcouncil', 'Off - ประธานสภา', 0, '', ''),
	(165, 'admin', 0, 'admin', 'ADMIN', 1000, '', '');
/*!40000 ALTER TABLE `job_grades` ENABLE KEYS */;

-- Dumping structure for table es_extended.licenses
CREATE TABLE IF NOT EXISTS `licenses` (
  `type` varchar(60) COLLATE utf8mb4_bin NOT NULL,
  `label` varchar(60) COLLATE utf8mb4_bin NOT NULL,
  PRIMARY KEY (`type`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=COMPACT;

-- Dumping data for table es_extended.licenses: ~4 rows (approximately)
/*!40000 ALTER TABLE `licenses` DISABLE KEYS */;
INSERT INTO `licenses` (`type`, `label`) VALUES
	('dmv', 'Code de la route'),
	('drive', 'Permis de conduire'),
	('drive_bike', 'Permis moto'),
	('drive_truck', 'Permis camion');
/*!40000 ALTER TABLE `licenses` ENABLE KEYS */;

-- Dumping structure for table es_extended.meeta_accessory_inventory
CREATE TABLE IF NOT EXISTS `meeta_accessory_inventory` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `owner` varchar(255) DEFAULT NULL,
  `label` varchar(255) DEFAULT 'NO_NAME',
  `skin` longtext DEFAULT NULL,
  `type` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  KEY `owner` (`owner`) USING BTREE,
  KEY `type` (`type`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=157 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC;

-- Dumping data for table es_extended.meeta_accessory_inventory: ~0 rows (approximately)
/*!40000 ALTER TABLE `meeta_accessory_inventory` DISABLE KEYS */;
/*!40000 ALTER TABLE `meeta_accessory_inventory` ENABLE KEYS */;

-- Dumping structure for table es_extended.owned_vehicles
CREATE TABLE IF NOT EXISTS `owned_vehicles` (
  `owner` varchar(22) COLLATE utf8mb3_bin NOT NULL,
  `plate` varchar(12) COLLATE utf8mb3_bin NOT NULL,
  `vehicle` longtext COLLATE utf8mb3_bin DEFAULT NULL,
  `type` varchar(20) COLLATE utf8mb3_bin NOT NULL DEFAULT 'car',
  `job` varchar(20) COLLATE utf8mb3_bin NOT NULL DEFAULT '',
  `stored` tinyint(1) NOT NULL DEFAULT 1,
  `health_vehicles` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `police` int(11) DEFAULT 0,
  `police_by` varchar(50) COLLATE utf8mb3_bin DEFAULT NULL,
  `time` timestamp NULL DEFAULT NULL,
  `time_hire` timestamp NOT NULL DEFAULT current_timestamp(),
  `day_hire` int(11) NOT NULL DEFAULT 0,
  `status_hire` tinyint(4) DEFAULT 0,
  `lasthouse` int(11) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

-- Dumping data for table es_extended.owned_vehicles: ~0 rows (approximately)
/*!40000 ALTER TABLE `owned_vehicles` DISABLE KEYS */;
/*!40000 ALTER TABLE `owned_vehicles` ENABLE KEYS */;

-- Dumping structure for table es_extended.phone_app_chat
CREATE TABLE IF NOT EXISTS `phone_app_chat` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `channel` varchar(20) NOT NULL,
  `message` varchar(255) NOT NULL,
  `time` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Dumping data for table es_extended.phone_app_chat: ~0 rows (approximately)
/*!40000 ALTER TABLE `phone_app_chat` DISABLE KEYS */;
/*!40000 ALTER TABLE `phone_app_chat` ENABLE KEYS */;

-- Dumping structure for table es_extended.phone_calls
CREATE TABLE IF NOT EXISTS `phone_calls` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `owner` varchar(10) NOT NULL,
  `num` varchar(10) NOT NULL,
  `incoming` int(11) NOT NULL,
  `time` timestamp NOT NULL DEFAULT current_timestamp(),
  `accepts` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Dumping data for table es_extended.phone_calls: ~0 rows (approximately)
/*!40000 ALTER TABLE `phone_calls` DISABLE KEYS */;
/*!40000 ALTER TABLE `phone_calls` ENABLE KEYS */;

-- Dumping structure for table es_extended.phone_messages
CREATE TABLE IF NOT EXISTS `phone_messages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `transmitter` varchar(10) NOT NULL,
  `receiver` varchar(10) NOT NULL,
  `message` varchar(255) NOT NULL DEFAULT '0',
  `time` timestamp NOT NULL DEFAULT current_timestamp(),
  `isRead` int(11) NOT NULL DEFAULT 0,
  `owner` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;

-- Dumping data for table es_extended.phone_messages: 0 rows
/*!40000 ALTER TABLE `phone_messages` DISABLE KEYS */;
/*!40000 ALTER TABLE `phone_messages` ENABLE KEYS */;

-- Dumping structure for table es_extended.phone_users_contacts
CREATE TABLE IF NOT EXISTS `phone_users_contacts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `identifier` varchar(60) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `number` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `display` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT '-1',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;

-- Dumping data for table es_extended.phone_users_contacts: 0 rows
/*!40000 ALTER TABLE `phone_users_contacts` DISABLE KEYS */;
/*!40000 ALTER TABLE `phone_users_contacts` ENABLE KEYS */;

-- Dumping structure for table es_extended.twitter_accounts
CREATE TABLE IF NOT EXISTS `twitter_accounts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(50) CHARACTER SET utf8mb3 NOT NULL DEFAULT '0',
  `password` varchar(50) COLLATE utf8mb4_bin NOT NULL DEFAULT '0',
  `avatar_url` varchar(255) COLLATE utf8mb4_bin DEFAULT NULL,
  `identifier` varchar(50) COLLATE utf8mb4_bin NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB AUTO_INCREMENT=18411 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

-- Dumping data for table es_extended.twitter_accounts: ~0 rows (approximately)
/*!40000 ALTER TABLE `twitter_accounts` DISABLE KEYS */;
/*!40000 ALTER TABLE `twitter_accounts` ENABLE KEYS */;

-- Dumping structure for table es_extended.twitter_likes
CREATE TABLE IF NOT EXISTS `twitter_likes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `authorId` int(11) DEFAULT NULL,
  `tweetId` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_twitter_likes_twitter_accounts` (`authorId`),
  KEY `FK_twitter_likes_twitter_tweets` (`tweetId`),
  CONSTRAINT `FK_twitter_likes_twitter_accounts` FOREIGN KEY (`authorId`) REFERENCES `twitter_accounts` (`id`),
  CONSTRAINT `FK_twitter_likes_twitter_tweets` FOREIGN KEY (`tweetId`) REFERENCES `twitter_tweets` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

-- Dumping data for table es_extended.twitter_likes: ~0 rows (approximately)
/*!40000 ALTER TABLE `twitter_likes` DISABLE KEYS */;
/*!40000 ALTER TABLE `twitter_likes` ENABLE KEYS */;

-- Dumping structure for table es_extended.twitter_tweets
CREATE TABLE IF NOT EXISTS `twitter_tweets` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `authorId` int(11) NOT NULL,
  `realUser` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `message` varchar(256) COLLATE utf8mb4_unicode_ci NOT NULL,
  `image` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT '',
  `time` timestamp NOT NULL DEFAULT current_timestamp(),
  `likes` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `FK_twitter_tweets_twitter_accounts` (`authorId`),
  CONSTRAINT `FK_twitter_tweets_twitter_accounts` FOREIGN KEY (`authorId`) REFERENCES `twitter_accounts` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=236598 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table es_extended.twitter_tweets: ~0 rows (approximately)
/*!40000 ALTER TABLE `twitter_tweets` DISABLE KEYS */;
/*!40000 ALTER TABLE `twitter_tweets` ENABLE KEYS */;

-- Dumping structure for table es_extended.users
CREATE TABLE IF NOT EXISTS `users` (
  `identifier` varchar(40) COLLATE utf8mb4_bin NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_bin NOT NULL DEFAULT '',
  `inventory` longtext COLLATE utf8mb4_bin DEFAULT NULL,
  `item_status` longtext COLLATE utf8mb4_bin DEFAULT NULL,
  `loadout` longtext COLLATE utf8mb4_bin DEFAULT NULL,
  `status` longtext COLLATE utf8mb4_bin DEFAULT NULL,
  `accounts` longtext COLLATE utf8mb4_bin DEFAULT NULL,
  `group` varchar(50) COLLATE utf8mb4_bin DEFAULT 'user',
  `skin` longtext COLLATE utf8mb4_bin DEFAULT NULL,
  `job` varchar(20) COLLATE utf8mb4_bin DEFAULT 'unemployed',
  `job_grade` int(11) DEFAULT 0,
  `position` varchar(255) COLLATE utf8mb4_bin DEFAULT '{"x":-269.4,"y":-955.3,"z":31.2,"heading":205.8}',
  `is_dead` tinyint(1) DEFAULT 0,
  `phone_number` varchar(10) COLLATE utf8mb4_bin DEFAULT NULL,
  `jail` int(11) NOT NULL DEFAULT 0,
  `tattoos` longtext COLLATE utf8mb4_bin DEFAULT NULL,
  `firstname` varchar(50) COLLATE utf8mb4_bin DEFAULT '',
  `lastname` varchar(50) COLLATE utf8mb4_bin DEFAULT '',
  `dateofbirth` varchar(25) COLLATE utf8mb4_bin DEFAULT '',
  `sex` varchar(10) COLLATE utf8mb4_bin DEFAULT '',
  `height` varchar(5) COLLATE utf8mb4_bin NOT NULL DEFAULT '',
  `gangname` varchar(16) COLLATE utf8mb4_bin NOT NULL DEFAULT 'none',
  `fish` int(11) NOT NULL DEFAULT 0,
  `gift` int(11) NOT NULL DEFAULT 0,
  `gift_vip` int(11) NOT NULL DEFAULT 0,
  `time` timestamp NULL DEFAULT current_timestamp(),
  `armour` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `health` tinyint(3) unsigned NOT NULL DEFAULT 200,
  `economy` int(11) NOT NULL DEFAULT 0,
  `illegal_work` int(11) NOT NULL DEFAULT 0,
  `metadata` longtext COLLATE utf8mb4_bin DEFAULT NULL,
  PRIMARY KEY (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

-- Dumping data for table es_extended.users: ~0 rows (approximately)
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
/*!40000 ALTER TABLE `users` ENABLE KEYS */;

-- Dumping structure for table es_extended.user_licenses
CREATE TABLE IF NOT EXISTS `user_licenses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `type` varchar(60) COLLATE utf8mb4_bin NOT NULL,
  `owner` varchar(60) COLLATE utf8mb4_bin NOT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=COMPACT;

-- Dumping data for table es_extended.user_licenses: ~0 rows (approximately)
/*!40000 ALTER TABLE `user_licenses` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_licenses` ENABLE KEYS */;

-- Dumping structure for table es_extended.vehicles
CREATE TABLE IF NOT EXISTS `vehicles` (
  `name` varchar(60) COLLATE utf8mb4_bin NOT NULL,
  `model` varchar(60) COLLATE utf8mb4_bin NOT NULL,
  `price` int(11) NOT NULL,
  `category` varchar(60) COLLATE utf8mb4_bin DEFAULT NULL,
  PRIMARY KEY (`model`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=COMPACT;

-- Dumping data for table es_extended.vehicles: ~131 rows (approximately)
/*!40000 ALTER TABLE `vehicles` DISABLE KEYS */;
INSERT INTO `vehicles` (`name`, `model`, `price`, `category`) VALUES
	('adder', 'adder', 990000, 'super'),
	('avarus', 'avarus', 35000, 'motorcycles'),
	('bagger', 'bagger', 65000, 'motorcycles'),
	('baller4', 'baller4', 125000, 'suvs'),
	('bestiagts', 'bestiagts', 235000, 'sports'),
	('bf400', 'bf400', 185000, 'motorcycles'),
	('bifta', 'bifta', 155000, 'offroad'),
	('bison3', 'bison3', 38000, 'vans'),
	('blista', 'blista', 3800, 'compacts'),
	('bmx', 'bmx', 200, 'bicycle'),
	('bobcatxl', 'bobcatxl', 32000, 'vans'),
	('bodhi2', 'bodhi2', 70000, 'offroad'),
	('brioso', 'brioso', 3500, 'compacts'),
	('brioso2', 'brioso2', 8200, 'compacts'),
	('btype2', 'btype2', 55000, 'sportsclassics'),
	('btype3', 'btype3', 55000, 'sportsclassics'),
	('calico', 'calico', 185000, 'sports'),
	('carbonizzare', 'carbonizzare', 215000, 'sports'),
	('carbonrs', 'carbonrs', 175000, 'motorcycles'),
	('casco', 'casco', 45000, 'sportsclassics'),
	('cheetah2', 'cheetah2', 975000, 'sportsclassics'),
	('chimera', 'chimera', 58000, 'motorcycles'),
	('comet3', 'comet3', 195000, 'sports'),
	('cruiser', 'cruiser', 180, 'bicycle'),
	('cypher', 'cypher', 185000, 'sports'),
	('daemon2', 'daemon2', 42000, 'motorcycles'),
	('defiler', 'defiler', 78500, 'motorcycles'),
	('diablous', 'diablous', 165000, 'motorcycles'),
	('diablous2', 'diablous2', 185000, 'motorcycles'),
	('dominator3', 'dominator3', 132000, 'sports'),
	('dominator7', 'dominator7', 180000, 'sports'),
	('double', 'double', 176800, 'motorcycles'),
	('drafter', 'drafter', 217000, 'sports'),
	('dubsta2', 'dubsta2', 120000, 'suvs'),
	('dubsta3', 'dubsta3', 150000, 'offroad'),
	('elegy', 'elegy', 186000, 'sports'),
	('elegy2', 'elegy2', 165000, 'sports'),
	('euros', 'euros', 210000, 'sports'),
	('everon', 'everon', 110000, 'offroad'),
	('f620', 'f620', 48000, 'coupes'),
	('faggio', 'faggio', 3500, 'motorcycles'),
	('faggio2', 'faggio2', 3800, 'motorcycles'),
	('faggio3', 'faggio3', 4100, 'motorcycles'),
	('feltzer2', 'feltzer2', 125000, 'sports'),
	('flashgt', 'flashgt', 195000, 'sports'),
	('freecrawler', 'freecrawler', 80000, 'offroad'),
	('furia', 'furia', 1870000, 'super'),
	('futo', 'futo', 95000, 'sports'),
	('futo2', 'futo2', 115000, 'sports'),
	('gb200', 'gb200', 135000, 'sports'),
	('gburrito', 'gburrito', 25000, 'vans'),
	('granger', 'granger', 95000, 'suvs'),
	('gt500', 'gt500', 80000, 'sportsclassics'),
	('hakuchou', 'hakuchou', 190000, 'motorcycles'),
	('hexer', 'hexer', 45000, 'motorcycles'),
	('issi2', 'issi2', 3750, 'compacts'),
	('issi3', 'issi3', 8000, 'compacts'),
	('issi7', 'issi7', 256000, 'sports'),
	('italigtb', 'italigtb', 1470000, 'super'),
	('italigtb2', 'italigtb2', 1480000, 'super'),
	('jester', 'jester', 189000, 'sports'),
	('kalahari', 'kalahari', 58000, 'offroad'),
	('kamacho', 'kamacho', 125000, 'offroad'),
	('kanjo', 'kanjo', 9950, 'compacts'),
	('komoda', 'komoda', 235000, 'sports'),
	('krieger', 'krieger', 2100000, 'super'),
	('kuruma', 'kuruma', 250000, 'sports'),
	('lectro', 'lectro', 100000, 'motorcycles'),
	('lynx', 'lynx', 175000, 'sports'),
	('mamba', 'mamba', 135000, 'muscle'),
	('massacro', 'massacro', 189000, 'sports'),
	('mesa3', 'mesa3', 72000, 'offroad'),
	('nightblade', 'nightblade', 75000, 'motorcycles'),
	('ninef', 'ninef', 235000, 'sports'),
	('ninef2', 'ninef2', 243000, 'sports'),
	('omnis', 'omnis', 156700, 'sports'),
	('panto', 'panto', 2000, 'compacts'),
	('patriot2', 'patriot2', 77000, 'suvs'),
	('pcj', 'pcj', 65000, 'motorcycles'),
	('penumbra2', 'penumbra2', 185000, 'sports'),
	('previon', 'previon', 175000, 'sports'),
	('ratloader', 'ratloader', 10000, 'muscle'),
	('ratloader2', 'ratloader2', 12000, 'muscle'),
	('reaper', 'reaper', 902000, 'super'),
	('rebel', 'rebel', 60000, 'offroad'),
	('rebla', 'rebla', 125000, 'suvs'),
	('remus', 'remus', 175000, 'sports'),
	('rt3000', 'rt3000', 195000, 'sports'),
	('ruffian', 'ruffian', 130000, 'motorcycles'),
	('sanchez2', 'sanchez2', 85000, 'motorcycles'),
	('sanctus', 'sanctus', 90000, 'motorcycles'),
	('sandking2', 'sandking2', 59000, 'offroad'),
	('sc1', 'sc1', 990000, 'super'),
	('schlagen', 'schlagen', 280000, 'sports'),
	('scorcher', 'scorcher', 200, 'bicycle'),
	('sentinel2', 'sentinel2', 62000, 'coupes'),
	('sentinel3', 'sentinel3', 95000, 'sports'),
	('seven70', 'seven70', 200000, 'sports'),
	('slamvan3', 'slamvan3', 13000, 'muscle'),
	('sovereign', 'sovereign', 65000, 'motorcycles'),
	('specter', 'specter', 156000, 'sports'),
	('speedo2', 'speedo2', 24500, 'vans'),
	('stafford', 'stafford', 25000, 'sedans'),
	('stretch', 'stretch', 150000, 'sedans'),
	('stryder', 'stryder', 17500, 'motorcycles'),
	('sugoi', 'sugoi', 265000, 'sports'),
	('sultan', 'sultan', 170000, 'sports'),
	('sultan2', 'sultan2', 190000, 'sports'),
	('sultanrs', 'sultanrs', 160000, 'sports'),
	('surano', 'surano', 170000, 'sports'),
	('surfer', 'surfer', 23500, 'vans'),
	('t20', 't20', 2350000, 'super'),
	('tailgater2', 'tailgater2', 275000, 'sports'),
	('taipan', 'taipan', 995000, 'super'),
	('thrax', 'thrax', 1900000, 'super'),
	('thrust', 'thrust', 73500, 'motorcycles'),
	('toros', 'toros', 370000, 'suvs'),
	('tribike', 'tribike', 150, 'bicycle'),
	('vagrant', 'vagrant', 185000, 'offroad'),
	('veto', 'veto', 13500, 'motorcycles'),
	('veto2', 'veto2', 17500, 'motorcycles'),
	('vstr', 'vstr', 138600, 'sports'),
	('weevil', 'weevil', 7800, 'compacts'),
	('windsor', 'windsor', 43500, 'coupes'),
	('windsor2', 'windsor2', 43500, 'coupes'),
	('xls', 'xls', 105000, 'suvs'),
	('yosemite', 'yosemite', 14500, 'muscle'),
	('zombiea', 'zombiea', 50000, 'motorcycles'),
	('zombieb', 'zombieb', 52000, 'motorcycles'),
	('zr350', 'zr350', 175000, 'sports'),
	('ztype', 'ztype', 75000, 'sportsclassics');
/*!40000 ALTER TABLE `vehicles` ENABLE KEYS */;

-- Dumping structure for table es_extended.vehicles_for_sale
CREATE TABLE IF NOT EXISTS `vehicles_for_sale` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `seller` varchar(50) NOT NULL,
  `vehicleProps` longtext NOT NULL,
  `price` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=119 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=COMPACT;

-- Dumping data for table es_extended.vehicles_for_sale: ~0 rows (approximately)
/*!40000 ALTER TABLE `vehicles_for_sale` DISABLE KEYS */;
/*!40000 ALTER TABLE `vehicles_for_sale` ENABLE KEYS */;

-- Dumping structure for table es_extended.vehicle_categories
CREATE TABLE IF NOT EXISTS `vehicle_categories` (
  `name` varchar(60) COLLATE utf8mb4_bin NOT NULL,
  `label` varchar(60) COLLATE utf8mb4_bin NOT NULL,
  PRIMARY KEY (`name`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=COMPACT;

-- Dumping data for table es_extended.vehicle_categories: ~13 rows (approximately)
/*!40000 ALTER TABLE `vehicle_categories` DISABLE KEYS */;
INSERT INTO `vehicle_categories` (`name`, `label`) VALUES
	('bicycle', 'Bicycle'),
	('compacts', 'Compacts [5KG.]'),
	('coupes', 'Coupes [5KG.]'),
	('gacha', 'Gachapon'),
	('motorcycles', 'Motorcycles'),
	('muscle', 'Muscle [20KG.]'),
	('offroad', 'Off Road [60KG.]'),
	('sedans', 'Sedans [5KG.]'),
	('sports', 'Sports'),
	('sportsclassics', 'Sports Classics'),
	('super', 'Supercar'),
	('suvs', 'SUVs [40KG.]'),
	('vans', 'Vans [40KG.]');
/*!40000 ALTER TABLE `vehicle_categories` ENABLE KEYS */;

-- Dumping structure for table es_extended.vehicle_sold
CREATE TABLE IF NOT EXISTS `vehicle_sold` (
  `client` varchar(50) COLLATE utf8mb4_bin NOT NULL,
  `model` varchar(50) COLLATE utf8mb4_bin NOT NULL,
  `plate` varchar(50) COLLATE utf8mb4_bin NOT NULL,
  `soldby` varchar(50) COLLATE utf8mb4_bin NOT NULL,
  `date` varchar(50) COLLATE utf8mb4_bin NOT NULL,
  PRIMARY KEY (`plate`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=COMPACT;

-- Dumping data for table es_extended.vehicle_sold: ~0 rows (approximately)
/*!40000 ALTER TABLE `vehicle_sold` DISABLE KEYS */;
/*!40000 ALTER TABLE `vehicle_sold` ENABLE KEYS */;

-- Dumping structure for table es_extended.vehicle_soldout
CREATE TABLE IF NOT EXISTS `vehicle_soldout` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `owner` varchar(50) NOT NULL,
  `vehicle` longtext NOT NULL,
  `plate` varchar(50) NOT NULL,
  `date` varchar(50) NOT NULL,
  `price` int(11) NOT NULL,
  PRIMARY KEY (`id`,`plate`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 ROW_FORMAT=COMPACT;

-- Dumping data for table es_extended.vehicle_soldout: ~0 rows (approximately)
/*!40000 ALTER TABLE `vehicle_soldout` DISABLE KEYS */;
/*!40000 ALTER TABLE `vehicle_soldout` ENABLE KEYS */;

-- Dumping structure for table es_extended.yellowpages_posts
CREATE TABLE IF NOT EXISTS `yellowpages_posts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `authorId` int(11) NOT NULL,
  `realUser` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `message` varchar(256) COLLATE utf8mb4_unicode_ci NOT NULL,
  `image` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `time` timestamp NOT NULL DEFAULT current_timestamp(),
  `phone` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `likes` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `FK_yellowpages_posts_twitter_accounts` (`authorId`),
  CONSTRAINT `FK_yellowpages_posts_twitter_accounts` FOREIGN KEY (`authorId`) REFERENCES `twitter_accounts` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=225 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table es_extended.yellowpages_posts: ~0 rows (approximately)
/*!40000 ALTER TABLE `yellowpages_posts` DISABLE KEYS */;
/*!40000 ALTER TABLE `yellowpages_posts` ENABLE KEYS */;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
