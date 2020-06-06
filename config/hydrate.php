<?php
  require $_SERVER["DOCUMENT_ROOT"] . '/config/database.php';
  require '../model/functions/hash_password.php';
  require_once $_SERVER["DOCUMENT_ROOT"] . '/model/classes/Database.class.php';
  require_once $_SERVER["DOCUMENT_ROOT"] . '/data/firstNames.php';
  require_once $_SERVER["DOCUMENT_ROOT"] . '/data/lastNames.php';
  require_once $_SERVER["DOCUMENT_ROOT"] . '/data/pictures.php';
  require_once $_SERVER["DOCUMENT_ROOT"] . '/data/tags.php';


  if (array_key_exists("amount", $_GET))
    $amount = intval($_GET["amount"]);
  else
    $amount = 50;

  try {
    echo "Creating db object...<br><br>";
    $db = new Database($dsn . ";dbname=" . $dbname, $username, $password);





    echo 'Assembling user query...<br>';
    $query = "INSERT INTO `user` (`firstname`, `lastname`, `pseudo`, `email`, `gender`, `orientation`, `password`, `biography`, `birth`, `longitude`, `latitude`, `pref_localisation`, `last_log`, `is_loged`, `popularity_score`, `pref_mail_notifications`) VALUES ";
    $first = true;
    for ($i = 0; $i < $amount; $i++) {
      if ( $first ) $first = false;
      else $query .= ", ";

      $query .= "(:fn$i, :ln$i, :ps$i, :em$i, :ge$i, :or$i, :pw$i, :bio$i, :birth$i, :lo$i, :la$i, :prefloc$i, :lastlog$i, :isloged$i, :pop$i, :prefmailnotif$i)";
    }

    echo "Binding values...<br>";
    $bindVal = array();
    for ($circle = 0; $circle <= (int)($amount / 1000); $circle++) {
      shuffle($firstNames);
      shuffle($lastNames);
      shuffle($profilePictures);

      for ($i = 0; $i < 1000 && $i + (1000 * $circle) < $amount; $i++) {
        $id = $i + (1000 * $circle);

        $bindVal[':fn'.$id] = $firstNames[$i];
        $bindVal[':ln'.$id] = $lastNames[$i];
        $bindVal[':ps'.$id] = strtolower($firstNames[$i][0] . $lastNames[$i]);
        $bindVal[':em'.$id] = strtolower($firstNames[$i] .'.'. $lastNames[$i]) .'@hydratemail.com';
        $bindVal[':ge'.$id] = rand(0, 1);
        $bindVal[':or'.$id] = rand(0, 2);
        $bindVal[':pw'.$id] = hash_password($bindVal[':em'.$id]);
        $bindVal[':bio'.$id] = "Je suis un faux compte ^^";
        $bindVal[':birth'.$id] = date("Y-m-d", rand(1, time()));
        $bindVal[':lo'.$id] = rand(-180000000, 180000000) / 1000000;
        $bindVal[':la'.$id] = rand(-90000000, 90000000) / 1000000;
        $bindVal[':prefloc'.$id] = rand(0, 1);
        $bindVal[':lastlog'.$id] = date("Y-m-d H:i:s", rand(1, time()));
        $bindVal[':isloged'.$id] = rand(0, 1);
        $bindVal[':pop'.$id] = rand(0, 100);
        $bindVal[':prefmailnotif'.$id] = rand(0, 1);

        echo
        '( ' . $bindVal[':fn'.$id]
        . ', ' . $bindVal[':ln'.$id]
        . ', ' . $bindVal[':ps'.$id]
        . ', ' . $bindVal[':em'.$id]
        . ', ' . $bindVal[':ge'.$id]
        . ', ' . $bindVal[':or'.$id]
        . ', ' . $bindVal[':birth'.$id]
        . ', ' . $bindVal[':lo'.$id]
        . ', ' . $bindVal[':la'.$id]
        . ', ' . $bindVal[':prefloc'.$id]
        . ', ' . $bindVal[':lastlog'.$id]
        . ', ' . $bindVal[':isloged'.$id]
        . ', ' . $bindVal[':pop'.$id]
        . ', ' . $bindVal[':prefmailnotif'.$id]
        . ' )<br>';
      }
    }

    echo "Inserting...<br><br>";
    $db->query($query, $bindVal);





    echo 'Querying IDs...<br>';
    $query = "SELECT LAST_INSERT_ID() AS `liID`;";
    $db->query($query, array());
    $row = $db->fetch();
    if ($row === false) {
      throw new DatabaseException("Failure on LAST_INSERT_ID.");
    }
    $firstID = $row['liID'];
    $lastID = $firstID + $amount - 1;
    echo 'Inserted IDs go from '.$firstID.' to '.$lastID.' )<br><br>';





    echo 'Assembling tags query...<br>';
    $query = "INSERT INTO `intrests` (`id_user`, `tag`) VALUES ";
    $first = true;
    for ($i = $firstID; $i <= $lastID; $i++) {
      if ( $first ) $first = false;
      else $query .= ", ";

      $query .= "(:id0th$i, :tag0th$i), (:id1th$i, :tag1th$i), (:id2th$i, :tag2th$i), (:id3th$i, :tag3th$i), (:id4th$i, :tag4th$i)";
    }

    echo "Binding values...<br>";
    $bindVal = array();
    for ($i = $firstID; $i <= $lastID; $i++) {
      $randTag = array_rand($tags, 5);

      $bindVal[":id0th$i"] = $i;
      $bindVal[":tag0th$i"] = $tags[$randTag[0]];
      $bindVal[":id1th$i"] = $i;
      $bindVal[":tag1th$i"] = $tags[$randTag[1]];
      $bindVal[":id2th$i"] = $i;
      $bindVal[":tag2th$i"] = $tags[$randTag[2]];
      $bindVal[":id3th$i"] = $i;
      $bindVal[":tag3th$i"] = $tags[$randTag[3]];
      $bindVal[":id4th$i"] = $i;
      $bindVal[":tag4th$i"] = $tags[$randTag[4]];

      echo
      $i . ': ( ' . $bindVal[":tag0th$i"]
      . ', ' . $bindVal[":tag1th$i"]
      . ', ' . $bindVal[":tag2th$i"]
      . ', ' . $bindVal[":tag3th$i"]
      . ', ' . $bindVal[":tag4th$i"]
      . ' )<br>';
    }

    echo "Inserting...<br><br>";
    $db->query($query, $bindVal);




    echo 'Assembling pictures query...<br>';
    $query = "INSERT INTO `picture` (`id_user`, `is_profile-picture`, `path`) VALUES ";
    $first = true;
    for ($i = $firstID; $i <= $lastID; $i++) {
      if ( $first ) $first = false;
      else $query .= ", ";

      $query .= "(:id$i, :pp$i, :path$i), (:id1$i, :npp1$i, :addpic1$i), (:id2$i, :npp2$i, :addpic2$i), (:id3$i, :npp3$i, :addpic3$i), (:id4$i, :npp4$i, :addpic4$i)";
    }

    echo "Binding values...<br>";
    $bindVal = array();

    for ($i = $firstID; $i <= $lastID; $i++) {
      $randPP = array_rand($profilePictures);

      $bindVal[":id$i"] = $i;
      $bindVal[":pp$i"] = true;
      $bindVal[":path$i"] = $profilePictures[$randPP];

      for ($j = 1; $j <= 4; $j++) {
        $bindVal[":id$j$i"] = $i;
        $bindVal[":npp$j$i"] = false;
        $bindVal[":addpic$j$i"] = "/Pictures/addpic.png";
      }

      echo
      $i . ': ' . $bindVal[":path$i"] . '<br>';
    }

    echo "Inserting...<br><br>";
    $db->query($query, $bindVal);





    echo 'Assembling like query...<br>';
    $query = "INSERT INTO `like` (`id_user_liking`, `id_user_liked`) VALUES ";
    $first = true;
    $amount_of_likes_per_user = 10;
    for ($i = $firstID; $i <= $lastID; $i++) {
      for ($j = 0; $j < $amount_of_likes_per_user; $j++) {
        if ( $first ) $first = false;
        else $query .= ", ";

        $query .= "(:id_user_liking$j$i, :id_user_liked$j$i)";
      }
    }

    echo "Binding values...<br>";
    $bindVal = array();

    for ($i = $firstID; $i <= $lastID; $i++) {
      $id_user_alredy_liked = array($i);

      for ($j = 0; $j < $amount_of_likes_per_user; $j++) {
        $rand_id_usr = -1;
        while (true) {
          $rand_id_usr = rand($firstID, $lastID);
          if (!in_array($rand_id_usr, $id_user_alredy_liked)) {
            $id_user_alredy_liked[] = $rand_id_usr;
            break;
          }
        }

        $bindVal[":id_user_liking$j$i"] = $i;
        $bindVal[":id_user_liked$j$i"] = $rand_id_usr;

        echo $i . ' likes ' . $rand_id_usr . '<br>';
      }
    }

    echo "Inserting...<br><br>";
    $db->query($query, $bindVal);




    echo 'Assembling profile viewed query...<br>';
    $query = "INSERT INTO `profile_viewed` (`id_user_viewing`, `id_user_viewed`) VALUES ";
    $first = true;
    $amount_of_views_per_user = 20;
    for ($i = $firstID; $i <= $lastID; $i++) {
      for ($j = 0; $j < $amount_of_views_per_user; $j++) {
        if ( $first ) $first = false;
        else $query .= ", ";

        $query .= "(:id_user_viewing$j$i, :id_user_viewed$j$i)";
      }
    }

    echo "Binding values...<br>";
    $bindVal = array();

    for ($i = $firstID; $i <= $lastID; $i++) {
      $id_user_alredy_viewed = array($i);

      for ($j = 0; $j < $amount_of_views_per_user; $j++) {
        $rand_id_usr = -1;
        while (true) {
          $rand_id_usr = rand($firstID, $lastID);
          if (!in_array($rand_id_usr, $id_user_alredy_viewed)) {
            $id_user_alredy_viewed[] = $rand_id_usr;
            break;
          }
        }

        $bindVal[":id_user_viewing$j$i"] = $i;
        $bindVal[":id_user_viewed$j$i"] = $rand_id_usr;

        echo $i . ' viewed ' . $rand_id_usr . '\'s profile<br>';
      }
    }

    echo "Inserting...<br><br>";
    $db->query($query, $bindVal);




    echo "Complete!";

  } catch (Exception $e) {
    echo $e.'<br>';
    var_dump($e->getTrace());
  }

?>
