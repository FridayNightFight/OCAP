// on any ACE explosive or mine *placement* via interaction menu, will execute the code here
["ACE_Explosives_Place", "init", {

	if (!isServer) exitWith {};

	_int = random 2000;
	
	_explConfig = configOf (_this # 0);
	_explName = _explConfig call BIS_fnc_displayName;
	_explType = typeOf (_this # 0);

	_markTextLocal = format["%1", _explName];
	_markName = format["Mine#%1", _int];
	_markColor = "ColorRed";
	_markerType = "Minefield";
	_placedPos = getPos (_this # 0);
	_placer = _placedPos nearestObject "Man";

	
	_markStr = format["|%1|%2|%3|%4|%5|%6|%7|%8|%9|%10",
		_markName,
		_placedPos,
		_markerType,
		"ICON", [1, 1],
		0,
		"Solid",
		_markColor,
		1,
		_markTextLocal
	];
	_markStr call BIS_fnc_stringToMarker;

	["fnf_ocap_handleMarker", ["CREATED", _markName, _placer, _placedPos, _markerType, "ICON", [1,1], 0, "Solid", _markColor, 1, _markTextLocal]] call CBA_fnc_localEvent;

	// (_this # 0) setVariable ["asscMarker", _markName, true];
	// systemChat str ((_this # 0) getVariable ["asscMarker", -1]);

}] call CBA_fnc_addClassEventHandler;