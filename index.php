<!DOCTYPE HTML>
<html>
<head>
  <meta charset="UTF-8">
  <title>Main</title>
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
              if (/*no user signed in*/ false) {
                ?>null<?php
              }
              else {
                ?>{ pseudo: "LeroyJenkins", picture: "/data/leroyspick.jpg" }<?php
              }
            ?>
  });
  </script>
</div>
</html>
