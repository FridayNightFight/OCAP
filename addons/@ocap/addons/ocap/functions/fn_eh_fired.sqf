_projectile = _this select 6;
_firer = _this select 7;
_frame = ocap_captureFrameNo;


// if (!isServer) exitWith {};

_muzzle = _this select 2;
_ammo = _this select 4;
_mag = _this select 5;
_magDisp = getText(configFile >> "CfgMagazines" >> _mag >> "displayNameShort");
_ammoSimType = getText(configFile >> "CfgAmmo" >> _ammo >> "simulation");
_int = random 2000;


// bullet handling, cut short
if (_ammoSimType isEqualTo "shotBullet") then {
	[_projectile, _firer, _frame] spawn {
		params["_projectile", "_firer", "_frame"];
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


	// non-bullet handling
	_markTextLocal = format["%1 - %2", _ammoSimType, _magDisp];
	// _markTextLocal = _magDisp;
	_markName = format["Projectile#%1", _int];
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

	_firerPosRaw = getPosATL _firer;
	_firerPos = parseSimpleArray (format["[%1,%2]", _firerPosRaw # 0, _firerPosRaw # 1]);
	["fnf_ocap_handleMarker", ["CREATED", _markName, _firer, _firerPos, "mil_triangle", "ICON", [1,1], 0, "Solid", "ColorRed", 1, _markTextLocal]] call CBA_fnc_serverEvent;



	
	// ["fnf_ocap_handleMarker", ["CREATED", _markStr, _firer]] call CBA_fnc_serverEvent;

	_lastPos = [];
	waitUntil {
		_pos = getPosATL _projectile;
		if (((_pos select 0) isEqualTo 0) || (!alive _projectile)) exitWith {
			true
		};
		
		if (!(_lastPos isEqualTo _pos)) then {
			_projPos = parseSimpleArray (format["[%1,%2]", _pos # 0, _pos # 1]);
			// _markName setMarkerPosLocal _lastPos;
			["fnf_ocap_handleMarker", ["UPDATED", _markName, _firer, _projPos]] call CBA_fnc_serverEvent;
		};

		_lastPos = _pos;
		false;
	};
	if (!(count _lastPos == 0)) then {
		_finalPos = parseSimpleArray (format["[%1,%2]", _lastPos # 0, _lastPos # 1]);
		["fnf_ocap_handleMarker", ["UPDATED", _markName, _firer, _finalPos]] call CBA_fnc_serverEvent;
	};
	sleep 5;
	// deleteMarkerLocal _markName;
	["fnf_ocap_handleMarker", ["DELETED", _markName]] call CBA_fnc_serverEvent;
};