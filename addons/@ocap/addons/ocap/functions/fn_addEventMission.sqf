addMissionEventHandler["HandleDisconnect", {
	_this call ocap_fnc_eh_disconnected;
}];

addMissionEventHandler["PlayerConnected", {
	_this call ocap_fnc_eh_connected;
}];

addMissionEventHandler ["EntityKilled", {
	_this call ocap_fnc_eh_killed;
}];


// LOG ACE REMOTE DET EVENTS
[{
    params ["_unit", "_range", "_explosive", "_fuzeTime", "_triggerItem"];

	_int = random 2000;

	// expl is ammo, need to find mag, and display name of mag
	_explosiveMag = getText(configFile >> "CfgAmmo" >> (typeOf _explosive) >> "defaultMagazine");
	_explosiveDisp = getText(configFile >> "CfgMagazines" >> _explosiveMag >> "displayName");
	_triggerItemDisp = getText(configFile >> "CfgWeapons" >> _triggerItem >> "displayName");

	_markTextLocal = format["%1 - %2", _triggerItemDisp, _explosiveDisp];
	_markName = format["Detonation#%1", _int];
	_markColor = "ColorRed";
	_markerType = "waypoint";
	_pos = getPos _explosive;

	["fnf_ocap_handleMarker", ["CREATED", _markName, _unit, _pos, _markerType, "ICON", [1,1], 0, "Solid", "ColorRed", 1, _markTextLocal]] call CBA_fnc_localEvent;

	[_markName] spawn {
		params ["_markName"];

		sleep 7;
		// [format['["fnf_ocap_handleMarker", ["DELETED", %1]] call CBA_fnc_serverEvent;', _markName]] remoteExec ["hint", 0];
		// systemChat format['["fnf_ocap_handleMarker", ["DELETED", %1]] call CBA_fnc_serverEvent;', _markName];
		["fnf_ocap_handleMarker", ["DELETED", _markName]] call CBA_fnc_localEvent;
	};

}] call ace_explosives_fnc_addDetonateHandler;



if (ocap_saveMissionEnded) then {
	addMissionEventHandler ["MPEnded", {
		["Mission ended automatically"] call ocap_fnc_exportData;
	}];
};

// Add event saving markers
["INIT"] call ocap_fnc_handleMarkers;

["WMT_fnc_EndMission", {
	_this call ocap_fnc_exportData;
}] call CBA_fnc_addEventHandler;