params ["_firer", "_weapon", "_muzzle", "_mode", "_ammo", "_magazine", "_projectile", "_vehicle"];

_frame = ocap_captureFrameNo;

// if (!isServer) exitWith {};

_ammoSimType = getText(configFile >> "CfgAmmo" >> _ammo >> "simulation");

// bullet handling, cut short
if (_ammoSimType isEqualTo "shotBullet") then {
	[_projectile, _firer, _frame, _ammoSimType, _ammo] spawn {
		params["_projectile", "_firer", "_frame", "_ammoSimType", "_ammo"];
		if (isNull _projectile) then {
			_projectile = nearestObject [_firer, _ammo];
		};
		private _lastPos = [];
		waitUntil {
			_pos = getPosATL _projectile;
			if (((_pos select 0) isEqualTo 0) || isNull _projectile) exitWith {
				true
			};
			_lastPos = _pos;
			false;
		};

		if !((count _lastPos) isEqualTo 0) then {
			[":FIRED:", [
				(_firer getVariable "ocap_id"),
				_frame, [_lastPos select 0, _lastPos select 1]
			]] call ocap_fnc_extension;
		};
	};

} else {

	// simulation == "ShotSmokeX"; // M18 Smoke
	// "ShotGrenade" // M67
	// "ShotRocket" // S-8
	// "ShotMissile" // R-27
	// "ShotShell" // VOG-17M, HE40mm
	// "ShotIlluminating" // 40mm_green Flare
	// "ShotMine" // Satchel remote

	_int = random 2000;
	_muzzleDisp = getText(configFile >> "CfgWeapons" >> _weapon >> _muzzle >> "displayName");
	if (_muzzleDisp == "") then {_muzzleDisp = getText(configFile >> "CfgWeapons" >> _weapon >> "displayNameShort")};
	if (_muzzleDisp == "") then {_muzzleDisp = getText(configFile >> "CfgWeapons" >> _weapon >> "displayName")};
	_magDisp = getText(configFile >> "CfgMagazines" >> _magazine >> "displayNameShort");
	if (_magDisp == "") then {_magDisp = getText(configFile >> "CfgMagazines" >> _magazine >> "displayName")};
	if (_magDisp == "") then {_magDisp = getText(configFile >> "CfgAmmo" >> _ammo >> "displayNameShort")};
	if (_magDisp == "") then {_magDisp = getText(configFile >> "CfgAmmo" >> _ammo >> "displayName")};

	// non-bullet handling
	private ["_markTextLocal"];
	if (!isNull _vehicle) then {
		_markTextLocal = format["[%3] %1 - %2", _muzzleDisp, _magDisp, ([configOf _vehicle] call BIS_fnc_displayName)];
	} else {
		if (_ammoSimType isEqualTo "shotGrenade") then {
			_markTextLocal = format["%1", _magDisp];
		} else {
			_markTextLocal = format["%1 - %2", _muzzleDisp, _magDisp];
		};
	};
	
	_markName = format["Projectile#%1", _int];
	_markColor = "ColorRed";
	_markerType = "";
	_magPic = (getText(configfile >> "CfgMagazines" >> _magazine >> "picture"));
	if (_magPic == "") then {
		_markerType = "mil_triangle";
	} else {
		_magPicSplit = _magPic splitString "\";
		_magPic = _magPicSplit # ((count _magPicSplit) -1);
		_markerType = format["magIcons/%1", _magPic];
		_markColor = "ColorWhite";
	};


	// _markStr = format["|%1|%2|%3|%4|%5|%6|%7|%8|%9|%10",
	// 	_markName,
	// 	getPos _firer,
	// 	"mil_triangle",
	// 	"ICON",
	// 	[1, 1],
	// 	0,
	// 	"Solid",
	// 	"ColorRed",
	// 	1,
	// 	_markTextLocal
	// ];

	// _markStr call BIS_fnc_stringToMarkerLocal;

	// diag_log text format["detected grenade, created marker %1", _markStr];

	// _markStr = str _mark;
	// _mark = createMarkerLocal [format["Projectile%1", _int],_projectile];
	// _mark setMarkerColorLocal "ColorRed";
	// _mark setMarkerTypeLocal "selector_selectable";
	// _mark setMarkerShapeLocal "ICON";
	// _mark setMarkerTextLocal format["%1 - %2", _firer, _markTextLocal];

	_firerPos = getPosATL _firer;
	_firerPos resize 2;
	["ocap_handleMarker", ["CREATED", _markName, _firer, _firerPos, _markerType, "ICON", [1,1], 0, "Solid", _markColor, 1, _markTextLocal, true]] call CBA_fnc_localEvent;

	if (isNull _projectile) then {
		_projectile = nearestObject [_firer, _ammo];
	};

	private _lastPos = [];
	waitUntil {
		_pos = getPosATL _projectile;
		if (((_pos select 0) isEqualTo 0) || isNull _projectile) exitWith {
			true
		};
		_lastPos = _pos;
		["ocap_handleMarker", ["UPDATED", _markName, _firer, [_pos # 0, _pos # 1], 0, 1]] call CBA_fnc_localEvent;
		sleep 0.1;
		false;
	};

	if !((count _lastPos) isEqualTo 0) then {
	// if (count _lastPos == 3) then {
		_lastPos resize 2;
		["ocap_handleMarker", ["UPDATED", _markName, _firer, _lastPos, 0, 1]] call CBA_fnc_localEvent;
	};
	sleep 10;
	// deleteMarkerLocal _markName;
	// };
	["ocap_handleMarker", ["DELETED", _markName]] call CBA_fnc_localEvent;
};