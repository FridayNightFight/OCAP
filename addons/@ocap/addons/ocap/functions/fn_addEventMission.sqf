addMissionEventHandler["HandleDisconnect", {
	_this call ocap_fnc_eh_disconnected;
}];

addMissionEventHandler["PlayerConnected", {
	_this call ocap_fnc_eh_connected;
}];

addMissionEventHandler ["EntityKilled", {
	_this call ocap_fnc_eh_killed;
}];

call ocap_fnc_trackAceExplPlace;

if (ocap_saveMissionEnded) then {
	addMissionEventHandler ["MPEnded", {
		["Mission ended automatically"] call ocap_fnc_exportData;
	}];
};

// Add event saving markers
[
	{BIS_fnc_init},
	{call ocap_fnc_handleMarkers;}
] call CBA_fnc_waitUntilAndExecute;


["WMT_fnc_EndMission", {
	_this call ocap_fnc_exportData;
}] call CBA_fnc_addEventHandler;