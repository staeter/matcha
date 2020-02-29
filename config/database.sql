-- phpMyAdmin SQL Dump
-- version 4.8.4
-- https://www.phpmyadmin.net/
--
-- Hôte : localhost:3306
-- Généré le :  lun. 24 fév. 2020 à 09:34
-- Version du serveur :  5.6.42
-- Version de PHP :  5.6.40

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de données :  `matcha`
--
CREATE DATABASE IF NOT EXISTS `matcha` DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;
USE `matcha`;

-- --------------------------------------------------------

--
-- Structure de la table `account_retrieval_requests`
--

CREATE TABLE IF NOT EXISTS `account_retrieval_requests` (
  `account_retrieval_request_key` int(10) UNSIGNED NOT NULL,
  `id_user` int(10) UNSIGNED NOT NULL,
  UNIQUE KEY `id_user` (`id_user`),
  UNIQUE KEY `account_retrieval_request_key` (`account_retrieval_request_key`,`id_user`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Structure de la table `account_verification`
--

CREATE TABLE IF NOT EXISTS `account_verification` (
  `account_verification_key` int(10) UNSIGNED NOT NULL,
  `id_user` int(10) UNSIGNED NOT NULL,
  UNIQUE KEY `id_user` (`id_user`),
  UNIQUE KEY `account_verification_key` (`account_verification_key`,`id_user`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Structure de la table `block`
--

CREATE TABLE IF NOT EXISTS `block` (
  `id_user_blocking` int(10) UNSIGNED DEFAULT NULL,
  `id_user_blocked` int(10) UNSIGNED DEFAULT NULL,
  `description` text,
  `date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  KEY `id_user_blocking` (`id_user_blocking`),
  KEY `id_user_blocked` (`id_user_blocked`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


-- --------------------------------------------------------

--
-- Structure de la table `intrests`
--

CREATE TABLE IF NOT EXISTS `intrests` (
  `id_user` int(10) UNSIGNED DEFAULT NULL,
  `tag` varchar(64) DEFAULT NULL,
  UNIQUE KEY `id_user` (`id_user`,`tag`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


-- --------------------------------------------------------

--
-- Structure de la table `like`
--

CREATE TABLE IF NOT EXISTS `like` (
  `id_user_liking` int(10) UNSIGNED DEFAULT NULL,
  `id_user_liked` int(10) UNSIGNED DEFAULT NULL,
  `liked` tinyint(1) DEFAULT '1',
  `date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY `id_user_liking` (`id_user_liking`,`id_user_liked`),
  KEY `id_user_liked` (`id_user_liked`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


-- --------------------------------------------------------

--
-- Structure de la table `messages`
--

CREATE TABLE IF NOT EXISTS `messages` (
  `id_message` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `id_user_sending` int(10) UNSIGNED DEFAULT NULL,
  `id_user_receiving` int(10) UNSIGNED DEFAULT NULL,
  `date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `content` text,
  `msg_read` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id_message`),
  UNIQUE KEY `id_message` (`id_message`),
  KEY `id_user_sending` (`id_user_sending`),
  KEY `id_user_receiving` (`id_user_receiving`)
) ENGINE=InnoDB AUTO_INCREMENT=49 DEFAULT CHARSET=utf8;


-- --------------------------------------------------------

--
-- Structure de la table `notifications`
--

CREATE TABLE IF NOT EXISTS `notifications` (
  `id_user` int(10) UNSIGNED NOT NULL,
  `notification` varchar(254) NOT NULL DEFAULT 'Something happened.',
  `date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `readed` tinyint(1) DEFAULT '0',
  KEY `id_user` (`id_user`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Structure de la table `picture`
--

CREATE TABLE IF NOT EXISTS `picture` (
  `id_picture` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `id_user` int(10) UNSIGNED DEFAULT NULL,
  `is_profile-picture` tinyint(1) DEFAULT '0',
  `path` varchar(254) DEFAULT NULL,
  PRIMARY KEY (`id_picture`),
  UNIQUE KEY `id_picture` (`id_picture`),
  KEY `id_user` (`id_user`)
) ENGINE=InnoDB AUTO_INCREMENT=71 DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Structure de la table `profile_viewed`
--

CREATE TABLE IF NOT EXISTS `profile_viewed` (
  `id_user_viewing` int(10) UNSIGNED DEFAULT NULL,
  `id_user_viewed` int(10) UNSIGNED DEFAULT NULL,
  `date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  KEY `id_user_viewing` (`id_user_viewing`),
  KEY `id_user_viewed` (`id_user_viewed`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Structure de la table `report`
--

CREATE TABLE IF NOT EXISTS `report` (
  `id_user_reporting` int(10) UNSIGNED DEFAULT NULL,
  `id_user_reported` int(10) UNSIGNED DEFAULT NULL,
  `description` text,
  `date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  KEY `id_user_reporting` (`id_user_reporting`),
  KEY `id_user_reported` (`id_user_reported`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Structure de la table `user`
--

CREATE TABLE IF NOT EXISTS `user` (
  `id_user` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `pseudo` varchar(64) NOT NULL,
  `email` varchar(254) NOT NULL,
  `password` char(128) NOT NULL,
  `firstname` varchar(64) NOT NULL,
  `lastname` varchar(64) NOT NULL,
  `gender` tinyint(1) DEFAULT '0',
  `orientation` int(10) UNSIGNED DEFAULT '0',
  `biography` text,
  `birth` date DEFAULT '2000-01-01',
  `longitude` float DEFAULT '0',
  `latitude` float DEFAULT '0',
  `pref_localisation` tinyint(1) NOT NULL DEFAULT '0',
  `last_log` datetime DEFAULT CURRENT_TIMESTAMP,
  `is_loged` tinyint(1) DEFAULT '0',
  `popularity_score` int(11) DEFAULT '50',
  `pref_mail_notifications` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`id_user`),
  UNIQUE KEY `id_user` (`id_user`),
  UNIQUE KEY `email` (`email`),
  UNIQUE KEY `email_2` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8;

--
-- Contraintes pour les tables déchargées
--

--
-- Contraintes pour la table `account_retrieval_requests`
--
ALTER TABLE `account_retrieval_requests`
  ADD CONSTRAINT `account_retrieval_requests_ibfk_1` FOREIGN KEY (`id_user`) REFERENCES `user` (`id_user`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Contraintes pour la table `account_verification`
--
ALTER TABLE `account_verification`
  ADD CONSTRAINT `account_verification_ibfk_1` FOREIGN KEY (`id_user`) REFERENCES `user` (`id_user`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Contraintes pour la table `block`
--
ALTER TABLE `block`
  ADD CONSTRAINT `block_ibfk_1` FOREIGN KEY (`id_user_blocking`) REFERENCES `user` (`id_user`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `block_ibfk_2` FOREIGN KEY (`id_user_blocked`) REFERENCES `user` (`id_user`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Contraintes pour la table `intrests`
--
ALTER TABLE `intrests`
  ADD CONSTRAINT `intrests_ibfk_1` FOREIGN KEY (`id_user`) REFERENCES `user` (`id_user`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Contraintes pour la table `like`
--
ALTER TABLE `like`
  ADD CONSTRAINT `like_ibfk_1` FOREIGN KEY (`id_user_liking`) REFERENCES `user` (`id_user`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `like_ibfk_2` FOREIGN KEY (`id_user_liked`) REFERENCES `user` (`id_user`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Contraintes pour la table `messages`
--
ALTER TABLE `messages`
  ADD CONSTRAINT `messages_ibfk_1` FOREIGN KEY (`id_user_sending`) REFERENCES `user` (`id_user`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `messages_ibfk_2` FOREIGN KEY (`id_user_receiving`) REFERENCES `user` (`id_user`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Contraintes pour la table `notifications`
--
ALTER TABLE `notifications`
  ADD CONSTRAINT `notifications_ibfk_1` FOREIGN KEY (`id_user`) REFERENCES `user` (`id_user`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Contraintes pour la table `picture`
--
ALTER TABLE `picture`
  ADD CONSTRAINT `picture_ibfk_1` FOREIGN KEY (`id_user`) REFERENCES `user` (`id_user`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Contraintes pour la table `profile_viewed`
--
ALTER TABLE `profile_viewed`
  ADD CONSTRAINT `profile_viewed_ibfk_1` FOREIGN KEY (`id_user_viewing`) REFERENCES `user` (`id_user`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `profile_viewed_ibfk_2` FOREIGN KEY (`id_user_viewed`) REFERENCES `user` (`id_user`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Contraintes pour la table `report`
--
ALTER TABLE `report`
  ADD CONSTRAINT `report_ibfk_1` FOREIGN KEY (`id_user_reporting`) REFERENCES `user` (`id_user`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `report_ibfk_2` FOREIGN KEY (`id_user_reported`) REFERENCES `user` (`id_user`) ON DELETE CASCADE ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
