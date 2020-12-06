#define _FOREACH_LOCAL_VERSION        16

// Foreach is testing us.
#if defined _FOREACH_INC_TEST
	#define _FOREACH_CUR_VERSION _FOREACH_LOCAL_VERSION
	#endinput
#endif
#if !defined _FOREACH_NO_TEST
	#define _FOREACH_INC_TEST
	#tryinclude <YSI\y_iterate>
	#undef _FOREACH_INC_TEST
	// <foreach> exists - test which is newer.
	#if defined _inc_y_iterate
		#if _FOREACH_CUR_VERSION > _FOREACH_LOCAL_VERSION
			// Foreach is newer.
			#undef _inc_y_iterate
			#define _FOREACH_NO_TEST
			#include <YSI\y_iterate>
			#endinput
		#endif
	#endif
#endif

#if !defined _samp_included
	#error "Please include a_samp or a_npc before foreach"
#endif

#if defined SendChat || defined FOREACH_NO_PLAYERS
	#define BOTSYNC_IS_BOT     (true)
#endif

#if defined IsPlayerNPC
	#define _FOREACH_BOT
#endif

#if defined YSI_ITTER_NO_SORT
	#error YSI_ITTER_NO_SORT is no longer supported by foreach.
#endif

#define _Y_ITER_ARRAY: _:_Y_ITER_C0:
#define _Y_ITER_ARRAY_SIZE(%1) _:_Y_ITER_C1:_Y_ITER_C2:sizeof %1@YSII_Ag-1

#define _Y_ITER_C0:%0[%1]@YSII_%4g%3) %0@YSII_%4g[%1]%3)
#define _Y_ITER_C1:_Y_ITER_C2:%0[%1]@YSII_Ag%3) %0@YSII_Ag[]%3)
#define _Y_ITER_C2:sizeof%0(%1)@YSII_Ag-1;_:(%2=_Y_ITER_ARRAY:%3(%4)@YSII_Ag[%5])!=_Y_ITER_ARRAY_SIZE(%6);) -1;_:(%2=%3@YSII_Ag(%4,%5))!=-1;)

#define _Y_ITER_C3:%0[%1]@YSII_Cg,%2[%3]@YSII_Ag[%4]={%5} _Y_ITER_C3:%0@YSII_Cg[%1],%0@YSII_Ag[%1][%4]

#if !defined BOTSYNC_IS_BOT
	static stock
		YSI_g_sCallbacks = 0;
#endif

#define IteratorArray:%1[%2]<%3> %1@YSII_Cg[%2],%1@YSII_Ag[%2][%3+1]//,%1@YSII_Rg[%2][%3+1]

#define Iterator:%1<%2> _Y_ITER_C3:%1@YSII_Cg,%1@YSII_Ag[(%2)+1]={(%2)*2,(%2)*2-1,...}
#define iterator%0<%1> Iterator:%0<%1>


#define Iter_Init Itter_Init
#define Itter_Init(%1) \
	Itter_InitInternal(%1@YSII_Ag,sizeof %1@YSII_Ag,sizeof %1@YSII_Ag[]-1)

#define Iter_Add Itter_Add
#define Itter_Add(%1,%2) Itter_AddInternal(_Y_ITER_ARRAY:%1@YSII_Cg,_Y_ITER_ARRAY:%1@YSII_Ag,%2,_Y_ITER_ARRAY_SIZE(%1))

#define Iter_Free Itter_Free
#define Itter_Free(%1) Itter_FreeInternal(_Y_ITER_ARRAY:%1@YSII_Ag,_Y_ITER_ARRAY_SIZE(%1))

#define Iter_Remove Itter_Remove
#define Itter_Remove(%1,%2) Itter_RemoveInternal(_Y_ITER_ARRAY:%1@YSII_Cg,_Y_ITER_ARRAY:%1@YSII_Ag,%2,_Y_ITER_ARRAY_SIZE(%1))

#define Iter_Contains Itter_Contains
#define Itter_Contains(%1,%2) Itter_ContainsInternal(_Y_ITER_ARRAY:%1@YSII_Ag,%2,_Y_ITER_ARRAY_SIZE(%1))


#define Iter_SafeRemove Itter_SafeRemove
#define Itter_SafeRemove(%1,%2,%3) Itter_SafeRemoveInternal(_Y_ITER_ARRAY:%1@YSII_Cg,_Y_ITER_ARRAY:%1@YSII_Ag,%2,%3,_Y_ITER_ARRAY_SIZE(%1))

#define Iter_Random Itter_Random
#define Itter_Random(%1) Itter_RandomInternal(_Y_ITER_ARRAY:%1@YSII_Cg,_Y_ITER_ARRAY:%1@YSII_Ag,_Y_ITER_ARRAY_SIZE(%1))

#define Iter_Count Itter_Count
#define Itter_Count(%1) (_Y_ITER_ARRAY:%1@YSII_Cg)

#define Iter_Clear Itter_Clear
#define Itter_Clear(%1) Itter_ClearInternal(_Y_ITER_ARRAY:%1@YSII_Cg,_Y_ITER_ARRAY:%1@YSII_Ag,_Y_ITER_ARRAY_SIZE(%1))


#if !defined BOTSYNC_IS_BOT
	new
		Iterator:Player<MAX_PLAYERS>;
	
	#if defined _FOREACH_BOT && !defined FOREACH_NO_BOTS
		new
			Iterator:Bot<MAX_PLAYERS>,
			Iterator:Character<MAX_PLAYERS>;
		
		//#define NPC@YSII_Sg Bot@YSII_Sg
		#define NPC@YSII_Cg Bot@YSII_Cg
		#define NPC@YSII_Ag Bot@YSII_Ag
		//#define NPC@YSII_Eg Bot@YSII_Eg
		//#define NPC@YSII_Rg Bot@YSII_Rg
	#endif
#endif


static stock
	YSI_gsOnPlayerConnect[] = "Itter_OnPlayerConnect",
	YSI_gsOnPlayerDisconnect[] = "Itter_OnPlayerDisconnect",
	YSI_gsOnGameModeInit[] = "Itter_OnGameModeInit",
	YSI_gsSpecifier@[] = "";

#define foreach%1(%0) for(new Y_FOREACH_SECOND|||Y_FOREACH_THIRD|||%0|||)
#define new%0|||%9|||%1:%2||| %9|||%0|||%1|||%2|||
#define Y_FOREACH_THIRD|||%0|||%1|||%2||| %1=Y_FOREACH_FIFTH|||Y_FOREACH_FOURTH|||%1:%2|||
#define Y_FOREACH_FOURTH|||%0=Y_FOREACH_FIFTH|||%1|||%2||| new Y_FOREACH_SIXTH;%0|||Y_FOREACH_SEVENTH|||%2|||
#define Y_FOREACH_SEVENTH|||%9Y_FOREACH_SIXTH;%0|||%1|||%2||| new %0:%1=%0:_Y_ITER_ARRAY_SIZE(%2);_:(%1=_Y_ITER_ARRAY:%2@YSII_Ag[%1])!=_Y_ITER_ARRAY_SIZE(%2);
#define Y_FOREACH_SIXTH;%0|||Y_FOREACH_SEVENTH|||%2||| %0=_Y_ITER_ARRAY_SIZE(%2);_:(%0=_Y_ITER_ARRAY:%2@YSII_Ag[%0])!=_Y_ITER_ARRAY_SIZE(%2);
#define Y_FOREACH_FIFTH|||Y_FOREACH_FOURTH|||%1:%2||| _Y_ITER_ARRAY_SIZE(%2);_:(%1=_Y_ITER_ARRAY:%2@YSII_Ag[%1])!=_Y_ITER_ARRAY_SIZE(%2);
#define Y_FOREACH_SECOND|||Y_FOREACH_THIRD|||%1,%2||| %2=_Y_ITER_ARRAY_SIZE(%1);_:(%2=_Y_ITER_ARRAY:%1@YSII_Ag[%2])!=_Y_ITER_ARRAY_SIZE(%1);

#define foreachex(%1,%2) foreach(%2:%1)

#if !defined BOTSYNC_IS_BOT
	public OnPlayerConnect(playerid)
	{
		#if defined _FOREACH_BOT
			if (!IsPlayerNPC(playerid))
			{
				Itter_Add(Player, playerid);
			}
			#if !defined FOREACH_NO_BOTS
				else
				{
					Itter_Add(Bot, playerid);
				}
				#pragma tabsize 4
				Itter_Add(Character, playerid);
			#endif
		#else
			Itter_Add(Player, playerid);
		#endif
		if (YSI_g_sCallbacks & 2)
		{
			CallLocalFunction(YSI_gsOnPlayerConnect, "i", playerid);
		}
		return 1;
	}
	
	#if defined _ALS_OnPlayerConnect
		#undef OnPlayerConnect
	#else
		#define _ALS_OnPlayerConnect
	#endif
	#define OnPlayerConnect Itter_OnPlayerConnect
	forward OnPlayerConnect(playerid);
#endif

#if !defined BOTSYNC_IS_BOT
	public OnFilterScriptInit()
	{
		if (funcidx(YSI_gsOnPlayerDisconnect) != -1)
		{
			YSI_g_sCallbacks |= 1;
		}
		if (funcidx(YSI_gsOnPlayerConnect) != -1)
		{
			YSI_g_sCallbacks |= 2;
		}
		CallLocalFunction("Itter_OnFilterScriptInit", YSI_gsSpecifier@);
		return 1;
	}
	
	#if defined _ALS_OnFilterScriptInit
		#undef OnFilterScriptInit
	#else
		#define _ALS_OnFilterScriptInit
	#endif
	#define OnFilterScriptInit Itter_OnFilterScriptInit
	forward OnFilterScriptInit();
#endif

#if !defined BOTSYNC_IS_BOT
	public OnGameModeInit()
	{
		// Clear everything.
		if (funcidx(YSI_gsOnPlayerDisconnect) != -1)
		{
			YSI_g_sCallbacks |= 1;
		}
		if (funcidx(YSI_gsOnPlayerConnect) != -1)
		{
			YSI_g_sCallbacks |= 2;
		}
		if (!Player@YSII_Cg)
		{
			#if defined _FOREACH_BOT && !defined FOREACH_NO_BOTS
				CallLocalFunction(YSI_gsOnGameModeInit, YSI_gsSpecifier@, Bot@YSII_Cg, Character@YSII_Cg, Player@YSII_Cg);
			#else
				CallLocalFunction(YSI_gsOnGameModeInit, YSI_gsSpecifier@, Player@YSII_Cg);
			#endif
			return 1;
		}

		#if defined _FOREACH_BOT && !defined FOREACH_NO_BOTS
			Bot@YSII_Cg = _Y_ITER_C3:0;
			Bot@YSII_Ag[MAX_PLAYERS] = MAX_PLAYERS;
			Character@YSII_Ag[MAX_PLAYERS] = MAX_PLAYERS;
			Character@YSII_Cg = _Y_ITER_C3:0;
			new
				lastBot = MAX_PLAYERS,
				lastCharacter = MAX_PLAYERS;
		#endif
		Player@YSII_Cg = _Y_ITER_C3:0;
		Player@YSII_Ag[MAX_PLAYERS] = MAX_PLAYERS;
		new
			lastPlayer = MAX_PLAYERS;
		for (new i = 0; i != MAX_PLAYERS; ++i)
		{
			if (IsPlayerConnected(i))
			{
				#if defined _FOREACH_BOT
					// Had to do "if ! else" due to compile options.
					if (!IsPlayerNPC(i))
					{
						Player@YSII_Ag[lastPlayer] = i;
						++Player@YSII_Cg;
						lastPlayer = i;
					}
					#if !defined FOREACH_NO_BOTS
						else
						{
							Bot@YSII_Ag[lastBot] = i;
							++Bot@YSII_Cg;
							lastBot = i;
						}
						#pragma tabsize 4
						Character@YSII_Ag[lastCharacter] = i;
						++Character@YSII_Cg;
						lastCharacter = i;
					#endif
				#else
					Player@YSII_Ag[lastPlayer] = i;
					++Player@YSII_Cg;
					lastPlayer = i;
				#endif
			}
			else
			{
				#if defined _FOREACH_BOT && !defined FOREACH_NO_BOTS
					Bot@YSII_Ag[i] = MAX_PLAYERS + 1;
					//Bot@YSII_Rg[i] = -1;
					Character@YSII_Ag[i] = MAX_PLAYERS + 1;
					//Character@YSII_Rg[i] = -1;
				#endif
				Player@YSII_Ag[i] = MAX_PLAYERS + 1;
			}
		}
		#if defined _FOREACH_BOT && !defined FOREACH_NO_BOTS
			Bot@YSII_Ag[lastPlayer] = MAX_PLAYERS;
			Character@YSII_Ag[lastPlayer] = MAX_PLAYERS;
		#endif
		Player@YSII_Ag[lastPlayer] = MAX_PLAYERS;
		CallLocalFunction(YSI_gsOnGameModeInit, YSI_gsSpecifier@);
		return 1;
	}
	
	#if defined _ALS_OnGameModeInit
		#undef OnGameModeInit
	#else
		#define _ALS_OnGameModeInit
	#endif
	#define OnGameModeInit Itter_OnGameModeInit
	forward OnGameModeInit();
#endif

#if !defined BOTSYNC_IS_BOT
	public OnPlayerDisconnect(playerid, reason)
	{
		if (YSI_g_sCallbacks & 1)
		{
			CallLocalFunction(YSI_gsOnPlayerDisconnect, "ii", playerid, reason);
		}
		#if defined _FOREACH_BOT
			if (!IsPlayerNPC(playerid))
			{
				Itter_Remove(Player, playerid);
			}
			#if !defined FOREACH_NO_BOTS
				else
				{
					Itter_Remove(Bot, playerid);
				}
				#pragma tabsize 4
				Itter_Remove(Character, playerid);
			#endif
		#else
			Itter_Remove(Player, playerid);
		#endif
		return 1;
	}
	
	#if defined _ALS_OnPlayerDisconnect
		#undef OnPlayerDisconnect
	#else
		#define _ALS_OnPlayerDisconnect
	#endif
	#define OnPlayerDisconnect Itter_OnPlayerDisconnect
	forward OnPlayerDisconnect(playerid, reason);
#endif

stock
	Itter_RandomInternal(count, array[], size)
{
	if (count == 0)
	{
		return -1;
	}
	new
		rnd = random(count),
		cur = array[size];
	while (cur != size)
	{
		if (rnd-- == 0)
		{
			return cur;
		}
		cur = array[cur];
	}
	return -1;
}

stock
	Itter_FreeInternal(array[], size)
{
	for (new i = 0; i != size; ++i)
	{
		if (array[i] > size)
		{
			return i;
		}
	}
	return -1;
}

stock
	Itter_AddInternal(&count, array[], value, size)
{
	if (0 <= value < size && array[value] > size)
	{
		new
			last = size,
			next = array[last];
		while (next < value)
		{
			last = next;
			next = array[last];
		}
		array[last] = value;
		array[value] = next;
		++count;
		return 1;
	}
	return 0;
}

stock
	Itter_RemoveInternal(&count, array[], value, size)
{
	new
		last;
	return Itter_SafeRemoveInternal(count, array, value, last, size);
}

stock
	Itter_SafeRemoveInternal(&count, array[], value, &last, size)
{
	if (0 <= value < size && array[value] <= size)
	{
		last = size;
		new
			next = array[last];
		while (next != value)
		{
			last = next;
			next = array[last];
		}
		array[last] = array[value];
		array[value] = size + 1;
		--count;
		return 1;
	}
	return 0;
}

stock
	Itter_ContainsInternal(array[], value, size)
{
	return 0 <= value < size && array[value] <= size;
}

stock
	Itter_ClearInternal(&count, array[], size)
{
	for (new i = 0, t = size + 1; i < size; ++i)
	{
		array[i] = t;
	}
	array[size] = size;
	count = 0;
}

stock
	Itter_InitInternal(arr[][], s0, s1)
{
	for (new i = 0, t = s1 + 1; i < s0; ++i)
	{
		for (new j = 0; j < s1; ++j)
		{
			arr[i][j] = t;
		}
		arr[i][s1] = s1;
	}
}

stock
	Itter_PrevInternal(array[], size, slot)
{
	if (0 <= slot <= size && array[slot] <= size)
	{
		new last = size;
		for ( ; ; )
		{
			new next = array[last];
			if (next == slot)
			{
				return last;
			}
			last = next;
		}
	}
	return size;
}

#define Iter_Begin(%1) (_Y_ITER_ARRAY_SIZE(%1))
#define Itter_Begin(%1) (_Y_ITER_ARRAY_SIZE(%1))
#define Iter_End(%1) (_Y_ITER_ARRAY_SIZE(%1))
#define Itter_End(%1) (_Y_ITER_ARRAY_SIZE(%1))
#define Iter_First(%1) (_Y_ITER_ARRAY:%1@YSII_Ag[_Y_ITER_ARRAY_SIZE(%1)])
#define Itter_First(%1) (_Y_ITER_ARRAY:%1@YSII_Ag[_Y_ITER_ARRAY_SIZE(%1)])
#define Iter_Last(%1) Itter_PrevInternal(_Y_ITER_ARRAY:%1@YSII_Ag,_Y_ITER_ARRAY_SIZE(%1),_Y_ITER_ARRAY_SIZE(%1))
#define Itter_Last(%1) Itter_PrevInternal(_Y_ITER_ARRAY:%1@YSII_Ag,_Y_ITER_ARRAY_SIZE(%1),_Y_ITER_ARRAY_SIZE(%1))
#define Iter_Next(%1,%2) (_Y_ITER_ARRAY:%1@YSII_Ag[(%2)])
#define Itter_Next(%1,%2) (_Y_ITER_ARRAY:%1@YSII_Ag[(%2)])
#define Iter_Prev(%1,%2) Itter_PrevInternal(_Y_ITER_ARRAY:%1@YSII_Ag,_Y_ITER_ARRAY_SIZE(%1),(%2))
#define Itter_Prev(%1,%2) Itter_PrevInternal(_Y_ITER_ARRAY:%1@YSII_Ag,_Y_ITER_ARRAY_SIZE(%1),(%2))