CREATE TABLE IF NOT EXISTS `user` (
  `id_user` INT UNSIGNED UNIQUE AUTO_INCREMENT NOT NULL,
  `pseudo` VARCHAR(64) NOT NULL,
  `email` VARCHAR(254) UNIQUE NOT NULL,
  `password` CHAR(128) NOT NULL,

  `gender` INT UNSIGNED,
  `orientation` INT UNSIGNED,
  `biography` TEXT,
  `birth` DATE,

  `last_localisation` VARCHAR(64),
  `last_log` DATETIME DEFAULT NOW(),
  `is_loged` BOOLEAN DEFAULT false,

  `popularity_score` INT,

  `pref_mail_notifications` BOOLEAN DEFAULT true,

  PRIMARY KEY (`id_user`),

  UNIQUE KEY(`email`)
);




CREATE TABLE IF NOT EXISTS `intrests` (
  `id_user` INT UNSIGNED,
  `tag` VARCHAR(64),

  UNIQUE KEY (`id_user`, `tag`),

  FOREIGN KEY (`id_user`)
  REFERENCES `user`(`id_user`)
  ON DELETE CASCADE
  ON UPDATE CASCADE
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




CREATE TABLE IF NOT EXISTS `notifications` (
	`id_user` INT UNSIGNED NOT NULL,
	`notification` VARCHAR(254) NOT NULL DEFAULT "Something happened.",

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




CREATE TABLE IF NOT EXISTS `picture` (
  `id_picture` INT UNSIGNED AUTO_INCREMENT UNIQUE NOT NULL,
  `id_user` INT UNSIGNED,
  `is_profile-picture` BOOLEAN DEFAULT false,
  `path` VARCHAR(254),

  PRIMARY KEY (`id_picture`),

  FOREIGN KEY (`id_user`)
  REFERENCES `user`(`id_user`)
  ON DELETE CASCADE
  ON UPDATE CASCADE
);




CREATE TABLE IF NOT EXISTS `like` (
  `id_user_liking` INT UNSIGNED,
  `id_user_liked` INT UNSIGNED,
  `liked` BOOLEAN DEFAULT true,
  `date` DATETIME NOT NULL DEFAULT NOW(),

  UNIQUE KEY (`id_user_liking`, `id_user_liked`),

  FOREIGN KEY (`id_user_liking`)
  REFERENCES `user`(`id_user`)
  ON DELETE CASCADE
  ON UPDATE CASCADE,

  FOREIGN KEY (`id_user_liked`)
  REFERENCES `user`(`id_user`)
  ON DELETE CASCADE
  ON UPDATE CASCADE
);




CREATE TABLE IF NOT EXISTS `profile_viewed` (
  `id_user_viewing` INT UNSIGNED,
  `id_user_viewed` INT UNSIGNED,
  `date` DATETIME NOT NULL DEFAULT NOW(),

  FOREIGN KEY (`id_user_viewing`)
  REFERENCES `user`(`id_user`)
  ON DELETE CASCADE
  ON UPDATE CASCADE,

  FOREIGN KEY (`id_user_viewed`)
  REFERENCES `user`(`id_user`)
  ON DELETE CASCADE
  ON UPDATE CASCADE
);




CREATE TABLE IF NOT EXISTS `report` (
  `id_user_reporting` INT UNSIGNED,
  `id_user_reported` INT UNSIGNED,
  `description` TEXT,
  `date` DATETIME NOT NULL DEFAULT NOW(),

  FOREIGN KEY (`id_user_reporting`)
  REFERENCES `user`(`id_user`)
  ON DELETE CASCADE
  ON UPDATE CASCADE,

  FOREIGN KEY (`id_user_reported`)
  REFERENCES `user`(`id_user`)
  ON DELETE CASCADE
  ON UPDATE CASCADE
);




CREATE TABLE IF NOT EXISTS `messages` (
  `id_message` INT UNSIGNED AUTO_INCREMENT UNIQUE NOT NULL,
  `id_user_sending` INT UNSIGNED,
  `id_user_receiving` INT UNSIGNED,
  `date` DATETIME NOT NULL DEFAULT NOW(),
  `content` TEXT,

  PRIMARY KEY (`id_message`),

  FOREIGN KEY (`id_user_sending`)
  REFERENCES `user`(`id_user`)
  ON DELETE CASCADE
  ON UPDATE CASCADE,

  FOREIGN KEY (`id_user_receiving`)
  REFERENCES `user`(`id_user`)
  ON DELETE CASCADE
  ON UPDATE CASCADE
);
