SET foreign_key_checks = 0;

DROP TABLE IF EXISTS `translations`;
CREATE TABLE `translations` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `ISO` text DEFAULT NULL,
  `content` text DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- TRANSLATIONS_LANGUAGES
DROP TABLE IF EXISTS `translations_languages`;
DROP TABLE IF EXISTS `translations_language`;
CREATE TABLE `translation_language` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `translation_id` int(11) unsigned DEFAULT NULL,
  `anrs_string_id` int(11) DEFAULT NULL,
  `assets_string_id` int(11) DEFAULT NULL,
  `instances_string_id` int(11) DEFAULT NULL,
  `measures_string_id` int(11) DEFAULT NULL,
  `objects_string_id` int(11) DEFAULT NULL,
  `objects_categories_string_id` int(11) DEFAULT NULL,
  `questions_string_id` int(11) DEFAULT NULL,
  `questions_choices_string_id` int(11) DEFAULT NULL,
  `rolf_risks_string_id` int(11) DEFAULT NULL,
  `rolf_tags_string_id` int(11) DEFAULT NULL,
  `scales_comments_string_id` int(11) DEFAULT NULL,
  `scales_impact_types_string_id` int(11) DEFAULT NULL,
  `themes_string_id` int(11) DEFAULT NULL,
  `threats_string_id` int(11) DEFAULT NULL,
  `vulnerabilities_string_id` int(11) DEFAULT NULL,
  `instances_risks_op_string_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `translation_id` (`translation_id`),
  CONSTRAINT `translations_ibfk_1` FOREIGN KEY (`translation_id`) REFERENCES `translations` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


-- 
-- Procedure to add new columns for ids translation into entity tables
DROP PROCEDURE IF EXISTS add_new_translation_id_columns;
DELIMITER ;;
CREATE PROCEDURE add_new_translation_id_columns ()
BEGIN
	ALTER TABLE `anrs` ADD description_translation_id INT(11), ADD label_translation_id INT(11);
	ALTER TABLE `assets` ADD description_translation_id INT(11), ADD label_translation_id INT(11);
	ALTER TABLE `instances` ADD name_translation_id INT(11), ADD label_translation_id INT(11);
	ALTER TABLE `measures` ADD description_translation_id INT(11);
	ALTER TABLE `objects` ADD name_translation_id INT(11), ADD label_translation_id INT(11);
	ALTER TABLE `objects_categories` ADD label_translation_id INT(11);
	ALTER TABLE `questions` ADD label_translation_id INT(11);
	ALTER TABLE `questions_choices` ADD label_translation_id INT(11);
	ALTER TABLE `rolf_risks` ADD description_translation_id INT(11), ADD label_translation_id INT(11);
	ALTER TABLE `rolf_tags` ADD label_translation_id INT(11);
	ALTER TABLE `scales_comments` ADD comment_translation_id INT(11);
	ALTER TABLE `scales_impact_types` ADD label_translation_id INT(11);
	ALTER TABLE `themes` ADD label_translation_id INT(11);
	ALTER TABLE `threats` ADD description_translation_id INT(11), ADD label_translation_id INT(11);
	ALTER TABLE `vulnerabilities` ADD description_translation_id INT(11), ADD label_translation_id INT(11);
  ALTER TABLE `instances_risks_op` ADD risk_cache_label_translation_id INT(11), ADD risk_cache_description_translation_id INT(11);
END;;
DELIMITER ;

CALL add_new_translation_id_columns;

SET foreign_key_checks = 1;
