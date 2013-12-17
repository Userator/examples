DROP TABLE IF EXISTS `quitsmoking_text`;

CREATE TABLE `quitsmoking_text` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT COMMENT 'номер',
  `sn` smallint(3) unsigned NOT NULL COMMENT 'порядковый номер',
  `uuid` varchar(36) NOT NULL COMMENT 'ключ',
  `text_sms` text NOT NULL COMMENT 'короткий текст',
  `text_wap` text NOT NULL COMMENT 'длинный текст',
  PRIMARY KEY (`id`),
  UNIQUE KEY `sn` (`sn`),
  UNIQUE KEY `uuid` (`uuid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='бросай курить';

DELIMITER $$
CREATE TRIGGER `uuid_before_insert_quitsmoking_text` BEFORE INSERT ON `quitsmoking_text` FOR EACH ROW
BEGIN
IF NEW.`uuid` = '' THEN
SET NEW.`uuid` = (SELECT UUID());
END IF;
END$$
DELIMITER ;

INSERT INTO `quitsmoking_text` (`id`, `sn`, `uuid`, `text_sms`, `text_wap`) VALUES
(1,1,'8473e3b5-382a-4c2b-644f-c14991c8c6f8','Оцените, насколько Вы зависимы?  Заполните тест Фагестрема.','Я курю, потому что не могу не курить! \n Оцените, насколько Вы зависимы?   \n Это, наверное, зависимость! А можно ли измерить степень своей никотиновой зависимости? \nСпециальный тест - тест Фагестрема поможет оценить степень никотиновой зависимости: Просто ответьте на вопросы и считайте баллы! \n• 1. Как скоро после того, как Вы проснулись, Вы выкуриваете 1сигарету? \nа) В течение первых 5мин - 3\nб) В течение 6-30мин - 2\nв) 30 мин- 60 мин - 1\nг) Более чем 60 мин - 0 \n• 2. Сложно ли для Вас воздержаться от курения в местах, где курение запрещено?\nа)Да - 1\nб)Нет - 0 \n• 3. От какой сигареты Вы не можете легко отказаться?\nа) Первая утром - 1\nб) Все остальные - 0 \n• 4. Сколько сигарет Вы выкуриваете в день?\nа) 10 или меньше - 0\nб) 11-12 - 1\nв) 21-30 - 2\nг) 31 и более - 3 \n• 5. Вы курите более часто в первые часы утром, после того, как проснетесь, чем в течение последующего дня?\nа) Да - 1\nб) Нет - 0 \n• 6. Курите ли Вы, если сильно больны и вынуждены находиться в кровати целый день?\nа) Да - 1\nб) Нет - 0\nИтак, сумма баллов: \n0-2  - у меня очень слабая зависимость, я справлюсь! \n3-4  - у меня слабая зависимость, может, в самом деле, взять и бросить курить! \n5 -  у меня средняя зависимость, надо подумать! \n6-7  - у меня  высокая зависимость! Что же делать, надо бежать за помощью! \n8-10 - у меня  очень высокая зависимость! Точно надо искать помощь!'),
(2,2,'e0596b40-23e2-0eb2-be85-9c7504d75f0b','Направление Вам рекомендаций начнется завтра. Программа Бросай курить разработана специалистами НП «НО Кардиоваскулярной профилактики и реабилитации» www.cardioprevent.ru',''),
(3,3,'466f1514-4759-92f3-153f-ce3f0e531f42','Каждые 6,5 секунд на планете умирает 1 человек от болезни, связанной с использованием табака.','');

DROP PROCEDURE IF EXISTS `getNextQuitsmokingTextByMSISDN`;

DELIMITER $$
CREATE PROCEDURE `getNextQuitsmokingTextByMSISDN`(IN `inmsisdn` BIGINT(11), `inreset` BOOL)
BEGIN
DECLARE `vsn` INT;
DECLARE `vsnmin` INT;
DECLARE `vsnmax` INT;
DECLARE `vsncurr` INT;
START TRANSACTION;
SET `vsn` = (SELECT `sn` FROM `quitsmoking_send` WHERE `msisdn` = `inmsisdn` LIMIT 1);
SET `vsnmin` = 1;
SET `vsnmax` = (SELECT MAX(`sn`) FROM `quitsmoking_text`);
SET `vsncurr` = 1;
IF `inreset` = TRUE THEN
SET `vsn` = 0;
END IF;
IF NOT ISNULL(`vsn`) AND `vsn` >= `vsnmin` AND `vsn` <= `vsnmax` - 1 THEN 
SET `vsncurr` = `vsn` + 1;
END IF;
INSERT INTO `quitsmoking_send` (`msisdn`, `sn`) VALUES (`inmsisdn`, `vsncurr`) ON DUPLICATE KEY UPDATE `sn` = `vsncurr`;
SELECT * FROM `quitsmoking_text` WHERE `sn` = `vsncurr`;
COMMIT;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS `getNextLoseWeightTextByMSISDN`;

DELIMITER $$
CREATE PROCEDURE `getNextLoseWeightTextByMSISDN`(IN `inmsisdn` BIGINT(11), `inreset` BOOL)
BEGIN
DECLARE `vsn` INT;
DECLARE `vsnmin` INT;
DECLARE `vsnmax` INT;
DECLARE `vsncurr` INT;
START TRANSACTION;
SET `vsn` = (SELECT `sn` FROM `loseweight_send` WHERE `msisdn` = `inmsisdn` LIMIT 1);
SET `vsnmin` = 1;
SET `vsnmax` = (SELECT MAX(`sn`) FROM `loseweight_text`);
SET `vsncurr` = 1;
IF `inreset` = TRUE THEN
SET `vsn` = 0;
END IF;
IF NOT ISNULL(`vsn`) AND `vsn` >= `vsnmin` AND `vsn` <= `vsnmax` - 1 THEN 
SET `vsncurr` = `vsn` + 1;
END IF;
INSERT INTO `loseweight_send` (`msisdn`, `sn`) VALUES (`inmsisdn`, `vsncurr`) ON DUPLICATE KEY UPDATE `sn` = `vsncurr`;
SELECT * FROM `loseweight_text` WHERE `sn` = `vsncurr`;
COMMIT;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS `getNextPregnancyTextByMSISDN`;

DELIMITER $$
CREATE PROCEDURE `getNextPregnancyTextByMSISDN`(IN `inmsisdn` BIGINT(11), IN `inweek` SMALLINT(2))
BEGIN
DECLARE `vsn` INT;
DECLARE `vsnmin` INT;
DECLARE `vsnmax` INT;
DECLARE `vsncurr` INT;
START TRANSACTION;
SET `vsn` = (SELECT `sn` FROM `pregnancy_send` WHERE `msisdn` = `inmsisdn` LIMIT 1);
SET `vsnmin` = 1;
SET `vsnmax` = 42;
SET `vsncurr` = 1;
IF NOT ISNULL(`vsn`) AND `vsn` >= `vsnmin` AND `vsn` <= `vsnmax` - 1 THEN 
SET `vsncurr` = `vsn` + 1;
END IF;
IF `inweek` >= `vsnmin` AND `inweek` <= `vsnmax` THEN 
SET `vsncurr` = `inweek`;
END IF;
INSERT INTO `pregnancy_send` (`msisdn`, `sn`) VALUES (`inmsisdn`, `vsncurr`) ON DUPLICATE KEY UPDATE `sn` = `vsncurr`;
	SELECT * FROM `pregnancy_text` WHERE `sn` = `vsncurr`;
    COMMIT; 
END$$
DELIMITER ;
