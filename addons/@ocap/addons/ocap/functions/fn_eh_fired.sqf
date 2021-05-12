private _projectile = _this select 6;
private _firer = _this select 7;
private _frame = ocap_captureFrameNo;

_muzzle = _this select 2;
_ammo = _this select 4;
_mag = _this select 5;
_magDisp = getText(configFile >> "CfgMagazines" >> _mag >> "displayNameShort");
_firer = _this select 7;
_int = random 2000;


_frags = [
	"M67",
	"HE Grenade",
	"HET Grenade",
	"HE-T Grenade",
	"HEDP Grenade",
	"Frag Grenade",
	"Incendiary Grenade",
	"V40",
	"FRAG",
	"M.24",
	"M.24 Frag",
	"M.24 x7",
	"M.39",
	"M.39 Frag",
	"M.43",
	"M.43 Frag",
	"Mk 2 Frag",
	"RGO Impact",
	"RGN Impact",
	"VOG-17",
	"VOG17M",
	"VOG30"
];

_smokes = [
	"Orange Smoke",
	"Purple Smoke",
	"Red Smoke"
];

_flares = [
	"White Flare",
	"Red Flare",
	"Green Flare",
	"Blue Flare"
];


// bullet handling, cut short
private _lastPos = [];
waitUntil {
	_pos = getPosATL _projectile;
	if (((_pos select 0) isEqualTo 0) || isNull _projectile) exitWith {true};
	_lastPos = _pos;
	false;
};

if !((count _lastPos) isEqualTo 0) then {
	[":FIRED:",[
		(_firer getVariable "ocap_id"),
		_frame,
		[_lastPos select 0, _lastPos select 1]
	]] call ocap_fnc_extension;
};


// grenade handling
_markTextLocal = "";
if (_magDisp in _frags) then {
	_markTextLocal = "FragG";
} else {
	if (["Smoke", _magDisp] call BIS_fnc_inString) then {
		_markTextLocal = "SmokeG";
	} else {
		if (_magDisp in _flares) then {
			_markTextLocal = "FlareG";
		};
	};
};

// _mark = format["|%1|%2|%3|%4|%5|%6|%7|%8|%9|%10",
// 	(text format["Projectile%1", _int]),
// 	getPos _projectile,
// 	"selector_selectable",
// 	"ICON",
// 	[1,1],
// 	0,
// 	"Solid",
// 	"Default",
// 	1,
// 	_markTextLocal
// ] call BIS_fnc_stringToMarkerLocal;
_mark = createMarkerLocal [format["Projectile%1", _int],_projectile, _firer call BIS_fnc_sideID, _firer];
[_mark, "selector_selectable"] remoteExec ["setMarkerTypeLocal", _firer];
[_mark, "ICON"] remoteExec ["setMarkerShapeLocal", _firer];
[_mark, _markTextLocal] remoteExec ["setMarkerTextLocal", _firer];

// ["fnf_ocap_handleMarker", ["CREATED", _mark call BIS_fnc_markerToString, player]] call CBA_fnc_serverEvent;

_lastPos = [];
waitUntil {
	_pos = getPosATL _projectile;
	if (((_pos select 0) isEqualTo 0) || (!alive _projectile)) exitWith {
		true
	};
	_lastPos = _pos;
	[_mark, _lastPos] remoteExec ["setMarkerPosLocal", _firer];
	sleep 0.1;
	// ["fnf_ocap_handleMarker", ["UPDATED", _mark call BIS_fnc_markerToString, player]] call CBA_fnc_serverEvent;
	false;
};
uiSleep 5;
[_mark] remoteExec ["deleteMarkerLocal", _firer];;
// ["fnf_ocap_handleMarker", ["DELETED", _mark, player]] call CBA_fnc_serverEvent;
if !((count _lastPos) isEqualTo 0) then {
	hint format["%1 landed at %2", _magDisp, _lastPos];
};