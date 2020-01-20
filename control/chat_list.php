<?php
//
session_start();
require $_SERVER["DOCUMENT_ROOT"] . '/model/classes/User.class.php';
require $_SERVER["DOCUMENT_ROOT"] . '/model/functions/hash_password.php';

$db = new Database('mysql:host=localhost:3306;dbname=matcha', 'root', 'rootroot');
$usr = unserialize($_SESSION['user']);



// je dois renvoyer dans un foreach pour chaque conversation avec un User
// un tableau contenant l id du gars / pseudo / picture / last log/ last message / unread(regle dans bdd ca)
//
//


// 1. fonction qui recense toutes les conversation avec un autre user
// 2. cette fonction renvoi une raw contenant les info de la table messages
//                    ( last message // unread)

// 3. je dois recuperer des infos de la table user pour pseudo id last log


// 4. je gere tjrs pas les pictures donc faudra revenir dessus une fois fait
//          du coup voir cmt recuperer une raw contenant le picture de profil
//            mtn j y pense je mettrais une photo de profil de base a tt le monde




// 1. && 2.  fonction a coder
    $raw_message = $usr->get_all_messages_of_user_connected();

    // probleme je recupere un tableau contenant toute les entree corespondant
    // a l id de l user connecte et moi j ai besoin d une occurence avec le dernier messages
    // je dois traiter ca pour faire mon foreach

   print_r($raw_message);


// 3.       fonction deja coder
    $raw_user = $usr->get_all_details();



    echo '<br><br>';

    if ($raw_message[0]['msg_read'] == 0)
      $unread = 'false';
    else
      $unread = 'true';

  //     $x = 0;
  //
  //     $tableau;
  //
  //     foreach ($raw_message as $key => $value) {
  //
  //       // je dois ici concatener mes strings, dans une variable a condition
  //       // qu elle a pas deja été concatener
  //       $tab .= '{
  //         "id" : '.$raw_message[$key]['id_user_sending'].',
  //         "pseudo" : "'.$raw_user['pseudo'].'",
  //         "picture" : "/data/joneysPick.png",
  //         "last_log" : "'.$raw_user['last_log'].'",
  //         "last_message" : "'.$raw_message[0]['content'].'",
  //         "unread" : '.$unread.'
  //       },
  //       ';
  //
  // };
  //echo($tab);

    // echo '{
    //   "data" : [
    //     {
    //       "id" : '.$raw_message[1]['id_user_sending'].',
    //       "pseudo" : "'.$raw_user['pseudo'].'",
    //       "picture" : "/data/joneysPick.png",
    //       "last_log" : "'.$raw_user['last_log'].'",
    //       "last_message" : "'.$raw_message[0]['content'].'",
    //       "unread" : '.$unread.'
    //     },
    //     {
    //       "id" : 12,
    //       "pseudo" : "Francis",
    //       "picture" : "/data/franc.png",
    //       "last_log" : "03-01-2020",
    //       "last_message" : "wow lol!",
    //       "unread" : true
    //     },
    //     {
    //       "id" : 14,
    //       "pseudo" : "lisa",
    //       "picture" : "/data/lizProfile.png",
    //       "last_log" : "29-12-2020",
    //       "last_message" : "hey! Lov u bro",
    //       "unread" : false
    //     }
    //   ],
    //   "alert" : {
    //     "color" : "DarkBlue",
    //     "message" : "chat list alert"
    //   }
    // }';


    //print_r($raw_user);

// 4.
    //    $picture_path = $usr->get_profile_picture_of_an_user();


    // de la je fais un foreacht key as value je fais un echo avec les infos
    // mmmmh je pense le message json sera mal formaté du coup je concatene
    // par ce que quand c le dernier je dois pas mettre de , apres l accolade
    // et jdois fermer le crochet + alert

// print_r($row);
//
// if ($row['is_loged'] == 1)
// {
//   $toprint = 'Now';
// }
// else {
//   $toprint = $row['last_log'];
// }
//
// echo '<br><br><br>';
//
// echo
// '{
//   "result" : "Success",
//    "message" : [
//     {
//       "id" : "'.$row['id_user'].'",
//       "pseudo" : "'.$row['pseudo'].'",
//       "picture" : "/data/name.png",
//       "last_log" : '.$toprint.',
//       "last_message" : "blabla!",
//       "unread" : "True"
//     }
//   ]
//   -- mamybe "alert" : {
//     "color" : "DarkRed",
//     "message" : "message for the user"
//   }';
//
//
//
// echo '{
//   "result" : "",
//   "message" : "sisi la famille"
// }';
?>
