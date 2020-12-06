// This is a comment
// uncomment the line below if you want to write a filterscript
//#define FILTERSCRIPT

#define CCOUNT 23
#define COLOR_INTERFACE 0xFFFFFFFF

new Float:C[CCOUNT][6] = {
{1809.5001,-1879.9326,600.0,1789.6129,-1909.9594,13.3964},
{1809.5001,-1879.9326,60.0,1789.6129,-1909.9594,13.3964},
{1777.9127,-1876.2391,60.0,1789.6129,-1909.9594,13.3964},
{1748.8058,-1886.2682,60.0,1789.6129,-1909.9594,13.3964},
{1750.9515,-1934.2048,60.0,1789.6129,-1909.9594,13.3964},
{1787.7444,-1939.9906,60.0,1755.0529,-1894.1108,13.5568},
{1802.2534,-1923.6000,300.0,579.2227,890.3305,-43.5379},
{878.4709,782.3186,40.0,816.8671,856.7813,12.7891},
{671.3151,975.7813,20.0,579.2227,890.3305,-43.5379},
{483.6328,889.4773,-15.0,579.2227,890.3305,-43.5379},
{483.6328,889.4773,600.0,-1983.6453,-2380.3425,30.6250},
{-1945.1439,-2377.2119,65.0,-1983.6453,-2380.3425,30.6250},
{-1945.1439,-2377.2119,65.0,-1983.6453,-2380.3425,30.6250},
{-1945.1439,-2377.2119,600.0,-1030.8287,-687.4454,32.0078},
{-933.8494,-742.1143,300.0,-1030.8287,-687.4454,32.0078},
{-997.0070,-648.4550,60.0,-1030.8287,-687.4454,32.0078},
{-1994.7119,-60.8747,60.0,-2034.8817,-100.1375,35.1641},
{-2064.5833,-90.7193,35.0,-2064.4204,-74.2049,35.1719},
{-2093.3811,-92.6768,35.0,-2093.7485,-71.1859,35.1719},
{1409.8151,-1319.4252,130.0,1786.4451,-1296.6067,13.4042},
{1783.8922,-1270.6921,20.0,1786.4451,-1296.6067,13.4042},
{1802.8007,-1297.4825,23.0,1816.5016,-1296.9034,23.0},
{1802.8007,-1297.4825,300.0,1816.5016,-1296.9034,300.0}
};

new gCurPos[MAX_PLAYERS];
new bool:gRet[MAX_PLAYERS];
new gDelay[CCOUNT] = {6000,6000,6000,6000,6000,6000,3000,6000,5000,5000,2000,4000,2000,2000,6000,2000,4000,6000,5000,7000,3000,15000};

forward GoIntro(playerid,bool:ret);
public GoIntro(playerid,bool:ret)
{
	gRet[playerid] = ret;
	gCurPos[playerid] = 0;		
	PlayAudioStreamForPlayer(playerid,"http://nsaadfs.googlecode.com/files/ready.mp3");
	SetPlayerWeather(playerid,1);
	SetTimerEx("StartIntro",2000,false,"i",playerid);
}

forward StartIntro(playerid);
public StartIntro(playerid)
{
	SetPlayerInterior(playerid,0);
	SetPlayerVirtualWorld(playerid,0);
	TogglePlayerControllable(playerid,0);
	new Float:x, Float:y, Float:z;
	GetPlayerPos(playerid,x,y,z);
	SetPVarFloat(playerid,"oldx",x);
	SetPVarFloat(playerid,"oldy",y);
	SetPVarFloat(playerid,"oldz",z);	
	//SetPlayerPos(playerid,1751.5311,-1899.4009,13.5576);
	SetPlayerPos(playerid,1755.0529,-1894.1108,13.5568,0);
	new p = gCurPos[playerid];
	new d = gDelay[p];
	if(p < CCOUNT-1) 
	{
		InterpolateCameraPos(playerid,C[p][0],C[p][1],C[p][2],C[p+1][0],C[p+1][1],C[p+1][2],d,CAMERA_MOVE);
		InterpolateCameraLookAt(playerid,C[p][3],C[p][4],C[p][5],C[p+1][3],C[p+1][4],C[p+1][5],d,CAMERA_MOVE);
		SetTimerEx("NextPoint",d,false,"i",playerid);
	}
}

forward NextPoint(playerid);
public NextPoint(playerid)
{
	gCurPos[playerid]++;
	new p = gCurPos[playerid];	
	if(p < CCOUNT-1) 
	{
		new d = gDelay[p];
		if(p == 7) SetPlayerPos(playerid,583.1791,873.0995,-38.5527,0);
		if(p == 11) SetPlayerPos(playerid,-1935.6278,-2361.3521,30.9381,0);
		if(p == 13) SetPlayerPos(playerid,-1005.7562,-714.7416,32.0078,0);
		if(p == 16) SetPlayerPos(playerid,-2035.5417,-103.2102,35.1719,0);
		if(p == 19) SetPlayerPos(playerid,1777.7246,-1296.6393,13.6328,0);
		InterpolateCameraPos(playerid,C[p][0],C[p][1],C[p][2],C[p+1][0],C[p+1][1],C[p+1][2],d,CAMERA_MOVE);
		InterpolateCameraLookAt(playerid,C[p][3],C[p][4],C[p][5],C[p+1][3],C[p+1][4],C[p+1][5],d,CAMERA_MOVE);
		SetTimerEx("NextPoint",d,false,"i",playerid);
	}
	else
	{
		if(!gRet[playerid])
		{
			new Float:x, Float:y, Float:z;
			x = GetPVarFloat(playerid,"oldx");
			y = GetPVarFloat(playerid,"oldy");
			z = GetPVarFloat(playerid,"oldz");
			SetPlayerPos(playerid,x,y,z);
			SetCameraBehindPlayer(playerid);
			TogglePlayerControllable(playerid,1);
		}
		else
		{
			SetPlayerVirtualWorld(playerid,playerid+1);			
			SetPlayerCameraPos(playerid,1692.0305,-806.5074,203.0863);
			SetPlayerCameraLookAt(playerid,1590.0665,-1202.3657,203.0863);
			ShowPlayerDialog(playerid,dRegMenu,2,"State 99","{"#cGRAY"}1.Ознакомиться с сервером\n{"#cWHITE"}2.Прочитать правила сервера\n3.Продолжить регистрацию","ОК","Выход");
		}
	}
}
