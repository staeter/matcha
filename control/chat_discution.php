<?php
//
session_start();
require $_SERVER["DOCUMENT_ROOT"] . '/model/classes/User.class.php';
$usr = unserialize($_SESSION['user']);


$row = $usr->get_all_messages_between_two_user($_POST['id']);
if (empty($row))
  {
    echo '{
    "data": {},
  	"alert": {
  		"color": "DarkBlue",
  		"message": "You dont have any conversation"
  	}}';
    return;
  }

$row2 = $usr->get_all_details_of_this_id($_POST['id']);


$row3 = $usr->get_picture_profil($_POST['id']);

if ($row2['is_loged'] == 1)
  $stringlastlog = "Now";
else
  $stringlastlog = $row2['last_log'];

$string = '{
  "data" : {
    "id" : '.$_POST['id'].',
    "pseudo" : "'.$row2['pseudo'].'",
    "picture" : "'.$row3['path'].'",
    "last_log" : "'.$stringlastlog.'",
    "messages" : [';

// print_r($row);
// return;



// true id send == userconnected
// false if id reive == otheruser
foreach ($row as $key => $value)
{
    if ($row[$key]['id_user_sending'] == $_SESSION['id'])
      $readed = 'false';
    else
      $readed = 'true';


    $string .= '{
      "sent" : '.$readed.',
      "date" : "'.$row[$key]['date'].'",
      "content" : "'.$row[$key]['content'].'"
    },
    ';
}

function enleve_virgule($string)
{
//$nbchar = strlen($string);
  $string = substr($string, 0, -7);
  $findestring = '
      ]
    },
      "alert" : {
      "color" : "DarkBlue",
      "message" : "chat discution alert"
    }
    }';

  $string .= $findestring;
  // $x ='{
	// "data": {
	// 	"id": 2,
	// 	"pseudo": "sosa",
	// 	"picture": "/Pictures/def.jpg",
	// 	"last_log": "Now",
	// 	"messages": [{
	// 		"sent": false,
	// 		"date": "2020-02-17 17:53:08",
	// 		"content": "test tjrs test"
	// 	}, {
	// 		"sent": true,
	// 		"date": "2020-02-17 17:06:42",
	// 		"content": "test message yo ma poule "
	// 	}]
	// },
	// "alert": {
	// 	"color": "DarkBlue",
	// 	"message": "chat discution alert"
	// }}';

  // avant de echo je vais mettre les messages à read


  return $string;
  }

$string = enleve_virgule($string);
$usr->set_msg_readed($_POST['id']);
echo $string;
?>
