_this addEventHandler ["Fired", {_this spawn ocap_fnc_eh_fired}];
_this addEventHandler ["Hit", {_this spawn ocap_fnc_eh_hit}];
if ((_this call BIS_fnc_objectType) # 0 == "Soldier") then {ocap_fnc_trackAceThrowing remoteExec ["call", _this]};