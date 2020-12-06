// SAMP FINANCE GAME V2.1.2

// тест PayDay
// Добавление велоаренды возле бизнес-центра и торгового центра
// Добавление домов
// Тест стоимости бизнесов с несколькими игроками
// Тест системы входа с игроками
// Тест всех диалогов
// Тест всех команд

#include <a_samp>
#include <a_http>
#include <gl_common>
#include <a_mysql>
#include <sscanf2>
#include <streamer>
#include <dc_cmd>
#include <PointToPoint>
#include <foreach>

#define MYSQLHOST "localhost"   // HOST MYSQL
#define MYSQLUSER "root"        // Имя пользователя MYSQL
#define MYSQLPASS ""            // Пароль пользователя MYSQL
#define MYSQLDABE "sfg"         // Имя базы MYSQL

#define SCM SendClientMessage
#define SCMTA SendClientMessageToAll
#define SPD ShowPlayerDialog
#define DSM DIALOG_STYLE_MSGBOX
#define DSI DIALOG_STYLE_INPUT
#define DSL DIALOG_STYLE_LIST
#define DSP DIALOG_STYLE_PASSWORD
#define DST DIALOG_STYLE_TABLIST
#define DSTH DIALOG_STYLE_TABLIST_HEADERS
#define COLOR_RED 0xFF0000AA
#define COLOR_BLACK 0x000000AA
#define COLOR_GRAY 0xAFAFAFAA
#define COLOR_OTVET 0x83F9C8AA
#define COLOR_ME 0xB27BD8AA
#define COLOR_GREEN 0x33AA33AA
#define COLOR_LRED 0xF85E43AA
#define COLOR_YELLOW 0xFFFF00AA
#define COLOR_WHITE 0xFFFFFFFF
#define COLOR_BLUE 0x4682B4AA
#define COLOR_ORANGE 0xFF9900AA
#define COLOR_SYSTEM 0xEFEFF7AA
#define COLOR_PINK 0xE75480FF
#define COLOR_INFO 0x269BD8FF
#define COLOR_ADMIN 0xF36223FF
#define publics%0(%1) forward%0(%1); public%0(%1)
#define RandomEx(%1,%2) (random(%2-%1)+%1)
#define GN(%1) Player[%1][pNickname]
#define GPN GetPlayerName(playerid, Player[playerid][pName], MAX_PLAYER_NAME);
#define PRESSED(%0) (((newkeys & (%0)) == (%0)) && ((oldkeys & (%0)) != (%0)))
#define RELEASED(%0) (((newkeys & (%0)) != (%0)) && ((oldkeys & (%0)) == (%0)))
#undef MAX_PLAYERS
#define MAX_PLAYERS 2
#define MAX_BUSINESS 9 // +1
#define MAX_HOUSE 1 // +1
#define MAX_RENT_VEH 40

enum pInfo
{
	pID,
	pNickname[32],
	pPassword[32],
	pEXP,
	pMoney,
	pDonate,
	pDonated,
	pCharity,
	pWithdraw,
	pWithdrawed,
	pWarn,
	pSkin,
	pInsurance,
	pHouse,
	pBusiness1,
	pBusiness2,
	pBusiness3,
	pVIP
}
enum hInfo
{
	hID,
	hOwner,
	hPrice,
	Float:hX,
	Float:hY,
	Float:hZ,
	hPick,
	Text3D:hText
}
enum bInfo
{
	bID,
    bName[64],
    bOwner,
    bPrice,
    Float:bX,
    Float:bY,
    Float:bZ,
    bBalance,
    bPick,
    Text3D:bText
}
enum rInfo
{
    rID,
    rPrice,
    rRenter
}
enum dInfo
{
	dLogin,
	dDonate,
	dDonateMoney,
	dDonateEXP,
	dVIP,
	dTaxi,
	dBuyLottery,
	dBetting,
	dBuySkin,
	dBuyInsurance,
	dRentCar,
	dWork,
	dWorkConfirm,
	dBusinessMenu,
	dBusinessMenu2,
	dAdminMenu,
	dEmptyResult
}
new Player[MAX_PLAYERS][pInfo];
// new House[MAX_HOUSES][hInfo];
new Business[MAX_BUSINESS][bInfo];
new bool: login[MAX_PLAYERS] = false;
new bool: alogin[MAX_PLAYERS] = false;
new bool: spawn[MAX_PLAYERS] = false;
new bool: tp[MAX_PLAYERS] = false;
new loginAttempt[MAX_PLAYERS] = 0;
new work[MAX_PLAYERS] = 0;
new bizSelected[MAX_PLAYERS] = 0;
new Float:tpX[MAX_PLAYERS];
new Float:tpY[MAX_PLAYERS];
new Float:tpZ[MAX_PLAYERS];
new rented_bike[MAX_PLAYERS];
new created_veh[MAX_PLAYERS];
new kazna = 0;
new RentCar[MAX_RENT_VEH][rInfo];
new IsRentableVehicle[MAX_VEHICLES];
new RenterName[MAX_PLAYER_NAME];

forward OnPlayerJoin(playerid);
forward UpdateTime();

main() {}

public OnGameModeInit()
{
	mysql_connect(MYSQLHOST, MYSQLUSER, MYSQLDABE, MYSQLPASS);
	new second, minute, hour;
	gettime(hour, minute, second);
	SetWorldTime(hour);
	if(mysql_ping() == 1)
	{
	    mysql_debug(0);
		printf("[Успешно] Соединение с MySQL сервером установлено");
	}
	else
	{
		printf("[Ошибка] Соединение с MySQL сервером не установлено");
		SendRconCommand("exit");
		GameModeExit();
		return true;
	}
	DisableInteriorEnterExits();
	EnableStuntBonusForAll(0);
	LimitGlobalChatRadius(13.0);
	LimitPlayerMarkerRadius(12.0);
	SetGameModeText("SFG 2.0.0");
	mysql_query("SET CHARACTER SET cp1251");
    SetTimer("UpdateTime", 1000*60, 1);
	SetWeather(1);
	Load();
	LoadBusiness();
	LoadTreasury();
	return true;
}

public OnGameModeExit()
{
 	SaveTreasury();
 	SaveBusiness();
	mysql_close();
	return true;
}

public OnPlayerRequestClass(playerid, classid)
{
    RemoveBuildingForPlayer(playerid, 1226, 1774.7578, -1931.3125, 16.3750, 0.25);
	RemoveBuildingForPlayer(playerid, 1226, 1806.4297, -1931.6016, 16.3750, 0.25);
	if(login[playerid]) return SpawnPlayer(playerid);
	SetTimerEx("OnPlayerJoin", 300, false, "i", playerid);
	return true;
}

public OnPlayerConnect(playerid)
{
	SetPlayerDataToDefault(playerid);
	return true;
}

public OnPlayerDisconnect(playerid)
{
	SaveTreasury();
	SaveBusiness();
	SavePlayer(playerid);
	return true;
}

public OnPlayerJoin(playerid)
{
	TogglePlayerControllable(playerid, 0);
	SpawnPlayer(playerid);
	SetPlayerVirtualWorld(playerid, playerid + 1);
	SetPlayerCameraPos(playerid, 1692.0305, -806.5074, 203.0863);
	SetPlayerCameraLookAt(playerid,1590.0665, -1202.3657, 203.0863);
	GetPlayerName(playerid, Player[playerid][pNickname], MAX_PLAYER_NAME);
	new query[256];
	mysql_real_escape_string(Player[playerid][pNickname], Player[playerid][pNickname]);
	format(query, sizeof(query), "SELECT `id` FROM `accounts` WHERE `nickname` = '%s'", Player[playerid][pNickname]);
	mysql_query(query);
	new tmp[16];
	mysql_store_result();
	mysql_fetch_row(tmp);
	mysql_free_result();
	format(query, sizeof(query), "SELECT `password` FROM `accounts` WHERE `nickname` = '%s'", Player[playerid][pNickname]);
	mysql_query(query);
	mysql_store_result();
	if(mysql_num_rows() > 0)
	{
		new result[128];
		mysql_fetch_row(result);
		sscanf(result,"p<|>s[24]", Player[playerid][pPassword]);
		if(!strlen(Player[playerid][pPassword]))
		{
			printf("[Error] Длина пароля игрока равна 0. Nickname: %s", Player[playerid][pNickname]);
			SCM(playerid, COLOR_RED, "Ошибка (#001). Обратитесь к администрации");
			KickPlayer(playerid, 50);
		}
  		SPD(playerid, dLogin, DSI, "Вход", "{FFFFFF}Добро пожаловать на сервер\n\n\tАккаунт зарегистрирован\n\tЧтобы войти введите пароль:", "ОК", "Выход");
	}
	else SCM(playerid, COLOR_GRAY, "Для регистрации аккаунта обратитесь к администрации!"), KickPlayer(playerid, 50);
	mysql_free_result();
	return true;
}

public OnPlayerSpawn(playerid)
{
    SetPlayerColor(playerid, 0xFFFFFF11);
	TogglePlayerControllable(playerid, 0);
	new Float:x, Float:y, Float:z;
	GetPlayerPos(playerid,x,y,z);
	if(!login[playerid]) return true;
	else 
	{
		SetPlayerSkin(playerid, Player[playerid][pSkin]);
		SetPlayerVirtualWorld(playerid, 0);
		SetPlayerInterior(playerid, 0);
		TogglePlayerControllable(playerid, 1);
		SetPlayerPos(playerid, 1755.0529, -1894.1108, 13.5568);
		SetPlayerFacingAngle(playerid, 270.0);
		SetCameraBehindPlayer(playerid);
		SetPlayerColor(playerid, 0xFFFFFF11);
	}
	if(Player[playerid][pMoney])
	{
		ResetPlayerMoney(playerid);		
		GivePlayerMoney(playerid, Player[playerid][pMoney]);
	}
	SetPlayerScore(playerid, Player[playerid][pEXP]);
	return true;
}

public OnPlayerDeath(playerid)
{
	spawn[playerid] = true;
	if(Player[playerid][pInsurance] == 0)
	{
	    if(Player[playerid][pMoney] >= 35)
	    {
	        SCM(playerid, COLOR_YELLOW, "Вы заплатили $35 за лечение, т.к. у вас нет страховки!");
	        transaction(playerid, -35);
	        kazna += 35;
		}
		else SCM(playerid, COLOR_YELLOW, "Недостаточно денег для оплаты лечения, государство покрыло ваши расходы!");
	}
	else SCM(playerid, COLOR_YELLOW, "Страховка покрыла ваши расходы на лечение!"), Player[playerid][pInsurance] -= 1;
	return true;
}

public OnPlayerText(playerid, text[])
{
	if(!login[playerid] || !Player[playerid][pID]) return true;
	new string[128];
    if(GetPlayerState(playerid) == PLAYER_STATE_ONFOOT)
    {
        ApplyAnimation(playerid, "PED", "IDLE_chat", 4.1, 0, 1, 1, 1, 1);
        SetTimerEx("Anim", 1000*3, 0, "i", playerid);
    }
	format(string, sizeof(string), "- %s (%s) [%d]", text, GN(playerid), playerid);
	SetPlayerChatBubble(playerid, text, COLOR_WHITE, 20.0, 5*1000);
	ProxDetector(20.0, playerid, string, COLOR_WHITE, COLOR_WHITE, COLOR_WHITE, COLOR_GRAY, COLOR_GRAY);
	return true;
}

public OnPlayerRequestSpawn(playerid)
{
	if(!login[playerid]) return true;
	return true;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(PRESSED(KEY_WALK))
	{
	    if(IsPlayerInRangeOfPoint(playerid, 1, 1786.75, -1299.74, 13.43)) SetPlayerPos(playerid, 1786.6896, -1299.7207, 120.2656); // Вход в бизнес-центр
		if(IsPlayerInRangeOfPoint(playerid, 1, 1786.69, -1299.72, 120.26)) SetPlayerPos(playerid, 1786.7538, -1299.7383, 13.4374); // Выход из бизнес-центра
		if(IsPlayerInRangeOfPoint(playerid, 2, 1125.90, -1483.27, 22.83)) // Автомат с газировкой
		{
			if(Player[playerid][pMoney] < 20) return err(playerid, "У вас недостаточно денег!");
			transaction(playerid, -20);
			kazna += 2;
			Business[1][bBalance] += 2;
			Business[4][bBalance] += 16;
			SetPlayerHealth(playerid, 100);
			new string[64];
			format(string, sizeof(string), "%s выпил Sprunk", GN(playerid));
        	ProxDetector(15.0, playerid, string, COLOR_ME, COLOR_ME, COLOR_ME, COLOR_ME, COLOR_ME);
		}
		if(IsPlayerInRangeOfPoint(playerid, 1, 1768.30, -1905.56, 13.56))
		{
			if(Player[playerid][pMoney] < 30) return err(playerid, "У вас недостаточно денег!");
			transaction(playerid, -30);
			kazna += 3;
			Business[1][bBalance] += 3;
			Business[8][bBalance] += 24;
			suc(playerid, "Вы арендовали велосипед!");
			new color = random(255);
			new Float:pos_x_veh, Float:pos_y_veh, Float:pos_z_veh;
			GetPlayerPos(playerid, pos_x_veh, pos_y_veh, pos_z_veh);
			rented_bike[playerid] = AddStaticVehicleEx(510, pos_x_veh, pos_y_veh, pos_z_veh, 270, color, color, -1);
			PutPlayerInVehicle(playerid, rented_bike[playerid], 0);
		}
		if(IsPlayerInRangeOfPoint(playerid, 1, 1111, -1484, 22.77))
		{
		    if(Player[playerid][pMoney] < 10) return err(playerid, "У вас недостаточно денег!");
		    transaction(playerid, -10);
		    kazna += 1;
		    Business[1][bBalance] += 1;
            Business[5][bBalance] += 8;
			GivePlayerWeapon(playerid, 24, 7);
			suc(playerid, "Вы купили Desert Eagle!");
		}
		if(IsPlayerInRangeOfPoint(playerid, 1, 1108, -1484, 22.77))
		{
			if(Player[playerid][pMoney] < 10) return err(playerid, "У вас недостаточно денег!");
			transaction(playerid, -10);
			kazna += 1;
			Business[1][bBalance] += 1;
			Business[5][bBalance] += 6;
			GivePlayerWeapon(playerid, 31, 50);
			suc(playerid, "Вы купили M4!");
		}
		if(IsPlayerInRangeOfPoint(playerid, 1, 1105, -1484, 22.6))
		{
			if(Player[playerid][pMoney] < 10) return err(playerid, "У вас недостаточно денег!");
			transaction(playerid, -10);
			kazna += 1;
			Business[1][bBalance] += 1;
			Business[5][bBalance] += 6;
			GivePlayerWeapon(playerid, 25, 5);
			suc(playerid, "Вы купили Shotgun!");
		}
		if(IsPlayerInRangeOfPoint(playerid, 1, 1102, -1484, 22.6))
		{
            if(Player[playerid][pMoney] < 10) return err(playerid, "У вас недостаточно денег!");
			transaction(playerid, -10);
			kazna += 1;
			Business[1][bBalance] += 1;
			Business[5][bBalance] += 6;
			GivePlayerWeapon(playerid, 29, 30);
			suc(playerid, "Вы купили MP5!");
		}
		if(IsPlayerInRangeOfPoint(playerid, 1, 1099, -1484, 22.6))
		{
			if(Player[playerid][pMoney] < 10) return err(playerid, "У вас недостаточно денег!");
			transaction(playerid, -10);
			kazna += 6;
			Business[1][bBalance] += 2;
			Business[5][bBalance] += 2;
			GivePlayerWeapon(playerid, 33, 5);
			suc(playerid, "Вы купили Rifle!");
		}
		if(IsPlayerInRangeOfPoint(playerid, 1, 1096, -1484, 22.6))
		{
		    if(Player[playerid][pMoney] < 10) return err(playerid, "У вас недостаточно денег!");
			transaction(playerid, -10);
			kazna += 1;
			Business[1][bBalance] += 1;
			Business[5][bBalance] += 6;
			SetPlayerArmour(playerid, 100);
			suc(playerid, "Вы купили бронежилет!");
		}
		if(IsPlayerInRangeOfPoint(playerid, 1, 1090.23, -1475.58, 22.74)) SPD(playerid, dBuyInsurance, DSI, "Страховая компания", "Укажите количество страховых купонов для покупки (1-1000)", "Далее", "Выход");
		if(IsPlayerInRangeOfPoint(playerid, 1, 1170.44, -1489.66, 22.75)) SPD(playerid, dBuySkin, DSI, "Магазин одежды", "Введите ID скина (1-311). Стоимость скина - $350", "Далее", "Выход");
		if(IsPlayerInRangeOfPoint(playerid, 1, 1122.5, -1486, 22.77)) SPD(playerid, dBuyLottery, DSL, "Лотерея", "Мгновенная лотерея ($50)\nСделать ставку", "Далее", "Выход");
		if(IsPlayerInRangeOfPoint(playerid, 1, 1801.8662, -1304, 120) || IsPlayerInRangeOfPoint(playerid, 1, 1803.8063, -1304, 120) || IsPlayerInRangeOfPoint(playerid, 1, 1805.8135, -1304, 120))
		{
		    if(work[playerid] == 0) return SPD(playerid, dWork, DSL, "Работа в бизнес-центре", "Получить работу\nПодтвердить работу", "Далее", "Выход");
			else SPD(playerid, dWorkConfirm, DSI, "Работа в бизнес-центре", "Введите ответ", "Далее", "Выход");
		}
	}
	return true;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	new string[256];
	switch(dialogid)
	{
	    case dLogin:
	    {
            if(!response) return KickPlayer(playerid, 50);
			else if(!strlen(inputtext)) SPD(playerid, dLogin, DSI, "Вход", "{FFFFFF}Добро пожаловать на сервер\n\n\tАккаунт зарегистрирован\n\tЧтобы войти введите пароль:", "ОК", "Выход");
			else
			{
				if(!strcmp(inputtext, Player[playerid][pPassword], false, MAX_PLAYER_NAME))
				{
					login[playerid] = true;
					LoadPlayerData(playerid);
					if(Player[playerid][pWarn] == 10) return SCM(playerid, COLOR_RED, "Ваш аккаунт заблокирован (10 предупреждений)"), KickPlayer(playerid, 50);
					SetPlayerScore(playerid, Player[playerid][pEXP]);
					SpawnPlayer(playerid);
					suc(playerid, "Вы вошли в аккаунт");
				}
				else
				{
					loginAttempt[playerid]++;
					format(string, sizeof(string), "Пароль введен неверно [%d/3]", loginAttempt[playerid]);
					SCM(playerid, COLOR_RED, string);
					if(loginAttempt[playerid] == 3) return KickPlayer(playerid, 50);
					SPD(playerid, dLogin, DSI, "Вход", "{FFFFFF}Добро пожаловать на сервер\n\n\tАккаунт зарегистрирован\n\tЧтобы войти введите пароль:", "ОК", "Выход");
				}
			}
		}
		case dDonate:
		{
			if(response)
			{
				switch(listitem)
				{
					case 0: SPD(playerid, dDonateMoney, DSI, "Игровая валюта", "Введите количество рублей, которое хотите обменять на игровую валюту", "Далее", "Назад");
					case 1:
					{
					    if(Player[playerid][pWarn] == 0) return err(playerid, "У вас нет предупреждений!");
					    new price = 2500;
					    if(Player[playerid][pVIP] == 1) price = 2000;
                        if(Player[playerid][pMoney] < price) return err(playerid, "У вас недостаточно денег!");
						transaction(playerid, -price);
						kazna += price;
						Player[playerid][pWarn] -= 1;
						suc(playerid, "Предупреждение снято!");
					}
					case 2:
					{
						if(Player[playerid][pVIP] == 1) return err(playerid, "Вы уже VIP-игрок!");
                        if(Player[playerid][pDonate] < 25) return err(playerid, "На вашем донат-счете недостаточно денег!");
                        Player[playerid][pDonate] -= 25;
						Player[playerid][pVIP] = 1;
						suc(playerid, "Теперь вы VIP-игрок!");
					}
					case 3: SPD(playerid, dDonateEXP, DSI, "EXP", "Введите количество EXP, которое хотите купить", "Далее", "Назад");
				}
			}
		}
		case dDonateMoney:
		{
			if(response)
			{
	   			new donateobmen = strval(inputtext);
	   			if(!strval(inputtext) || donateobmen < 1 || donateobmen > 1000000) return SPD(playerid, dDonateMoney, DSI, "Игровая валюта", "Введите количество рублей, которое хотите обменять на игровую валюту", "Далее", "Назад");
	   			if(Player[playerid][pDonate] < donateobmen) return err(playerid, "На вашем донат-счете недостаточно денег!");
	   			new kurs = 900;
	   			if(Player[playerid][pVIP] == 1) kurs = 950;
				transaction(playerid, donateobmen*kurs);
		        Player[playerid][pDonate] -= donateobmen;
		        format(string, sizeof(string), "Вы перевели {269BD8}%d рублей {FFFFFF}в {33AA33}$%d!", donateobmen, donateobmen*kurs);
		        suc(playerid, string);
    		}
		}
		case dDonateEXP:
		{
            if(response)
		    {
				new buyexp = strval(inputtext);
	   			if(!strval(inputtext) || buyexp < 1 || buyexp > 1000000) return SPD(playerid, dDonateEXP, DSI, "EXP", "Введите количество EXP, которое хотите купить", "Далее", "Назад");
	   			new price = 750;
	   			if(Player[playerid][pVIP] == 1) price = 700;
	   			if(Player[playerid][pMoney] < buyexp*price) return err(playerid, "У вас недостаточно денег!");
				transaction(playerid, -buyexp*price);
		        Player[playerid][pEXP] += buyexp;
		        format(string, sizeof(string), "Вы купили {269BD8}%d EXP{FFFFFF}!", buyexp);
		        suc(playerid, string);
		        SetPlayerScore(playerid, Player[playerid][pEXP]);
    		}
		}
		case dVIP:
		{
            if(response)
			{
				switch(listitem)
				{
					case 0:
					{
						if(Player[playerid][pMoney] < 10) return err(playerid, "У вас недостаточно денег!");
						transaction(playerid, -10);
						kazna += 10;
						SetPlayerHealth(playerid, 100);
					}
					case 1:
					{
					    if(Player[playerid][pMoney] < 10) return err(playerid, "У вас недостаточно денег!");
						transaction(playerid, -10);
						kazna += 10;
						SetVehicleHealth(GetPlayerVehicleID(playerid), 1000);
						RepairVehicle(GetPlayerVehicleID(playerid));
					}
				}
			}
		}
		case dTaxi:
		{
            if(response)
			{
				static const Float:pos[][3] =
				{
					{1786.3552,-1287.2273,13.6328},
					{1129.0326,-1413.5546,13.6065}
				};
				if(Player[playerid][pMoney] < 50) return err(playerid, "У вас недостаточно денег!");
				transaction(playerid, -50);
				kazna += 50;
				SetPlayerPos(playerid, pos[listitem][0], pos[listitem][1], pos[listitem][2]);
				SCM(playerid, COLOR_GREEN, "Точка назначения достигнута!");
			}
		}
		case dBuyLottery:
		{
            if(response)
			{
				switch(listitem)
				{
					case 0:
					{
						if(Player[playerid][pMoney] < 50) return err(playerid, "У вас недостаточно денег!");
						transaction(playerid, -50);
						kazna += 5;
						Business[1][bBalance] += 5;
						Business[3][bBalance] += 40;
						new rnd = random(100);
						// 5000 = (1500-2500)*1 + (275-375)*3 + (75-115)*5 + (35-55)*5 + 51*0 (2875-4475)
						switch(rnd)
						{
							case 0..50: SCM(playerid, COLOR_LRED, "Вы проиграли, попробуйте еще раз!");
							case 51..90:
							{
								new win = random(21)+35; // 35-55
								format(string, sizeof(string), "Вы выиграли $%d, поздравляем!", win);
								SCM(playerid, COLOR_GREEN, string);
								Business[3][bBalance] -= win;
								transaction(playerid, win);
							}
							case 91..95:
							{
			    				new win = random(41)+75; // 75-115
                                format(string, sizeof(string), "Вы выиграли $%d, поздравляем!", win);
								SCM(playerid, COLOR_GREEN, string);
								Business[3][bBalance] -= 100;
								transaction(playerid, 100);
							}
							case 96..98:
							{
								new win = random(101)+275; // 275-375
								format(string, sizeof(string), "Вы выиграли $%d, поздравляем!", win);
								SCM(playerid, COLOR_GREEN, string);
								Business[3][bBalance] -= 350;
								transaction(playerid, 350);
							}
							case 99:
							{
							    new win = random(1001)+1500; // 1500-2500
								format(string, sizeof(string), "Вы выиграли $%d, поздравляем!", win);
								SCM(playerid, COLOR_GREEN, string);
								Business[3][bBalance] -= 3000;
								transaction(playerid, 3000);
							}
						}
					}
					case 1: SPD(playerid, dBetting, DSI, "Лотерея", "Введите ставку ($10 - $100.000.000)", "Далее", "Выход");
				}
			}
		}
		case dBetting:
		{
            if(response)
			{
                new bet = strval(inputtext);
	   			if(!strval(inputtext) || bet < 10 || bet > 100000000) return SPD(playerid, dBetting, DSI, "Лотерея", "Введите ставку ($10 - $100.000.000)", "Далее", "Назад");
	   			if(Player[playerid][pMoney] < bet) return err(playerid, "У вас недостаточно денег!");
	   			transaction(playerid, -bet);
	   			kazna += bet/10;
	   			Business[1][bBalance] += bet/10;
	   			Business[3][bBalance] += bet*4/5;
	   			new rnd = random(100);
	   			if(rnd > 59)
	   			{
	   			    format(string, sizeof(string), "Вы выиграли в лотерее $%d, поздравляем!", bet*9/5);
					SCM(playerid, COLOR_GREEN, string);
					Business[3][bBalance] -= bet*9/5;
					transaction(playerid, bet*9/5);
				}
				else SCM(playerid, COLOR_LRED, "Вы проиграли, попробуйте еще раз!");
			}
		}
		case dBuySkin:
		{
            if(response)
			{
			    new skinid = strval(inputtext);
				if(!strval(inputtext) || skinid < 1 || skinid > 311) return SPD(playerid, dBuySkin, DSI, "Магазин одежды", "Введите ID скина (1-311). Стоимость скина - $350", "Далее", "Выход");
				if(Player[playerid][pMoney] < 350) return err(playerid, "У вас недостаточно денег!");
				transaction(playerid, -350);
				kazna += 35;
				Business[1][bBalance] += 35;
				Business[7][bBalance] += 280;
				SetPlayerSkin(playerid, skinid);
				Player[playerid][pSkin] = skinid;
				suc(playerid, "Вы купили скин!");
			}
		}
		case dBuyInsurance:
		{
            if(response)
			{
			    new amount = strval(inputtext);
			    if(!strval(inputtext) || amount < 1 || amount > 1000) return SPD(playerid, dBuyInsurance, DSI, "Страховая компания", "Укажите количество страховых купонов для покупки (1-1000)", "Далее", "Выход");
			    if(Player[playerid][pMoney] < amount*10) return err(playerid, "У вас недостаточно денег!");
				transaction(playerid, -amount*10);
				kazna += amount;
				Business[1][bBalance] += amount;
				Business[2][bBalance] += amount*8;
				Player[playerid][pInsurance] += amount;
				format(string, sizeof(string), "Вы купили %d страховых купонов", amount);
				suc(playerid, string);
			}
		}
		case dRentCar:
		{
            if(response)
			{
				new carprice = RentCar[GetPlayerVehicleID(playerid)][rPrice];
				if(Player[playerid][pMoney] < carprice)
	         	{
           			RemovePlayerFromVehicle(playerid);
                 	TogglePlayerControllable(playerid, 1);
                 	err(playerid, "У вас недостаточно денег!");
                 	return true;
	         	}
             	SCM(playerid, COLOR_GREEN, "Вы арендовали т/с!");
              	TogglePlayerControllable(playerid, 1);
              	transaction(playerid, -carprice);
              	kazna += carprice/10;
              	Business[1][bBalance] += carprice/10;
              	Business[6][bBalance] += carprice*4/5;
        		RentCar[GetPlayerVehicleID(playerid)][rRenter] = GetPlayerName(playerid, RenterName, sizeof(RenterName));
        	}
            else
        	{
            	RemovePlayerFromVehicle(playerid);
		    	TogglePlayerControllable(playerid, 1);
        	}
		}
		case dWork:
		{
            if(response)
			{
				new rnd1 = random(100), rnd2 = random(100);
				work[playerid] = rnd1 + rnd2;
				format(string, sizeof(string), "Вам необходимо найти сумму чисел %d и %d", rnd1, rnd2);
				SCM(playerid, COLOR_OTVET, string);
			}
		}
		case dWorkConfirm:
		{
            if(response)
			{
			    if(!strval(inputtext) || strval(inputtext) < 0 || strval(inputtext) > 200) return SPD(playerid, dWorkConfirm, DSI, "Работа в бизнес-центре", "Введите ответ", "Далее", "Выход");
				new answer = strval(inputtext);
				if(answer == work[playerid])
				{
				    new salary = random(50);
				    format(string, sizeof(string), "Вы дали правильный ответ и получили $%d", salary);
					SCM(playerid, COLOR_GREEN, string);
					work[playerid] = 0;
					transaction(playerid, salary);
					kazna -= salary;
				}
				else
				{
				    new rnd1 = random(100), rnd2 = random(100);
					work[playerid] = rnd1 + rnd2;
					err(playerid, "Вы дали неверный ответ!");
					format(string, sizeof(string), "Новое задание: Вам необходимо найти сумму чисел %d и %d", rnd1, rnd2);
					SCM(playerid, COLOR_OTVET, string);
				}
			}
		}
		case dBusinessMenu:
		{
            if(response)
			{
				switch(listitem)
				{
					case 0:
					{
						bizSelected[playerid] = 1;
					    format(string, sizeof(string), "Снять деньги ($%d)\nПродать бизнес ($%d)", Business[Player[playerid][pBusiness1]][bBalance], Business[Player[playerid][pBusiness1]][bPrice]/2);
						SPD(playerid, dBusinessMenu2, DSL, Business[Player[playerid][pBusiness1]][bName], string, "Далее", "Выход");
					}
					case 1:
					{
					    bizSelected[playerid] = 2;
						format(string, sizeof(string), "Снять деньги ($%d)\nПродать бизнес ($%d)", Business[Player[playerid][pBusiness2]][bBalance], Business[Player[playerid][pBusiness2]][bPrice]/2);
						SPD(playerid, dBusinessMenu2, DSL, Business[Player[playerid][pBusiness2]][bName], string, "Далее", "Выход");
					}
					case 2:
					{
						bizSelected[playerid] = 3;
						format(string, sizeof(string), "Снять деньги ($%d)\nПродать бизнес ($%d)", Business[Player[playerid][pBusiness3]][bBalance], Business[Player[playerid][pBusiness3]][bPrice]/2);
						SPD(playerid, dBusinessMenu2, DSL, Business[Player[playerid][pBusiness3]][bName], string, "Далее", "Выход");
					}
				}
			}
		}
		case dBusinessMenu2:
		{
            if(response)
			{
			    switch(bizSelected[playerid])
			    {
					case 1:
					{
						switch(listitem)
						{
							case 0:
							{
								transaction(playerid, Business[Player[playerid][pBusiness1]][bBalance]);
								Business[Player[playerid][pBusiness1]][bBalance] = 0;
								suc(playerid, "Вы сняли деньги!");
							}
							case 1:
							{
								Business[Player[playerid][pBusiness1]][bOwner] = 0;
							    UpdateBusiness(Player[playerid][pBusiness1]);
								transaction(playerid, Business[Player[playerid][pBusiness1]][bPrice]/2);
								Player[playerid][pBusiness1] = Player[playerid][pBusiness2];
								Player[playerid][pBusiness2] = Player[playerid][pBusiness3];
								Player[playerid][pBusiness3] = 0;
								suc(playerid, "Вы продали бизнес!");
							}
						}
					}
					case 2:
					{
						switch(listitem)
						{
							case 0:
							{
								transaction(playerid, Business[Player[playerid][pBusiness2]][bBalance]);
								Business[Player[playerid][pBusiness2]][bBalance] = 0;
								suc(playerid, "Вы сняли деньги!");
							}
							case 1:
							{
							    Business[Player[playerid][pBusiness2]][bOwner] = 0;
							    UpdateBusiness(Player[playerid][pBusiness2]);
								transaction(playerid, Business[Player[playerid][pBusiness2]][bPrice]/2);
								Player[playerid][pBusiness2] = Player[playerid][pBusiness3];
								Player[playerid][pBusiness3] = 0;
								suc(playerid, "Вы продали бизнес!");
							}
						}
					}
					case 3:
					{
						switch(listitem)
						{
							case 0:
							{
								transaction(playerid, Business[Player[playerid][pBusiness3]][bBalance]);
								Business[Player[playerid][pBusiness3]][bBalance] = 0;
								suc(playerid, "Вы сняли деньги!");
							}
							case 1:
							{
							    Business[Player[playerid][pBusiness3]][bOwner] = 0;
							    UpdateBusiness(Player[playerid][pBusiness3]);
							    Player[playerid][pBusiness3] = 0;
								transaction(playerid, Business[Player[playerid][pBusiness3]][bPrice]/2);
								suc(playerid, "Вы продали бизнес!");
							}
						}
					}
				}
			}
		}
		case dAdminMenu:
		{
            if(response)
			{
				switch(listitem)
				{
					case 0:
					{
						if(tp[playerid] == false) return inf(playerid, "Отметьте место на карте!");
						if(GetPlayerVehicleID(playerid) > 0 && GetPlayerState(playerid) == PLAYER_STATE_DRIVER) SetVehiclePos(GetPlayerVehicleID(playerid), tpX[playerid], tpY[playerid], tpZ[playerid]);
		  				else SetPlayerPos(playerid, tpX[playerid], tpY[playerid], tpZ[playerid]), SCM(playerid, COLOR_WHITE, "Вы телепортировались!");
					}
					case 1: PayDay();
					case 2: GameModeExit();
				}
			}
		}
		case dEmptyResult: return true;
	}
	return true;
}
public UpdateTime()
{
	new hour, minute, second;
	gettime(hour, minute, second);
	if(minute == 0) PayDay();
	return true;
}
public OnPlayerClickMap(playerid, Float:fX, Float:fY, Float:fZ)
{
	tp[playerid] = true, tpX[playerid] = fX, tpY[playerid] = fY, tpZ[playerid] = fZ;
 	return true;
}
public OnPlayerStateChange(playerid, newstate, oldstate)
{
	if(newstate == 2)
    {
		if(RentCar[GetPlayerVehicleID(playerid)][rRenter] == 0 && IsRentableVehicle[GetPlayerVehicleID(playerid)])
		{
			new string[144];
		    TogglePlayerControllable(playerid, 0);
            format(string, sizeof(string), "{FFFFFF}Этот транспорт сдается в аренду за {33AA33}$%d\n{FFFFFF}Хотите арендовать это т/с?", RentCar[GetPlayerVehicleID(playerid)][rPrice]);
			SPD(playerid, dRentCar, DSM, "Аренда", string, "Да", "Выход");
		}
		if(RentCar[GetPlayerVehicleID(playerid)][rRenter] != 0 && IsRentableVehicle[GetPlayerVehicleID(playerid)])
		{
			if(RentCar[GetPlayerVehicleID(playerid)][rRenter] != GetPlayerName(playerid, RenterName, sizeof(RenterName)))
			{
                 err(playerid, "Это т/с уже арендовано другим игроком!");
                 RemovePlayerFromVehicle(playerid);
		         TogglePlayerControllable(playerid, 1);
			}
	    }
	}
	return true;
}
stock KickPlayer(playerid, timer)
{
	SetTimerEx("KickTimer", timer, false, "i", playerid);
	return true;
}
forward KickTimer(playerid);
public KickTimer(playerid)
{
	Kick(playerid);
}
publics Anim(playerid)
{
    ApplyAnimation(playerid, "PED", "facanger", 4.1, 0, 1, 1, 1, 1);
	return true;
}
forward CountRentedVehicles();
public CountRentedVehicles()
{
	new count;
	for(new i = 1; i < TotalVehicles(); i++)
	{
	    if(IsRentableVehicle[i] == 1) count++;
	}
}
stock AddRentVehicle(id, model, Float:X, Float:Y, Float:Z, Float:Angle, color1, color2, price)
{
    new newvid = AddStaticVehicle(model, X, Y, Z, Angle, color1, color2);
    RentCar[newvid][rPrice] = price;
    RentCar[newvid][rID] = id;
    RentCar[newvid][rRenter] = 0;
    IsRentableVehicle[newvid] = 1;
    SetVehicleNumberPlate(newvid, "RENT");
}
TotalVehicles()
{
	new vid = CreateVehicle(411, 0, 0, 0, 0, -1, -1, 10);
	DestroyVehicle(vid);
	vid--;
	return vid;
}
forward SetCameraBehindPlayerDelay(playerid);
public SetCameraBehindPlayerDelay(playerid)
{
	SetCameraBehindPlayer(playerid);
}
stock SetPlayerDataToDefault(playerid)
{
	SPD(playerid, -1, DSM, "", "", "", "");
	Player[playerid][pID] = 0;
	strdel(Player[playerid][pNickname], 0, MAX_PLAYER_NAME);
	strdel(Player[playerid][pPassword], 0, MAX_PLAYER_NAME);
	Player[playerid][pEXP] = 0;
	Player[playerid][pMoney] = 0;
	Player[playerid][pEXP] = 0;
	Player[playerid][pDonate] = 0;
	Player[playerid][pDonated] = 0;
	Player[playerid][pCharity] = 0;
	Player[playerid][pWithdraw] = 0;
	Player[playerid][pWithdrawed] = 0;
	Player[playerid][pWarn] = 0;
	Player[playerid][pSkin] = 0;
	Player[playerid][pInsurance] = 0;
	Player[playerid][pHouse] = 0;
	Player[playerid][pBusiness1] = 0;
	Player[playerid][pBusiness2] = 0;
	Player[playerid][pBusiness3] = 0;
	Player[playerid][pVIP] = 0;
	login[playerid] = false;
	alogin[playerid] = false;
	spawn[playerid] = false;
	tp[playerid] = false;
	loginAttempt[playerid] = 0;
	work[playerid] = 0;
	bizSelected[playerid] = 0;
	strdel(Player[playerid][pNickname], 0, MAX_PLAYER_NAME);
	strdel(Player[playerid][pPassword], 0, MAX_PLAYER_NAME);
	return true;
}

stock UpdatePlayerData(playerid, field[], data)
{
	new query[512];
	format(query, sizeof(query), "UPDATE `accounts` SET `%s` = '%d' WHERE `id` = '%d'", field, data, Player[playerid][pID]);
	mysql_query(query);
	return mysql_errno();
}
stock Load()
{
	CreateObject(3483, 1796.52, -1925.67, 19.3855, 0, 0, 180);
	CreateObject(4003, 1767.2572, -1883.145, 16.66, 0, 0, 180);
	CreateObject(19464, 1786.83, -1301.2937, 121.7, 0, 0, 90);
	CreateObject(19464, 1786.39, -1301.33276, 15.1676, 0, 0, 90);
	CreateObject(1775, 1125.90, -1483.27625, 22.83194, 0, 0, 0);
	CreateObject(3860, 1122.45, -1484.19885, 22.75982, 0, 0, 0); // Палатка
	CreateObject(3860, 1114.41, -1484.19885, 22.75980, 0, 0, 0); // Палатка
	CreateObject(2009, 1804.90515, -1303.92, 119.2963, 0, 0, 0); // Стол
	CreateObject(2009, 1800.95898, -1303.92, 119.2963, 0, 0, 0); // Стол
	CreateObject(2009, 1802.92932, -1303.92, 119.2963, 0, 0, 0); // Стол
	SetTimer("CountRentedVehicles", 1000, 0);
   	AddRentVehicle(1, 542, 1106, -1485, 15.55, -60, 6, 6, 40);
   	AddRentVehicle(2, 542, 1106, -1480, 15.55, -60, 6, 6, 40);
   	AddRentVehicle(3, 579, 1106, -1475, 15.55, -60, 6, 6, 60);
   	AddRentVehicle(4, 579, 1106, -1470, 15.55, -60, 6, 6, 60);
	AddRentVehicle(5, 562, 1106, -1465, 15.55, -60, 6, 6, 80);
	AddRentVehicle(6, 562, 1106, -1460, 15.55, -60, 6, 6, 80);
	AddRentVehicle(7, 541, 1106, -1455, 15.55, -60, 6, 6, 100);
	AddRentVehicle(8, 541, 1106, -1450, 15.55, -60, 6, 6, 100);
	AddRentVehicle(9, 495, 1106, -1445, 15.55, -60, 6, 6, 120);
	AddRentVehicle(10, 495, 1106, -1440, 15.55, -60, 6, 6, 120);
	AddRentVehicle(11, 411, 1106, -1435, 15.55, -60, 6, 6, 150);
	AddRentVehicle(12, 411, 1106, -1430, 15.55, -60, 6, 6, 150);
	AddRentVehicle(13, 522, 1120, -1478, 15.35, 0, 6, 6, 250);
	AddRentVehicle(14, 522, 1120, -1483, 15.35, 0, 6, 6, 250);
	AddRentVehicle(15, 487, 1133, -1445, 15.35, 0, 6, 6, 500);
	AddRentVehicle(16, 487, 1124, -1445, 15.35, 0, 6, 6, 500);
	CreatePickup(19135, 23, 1786.7538, -1299.7383, 13.14, 0); // Вход в бизнес-центр
	CreatePickup(19135, 23, 1786.6896, -1299.7207, 119.96, 0); // Выход из бизнес-центра
	CreatePickup(1073, 23, 1768.30, -1905.56, 13.56, 0); // Аренда велосипедов ЖДЛС
	// Аренда велосипедов Бизнес-центр
	// Аренда велосипедов Торговый центр
    CreatePickup(411, 23, 1768.30, -1905.56, 13.56, 0); // Аренда велосипедов ЖДЛС (( test )) // инфернус как пикап
	CreatePickup(348, 23, 1111, -1484, 22.6, 0); // Deagle
	CreatePickup(356, 23, 1108, -1484, 22.6, 0); // M4
	CreatePickup(349, 23, 1105, -1484, 22.6, 0); // Shotgun
	CreatePickup(353, 23, 1102, -1484, 22.6, 0); // MP5
	CreatePickup(357, 23, 1099, -1484, 22.6, 0); // Rifle
	CreatePickup(373, 23, 1096, -1484, 22.6, 0); // Бронежилет
	CreatePickup(19135, 23, 1122.5, -1486, 22.47, 0); // Лотерея
	CreatePickup(19135, 23, 1090.23, -1475.58, 22.44, 0); // Страховая компания
	CreatePickup(19135, 23, 1170.44, -1489.66, 22.45, 0); // Магазин одежды
	CreatePickup(19135, 23, 1801.8662, -1304, 120, 0); // Работа в бизнес-центре
	CreatePickup(19135, 23, 1803.8063, -1304, 120, 0); // Работа в бизнес-центре
	CreatePickup(19135, 23, 1805.8135, -1304, 120, 0); // Работа в бизнес-центре
	Create3DTextLabel("[ALT]", COLOR_WHITE, 1786.7538, -1299.74, 13.137, 7, 0, 0); // Вход в бизнес-центр
	Create3DTextLabel("[ALT]", COLOR_WHITE, 1786.6896, -1299.72, 120.2656, 7, 0, 0); // Выход из бизнес-центра
	Create3DTextLabel("[ALT]\n$20\nВыпить газировку (пополняет HP)", COLOR_BLACK, 1126, -1483.27, 22.83, 10, 0, 0); // Автомат с газировкой
	Create3DTextLabel("[ALT]\n$30\nАренда велосипедов", COLOR_WHITE, 1768.30, -1905.56, 13.56, 10, 0, 0); // Аренда велосипедов
	Create3DTextLabel("[ALT]\n$10\nDesert Eagle\n7 патронов", COLOR_RED, 1111, -1484, 22.77, 10, 0, 0); // Deagle
	Create3DTextLabel("[ALT]\n$10\nM4\n50 патронов", COLOR_RED, 1108, -1484, 22.6, 10, 0, 0); // M4
	Create3DTextLabel("[ALT]\n$10\nShotgun\n5 патронов", COLOR_RED, 1105, -1484, 22.6, 10, 0, 0); // Shotgun
	Create3DTextLabel("[ALT]\n$10\nMP5\n30 патронов", COLOR_RED, 1102, -1484, 22.6, 10, 0, 0); // MP5
	Create3DTextLabel("[ALT]\n$10\nRifle\n5 патронов", COLOR_RED, 1099, -1484, 22.6, 10, 0, 0); // Rifle
	Create3DTextLabel("[ALT]\n$10\nБронежилет", COLOR_RED, 1096, -1484, 22.6, 10, 0, 0); // Бронежилет
	Create3DTextLabel("[ALT]\nЛотерея", COLOR_WHITE, 1122.5, -1486, 22.77, 10, 0, 0); // Лотерея
	Create3DTextLabel("[ALT]\nСтраховая компания", COLOR_WHITE, 1090.23, -1475.58, 22.74, 10, 0, 0); // Страховая компания
	Create3DTextLabel("[ALT]\nМагазин одежды", COLOR_WHITE, 1170.44, -1489.66, 22.75, 10, 0, 0); // Магазин одежды
}
stock LoadPlayerData(playerid)
{
	new query[256];
	format(query, sizeof(query), "SELECT * FROM `accounts` WHERE nickname = '%s'", Player[playerid][pNickname]);
	mysql_query(query);
	new result[512];
	mysql_store_result();
	mysql_fetch_row(result);
	mysql_free_result();
	sscanf(result, "p<|>e<is[32]s[32]iiiiiiiiiiiiiii>", Player[playerid]);
}
stock SavePlayer(playerid)
{
	new query[2048];
	format(query, sizeof(query), "UPDATE `accounts` SET exp = '%d', money = '%d', donate = '%d', donated = '%d', charity = '%d', withdraw = '%d', withdrawed = '%d', warn = '%d', skin = '%d', insurance = '%d', house = '%d', business1 = '%d', business2 = '%d', business3 = '%d', VIP = '%d' WHERE id = '%d'",
	Player[playerid][pEXP], Player[playerid][pMoney], Player[playerid][pDonate], Player[playerid][pDonated], Player[playerid][pCharity], Player[playerid][pWithdraw], Player[playerid][pWithdrawed], Player[playerid][pWarn], Player[playerid][pSkin], Player[playerid][pInsurance], Player[playerid][pHouse], Player[playerid][pBusiness1], Player[playerid][pBusiness2], Player[playerid][pBusiness3], Player[playerid][pVIP], Player[playerid][pID]);
	mysql_query(query);
	if(mysql_errno()) printf("[Ошибка] Не сохранен аккаунт %s(%d)", Player[playerid][pNickname], Player[playerid][pID]);
	else printf("[Успешно] Сохранен аккаунт %s(%d)", Player[playerid][pNickname], Player[playerid][pID]);
	return true;
}
stock LoadBusiness()
{
	new loaded = 0;
	for(new b = 1; b < MAX_BUSINESS; b++)
	{
	    new query[256], result[1024], string[512];
        format(query, sizeof(query), "SELECT * FROM `business` WHERE `id` = '%d'", b);
        mysql_query(query);
		mysql_store_result();
		mysql_fetch_row(result);
		sscanf(result, "p<|>e<is[64]iifffi>", Business[b]);
		mysql_free_result();
        if(Business[b][bOwner] == 0)
        {
            Business[b][bPick] = CreatePickup(19132, 23, Business[b][bX], Business[b][bY], Business[b][bZ], 0);
            format(string, sizeof(string), "{5CDF34}%s\n{80A6FF}Владелец: {FFFFFF}нет\n{80A6FF}Стоимость: {FFFFFF}$%d", Business[b][bName], Business[b][bPrice]);
            Business[b][bText] = Create3DTextLabel(string, COLOR_WHITE, Business[b][bX], Business[b][bY], Business[b][bZ] + 0.5, 10, 0, 0);
        }
        else
        {
            new nickname[MAX_PLAYER_NAME];
            GetPlayerNameByID(Business[b][bOwner], nickname);
            Business[b][bPick] = CreatePickup(19132, 23, Business[b][bX], Business[b][bY], Business[b][bZ], 0);
            format(string, sizeof(string), "{5CDF34}%s\n{80A6FF}Владелец: {FFFFFF}%s\n{80A6FF}Стоимость: {FFFFFF}$%d", Business[b][bName], nickname, Business[b][bPrice]);
            Business[b][bText] = Create3DTextLabel(string, COLOR_WHITE, Business[b][bX], Business[b][bY], Business[b][bZ]+0.5, 10, 0, 0);
        }
        loaded++;
	}
	printf("[Успешно] Загружено %d бизнесов", loaded);
}
stock UpdateBusiness(b)
{
    new string[256];
    if(Business[b][bOwner] == 0)
    {
        format(string, sizeof(string), "{5CDF34}%s\n{80A6FF}Владелец: {FFFFFF}нет\n{80A6FF}Стоимость: {FFFFFF}$%d", Business[b][bName], Business[b][bPrice]);
        Update3DTextLabelText(Business[b][bText], COLOR_WHITE, string);
    }
    else
    {
		new nickname[MAX_PLAYER_NAME];
		GetPlayerNameByID(Business[b][bOwner], nickname);
        format(string, sizeof(string), "{5CDF34}%s\n{80A6FF}Владелец: {FFFFFF}%s\n{80A6FF}Стоимость: {FFFFFF}$%d", Business[b][bName], nickname, Business[b][bPrice]);
        Update3DTextLabelText(Business[b][bText], COLOR_WHITE, string);
    }
}
stock SaveBusiness()
{
	new saved = 0;
	for(new b = 1; b < MAX_BUSINESS; b++)
	{
		new query[512];
		format(query, sizeof(query), "UPDATE `business` SET ownerid = %d, balance = %d WHERE id = %d", Business[b][bOwner], Business[b][bBalance], b);
		mysql_query(query);
        if(mysql_errno()) printf("[Ошибка] Не сохранен бизнес %d", b);
		saved++;
	}
	printf("[Успешно] Сохранено %d бизнесов", saved);
	return true;
}
stock LoadTreasury()
{
	mysql_query("SELECT `treasury` FROM `serverdata`");
	mysql_store_result();
	new result[18];
	mysql_fetch_row(result);
	kazna = strval(result);
	mysql_free_result();
	printf("[Успешно] Казна загружена ($%d)", kazna);
}
stock SaveTreasury()
{
	new query[128];
	format(query, sizeof(query), "UPDATE `serverdata` SET `treasury` = %d", kazna);
	mysql_query(query);
	printf("[Успешно] Казна сохранена ($%d)", kazna);
}
stock PayDay()
{	
	new h, m, s;
	gettime(h, m, s);
	SetWorldTime(h);
	for(new i; i < MAX_PLAYERS; i++)
	{
		if(!IsPlayerConnected(i) || !Player[i][pID]) continue;
		SCM(i, COLOR_WHITE, "========== [Банковский чек] =========");
		if(Player[i][pMoney] >= 10)
		{
			SCM(i, COLOR_WHITE, "Налог: $10");
			transaction(i, -10);
			kazna += 10;
		}
		else SCM(i, COLOR_WHITE, "У вас недостаточно денег для оплаты налога, поэтому вы платите меньше!");
		SCM(i, COLOR_WHITE, "=====================================");
		Player[i][pEXP]++;
		SetPlayerScore(i, Player[i][pEXP]);
		GameTextForPlayer(i, "~y~PayDay", 5000, 1);
	}
	return true;
}
stock AdminChat(color,mes[])
{
	for(new i; i < MAX_PLAYERS; i++)
	{
		if(!IsPlayerConnected(i) || !alogin[i]) continue;
		SCM(i, color, mes);
	}
}
stock GetPlayerNameByID(id, nickname[])
{
	new query[128];
	format(query, sizeof(query), "SELECT `nickname` FROM `accounts` WHERE `id` = '%d'", id);
	mysql_query(query);
	mysql_store_result();
	if(mysql_num_rows() <= 0) strcat(nickname, "Неизвестно (ошибка)", 24);
	else mysql_fetch_row(nickname);
	mysql_free_result();
}
stock AntiMoney()
{
	for(new i = 0; i < MAX_PLAYERS; i++)
	{
		if(IsPlayerConnected(i))
		{
			if(Player[i][pMoney] != GetPlayerMoney(i))
			{
				ResetPlayerMoney(i);
				GivePlayerMoney(i, Player[i][pMoney]);
			}
		}
	}
}
/*stock SetPlayerSpawn(playerid)
{
	if(spawn[playerid] == true)
	{
	    SetPlayerPos(playerid, 1178.1919,-1323.1329,14.1079);
		spawn[playerid] = false;
		SetPlayerSkin(playerid, Player[playerid][pSkin]);
		SetPlayerScore(playerid, Player[playerid][pEXP]);
		ResetPlayerMoney(playerid);
		GivePlayerMoney(playerid, Player[playerid][pMoney]);
	}
	else
	{
	    SetPlayerPos(playerid, 1763, -1897, 14);
		SetPlayerSkin(playerid, Player[playerid][pSkin]);
		SetPlayerScore(playerid, Player[playerid][pEXP]);
		ResetPlayerMoney(playerid);
		GivePlayerMoney(playerid, Player[playerid][pMoney]);
		SetPlayerColor(playerid, 0xFFFFFF80);
	}
	return true;
}*/
stock Money(playerid)
{
	return Player[playerid][pMoney];
}
stock ProxDetector(Float:radi, playerid, string[],col1,col2,col3,col4,col5)
{
	new Float:posx, Float:posy, Float:posz, Float:oldposx, Float:oldposy, Float:oldposz, Float:tempposx, Float:tempposy, Float:tempposz;
	GetPlayerPos(playerid, oldposx, oldposy, oldposz);
	for(new i = 0; i < MAX_PLAYERS; i++)
	{
		if(GetPlayerVirtualWorld(playerid) == GetPlayerVirtualWorld(i))
		{
			GetPlayerPos(i, posx, posy, posz);
			tempposx = oldposx-posx;
			tempposy = oldposy-posy;
			tempposz = oldposz-posz;
			if (((tempposx < radi/16) && (tempposx > -radi/16)) && ((tempposy < radi/16) && (tempposy > -radi/16)) && ((tempposz < radi/16) && (tempposz > -radi/16))) SCM(i, col1, string);
			else if (((tempposx < radi/8) && (tempposx > -radi/8)) && ((tempposy < radi/8) && (tempposy > -radi/8)) && ((tempposz < radi/8) && (tempposz > -radi/8))) SCM(i, col2, string);
			else if (((tempposx < radi/4) && (tempposx > -radi/4)) && ((tempposy < radi/4) && (tempposy > -radi/4)) && ((tempposz < radi/4) && (tempposz > -radi/4))) SCM(i, col3, string);
			else if (((tempposx < radi/2) && (tempposx > -radi/2)) && ((tempposy < radi/2) && (tempposy > -radi/2)) && ((tempposz < radi/2) && (tempposz > -radi/2))) SCM(i, col4, string);
			else if (((tempposx < radi) && (tempposx > -radi)) && ((tempposy < radi) && (tempposy > -radi)) && ((tempposz < radi) && (tempposz > -radi))) SCM(i, col5, string);
		}
	}
}
stock ShowStats(playerid, gplayerid)
{
	new string[256];
	format(string, sizeof(string),
	"Очки опыта\t%d\n\
	Предупреждения\t%d/10\n\
	Деньги\t$%d\n\
	Донат\t%d рублей\n\
	Задоначено\t%d рублей\n\
	Благотворительность\t$%d\n\
	Счет для вывода\t%d рублей\n\
	Выведено\t%d рублей\n\
	Страховка\t%d страховых купонов\n",
	Player[gplayerid][pEXP], Player[gplayerid][pWarn], Player[gplayerid][pMoney], Player[gplayerid][pDonate], Player[playerid][pDonated], Player[playerid][pCharity], Player[gplayerid][pWithdraw], Player[gplayerid][pWithdrawed], Player[gplayerid][pInsurance]);
	SPD(playerid, dEmptyResult, DST, GN(gplayerid), string, "OK", "");
}
stock transaction(pid, amount)
{
	GivePlayerMoney(pid, amount);
	Player[pid][pMoney] += amount;
	return true;
}
stock err(plid, message[])
{
	new string[144];
	format(string, sizeof(string), "{FF0000}• {FFFFFF}%s", message);
	SCM(plid, COLOR_WHITE, string);
	return true;
}
stock suc(plid, message[])
{
	new string[144];
	format(string, sizeof(string), "{00FF00}• {FFFFFF}%s", message);
	SCM(plid, COLOR_WHITE, string);
}
stock inf(plid, message[])
{
	new string[144];
	format(string, sizeof(string), "{269BD8}• {FFFFFF}%s", message);
	SCM(plid, COLOR_WHITE, string);
	return true;
}


// КОМАНДЫ
// ADMIN
CMD:ahelp(playerid)
{
	if(!login[playerid] || !alogin[playerid]) return true;
	SCM(playerid, COLOR_ORANGE, "/al /ahelp /a /amn /admins /ans /money /gethere /goto /givegun /takegun");
	SCM(playerid, COLOR_ORANGE, "/kick /warn /ban /hp /fixcar /skin /msg /slap /car /getbdata /getstats");
	SCM(playerid, COLOR_ORANGE, "/delcar /tow /untow /setweather /settime /debug");
	return true;
}
CMD:al(playerid)
{
    if(!login[playerid]) return true;
	alogin[playerid] = true;
	return true;
}
CMD:a(playerid, params[], string[144])
{
    if(!login[playerid] || !alogin[playerid]) return true;
    if(sscanf(params, "s[128]", params[0])) return inf(playerid, "/a [текст]");
 	format(string, sizeof(string), "[A] %s[%d]: %s", GN(playerid), playerid, params[0]);
	AdminChat(COLOR_INFO, string);
	return true;
}
CMD:ans(playerid, params[], string[144])
{
	if(!login[playerid] || !alogin[playerid]) return true;
	if(sscanf(params, "is[128]", params[0], params[1])) return inf(playerid, "/ans [ID] [Ответ]");
	if(!IsPlayerConnected(params[0])) return err(playerid, "Неверный ID!");
	format(string, sizeof(string), "Администратор %s ответил игроку %s[%d]: %s", Player[playerid][pNickname], GN(params[0]), params[0], params[1]);
	SCM(params[0], COLOR_OTVET, string);
	format(string, sizeof(string), "[A] Администратор %s ответил игроку %s[%d]: %s", GN(playerid), GN(params[0]), params[0], params[1]);
	AdminChat(COLOR_OTVET, string);
	return true;
}
CMD:admins(playerid, string[40])
{
	if(!login[playerid] || !alogin[playerid]) return true;
	SCM(playerid, COLOR_INFO, "Администраторы онлайн:");
	for(new i; i < MAX_PLAYERS; i++)
	{
		if(!IsPlayerConnected(i) || !alogin[i]) continue;
		format(string, sizeof(string), "%s[%d]", Player[i][pNickname], i);
		SCM(playerid, COLOR_SYSTEM, string);
	}
	return true;
}
CMD:money(playerid, params[])
{
    if(!login[playerid] || !alogin[playerid]) return true;
    if(sscanf(params, "ii", params[0], params[1])) return inf(playerid, "/givemoney [ID игрока] [К-во денег]");
	if(!IsPlayerConnected(params[0])) return err(playerid, "Неверный ID игрока");
	if(params[1] < -1000000 || params[1] > 1000000) return err(playerid, "Неверная сумма");
	transaction(params[0], params[1]);
	new string[128];
	format(string, sizeof(string), "[A] Администратор %s выдал игроку %s[%d] $%d", GN(playerid), GN(params[0]), params[0], params[1]);
	AdminChat(COLOR_INFO, string);
	format(string, sizeof(string), "Администратор %s выдал вам $%d", GN(playerid), params[1]);
	SCM(playerid, COLOR_ORANGE, string);
	return true;
}
CMD:gethere(playerid, params[], string[144])
{
	if(!login[playerid] || !alogin[playerid]) return true;
	if(sscanf(params, "d", params[0])) return inf(playerid, "/gethere [ID]");
	if(!IsPlayerConnected(params[0]) || params[0] == playerid) return err(playerid, "Неверный ID!");
	new carid = GetPlayerVehicleID(params[0]), world = GetPlayerVirtualWorld(playerid), inter = GetPlayerInterior(playerid), Float:tpx, Float:tpy, Float:tpz;
	GetPlayerPos(playerid, tpx, tpy, tpz);
	if(GetPlayerState(params[0]) == 2) return SetVehiclePos(carid, tpx, tpy+4, tpz), SetVehicleVirtualWorld(carid, world);
	else SetPlayerPos(params[0], tpx, tpy+2, tpz), SetPlayerVirtualWorld(params[0], world), SetPlayerInterior(params[0], inter);
	format(string, sizeof(string), "[A] Администратор %s телепортировал к себе игрока %s[%d]", GN(playerid), GN(params[0]), params[0]);
	AdminChat(COLOR_INFO, string);
	format(string, sizeof(string), "Администратор %s телепортировал Вас к себе", GN(playerid));
	SCM(playerid, COLOR_WHITE, string);
	return true;
}
CMD:goto(playerid, params[], string[144])
{
    if(!login[playerid] || !alogin[playerid]) return true;
    if(sscanf(params, "d", params[0])) return inf(playerid, "/goto [ID]");
    if(!IsPlayerConnected(params[0]) || params[0] == playerid) return err(playerid, "Неверный ID!");
	new carid = GetPlayerVehicleID(playerid), world = GetPlayerVirtualWorld(params[0]), inter = GetPlayerInterior(params[0]), Float:tpx, Float:tpy, Float:tpz;
	GetPlayerPos(params[0], tpx, tpy, tpz);
	if(GetPlayerState(playerid) == 2) return SetVehiclePos(carid, tpx, tpy+4, tpz), SetVehicleVirtualWorld(carid, world);
	else SetPlayerPos(playerid, tpx, tpy+2, tpz), SetPlayerVirtualWorld(playerid, world), SetPlayerInterior(playerid, inter);
	format(string, sizeof(string), "[A] Администратор %s телепортировался к игроку %s[%d]", GN(playerid), GN(params[0]), params[0]);
	AdminChat(COLOR_INFO, string);
	format(string, sizeof(string), "Вы телепортировались к игроку %s[%d]", GN(params[0]), params[0]);
	SCM(playerid, COLOR_WHITE, string);
	return true;
}
CMD:getstats(playerid, params[])
{
    if(!login[playerid] || !alogin[playerid]) return true;
    if(sscanf(params, "d", params[0])) return inf(playerid, "/getstats [ID]");
    if(!IsPlayerConnected(params[0])) return err(playerid, "Неверный ID!");
    ShowStats(playerid, params[0]);
	return true;
}
CMD:takegun(playerid, params[], string[144])
{
    if(!login[playerid] || !alogin[playerid]) return true;
    if(sscanf(params, "d", params[0])) return inf(playerid, "/takegun [ID]");
    if(!IsPlayerConnected(params[0])) return err(playerid, "Неверный ID!");
    ResetPlayerWeapons(params[0]);
	format(string, sizeof(string), "[A] Администратор %s забрал оружие у игрока %s[%d]", GN(playerid), GN(params[0]), params[0]);
	AdminChat(COLOR_INFO, string);
	format(string, sizeof(string), "Администратор %s забрал у вас оружие", GN(playerid));
	SCM(params[0], COLOR_YELLOW, string);
	return true;
}
CMD:kick(playerid, params[], string[144])
{
    if(!login[playerid] || !alogin[playerid]) return true;
    if(sscanf(params, "ds[64]", params[0], params[1])) return inf(playerid, "/kick [ID] [Причина]");
    if(!IsPlayerConnected(params[0])) return err(playerid, "Неверный ID!");
    format(string, sizeof(string), "Администратор %s кикнул игрока %s. Причина: %s", GN(playerid), GN(params[0]), params[1]);
	SCMTA(COLOR_LRED, string);
	KickPlayer(playerid, 50);
	return true;
}
CMD:warn(playerid, params[], string[144])
{
    if(!login[playerid] || !alogin[playerid]) return true;
    if(sscanf(params, "ds[64]", params[0], params[1])) return inf(playerid, "/warn [ID] [Причина]");
    if(!IsPlayerConnected(params[0])) return err(playerid, "Неверный ID!");
    Player[params[0]][pWarn] += 1;
	format(string, sizeof(string), "Администратор %s выдал предупреждение игроку %s[%d/10]. Причина: %s", GN(playerid), GN(params[0]), Player[params[0]][pWarn], params[1]);
	SCMTA(COLOR_LRED, string);
	if(Player[params[0]][pWarn] < 10) return true;
	format(string, sizeof(string), "Игрок %s получил бан за 10 предупреждений", GN(params[0]));
	SCMTA(COLOR_LRED, string);
    return true;
}
CMD:ban(playerid, params[], string[144])
{
	if(!login[playerid] || !alogin[playerid]) return true;
	if(sscanf(params, "ds[64]", params[0], params[1])) return inf(playerid, "/ban [ID] [Причина]");
	if(!IsPlayerConnected(params[0])) return err(playerid, "Неверный ID!");
	Player[params[0]][pWarn] = 10;
	format(string, sizeof(string), "Администратор %s забанил игрока %s. Причина: %s", GN(playerid), GN(params[0]), params[1]);
	SCMTA(COLOR_LRED, string);
	KickPlayer(playerid, 50);
	return true;
}
CMD:fixcar(playerid, params[], string[144])
{
    if(!login[playerid] || !alogin[playerid]) return true;
    if(sscanf(params, "d", params[0])) return inf(playerid, "/fixcar [ID]");
    if(!IsPlayerConnected(params[0])) return err(playerid, "Неверный ID!");
    SetVehicleHealth(GetPlayerVehicleID(params[0]), 1000);
	RepairVehicle(GetPlayerVehicleID(params[0]));
	format(string, sizeof(string), "[A] Администратор %s отремонтировал т/с игроку %s[%d]", GN(playerid), GN(params[0]), params[0]);
	AdminChat(COLOR_INFO, string);
	format(string, sizeof(string), "Администратор %s починил ваше т/с", GN(playerid));
	SCM(playerid, COLOR_WHITE, string);
	return true;
}
CMD:amn(playerid)
{
	if(!login[playerid] || !alogin[playerid]) return true;
	SPD(playerid, dAdminMenu, DSL, "Админ-меню", "[1] Телепорт\n[2] PayDay\n[3] Рестарт сервера", "Далее", "Выход");
	return true;
}
CMD:hp(playerid, params[], string[144])
{
	if(!login[playerid] || !alogin[playerid]) return true;
	if(sscanf(params, "ii", params[0], params[1])) return inf(playerid, "/hp [ID] [HP]");
	if(!IsPlayerConnected(params[0])) return err(playerid, "Неверный ID!");
	SetPlayerHealth(params[0], params[1]);
	format(string, sizeof(string), "[A] Администратор %s выдал %d HP игроку %s[%d]", GN(playerid), params[1], GN(params[0]), params[0]);
	AdminChat(COLOR_INFO, string);
	format(string, sizeof(string), "Администратор %s выдал вам %d HP", GN(playerid), params[1]);
	SCM(playerid, COLOR_WHITE, string);
	return true;
}
CMD:skin(playerid, params[], string[144])
{
	if(!login[playerid] || !alogin[playerid]) return true;
	if(sscanf(params, "ii", params[0], params[1])) return inf(playerid, "/skin [ID] [ID скина]");
	if(!IsPlayerConnected(params[0])) return err(playerid, "Неверный ID!");
 	if(params[2] < 0 || params[2] > 311) return err(playerid, "ID скина: 0-311");
   	SetPlayerSkin(params[0], params[1]);
   	format(string, sizeof(string), "[A] Администратор %s выдал игроку %s[%d] временный скин %d", GN(playerid), GN(params[0]), params[0], params[1]);
	AdminChat(COLOR_INFO, string);
	format(string, sizeof(string), "Администратор %s выдал вам временный скин %d", GN(playerid), params[1]);
	SCM(playerid, COLOR_WHITE, string);
	return true;
}
CMD:msg(playerid, params[], string[144])
{
	if(!login[playerid] || !alogin[playerid]) return true;
	if(sscanf(params, "s[128]", params[0])) return inf(playerid, "/msg [текст]");
	format(string, sizeof(string), "Администратор %s: %s", GN(playerid), params[0]);
	SCMTA(COLOR_YELLOW, string);
	return true;
}
CMD:givegun(playerid, params[], string[144])
{
    if(!login[playerid] || !alogin[playerid]) return true;
	if(sscanf(params, "iii", params[0], params[1], params[2])) return inf(playerid, "/givegun [ID] [ID оружия] [Патроны]");
	if(!IsPlayerConnected(params[0])) return err(playerid, "Неверный ID!");
	if(params[1] < 0 || params[1] > 46) return err(playerid, "ID оружия: 0-46!");
	if(params[2] < 1 || params[2] > 1000) return err(playerid, "Патроны: 1-1000");
	GivePlayerWeapon(params[0], params[1], params[2]);
	format(string, sizeof(string), "[A] Администратор %s выдал оружие игроку %s[%d]", GN(playerid), GN(params[0]), params[0]);
	AdminChat(COLOR_INFO, string);
	format(string, sizeof(string), "Администратор %s выдал вам оружие", GN(playerid));
	SCM(playerid, COLOR_WHITE, string);
	return true;
}
CMD:slap(playerid, params[], string[144])
{
	if(!login[playerid] || !alogin[playerid]) return true;
    if(sscanf(params, "ii", params[0], params[1])) return inf(playerid, "/slap [ID] [Высота]");
    if(!IsPlayerConnected(params[0])) return err(playerid, "Неверный ID!");
    new Float:x, Float:y, Float:z;
    GetPlayerPos(params[0], x, y, z);
    SetPlayerPos(params[0], x, y, z+params[1]);
	format(string, sizeof(string), "[A] Администратор %s слапнул игрока %s[%d] на высоту %d", GN(playerid), GN(params[0]), params[0], params[1]);
    AdminChat(COLOR_INFO, string);
    return true;
}
CMD:car(playerid, params[])
{
    if(!login[playerid] || !alogin[playerid]) return true;
    if(sscanf(params, "iii", params[0], params[1], params[2])) return inf(playerid, "/car [ID т/с] [Цвет 1] [Цвет 2]");
    if(params[0] < 400 || params[0] > 611) return err(playerid, "ID авто: 400-611");
    if(params[1] < 0 || params[1] > 255) return err(playerid, "Цвет 1: 0-255");
    if(params[1] < 0 || params[2] > 255) return err(playerid, "Цвет 2: 0-255");
    new Float:pos_x_veh, Float:pos_y_veh, Float:pos_z_veh, Float:rot_veh;
    GetPlayerPos(playerid, pos_x_veh, pos_y_veh, pos_z_veh), GetPlayerFacingAngle(playerid, rot_veh);
    created_veh[playerid] = AddStaticVehicleEx(params[0], pos_x_veh, pos_y_veh, pos_z_veh, rot_veh, params[1], params[2], -1);
    PutPlayerInVehicle(playerid, created_veh[playerid], 0);
	SCM(playerid, COLOR_WHITE, "Вы создали т/с");
    return true;
}
CMD:delcar(playerid)
{
	if(!login[playerid] || !alogin[playerid]) return true;
	DestroyVehicle(GetPlayerVehicleID(playerid));
	SCM(playerid, COLOR_YELLOW, "Вы удалили т/с");
	return true;
}
CMD:debug(playerid, params[])
{
    if(!login[playerid] || !alogin[playerid]) return true;
    if(sscanf(params, "d", params[0])) return inf(playerid, "/debug [ID]");
    if(!IsPlayerConnected(params[0])) return err(playerid, "Неверный ID!");
    TogglePlayerControllable(params[0], 0);
	TogglePlayerControllable(params[0], 1);
	return true;
}
CMD:getbdata(playerid, params[], string[256])
{
	if(!login[playerid] || !alogin[playerid]) return true;
	if(sscanf(params, "d", params[0])) return inf(playerid, "/getdata [ID бизнеса]");
	format(string, sizeof(string), "[%d]%s | ownerid: %d | balance: %d", Business[params[0]][bID], Business[params[0]][bName], Business[params[0]][bOwner], Business[params[0]][bBalance]);
	SCM(playerid, COLOR_WHITE, string);
	return true;
}
CMD:tow(playerid, params[])
{
	if(!login[playerid] || !alogin[playerid]) return true;
	new vehplid = GetPlayerVehicleID(playerid);
	new Float:plAngle, Float:crAngle, Float:Angle, Float:Angle2;
	GetVehicleZAngle(vehplid, plAngle);
	if(GetVehicleModel(vehplid) != 525) return err(playerid, "Вы не в эвакуаторе!");
	new Float:posx, Float:posy, Float:posz, Float:oldposx, Float:oldposy, Float:oldposz;
	new Float:tempposx, Float:tempposy, Float:tempposz, Float:Radi = 6.0, Float:AngRange = 90.0;
	for(new i = 0; i < MAX_VEHICLES; i++)
	{
		if(i == vehplid) continue;
		GetVehiclePos(vehplid, posx, posy, posz);
		GetVehiclePos(i, oldposx, oldposy, oldposz);
		tempposx = (oldposx - posx);
		tempposy = (oldposy - posy);
		tempposz = (oldposz - posz);
		if(((tempposx < Radi) && (tempposx > -Radi)) && ((tempposy < Radi) && (tempposy > -Radi)) && ((tempposz < Radi) && (tempposz > -Radi)))
		{
			GetVehicleZAngle(i, crAngle);
			Angle = (plAngle - crAngle);
			Angle2 = (Angle - 180.0);
			if(((Angle < AngRange) && (Angle > -AngRange)) || ((Angle2 < AngRange) && (Angle2 > -AngRange)))
			{
				AttachTrailerToVehicle(i, vehplid);
				return true;
			}
		}
	}
	err(playerid, "Рядом нет машин!");
	return true;
}
CMD:untow(playerid)
{
    if(!login[playerid] || !alogin[playerid]) return true;
	DetachTrailerFromVehicle(GetPlayerVehicleID(playerid));
	suc(playerid, "Вы отцепили т/с!");
	return true;
}
CMD:setweather(playerid, params[])
{
	if(!login[playerid] || !alogin[playerid]) return true;
	if(sscanf(params, "d", params[0]) || params[0] < 0 || params[0] > 20) return inf(playerid, "/setweather [0-20]");
	SetWeather(params[0]);
	return true;
}
CMD:settime(playerid, params[])
{
	if(!login[playerid] || !alogin[playerid]) return true;
	if(sscanf(params, "d", params[0]) || params[0] < 0 || params[0] > 23) return inf(playerid, "/settime [0-23]");
	SetWorldTime(params[0]);
	return true;
}



// USER
CMD:pay(playerid, params[], string[144])
{
	if(!login[playerid]) return true;
	if(sscanf(params, "ii", params[0], params[1])) return inf(playerid, "/pay [ID игрока] [сумма]");
	if(!IsPlayerConnected(params[0]) || playerid == params[0]) return err(playerid, "Неверный ID!");
	if(GetPlayerDistanceToPlayer(playerid, params[0]) > 3.0 || GetPlayerVirtualWorld(playerid) != GetPlayerVirtualWorld(params[0])) return err(playerid,  "Вы далеко друг от друга");
	if(params[1] < 1 || params[1] > 5000) return err(playerid, "Можно передавать от 1 до 5000$");
	if(Player[playerid][pMoney] < params[1]) return err(playerid, "У Вас недостаточно денег");
	transaction(playerid, -params[1]);
	transaction(params[0], params[1]);
	format(string, sizeof(string), "%s передал Вам $%d", Player[playerid][pNickname], params[1]);
	SCM(params[0], COLOR_INFO, string);
	format(string, sizeof(string), "Вы передали %s $%d", Player[params[0]][pNickname], params[1]);
	SCM(playerid, COLOR_INFO, string);
	return true;
}
CMD:time(playerid)
{
	if(!login[playerid]) return true;
	new h, m, s, mes[24];
	gettime(h, m, s);
	if(m < 10) format(mes, sizeof(mes), "%d:0%d", h, m);
	else format(mes, sizeof(mes),"%d:%d", h, m);
	GameTextForPlayer(playerid, mes, 5000, 1);
	ApplyAnimation(playerid, "COP_AMBIENT", "Coplook_watch", 4.1, 0, 0, 0, 0, 2000, 1);
	return true;
}
CMD:id(playerid, params[])
{
    if(!login[playerid]) return true;
	if(sscanf(params, "s[64]", params[0])) return inf(playerid, "/id [Ник игрока]");
	new id = -1, name[24];
	if(!isNumeric(params[0]))
	{
		for(new i; i < MAX_PLAYERS; i++)
		{
			if(!IsPlayerConnected(i)) continue;
			GetPlayerName(i, name, 24);
			if(strfind(name, params[0], true) != -1) {id = i; break;}
		}
		if(id == -1) return SCM(playerid, COLOR_GRAY, "Не найдено");
	}
	else
	{
		id = strval(params[0]);
		if(!IsPlayerConnected(id)) return err(playerid, "Неверный ID!");
		GetPlayerName(id, name, 24);
	}
	new mes[128];
	format(mes, sizeof(mes), "%s [%d]", name, id);
	SCM(playerid, COLOR_WHITE, mes);
	return true;
}
CMD:eject(playerid, params[])
{
    if(!login[playerid]) return true;
    if(!IsPlayerInAnyVehicle(playerid)) return err(playerid, "Вы должны быть в т.с.");
	if(GetPlayerVehicleSeat(playerid) != 0) return err(playerid, "Вы должны быть за рулем");
	if(sscanf(params, "i", params[0])) return inf(playerid, "/eject [ID]");
	if(!IsPlayerConnected(params[0]) || params[0] == playerid) return err(playerid, "Неверный ID!");
	new vehicleid = GetPlayerVehicleID(playerid);
	if(vehicleid == GetPlayerVehicleID(params[0]) && GetPlayerVehicleSeat(params[0]) != 0)
	{
		SCM(params[0], COLOR_GRAY, "Водитель вытолкнул вас из т.с.");
		RemovePlayerFromVehicle(params[0]);
	}
	return true;
}

// Персонаж
CMD:help(playerid)
{
    if(!login[playerid]) return true;
	SCM(playerid, COLOR_ORANGE, "/help /rep /sms /vip /pay /time /id /eject /stats /donate");
	SCM(playerid, COLOR_ORANGE, "/wd /withdraw /wdhistory /ad /charity /unrent /taxi");
	SCM(playerid, COLOR_ORANGE, "/business /buybusiness /econ /info");
	return true;
}
CMD:stats(playerid)
{
    if(!login[playerid]) return true;
	ShowStats(playerid, playerid);
	return true;
}
CMD:donate(playerid, string[256])
{
    if(!login[playerid]) return true;
	format(string, sizeof(string), "Услуга\tЦена\tЦена для VIP\nИгровая валюта\t1 руб = $900\t1 руб = $950\nСнять варн\t$2500\t$2000\nКупить VIP\t{1CE0D9}20 рублей\nКупить EXP\t$700\t$750\n \nВаш баланс\t{1CE0D9}%d рублей", Player[playerid][pDonate]);
	SPD(playerid, dDonate, DSTH, "Донат", string, "Далее", "Выход");
	return true;
}
CMD:withdraw(playerid, params[], string[144])
{
    if(!login[playerid]) return true;
	if(Player[playerid][pVIP] == 0) return err(playerid, "Вывод денег доступен только VIP-игрокам!");
	if(Player[playerid][pWarn] != 0) return err(playerid, "Вывод денег доступен только игрокам без предупреждений!");
	if(sscanf(params, "ds[128]", params[0], params[1])) return inf(playerid, "/withdraw [сумма] [кошелек]");
	if(params[0] < 50 || params[0] > 1000000) return err(playerid, "Выводить можно от 50 до 1.000.000 рублей!");
	if(Player[playerid][pWithdraw] < params[0]) return err(playerid, "У вас недостаточно рублей для вывода!");
	if(Player[playerid][pEXP] < params[0]) return err(playerid, "У вас недостаточно EXP для вывода!");
	if(Player[playerid][pDonated] < (Player[playerid][pWithdrawed] + params[0])/2) return format(string, sizeof(string), "Вам необходимо задонатить еще {1CE0D9}%d рублей{FFFFFF}, чтобы вывести такую сумму", -(Player[playerid][pDonated] - (Player[playerid][pWithdrawed] + params[0])/2)), SCM(playerid, COLOR_WHITE, string);
	new query[256];
	format(query, sizeof(query), "INSERT INTO `withdraw` (requester, amount, wallet) VALUES ('%d', '%d', '%s')", Player[playerid][pID], params[0], params[1]);
	mysql_query(query);
	format(string, sizeof(string), "Вы оставили заявку на вывод (%d рублей на %s)", params[0], params[1]);
	suc(playerid, string);
	inf(playerid, "Для редактирования или отмены заявки обращайтесь к администрации");
	return true;
}
CMD:wdhistory(playerid)
{
	new query[256];
 	format(query, sizeof(query), "SELECT * FROM `withdraw` WHERE requester = '%d'", Player[playerid][pID]);
	mysql_query(query);
	mysql_store_result();
	if(mysql_num_rows() > 0)
	{
	    new string[2048], str[128], var[32], id, amount, wallet[32], status, status_text[32];
		format(str, sizeof(str), "ID выплаты\tСумма\tКошелек\tСтатус");
		strcat(string, str);
		for(new i = 0; i < mysql_num_rows(); i++)
		{
			if(mysql_fetch_row_format(query))
			{
				mysql_get_field("id", var);
				id = strval(var);
				mysql_get_field("amount", var);
				amount = strval(var);
				mysql_get_field("wallet", var);
				wallet = var;
				mysql_get_field("status", var);
				status = strval(var);
				switch(status)
				{
				    case 0: status_text = "{FFFF00}Ожидание";
				    case 1: status_text = "{FF0000}Отказано";
				    case 2: status_text = "{1CE0D9}Одобрено";
				    case 3: status_text = "{00FF00}Выплачено";
				    default: status_text = "{FF0000}Ошибка";
				}
				format(str, sizeof(str), "\n{FFFFFF}%d\t{1CE0D9}%d рублей\t{FFFFFF}%s\t%s", id, amount, wallet, status_text);
				strcat(string, str);
			}
		}
  		SPD(playerid, dEmptyResult, DSTH, "История выплат", string, "ОК", "");
	}
	else SPD(playerid, dEmptyResult, DSM, "История выплат", "У вас пустая история выплат", "ОК", "");
	mysql_free_result();
	return true;
}
CMD:wd(playerid, params[], string[144])
{
    if(!login[playerid]) return true;
	inf(playerid, "При переводе от 10 рублей вы получите бонус 20 процентов к сумме!");
	if(sscanf(params, "d", params[0])) return err(playerid, "/wd [Сумма]");
	if(params[0] < 1 || params[0] > 1000000) return err(playerid, "Перевести можно от 1 до 1.000.000 рублей!");
	if(params[0] > Player[playerid][pWithdraw]) return err(playerid, "У вас недостаточно денег на счету для вывода!");
	Player[playerid][pWithdraw] -= params[0];
	if(params[0] > 10)
	{
        Player[playerid][pDonate] += params[0]*6/5;
		format(string, sizeof(string), "Вы получили {269BD8}%d рублей на донат-счет!", params[0]*6/5);
	}
	else
	{
		Player[playerid][pDonate] += params[0];
		format(string, sizeof(string), "Вы получили {269BD8}%d рублей на донат-счет!", params[0]);
	}
	suc(playerid, string);
	return true;
}
CMD:vip(playerid)
{
    if(!login[playerid]) return true;
	if(Player[playerid][pVIP] == 0) return err(playerid, "У вас нет VIP-статуса!");
	SPD(playerid, dVIP, DSTH, "VIP", "Услуга\tЦена\nВылечиться\t$10\nПочинить т/c\t$10", "Далее", "Выход");
	return true;
}

// Взаимодействие
CMD:rep(playerid, params[], string[144])
{
    if(!login[playerid]) return true;
	if(sscanf(params, "s[128]", params[0])) return inf(playerid, "/rep [текст]");
 	format(string, sizeof(string), "[A] %s[%d]: %s", GN(playerid), playerid, params[0], string);
	AdminChat(COLOR_OTVET, string);
	format(string, sizeof(string), "%s[%d]: %s", GN(playerid), playerid, params[0]);
	SCM(playerid, COLOR_OTVET, string);
	return true;
}
CMD:sms(playerid, params[], string[144])
{
    if(!login[playerid]) return true;
	if(sscanf(params, "is[128]", params[0], params[1])) return inf(playerid, "/sms [ID] [Текст]");
	if(!IsPlayerConnected(params[0])) return err(playerid, "Неверный ID!");
	format(string, sizeof(string), "SMS: %s. Получатель: %s[%d]", params[1], GN(params[0]), params[0]);
	SCM(playerid, COLOR_YELLOW, string);
	format(string, sizeof(string), "SMS: %s. Отправитель: %s[%d]", params[1], GN(playerid), params[0]);
	SCM(params[0], COLOR_YELLOW, string);
	return true;
}
CMD:ad(playerid, params[], string[144])
{
    if(!login[playerid]) return true;
	if(sscanf(params, "s[128]", params[0])) return inf(playerid, "/ad [текст]");
	if(Player[playerid][pMoney] < 100) return err(playerid, "У вас недостаточно денег!");
	transaction(playerid, -100);
	kazna += 100;
	format(string, sizeof(string), "{00FF00}[Реклама] %s. Отправитель: %s[%d]", params[0], GN(playerid), playerid, string);
	SCMTA(COLOR_WHITE, string);
	return true;
}
CMD:charity(playerid, params[], string[144])
{
    if(!login[playerid]) return true;
	if(sscanf(params, "d", params[0])) return inf(playerid, "/charity [Сумма]");
	if(Player[playerid][pMoney] < params[0]) return err(playerid, "У вас недостаточно денег!");
	transaction(playerid, -params[0]);
	kazna += params[0];
	Player[playerid][pCharity] += params[0];
	if(params[0] > 1999)
	{
	    Player[playerid][pWithdraw] += floatround(params[0]/2000, floatround_floor);
	    format(string, sizeof(string), "Вы получили %d рублей на счет для вывода за большое пожертвование, спасибо!", floatround(params[0]/2000, floatround_floor));
	    SCM(playerid, COLOR_GREEN, string);
	}
  	else SCM(playerid, COLOR_GREEN, "Спасибо за пожертвование!");
	return true;
}


// Бизнес
CMD:business(playerid, string[144])
{
    if(!login[playerid]) return true;
	if(Player[playerid][pBusiness1] == 0) return err(playerid, "У вас нет бизнесов!");
	if(Player[playerid][pBusiness2] == 0) format(string, sizeof(string), "%s", Business[Player[playerid][pBusiness1]][bName]);
	if(Player[playerid][pBusiness3] == 0) format(string, sizeof(string), "%s\n%s", Business[Player[playerid][pBusiness1]][bName], Business[Player[playerid][pBusiness2]][bName]);
	if(Player[playerid][pBusiness3] != 0) format(string, sizeof(string), "%s\n%s\n%s", Business[Player[playerid][pBusiness1]][bName], Business[Player[playerid][pBusiness2]][bName], Business[Player[playerid][pBusiness3]][bName]);
	SPD(playerid, dBusinessMenu, DSL, "Бизнесы", string, "Далее", "Выход");
	return true;
}
CMD:buybusiness(playerid)
{
    if(!login[playerid]) return true;
    for(new b = 1; b <= MAX_BUSINESS; b++)
    {
        if(!IsPlayerInRangeOfPoint(playerid, 1.5, Business[b][bX], Business[b][bY], Business[b][bZ])) continue;
        if(Player[playerid][pMoney] < Business[b][bPrice]) return err(playerid, "У вас недостаточно денег!");
        if(strcmp(Business[b][bOwner], "None", true) != 0) return err(playerid, "Бизнес не продается!");
		if(Player[playerid][pBusiness3] != 0) return err(playerid, "У вас максимальное количество бизнесов!");
        Business[b][bOwner] = Player[playerid][pID];
        UpdateBusiness(b);
        kazna += Business[b][bPrice];
		transaction(playerid, -Business[b][bPrice]);
        SCM(playerid, COLOR_GREEN, "Вы купили бизнес!");
		if(Player[playerid][pBusiness1] == 0) return Player[playerid][pBusiness1] = b;
		if(Player[playerid][pBusiness2] == 0) return Player[playerid][pBusiness2] = b;
		if(Player[playerid][pBusiness3] == 0) return Player[playerid][pBusiness3] = b;
        return true;
    }
    return true;
}


// Прочее
CMD:unrent(playerid)
{
    if(!login[playerid]) return true;
    if(!IsRentableVehicle[GetPlayerVehicleID(playerid)]) return err(playerid, "Вы не арендуете данное т/с!");
	SetVehicleToRespawn(GetPlayerVehicleID(playerid));
	RentCar[GetPlayerVehicleID(playerid)][rRenter] = 0;
    suc(playerid, "Вы отказались от аренды!");
    return true;
}
CMD:taxi(playerid)
{
    if(!login[playerid]) return true;
	SPD(playerid, dTaxi, DSL, "Выберите точку назначения. Стоимость поездки - $50", "Бизнес-центр\nТорговый центр", "Далее", "Выход");
	return true;
}
CMD:econ(playerid, string[128])
{
    if(!login[playerid]) return true;
	for(new i = 0; i < MAX_PLAYERS; i++)
	{
		if(IsPlayerConnected(i)) SavePlayer(i);
 	}
	SaveBusiness();
	new query[128];
	format(query, sizeof(query), "SELECT sum(`money`) from `accounts`");
	mysql_query(query);
	new result[18], playersmoney, businessmoney;
	mysql_store_result();
	mysql_fetch_row(result);
	playersmoney = strval(result);
	mysql_free_result();
	format(query, sizeof(query), "SELECT sum(`balance`) from `business`");
	mysql_query(query);
	mysql_store_result();
	mysql_fetch_row(result);
	businessmoney = strval(result);
	mysql_free_result();
	format(string, sizeof(string), "Казна: {33AA33}$%d", kazna);
	inf(playerid, string);
	format(string, sizeof(string), "Денег у игроков: {33AA33}$%d", playersmoney);
	inf(playerid, string);
	format(string, sizeof(string), "Денег в кассах бизнесов: {33AA33}$%d", businessmoney);
	inf(playerid, string);
	return true;
}
CMD:info(playerid)
{
    if(!login[playerid]) return true;
	SPD(playerid, dEmptyResult, DSTH, "SAMP Finance Game v2.1.2", "Задача\tВознаграждение\nНахождение любой неточности в моде\t5 рублей\nНахождение бага\t15 рублей\tНахождение критического бага\t50 рублей\nУникальная идея для сервера\tдо 100 рублей", "ОК", "");
	return true;
}
