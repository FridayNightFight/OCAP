addMissionEventHandler["HandleDisconnect", {
	_this call ocap_fnc_eh_disconnected;
}];

addMissionEventHandler["PlayerConnected", {
	_this call ocap_fnc_eh_connected;
}];

addMissionEventHandler ["EntityKilled", {
	_this call ocap_fnc_eh_killed;
}];

// Add event saving markers
["INIT"] call ocap_fnc_handleMarkers;

["WMT_fnc_EndMission", {
	_this call ocap_fnc_exportData;
}] call CBA_fnc_addEventHandler;