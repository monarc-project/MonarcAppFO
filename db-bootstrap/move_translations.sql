-- Request to add the new translation table
DROP TABLE IF EXISTS `translations`;

CREATE TABLE `translations` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `FR` text DEFAULT NULL,
  `EN` text DEFAULT NULL,
  `DE` text DEFAULT NULL,
  `NL` text DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


-- Procedure to add new columns for ids translation into tables

DELIMITER ;;
CREATE PROCEDURE add_new_translation_id_columns ()
BEGIN
	ALTER TABLE `anrs` ADD description_translation_id INT(11), ADD label_translation_id INT(11);
	ALTER TABLE `assets` ADD description_translation_id INT(11), ADD label_translation_id INT(11);
	ALTER TABLE `guides` ADD description_translation_id INT(11);
	ALTER TABLE `guides_items` ADD description_translation_id INT(11);
	ALTER TABLE `historicals` ADD label_translation_id INT(11);
	ALTER TABLE `instances` ADD name_translation_id INT(11), ADD label_translation_id INT(11);
	ALTER TABLE `measures` ADD description_translation_id INT(11);
	ALTER TABLE `models` ADD description_translation_id INT(11), ADD label_translation_id INT(11);
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
END;;
DELIMITER ;


-- Procedure to duplicate translations

-- ASSETS
DELIMITER ;;
CREATE PROCEDURE duplicate_data_assets ()
BEGIN
    DECLARE i INT DEFAULT 0;
	DECLARE j INT DEFAULT 0;
    DECLARE table_length INT DEFAULT 0;
    
    SET table_length = (SELECT COUNT(*) FROM `assets`);
    
    WHILE i < table_length DO
	
    	SET @current_assets_id = (SELECT `id` FROM assets LIMIT 1 OFFSET i);
    	
    	SET @query = CONCAT('INSERT INTO `translations` (`FR`, `EN`, `DE`, `NL`) SELECT `label1`, `label2`, `label3`, `label4` FROM `assets` LIMIT 1 OFFSET ', i) ;
    	PREPARE statement FROM @query; 
    	EXECUTE statement; 
    	DEALLOCATE PREPARE statement;
    	
    	SET @new_label_translation_id = (SELECT `id` FROM `translations` ORDER BY `id` DESC LIMIT 1);
    	
    	SET @query = CONCAT('UPDATE `assets` SET `label_translation_id` = ', @new_label_translation_id, ' WHERE `id` = ', @current_assets_id);
    	PREPARE statement FROM @query; 
    	EXECUTE statement; 
    	DEALLOCATE PREPARE statement;
    	
    	SET i = i + 1;
    END WHILE;

	WHILE j < table_length DO
	
    	SET @current_assets_id = (SELECT `id` FROM assets LIMIT 1 OFFSET j);
    	
    	SET @query = CONCAT('INSERT INTO `translations` (`FR`, `EN`, `DE`, `NL`) SELECT `description1`, `description2`, `description3`, `description4` FROM `assets` LIMIT 1 OFFSET ', j) ;
    	PREPARE statement FROM @query; 
    	EXECUTE statement; 
    	DEALLOCATE PREPARE statement;
    	
    	SET @new_description_translation_id = (SELECT `id` FROM `translations` ORDER BY `id` DESC LIMIT 1);
    	
    	SET @query = CONCAT('UPDATE `assets` SET `description_translation_id` = ', @new_description_translation_id, ' WHERE `id` = ', @current_assets_id);
    	PREPARE statement FROM @query; 
    	EXECUTE statement; 
    	DEALLOCATE PREPARE statement;
    	
    	SET j = j + 1;
    END WHILE; 
END;;
DELIMITER ;



-- GUIDES 
DELIMITER ;;
CREATE PROCEDURE duplicate_data_guides ()
BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE table_length INT DEFAULT 0;
    
    SET table_length = (SELECT COUNT(*) FROM `guides`);
    
    WHILE i < table_length DO
	
    	SET @current_guides_id = (SELECT `id` FROM guides LIMIT 1 OFFSET i);
    	
    	SET @query = CONCAT('INSERT INTO `translations` (`FR`, `EN`, `DE`, `NL`) SELECT `description1`, `description2`, `description3`, `description4` FROM `guides` LIMIT 1 OFFSET ', i) ;
    	PREPARE statement FROM @query; 
    	EXECUTE statement; 
    	DEALLOCATE PREPARE statement;
    	
    	SET @new_id_translation = (SELECT `id` FROM `translations` ORDER BY `id` DESC LIMIT 1);
    	
    	SET @query = CONCAT('UPDATE `guides` SET `description_translation_id` = ', @new_id_translation, ' WHERE `id` = ', @current_guides_id);
    	PREPARE statement FROM @query; 
    	EXECUTE statement; 
    	DEALLOCATE PREPARE statement;
    	
    	SET i = i + 1;
    END WHILE;
END;;
DELIMITER ;

-- GUIDES_ITEMS
DELIMITER ;;
CREATE PROCEDURE duplicate_data_guides_items ()
BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE table_length INT DEFAULT 0;
    
    SET table_length = (SELECT COUNT(*) FROM `guides_items`);

    WHILE i < table_length DO
	
    	SET @current_guide_items_id = (SELECT `id` FROM guides_items LIMIT 1 OFFSET i);
    	
    	SET @query = CONCAT('INSERT INTO `translations` (`FR`, `EN`, `DE`, `NL`) SELECT `description1`, `description2`, `description3`, `description4` FROM `guides_items` LIMIT 1 OFFSET ', i) ;
    	PREPARE statement FROM @query; 
    	EXECUTE statement; 
    	DEALLOCATE PREPARE statement;
    	
    	SET @new_description_translation_id = (SELECT `id` FROM `translations` ORDER BY `id` DESC LIMIT 1);
    	
    	SET @query = CONCAT('UPDATE `guides_items` SET `description_translation_id` = ', @new_description_translation_id, ' WHERE `id` = ', @current_guide_items_id);
    	PREPARE statement FROM @query; 
    	EXECUTE statement; 
    	DEALLOCATE PREPARE statement;
    	
    	SET i = i + 1;
    END WHILE;
END;;
DELIMITER ;


-- HISTORICALS
DELIMITER ;;
CREATE PROCEDURE duplicate_data_historicals ()
BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE table_length INT DEFAULT 0;
    
    SET table_length = (SELECT COUNT(*) FROM `historicals`);
    
    WHILE i < table_length DO
	
    	SET @current_historicals_id = (SELECT `id` FROM historicals LIMIT 1 OFFSET i);
    	
    	SET @query = CONCAT('INSERT INTO `translations` (`FR`, `EN`, `DE`, `NL`) SELECT `label1`, `label2`, `label3`, `label4` FROM `historicals` LIMIT 1 OFFSET ', i) ;
    	PREPARE statement FROM @query; 
    	EXECUTE statement; 
    	DEALLOCATE PREPARE statement;
    	
    	SET @new_label_translation_id = (SELECT `id` FROM `translations` ORDER BY `id` DESC LIMIT 1);
    	
    	SET @query = CONCAT('UPDATE `historicals` SET `label_translation_id` = ', @new_label_translation_id, ' WHERE `id` = ', @current_historicals_id);
    	PREPARE statement FROM @query; 
    	EXECUTE statement; 
    	DEALLOCATE PREPARE statement;
    	
    	SET i = i + 1;
    END WHILE;
END;;
DELIMITER ;

-- INSTANCES
DELIMITER ;;
CREATE PROCEDURE duplicate_data_instances ()
BEGIN
    DECLARE i INT DEFAULT 0;
	DECLARE j INT DEFAULT 0;
    DECLARE table_length INT DEFAULT 0;
    
    SET table_length = (SELECT COUNT(*) FROM `instances`);
    
    WHILE i < table_length DO
	
    	SET @current_instances_id = (SELECT `id` FROM instances LIMIT 1 OFFSET i);
    	
    	SET @query = CONCAT('INSERT INTO `translations` (`FR`, `EN`, `DE`, `NL`) SELECT `label1`, `label2`, `label3`, `label4` FROM `instances` LIMIT 1 OFFSET ', i) ;
    	PREPARE statement FROM @query; 
    	EXECUTE statement; 
    	DEALLOCATE PREPARE statement;
    	
    	SET @new_label_translation_id = (SELECT `id` FROM `translations` ORDER BY `id` DESC LIMIT 1);
    	
    	SET @query = CONCAT('UPDATE `instances` SET `label_translation_id` = ', @new_label_translation_id, ' WHERE `id` = ', @current_instances_id);
    	PREPARE statement FROM @query; 
    	EXECUTE statement; 
    	DEALLOCATE PREPARE statement;
    	
    	SET i = i + 1;
    END WHILE;

	WHILE j < table_length DO
	
    	SET @current_name_translation_id = (SELECT `id` FROM instances LIMIT 1 OFFSET j);
    	
    	SET @query = CONCAT('INSERT INTO `translations` (`FR`, `EN`, `DE`, `NL`) SELECT `name1`, `name2`, `name3`, `name4` FROM `instances` LIMIT 1 OFFSET ', j) ;
    	PREPARE statement FROM @query; 
    	EXECUTE statement; 
    	DEALLOCATE PREPARE statement;
    	
    	SET @new_name_translation_id = (SELECT `id` FROM `translations` ORDER BY `id` DESC LIMIT 1);
    	
    	SET @query = CONCAT('UPDATE `instances` SET `name_translation_id` = ', @new_name_translation_id, ' WHERE `id` = ', @current_name_translation_id);
    	PREPARE statement FROM @query; 
    	EXECUTE statement; 
    	DEALLOCATE PREPARE statement;
    	
    	SET j = j + 1;
    END WHILE;
END;;
DELIMITER ;

-- MEASURES
DELIMITER ;;
CREATE PROCEDURE duplicate_data_measures ()
BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE table_length INT DEFAULT 0;
    
    SET table_length = (SELECT COUNT(*) FROM `measures`);
    
    WHILE i < table_length DO
	
    	SET @current_measures_id = (SELECT `id` FROM measures LIMIT 1 OFFSET i);
    	
    	SET @query = CONCAT('INSERT INTO `translations` (`FR`, `EN`, `DE`, `NL`) SELECT `description1`, `description2`, `description3`, `description4` FROM `measures` LIMIT 1 OFFSET ', i) ;
    	PREPARE statement FROM @query; 
    	EXECUTE statement; 
    	DEALLOCATE PREPARE statement;
    	
    	SET @new_description_translation_id = (SELECT `id` FROM `translations` ORDER BY `id` DESC LIMIT 1);
    	
    	SET @query = CONCAT('UPDATE `measures` SET `description_translation_id` = ', @new_description_translation_id, ' WHERE `id` = ', @current_measures_id);
    	PREPARE statement FROM @query; 
    	EXECUTE statement; 
    	DEALLOCATE PREPARE statement;
    	
    	SET i = i + 1;
    END WHILE;
END;;
DELIMITER ;

-- MODELS
DELIMITER ;;
CREATE PROCEDURE duplicate_data_models ()
BEGIN
    DECLARE i INT DEFAULT 0;
	DECLARE j INT DEFAULT 0;
    DECLARE table_length INT DEFAULT 0;
    
    SET table_length = (SELECT COUNT(*) FROM `models`);
    
    WHILE i < table_length DO
	
    	SET @current_guide_id = (SELECT `id` FROM models LIMIT 1 OFFSET i);
    	
    	SET @query = CONCAT('INSERT INTO `translations` (`FR`, `EN`, `DE`, `NL`) SELECT `description1`, `description2`, `description3`, `description4` FROM `models` LIMIT 1 OFFSET ', i) ;
    	PREPARE statement FROM @query; 
    	EXECUTE statement; 
    	DEALLOCATE PREPARE statement;
    	
    	SET @new_id_translation = (SELECT `id` FROM `translations` ORDER BY `id` DESC LIMIT 1);
    	
    	SET @query = CONCAT('UPDATE `models` SET `description_translation_id` = ', @new_id_translation, ' WHERE `id` = ', @current_guide_id);
    	PREPARE statement FROM @query; 
    	EXECUTE statement; 
    	DEALLOCATE PREPARE statement;
    	
    	SET i = i + 1;
    END WHILE;

	WHILE j < table_length DO
	
    	SET @current_label_translation_id = (SELECT `id` FROM models LIMIT 1 OFFSET j);
    	
    	SET @query = CONCAT('INSERT INTO `translations` (`FR`, `EN`, `DE`, `NL`) SELECT `label1`, `label2`, `label3`, `label4` FROM `models` LIMIT 1 OFFSET ', j) ;
    	PREPARE statement FROM @query; 
    	EXECUTE statement; 
    	DEALLOCATE PREPARE statement;
    	
    	SET @new_label_translation_id = (SELECT `id` FROM `translations` ORDER BY `id` DESC LIMIT 1);
    	
    	SET @query = CONCAT('UPDATE `models` SET `label_translation_id` = ', @new_label_translation_id, ' WHERE `id` = ', @current_label_translation_id);
    	PREPARE statement FROM @query; 
    	EXECUTE statement; 
    	DEALLOCATE PREPARE statement;
    	
    	SET j = j + 1;
    END WHILE;
END;;
DELIMITER ;

-- OBJECTS

DELIMITER ;;
CREATE PROCEDURE duplicate_data_objects ()
BEGIN
    DECLARE i INT DEFAULT 0;
	DECLARE j INT DEFAULT 0;
    DECLARE table_length INT DEFAULT 0;
    
    SET table_length = (SELECT COUNT(*) FROM `objects`);
    
    WHILE i < table_length DO
	
    	SET @current_label_translation_id = (SELECT `id` FROM objects LIMIT 1 OFFSET i);
    	
    	SET @query = CONCAT('INSERT INTO `translations` (`FR`, `EN`, `DE`, `NL`) SELECT `label1`, `label2`, `label3`, `label4` FROM `objects` LIMIT 1 OFFSET ', i) ;
    	PREPARE statement FROM @query; 
    	EXECUTE statement; 
    	DEALLOCATE PREPARE statement;
    	
    	SET @new_label_translation_id = (SELECT `id` FROM `translations` ORDER BY `id` DESC LIMIT 1);
    	
    	SET @query = CONCAT('UPDATE `objects` SET `label_translation_id` = ', @new_label_translation_id, ' WHERE `id` = ', @current_label_translation_id);
    	PREPARE statement FROM @query; 
    	EXECUTE statement; 
    	DEALLOCATE PREPARE statement;
    	
    	SET i = i + 1;
    END WHILE;

	WHILE j < table_length DO
	
    	SET @current_name_translation_id = (SELECT `id` FROM objects LIMIT 1 OFFSET j);
    	
    	SET @query = CONCAT('INSERT INTO `translations` (`FR`, `EN`, `DE`, `NL`) SELECT `name1`, `name2`, `name3`, `name4` FROM `objects` LIMIT 1 OFFSET ', j) ;
    	PREPARE statement FROM @query; 
    	EXECUTE statement; 
    	DEALLOCATE PREPARE statement;
    	
    	SET @new_name_translation_id = (SELECT `id` FROM `translations` ORDER BY `id` DESC LIMIT 1);
    	
    	SET @query = CONCAT('UPDATE `objects` SET `name_translation_id` = ', @new_name_translation_id, ' WHERE `id` = ', @current_name_translation_id);
    	PREPARE statement FROM @query; 
    	EXECUTE statement; 
    	DEALLOCATE PREPARE statement;
    	
    	SET j = j + 1;
    END WHILE;
END;;
DELIMITER ;

-- OBJECTS_CATEGORIES 
DELIMITER ;;
CREATE PROCEDURE duplicate_data_objects_categories ()
BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE table_length INT DEFAULT 0;
    
    SET table_length = (SELECT COUNT(*) FROM `objects_categories`);
    
    WHILE i < table_length DO
	
    	SET @current_objects_categories_id = (SELECT `id` FROM objects_categories LIMIT 1 OFFSET i);
    	
    	SET @query = CONCAT('INSERT INTO `translations` (`FR`, `EN`, `DE`, `NL`) SELECT `label1`, `label2`, `label3`, `label4` FROM `objects_categories` LIMIT 1 OFFSET ', i) ;
    	PREPARE statement FROM @query; 
    	EXECUTE statement; 
    	DEALLOCATE PREPARE statement;
    	
    	SET @new_label_translation_id = (SELECT `id` FROM `translations` ORDER BY `id` DESC LIMIT 1);
    	
    	SET @query = CONCAT('UPDATE `objects_categories` SET `label_translation_id` = ', @new_label_translation_id, ' WHERE `id` = ', @current_objects_categories_id);
    	PREPARE statement FROM @query; 
    	EXECUTE statement; 
    	DEALLOCATE PREPARE statement;
    	
    	SET i = i + 1;
    END WHILE;
END;;
DELIMITER ;

-- QUESTIONS
DELIMITER ;;
CREATE PROCEDURE duplicate_data_questions ()
BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE table_length INT DEFAULT 0;
    
    SET table_length = (SELECT COUNT(*) FROM `questions`);
    
    WHILE i < table_length DO
	
    	SET @current_questions_id = (SELECT `id` FROM questions LIMIT 1 OFFSET i);
    	
    	SET @query = CONCAT('INSERT INTO `translations` (`FR`, `EN`, `DE`, `NL`) SELECT `label1`, `label2`, `label3`, `label4` FROM `questions` LIMIT 1 OFFSET ', i) ;
    	PREPARE statement FROM @query; 
    	EXECUTE statement; 
    	DEALLOCATE PREPARE statement;
    	
    	SET @new_label_translation_id = (SELECT `id` FROM `translations` ORDER BY `id` DESC LIMIT 1);
    	
    	SET @query = CONCAT('UPDATE `questions` SET `label_translation_id` = ', @new_label_translation_id, ' WHERE `id` = ', @current_questions_id);
    	PREPARE statement FROM @query; 
    	EXECUTE statement; 
    	DEALLOCATE PREPARE statement;
    	
    	SET i = i + 1;
    END WHILE;
END;;
DELIMITER ;

-- QUESTIONS_CHOICES
DELIMITER ;;
CREATE PROCEDURE duplicate_data_questions_choices ()
BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE table_length INT DEFAULT 0;
    
    SET table_length = (SELECT COUNT(*) FROM `questions_choices`);
    
    WHILE i < table_length DO
	
    	SET @current_questions_choices_id = (SELECT `id` FROM questions_choices LIMIT 1 OFFSET i);
    	
    	SET @query = CONCAT('INSERT INTO `translations` (`FR`, `EN`, `DE`, `NL`) SELECT `label1`, `label2`, `label3`, `label4` FROM `questions_choices` LIMIT 1 OFFSET ', i) ;
    	PREPARE statement FROM @query; 
    	EXECUTE statement; 
    	DEALLOCATE PREPARE statement;
    	
    	SET @new_label_translation_id = (SELECT `id` FROM `translations` ORDER BY `id` DESC LIMIT 1);
    	
    	SET @query = CONCAT('UPDATE `questions_choices` SET `label_translation_id` = ', @new_label_translation_id, ' WHERE `id` = ', @current_questions_choices_id);
    	PREPARE statement FROM @query; 
    	EXECUTE statement; 
    	DEALLOCATE PREPARE statement;
    	
    	SET i = i + 1;
    END WHILE;
END;;
DELIMITER ;

-- ROLF_RISKS
DELIMITER ;;
CREATE PROCEDURE duplicate_data_rolf_risks ()
BEGIN
    DECLARE i INT DEFAULT 0;
	DECLARE j INT DEFAULT 0;
    DECLARE table_length INT DEFAULT 0;
    
    SET table_length = (SELECT COUNT(*) FROM `rolf_risks`);
    
    WHILE i < table_length DO
    	SET @current_rolf_risks_id = (SELECT `id` FROM rolf_risks LIMIT 1 OFFSET i);
    	
    	SET @query = CONCAT('INSERT INTO `translations` (`FR`, `EN`, `DE`, `NL`) SELECT `label1`, `label2`, `label3`, `label4` FROM `rolf_risks` LIMIT 1 OFFSET ', i) ;
    	PREPARE statement FROM @query; 
    	EXECUTE statement; 
    	DEALLOCATE PREPARE statement;
    	
    	SET @new_label_translation_id = (SELECT `id` FROM `translations` ORDER BY `id` DESC LIMIT 1);
    	
    	SET @query = CONCAT('UPDATE `rolf_risks` SET `label_translation_id` = ', @new_label_translation_id, ' WHERE `id` = ', @current_rolf_risks_id);
    	PREPARE statement FROM @query; 
    	EXECUTE statement; 
    	DEALLOCATE PREPARE statement;
    	
    	SET i = i + 1;
    END WHILE;

	WHILE j < table_length DO
    	SET @current_rolf_risks_id = (SELECT `id` FROM rolf_risks LIMIT 1 OFFSET j);
    	
    	SET @query = CONCAT('INSERT INTO `translations` (`FR`, `EN`, `DE`, `NL`) SELECT `description1`, `description2`, `description3`, `description4` FROM `rolf_risks` LIMIT 1 OFFSET ', j) ;
    	PREPARE statement FROM @query; 
    	EXECUTE statement; 
    	DEALLOCATE PREPARE statement;
    	
    	SET @new_description_translation_id = (SELECT `id` FROM `translations` ORDER BY `id` DESC LIMIT 1);
    	
    	SET @query = CONCAT('UPDATE `rolf_risks` SET `description_translation_id` = ', @new_description_translation_id, ' WHERE `id` = ', @current_rolf_risks_id);
    	PREPARE statement FROM @query; 
    	EXECUTE statement; 
    	DEALLOCATE PREPARE statement;
    	
    	SET j = j + 1;
    END WHILE;
END;;
DELIMITER ;

-- ROLF-TAGS
DELIMITER ;;
CREATE PROCEDURE duplicate_data_rolf_tags ()
BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE table_length INT DEFAULT 0;
    
    SET table_length = (SELECT COUNT(*) FROM `rolf_tags`);
    
    WHILE i < table_length DO
	
    	SET @current_label_translation_id = (SELECT `id` FROM rolf_tags LIMIT 1 OFFSET i);
    	
    	SET @query = CONCAT('INSERT INTO `translations` (`FR`, `EN`, `DE`, `NL`) SELECT `label1`, `label2`, `label3`, `label4` FROM `rolf_tags` LIMIT 1 OFFSET ', i) ;
    	PREPARE statement FROM @query; 
    	EXECUTE statement; 
    	DEALLOCATE PREPARE statement;
    	
    	SET @new_label_translation_id = (SELECT `id` FROM `translations` ORDER BY `id` DESC LIMIT 1);
    	
    	SET @query = CONCAT('UPDATE `rolf_tags` SET `label_translation_id` = ', @new_label_translation_id, ' WHERE `id` = ', @current_label_translation_id);
    	PREPARE statement FROM @query; 
    	EXECUTE statement; 
    	DEALLOCATE PREPARE statement;
    	
    	SET i = i + 1;
    END WHILE;
END;;
DELIMITER ;

-- SCALES_IMPACT_TYPES
DELIMITER ;;
CREATE PROCEDURE duplicate_data_scales_impact_types ()
BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE table_length INT DEFAULT 0;
    
    SET table_length = (SELECT COUNT(*) FROM `scales_impact_types`);
    
    WHILE i < table_length DO
	
    	SET @current_scales_impact_types_id = (SELECT `id` FROM scales_impact_types LIMIT 1 OFFSET i);
    	
    	SET @query = CONCAT('INSERT INTO `translations` (`FR`, `EN`, `DE`, `NL`) SELECT `label1`, `label2`, `label3`, `label4` FROM `scales_impact_types` LIMIT 1 OFFSET ', i) ;
    	PREPARE statement FROM @query; 
    	EXECUTE statement; 
    	DEALLOCATE PREPARE statement;
    	
    	SET @new_label_translation_id = (SELECT `id` FROM `translations` ORDER BY `id` DESC LIMIT 1);
    	
    	SET @query = CONCAT('UPDATE `scales_impact_types` SET `label_translation_id` = ', @new_label_translation_id, ' WHERE `id` = ', @current_scales_impact_types_id);
    	PREPARE statement FROM @query; 
    	EXECUTE statement; 
    	DEALLOCATE PREPARE statement;
    	
    	SET i = i + 1;
    END WHILE;
END;;
DELIMITER ;

-- THEMES
DELIMITER ;;
CREATE PROCEDURE duplicate_data_themes ()
BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE table_length INT DEFAULT 0;
    
    SET table_length = (SELECT COUNT(*) FROM `themes`);
    
    WHILE i < table_length DO
	
    	SET @current_themes_id = (SELECT `id` FROM themes LIMIT 1 OFFSET i);
    	
    	SET @query = CONCAT('INSERT INTO `translations` (`FR`, `EN`, `DE`, `NL`) SELECT `label1`, `label2`, `label3`, `label4` FROM `themes` LIMIT 1 OFFSET ', i) ;
    	PREPARE statement FROM @query; 
    	EXECUTE statement; 
    	DEALLOCATE PREPARE statement;
    	
    	SET @new_label_translation_id = (SELECT `id` FROM `translations` ORDER BY `id` DESC LIMIT 1);
    	
    	SET @query = CONCAT('UPDATE `themes` SET `label_translation_id` = ', @new_label_translation_id, ' WHERE `id` = ', @current_themes_id);
    	PREPARE statement FROM @query; 
    	EXECUTE statement; 
    	DEALLOCATE PREPARE statement;
    	
    	SET i = i + 1;
    END WHILE;
END;;
DELIMITER ;

-- THREATS
DELIMITER ;;
CREATE PROCEDURE duplicate_data_threats ()
BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE table_length INT DEFAULT 0;
    
    SET table_length = (SELECT COUNT(*) FROM `threats`);
    
    WHILE i < table_length DO
	
    	SET @current_threats_id = (SELECT `id` FROM threats LIMIT 1 OFFSET i);
    	
    	SET @query = CONCAT('INSERT INTO `translations` (`FR`, `EN`, `DE`, `NL`) SELECT `label1`, `label2`, `label3`, `label4` FROM `threats` LIMIT 1 OFFSET ', i) ;
    	PREPARE statement FROM @query; 
    	EXECUTE statement; 
    	DEALLOCATE PREPARE statement;
    	
    	SET @new_label_translation_id = (SELECT `id` FROM `translations` ORDER BY `id` DESC LIMIT 1);
    	
    	SET @query = CONCAT('UPDATE `threats` SET `label_translation_id` = ', @new_label_translation_id, ' WHERE `id` = ', @current_threats_id);
    	PREPARE statement FROM @query; 
    	EXECUTE statement; 
    	DEALLOCATE PREPARE statement;
    	
    	SET i = i + 1;
    END WHILE;
END;;
DELIMITER ;

-- VULNERABILITIES
DELIMITER ;;
CREATE PROCEDURE duplicate_data_vulnerabilities ()
BEGIN
    DECLARE i INT DEFAULT 0;
	DECLARE j INT DEFAULT 0;
    DECLARE table_length INT DEFAULT 0;
    
    SET table_length = (SELECT COUNT(*) FROM `vulnerabilities`);
    
    WHILE i < table_length DO
	
    	SET @current_vulnerabilities_id = (SELECT `id` FROM vulnerabilities LIMIT 1 OFFSET i);
    	
    	SET @query = CONCAT('INSERT INTO `translations` (`FR`, `EN`, `DE`, `NL`) SELECT `label1`, `label2`, `label3`, `label4` FROM `vulnerabilities` LIMIT 1 OFFSET ', i) ;
    	PREPARE statement FROM @query; 
    	EXECUTE statement; 
    	DEALLOCATE PREPARE statement;
    	
    	SET @new_label_translation_id = (SELECT `id` FROM `translations` ORDER BY `id` DESC LIMIT 1);
    	
    	SET @query = CONCAT('UPDATE `vulnerabilities` SET `label_translation_id` = ', @new_label_translation_id, ' WHERE `id` = ', @current_vulnerabilities_id);
    	PREPARE statement FROM @query; 
    	EXECUTE statement; 
    	DEALLOCATE PREPARE statement;
    	
    	SET i = i + 1;
    END WHILE;

	WHILE j < table_length DO
	
    	SET @current_vulnerabilities_id = (SELECT `id` FROM vulnerabilities LIMIT 1 OFFSET j);
    	
    	SET @query = CONCAT('INSERT INTO `translations` (`FR`, `EN`, `DE`, `NL`) SELECT `description1`, `description2`, `description3`, `description4` FROM `vulnerabilities` LIMIT 1 OFFSET ', j) ;
    	PREPARE statement FROM @query; 
    	EXECUTE statement; 
    	DEALLOCATE PREPARE statement;
    	
    	SET @new_description_translation_id = (SELECT `id` FROM `translations` ORDER BY `id` DESC LIMIT 1);
    	
    	SET @query = CONCAT('UPDATE `vulnerabilities` SET `description_translation_id` = ', @new_description_translation_id, ' WHERE `id` = ', @current_vulnerabilities_id);
    	PREPARE statement FROM @query; 
    	EXECUTE statement; 
    	DEALLOCATE PREPARE statement;
    	
    	SET j = j + 1;
	END WHILE;
END;;
DELIMITER ;


-- SCALES_COMMENTS
DELIMITER ;;
CREATE PROCEDURE duplicate_data_scales_comments ()
BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE table_length INT DEFAULT 0;
    
    SET table_length = (SELECT COUNT(*) FROM `scales_comments`); 
    
    WHILE i < table_length DO
	
    	SET @current_scales_comments_id = (SELECT `id` FROM scales_comments LIMIT 1 OFFSET i);
    	
    	SET @query = CONCAT('INSERT INTO `translations` (`FR`, `EN`, `DE`, `NL`) SELECT `comment1`, `comment2`, `comment3`, `comment4` FROM `scales_comments` LIMIT 1 OFFSET ', i) ;
    	PREPARE statement FROM @query; 
    	EXECUTE statement; 
    	DEALLOCATE PREPARE statement;
    	
    	SET @new_comment_translation_id = (SELECT `id` FROM `translations` ORDER BY `id` DESC LIMIT 1);
    	
    	SET @query = CONCAT('UPDATE `scales_comments` SET `comment_translation_id` = ', @new_comment_translation_id, ' WHERE `id` = ', @current_scales_comments_id);
    	PREPARE statement FROM @query; 
    	EXECUTE statement; 
    	DEALLOCATE PREPARE statement;
    	
    	SET i = i + 1;
    END WHILE;
END;;
DELIMITER ;


-- Procedure to delete old hard-codded translations columns in tables
DELIMITER ;;
CREATE PROCEDURE delete_old_translation_columns ()
BEGIN
	ALTER TABLE assets DROP COLUMN label1, DROP COLUMN label2, DROP COLUMN label3, DROP COLUMN label4, DROP COLUMN description1, DROP COLUMN description2, DROP COLUMN description3, DROP COLUMN description4;
	ALTER TABLE guides DROP COLUMN description1, DROP COLUMN description2, DROP COLUMN description3, DROP COLUMN description4;
	ALTER TABLE guides_items DROP COLUMN description1, DROP COLUMN description2, DROP COLUMN description3, DROP COLUMN description4;
	ALTER TABLE historicals DROP COLUMN label1, DROP COLUMN label2, DROP COLUMN label3, DROP COLUMN label4;
	ALTER TABLE assets DROP COLUMN label1, DROP COLUMN label2, DROP COLUMN label3, DROP COLUMN label4, DROP COLUMN name1, DROP COLUMN name2, DROP COLUMN name3, DROP COLUMN name4;
	ALTER TABLE measures DROP COLUMN description1, DROP COLUMN description2, DROP COLUMN description3, DROP COLUMN description4;
	ALTER TABLE models DROP COLUMN label1, DROP COLUMN label2, DROP COLUMN label3, DROP COLUMN label4, DROP COLUMN description1, DROP COLUMN description2, DROP COLUMN description3, DROP COLUMN description4;
	ALTER TABLE objects DROP COLUMN label1, DROP COLUMN label2, DROP COLUMN label3, DROP COLUMN label4, DROP COLUMN name1, DROP COLUMN name2, DROP COLUMN name3, DROP COLUMN name4;
	ALTER TABLE objects_categories DROP COLUMN label1, DROP COLUMN label2, DROP COLUMN label3, DROP COLUMN label4;
	ALTER TABLE questions DROP COLUMN label1, DROP COLUMN label2, DROP COLUMN label3, DROP COLUMN label4;
	ALTER TABLE questions_choices DROP COLUMN label1, DROP COLUMN label2, DROP COLUMN label3, DROP COLUMN label4;
	ALTER TABLE rolf_tags DROP COLUMN label1, DROP COLUMN label2, DROP COLUMN label3, DROP COLUMN label4;
	ALTER TABLE scales_comments DROP COLUMN comment1, DROP COLUMN comment2, DROP COLUMN comment3, DROP COLUMN comment4;
	ALTER TABLE scales_impact_types DROP COLUMN label1, DROP COLUMN label2, DROP COLUMN label3, DROP COLUMN label4;
	ALTER TABLE themes DROP COLUMN label1, DROP COLUMN label2, DROP COLUMN label3, DROP COLUMN label4;
	ALTER TABLE threats DROP COLUMN label1, DROP COLUMN label2, DROP COLUMN label3, DROP COLUMN label4;
	ALTER TABLE rolf_risks DROP COLUMN label1, DROP COLUMN label2, DROP COLUMN label3, DROP COLUMN label4, DROP COLUMN description1, DROP COLUMN description2, DROP COLUMN description3, DROP COLUMN description4;
	ALTER TABLE vulnerabilities DROP COLUMN label1, DROP COLUMN label2, DROP COLUMN label3, DROP COLUMN label4, DROP COLUMN description1, DROP COLUMN description2, DROP COLUMN description3, DROP COLUMN description4;
END;;
DELIMITER ;



