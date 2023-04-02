DROP PROCEDURE IF EXISTS `SkillsOntario`.`sp_createUser`;
DROP PROCEDURE IF EXISTS `SkillsOntario`.`sp_validateLogin`;
DROP TABLE IF EXISTS `SkillsOntario`.`tbl_user`;
DROP SCHEMA IF EXISTS SkillsOntario;

CREATE SCHEMA SkillsOntario;

CREATE TABLE `SkillsOntario`.`tbl_user` (
  `user_id` BIGINT UNIQUE AUTO_INCREMENT,
  `user_name` VARCHAR(45) NULL,
  `user_username` VARCHAR(45) NULL,
  `user_password` VARCHAR(200) NULL,
  PRIMARY KEY (`user_id`));
  
  DELIMITER $$
CREATE PROCEDURE `SkillsOntario`.`sp_createUser`(
    IN p_name VARCHAR(20),
    IN p_username VARCHAR(50),
    IN p_password VARCHAR(200)
)
BEGIN
    if ( select exists (select 1 from tbl_user where user_username = p_username) ) THEN
     
        select 'Username Exists !!';
     
    ELSE
     
        insert into SkillsOntario.tbl_user
        (
            user_name,
            user_username,
            user_password
        )
        values
        (
            p_name,
            p_username,
            p_password
        );
     
    END IF;
END$$
DELIMITER ;


DELIMITER $$
CREATE PROCEDURE `SkillsOntario`.`sp_validateLogin`(
IN p_username VARCHAR(50)
)
BEGIN
    select * from SkillsOntario.tbl_user where user_username = p_username;
END$$
DELIMITER ;
