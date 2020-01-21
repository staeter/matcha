<?php
//
session_start();
require $_SERVER["DOCUMENT_ROOT"] . '/model/classes/User.class.php';
require $_SERVER["DOCUMENT_ROOT"] . '/model/functions/hash_password.php';

$db = new Database('mysql:host=localhost:3306;dbname=matcha', 'root', 'rootroot');
$usr = unserialize($_SESSION['user']);


$row = $usr->get_all_messages_between_two_user($_POST['id']);



$string = '{
  "data" : {
    "messages" : [';

foreach ($row as $key => $value) {
    // code...
    $string .= '
    {
          "sent" : true,
          "date" : "12-01-2020",
          "content" : "sosasosa"
        },
        ';
  }

function enleve_virgule($string)
{


  // echo $string;
  //
  // echo '<br><br>';
    $nbchar = strlen($string);
  // echo $nbchar;
  // echo '<br><br>';
  $string1 = substr($string, 0, -10);

  // echo $string1;
  // echo '<br><br>';


    //
    // $count = $nbchar - $nbcharalertfixe - 178;
    //
    // $newstring2 = substr($string, 0,  ($nbchar - $nbcharalertfixe - 17));
    // echo $newstring2;
    //
    $findestring = '
      ]
    },
      "alert" : {
      "color" : "DarkBlue",
      "message" : "chat discution alert"
    }
    }';

    //
     $string1 .= $findestring;
    // echo $newstring2;


    echo $string1;
    // $stringstart = '{
    //   "data" : {
    //     "messages" : [';
    // $stringstart;
    // $stringstart .= $newstring2;
    // $stringstart .= $newstring;
    //
    //
    //
    // echo $stringstart;


  //  $string[$nbchar - $nbcharalertfixe] = 'W';
  }



//
// echo $string;
// echo "<br><br>";
// // echo "<br><br>";
//
// function enleve_virgule2($string)
// {
//
//   $stringtocount = '
//     ]
//   },
//     "alert" : {
//     "color" : "DarkBlue",
//     "message" : "chat discution alert"
//   }
//   }';
//
//   $c = strlen($stringtocount);
//   $s = strlen($string);
//
//   // echo $c;
//   // echo '<br>';
//   // echo $s;
//   // echo '<br>';
//
//  $string[$s - $c + 4] = '';
//   //echo $string[$s - $c - 20];
//
//   // echo '<br>';
//   // echo '<br>';
//
// echo $string;
//
// //  echo [string['']]
//
//
//
// }

// enleve_virgule2($string);
// echo '<br>';
// echo $string[257];
//
// echo '<br>';
// $string[257] = 'X';
// echo $string;
if (empty($row))
{
  echo '{
  "data" : {
    "messages" : [

  ]},
  "alert" : {
    "color" : "DarkRed",
    "message" : "there is not conversation between those user!"
  }
  }';
}
else {
  enleve_virgule($string);
}
//echo $string;

//echo '<br><br><br><br><br><br><br><br><br><br>';

//echo $string;
?>
