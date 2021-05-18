// on any ACE explosive or mine *placement* via interaction menu, will execute the code here
["ACE_Explosives_Place", "init", {

	if (!isServer) exitWith {};
	_placedPos = getPos (_this # 0);
	[(_this # 0), _placedPos] spawn ocap_fnc_trackAceExplLife;

}] call CBA_fnc_addClassEventHandler;