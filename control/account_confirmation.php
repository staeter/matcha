<?php
  session_start();
  
  require_once $_SERVER["DOCUMENT_ROOT"] . '/config/database.php';
  require_once $_SERVER["DOCUMENT_ROOT"] . '/model/classes/User.class.php';
	require_once $_SERVER["DOCUMENT_ROOT"] . '/model/classes/Database.class.php';
  
  $db = new Database($dsn . ";dbname=" . $dbname, $username, $password);

  try
  {
    $usr = User::receive_account_verification_request($_POST['a'], $_POST['b'], $db);
    $job_done = 1;
  }
  catch (Exception $e) 
  {
    $job_done = 0;
  }
 
  if ($job_done == 1)
  {
    echo 
    '{
    "result": "Success",
    "message": "Votre compte à bien été validé !",
    "alert": 
      {
        "color": "DarkGrenn",
        "message": "Votre compte à bien été vérfié."
      }
    }';
  }
  else if ($job_done == 0)
  {
    echo 
    '{
      "result": "Failure",
      "message": "Un problème est arrivé dans la validation de votre compte !",
      "alert": 
      {
        "color": "DarkRed",
        "message": "Un problème est arrivé dans la validation de votre compte !"
      }
    }';
  }
  else
  {
    echo 
    '{
      "result": "Failure",
      "message": "Un problème Innatendu est arrivé dans la validation de votre compte !",
      "alert": 
      {
        "color": "DarkRed",
        "message": "Un problème Innatendu est arrivé dans la validation de votre compte !"
      }
    }';
  }
?>
