private _projectile = _this select 6;
private _unit = _this select 7;
private _frame = ocap_captureFrameNo;

private _lastPos = [];
waitUntil {
	_pos = getPosATL _projectile;
	if (((_pos select 0) isEqualTo 0) || isNull _projectile) exitWith {true};
	_lastPos = _pos;
	false;
};

if !((count _lastPos) isEqualTo 0) then {
	[":FIRED:",[
		(_unit getVariable "ocap_id"),
		_frame,
		[_lastPos select 0, _lastPos select 1]
	]] call ocap_fnc_extension;
};