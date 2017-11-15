--
-- Table structure for table `amvs`
--

DROP TABLE IF EXISTS `amvs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `amvs` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `anr_id` int(11) unsigned DEFAULT NULL,
  `asset_id` int(11) unsigned DEFAULT NULL,
  `threat_id` int(11) unsigned DEFAULT NULL,
  `vulnerability_id` int(11) unsigned DEFAULT NULL,
  `measure1_id` int(11) unsigned DEFAULT NULL,
  `measure2_id` int(11) unsigned DEFAULT NULL,
  `measure3_id` int(11) unsigned DEFAULT NULL,
  `position` int(11) DEFAULT '1',
  `status` int(11) DEFAULT '1',
  `creator` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updater` varchar(255) DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `anr_id` (`anr_id`),
  KEY `asset_id` (`asset_id`),
  KEY `threat_id` (`threat_id`),
  KEY `vulnerability_id` (`vulnerability_id`),
  KEY `measure1_id` (`measure1_id`),
  KEY `measure2_id` (`measure2_id`),
  KEY `measure3_id` (`measure3_id`),
  CONSTRAINT `amvs_ibfk_1` FOREIGN KEY (`anr_id`) REFERENCES `anrs` (`id`) ON DELETE CASCADE,
  CONSTRAINT `amvs_ibfk_2` FOREIGN KEY (`asset_id`) REFERENCES `assets` (`id`) ON DELETE CASCADE,
  CONSTRAINT `amvs_ibfk_3` FOREIGN KEY (`threat_id`) REFERENCES `threats` (`id`) ON DELETE CASCADE,
  CONSTRAINT `amvs_ibfk_4` FOREIGN KEY (`vulnerability_id`) REFERENCES `vulnerabilities` (`id`) ON DELETE CASCADE,
  CONSTRAINT `amvs_ibfk_5` FOREIGN KEY (`measure1_id`) REFERENCES `measures` (`id`) ON DELETE SET NULL,
  CONSTRAINT `amvs_ibfk_6` FOREIGN KEY (`measure2_id`) REFERENCES `measures` (`id`) ON DELETE SET NULL,
  CONSTRAINT `amvs_ibfk_7` FOREIGN KEY (`measure3_id`) REFERENCES `measures` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=11985 DEFAULT CHARSET=utf8;

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `anrs_objects`
--
-- TODO : Créer cette table une fois que objects est faite
DROP TABLE IF EXISTS `anrs_objects`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `anrs_objects` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `anr_id` int(11) unsigned DEFAULT NULL,
  `object_id` int(11) unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `anr_id` (`anr_id`),
  KEY `object_id` (`object_id`),
  CONSTRAINT `anrs_objects_ibfk_1` FOREIGN KEY (`anr_id`) REFERENCES `anrs` (`id`) ON DELETE CASCADE,
  CONSTRAINT `anrs_objects_ibfk_2` FOREIGN KEY (`object_id`) REFERENCES `objects` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;


--
-- Table structure for table `anrs_objects_categories`
--

-- TODO :  Problème de cohérence des données
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;


--
-- Table structure for table `assets`
--
DROP TABLE IF EXISTS `assets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `assets` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
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
  PRIMARY KEY (`id`),
  KEY `anr_id` (`anr_id`,`code`),
  KEY `anr_id_2` (`anr_id`),
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
  `asset_id` int(11) unsigned NOT NULL,
  `model_id` int(11) unsigned NOT NULL,
  PRIMARY KEY (`asset_id`,`model_id`),
  KEY `asset_id` (`asset_id`),
  KEY `model_id` (`model_id`),
  CONSTRAINT `assets_models_ibfk_1` FOREIGN KEY (`asset_id`) REFERENCES `assets` (`id`),
  CONSTRAINT `assets_models_ibfk_2` FOREIGN KEY (`model_id`) REFERENCES `models` (`id`),
  CONSTRAINT `assets_models_ibfk_3` FOREIGN KEY (`asset_id`) REFERENCES `assets` (`id`) ON DELETE CASCADE,
  CONSTRAINT `assets_models_ibfk_4` FOREIGN KEY (`model_id`) REFERENCES `models` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cities`
--

DROP TABLE IF EXISTS `cities`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cities` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `country_id` int(11) unsigned DEFAULT NULL,
  `label` varchar(255) NOT NULL,
  `creator` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updater` varchar(255) DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `country_id` (`country_id`),
  CONSTRAINT `cities_ibfk_1` FOREIGN KEY (`country_id`) REFERENCES `countries` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=110970 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `countries`
--

DROP TABLE IF EXISTS `countries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `countries` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `iso` varchar(2) NOT NULL DEFAULT '',
  `iso3` varchar(3) DEFAULT NULL,
  `name` varchar(80) DEFAULT '',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=240 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;


--
-- Table structure for table `deliveries_models`
--

DROP TABLE IF EXISTS `deliveries_models`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `deliveries_models` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `category` tinyint(4) NOT NULL DEFAULT '0',
  `description1` text,
  `path1` varchar(255) DEFAULT NULL,
  `content1` longblob,
  `creator` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updater` varchar(255) DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `description2` text,
  `description3` text,
  `description4` text,
  `anr_id` int(11) unsigned DEFAULT NULL,
  `path2` varchar(255) DEFAULT NULL,
  `content2` longblob,
  `path3` varchar(255) DEFAULT NULL,
  `content3` longblob,
  `path4` varchar(255) DEFAULT NULL,
  `content4` longblob,
  PRIMARY KEY (`id`),
  KEY `anr_id` (`anr_id`),
  CONSTRAINT `deliveries_models_ibfk_1` FOREIGN KEY (`anr_id`) REFERENCES `anrs` (`id`) ON DELETE CASCADE
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
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
  `anr_id` int(11) unsigned DEFAULT NULL,
  `asset_id` int(11) unsigned DEFAULT NULL,
  `object_id` int(11) unsigned DEFAULT NULL,
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
  KEY `asset_id` (`asset_id`),
  KEY `object_id` (`object_id`),
  KEY `root_id` (`root_id`),
  KEY `parent_id` (`parent_id`),
  CONSTRAINT `instances_ibfk_1` FOREIGN KEY (`anr_id`) REFERENCES `anrs` (`id`) ON DELETE CASCADE,
  CONSTRAINT `instances_ibfk_2` FOREIGN KEY (`asset_id`) REFERENCES `assets` (`id`) ON DELETE CASCADE,
  CONSTRAINT `instances_ibfk_3` FOREIGN KEY (`object_id`) REFERENCES `objects` (`id`) ON DELETE CASCADE,
  CONSTRAINT `instances_ibfk_4` FOREIGN KEY (`root_id`) REFERENCES `instances` (`id`) ON DELETE CASCADE,
  CONSTRAINT `instances_ibfk_5` FOREIGN KEY (`parent_id`) REFERENCES `instances` (`id`) ON DELETE CASCADE
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
  `anr_id` int(11) unsigned DEFAULT '0',
  `instance_id` int(11) unsigned DEFAULT '0',
  `object_id` int(11) unsigned DEFAULT '0',
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
  KEY `object_id` (`object_id`),
  KEY `scale_impact_type_id` (`scale_impact_type_id`),
  CONSTRAINT `instances_consequences_ibfk_1` FOREIGN KEY (`anr_id`) REFERENCES `anrs` (`id`) ON DELETE CASCADE,
  CONSTRAINT `instances_consequences_ibfk_2` FOREIGN KEY (`instance_id`) REFERENCES `instances` (`id`) ON DELETE CASCADE,
  CONSTRAINT `instances_consequences_ibfk_3` FOREIGN KEY (`object_id`) REFERENCES `objects` (`id`) ON DELETE CASCADE,
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
  `anr_id` int(11) unsigned DEFAULT NULL,
  `amv_id` int(11) unsigned DEFAULT NULL,
  `specific` tinyint(4) DEFAULT '0',
  `asset_id` int(11) unsigned DEFAULT NULL,
  `threat_id` int(11) unsigned DEFAULT NULL,
  `vulnerability_id` int(11) unsigned DEFAULT NULL,
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
  KEY `amv_id` (`amv_id`),
  KEY `asset_id` (`asset_id`),
  KEY `threat_id` (`threat_id`),
  KEY `vulnerability_id` (`vulnerability_id`),
  KEY `instance_id` (`instance_id`),
  CONSTRAINT `instances_risks_ibfk_1` FOREIGN KEY (`anr_id`) REFERENCES `anrs` (`id`) ON DELETE CASCADE,
  CONSTRAINT `instances_risks_ibfk_2` FOREIGN KEY (`amv_id`) REFERENCES `amvs` (`id`) ON DELETE CASCADE,
  CONSTRAINT `instances_risks_ibfk_4` FOREIGN KEY (`asset_id`) REFERENCES `assets` (`id`) ON DELETE CASCADE,
  CONSTRAINT `instances_risks_ibfk_5` FOREIGN KEY (`threat_id`) REFERENCES `threats` (`id`) ON DELETE CASCADE,
  CONSTRAINT `instances_risks_ibfk_6` FOREIGN KEY (`vulnerability_id`) REFERENCES `vulnerabilities` (`id`) ON DELETE CASCADE,
  CONSTRAINT `instances_risks_ibfk_7` FOREIGN KEY (`instance_id`) REFERENCES `instances` (`id`) ON DELETE CASCADE
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
  `anr_id` int(11) unsigned DEFAULT NULL,
  `instance_id` int(11) unsigned DEFAULT NULL,
  `object_id` int(11) unsigned DEFAULT NULL,
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
  KEY `object_id` (`object_id`),
  KEY `rolf_risk_id` (`rolf_risk_id`),
  CONSTRAINT `instances_risks_op_ibfk_1` FOREIGN KEY (`anr_id`) REFERENCES `anrs` (`id`) ON DELETE CASCADE,
  CONSTRAINT `instances_risks_op_ibfk_2` FOREIGN KEY (`instance_id`) REFERENCES `instances` (`id`) ON DELETE CASCADE,
  CONSTRAINT `instances_risks_op_ibfk_3` FOREIGN KEY (`rolf_risk_id`) REFERENCES `rolf_risks` (`id`) ON DELETE SET NULL,
  CONSTRAINT `instances_risks_op_ibfk_4` FOREIGN KEY (`object_id`) REFERENCES `objects` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `measures`
--

DROP TABLE IF EXISTS `measures`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `measures` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `anr_id` int(11) unsigned DEFAULT NULL,
  `code` varchar(255) DEFAULT NULL,
  `description1` text,
  `description2` text,
  `description3` text,
  `description4` text,
  `status` tinyint(4) DEFAULT '1',
  `creator` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updater` varchar(255) DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `anr_id` (`anr_id`),
  CONSTRAINT `measures_ibfk_1` FOREIGN KEY (`anr_id`) REFERENCES `anrs` (`id`) ON DELETE CASCADE
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `objects`
--

DROP TABLE IF EXISTS `objects`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `objects` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `object_category_id` int(11) unsigned DEFAULT NULL,
  `asset_id` int(11) unsigned DEFAULT NULL,
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
  PRIMARY KEY (`id`),
  KEY `object_category_id` (`object_category_id`),
  KEY `asset_id` (`asset_id`),
  KEY `rolf_tag_id` (`rolf_tag_id`),
  KEY `anr_id` (`anr_id`),
  CONSTRAINT `objects_ibfk_2` FOREIGN KEY (`object_category_id`) REFERENCES `objects_categories` (`id`) ON DELETE SET NULL,
  CONSTRAINT `objects_ibfk_3` FOREIGN KEY (`asset_id`) REFERENCES `assets` (`id`) ON DELETE CASCADE,
  CONSTRAINT `objects_ibfk_5` FOREIGN KEY (`rolf_tag_id`) REFERENCES `rolf_tags` (`id`) ON DELETE SET NULL,
  CONSTRAINT `objects_ibfk_7` FOREIGN KEY (`anr_id`) REFERENCES `anrs` (`id`) ON DELETE CASCADE
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `objects_objects`
--

DROP TABLE IF EXISTS `objects_objects`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `objects_objects` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `anr_id` int(11) unsigned DEFAULT NULL,
  `father_id` int(11) unsigned DEFAULT NULL,
  `child_id` int(11) unsigned DEFAULT NULL,
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
  CONSTRAINT `objects_objects_ibfk_2` FOREIGN KEY (`father_id`) REFERENCES `objects` (`id`) ON DELETE CASCADE,
  CONSTRAINT `objects_objects_ibfk_3` FOREIGN KEY (`child_id`) REFERENCES `objects` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
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
  CONSTRAINT `rolf_risks_tags_ibfk_2` FOREIGN KEY (`rolf_risk_id`) REFERENCES `rolf_risks` (`id`) ON DELETE CASCADE,
  CONSTRAINT `rolf_risks_tags_ibfk_3` FOREIGN KEY (`rolf_tag_id`) REFERENCES `rolf_tags` (`id`) ON DELETE CASCADE,
  CONSTRAINT `rolf_risks_tags_ibfk_4` FOREIGN KEY (`rolf_risk_id`) REFERENCES `rolf_risks` (`id`) ON DELETE CASCADE,
  CONSTRAINT `rolf_risks_tags_ibfk_5` FOREIGN KEY (`rolf_tag_id`) REFERENCES `rolf_tags` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `threats`
--

DROP TABLE IF EXISTS `threats`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `threats` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
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
  `d` tinyint(4) DEFAULT '0',
  `status` tinyint(4) DEFAULT '1',
  `trend` int(11) NOT NULL DEFAULT '1',
  `comment` text,
  `qualification` int(11) DEFAULT '-1',
  `creator` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updater` varchar(255) DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `anr_id` (`anr_id`,`code`),
  KEY `anr_id_2` (`anr_id`),
  KEY `threat_theme_id` (`theme_id`),
  CONSTRAINT `threats_ibfk_1` FOREIGN KEY (`anr_id`) REFERENCES `anrs` (`id`) ON DELETE CASCADE,
  CONSTRAINT `threats_ibfk_2` FOREIGN KEY (`theme_id`) REFERENCES `themes` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `threats_models`
--

DROP TABLE IF EXISTS `threats_models`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `threats_models` (
  `threat_id` int(11) unsigned NOT NULL,
  `model_id` int(11) unsigned NOT NULL,
  PRIMARY KEY (`threat_id`,`model_id`),
  KEY `threat_id` (`threat_id`),
  KEY `model_id` (`model_id`),
  CONSTRAINT `threats_models_ibfk_1` FOREIGN KEY (`threat_id`) REFERENCES `threats` (`id`),
  CONSTRAINT `threats_models_ibfk_2` FOREIGN KEY (`model_id`) REFERENCES `models` (`id`),
  CONSTRAINT `threats_models_ibfk_3` FOREIGN KEY (`threat_id`) REFERENCES `threats` (`id`) ON DELETE CASCADE,
  CONSTRAINT `threats_models_ibfk_4` FOREIGN KEY (`model_id`) REFERENCES `models` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `vulnerabilities`
--

DROP TABLE IF EXISTS `vulnerabilities`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `vulnerabilities` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
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
  PRIMARY KEY (`id`),
  UNIQUE KEY `anr_id` (`anr_id`,`code`),
  KEY `anr_id_2` (`anr_id`),
  CONSTRAINT `vulnerabilities_ibfk_1` FOREIGN KEY (`anr_id`) REFERENCES `anrs` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5746 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `vulnerabilities_models`
--

DROP TABLE IF EXISTS `vulnerabilities_models`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `vulnerabilities_models` (
  `vulnerability_id` int(11) unsigned NOT NULL,
  `model_id` int(11) unsigned NOT NULL,
  PRIMARY KEY (`vulnerability_id`,`model_id`),
  KEY `vulnerability_id` (`vulnerability_id`),
  KEY `model_id` (`model_id`),
  CONSTRAINT `vulnerabilities_models_ibfk_1` FOREIGN KEY (`vulnerability_id`) REFERENCES `vulnerabilities` (`id`),
  CONSTRAINT `vulnerabilities_models_ibfk_2` FOREIGN KEY (`model_id`) REFERENCES `models` (`id`),
  CONSTRAINT `vulnerabilities_models_ibfk_3` FOREIGN KEY (`vulnerability_id`) REFERENCES `vulnerabilities` (`id`) ON DELETE CASCADE,
  CONSTRAINT `vulnerabilities_models_ibfk_4` FOREIGN KEY (`model_id`) REFERENCES `models` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;