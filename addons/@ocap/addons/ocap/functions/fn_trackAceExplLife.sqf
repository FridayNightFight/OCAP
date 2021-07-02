
waitUntil {isNull (_this # 0)};
sleep 1;
params ["_unarmedPlacement", "_placedPos"];

_nearMines = [];
_nearMines append (_placedPos nearObjects ["TimeBombCore", 5]);
_nearMines append (_placedPos nearObjects ["APERSMine_Range_Ammo", 5]);
_nearMines append (_placedPos nearObjects ["ATMine_Range_Ammo", 5]);

if (_nearMines isEqualTo []) then {
	exit;
} else {
	_armedMine = _nearMines # 0;

	_int = random 2000;

	_explType = typeOf _armedMine;
	_explosiveMag = getText(configFile >> "CfgAmmo" >> _explType >> "defaultMagazine");
	_explosiveDisp = getText(configFile >> "CfgMagazines" >> _explosiveMag >> "displayName");

	_placedPos = getPos _armedMine;
	_placer = _placedPos nearestObject "Man";
	_placer addOwnedMine _armedMine;

	_markTextLocal = format["%1", _explosiveDisp];
	_markName = format["Mine#%1/%2", _int, _placedPos];
	_markColor = "ColorRed";
	_markerType = "Minefield";

	["ocap_handleMarker", ["CREATED", _markName, _placer, _placedPos, _markerType, "ICON", [1,1], 0, "Solid", "ColorRed", 1, _markTextLocal, true]] call CBA_fnc_localEvent;

	waitUntil {isNull _armedMine};

	["ocap_handleMarker", ["DELETED", _markName]] call CBA_fnc_localEvent;

	_markerType = "waypoint";
	_markName = format["Detonation#%1", _int];

	["ocap_handleMarker", ["CREATED", _markName, _placer, _placedPos, _markerType, "ICON", [1,1], 0, "Solid", _markColor, 1, _markTextLocal, true]] call CBA_fnc_localEvent;

	[_markName] spawn {
		params ["_markName"];
		sleep 10;
		["ocap_handleMarker", ["DELETED", _markName]] call CBA_fnc_localEvent;
	};
};