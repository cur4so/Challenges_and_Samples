<?php session_start();?>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
  <title>An example of on-line vote poll</title>
<link rel="stylesheet" type="text/css" href="css/style.css" >
    
<script src="js/jquery.min.js" type="text/javascript"></script>
<script src="js/jquery.jqplot.min.js" type="text/javascript"></script>
  <script language="javascript" type="text/javascript" src="js/plugins/jqplot.barRenderer.min.js"></script>
  <script language="javascript" type="text/javascript" src="js/plugins/jqplot.highlighter.min.js"></script>
  <script language="javascript" type="text/javascript" src="js/plugins/jqplot.categoryAxisRenderer.min.js"></script>
  <script language="javascript" type="text/javascript" src="js/plugins/jqplot.pieRenderer.min.js"></script>

<script  type="text/javascript">

var plot1=null;
   
function checkRadio(field) { 

    for(var i=0; i < field.length; i++) { 
        if(field[i].checked) { return field[i].value; }
    } 
    return false; 

}

function show_stat(dats,a){

    var ele = document.getElementById("chart1");

    if (ele.style.display == "none"){
        ele.style.display = "block";
    }

var ren,x,rendOpts,legend,pl,title;

if (a == 1){
    ren=$.jqplot.BarRenderer;
    title1="<small>How many people have choosen a given option</small>";

    pl= { show: true };
    x = {
        label: 'vote choice',
        renderer: $.jqplot.CategoryAxisRenderer,
	tickOptions: {
            mark: 'outside',
            showMark: true,
            showGridline: false, 
            show: true,
            showLabel: true    
		}
    };
    rendOpts= {
        barWidth: 80,
        barMargin: 0,
 	showDataLabels: true,
        highlightMouseOver: false,
    } ;
    legend={
        placement: 'inside',
    };
}
else{
    ren=$.jqplot.PieRenderer;
    pl= { show: false };
    x = { };
    rendOpts= { padding: 8, 
        pieMargin: 3,
	showDataLabels: true,
        highlightMouseOver: false,
    };
    legend = {
        show:false, 
        rendererOptions: {numberRows: 1}, 
        showSwatch: true,
        location:'s',
	placement: 'inside',
        marginTop: '10px'
    };
    title1="";      
}

options={
    series:[
        {
            renderer: ren,
  	    pointLabels: pl,
            showHighlight: false,
            rendererOptions: rendOpts
        } 
    ],
    title: title1, 
    grid: {            
        background: 'transparent',
	drawBorder: false,
    },
    gridPadding: {
	top:0, 
	right:0, 
	bottom:0, 
	left:0
    },
    legend: legend,
    axesDefaults: {
        show: false,
        borderWidth: 0,
	tickOptions: {
            show: false,
            showLabel: false 
	},
    },
    axes: {
       xaxis: x
    }   
};


if (plot1 == null){
    plot1= $.jqplot('chart1',[dats],options);
} else {
    $('#chart1').empty();
    plot1 = null;
    plot1= $.jqplot('chart1',[dats],options);
}

}


function add_vote(val) {

    $.ajax({
        type: "GET",
        url: "submit_get_data.php",
        data: "v="+val,
        dataType: "text",
        success: function(data) {
            if ( data.indexOf("already") >= 0  ){ return dats=-1; }
            else {
                var isnum=/\d+/;
                dats = data.split(";");
                dats = $.grep(dats,function(n){ return(n); });
                for (i=0;i < dats.length;i++){  
                    dats[i]=dats[i].split(",");
	        }
                var i=0;
                if (! isnum.test(dats[0][1])){ return dats=false; }
                else{
                    for (i=0;i < dats.length;i++){ dats[i][1] = parseFloat(dats[i][1]); }
                    return dats;
                } 
            }
        }    
    });

return dats;
}

function validate(div_id,form) {
	
    var ele = document.getElementById(div_id);

    if(radioValue = checkRadio(form.r1)) { 
	
        if (ele.style.display == "block") {
      	    ele.style.display = "none";
        } else {
	    ele.style.display = "block";
            if (div_id == "d1"){
                var dats=add_vote(radioValue);

                if (dats == -1){
	            ele.innerHTML = "Sorry, you have voted already<br> "; 
                }
	        else if (dats){
	            ele.innerHTML = "Thanks for your vote!<br> \
		        You selected option " + radioValue + "<br> \
		        <h2>Show statistics as <a href='#' onclick=\"show_stat(dats,0)\">pie</a> or \
		        <a href='#' onclick=\"show_stat(dats,1)\">bars</a>  </h2>"; 
                } else {
		    ele.innerHTML = "Thanks for your vote!<br> \
		        You selected option " + radioValue + "<br> \
		        Unfortunately, currently your vote cannot be accepted.<br>\
		        Come again"; 
                }
           }
       }
   return false; 
   } 
   else { alert("please select one of the options"); return false; }  
}
</script>
</head>

<body>
<?php
if (!isset($_SESSION["voted"])){$_SESSION["voted"]=0;}
?>


<div id ="d0" class="main" >
<center>
<h1> What picture do you like ?</h1>
<form name="vote" method="post" action="#" onsubmit="return validate('d1',this)">
<table><tr>
<td align='center'><img src="images/f1.jpg" border="0"></image><br>
	<input type="radio" name="r1" value="1"> </td>
<td align='center'><img src="images/f2.jpg" border="0"></image><br>
	<input type="radio" name="r1" value="2"> </td>
<td align='center'><img src="images/f3.jpg" border="0"></image><br>
	<input type="radio" name="r1" value="3"> </td>
<td align='center'><img src="images/f4.jpg" border="0"></image><br>
	<input type="radio" name="r1" value="4"> </td>
<td align='center'><img src="images/f5.jpg" border="0"></image><br>
	<input type="radio" name="r1" value="5"> </td>
</tr></table>
<input type="submit" name="submit"  value="submit"> 
</form>

<div id="d1" style="display: none;"> </div>
<div id="chart1" style="display: none; width:500px; height:300px;"> </div>
</center>
</div>
</body>
</html>

