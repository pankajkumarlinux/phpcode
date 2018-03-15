<?php
$con = mysql_connect("localhost","root","Redhat@123");
if (!$con)
  {
  die('Could not connect: ' . mysql_error());
  }

mysql_select_db("studentinfo", $con);
?>
