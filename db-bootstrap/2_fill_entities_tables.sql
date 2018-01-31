-- Procedures to fill translations_id columns (for entity tables)

-- ANRS
DROP PROCEDURE IF EXISTS fill_anrs_data;
DELIMITER ;;
CREATE PROCEDURE fill_anrs_data ()
BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE j INT DEFAULT 0;
    DECLARE entity_table_length INT DEFAULT 0;
    DECLARE entity_description_translation_id INT DEFAULT 0;
    DECLARE entity_label_translation_id INT DEFAULT 0;
    
    SET entity_table_length = (SELECT COUNT(*) FROM `anrs`); 

    WHILE i < entity_table_length DO
        SET entity_description_translation_id = i + 1;
        
        SET @entity_id = (SELECT `id` FROM `anrs` LIMIT 1 OFFSET i);

        SET @query = CONCAT('UPDATE `anrs` SET `description_translation_id` = ', entity_description_translation_id, ' WHERE `id` = ', @entity_id);
        PREPARE statement FROM @query; 
        EXECUTE statement; 
        DEALLOCATE PREPARE statement;
        
        SET i = i + 1;

        IF i = entity_table_length THEN SET @entity_id_for_following_translation = i + 1;
        END IF;
    END WHILE;

    WHILE j < entity_table_length DO
        SET entity_label_translation_id = @entity_id_for_following_translation;
        
        SET @entity_id = (SELECT `id` FROM `anrs` LIMIT 1 OFFSET j);

        SET @query = CONCAT('UPDATE `anrs` SET `label_translation_id` = ', entity_label_translation_id, ' WHERE `id` = ', @entity_id);
        PREPARE statement FROM @query; 
        EXECUTE statement; 
        DEALLOCATE PREPARE statement;
        
        SET j = j + 1;
        SET @entity_id_for_following_translation = @entity_id_for_following_translation + 1;
    END WHILE;

END;;
DELIMITER ;

-- ASSETS
DROP PROCEDURE IF EXISTS fill_assets_data;
DELIMITER ;;
CREATE PROCEDURE fill_assets_data ()
BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE j INT DEFAULT 0;
    DECLARE entity_table_length INT DEFAULT 0;
    DECLARE entity_description_translation_id INT DEFAULT 0;
    DECLARE entity_label_translation_id INT DEFAULT 0;
    
    SET entity_table_length = (SELECT COUNT(*) FROM `assets`); 

    WHILE i < entity_table_length DO
        SET entity_description_translation_id = i + 1;
        
        SET @entity_id = (SELECT `id` FROM `assets` LIMIT 1 OFFSET i);

        SET @query = CONCAT('UPDATE `assets` SET `description_translation_id` = ', entity_description_translation_id, ' WHERE `id` = ', @entity_id);
        PREPARE statement FROM @query; 
        EXECUTE statement; 
        DEALLOCATE PREPARE statement;
        
        SET i = i + 1;

        IF i = entity_table_length THEN SET @entity_id_for_following_translation = i + 1;
        END IF;
    END WHILE;

    WHILE j < entity_table_length DO
        SET entity_label_translation_id = @entity_id_for_following_translation;
        
        SET @entity_id = (SELECT `id` FROM `assets` LIMIT 1 OFFSET j);

        SET @query = CONCAT('UPDATE `assets` SET `label_translation_id` = ', entity_label_translation_id, ' WHERE `id` = ', @entity_id);
        PREPARE statement FROM @query; 
        EXECUTE statement; 
        DEALLOCATE PREPARE statement;
        
        SET j = j + 1;
        SET @entity_id_for_following_translation = @entity_id_for_following_translation + 1;
    END WHILE;

END;;
DELIMITER ;

-- GUIDES 
DROP PROCEDURE IF EXISTS fill_guides_data;
DELIMITER ;;
CREATE PROCEDURE fill_guides_data ()
BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE entity_table_length INT DEFAULT 0;
    DECLARE entity_description_translation_id INT DEFAULT 0;
    
    SET entity_table_length = (SELECT COUNT(*) FROM `guides`); 

    WHILE i < entity_table_length DO
        SET entity_description_translation_id = i + 1;
        
        SET @entity_id = (SELECT `id` FROM `guides` LIMIT 1 OFFSET i);

        SET @query = CONCAT('UPDATE `guides` SET `description_translation_id` = ', entity_description_translation_id, ' WHERE `id` = ', @entity_id);
        PREPARE statement FROM @query; 
        EXECUTE statement; 
        DEALLOCATE PREPARE statement;
        
        SET i = i + 1;
    END WHILE;
END;;
DELIMITER ;

-- GUIDES_ITEMS 
DROP PROCEDURE IF EXISTS fill_guides_items_data;
DELIMITER ;;
CREATE PROCEDURE fill_guides_items_data ()
BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE entity_table_length INT DEFAULT 0;
    DECLARE entity_description_translation_id INT DEFAULT 0;
    
    SET entity_table_length = (SELECT COUNT(*) FROM `guides_items`); 

    WHILE i < entity_table_length DO
        SET entity_description_translation_id = i + 1;
        
        SET @entity_id = (SELECT `id` FROM `guides_items` LIMIT 1 OFFSET i);

        SET @query = CONCAT('UPDATE `guides_items` SET `description_translation_id` = ', entity_description_translation_id, ' WHERE `id` = ', @entity_id);
        PREPARE statement FROM @query; 
        EXECUTE statement; 
        DEALLOCATE PREPARE statement;
        
        SET i = i + 1;
    END WHILE;
END;;
DELIMITER ;

-- HISTORICALS
DROP PROCEDURE IF EXISTS fill_historicals_data;
DELIMITER ;;
CREATE PROCEDURE fill_historicals_data ()
BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE entity_table_length INT DEFAULT 0;
    DECLARE entity_label_translation_id INT DEFAULT 0;
    
    SET entity_table_length = (SELECT COUNT(*) FROM `historicals`); 

    WHILE i < entity_table_length DO
        SET entity_label_translation_id = i + 1;
        
        SET @entity_id = (SELECT `id` FROM `historicals` LIMIT 1 OFFSET i);

        SET @query = CONCAT('UPDATE `historicals` SET `label_translation_id` = ', entity_label_translation_id, ' WHERE `id` = ', @entity_id);
        PREPARE statement FROM @query; 
        EXECUTE statement; 
        DEALLOCATE PREPARE statement;
        
        SET i = i + 1;
    END WHILE;
END;;
DELIMITER ;

-- INSTANCES
DROP PROCEDURE IF EXISTS fill_instances_data;
DELIMITER ;;
CREATE PROCEDURE fill_instances_data ()
BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE j INT DEFAULT 0;
    DECLARE entity_table_length INT DEFAULT 0;
    DECLARE entity_name_translation_id INT DEFAULT 0;
    DECLARE entity_label_translation_id INT DEFAULT 0;
    
    SET entity_table_length = (SELECT COUNT(*) FROM `instances`); 

    WHILE i < entity_table_length DO
        SET entity_name_translation_id = i + 1;
        
        SET @entity_id = (SELECT `id` FROM `instances` LIMIT 1 OFFSET i);

        SET @query = CONCAT('UPDATE `instances` SET `name_translation_id` = ', entity_name_translation_id, ' WHERE `id` = ', @entity_id);
        PREPARE statement FROM @query; 
        EXECUTE statement; 
        DEALLOCATE PREPARE statement;
        
        SET i = i + 1;

        IF i = entity_table_length THEN SET @entity_id_for_following_translation = i + 1;
        END IF;
    END WHILE;

    WHILE j < entity_table_length DO
        SET entity_label_translation_id = @entity_id_for_following_translation;
        
        SET @entity_id = (SELECT `id` FROM `instances` LIMIT 1 OFFSET j);

        SET @query = CONCAT('UPDATE `instances` SET `label_translation_id` = ', entity_label_translation_id, ' WHERE `id` = ', @entity_id);
        PREPARE statement FROM @query; 
        EXECUTE statement; 
        DEALLOCATE PREPARE statement;
        
        SET j = j + 1;
        SET @entity_id_for_following_translation = @entity_id_for_following_translation + 1;
    END WHILE;

END;;
DELIMITER ;


-- MEASURES
DROP PROCEDURE IF EXISTS fill_measures_data;
DELIMITER ;;
CREATE PROCEDURE fill_measures_data ()
BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE entity_table_length INT DEFAULT 0;
    DECLARE entity_description_translation_id INT DEFAULT 0;
    
    SET entity_table_length = (SELECT COUNT(*) FROM `measures`); 

    WHILE i < entity_table_length DO
        SET entity_description_translation_id = i + 1;
        
        SET @entity_id = (SELECT `id` FROM `measures` LIMIT 1 OFFSET i);

        SET @query = CONCAT('UPDATE `measures` SET `description_translation_id` = ', entity_description_translation_id, ' WHERE `id` = ', @entity_id);
        PREPARE statement FROM @query; 
        EXECUTE statement; 
        DEALLOCATE PREPARE statement;
        
        SET i = i + 1;
    END WHILE;
END;;
DELIMITER ;

-- MODELS
DROP PROCEDURE IF EXISTS fill_models_data;
DELIMITER ;;
CREATE PROCEDURE fill_models_data ()
BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE j INT DEFAULT 0;
    DECLARE entity_table_length INT DEFAULT 0;
    DECLARE entity_description_translation_id INT DEFAULT 0;
    DECLARE entity_label_translation_id INT DEFAULT 0;
    
    SET entity_table_length = (SELECT COUNT(*) FROM `models`); 

    WHILE i < entity_table_length DO
        SET entity_description_translation_id = i + 1;
        
        SET @entity_id = (SELECT `id` FROM `models` LIMIT 1 OFFSET i);

        SET @query = CONCAT('UPDATE `models` SET `description_translation_id` = ', entity_description_translation_id, ' WHERE `id` = ', @entity_id);
        PREPARE statement FROM @query; 
        EXECUTE statement; 
        DEALLOCATE PREPARE statement;
        
        SET i = i + 1;

        IF i = entity_table_length THEN SET @entity_id_for_following_translation = i + 1;
        END IF;
    END WHILE;

    WHILE j < entity_table_length DO
        SET entity_label_translation_id = @entity_id_for_following_translation;
        
        SET @entity_id = (SELECT `id` FROM `models` LIMIT 1 OFFSET j);

        SET @query = CONCAT('UPDATE `models` SET `label_translation_id` = ', entity_label_translation_id, ' WHERE `id` = ', @entity_id);
        PREPARE statement FROM @query; 
        EXECUTE statement; 
        DEALLOCATE PREPARE statement;
        
        SET j = j + 1;
        SET @entity_id_for_following_translation = @entity_id_for_following_translation + 1;
    END WHILE;

END;;
DELIMITER ;

-- OBJECTS
DROP PROCEDURE IF EXISTS fill_objects_data;
DELIMITER ;;
CREATE PROCEDURE fill_objects_data ()
BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE j INT DEFAULT 0;
    DECLARE entity_table_length INT DEFAULT 0;
    DECLARE entity_name_translation_id INT DEFAULT 0;
    DECLARE entity_label_translation_id INT DEFAULT 0;
    
    SET entity_table_length = (SELECT COUNT(*) FROM `objects`); 

    WHILE i < entity_table_length DO
        SET entity_name_translation_id = i + 1;
        
        SET @entity_id = (SELECT `id` FROM `objects` LIMIT 1 OFFSET i);

        SET @query = CONCAT('UPDATE `objects` SET `name_translation_id` = ', entity_name_translation_id, ' WHERE `id` = ', @entity_id);
        PREPARE statement FROM @query; 
        EXECUTE statement; 
        DEALLOCATE PREPARE statement;
        
        SET i = i + 1;

        IF i = entity_table_length THEN SET @entity_id_for_following_translation = i + 1;
        END IF;
    END WHILE;

    WHILE j < entity_table_length DO
        SET entity_label_translation_id = @entity_id_for_following_translation;
        
        SET @entity_id = (SELECT `id` FROM `objects` LIMIT 1 OFFSET j);

        SET @query = CONCAT('UPDATE `objects` SET `label_translation_id` = ', entity_label_translation_id, ' WHERE `id` = ', @entity_id);
        PREPARE statement FROM @query; 
        EXECUTE statement; 
        DEALLOCATE PREPARE statement;
        
        SET j = j + 1;
        SET @entity_id_for_following_translation = @entity_id_for_following_translation + 1;
    END WHILE;

END;;
DELIMITER ;

-- OBJECTS_CATEGORIES
DROP PROCEDURE IF EXISTS fill_objects_categories_data;
DELIMITER ;;
CREATE PROCEDURE fill_objects_categories_data ()
BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE entity_table_length INT DEFAULT 0;
    DECLARE entity_label_translation_id INT DEFAULT 0;
    
    SET entity_table_length = (SELECT COUNT(*) FROM `objects_categories`); 

    WHILE i < entity_table_length DO
        SET entity_label_translation_id = i + 1;
        
        SET @entity_id = (SELECT `id` FROM `objects_categories` LIMIT 1 OFFSET i);

        SET @query = CONCAT('UPDATE `objects_categories` SET `label_translation_id` = ', entity_label_translation_id, ' WHERE `id` = ', @entity_id);
        PREPARE statement FROM @query; 
        EXECUTE statement; 
        DEALLOCATE PREPARE statement;
        
        SET i = i + 1;
    END WHILE;
END;;
DELIMITER ;

-- QUESTIONS
DROP PROCEDURE IF EXISTS fill_questions_data;
DELIMITER ;;
CREATE PROCEDURE fill_questions_data ()
BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE entity_table_length INT DEFAULT 0;
    DECLARE entity_label_translation_id INT DEFAULT 0;
    
    SET entity_table_length = (SELECT COUNT(*) FROM `questions`); 

    WHILE i < entity_table_length DO
        SET entity_label_translation_id = i + 1;
        
        SET @entity_id = (SELECT `id` FROM `questions` LIMIT 1 OFFSET i);

        SET @query = CONCAT('UPDATE `questions` SET `label_translation_id` = ', entity_label_translation_id, ' WHERE `id` = ', @entity_id);
        PREPARE statement FROM @query; 
        EXECUTE statement; 
        DEALLOCATE PREPARE statement;
        
        SET i = i + 1;
    END WHILE;
END;;
DELIMITER ;

-- QUESTIONS_CHOICES
DROP PROCEDURE IF EXISTS fill_questions_choices;
DELIMITER ;;
CREATE PROCEDURE fill_questions_choices_data ()
BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE entity_table_length INT DEFAULT 0;
    DECLARE entity_label_translation_id INT DEFAULT 0;
    
    SET entity_table_length = (SELECT COUNT(*) FROM `questions_choices`); 

    WHILE i < entity_table_length DO
        SET entity_label_translation_id = i + 1;
        
        SET @entity_id = (SELECT `id` FROM `questions_choices` LIMIT 1 OFFSET i);

        SET @query = CONCAT('UPDATE `questions_choices` SET `label_translation_id` = ', entity_label_translation_id, ' WHERE `id` = ', @entity_id);
        PREPARE statement FROM @query; 
        EXECUTE statement; 
        DEALLOCATE PREPARE statement;
        
        SET i = i + 1;
    END WHILE;
END;;
DELIMITER ;


-- ROLF_RISKS
DROP PROCEDURE IF EXISTS fill_rolf_risks_data;
DELIMITER ;;
CREATE PROCEDURE fill_rolf_risks_data ()
BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE j INT DEFAULT 0;
    DECLARE entity_table_length INT DEFAULT 0;
    DECLARE entity_description_translation_id INT DEFAULT 0;
    DECLARE entity_label_translation_id INT DEFAULT 0;
    
    SET entity_table_length = (SELECT COUNT(*) FROM `rolf_risks`); 

    WHILE i < entity_table_length DO
        SET entity_description_translation_id = i + 1;
        
        SET @entity_id = (SELECT `id` FROM `rolf_risks` LIMIT 1 OFFSET i);

        SET @query = CONCAT('UPDATE `rolf_risks` SET `description_translation_id` = ', entity_description_translation_id, ' WHERE `id` = ', @entity_id);
        PREPARE statement FROM @query; 
        EXECUTE statement; 
        DEALLOCATE PREPARE statement;
        
        SET i = i + 1;

        IF i = entity_table_length THEN SET @entity_id_for_following_translation = i + 1;
        END IF;
    END WHILE;

    WHILE j < entity_table_length DO
        SET entity_label_translation_id = @entity_id_for_following_translation;
        
        SET @entity_id = (SELECT `id` FROM `rolf_risks` LIMIT 1 OFFSET j);

        SET @query = CONCAT('UPDATE `rolf_risks` SET `label_translation_id` = ', entity_label_translation_id, ' WHERE `id` = ', @entity_id);
        PREPARE statement FROM @query; 
        EXECUTE statement; 
        DEALLOCATE PREPARE statement;
        
        SET j = j + 1;
        SET @entity_id_for_following_translation = @entity_id_for_following_translation + 1;
    END WHILE;

END;;
DELIMITER ;


-- ROLF_TAGS
DROP PROCEDURE IF EXISTS fill_rolf_tags_data;
DELIMITER ;;
CREATE PROCEDURE fill_rolf_tags_data ()
BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE entity_table_length INT DEFAULT 0;
    DECLARE entity_label_translation_id INT DEFAULT 0;
    
    SET entity_table_length = (SELECT COUNT(*) FROM `rolf_tags`); 

    WHILE i < entity_table_length DO
        SET entity_label_translation_id = i + 1;
        
        SET @entity_id = (SELECT `id` FROM `rolf_tags` LIMIT 1 OFFSET i);

        SET @query = CONCAT('UPDATE `rolf_tags` SET `label_translation_id` = ', entity_label_translation_id, ' WHERE `id` = ', @entity_id);
        PREPARE statement FROM @query; 
        EXECUTE statement; 
        DEALLOCATE PREPARE statement;
        
        SET i = i + 1;
    END WHILE;
END;;
DELIMITER ;

-- SCALES_COMMENTS
DROP PROCEDURE IF EXISTS fill_scales_comments_data;
DELIMITER ;;
CREATE PROCEDURE fill_scales_comments_data ()
BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE entity_table_length INT DEFAULT 0;
    DECLARE entity_comment_translation_id INT DEFAULT 0;
    
    SET entity_table_length = (SELECT COUNT(*) FROM `scales_comments`); 

    WHILE i < entity_table_length DO
        SET entity_comment_translation_id = i + 1;
        
        SET @entity_id = (SELECT `id` FROM `scales_comments` LIMIT 1 OFFSET i);

        SET @query = CONCAT('UPDATE `scales_comments` SET `comment_translation_id` = ', entity_comment_translation_id, ' WHERE `id` = ', @entity_id);
        PREPARE statement FROM @query; 
        EXECUTE statement; 
        DEALLOCATE PREPARE statement;
        
        SET i = i + 1;
    END WHILE;
END;;
DELIMITER ;

-- SCALES_IMPACT_TYPES
DROP PROCEDURE IF EXISTS fill_scales_impact_types_data;
DELIMITER ;;
CREATE PROCEDURE fill_scales_impact_types_data ()
BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE entity_table_length INT DEFAULT 0;
    DECLARE entity_label_translation_id INT DEFAULT 0;
    
    SET entity_table_length = (SELECT COUNT(*) FROM `scales_impact_types`); 

    WHILE i < entity_table_length DO
        SET entity_label_translation_id = i + 1;
        
        SET @entity_id = (SELECT `id` FROM `scales_impact_types` LIMIT 1 OFFSET i);

        SET @query = CONCAT('UPDATE `scales_impact_types` SET `label_translation_id` = ', entity_label_translation_id, ' WHERE `id` = ', @entity_id);
        PREPARE statement FROM @query; 
        EXECUTE statement; 
        DEALLOCATE PREPARE statement;
        
        SET i = i + 1;
    END WHILE;
END;;
DELIMITER ;

-- THEMES
DROP PROCEDURE IF EXISTS fill_themes_data;
DELIMITER ;;
CREATE PROCEDURE fill_themes_data ()
BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE entity_table_length INT DEFAULT 0;
    DECLARE entity_label_translation_id INT DEFAULT 0;
    
    SET entity_table_length = (SELECT COUNT(*) FROM `themes`); 

    WHILE i < entity_table_length DO
        SET entity_label_translation_id = i + 1;
        
        SET @entity_id = (SELECT `id` FROM `themes` LIMIT 1 OFFSET i);

        SET @query = CONCAT('UPDATE `themes` SET `label_translation_id` = ', entity_label_translation_id, ' WHERE `id` = ', @entity_id);
        PREPARE statement FROM @query; 
        EXECUTE statement; 
        DEALLOCATE PREPARE statement;
        
        SET i = i + 1;
    END WHILE;
END;;
DELIMITER ;

-- THREATS
DROP PROCEDURE IF EXISTS fill_threats_data;
DELIMITER ;;
CREATE PROCEDURE fill_threats_data ()
BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE j INT DEFAULT 0;
    DECLARE entity_table_length INT DEFAULT 0;
    DECLARE entity_description_translation_id INT DEFAULT 0;
    DECLARE entity_label_translation_id INT DEFAULT 0;
    
    SET entity_table_length = (SELECT COUNT(*) FROM `threats`); 

    WHILE i < entity_table_length DO
        SET entity_description_translation_id = i + 1;
        
        SET @entity_id = (SELECT `id` FROM `threats` LIMIT 1 OFFSET i);

        SET @query = CONCAT('UPDATE `threats` SET `description_translation_id` = ', entity_description_translation_id, ' WHERE `id` = ', @entity_id);
        PREPARE statement FROM @query; 
        EXECUTE statement; 
        DEALLOCATE PREPARE statement;
        
        SET i = i + 1;

        IF i = entity_table_length THEN SET @entity_id_for_following_translation = i + 1;
        END IF;
    END WHILE;

    WHILE j < entity_table_length DO
        SET entity_label_translation_id = @entity_id_for_following_translation;
        
        SET @entity_id = (SELECT `id` FROM `threats` LIMIT 1 OFFSET j);

        SET @query = CONCAT('UPDATE `threats` SET `label_translation_id` = ', entity_label_translation_id, ' WHERE `id` = ', @entity_id);
        PREPARE statement FROM @query; 
        EXECUTE statement; 
        DEALLOCATE PREPARE statement;
        
        SET j = j + 1;
        SET @entity_id_for_following_translation = @entity_id_for_following_translation + 1;
    END WHILE;

END;;
DELIMITER ;

-- VULNERABILITIES
DROP PROCEDURE IF EXISTS fill_vulnerabilities_data;
DELIMITER ;;
CREATE PROCEDURE fill_vulnerabilities_data ()
BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE j INT DEFAULT 0;
    DECLARE entity_table_length INT DEFAULT 0;
    DECLARE entity_description_translation_id INT DEFAULT 0;
    DECLARE entity_label_translation_id INT DEFAULT 0;
    
    SET entity_table_length = (SELECT COUNT(*) FROM `vulnerabilities`); 

    WHILE i < entity_table_length DO
        SET entity_description_translation_id = i + 1;
        
        SET @entity_id = (SELECT `id` FROM `vulnerabilities` LIMIT 1 OFFSET i);

        SET @query = CONCAT('UPDATE `vulnerabilities` SET `description_translation_id` = ', entity_description_translation_id, ' WHERE `id` = ', @entity_id);
        PREPARE statement FROM @query; 
        EXECUTE statement; 
        DEALLOCATE PREPARE statement;
        
        SET i = i + 1;

        IF i = entity_table_length THEN SET @entity_id_for_following_translation = i + 1;
        END IF;
    END WHILE;

    WHILE j < entity_table_length DO
        SET entity_label_translation_id = @entity_id_for_following_translation;
        
        SET @entity_id = (SELECT `id` FROM `vulnerabilities` LIMIT 1 OFFSET j);

        SET @query = CONCAT('UPDATE `vulnerabilities` SET `label_translation_id` = ', entity_label_translation_id, ' WHERE `id` = ', @entity_id);
        PREPARE statement FROM @query; 
        EXECUTE statement; 
        DEALLOCATE PREPARE statement;
        
        SET j = j + 1;
        SET @entity_id_for_following_translation = @entity_id_for_following_translation + 1;
    END WHILE;

END;;
DELIMITER ;


-- INSTANCES_RISKS_OP
DROP PROCEDURE IF EXISTS fill_instances_risks_op_data;
DELIMITER ;;
CREATE PROCEDURE fill_instances_risks_op_data ()
    BEGIN
        DECLARE i INT DEFAULT 0;
        DECLARE j INT DEFAULT 0;
        DECLARE entity_table_length INT DEFAULT 0;
        DECLARE entity_description_translation_id INT DEFAULT 0;
        DECLARE entity_label_translation_id INT DEFAULT 0;

        SET entity_table_length = (SELECT COUNT(*) FROM `instances_risks_op`);

        WHILE i < entity_table_length DO
            SET entity_description_translation_id = i + 1;

            SET @entity_id = (SELECT `id` FROM `instances_risks_op` LIMIT 1 OFFSET i);

            SET @query = CONCAT('UPDATE `vulnerabilities` SET `risk_cache_description_translation_id` = ', entity_description_translation_id, ' WHERE `id` = ', @entity_id);
            PREPARE statement FROM @query;
            EXECUTE statement;
            DEALLOCATE PREPARE statement;

            SET i = i + 1;

            IF i = entity_table_length THEN SET @entity_id_for_following_translation = i + 1;
            END IF;
        END WHILE;

        WHILE j < entity_table_length DO
            SET entity_label_translation_id = @entity_id_for_following_translation;

            SET @entity_id = (SELECT `id` FROM `instances_risks_op` LIMIT 1 OFFSET j);

            SET @query = CONCAT('UPDATE `vulnerabilities` SET `risk_cache_label_translation_id` = ', entity_label_translation_id, ' WHERE `id` = ', @entity_id);
            PREPARE statement FROM @query;
            EXECUTE statement;
            DEALLOCATE PREPARE statement;

            SET j = j + 1;
            SET @entity_id_for_following_translation = @entity_id_for_following_translation + 1;
        END WHILE;

    END;;
DELIMITER ;

-- Call procedures
CALL `fill_anrs_data`;
CALL `fill_assets_data`;
CALL `fill_guides_data`;
CALL `fill_guides_items_data`;
CALL `fill_historicals_data`;
CALL `fill_instances_data`;
CALL `fill_measures_data`;
CALL `fill_models_data`;
CALL `fill_objects_data`;
CALL `fill_objects_categories_data`;
CALL `fill_questions_data`;
CALL `fill_questions_choices_data`;
CALL `fill_rolf_risks_data`;
CALL `fill_rolf_tags_data`;
CALL `fill_scales_comments_data`;
CALL `fill_scales_impact_types_data`;
CALL `fill_themes_data`;
CALL `fill_threats_data`;
CALL `fill_vulnerabilities_data`;
CALL `fill_instances_risks_op_data`;