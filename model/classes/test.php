<?php
session_start();

require $_SERVER["DOCUMENT_ROOT"] . '/model/classes/User.class.php';
require $_SERVER["DOCUMENT_ROOT"] . '/model/functions/hash_password.php';


// if (empty($_POST['password']) || empty($_POST['confirm']))
// {
//     echo '{
//       "result" : "Failure",
//       "message" : "Vous devez remplir tout les champs."
//     }';
// }

// if (strcmp($_POST['oldpw'], $_POST['newpw']) !== 0)
// {
//   echo '{
//     "result" : "Failure",
//     "message" : "Passwords doesnt match."
//   }';
// }
// else {

  try {
    $db = new Database('mysql:host=localhost:3306;dbname=matcha', 'root', 'rootroot');

  //  $id = 41;



    $pw = 'sosa';
    //$newpw = 'skssk12&skskksksoa';
//User::send_account_retrieval




   $usr = new User('sosa', hash_password($pw), $db);
  $row = $usr->get_all_details();
    $row2 = $usr->get_pref_mail_notifications();
  print_r($row1);
  echo '<br> <br>';
  echo $row2;
  $jsonmsg =(array('
{
"data" {
"id": "'.$row['id_user'].'",
"pseudo": "'.$row['pseudo'].'",
"first_name": "'.$row['firstname'].'",
"last_name": "'.$row['lastname'].'",
"gender": "'.$stringforgender.'",
"orientation": "'.$row['orientation'].'",
"biography": "'.$row['biography'].'",
"birth": "'.$row['birth'].'",
"last_log": "'.$stringforlast_log.'",
"pictures" : ["/data/name.png", "/data/pic2.png"],
"is_loged": "'.$row['is_loged'].'",
"popularity_score": "'.$row['popularity_score'].'"
"tags" : ["joy", "stuff"],
"liked" : false
}
}
'));
print_r($jsonmsg);




    //$usr = new User('sosa', hash_password('sosa'), $db);
    //$row = $usr->get_all_details($id);
    //  print_r($row);
    // echo '{
    //   "result" : "Success",
    //   "message" : "is valid hashed psw ! (object created)."
    // }';

  } catch (\Exception $e) {
    echo '{
      "result" : "Failure",
      "message" : "rooo'.$e->getMessage().'"
    }';

  }
  // reucp de modif de user


  // session_start();
  // require $_SERVER["DOCUMENT_ROOT"] . '/model/classes/User.class.php';
  // require $_SERVER["DOCUMENT_ROOT"] . '/model/functions/hash_password.php';
  //
  // $db = new Database('mysql:host=localhost:3306;dbname=matcha', 'root', 'rootroot');
  //
  // try {
  //   $usr = new User('sosa', hash_password($pw), $db);
  //   $row = $usr->get_all_details();
  //
  // } catch (\Exception $e) {
  //   echo '{
  //     "result" : "Failure",
  //     "message" : "'.$e->getMessage().'"
  //   }';
  // }




  /*
  {
    "id" : 12,
    "pseudo" : "myPseudo",
    "first_name" : "John",
    "last_name" : "Doe",
    "gender" : "Man" or "Woman",
    "orientation" : "Homosexual" or "Bisexual" or "Heterosexual",
    "biography" : "blablabla",
    "birth" : "some date",
    "last_log" : "Now" or "some date",
    "is_loged" : "True" or "False",
    "pictures" : ["/data/name.png", ...],
    "popularity_score" : 12,
    "tags" : ["#tag", ...],
    "liked" : "True" or "False",
    -- mamybe "alert" : {
    "result" : "Failure",
    -- maybe "data" : {
      "id" : "'.$row['id']}.'",
      "pseudo" : '.$row['pseudo']}.',
      "first_name" : '.$row['firstname']}.',
      "last_name" : '.$row['lastname']}.',
      "gender" : '.$row['gender']}.',
      "orientation" : "Homosexual" or "Bisexual" or "Heterosexual",
      "biography" : "blablabla",
      "birth" : "some date",
      "last_log" : "Now" or "some date",
      "is_loged" : "True" or "False",
      "pictures" : ["/data/name.png", ...],
      "popularity_score" : 12,
      "tags" : ["#tag", ...],
      "liked" : "True" or "False"
    }
    -- maybe "alert" : {
      "color" : "DarkRed",
      "message" : "message for the user"
    }

  // public function get_all_details()
  // {
  //   $query = 'SELECT * FROM user WHERE id_user = :id';
  //   $this->_db->query($query, array(':id' => $this->get_id()));
  //   $row = $this->_db->fetch();
  //   if ($row === false) {
  //     throw new InvalidParamException("Failed running " . __METHOD__ . ". Id not found in database.");
  //   }
  //    return $row;
  // }
  //

//
// }

//oldpw newpw
/*
{
  "result" : "Success" or "Failure",
  "message" : "This is a message I want the user to see"
}
*/

?>
