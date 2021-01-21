<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="X-UA-Compatible" content="IE=Edge"/>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<meta http-equiv="Pragma" content="no-cache">
<meta http-equiv="Expires" content="-1">
<link rel="shortcut icon" href="images/favicon.png">
<link rel="icon" href="images/favicon.png">
<title>ntpMerlin</title>
<link rel="stylesheet" type="text/css" href="index_style.css">
<link rel="stylesheet" type="text/css" href="form_style.css">
<style>
p {
  font-weight: bolder;
}

thead.collapsible-jquery {
  color: white;
  padding: 0px;
  width: 100%;
  border: none;
  text-align: left;
  outline: none;
  cursor: pointer;
}

label.settingvalue {
  margin-right: 10px !important;
  vertical-align: top !important;
}

.invalid {
  background-color: darkred !important;
}
</style>
<script language="JavaScript" type="text/javascript" src="/ext/shared-jy/jquery.js"></script>
<script language="JavaScript" type="text/javascript" src="/ext/shared-jy/moment.js"></script>
<script language="JavaScript" type="text/javascript" src="/ext/shared-jy/chart.js"></script>
<script language="JavaScript" type="text/javascript" src="/ext/shared-jy/hammerjs.js"></script>
<script language="JavaScript" type="text/javascript" src="/ext/shared-jy/chartjs-plugin-zoom.js"></script>
<script language="JavaScript" type="text/javascript" src="/ext/shared-jy/chartjs-plugin-annotation.js"></script>
<script language="JavaScript" type="text/javascript" src="/ext/shared-jy/d3.js"></script>
<script language="JavaScript" type="text/javascript" src="/state.js"></script>
<script language="JavaScript" type="text/javascript" src="/general.js"></script>
<script language="JavaScript" type="text/javascript" src="/popup.js"></script>
<script language="JavaScript" type="text/javascript" src="/help.js"></script>
<script language="JavaScript" type="text/javascript" src="/ext/shared-jy/detect.js"></script>
<script language="JavaScript" type="text/javascript" src="/tmhist.js"></script>
<script language="JavaScript" type="text/javascript" src="/tmmenu.js"></script>
<script language="JavaScript" type="text/javascript" src="/client_function.js"></script>
<script language="JavaScript" type="text/javascript" src="/validator.js"></script>
<script language="JavaScript" type="text/javascript" src="/ext/ntpmerlin/ntpstatstext.js"></script>
<script>
var custom_settings;
function LoadCustomSettings(){
	custom_settings = <% get_custom_settings(); %>;
	for (var prop in custom_settings){
		if (Object.prototype.hasOwnProperty.call(custom_settings, prop)){
			if(prop.indexOf("ntpmerlin") != -1 && prop.indexOf("ntpmerlin_version") == -1){
				eval("delete custom_settings."+prop)
			}
		}
	}
}
var $j=jQuery.noConflict(),maxNoCharts=6,currentNoCharts=0,ShowLines=GetCookie("ShowLines","string"),ShowFill=GetCookie("ShowFill","string"),DragZoom=!0,ChartPan=!1;Chart.defaults.global.defaultFontColor="#CCC",Chart.Tooltip.positioners.cursor=function(a,b){return b};var metriclist=["Offset","Drift"],measureunitlist=["ms","ppm"],chartlist=["daily","weekly","monthly"],timeunitlist=["hour","day","day"],intervallist=[24,7,30],bordercolourlist=["#fc8500","#ffffff"],backgroundcolourlist=["rgba(252,133,0,0.5)","rgba(255,255,255,0.5)"];function keyHandler(a){27==a.keyCode&&($j(document).off("keydown"),ResetZoom())}$j(document).keydown(function(a){keyHandler(a)}),$j(document).keyup(function(){$j(document).keydown(function(a){keyHandler(a)})});function Draw_Chart_NoData(a){document.getElementById("divLineChart_"+a).width="730",document.getElementById("divLineChart_"+a).height="500",document.getElementById("divLineChart_"+a).style.width="730px",document.getElementById("divLineChart_"+a).style.height="500px";var b=document.getElementById("divLineChart_"+a).getContext("2d");b.save(),b.textAlign="center",b.textBaseline="middle",b.font="normal normal bolder 48px Arial",b.fillStyle="white",b.fillText("No data to display",365,250),b.restore()}function Draw_Chart(a,b,c,d,e){var f=getChartPeriod($j("#"+a+"_Period option:selected").val()),g=timeunitlist[$j("#"+a+"_Period option:selected").val()],h=intervallist[$j("#"+a+"_Period option:selected").val()],j=window[a+f];if("undefined"==typeof j||null===j)return void Draw_Chart_NoData(a);if(0==j.length)return void Draw_Chart_NoData(a);var k=j.map(function(a){return a.Metric}),l=j.map(function(a){return{x:a.Time,y:a.Value}}),m=window["LineChart_"+a],n=getTimeFormat($j("#Time_Format option:selected").val(),"axis"),o=getTimeFormat($j("#Time_Format option:selected").val(),"tooltip");factor=0,"hour"==g?factor=3600000:"day"==g&&(factor=86400000),m!=null&&m.destroy();var p=document.getElementById("divLineChart_"+a).getContext("2d"),q={segmentShowStroke:!1,segmentStrokeColor:"#000",animationEasing:"easeOutQuart",animationSteps:100,maintainAspectRatio:!1,animateScale:!0,hover:{mode:"point"},legend:{display:!1,position:"bottom",onClick:null},title:{display:!0,text:b},tooltips:{callbacks:{title:function(a){return moment(a[0].xLabel,"X").format(o)},label:function(a,b){return round(b.datasets[a.datasetIndex].data[a.index].y,3).toFixed(3)+" "+c}},mode:"point",position:"cursor",intersect:!0},scales:{xAxes:[{type:"time",gridLines:{display:!0,color:"#282828"},ticks:{min:moment().subtract(h,g+"s"),display:!0},time:{parser:"X",unit:g,stepSize:1,displayFormats:n}}],yAxes:[{gridLines:{display:!1,color:"#282828"},scaleLabel:{display:!1,labelString:c},ticks:{display:!0,callback:function(a){return round(a,3).toFixed(3)+" "+c}}}]},plugins:{zoom:{pan:{enabled:ChartPan,mode:"xy",rangeMin:{x:new Date().getTime()-factor*h,y:getLimit(l,"y","min",!1)-.1*Math.sqrt(Math.pow(getLimit(l,"y","min",!1),2))},rangeMax:{x:new Date().getTime(),y:getLimit(l,"y","max",!1)+.1*getLimit(l,"y","max",!1)}},zoom:{enabled:!0,drag:DragZoom,mode:"xy",rangeMin:{x:new Date().getTime()-factor*h,y:getLimit(l,"y","min",!1)-.1*Math.sqrt(Math.pow(getLimit(l,"y","min",!1),2))},rangeMax:{x:new Date().getTime(),y:getLimit(l,"y","max",!1)+.1*getLimit(l,"y","max",!1)},speed:.1}}},annotation:{drawTime:"afterDatasetsDraw",annotations:[{type:ShowLines,mode:"horizontal",scaleID:"y-axis-0",value:getAverage(l),borderColor:d,borderWidth:1,borderDash:[5,5],label:{backgroundColor:"rgba(0,0,0,0.3)",fontFamily:"sans-serif",fontSize:10,fontStyle:"bold",fontColor:"#fff",xPadding:6,yPadding:6,cornerRadius:6,position:"center",enabled:!0,xAdjust:0,yAdjust:0,content:"Avg="+round(getAverage(l),3).toFixed(3)+c}},{type:ShowLines,mode:"horizontal",scaleID:"y-axis-0",value:getLimit(l,"y","max",!0),borderColor:d,borderWidth:1,borderDash:[5,5],label:{backgroundColor:"rgba(0,0,0,0.3)",fontFamily:"sans-serif",fontSize:10,fontStyle:"bold",fontColor:"#fff",xPadding:6,yPadding:6,cornerRadius:6,position:"right",enabled:!0,xAdjust:15,yAdjust:0,content:"Max="+round(getLimit(l,"y","max",!0),3).toFixed(3)+c}},{type:ShowLines,mode:"horizontal",scaleID:"y-axis-0",value:getLimit(l,"y","min",!0),borderColor:d,borderWidth:1,borderDash:[5,5],label:{backgroundColor:"rgba(0,0,0,0.3)",fontFamily:"sans-serif",fontSize:10,fontStyle:"bold",fontColor:"#fff",xPadding:6,yPadding:6,cornerRadius:6,position:"left",enabled:!0,xAdjust:15,yAdjust:0,content:"Min="+round(getLimit(l,"y","min",!0),3).toFixed(3)+c}}]}},r={labels:k,datasets:[{data:l,borderWidth:1,pointRadius:1,lineTension:0,fill:ShowFill,backgroundColor:e,borderColor:d}]};m=new Chart(p,{type:"line",data:r,options:q}),window["LineChart_"+a]=m}function getLimit(a,b,c,d){var e,f=0;return e="x"==b?a.map(function(a){return a.x}):a.map(function(a){return a.y}),f="max"==c?Math.max.apply(Math,e):Math.min.apply(Math,e),"max"==c&&0==f&&!1==d&&(f=1),f}function getAverage(a){for(var b=0,c=0;c<a.length;c++)b+=1*a[c].y;var d=b/a.length;return d}function round(a,b){return+(Math.round(a+"e"+b)+"e-"+b)}function ToggleLines(){for(""==ShowLines?(ShowLines="line",SetCookie("ShowLines","line")):(ShowLines="",SetCookie("ShowLines","")),i=0;i<metriclist.length;i++){for(i3=0;3>i3;i3++)window["LineChart_"+metriclist[i]].options.annotation.annotations[i3].type=ShowLines;window["LineChart_"+metriclist[i]].update()}}function ToggleFill(){for("false"==ShowFill?(ShowFill="origin",SetCookie("ShowFill","origin")):(ShowFill="false",SetCookie("ShowFill","false")),i=0;i<metriclist.length;i++)window["LineChart_"+metriclist[i]].data.datasets[0].fill=ShowFill,window["LineChart_"+metriclist[i]].update()}function RedrawAllCharts(){for(i=0;i<metriclist.length;i++)for(i2=0;i2<chartlist.length;i2++)d3.csv("/ext/ntpmerlin/csv/"+metriclist[i]+chartlist[i2]+".htm").then(SetGlobalDataset.bind(null,metriclist[i]+chartlist[i2]))}function SetGlobalDataset(a,b){if(window[a]=b,currentNoCharts++,currentNoCharts==maxNoCharts){for(document.getElementById("ntpupdate_text").innerHTML="",showhide("imgNTPUpdate",!1),showhide("ntpupdate_text",!1),showhide("btnUpdateStats",!0),i=0;i<metriclist.length;i++)$j("#"+metriclist[i]+"_Period").val(GetCookie(metriclist[i]+"_Period","number")),Draw_Chart(metriclist[i],metriclist[i],measureunitlist[i],bordercolourlist[i],backgroundcolourlist[i]);AddEventHandlers()}}function getTimeFormat(a,b){var c;return"axis"==b?0==a?c={millisecond:"HH:mm:ss.SSS",second:"HH:mm:ss",minute:"HH:mm",hour:"HH:mm"}:1==a&&(c={millisecond:"h:mm:ss.SSS A",second:"h:mm:ss A",minute:"h:mm A",hour:"h A"}):"tooltip"==b&&(0==a?c="YYYY-MM-DD HH:mm:ss":1==a&&(c="YYYY-MM-DD h:mm:ss A")),c}function GetCookie(a,b){var c;if(null!=(c=cookie.get("ntp_"+a)))return cookie.get("ntp_"+a);return"string"==b?"":"number"==b?0:void 0}function SetCookie(a,b){cookie.set("ntp_"+a,b,31)}function AddEventHandlers(){$j(".collapsible-jquery").click(function(){$j(this).siblings().toggle("fast",function(){"none"==$j(this).css("display")?SetCookie($j(this).siblings()[0].id,"collapsed"):SetCookie($j(this).siblings()[0].id,"expanded")})}),$j(".collapsible-jquery").each(function(){"collapsed"==GetCookie($j(this)[0].id,"string")?$j(this).siblings().toggle(!1):$j(this).siblings().toggle(!0)})}$j.fn.serializeObject=function(){var b=custom_settings,c=this.serializeArray();return $j.each(c,function(){void 0!==b[this.name]&&-1!=this.name.indexOf("ntpmerlin")&&-1==this.name.indexOf("version")?(!b[this.name].push&&(b[this.name]=[b[this.name]]),b[this.name].push(this.value||"")):-1!=this.name.indexOf("ntpmerlin")&&-1==this.name.indexOf("version")&&(b[this.name]=this.value||"")}),b};function SetCurrentPage(){document.form.next_page.value=window.location.pathname.substring(1),document.form.current_page.value=window.location.pathname.substring(1)}function ErrorCSVExport(){document.getElementById("aExport").href="javascript:alert(\"Error exporting CSV, please refresh the page and try again\")"}function ParseCSVExport(a){for(var b,c="Timestamp,Offset,Frequency,Sys_Jitter,Clk_Jitter,Clk_Wander,Rootdisp\n",d=0;d<a.length;d++)b=a[d].Timestamp+","+a[d].Offset+","+a[d].Frequency+","+a[d].Sys_Jitter+","+a[d].Clk_Jitter+","+a[d].Clk_Wander+","+a[d].Rootdisp,c+=d<a.length-1?b+"\n":b;document.getElementById("aExport").href="data:text/csv;charset=utf-8,"+encodeURIComponent(c)}function initial(){SetCurrentPage(),LoadCustomSettings(),show_menu(),get_conf_file(),d3.csv("/ext/ntpmerlin/csv/CompleteResults.htm").then(function(a){ParseCSVExport(a)}).catch(function(){ErrorCSVExport()}),$j("#Time_Format").val(GetCookie("Time_Format","number")),ScriptUpdateLayout(),SetNTPDStatsTitle(),RedrawAllCharts()}function ScriptUpdateLayout(){var a=GetVersionNumber("local"),b=GetVersionNumber("server");$j("#scripttitle").text($j("#scripttitle").text()+" - "+a),$j("#ntpmerlin_version_local").text(a),a!=b&&"N/A"!=b&&($j("#ntpmerlin_version_server").text("Updated version available: "+b),showhide("btnChkUpdate",!1),showhide("ntpmerlin_version_server",!0),showhide("btnDoUpdate",!0))}function reload(){location.reload(!0)}function getChartPeriod(a){var b="daily";return 0==a?b="daily":1==a?b="weekly":2==a&&(b="monthly"),b}function ResetZoom(){for(i=0;i<metriclist.length;i++){var a=window["LineChart_"+metriclist[i]];"undefined"!=typeof a&&null!==a&&a.resetZoom()}}function ToggleDragZoom(a){var b=!0,c=!1,d="";for(-1==a.value.indexOf("On")?(b=!0,c=!1,DragZoom=!0,ChartPan=!1,d="Drag Zoom On"):(b=!1,c=!0,DragZoom=!1,ChartPan=!0,d="Drag Zoom Off"),i=0;i<metriclist.length;i++){var e=window["LineChart_"+metriclist[i]];"undefined"!=typeof e&&null!==e&&(e.options.plugins.zoom.zoom.drag=b,e.options.plugins.zoom.pan.enabled=c,a.value=d,e.update())}}function update_status(){$j.ajax({url:"/ext/ntpmerlin/detect_update.js",dataType:"script",timeout:3e3,error:function(){setTimeout(update_status,1e3)},success:function(){"InProgress"==updatestatus?setTimeout(update_status,1e3):(document.getElementById("imgChkUpdate").style.display="none",showhide("ntpmerlin_version_server",!0),"None"==updatestatus?($j("#ntpmerlin_version_server").text("No update available"),showhide("btnChkUpdate",!0),showhide("btnDoUpdate",!1)):($j("#ntpmerlin_version_server").text("Updated version available: "+updatestatus),showhide("btnChkUpdate",!1),showhide("btnDoUpdate",!0)))}})}function CheckUpdate(){showhide("btnChkUpdate",!1),document.formScriptActions.action_script.value="start_ntpmerlincheckupdate",document.formScriptActions.submit(),document.getElementById("imgChkUpdate").style.display="",setTimeout(update_status,2e3)}function DoUpdate(){document.form.action_script.value="start_ntpmerlindoupdate";document.form.action_wait.value=10,showLoading(),document.form.submit()}function update_ntpstats(){$j.ajax({url:"/ext/ntpmerlin/detect_ntpmerlin.js",dataType:"script",timeout:1e3,error:function(){setTimeout(update_ntpstats,1e3)},success:function(){"InProgress"==ntpstatus?setTimeout(update_ntpstats,1e3):"Done"==ntpstatus&&(document.getElementById("ntpupdate_text").innerHTML="Refreshing charts...",PostNTPUpdate())}})}function PostNTPUpdate(){currentNoCharts=0,reload_js("/ext/ntpmerlin/ntpstatstext.js"),$j("#Time_Format").val(GetCookie("Time_Format","number")),SetNTPDStatsTitle(),setTimeout(RedrawAllCharts,3e3)}function reload_js(a){$j("script[src=\""+a+"\"]").remove(),$j("<script>").attr("src",a+"?cachebuster="+new Date().getTime()).appendTo("head")}function UpdateStats(){showhide("btnUpdateStats",!1),document.formScriptActions.action_script.value="start_ntpmerlin",document.formScriptActions.submit(),document.getElementById("ntpupdate_text").innerHTML="Retrieving timeserver stats",showhide("imgNTPUpdate",!0),showhide("ntpupdate_text",!0),setTimeout(update_ntpstats,2e3)}function SaveConfig(){document.getElementById("amng_custom").value=JSON.stringify($j("form").serializeObject());document.form.action_script.value="start_ntpmerlinconfig";document.form.action_wait.value=10,showLoading(),document.form.submit()}function GetVersionNumber(a){var b;return"local"==a?b=custom_settings.ntpmerlin_version_local:"server"==a&&(b=custom_settings.ntpmerlin_version_server),"undefined"==typeof b||null==b?"N/A":b}function get_conf_file(){$j.ajax({url:"/ext/ntpmerlin/config.htm",dataType:"text",error:function(){setTimeout(get_conf_file,1e3)},success:function(data){var configdata=data.split("\n");configdata=configdata.filter(Boolean);for(var i=0;i<configdata.length;i++)eval("document.form.ntpmerlin_"+configdata[i].split("=")[0].toLowerCase()).value=configdata[i].split("=")[1].replace(/(\r\n|\n|\r)/gm,"")}})}function changeChart(a){value=1*a.value,name=a.id.substring(0,a.id.indexOf("_")),SetCookie(a.id,value),"Offset"==name?Draw_Chart("Offset",metriclist[0],measureunitlist[0],bordercolourlist[0],backgroundcolourlist[0]):"Drift"==name&&Draw_Chart("Drift",metriclist[1],measureunitlist[1],bordercolourlist[1],backgroundcolourlist[1])}function changeAllCharts(a){for(value=1*a.value,name=a.id.substring(0,a.id.indexOf("_")),SetCookie(a.id,value),i=0;i<metriclist.length;i++)Draw_Chart(metriclist[i],metriclist[i],measureunitlist[i],bordercolourlist[i],backgroundcolourlist[i])}
</script>
</head>
<body onload="initial();" onunload="return unload_body();">
<div id="TopBanner"></div>
<div id="Loading" class="popup_bg"></div>
<iframe name="hidden_frame" id="hidden_frame" src="about:blank" width="0" height="0" frameborder="0"></iframe>
<form method="post" name="form" id="ruleForm" action="/start_apply.htm" target="hidden_frame">
<input type="hidden" name="current_page" value="">
<input type="hidden" name="next_page" value="">
<input type="hidden" name="modified" value="0">
<input type="hidden" name="action_mode" value="apply">
<input type="hidden" name="action_script" value="start_ntpmerlin">
<input type="hidden" name="action_wait" value="35">
<input type="hidden" name="first_time" value="">
<input type="hidden" name="SystemCmd" value="">
<input type="hidden" name="preferred_lang" id="preferred_lang" value="<% nvram_get("preferred_lang"); %>">
<input type="hidden" name="firmver" value="<% nvram_get("firmver"); %>">
<input type="hidden" name="amng_custom" id="amng_custom" value="">
<table class="content" align="center" cellpadding="0" cellspacing="0">
<tr>
<td width="17">&nbsp;</td>
<td valign="top" width="202">
<div id="mainMenu"></div>
<div id="subMenu"></div></td>
<td valign="top">
<div id="tabMenu" class="submenuBlock"></div>
<table width="98%" border="0" align="left" cellpadding="0" cellspacing="0">
<tr>
<td valign="top">
<table width="760px" border="0" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTitle" id="FormTitle">
<tbody>
<tr bgcolor="#4D595D">
<td valign="top">
<div>&nbsp;</div>
<div class="formfonttitle" id="scripttitle" style="text-align:center;">ntpMerlin</div>
<div id="statstitle" style="text-align:center;">Stats last updated:</div>
<div style="margin:10px 0 10px 5px;" class="splitLine"></div>
<div class="formfontdesc">ntpMerlin implementa un servidor de tiempo NTP para AsusWRT Merlin con gráficos de resúmenes de rendimiento diarios, semanales y mensuales. Está disponible una opción entre ntpd y chrony.</div>
<table width="100%" border="1" align="center" cellpadding="2" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" style="border:0px;" id="table_buttons">
<thead class="collapsible-jquery" id="scripttools">
<tr><td colspan="2">Utilidades (click para expandir/contraer)</td></tr>
</thead>
<tr>
<th width="20%">Información de Versión</th>
<td>
<span id="ntpmerlin_version_local" style="color:#FFFFFF;"></span>
&nbsp;&nbsp;&nbsp;
<span id="ntpmerlin_version_server" style="display:none;">Actualizar versión</span>
&nbsp;&nbsp;&nbsp;
<input type="button" class="button_gen" onclick="CheckUpdate();" value="Comprobar" id="btnChkUpdate">
<img id="imgChkUpdate" style="display:none;vertical-align:middle;" src="images/InternetScan.gif"/>
<input type="button" class="button_gen" onclick="DoUpdate();" value="Actualizar" id="btnDoUpdate" style="display:none;">
&nbsp;&nbsp;&nbsp;
</td>
</tr>
<tr>
<th width="20%">Actualizar estadísticas</th>
<td>
<input type="button" onclick="UpdateStats();" value="Actualizar" class="button_gen" name="btnUpdateStats" id="btnUpdateStats">
<img id="imgNTPUpdate" style="display:none;vertical-align:middle;" src="images/InternetScan.gif"/>
&nbsp;&nbsp;&nbsp;
<span id="ntpupdate_text" style="display:none;"></span>
</td>
</tr>
<tr>
<th width="20%">Exportar</th>
<td>
<a id="aExport" href="" download="ntpmerlin.csv"><input type="button" value="Exportar a CSV" class="button_gen" name="btnExport"></a>
</td>
</tr>
</table>
<div style="line-height:10px;">&nbsp;</div>
<table width="100%" border="1" align="center" cellpadding="2" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" style="border:0px;" id="table_config">
<thead class="collapsible-jquery" id="scriptconfig">
<tr><td colspan="2">Configuración (click para expandir/contraer)</td></tr>
</thead>
<tr class="even" id="rowdataoutput">
<th width="40%">Modo Salida de Datos<br/><span style="color:#FFCC00;">(para gráficos semanales y mensuales)</span></th>
<td class="settingvalue">
<input type="radio" name="ntpmerlin_outputdatamode" id="ntpmerlin_dataoutput_average" class="input" value="average" checked>
<label for="ntpmerlin_dataoutput_average" class="settingvalue">Media</label>
<input type="radio" name="ntpmerlin_outputdatamode" id="ntpmerlin_dataoutput_raw" class="input" value="raw">
<label for="ntpmerlin_dataoutput_raw" class="settingvalue">Bruto</label>
</td>
</tr>
<tr class="even" id="rowtimeoutput">
<th width="40%">Modo Salida de Tiempo<br/><span style="color:#FFCC00;">(for CSV export)</span></th>
<td class="settingvalue">
<input type="radio" name="ntpmerlin_outputtimemode" id="ntpmerlin_timeoutput_non-unix" class="input" value="non-unix" checked>
<label for="ntpmerlin_timeoutput_non-unix" class="settingvalue">No-Unix</label>
<input type="radio" name="ntpmerlin_outputtimemode" id="ntpmerlin_timeoutput_unix" class="input" value="unix">
<label for="ntpmerlin_timeoutput_unix" class="settingvalue">Unix</label>
</td>
</tr>
<tr class="even" id="rowstorageloc">
<th width="40%">Ubicación Almacenamiento de Datos</th>
<td class="settingvalue">
<input type="radio" name="ntpmerlin_storagelocation" id="ntpmerlin_storageloc_jffs" class="input" value="jffs" checked>
<label for="ntpmerlin_storageloc_jffs" class="settingvalue">JFFS</label>
<input type="radio" name="ntpmerlin_storagelocation" id="ntpmerlin_storageloc_usb" class="input" value="usb">
<label for="ntpmerlin_storageloc_usb" class="settingvalue">USB</label>
</td>
</tr>
<tr class="even" id="rowtimeserver">
<th width="40%">Servidor NTP</th>
<td class="settingvalue">
<input type="radio" name="ntpmerlin_timeserver" id="ntpmerlin_timeserver_ntpd" class="input" value="ntpd" checked>
<label for="ntpmerlin_timeserver_ntpd" class="settingvalue">NTPD</label>
<input type="radio" name="ntpmerlin_timeserver" id="ntpmerlin_timeserver_chronyd" class="input" value="chronyd">
<label for="ntpmerlin_timeserver_chronyd" class="settingvalue">Chrony</label>
</td>
</tr>
<tr class="apply_gen" valign="top" height="35px">
<td colspan="2" style="background-color:rgb(77, 89, 93);">
<input type="button" onclick="SaveConfig();" value="Guardar" class="button_gen" name="button">
</td>
</tr>
</table>
<div style="line-height:10px;">&nbsp;</div>
<table width="100%" border="1" align="center" cellpadding="2" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" style="border:0px;" id="table_buttons2">
<thead class="collapsible-jquery" id="ntpmerlin_charttools">
<tr><td colspan="2">Opciones de Vista de los Gráficos (click para expandir/contraer)</td></tr>
</thead>
<tr>
<th width="20%"><span style="color:#FFFFFF;">Formato de tiempo</span><br /><span style="color:#FFCC00;">((para informacion del eje de las últimas 24 horas))</span></th>
<td>
<select style="width:100px" class="input_option" onchange="changeAllCharts(this)" id="Time_Format">
<option value="0">24h</option>
<option value="1">12h</option>
</select>
</td>
</tr>
<tr class="apply_gen" valign="top">
<td style="background-color:rgb(77, 89, 93);" colspan="2">
<input type="button" onclick="ToggleDragZoom(this);" value="Ventana Zoom" class="button_gen" name="btnDragZoom">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
<input type="button" onclick="ResetZoom();" value="Anular Zoom" class="button_gen" name="btnResetZoom">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
<input type="button" onclick="ToggleLines();" value="Líneas" class="button_gen" name="btnToggleLines">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
<input type="button" onclick="ToggleFill();" value="Relleno" class="button_gen" name="btnToggleFill">
</td>
</tr>
</table>
<div style="line-height:10px;">&nbsp;</div>
<table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" id="table_charts">
<thead class="collapsible-jquery" id="thead_charts">
<tr>
<td>Gráficos (click para expandir/contraer)</td>
</tr>
</thead>
<tr><td align="center" style="padding: 0px;">
<table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable">
<thead class="collapsible-jquery" id="chart_offset">
<tr>
<td colspan="2">Offset (click para expandir/contraer)</td>
</tr>
</thead>
<tr class="even">
<th width="40%">Período para mostrar</th>
<td>
<select style="width:150px" class="input_option" onchange="changeChart(this)" id="Offset_Period">
<option value="0">Últimas 24 horas</option>
<option value="1">Últimos 7 días</option>
<option value="2">Últimos 30 días</option>
</select>
</td>
</tr>
<tr>
<td colspan="2" align="center" style="padding: 0px;">
<div style="background-color:#2f3e44;border-radius:10px;width:730px;height:500px;padding-left:5px;"><canvas id="divLineChart_Offset" height="500" /></div>
</td>
</tr>
</table>
<div style="line-height:10px;">&nbsp;</div>
<table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable">
<thead class="collapsible-jquery" id="chart_drift">
<tr>
<td colspan="2">Drift (click para expandir/contraer)</td>
</tr>
</thead>
<tr class="even">
<th width="40%">Período para mostrar</th>
<td>
<select style="width:150px" class="input_option" onchange="changeChart(this)" id="Drift_Period">
<option value="0">Últimas 24 horas</option>
<option value="1">Últimos 7 días</option>
<option value="2">Últimos 30 días</option>
</select>
</td>
</tr>
<tr>
<td colspan="2" align="center" style="padding: 0px;">
<div style="background-color:#2f3e44;border-radius:10px;width:730px;height:500px;padding-left:5px;"><canvas id="divLineChart_Drift" height="500" /></div>
</td>
</tr>
</table>
</td>
</tr>
</table>
</td>
</tr>
</tbody>
</table>
</td>
</tr>
</table>
</td>
</tr>
</table>
</form>
<form method="post" name="formScriptActions" action="/start_apply.htm" target="hidden_frame">
<input type="hidden" name="productid" value="<% nvram_get("productid"); %>">
<input type="hidden" name="current_page" value="">
<input type="hidden" name="next_page" value="">
<input type="hidden" name="action_mode" value="apply">
<input type="hidden" name="action_script" value="">
<input type="hidden" name="action_wait" value="">
</form>
<div id="footer"></div>
</body>
</html>
