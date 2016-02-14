<?php
session_start();
if (isset($_SESSION["voted"])){ 
  print "-1"; exit();
} else { 
  if (isset($_GET["v"])){

    $v=escapeshellarg($_GET["v"]);

    $host='host.name.or.address';
    $db='your_db';

    $dbh = pg_connect("host=$host dbname=$db");
    if (! $dbh) {
      print "Error: Could not connect to database ";
      exit();
    }

    $result=pg_query($dbh,"select v from votes where i=$v");
    $row= pg_fetch_array($result,0,PGSQL_NUM);
    $new=$row[0]+1;
    $q="update votes set v=".$new." where i=".$v;
    $result=pg_query($dbh,$q);
    if (!$result) {
      print "An error occured";
      exit();
    }
    $result=pg_query($dbh,"select i,v from votes order by i");
 
    pg_close($dbh);

    $nr=pg_num_rows($result);

    if ($nr > 0){
      $i=0;
      $r='';

      while($i<$nr){
        $row= pg_fetch_array($result,$i,PGSQL_NUM);
        $r .= $row[0].",".$row[1].";";
        $i++;
      }
      $r = substr($r,0,-1); 
      print $r;
      $_SESSION["voted"]=1;
    }
  }
  else {print "no input data";}
  exit();  
}
?>

