CREATE TABLE IF NOT EXISTS `user` (
  `id_user` INT UNSIGNED UNIQUE AUTO_INCREMENT NOT NULL,
  `pseudo` VARCHAR(64) NOT NULL,
  `email` VARCHAR(254) UNIQUE NOT NULL,
  `password` CHAR(128) NOT NULL,

  `pref_mail_notifications` BOOLEAN DEFAULT true,

  PRIMARY KEY (`id_user`),

  UNIQUE KEY(`email`)
);




CREATE TABLE IF NOT EXISTS `account_verification` (
	`account_verification_key` INT UNSIGNED NOT NULL,
	`id_user` INT UNSIGNED UNIQUE NOT NULL,

	UNIQUE KEY (`account_verification_key`, `id_user`),

	FOREIGN KEY (`id_user`)
    REFERENCES `user`(`id_user`)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);




CREATE TABLE IF NOT EXISTS `account_retrieval_requests` (
	`account_retrieval_request_key` INT UNSIGNED NOT NULL,
	`id_user` INT UNSIGNED UNIQUE NOT NULL,

	UNIQUE KEY (`account_retrieval_request_key`, `id_user`),

	FOREIGN KEY (`id_user`)
    REFERENCES `user`(`id_user`)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);





-- CREATE TABLE IF NOT EXISTS `cookie` (
--   `id_cookie` INT UNSIGNED AUTO_INCREMENT NOT NULL,
--   `id_user` INT UNSIGNED,
--   `creation_date` DATETIME NOT NULL DEFAULT NOW(),
--
--   PRIMARY KEY (`id_cookie`),
--
--   FOREIGN KEY (`id_user`)
--   REFERENCES `user`(`id_user`)
--   ON DELETE CASCADE
--   ON UPDATE CASCADE
-- );




CREATE TABLE IF NOT EXISTS `picture` (
  `id_picture` INT UNSIGNED AUTO_INCREMENT UNIQUE NOT NULL,
  `id_user` INT UNSIGNED,
  `path` VARCHAR(254),
  `public` BOOLEAN DEFAULT false,
  `date` DATETIME NOT NULL DEFAULT NOW(),

  PRIMARY KEY (`id_picture`),

  FOREIGN KEY (`id_user`)
  REFERENCES `user`(`id_user`)
  ON DELETE CASCADE
  ON UPDATE CASCADE
);




CREATE TABLE IF NOT EXISTS `like` (
  `id_user` INT UNSIGNED,
  `id_picture` INT UNSIGNED,
  `date` DATETIME NOT NULL DEFAULT NOW(),

  UNIQUE KEY (`id_user`, `id_picture`),

  FOREIGN KEY (`id_user`)
  REFERENCES `user`(`id_user`)
  ON DELETE CASCADE
  ON UPDATE CASCADE,

  FOREIGN KEY (`id_picture`)
  REFERENCES `picture`(`id_picture`)
  ON DELETE CASCADE
  ON UPDATE CASCADE
);




CREATE TABLE IF NOT EXISTS `comment` (
  `id_comment` INT UNSIGNED AUTO_INCREMENT UNIQUE NOT NULL,
  `id_user` INT UNSIGNED NOT NULL,
  `id_picture` INT UNSIGNED NOT NULL,
  `date` DATETIME NOT NULL DEFAULT NOW(),
  `content` TEXT,

  PRIMARY KEY (`id_comment`),

  FOREIGN KEY (`id_user`)
  REFERENCES `user`(`id_user`)
  ON DELETE CASCADE
  ON UPDATE CASCADE,

  FOREIGN KEY (`id_picture`)
  REFERENCES `picture`(`id_picture`)
  ON DELETE CASCADE
  ON UPDATE CASCADE
);
