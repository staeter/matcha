<?php
function get_client_ip()
{
    $ipaddress = '';
    if (isset($_SERVER['HTTP_CLIENT_IP'])) {
        $ipaddress = $_SERVER['HTTP_CLIENT_IP'];
    } else if (isset($_SERVER['HTTP_X_FORWARDED_FOR'])) {
        $ipaddress = $_SERVER['HTTP_X_FORWARDED_FOR'];
    } else if (isset($_SERVER['HTTP_X_FORWARDED'])) {
        $ipaddress = $_SERVER['HTTP_X_FORWARDED'];
    } else if (isset($_SERVER['HTTP_FORWARDED_FOR'])) {
        $ipaddress = $_SERVER['HTTP_FORWARDED_FOR'];
    } else if (isset($_SERVER['HTTP_FORWARDED'])) {
        $ipaddress = $_SERVER['HTTP_FORWARDED'];
    } else if (isset($_SERVER['REMOTE_ADDR'])) {
        $ipaddress = $_SERVER['REMOTE_ADDR'];
    } else {
        $ipaddress = 'UNKNOWN';
    }

    return $ipaddress;
}

$PublicIP = get_client_ip();
//$PublicIP = '8.8.8.8';
$json     = file_get_contents("http://ipinfo.io/81.246.29.107/geo");
$json     = json_decode($json, true);

var_dump($json);
function set_last_location($country, $town)
{
  $query = ('UPDATE user SET last_localisation = :last_loc WHERE id_user = :id');
  $db->query($query, array(':bio' => $country .','. $town, ':id' => $this->_id));
  $db->execute();
}
//$country  = $json['country'];
//$region   = $json['region'];
//$city     = $json['city'];

?>
