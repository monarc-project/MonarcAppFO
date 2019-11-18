-- MySQL dump 10.16  Distrib 10.1.41-MariaDB, for debian-linux-gnu (x86_64)
--
-- Host: localhost    Database: monarc_common
-- ------------------------------------------------------
-- Server version	10.1.41-MariaDB-0ubuntu0.18.04.1

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `amvs`
--

DROP TABLE IF EXISTS `amvs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `amvs` (
  `uuid` char(36) NOT NULL,
  `vulnerability_id` char(36) NOT NULL,
  `threat_id` char(36) NOT NULL,
  `asset_id` char(36) NOT NULL,
  `anr_id` int(11) unsigned DEFAULT NULL,
  `position` int(11) DEFAULT '1',
  `status` int(11) DEFAULT '1',
  `creator` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updater` varchar(255) DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`uuid`),
  KEY `anr_id` (`anr_id`),
  KEY `asset_id` (`asset_id`),
  KEY `threat_id` (`threat_id`),
  KEY `vulnerability_id` (`vulnerability_id`),
  KEY `uuid` (`uuid`),
  CONSTRAINT `amvs_ibfk_1` FOREIGN KEY (`anr_id`) REFERENCES `anrs` (`id`) ON DELETE CASCADE,
  CONSTRAINT `amvs_ibfk_5` FOREIGN KEY (`asset_id`) REFERENCES `assets` (`uuid`) ON DELETE CASCADE,
  CONSTRAINT `amvs_ibfk_6` FOREIGN KEY (`threat_id`) REFERENCES `threats` (`uuid`) ON DELETE CASCADE,
  CONSTRAINT `amvs_ibfk_7` FOREIGN KEY (`vulnerability_id`) REFERENCES `vulnerabilities` (`uuid`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `anrs`
--

DROP TABLE IF EXISTS `anrs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `anrs` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `label1` varchar(255) DEFAULT NULL,
  `label2` varchar(255) DEFAULT NULL,
  `label3` varchar(255) DEFAULT NULL,
  `label4` varchar(255) DEFAULT NULL,
  `description1` text,
  `description2` text,
  `description3` text,
  `description4` text,
  `seuil1` int(11) DEFAULT '0',
  `seuil2` int(11) DEFAULT '0',
  `seuil_rolf1` int(11) DEFAULT '0',
  `seuil_rolf2` int(11) DEFAULT '0',
  `seuil_traitement` int(11) DEFAULT '0',
  `init_anr_context` tinyint(4) DEFAULT '0',
  `init_eval_context` tinyint(4) DEFAULT '0',
  `init_risk_context` tinyint(4) DEFAULT '0',
  `init_def_context` tinyint(4) DEFAULT '0',
  `init_livrable_done` tinyint(4) DEFAULT '0',
  `model_impacts` tinyint(4) DEFAULT '0',
  `model_summary` tinyint(4) DEFAULT '0',
  `model_livrable_done` tinyint(4) DEFAULT '0',
  `eval_risks` tinyint(4) DEFAULT '0',
  `eval_plan_risks` tinyint(4) DEFAULT '0',
  `eval_livrable_done` tinyint(4) DEFAULT '0',
  `manage_risks` tinyint(4) DEFAULT '0',
  `context_ana_risk` text,
  `context_gest_risk` text,
  `synth_threat` text,
  `synth_act` text,
  `cache_model_show_rolf_brut` tinyint(4) DEFAULT '0',
  `show_rolf_brut` tinyint(4) DEFAULT '0',
  `creator` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updater` varchar(255) DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=44 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `anrs_objects`
--

DROP TABLE IF EXISTS `anrs_objects`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `anrs_objects` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `object_id` char(36) NOT NULL,
  `anr_id` int(11) unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `anr_id` (`anr_id`),
  KEY `object_id` (`object_id`),
  CONSTRAINT `anrs_objects_ibfk_1` FOREIGN KEY (`anr_id`) REFERENCES `anrs` (`id`) ON DELETE CASCADE,
  CONSTRAINT `anrs_objects_ibfk_2` FOREIGN KEY (`object_id`) REFERENCES `objects` (`uuid`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=1535 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `anrs_objects_categories`
--

DROP TABLE IF EXISTS `anrs_objects_categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `anrs_objects_categories` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `anr_id` int(11) unsigned DEFAULT NULL,
  `object_category_id` int(11) unsigned DEFAULT NULL,
  `position` int(11) DEFAULT '1',
  `creator` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updater` varchar(255) DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `anr_id` (`anr_id`),
  KEY `object_category_id` (`object_category_id`),
  CONSTRAINT `anrs_objects_categories_ibfk_1` FOREIGN KEY (`anr_id`) REFERENCES `anrs` (`id`) ON DELETE CASCADE,
  CONSTRAINT `anrs_objects_categories_ibfk_2` FOREIGN KEY (`object_category_id`) REFERENCES `objects_categories` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=69 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `assets`
--

DROP TABLE IF EXISTS `assets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `assets` (
  `uuid` char(36) NOT NULL,
  `anr_id` int(11) unsigned DEFAULT '0',
  `mode` tinyint(4) DEFAULT '1',
  `type` tinyint(4) DEFAULT '1',
  `code` char(100) DEFAULT NULL,
  `label1` varchar(255) DEFAULT NULL,
  `label2` varchar(255) DEFAULT NULL,
  `label3` varchar(255) DEFAULT NULL,
  `label4` varchar(255) DEFAULT NULL,
  `description1` text,
  `description2` text,
  `description3` text,
  `description4` text,
  `status` tinyint(4) DEFAULT '1',
  `creator` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updater` varchar(255) DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`uuid`),
  KEY `anr_id` (`anr_id`,`code`),
  KEY `anr_id_2` (`anr_id`),
  KEY `uuid` (`uuid`),
  CONSTRAINT `assets_ibfk_1` FOREIGN KEY (`anr_id`) REFERENCES `anrs` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `assets_models`
--

DROP TABLE IF EXISTS `assets_models`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `assets_models` (
  `model_id` int(11) unsigned NOT NULL,
  `asset_id` char(36) NOT NULL,
  PRIMARY KEY (`asset_id`,`model_id`),
  KEY `model_id` (`model_id`),
  CONSTRAINT `assets_models_ibfk_2` FOREIGN KEY (`model_id`) REFERENCES `models` (`id`),
  CONSTRAINT `assets_models_ibfk_4` FOREIGN KEY (`model_id`) REFERENCES `models` (`id`) ON DELETE CASCADE,
  CONSTRAINT `assets_models_ibfk_5` FOREIGN KEY (`asset_id`) REFERENCES `assets` (`uuid`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `guides`
--

DROP TABLE IF EXISTS `guides`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `guides` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `anr_id` int(11) unsigned DEFAULT NULL,
  `type` tinyint(4) NOT NULL,
  `description1` text,
  `description2` text,
  `description3` text,
  `description4` text,
  `is_with_items` tinyint(4) NOT NULL,
  `creator` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updater` varchar(255) DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `anr_id` (`anr_id`),
  CONSTRAINT `guides_ibfk_1` FOREIGN KEY (`anr_id`) REFERENCES `anrs` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `guides_items`
--

DROP TABLE IF EXISTS `guides_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `guides_items` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `anr_id` int(11) unsigned DEFAULT NULL,
  `guide_id` int(11) unsigned DEFAULT NULL,
  `description1` text NOT NULL,
  `description2` text NOT NULL,
  `description3` text NOT NULL,
  `description4` text NOT NULL,
  `position` int(11) NOT NULL DEFAULT '0',
  `creator` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updater` varchar(255) DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `anr_id` (`anr_id`),
  KEY `guide_id` (`guide_id`),
  KEY `position` (`position`),
  CONSTRAINT `guides_items_ibfk_1` FOREIGN KEY (`anr_id`) REFERENCES `anrs` (`id`) ON DELETE CASCADE,
  CONSTRAINT `guides_items_ibfk_2` FOREIGN KEY (`guide_id`) REFERENCES `guides` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `historicals`
--

DROP TABLE IF EXISTS `historicals`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `historicals` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `source_id` int(11) unsigned DEFAULT NULL,
  `type` varchar(255) DEFAULT NULL,
  `action` varchar(255) DEFAULT NULL,
  `label1` varchar(255) DEFAULT NULL,
  `label2` varchar(255) DEFAULT NULL,
  `label3` varchar(255) DEFAULT NULL,
  `label4` varchar(255) DEFAULT NULL,
  `details` text,
  `creator` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updater` varchar(255) DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `instances`
--

DROP TABLE IF EXISTS `instances`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `instances` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `object_id` char(36) DEFAULT NULL,
  `asset_id` char(36) NOT NULL,
  `anr_id` int(11) unsigned DEFAULT NULL,
  `root_id` int(11) unsigned DEFAULT NULL,
  `parent_id` int(11) unsigned DEFAULT NULL,
  `name1` varchar(255) DEFAULT NULL,
  `name2` varchar(255) DEFAULT NULL,
  `name3` varchar(255) DEFAULT NULL,
  `name4` varchar(255) DEFAULT NULL,
  `label1` varchar(255) DEFAULT NULL,
  `label2` varchar(255) DEFAULT NULL,
  `label3` varchar(255) DEFAULT NULL,
  `label4` varchar(255) DEFAULT NULL,
  `disponibility` decimal(11,2) DEFAULT '0.00',
  `level` tinyint(4) DEFAULT '1',
  `asset_type` tinyint(4) DEFAULT '3',
  `exportable` tinyint(4) DEFAULT '1',
  `creator` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updater` varchar(255) DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `position` int(11) DEFAULT '0',
  `c` int(11) DEFAULT '-1',
  `i` int(11) DEFAULT '-1',
  `d` int(11) DEFAULT '-1',
  `ch` tinyint(4) DEFAULT '0',
  `ih` tinyint(4) DEFAULT '0',
  `dh` tinyint(4) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `anr_id` (`anr_id`),
  KEY `root_id` (`root_id`),
  KEY `parent_id` (`parent_id`),
  KEY `asset_id` (`asset_id`),
  KEY `object_id` (`object_id`),
  CONSTRAINT `instances_ibfk_1` FOREIGN KEY (`anr_id`) REFERENCES `anrs` (`id`) ON DELETE CASCADE,
  CONSTRAINT `instances_ibfk_4` FOREIGN KEY (`root_id`) REFERENCES `instances` (`id`) ON DELETE CASCADE,
  CONSTRAINT `instances_ibfk_5` FOREIGN KEY (`parent_id`) REFERENCES `instances` (`id`) ON DELETE CASCADE,
  CONSTRAINT `instances_ibfk_6` FOREIGN KEY (`asset_id`) REFERENCES `assets` (`uuid`) ON DELETE CASCADE,
  CONSTRAINT `instances_ibfk_7` FOREIGN KEY (`object_id`) REFERENCES `objects` (`uuid`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `instances_consequences`
--

DROP TABLE IF EXISTS `instances_consequences`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `instances_consequences` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `object_id` char(36) DEFAULT NULL,
  `anr_id` int(11) unsigned DEFAULT '0',
  `instance_id` int(11) unsigned DEFAULT '0',
  `scale_impact_type_id` int(11) unsigned DEFAULT '0',
  `is_hidden` tinyint(4) DEFAULT '0',
  `locally_touched` tinyint(4) DEFAULT '0',
  `c` tinyint(4) DEFAULT '-1',
  `i` tinyint(4) DEFAULT '-1',
  `d` tinyint(4) DEFAULT '-1',
  `creator` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updater` varchar(255) DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `anr_id` (`anr_id`),
  KEY `instance_id` (`instance_id`),
  KEY `scale_impact_type_id` (`scale_impact_type_id`),
  CONSTRAINT `instances_consequences_ibfk_1` FOREIGN KEY (`anr_id`) REFERENCES `anrs` (`id`) ON DELETE CASCADE,
  CONSTRAINT `instances_consequences_ibfk_2` FOREIGN KEY (`instance_id`) REFERENCES `instances` (`id`) ON DELETE CASCADE,
  CONSTRAINT `instances_consequences_ibfk_4` FOREIGN KEY (`scale_impact_type_id`) REFERENCES `scales_impact_types` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `instances_risks`
--

DROP TABLE IF EXISTS `instances_risks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `instances_risks` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `amv_id` char(36) DEFAULT NULL,
  `vulnerability_id` char(36) NOT NULL,
  `threat_id` char(36) NOT NULL,
  `asset_id` char(36) NOT NULL,
  `anr_id` int(11) unsigned DEFAULT NULL,
  `specific` tinyint(4) DEFAULT '0',
  `mh` tinyint(4) NOT NULL DEFAULT '1',
  `threat_rate` int(11) NOT NULL DEFAULT '-1',
  `vulnerability_rate` int(11) NOT NULL DEFAULT '-1',
  `kind_of_measure` tinyint(4) DEFAULT '5',
  `reduction_amount` int(3) DEFAULT '0',
  `comment` text,
  `comment_after` text,
  `risk_c` int(11) DEFAULT '-1',
  `risk_i` int(11) DEFAULT '-1',
  `risk_d` int(11) DEFAULT '-1',
  `cache_max_risk` int(11) DEFAULT '-1',
  `cache_targeted_risk` int(11) DEFAULT '-1',
  `creator` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updater` varchar(255) DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `instance_id` int(11) unsigned DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `anr_id` (`anr_id`),
  KEY `instance_id` (`instance_id`),
  KEY `asset_id` (`asset_id`),
  KEY `threat_id` (`threat_id`),
  KEY `vulnerability_id` (`vulnerability_id`),
  KEY `amv_id` (`amv_id`),
  CONSTRAINT `instances_risks_ibfk_1` FOREIGN KEY (`anr_id`) REFERENCES `anrs` (`id`) ON DELETE CASCADE,
  CONSTRAINT `instances_risks_ibfk_10` FOREIGN KEY (`vulnerability_id`) REFERENCES `vulnerabilities` (`uuid`) ON DELETE CASCADE,
  CONSTRAINT `instances_risks_ibfk_11` FOREIGN KEY (`amv_id`) REFERENCES `amvs` (`uuid`) ON DELETE CASCADE,
  CONSTRAINT `instances_risks_ibfk_7` FOREIGN KEY (`instance_id`) REFERENCES `instances` (`id`) ON DELETE CASCADE,
  CONSTRAINT `instances_risks_ibfk_8` FOREIGN KEY (`asset_id`) REFERENCES `assets` (`uuid`) ON DELETE CASCADE,
  CONSTRAINT `instances_risks_ibfk_9` FOREIGN KEY (`threat_id`) REFERENCES `threats` (`uuid`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `instances_risks_op`
--

DROP TABLE IF EXISTS `instances_risks_op`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `instances_risks_op` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `object_id` char(36) DEFAULT NULL,
  `anr_id` int(11) unsigned DEFAULT NULL,
  `instance_id` int(11) unsigned DEFAULT NULL,
  `rolf_risk_id` int(11) unsigned DEFAULT NULL,
  `risk_cache_code` char(100) DEFAULT NULL,
  `risk_cache_label1` varchar(255) DEFAULT NULL,
  `risk_cache_label2` varchar(255) DEFAULT NULL,
  `risk_cache_label3` varchar(255) DEFAULT NULL,
  `risk_cache_label4` varchar(255) DEFAULT NULL,
  `risk_cache_description1` text,
  `risk_cache_description2` text,
  `risk_cache_description3` text,
  `risk_cache_description4` text,
  `brut_prob` int(11) DEFAULT '-1',
  `brut_r` int(11) DEFAULT '-1',
  `brut_o` int(11) DEFAULT '-1',
  `brut_l` int(11) DEFAULT '-1',
  `brut_f` int(11) DEFAULT '-1',
  `cache_brut_risk` int(11) DEFAULT '-1',
  `net_prob` int(11) DEFAULT '-1',
  `net_r` int(11) DEFAULT '-1',
  `net_o` int(11) DEFAULT '-1',
  `net_l` int(11) DEFAULT '-1',
  `net_f` int(11) DEFAULT '-1',
  `cache_net_risk` int(11) DEFAULT '-1',
  `targeted_prob` int(11) DEFAULT '-1',
  `targeted_r` int(11) DEFAULT '-1',
  `targeted_o` int(11) DEFAULT '-1',
  `targeted_l` int(11) DEFAULT '-1',
  `targeted_f` int(11) DEFAULT '-1',
  `cache_targeted_risk` int(11) DEFAULT '-1',
  `kind_of_measure` tinyint(4) DEFAULT '5',
  `comment` text,
  `mitigation` text,
  `specific` tinyint(4) DEFAULT '0',
  `creator` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updater` varchar(255) DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `net_p` int(11) DEFAULT '-1',
  `targeted_p` int(11) DEFAULT '-1',
  `brut_p` int(11) DEFAULT '-1',
  PRIMARY KEY (`id`),
  KEY `anr_id` (`anr_id`),
  KEY `instance_id` (`instance_id`),
  KEY `rolf_risk_id` (`rolf_risk_id`),
  KEY `object_id` (`object_id`),
  CONSTRAINT `instances_risks_op_ibfk_1` FOREIGN KEY (`anr_id`) REFERENCES `anrs` (`id`) ON DELETE CASCADE,
  CONSTRAINT `instances_risks_op_ibfk_2` FOREIGN KEY (`instance_id`) REFERENCES `instances` (`id`) ON DELETE CASCADE,
  CONSTRAINT `instances_risks_op_ibfk_3` FOREIGN KEY (`rolf_risk_id`) REFERENCES `rolf_risks` (`id`) ON DELETE SET NULL,
  CONSTRAINT `instances_risks_op_ibfk_4` FOREIGN KEY (`object_id`) REFERENCES `objects` (`uuid`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `measures`
--

DROP TABLE IF EXISTS `measures`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `measures` (
  `uuid` char(36) NOT NULL,
  `soacategory_id` int(11) unsigned DEFAULT NULL,
  `referential_uuid` char(36) NOT NULL,
  `code` varchar(255) DEFAULT NULL,
  `label1` text,
  `label2` text,
  `label3` text,
  `label4` text,
  `status` tinyint(4) DEFAULT '1',
  `creator` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updater` varchar(255) DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`uuid`),
  UNIQUE KEY `referential_uuid` (`referential_uuid`,`code`),
  KEY `soacategory_id` (`soacategory_id`),
  KEY `uuid` (`uuid`),
  CONSTRAINT `measures_ibfk_2` FOREIGN KEY (`referential_uuid`) REFERENCES `referentials` (`uuid`) ON DELETE CASCADE,
  CONSTRAINT `measures_ibfk_3` FOREIGN KEY (`soacategory_id`) REFERENCES `soacategory` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `measures_amvs`
--

DROP TABLE IF EXISTS `measures_amvs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `measures_amvs` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `measure_id` char(36) NOT NULL,
  `creator` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updater` varchar(255) DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `amv_id` char(36) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `measure_id` (`measure_id`),
  KEY `amv_id` (`amv_id`),
  CONSTRAINT `measures_amvs_ibfk_2` FOREIGN KEY (`measure_id`) REFERENCES `measures` (`uuid`) ON DELETE CASCADE,
  CONSTRAINT `measures_amvs_ibfk_3` FOREIGN KEY (`amv_id`) REFERENCES `amvs` (`uuid`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=39861 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `measures_measures`
--

DROP TABLE IF EXISTS `measures_measures`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `measures_measures` (
  `child_id` char(36) NOT NULL,
  `father_id` char(36) NOT NULL,
  `creator` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updater` varchar(255) DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`child_id`,`father_id`),
  KEY `father_id` (`father_id`),
  CONSTRAINT `measures_measures_ibfk_1` FOREIGN KEY (`father_id`) REFERENCES `measures` (`uuid`) ON DELETE CASCADE,
  CONSTRAINT `measures_measures_ibfk_2` FOREIGN KEY (`child_id`) REFERENCES `measures` (`uuid`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `measures_rolf_risks`
--

DROP TABLE IF EXISTS `measures_rolf_risks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `measures_rolf_risks` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `anr_id` int(11) unsigned DEFAULT NULL,
  `rolf_risk_id` int(11) unsigned DEFAULT NULL,
  `measure_id` char(36) NOT NULL,
  `creator` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updater` varchar(255) DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `anr_id` (`anr_id`),
  KEY `rolf_risk_id` (`rolf_risk_id`),
  KEY `measure_id` (`measure_id`),
  CONSTRAINT `measures_rolf_risks_ibfk_1` FOREIGN KEY (`anr_id`) REFERENCES `anrs` (`id`) ON DELETE CASCADE,
  CONSTRAINT `measures_rolf_risks_ibfk_2` FOREIGN KEY (`rolf_risk_id`) REFERENCES `rolf_risks` (`id`) ON DELETE CASCADE,
  CONSTRAINT `measures_rolf_risks_ibfk_3` FOREIGN KEY (`measure_id`) REFERENCES `measures` (`uuid`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `models`
--

DROP TABLE IF EXISTS `models`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `models` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `anr_id` int(11) unsigned DEFAULT NULL,
  `label1` varchar(255) DEFAULT NULL,
  `label2` varchar(255) DEFAULT NULL,
  `label3` varchar(255) DEFAULT NULL,
  `label4` varchar(255) DEFAULT NULL,
  `description1` text,
  `description2` text,
  `description3` text,
  `description4` text,
  `status` tinyint(4) DEFAULT '1',
  `is_scales_updatable` tinyint(4) DEFAULT '1',
  `is_default` tinyint(4) DEFAULT '0',
  `is_deleted` tinyint(4) DEFAULT '0',
  `is_generic` tinyint(4) DEFAULT '0',
  `is_regulator` tinyint(4) DEFAULT '0',
  `show_rolf_brut` tinyint(4) DEFAULT '0',
  `creator` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updater` varchar(255) DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `anr_id` (`anr_id`),
  CONSTRAINT `models_ibfk_1` FOREIGN KEY (`anr_id`) REFERENCES `anrs` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=42 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `objects`
--

DROP TABLE IF EXISTS `objects`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `objects` (
  `uuid` char(36) NOT NULL,
  `asset_id` char(36) NOT NULL,
  `object_category_id` int(11) unsigned DEFAULT NULL,
  `rolf_tag_id` int(11) unsigned DEFAULT NULL,
  `mode` tinyint(4) DEFAULT '1',
  `scope` tinyint(4) DEFAULT '1',
  `name1` varchar(255) DEFAULT NULL,
  `name2` varchar(255) DEFAULT NULL,
  `name3` varchar(255) DEFAULT NULL,
  `name4` varchar(255) DEFAULT NULL,
  `label1` varchar(255) DEFAULT NULL,
  `label2` varchar(255) DEFAULT NULL,
  `label3` varchar(255) DEFAULT NULL,
  `label4` varchar(255) DEFAULT NULL,
  `disponibility` decimal(11,5) DEFAULT '0.00000',
  `position` int(11) DEFAULT '1',
  `token_import` char(13) DEFAULT NULL,
  `original_name` varchar(255) DEFAULT NULL,
  `creator` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updater` varchar(255) DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `anr_id` int(11) unsigned DEFAULT NULL,
  PRIMARY KEY (`uuid`),
  KEY `object_category_id` (`object_category_id`),
  KEY `rolf_tag_id` (`rolf_tag_id`),
  KEY `anr_id` (`anr_id`),
  KEY `asset_id` (`asset_id`),
  KEY `uuid` (`uuid`),
  CONSTRAINT `objects_ibfk_2` FOREIGN KEY (`object_category_id`) REFERENCES `objects_categories` (`id`) ON DELETE SET NULL,
  CONSTRAINT `objects_ibfk_5` FOREIGN KEY (`rolf_tag_id`) REFERENCES `rolf_tags` (`id`) ON DELETE SET NULL,
  CONSTRAINT `objects_ibfk_7` FOREIGN KEY (`anr_id`) REFERENCES `anrs` (`id`) ON DELETE CASCADE,
  CONSTRAINT `objects_ibfk_8` FOREIGN KEY (`asset_id`) REFERENCES `assets` (`uuid`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `objects_categories`
--

DROP TABLE IF EXISTS `objects_categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `objects_categories` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `anr_id` int(11) unsigned DEFAULT NULL,
  `root_id` int(11) unsigned DEFAULT NULL,
  `parent_id` int(11) unsigned DEFAULT NULL,
  `label1` text,
  `label2` text,
  `label3` text,
  `label4` text,
  `position` int(11) DEFAULT '1',
  `creator` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updater` varchar(255) DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `root_id` (`root_id`),
  KEY `parent_id` (`parent_id`),
  KEY `position` (`position`),
  KEY `anr_id` (`anr_id`),
  CONSTRAINT `objects_categories_ibfk_2` FOREIGN KEY (`root_id`) REFERENCES `objects_categories` (`id`) ON DELETE SET NULL,
  CONSTRAINT `objects_categories_ibfk_3` FOREIGN KEY (`parent_id`) REFERENCES `objects_categories` (`id`) ON DELETE SET NULL,
  CONSTRAINT `objects_categories_ibfk_4` FOREIGN KEY (`anr_id`) REFERENCES `anrs` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=186 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `objects_objects`
--

DROP TABLE IF EXISTS `objects_objects`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `objects_objects` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `child_id` char(36) DEFAULT NULL,
  `father_id` char(36) DEFAULT NULL,
  `anr_id` int(11) unsigned DEFAULT NULL,
  `creator` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updater` varchar(255) DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `position` int(11) unsigned NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`),
  KEY `anr_id` (`anr_id`),
  KEY `father_id` (`father_id`),
  KEY `child_id` (`child_id`),
  CONSTRAINT `objects_objects_ibfk_1` FOREIGN KEY (`anr_id`) REFERENCES `anrs` (`id`) ON DELETE CASCADE,
  CONSTRAINT `objects_objects_ibfk_2` FOREIGN KEY (`father_id`) REFERENCES `objects` (`uuid`) ON DELETE CASCADE,
  CONSTRAINT `objects_objects_ibfk_3` FOREIGN KEY (`child_id`) REFERENCES `objects` (`uuid`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=665 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `phinxlog`
--

DROP TABLE IF EXISTS `phinxlog`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `phinxlog` (
  `version` bigint(20) NOT NULL,
  `migration_name` varchar(100) DEFAULT NULL,
  `start_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `end_time` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `breakpoint` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `questions`
--

DROP TABLE IF EXISTS `questions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `questions` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `label1` varchar(255) DEFAULT NULL,
  `label2` varchar(255) DEFAULT NULL,
  `label3` varchar(255) DEFAULT NULL,
  `label4` varchar(255) DEFAULT NULL,
  `position` int(11) unsigned DEFAULT NULL,
  `type` tinyint(4) NOT NULL DEFAULT '0',
  `multichoice` tinyint(4) NOT NULL DEFAULT '0',
  `creator` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updater` varchar(255) DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=79 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `questions_choices`
--

DROP TABLE IF EXISTS `questions_choices`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `questions_choices` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `question_id` int(11) unsigned DEFAULT NULL,
  `label1` varchar(255) DEFAULT NULL,
  `label2` varchar(255) DEFAULT NULL,
  `label3` varchar(255) DEFAULT NULL,
  `label4` varchar(255) DEFAULT NULL,
  `position` int(11) unsigned DEFAULT NULL,
  `type` tinyint(4) NOT NULL DEFAULT '0',
  `multichoice` tinyint(4) NOT NULL DEFAULT '0',
  `creator` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updater` varchar(255) DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `question_id` (`question_id`),
  CONSTRAINT `questions_choices_ibfk_1` FOREIGN KEY (`question_id`) REFERENCES `questions` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=50 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `referentials`
--

DROP TABLE IF EXISTS `referentials`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `referentials` (
  `uuid` char(36) NOT NULL,
  `label1` varchar(255) DEFAULT NULL,
  `label2` varchar(255) DEFAULT NULL,
  `label3` varchar(255) DEFAULT NULL,
  `label4` varchar(255) DEFAULT NULL,
  `creator` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updater` varchar(255) DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`uuid`),
  KEY `uuid` (`uuid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `rolf_risks`
--

DROP TABLE IF EXISTS `rolf_risks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `rolf_risks` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `anr_id` int(11) unsigned DEFAULT NULL,
  `code` char(100) DEFAULT NULL,
  `label1` varchar(255) DEFAULT NULL,
  `label2` varchar(255) DEFAULT NULL,
  `label3` varchar(255) DEFAULT NULL,
  `label4` varchar(255) DEFAULT NULL,
  `description1` text,
  `description2` text,
  `description3` text,
  `description4` text,
  `creator` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updater` varchar(255) DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `anr_id` (`anr_id`,`code`),
  KEY `anr_id_2` (`anr_id`),
  CONSTRAINT `rolf_risks_ibfk_1` FOREIGN KEY (`anr_id`) REFERENCES `anrs` (`id`) ON DELETE CASCADE,
  CONSTRAINT `rolf_risks_ibfk_2` FOREIGN KEY (`anr_id`) REFERENCES `anrs` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=126 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `rolf_risks_tags`
--

DROP TABLE IF EXISTS `rolf_risks_tags`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `rolf_risks_tags` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `rolf_risk_id` int(11) unsigned DEFAULT NULL,
  `rolf_tag_id` int(11) unsigned DEFAULT NULL,
  `creator` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updater` varchar(255) DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `rolf_risk_id` (`rolf_risk_id`),
  KEY `rolf_tag_id` (`rolf_tag_id`),
  CONSTRAINT `rolf_risks_tags_ibfk_1` FOREIGN KEY (`rolf_risk_id`) REFERENCES `rolf_risks` (`id`) ON DELETE CASCADE,
  CONSTRAINT `rolf_risks_tags_ibfk_2` FOREIGN KEY (`rolf_tag_id`) REFERENCES `rolf_tags` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=98 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `rolf_tags`
--

DROP TABLE IF EXISTS `rolf_tags`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `rolf_tags` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `anr_id` int(11) unsigned DEFAULT NULL,
  `code` char(100) DEFAULT NULL,
  `label1` varchar(255) DEFAULT NULL,
  `label2` varchar(255) DEFAULT NULL,
  `label3` varchar(255) DEFAULT NULL,
  `label4` varchar(255) DEFAULT NULL,
  `creator` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updater` varchar(255) DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `anr_id` (`anr_id`,`code`),
  KEY `anr_id_2` (`anr_id`),
  CONSTRAINT `rolf_tags_ibfk_1` FOREIGN KEY (`anr_id`) REFERENCES `anrs` (`id`) ON DELETE CASCADE,
  CONSTRAINT `rolf_tags_ibfk_2` FOREIGN KEY (`anr_id`) REFERENCES `anrs` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `scales`
--

DROP TABLE IF EXISTS `scales`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `scales` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `anr_id` int(11) unsigned DEFAULT NULL,
  `type` tinyint(4) DEFAULT '0',
  `min` int(11) DEFAULT '0',
  `max` int(11) DEFAULT '0',
  `creator` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updater` varchar(255) DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `anr_id` (`anr_id`),
  CONSTRAINT `scales_ibfk_1` FOREIGN KEY (`anr_id`) REFERENCES `anrs` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=100 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `scales_comments`
--

DROP TABLE IF EXISTS `scales_comments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `scales_comments` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `anr_id` int(11) unsigned DEFAULT NULL,
  `scale_id` int(11) unsigned DEFAULT NULL,
  `scale_type_impact_id` int(11) unsigned DEFAULT NULL,
  `val` int(11) DEFAULT '0',
  `comment1` text,
  `comment2` text,
  `comment3` text,
  `comment4` text,
  `creator` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updater` varchar(255) DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `anr_id` (`anr_id`),
  KEY `scale_id` (`scale_id`),
  KEY `scale_type_impact_id` (`scale_type_impact_id`),
  CONSTRAINT `scales_comments_ibfk_1` FOREIGN KEY (`anr_id`) REFERENCES `anrs` (`id`) ON DELETE CASCADE,
  CONSTRAINT `scales_comments_ibfk_2` FOREIGN KEY (`scale_id`) REFERENCES `scales` (`id`) ON DELETE CASCADE,
  CONSTRAINT `scales_comments_ibfk_3` FOREIGN KEY (`scale_type_impact_id`) REFERENCES `scales_impact_types` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=1171 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `scales_impact_types`
--

DROP TABLE IF EXISTS `scales_impact_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `scales_impact_types` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `anr_id` int(11) unsigned DEFAULT NULL,
  `scale_id` int(11) unsigned DEFAULT NULL,
  `type` char(3) DEFAULT NULL,
  `label1` varchar(255) DEFAULT NULL,
  `is_sys` tinyint(4) DEFAULT '0',
  `is_hidden` tinyint(4) DEFAULT '0',
  `position` int(11) DEFAULT '0',
  `creator` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updater` varchar(255) DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `label2` varchar(255) DEFAULT NULL,
  `label3` varchar(255) DEFAULT NULL,
  `label4` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `anr_id` (`anr_id`),
  KEY `scale_id` (`scale_id`),
  KEY `type` (`type`),
  CONSTRAINT `scales_impact_types_ibfk_1` FOREIGN KEY (`anr_id`) REFERENCES `anrs` (`id`) ON DELETE CASCADE,
  CONSTRAINT `scales_impact_types_ibfk_2` FOREIGN KEY (`scale_id`) REFERENCES `scales` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=265 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `soacategory`
--

DROP TABLE IF EXISTS `soacategory`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `soacategory` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `label1` longtext,
  `label2` longtext,
  `label3` longtext,
  `label4` longtext,
  `status` int(11) DEFAULT '1',
  `referential_uuid` char(36) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `referential_uuid` (`referential_uuid`),
  CONSTRAINT `soacategory_ibfk_1` FOREIGN KEY (`referential_uuid`) REFERENCES `referentials` (`uuid`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=89 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `themes`
--

DROP TABLE IF EXISTS `themes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `themes` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `anr_id` int(11) unsigned DEFAULT NULL,
  `label1` varchar(255) DEFAULT NULL,
  `label2` varchar(255) DEFAULT NULL,
  `label3` varchar(255) DEFAULT NULL,
  `label4` varchar(255) DEFAULT NULL,
  `creator` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updater` varchar(255) DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `anr_id` (`anr_id`),
  CONSTRAINT `themes_ibfk_1` FOREIGN KEY (`anr_id`) REFERENCES `anrs` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=43 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `threats`
--

DROP TABLE IF EXISTS `threats`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `threats` (
  `uuid` char(36) NOT NULL,
  `anr_id` int(11) unsigned DEFAULT NULL,
  `theme_id` int(11) unsigned DEFAULT NULL,
  `mode` tinyint(4) DEFAULT '1',
  `code` char(100) DEFAULT NULL,
  `label1` varchar(255) DEFAULT NULL,
  `label2` varchar(255) DEFAULT NULL,
  `label3` varchar(255) DEFAULT NULL,
  `label4` varchar(255) DEFAULT NULL,
  `description1` varchar(1024) DEFAULT NULL,
  `description2` varchar(1024) DEFAULT NULL,
  `description3` varchar(1024) DEFAULT NULL,
  `description4` varchar(1024) DEFAULT NULL,
  `c` tinyint(4) DEFAULT '0',
  `i` tinyint(4) DEFAULT '0',
  `a` tinyint(4) DEFAULT '0',
  `status` tinyint(4) DEFAULT '1',
  `trend` int(11) NOT NULL DEFAULT '1',
  `comment` text,
  `qualification` int(11) DEFAULT '-1',
  `creator` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updater` varchar(255) DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`uuid`),
  UNIQUE KEY `anr_id` (`anr_id`,`code`),
  KEY `anr_id_2` (`anr_id`),
  KEY `threat_theme_id` (`theme_id`),
  KEY `uuid` (`uuid`),
  CONSTRAINT `threats_ibfk_1` FOREIGN KEY (`anr_id`) REFERENCES `anrs` (`id`) ON DELETE CASCADE,
  CONSTRAINT `threats_ibfk_2` FOREIGN KEY (`theme_id`) REFERENCES `themes` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `threats_models`
--

DROP TABLE IF EXISTS `threats_models`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `threats_models` (
  `model_id` int(11) unsigned NOT NULL,
  `threat_id` char(36) NOT NULL,
  PRIMARY KEY (`threat_id`,`model_id`),
  KEY `model_id` (`model_id`),
  CONSTRAINT `threats_models_ibfk_2` FOREIGN KEY (`model_id`) REFERENCES `models` (`id`),
  CONSTRAINT `threats_models_ibfk_4` FOREIGN KEY (`model_id`) REFERENCES `models` (`id`) ON DELETE CASCADE,
  CONSTRAINT `threats_models_ibfk_5` FOREIGN KEY (`threat_id`) REFERENCES `threats` (`uuid`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `vulnerabilities`
--

DROP TABLE IF EXISTS `vulnerabilities`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `vulnerabilities` (
  `uuid` char(36) NOT NULL,
  `anr_id` int(11) unsigned DEFAULT NULL,
  `mode` tinyint(4) DEFAULT '1',
  `code` char(100) DEFAULT NULL,
  `label1` varchar(255) DEFAULT '',
  `label2` varchar(255) DEFAULT '',
  `label3` varchar(255) DEFAULT '',
  `label4` varchar(255) DEFAULT '',
  `description1` text,
  `description2` text,
  `description3` text,
  `description4` text,
  `status` tinyint(4) DEFAULT '1',
  `creator` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updater` varchar(255) DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`uuid`),
  UNIQUE KEY `anr_id` (`anr_id`,`code`),
  KEY `anr_id_2` (`anr_id`),
  KEY `uuid` (`uuid`),
  CONSTRAINT `vulnerabilities_ibfk_1` FOREIGN KEY (`anr_id`) REFERENCES `anrs` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `vulnerabilities_models`
--

DROP TABLE IF EXISTS `vulnerabilities_models`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `vulnerabilities_models` (
  `model_id` int(11) unsigned NOT NULL,
  `vulnerability_id` char(36) NOT NULL,
  PRIMARY KEY (`vulnerability_id`,`model_id`),
  KEY `model_id` (`model_id`),
  CONSTRAINT `vulnerabilities_models_ibfk_2` FOREIGN KEY (`model_id`) REFERENCES `models` (`id`),
  CONSTRAINT `vulnerabilities_models_ibfk_4` FOREIGN KEY (`model_id`) REFERENCES `models` (`id`) ON DELETE CASCADE,
  CONSTRAINT `vulnerabilities_models_ibfk_5` FOREIGN KEY (`vulnerability_id`) REFERENCES `vulnerabilities` (`uuid`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2019-09-12 11:01:07
