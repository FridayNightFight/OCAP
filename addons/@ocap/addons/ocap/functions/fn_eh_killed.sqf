params ["_victim", "_killer", "_instigator"];
if !(_victim getvariable ["ocapIsKilled",false]) then {
    _victim setvariable ["ocapIsKilled",true];

    [_victim, _killer, _instigator] spawn {
        params ["_victim", "_killer", "_instigator"];
        private _frame = ocap_captureFrameNo;
        if (_killer == _victim) then {
            private _time = diag_tickTime;
            [_victim, {
                _this setVariable ["ace_medical_lastDamageSource", (_this getVariable "ace_medical_lastDamageSource"), 2];
            }] remoteExec ["call", _victim];
            waitUntil {diag_tickTime - _time > 10 || !(isNil {_victim getVariable "ace_medical_lastDamageSource"})};
            _killer = _victim getVariable ["ace_medical_lastDamageSource", _killer];
        } else {
            _killer
        };
        if (isNull _instigator) then {
            _instigator = UAVControl vehicle _killer select 0
        };
        if ((isNull _instigator) || (_instigator == _victim)) then {
            _instigator = _killer
        };
        if (_instigator isKindOf "AllVehicles") then {
            // _instigator =  effectiveCommander _instigator
            _instigator = call {
                if(alive(gunner _instigator))exitWith{gunner _instigator};
                if(alive(commander _instigator))exitWith{commander _instigator};
                if(alive(driver _instigator))exitWith{driver _instigator};
                    effectiveCommander _instigator
            };
        };
        if (isNull _instigator) then {
            _instigator = _killer
        };

        // [ocap_captureFrameNo, "killed", _victimId, ["null"], -1];
        private _victimId = _victim getVariable ["ocap_id", -1];
        if (_victimId == -1) exitWith {};
        private _eventData = [_frame, "killed", _victimId, ["null"], -1];

        if (!isNull _instigator) then {
            _killerId = _instigator getVariable ["ocap_id", -1];
            if (_killerId != -1) then {
                private _killerInfo = [];
                if (_instigator isKindOf "CAManBase") then {
                    _killerInfo = [
                        _killerId,
                        getText (configFile >> "CfgWeapons" >> currentWeapon _instigator >> "displayName")
                    ];
                } else {
                    _killerInfo = [_killerId];
                };

                _eventData = [
                    _frame,
                    "killed",
                    _victimId,
                    _killerInfo,
                    round(_instigator distance _victim)
                ];
            };
        };

        [":EVENT:", _eventData] call ocap_fnc_extension;
    };
};