-- phpMyAdmin SQL Dump
-- version 4.8.4
-- https://www.phpmyadmin.net/
--
-- Hôte : localhost:3306
-- Généré le :  Dim 23 fév. 2020 à 09:45
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

-- --------------------------------------------------------

--
-- Structure de la table `account_retrieval_requests`
--

CREATE TABLE IF NOT EXISTS `account_retrieval_requests` (
  `account_retrieval_request_key` int(10) UNSIGNED NOT NULL,
  `id_user` int(10) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Structure de la table `account_verification`
--

CREATE TABLE IF NOT EXISTS `account_verification` (
  `account_verification_key` int(10) UNSIGNED NOT NULL,
  `id_user` int(10) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Déchargement des données de la table `account_verification`
--

INSERT INTO `account_verification` (`account_verification_key`, `id_user`) VALUES
(4294967295, 8);

-- --------------------------------------------------------

--
-- Structure de la table `intrests`
--

CREATE TABLE IF NOT EXISTS `intrests` (
  `id_user` int(10) UNSIGNED DEFAULT NULL,
  `tag` varchar(64) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Déchargement des données de la table `intrests`
--

INSERT INTO `intrests` (`id_user`, `tag`) VALUES
(4, 'test'),
(5, 'faut'),
(5, 'les'),
(5, 'lova'),
(9, 'homo'),
(9, 'love');

-- --------------------------------------------------------

--
-- Structure de la table `like`
--

CREATE TABLE IF NOT EXISTS `like` (
  `id_user_liking` int(10) UNSIGNED DEFAULT NULL,
  `id_user_liked` int(10) UNSIGNED DEFAULT NULL,
  `liked` tinyint(1) DEFAULT '1',
  `date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Déchargement des données de la table `like`
--

INSERT INTO `like` (`id_user_liking`, `id_user_liked`, `liked`, `date`) VALUES
(4, 5, 1, '2020-02-19 01:02:15'),
(2, 2, 1, '2020-02-19 18:25:21'),
(2, 4, 1, '2020-02-19 18:38:50'),
(2, 1, 1, '2020-02-19 23:21:18'),
(4, 3, 0, '2020-02-20 13:33:51'),
(2, 5, 1, '2020-02-20 15:49:05'),
(5, 3, 1, '2020-02-21 14:20:30'),
(7, 5, 1, '2020-02-21 21:52:31'),
(5, 7, 0, '2020-02-23 07:11:51');

-- --------------------------------------------------------

--
-- Structure de la table `messages`
--

CREATE TABLE IF NOT EXISTS `messages` (
  `id_message` int(10) UNSIGNED NOT NULL,
  `id_user_sending` int(10) UNSIGNED DEFAULT NULL,
  `id_user_receiving` int(10) UNSIGNED DEFAULT NULL,
  `date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `content` text,
  `msg_read` tinyint(1) DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Déchargement des données de la table `messages`
--

INSERT INTO `messages` (`id_message`, `id_user_sending`, `id_user_receiving`, `date`, `content`, `msg_read`) VALUES
(1, 1, 2, '2020-02-18 22:42:18', 'Salut !!! juste pour testeer', 1),
(2, 2, 1, '2020-02-18 23:01:14', 'kk', 1),
(3, 2, 1, '2020-02-18 23:50:48', 'yo mec', 1),
(4, 2, 2, '2020-02-18 23:51:54', 'test message vers moi meme', 1),
(5, 2, 2, '2020-02-18 23:52:06', 'nice', 1),
(6, 1, 2, '2020-02-18 23:52:07', 'nice', 1),
(7, 2, 1, '2020-02-19 00:19:04', 'voir si le msg est lu', 1),
(8, 2, 3, '2020-02-19 00:44:32', 'salut test, je t envoi un msg test !', 1),
(9, 1, 4, '2020-02-19 00:47:05', 'salut !', 1),
(10, 2, 4, '2020-02-19 00:47:17', 'yo eksjsjs !', 1),
(12, 4, 1, '2020-02-19 00:47:50', 'yo ?', 1),
(13, 4, 2, '2020-02-19 01:03:22', 'salut !', 1),
(15, 4, 1, '2020-02-19 01:03:44', 'kk', 1),
(16, 4, 2, '2020-02-19 01:03:48', 'yo', 1),
(17, 4, 2, '2020-02-19 01:03:50', 'yo !!', 1),
(18, 4, 2, '2020-02-19 01:03:50', 'yo !!', 1),
(19, 4, 2, '2020-02-19 13:01:53', 'yo', 1),
(20, 2, 1, '2020-02-19 20:14:46', 'hhh', 1),
(21, 2, 4, '2020-02-19 20:15:40', 'bruno est pd', 1),
(22, 2, 4, '2020-02-19 20:15:52', 'bruno est pd', 1),
(23, 3, 2, '2020-02-20 13:40:23', 'salut mec !', 1),
(24, 4, 2, '2020-02-20 15:43:01', 'jjj', 1),
(25, 4, 2, '2020-02-20 15:43:38', 'test simon', 1),
(26, 3, 2, '2020-02-20 15:54:48', 'salut dernier msg', 1);

-- --------------------------------------------------------

--
-- Structure de la table `notifications`
--

CREATE TABLE IF NOT EXISTS `notifications` (
  `id_user` int(10) UNSIGNED NOT NULL,
  `notification` varchar(254) NOT NULL DEFAULT 'Something happened.',
  `date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `readed` tinyint(1) DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Déchargement des données de la table `notifications`
--

INSERT INTO `notifications` (`id_user`, `notification`, `date`, `readed`) VALUES
(2, 'reda send u a message !', '2020-02-18 23:01:14', 1),
(1, 'reda send u a message !', '2020-02-18 23:50:48', 0),
(2, 'reda send u a message !', '2020-02-18 23:52:06', 1),
(2, 'reda send u a message !', '2020-02-18 23:52:07', 1),
(1, 'reda send u a message !', '2020-02-19 00:19:04', 0),
(1, 'test2 send u a message !', '2020-02-19 00:47:50', 0),
(2, 'reda visit ur profile !', '2020-02-19 01:02:02', 1),
(2, 'reda visit ur profile !', '2020-02-19 01:02:14', 1),
(2, 'test2 liked u !', '2020-02-19 01:02:15', 1),
(2, 'test2 send u a message !', '2020-02-19 01:03:22', 1),
(3, 'test2 send u a message !', '2020-02-19 01:03:27', 1),
(1, 'test2 send u a message !', '2020-02-19 01:03:44', 0),
(2, 'test2 send u a message !', '2020-02-19 01:03:48', 1),
(2, 'test2 send u a message !', '2020-02-19 01:03:50', 1),
(2, 'test2 send u a message !', '2020-02-19 01:03:50', 1),
(2, 'test2 send u a message !', '2020-02-19 13:01:53', 1),
(2, 'reda visit ur profile !', '2020-02-19 13:02:35', 1),
(2, 'test2 unliked u  :( )!', '2020-02-19 13:02:38', 1),
(2, 'redaoknkkn visit ur profile !', '2020-02-19 18:19:18', 1),
(2, 'reda liked u !', '2020-02-19 18:25:21', 1),
(4, 'test2 visit ur profile !', '2020-02-19 18:38:46', 1),
(4, 'redaoknkkn liked u !', '2020-02-19 18:38:50', 1),
(1, 'redaoknkkn send u a message !', '2020-02-19 20:14:46', 0),
(4, 'redaoknkkn send u a message !', '2020-02-19 20:15:40', 1),
(4, 'redaoknkkn send u a message !', '2020-02-19 20:15:52', 1),
(1, 'reda liked u !', '2020-02-19 23:21:18', 0),
(2, 'test2 liked u again :p !', '2020-02-20 12:56:32', 1),
(1, 'sosa visit ur profile !', '2020-02-20 13:32:22', 0),
(1, 'sosa visit ur profile !', '2020-02-20 13:32:34', 0),
(2, 'redaloca visit ur profile !', '2020-02-20 13:32:37', 1),
(3, 'test visit ur profile !', '2020-02-20 13:32:45', 1),
(3, 'test2 liked u !', '2020-02-20 13:33:51', 1),
(1, 'sosa visit ur profile !', '2020-02-20 13:33:58', 0),
(2, 'redaloca visit ur profile !', '2020-02-20 13:34:01', 1),
(3, 'test2 unliked u  :( )!', '2020-02-20 13:37:01', 1),
(2, 'test send u a message !', '2020-02-20 13:40:23', 1),
(1, 'sosa visit ur profile !', '2020-02-20 13:40:57', 0),
(1, 'sosa visit ur profile !', '2020-02-20 13:41:45', 0),
(2, 'test2 send u a message !', '2020-02-20 15:43:01', 1),
(2, 'test2 send u a message !', '2020-02-20 15:43:38', 1),
(3, 'redaloca liked u !', '2020-02-20 15:49:05', 1),
(2, 'test send u a message !', '2020-02-20 15:54:48', 1),
(1, 'sosa visit ur profile !', '2020-02-20 16:34:52', 0),
(2, 'redaloca visit ur profile !', '2020-02-20 18:59:42', 1),
(2, 'meuf liked u !', '2020-02-20 19:11:47', 1),
(1, 'sosa visit ur profile !', '2020-02-20 19:15:38', 0),
(3, 'test visit ur profile !', '2020-02-20 19:16:57', 0),
(7, 'meuf2 visit ur profile !', '2020-02-20 20:17:54', 1),
(4, 'test2 visit ur profile !', '2020-02-20 20:18:27', 0),
(3, 'test visit ur profile !', '2020-02-21 13:51:48', 0),
(1, 'sosa visit ur profile !', '2020-02-21 13:52:01', 0),
(3, 'test visit ur profile !', '2020-02-21 13:52:33', 0),
(3, 'test visit ur profile !', '2020-02-21 13:52:39', 0),
(3, 'test visit ur profile !', '2020-02-21 13:53:06', 0),
(3, 'simon visit ur profile !', '2020-02-21 13:55:28', 0),
(3, 'simon visit ur profile !', '2020-02-21 13:55:39', 0),
(3, 'simon visit ur profile !', '2020-02-21 13:56:02', 0),
(3, 'simon visit ur profile !', '2020-02-21 13:56:06', 0),
(3, 'simon visit ur profile !', '2020-02-21 13:56:12', 0),
(3, 'simon visit ur profile !', '2020-02-21 13:57:49', 0),
(3, 'test visit ur profile !', '2020-02-21 14:00:12', 0),
(3, 'test visit ur profile !', '2020-02-21 14:00:34', 0),
(3, 'test visit ur profile !', '2020-02-21 14:01:18', 0),
(3, 'test visit ur profile !', '2020-02-21 14:01:32', 0),
(3, 'test visit ur profile !', '2020-02-21 14:01:41', 0),
(3, 'test visit ur profile !', '2020-02-21 14:02:09', 0),
(3, 'test visit ur profile !', '2020-02-21 14:02:31', 0),
(3, 'test visit ur profile !', '2020-02-21 14:02:41', 0),
(3, 'test visit ur profile !', '2020-02-21 14:02:44', 0),
(3, 'test visit ur profile !', '2020-02-21 14:03:16', 0),
(3, 'test visit ur profile !', '2020-02-21 14:03:52', 0),
(3, 'test visit ur profile !', '2020-02-21 14:04:08', 0),
(3, 'test visit ur profile !', '2020-02-21 14:04:34', 0),
(3, 'test visit ur profile !', '2020-02-21 14:04:52', 0),
(3, 'simon visit ur profile !', '2020-02-21 14:07:54', 0),
(3, 'simon visit ur profile !', '2020-02-21 14:08:48', 0),
(3, 'simon visit ur profile !', '2020-02-21 14:09:37', 0),
(3, 'simon visit ur profile !', '2020-02-21 14:09:41', 0),
(3, 'simon visit ur profile !', '2020-02-21 14:10:05', 0),
(3, 'simon visit ur profile !', '2020-02-21 14:10:09', 0),
(3, 'simon visit ur profile !', '2020-02-21 14:10:12', 0),
(3, 'simon visit ur profile !', '2020-02-21 14:11:26', 0),
(3, 'simon visit ur profile !', '2020-02-21 14:11:38', 0),
(3, 'simon visit ur profile !', '2020-02-21 14:11:58', 0),
(3, 'simon visit ur profile !', '2020-02-21 14:13:00', 0),
(3, 'simon visit ur profile !', '2020-02-21 14:18:45', 0),
(3, 'simon visit ur profile !', '2020-02-21 14:20:14', 0),
(3, 'simon liked u !', '2020-02-21 14:20:30', 0),
(3, 'simon visit ur profile !', '2020-02-21 14:20:41', 0),
(3, 'simon visit ur profile !', '2020-02-21 14:21:40', 0),
(3, 'simon visit ur profile !', '2020-02-21 14:21:53', 0),
(3, 'simon visit ur profile !', '2020-02-21 14:21:59', 0),
(3, 'simon visit ur profile !', '2020-02-21 14:22:04', 0),
(3, 'simon visit ur profile !', '2020-02-21 14:23:37', 0),
(3, 'simon visit ur profile !', '2020-02-21 14:32:46', 0),
(7, 'simon visit ur profile !', '2020-02-21 14:32:55', 0),
(3, 'simon visit ur profile !', '2020-02-21 14:33:24', 0),
(7, 'simon visit ur profile !', '2020-02-21 14:33:32', 0),
(3, 'simon visit ur profile !', '2020-02-21 14:35:13', 0),
(3, 'simon unliked u  :( )!', '2020-02-21 14:35:14', 0),
(3, 'simon liked u again :p !', '2020-02-21 14:35:41', 0),
(3, 'simon visit ur profile !', '2020-02-21 21:45:10', 0),
(3, 'simon visit ur profile !', '2020-02-21 21:45:26', 0),
(7, 'simon visit ur profile !', '2020-02-21 21:45:33', 0),
(3, 'simon visit ur profile !', '2020-02-21 21:45:43', 0),
(3, 'simon visit ur profile !', '2020-02-21 21:45:48', 0),
(3, 'simon visit ur profile !', '2020-02-21 21:46:11', 0),
(1, 'simon visit ur profile !', '2020-02-21 21:46:29', 0),
(1, 'simon visit ur profile !', '2020-02-21 21:47:15', 0),
(2, 'simon visit ur profile !', '2020-02-21 21:47:38', 0),
(3, 'simon visit ur profile !', '2020-02-21 21:47:48', 0),
(3, 'simon visit ur profile !', '2020-02-21 21:48:26', 0),
(3, 'simon visit ur profile !', '2020-02-21 21:48:40', 0),
(3, 'simon visit ur profile !', '2020-02-21 21:48:50', 0),
(7, 'simon visit ur profile !', '2020-02-21 21:49:00', 0),
(1, 'simon visit ur profile !', '2020-02-21 21:49:19', 0),
(7, 'simon visit ur profile !', '2020-02-21 21:49:22', 0),
(3, 'simon visit ur profile !', '2020-02-21 21:49:29', 0),
(7, 'simon visit ur profile !', '2020-02-21 21:49:44', 0),
(3, 'simon visit ur profile !', '2020-02-21 21:49:47', 0),
(2, 'simon visit ur profile !', '2020-02-21 21:49:54', 0),
(1, 'simon visit ur profile !', '2020-02-21 21:50:00', 0),
(3, 'simon visit ur profile !', '2020-02-21 21:53:16', 0),
(1, 'simon visit ur profile !', '2020-02-22 11:44:46', 0),
(7, 'simon visit ur profile !', '2020-02-22 11:44:56', 0),
(7, 'simon visit ur profile !', '2020-02-22 11:45:38', 0),
(7, 'simon visit ur profile !', '2020-02-22 11:57:36', 0),
(7, 'simon visit ur profile !', '2020-02-22 16:38:36', 0),
(7, 'simon visit ur profile !', '2020-02-22 16:39:34', 0),
(7, 'simon liked u !', '2020-02-22 16:39:37', 0),
(2, 'simon visit ur profile !', '2020-02-22 16:43:05', 0),
(7, 'simon visit ur profile !', '2020-02-23 06:20:31', 0),
(7, 'simon visit ur profile !', '2020-02-23 06:59:19', 0),
(7, 'simon liked u !', '2020-02-23 06:59:21', 0),
(7, 'U got a match with simon', '2020-02-23 06:59:21', 0),
(7, 'simon visit ur profile !', '2020-02-23 06:59:42', 0),
(7, 'simon unliked u  :( )!', '2020-02-23 07:00:36', 0),
(7, 'simon liked u again :p !', '2020-02-23 07:00:46', 0),
(7, 'simon unliked u  :( )!', '2020-02-23 07:00:51', 0),
(7, 'simon liked u again :p !', '2020-02-23 07:00:57', 0),
(7, 'simon liked u !', '2020-02-23 07:01:11', 0),
(5, 'U got a match with simon', '2020-02-23 07:04:49', 1),
(7, 'U got a match with simon', '2020-02-23 07:04:49', 0),
(5, 'U got a match with simon', '2020-02-23 07:06:55', 1),
(5, 'U got a match with simon', '2020-02-23 07:07:17', 1),
(7, 'U got a match with meuf2', '2020-02-23 07:07:17', 0),
(7, 'simon liked u !', '2020-02-23 07:08:29', 0),
(7, 'U got a match with simon', '2020-02-23 07:08:29', 0),
(5, 'U got a match with meuf2', '2020-02-23 07:08:29', 1),
(7, 'simon liked u !', '2020-02-23 07:10:23', 0),
(7, 'U got a match with simon', '2020-02-23 07:10:23', 0),
(5, 'U got a match with meuf2', '2020-02-23 07:10:23', 1),
(7, 'simon liked u !', '2020-02-23 07:11:51', 0),
(7, 'U got a match with simon', '2020-02-23 07:11:51', 0),
(5, 'U got a match with meuf2', '2020-02-23 07:11:51', 1),
(7, 'simon send u a message !', '2020-02-23 07:12:16', 0),
(7, 'simon unliked u  :( )!', '2020-02-23 07:21:34', 0),
(7, 'simon liked u again :p !', '2020-02-23 07:21:45', 0),
(7, 'simon visit ur profile !', '2020-02-23 07:22:12', 0),
(7, 'simon unliked u  :( )!', '2020-02-23 07:22:17', 0),
(7, 'simon liked u again :p !', '2020-02-23 07:22:19', 0),
(7, 'simon unliked u  :( )!', '2020-02-23 07:22:19', 0),
(7, 'simon liked u again :p !', '2020-02-23 07:22:20', 0),
(7, 'simon unliked u  :( )!', '2020-02-23 07:22:20', 0),
(7, 'simon liked u again :p !', '2020-02-23 07:22:20', 0),
(7, 'simon unliked u  :( )!', '2020-02-23 07:22:20', 0),
(7, 'simon liked u again :p !', '2020-02-23 07:22:20', 0),
(7, 'simon unliked u  :( )!', '2020-02-23 07:22:20', 0),
(7, 'simon liked u again :p !', '2020-02-23 07:22:20', 0),
(7, 'simon unliked u  :( )!', '2020-02-23 07:22:21', 0),
(7, 'simon liked u again :p !', '2020-02-23 07:22:21', 0),
(7, 'simon unliked u  :( )!', '2020-02-23 07:22:21', 0),
(7, 'simon liked u again :p !', '2020-02-23 07:22:21', 0),
(7, 'simon unliked u  :( )!', '2020-02-23 07:22:21', 0),
(7, 'simon liked u again :p !', '2020-02-23 07:22:21', 0),
(7, 'simon unliked u  :( )!', '2020-02-23 07:22:46', 0),
(7, 'simon liked u again :p !', '2020-02-23 07:22:47', 0),
(7, 'simon unliked u  :( )!', '2020-02-23 07:22:47', 0),
(7, 'simon liked u again :p !', '2020-02-23 07:22:47', 0),
(7, 'simon unliked u  :( )!', '2020-02-23 07:22:47', 0),
(7, 'simon liked u again :p !', '2020-02-23 07:22:47', 0),
(7, 'simon unliked u  :( )!', '2020-02-23 07:22:48', 0),
(7, 'simon liked u again :p !', '2020-02-23 07:22:48', 0),
(7, 'simon unliked u  :( )!', '2020-02-23 07:22:49', 0),
(7, 'simon liked u again :p !', '2020-02-23 07:22:49', 0),
(7, 'simon unliked u  :( )!', '2020-02-23 07:22:52', 0),
(7, 'simon liked u again :p !', '2020-02-23 07:23:02', 0),
(7, 'simon unliked u  :( )!', '2020-02-23 07:23:06', 0),
(7, 'simon liked u again :p !', '2020-02-23 07:23:59', 0),
(7, 'simon unliked u  :( )!', '2020-02-23 07:24:03', 0),
(7, 'simon liked u again :p !', '2020-02-23 07:24:25', 0),
(7, 'simon unliked u  :( )!', '2020-02-23 07:24:29', 0),
(7, 'simon liked u again :p !', '2020-02-23 07:24:52', 0),
(7, 'simon unliked u  :( )!', '2020-02-23 07:24:56', 0),
(7, 'U lost match with simon, so ur chat was deleted !', '2020-02-23 07:24:56', 0),
(5, 'U lost a match with meuf2', '2020-02-23 07:24:56', 1),
(7, 'simon liked u again :p !', '2020-02-23 07:26:57', 0),
(7, 'U got a match with simon', '2020-02-23 07:26:57', 0),
(5, 'U got a match with meuf2', '2020-02-23 07:26:57', 1),
(7, 'simon visit ur profile !', '2020-02-23 07:33:02', 0),
(7, 'simon unliked u  :( )!', '2020-02-23 07:49:58', 0),
(7, 'U lost match with simon, so ur chat was deleted !', '2020-02-23 07:49:58', 0),
(5, 'U lost a match with meuf2', '2020-02-23 07:49:58', 1),
(7, 'simon visit ur profile !', '2020-02-23 08:19:01', 0),
(7, 'simon liked u again :p !', '2020-02-23 08:40:20', 0),
(7, 'U got a match with simon', '2020-02-23 08:40:20', 0),
(5, 'U got a match with meuf2', '2020-02-23 08:40:20', 1),
(7, 'simon send u a message !', '2020-02-23 08:40:31', 0),
(7, 'simon unliked u  :( )!', '2020-02-23 08:41:01', 0),
(7, 'U lost match with simon, so ur chat was deleted !', '2020-02-23 08:41:01', 0),
(5, 'U lost a match with meuf2', '2020-02-23 08:41:01', 1),
(7, 'simon liked u again :p !', '2020-02-23 13:08:25', 0),
(7, 'U got a match with simon', '2020-02-23 13:08:25', 0),
(5, 'U got a match with meuf2', '2020-02-23 13:08:25', 1),
(7, 'simon unliked u  :( )!', '2020-02-23 13:22:17', 0),
(7, 'U lost match with simon, so ur chat was deleted !', '2020-02-23 13:22:17', 0),
(5, 'U lost a match with meuf2', '2020-02-23 13:22:17', 1),
(7, 'simon liked u again :p !', '2020-02-23 13:25:33', 0),
(7, 'U got a match with simon', '2020-02-23 13:25:33', 0),
(5, 'U got a match with meuf2', '2020-02-23 13:25:33', 1),
(7, 'simon unliked u  :( )!', '2020-02-23 13:26:55', 0),
(7, 'U lost match with simon, so ur chat was deleted !', '2020-02-23 13:26:55', 0),
(5, 'U lost a match with meuf2', '2020-02-23 13:26:55', 1),
(7, 'simon visit ur profile !', '2020-02-23 13:27:44', 0),
(7, 'simon liked u again :p !', '2020-02-23 13:27:53', 0),
(7, 'U got a match with simon', '2020-02-23 13:27:53', 0),
(5, 'U got a match with meuf2', '2020-02-23 13:27:53', 1),
(7, 'simon unliked u  :( )!', '2020-02-23 13:29:49', 0),
(7, 'U lost match with simon, so ur chat was deleted !', '2020-02-23 13:29:49', 0),
(5, 'U lost a match with meuf2', '2020-02-23 13:29:49', 1),
(7, 'simon liked u again :p !', '2020-02-23 13:34:02', 0),
(7, 'U got a match with simon', '2020-02-23 13:34:02', 0),
(5, 'U got a match with meuf2', '2020-02-23 13:34:02', 1),
(7, 'simon unliked u  :( )!', '2020-02-23 13:35:51', 0),
(7, 'U lost match with simon, so ur chat was deleted !', '2020-02-23 13:35:51', 0),
(5, 'U lost a match with meuf2', '2020-02-23 13:35:51', 1);

-- --------------------------------------------------------

--
-- Structure de la table `picture`
--

CREATE TABLE IF NOT EXISTS `picture` (
  `id_picture` int(10) UNSIGNED NOT NULL,
  `id_user` int(10) UNSIGNED DEFAULT NULL,
  `is_profile-picture` tinyint(1) DEFAULT '0',
  `path` varchar(254) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Déchargement des données de la table `picture`
--

INSERT INTO `picture` (`id_picture`, `id_user`, `is_profile-picture`, `path`) VALUES
(1, 1, 1, '/Pictures/rick.png'),
(2, 1, 0, '/Pictures/addpic.png'),
(3, 1, 0, '/Pictures/addpic.png'),
(4, 1, 0, '/Pictures/addpic.png'),
(5, 1, 0, '/Pictures/addpic.png'),
(6, 2, 1, '/Pictures/addpic.png'),
(7, 2, 0, '/Pictures/addpic.png'),
(8, 2, 0, '/Pictures/addpic.png'),
(9, 2, 0, '/Pictures/addpic.png'),
(10, 2, 0, '/Pictures/addpic.png'),
(11, 3, 1, '/Pictures/addpic.png'),
(12, 3, 0, '/Pictures/addpic.png'),
(13, 3, 0, '/Pictures/addpic.png'),
(14, 3, 0, '/Pictures/addpic.png'),
(15, 3, 0, '/Pictures/addpic.png'),
(16, 4, 1, '/Pictures/rick.png'),
(17, 4, 0, '/Pictures/addpic.png'),
(18, 4, 0, '/Pictures/addpic.png'),
(19, 4, 0, '/Pictures/addpic.png'),
(20, 4, 0, '/Pictures/addpic.png'),
(21, 5, 1, '/Pictures/mec1.jpeg'),
(22, 5, 0, '/Pictures/addpic.png'),
(23, 5, 0, '/Pictures/addpic.png'),
(24, 5, 0, '/Pictures/addpic.png'),
(25, 5, 0, '/Pictures/addpic.png'),
(31, 7, 1, '/Pictures/meuf2.jpg'),
(32, 7, 0, '/Pictures/addpic.png'),
(33, 7, 0, '/Pictures/addpic.png'),
(34, 7, 0, '/Pictures/IMG_1475.JPG'),
(35, 7, 0, '/Pictures/addpic.png'),
(36, 8, 1, '/Pictures/def.jpg'),
(37, 8, 0, '/Pictures/addpic.png'),
(38, 8, 0, '/Pictures/addpic.png'),
(39, 8, 0, '/Pictures/addpic.png'),
(40, 8, 0, '/Pictures/addpic.png'),
(41, 9, 1, '/Pictures/def.jpg'),
(42, 9, 0, '/Pictures/addpic.png'),
(43, 9, 0, '/Pictures/addpic.png'),
(44, 9, 0, '/Pictures/addpic.png'),
(45, 9, 0, '/Pictures/addpic.png');

-- --------------------------------------------------------

--
-- Structure de la table `profile_viewed`
--

CREATE TABLE IF NOT EXISTS `profile_viewed` (
  `id_user_viewing` int(10) UNSIGNED DEFAULT NULL,
  `id_user_viewed` int(10) UNSIGNED DEFAULT NULL,
  `date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Déchargement des données de la table `profile_viewed`
--

INSERT INTO `profile_viewed` (`id_user_viewing`, `id_user_viewed`, `date`) VALUES
(7, 5, '2020-02-23 06:23:50'),
(2, 5, '2020-02-23 06:24:00'),
(5, 7, '2020-02-23 07:36:48'),
(5, 7, '2020-02-23 08:19:01'),
(5, 7, '2020-02-23 13:27:44');

-- --------------------------------------------------------

--
-- Structure de la table `report`
--

CREATE TABLE IF NOT EXISTS `report` (
  `id_user_reporting` int(10) UNSIGNED DEFAULT NULL,
  `id_user_reported` int(10) UNSIGNED DEFAULT NULL,
  `description` text,
  `date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Déchargement des données de la table `report`
--

INSERT INTO `report` (`id_user_reporting`, `id_user_reported`, `description`, `date`) VALUES
(5, 7, 'Default Description By now', '2020-02-23 08:23:26');

-- --------------------------------------------------------

--
-- Structure de la table `user`
--

CREATE TABLE IF NOT EXISTS `user` (
  `id_user` int(10) UNSIGNED NOT NULL,
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
  `pref_mail_notifications` tinyint(1) DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Déchargement des données de la table `user`
--

INSERT INTO `user` (`id_user`, `pseudo`, `email`, `password`, `firstname`, `lastname`, `gender`, `orientation`, `biography`, `birth`, `longitude`, `latitude`, `pref_localisation`, `last_log`, `is_loged`, `popularity_score`, `pref_mail_notifications`) VALUES
(1, 'sosa', 'yapselej938@webbamail.com', '960277413cd8efd01614dcf9e0b3eea0ba415add0adb8e2dd8064a942cd85991d086b58baa1984d33f11d8bd4d2b4e74f444bb6dc1dc80bb59386d537fa7eb8c', 'ssosa', 'sosa', 1, 0, 'sss sosa loca ksksk', '1990-01-01', 0, 0, 0, '2020-02-18 21:39:59', 1, 50, 1),
(2, 'redaloca', 'sjsi@dsksk.com', '688024d48d9d231e75b27f5e59366e252154e620c43a79a4dfc5c8de508f1884679229a221086f515fa48fe53a842b29ecb8441b9fc8e4a4cc87bfe4aec4caac', 'loco', 'loca', 1, 0, 'sosa', '1989-12-28', 0, 0, 0, '2020-02-18 22:41:23', 0, 50, 1),
(3, 'test', 'gemori5670@maillei.com', '5e07746edd4632d69525420c6b0a031ae98bbee44c8185d88c255391b449a8e96a5ac86663b2f3f481a1f37a86687a290c2b86d7426930f29df200d610e21d75', 'test', 'test', 1, 0, 'test', '2000-01-01', 0, 0, 0, '2020-02-19 00:43:31', 0, 50, 1),
(4, 'test2', 'tehen78357@kamismail.com', 'be213ae173b37bc730ba2049a2ed8db9ba1987fb6965244dbe0de72313ac17fde02d6d191dfd56cbad9b7bffeaf2210e0edcc31789a45a489e4f1c2a41091daf', 'test2', 'test2', 1, 0, 'yo ', '2003-01-01', 0, 0, 0, '2020-02-19 00:46:18', 0, 50, 1),
(5, 'simon', 'redaelbouri54@gmai.o', '9fe76d382f3e9883c14376355ac953ea92f136c4e823973861aed2142508cc252692e63fe45ac8612da56d6d9f076ec5eea181e01169ca70cd7a502108d042a4', 'simon', 'sosa', 1, 1, 'sosa ', '1963-01-01', 0, 0, 0, '2020-02-20 15:56:03', 0, 5, 1),
(7, 'meuf2', 'saracroche@telephone.com', '15a59c1ccbb29934c24a0f5d9125985a3af3e55cd157eebe3b01976cdad7cc105f408fb611e6e2d1893364f3aa68d834f0a2d4d8271256974bc31d42c595fe4d', 'croche', 'sara', 0, 0, 'je cherche a faire des rencontres', '2000-01-01', 0, 0, 0, '2020-02-20 20:14:34', 1, 55, 1),
(8, 'ilies', 'ilies@hot.com', '1f9823619362842e6dbc28eaa9f0ac30f93e45e8ec7fd15a9ab18a641a73ba41e313698876ffdafdfc8fe3a2fd6795169251c80a1853c0343db326dff24f2ff5', 'lolilol', 'ilies', 0, 0, NULL, '2000-01-01', 0, 0, 0, '2020-02-23 13:48:52', 0, 50, 1),
(9, 'iliesso', 'fiditor431@link3mail.com', '843a87f4119de522e13dc58c153ddc99f6fff115d1b22be85338789a08d5b22a1618be57ad682fc24453067e62dff686460ee090391ec28368a41e9d1d4b763f', 'lolilol', 'ilies', 1, 2, 'losa', '1986-01-01', 4.31724, 50.8883, 1, '2020-02-23 13:49:31', 1, 50, 1);

--
-- Index pour les tables déchargées
--

--
-- Index pour la table `account_retrieval_requests`
--
ALTER TABLE `account_retrieval_requests`
  ADD UNIQUE KEY `id_user` (`id_user`),
  ADD UNIQUE KEY `account_retrieval_request_key` (`account_retrieval_request_key`,`id_user`);

--
-- Index pour la table `account_verification`
--
ALTER TABLE `account_verification`
  ADD UNIQUE KEY `id_user` (`id_user`),
  ADD UNIQUE KEY `account_verification_key` (`account_verification_key`,`id_user`);

--
-- Index pour la table `intrests`
--
ALTER TABLE `intrests`
  ADD UNIQUE KEY `id_user` (`id_user`,`tag`);

--
-- Index pour la table `like`
--
ALTER TABLE `like`
  ADD UNIQUE KEY `id_user_liking` (`id_user_liking`,`id_user_liked`),
  ADD KEY `id_user_liked` (`id_user_liked`);

--
-- Index pour la table `messages`
--
ALTER TABLE `messages`
  ADD PRIMARY KEY (`id_message`),
  ADD UNIQUE KEY `id_message` (`id_message`),
  ADD KEY `id_user_sending` (`id_user_sending`),
  ADD KEY `id_user_receiving` (`id_user_receiving`);

--
-- Index pour la table `notifications`
--
ALTER TABLE `notifications`
  ADD KEY `id_user` (`id_user`);

--
-- Index pour la table `picture`
--
ALTER TABLE `picture`
  ADD PRIMARY KEY (`id_picture`),
  ADD UNIQUE KEY `id_picture` (`id_picture`),
  ADD KEY `id_user` (`id_user`);

--
-- Index pour la table `profile_viewed`
--
ALTER TABLE `profile_viewed`
  ADD KEY `id_user_viewing` (`id_user_viewing`),
  ADD KEY `id_user_viewed` (`id_user_viewed`);

--
-- Index pour la table `report`
--
ALTER TABLE `report`
  ADD KEY `id_user_reporting` (`id_user_reporting`),
  ADD KEY `id_user_reported` (`id_user_reported`);

--
-- Index pour la table `user`
--
ALTER TABLE `user`
  ADD PRIMARY KEY (`id_user`),
  ADD UNIQUE KEY `id_user` (`id_user`),
  ADD UNIQUE KEY `email` (`email`),
  ADD UNIQUE KEY `email_2` (`email`);

--
-- AUTO_INCREMENT pour les tables déchargées
--

--
-- AUTO_INCREMENT pour la table `messages`
--
ALTER TABLE `messages`
  MODIFY `id_message` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=46;

--
-- AUTO_INCREMENT pour la table `picture`
--
ALTER TABLE `picture`
  MODIFY `id_picture` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=46;

--
-- AUTO_INCREMENT pour la table `user`
--
ALTER TABLE `user`
  MODIFY `id_user` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

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
