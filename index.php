<!DOCTYPE HTML>
<html>
<head>
  <meta charset="UTF-8">
  <title>Main</title>

  <link rel="stylesheet" href="/css/galery.css">
  <link rel="stylesheet" href="/css/multi-input.css">
  <link rel="stylesheet" href="/css/header.css">
  <script src="/index.js"></script>
</head>

<body>
  <div id="elm"></div>
  <script>
  var app = Elm.Main.init({
    node: document.getElementById('elm'),
    flags:  <?php
              if (!isset($_SESSION['id'])) {
                ?>null<?php
              }
              else {
                ?>{ pseudo: .$_SESSION['pseudo']., picture: "/Pictures/rick.png" }<?php
              }
            ?>
  });
  </script>
</div>
</html>
