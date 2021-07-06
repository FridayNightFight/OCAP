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

// Custom event handler
ocap_customEvent_handle = ["ocap_handleCustomEvent", {
	params ["_eventName", "_eventMessage"];
	[":EVENT:", 
		[ocap_captureFrameNo, _eventName, _eventMessage]
	] call ocap_fnc_extension;
}] call CBA_fnc_addEventHandler;
// to call, run
// ["ocap_handleCustomEvent", ["eventType", "eventMessage"]] call CBA_fnc_serverEvent;

// Add event saving markers
call ocap_fnc_handleMarkers;


["WMT_fnc_EndMission", {
	_this call ocap_fnc_exportData;
}] call CBA_fnc_addEventHandler;