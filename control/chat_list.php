<?php
//
session_start();
require $_SERVER["DOCUMENT_ROOT"] . '/model/classes/User.class.php';
$usr = unserialize($_SESSION['user']);

function getLatestMessages(array $messages, $receiverId) {
    $times = [];
    $chats = [];
    foreach ($messages as $message) {
        if ($message['id_user_receiving'] === $receiverId) {
            $senderId = $message['id_user_sending'];
            if (!isset($times[$senderId])) {
                $times[$senderId] = 0;
            }
            $date = new DateTime($message['date']);
            $unix = $date->getTimestamp();
            if ($unix > $times[$senderId]) {
                $times[$senderId] = $unix;
                $chats[$senderId] = $message;
            }
        }
    }
    return $chats;
}

$raw_message = $usr->get_all_messages_of_user_connected();
$arraytoconvertinJson = getLatestMessages($raw_message, $usr->get_id());
//print_r($raw_message);
function  tri($array)
{


}

$reda = tri($raw_message);
// 3.       fonction deja coder
$raw_user = $usr->get_all_details();

// print_r($arraytoconvertinJson);
// return;

$jsondata = '{
  "data" : [
    ';
$findestring = '],
"alert" : {
  "color" : "DarkBlue",
  "message" : "chat list alert"
}
}';

foreach ($arraytoconvertinJson as $key => $value) {
  // code...

  //on va mettre les valeurs à inserer ici
  //gere l affichie de id
  if ($arraytoconvertinJson[$key]['id_user_receiving'] == $usr->get_id())
      $arraytoconvertinJson[$key]['id_user_receiving'] = $arraytoconvertinJson[$key]['id_user_sending'];

  // je dois gerer l affichage de Pseudo

  //picture
  //lastlog
  //if ($arraytoconvertinJson[$key]['id_user_sending'] == $usr->get_id() || $arraytoconvertinJson[$key]['id_user_receiving'] == $usr->get_id())
    $ret = $usr->get_all_details_of_this_id($arraytoconvertinJson[$key]['id_user_receiving']);
    $id_pic = $arraytoconvertinJson[$key]['id_user_receiving'];

  if ($raw_message[0]['msg_read'] != 0)
    $unread = 'false';
  else
    $unread = 'true';
$row = $usr->get_picture_profil($id_pic);

  if ($ret['is_loged'] == 1)
    $stringlastlog = "Now";
  else {
    $stringlastlog = $ret['last_log'];
  }


  $lastmsg = $raw_message[0]['content'];



  $jsondata .='
  {
        "id" : '.$arraytoconvertinJson[$key]['id_user_receiving'].',
        "pseudo" : "'.$ret['pseudo'].'",
        "picture" : "'.$row['path'].'",
        "last_log" : "'.$stringlastlog.'",
        "last_message" : "'.$lastmsg.'",
        "unread" : '.$unread.'
      },
  ';
}


$jsondata = substr($jsondata, 0, -5);
$jsondata .= $findestring;

echo $jsondata;
return;
?>
