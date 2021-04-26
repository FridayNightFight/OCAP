params ["_victim", "_hitter"];
_victimId = _victim getVariable "ocap_id";

private _eventData = [ocap_captureFrameNo, "hit", _victimId, ["null"], -1];
if (!isNull _hitter) then {
	_hitterInfo = [];
	if (_hitter isKindOf "CAManBase") then {
		_hitterInfo = [
			_hitter getVariable "ocap_id",
			getText (configFile >> "CfgWeapons" >> currentWeapon _hitter >> "displayName")
		];
	} else {
		_hitterInfo = [_hitter getVariable "ocap_id"];
	};
	_eventData = [
		ocap_captureFrameNo,
		"hit",
		_victimId,
		_hitterInfo,
		round (_victim distance _hitter)
	];
};

[":EVENT:", _eventData] call ocap_fnc_extension;
