// params ["_function",["_params",[],[[]]]];


params ["_function"];

if (_function == "INIT") then {
	// diag_log ["INIT"];
	
	ocap_markers_tracked = []; // Markers which we saves into replay

	{
		["fnf_ocap_handleMarker", ["CREATED", _x call BIS_fnc_markerToString, objNull]] call CBA_fnc_serverEvent;
	} forEach allMapMarkers;

	{
		// handle created markers
		addMissionEventHandler ["MarkerCreated", {
			params ["_marker", "_channelNumber", "_owner", "_local"];

			if (!_local) exitWith {};
			diag_log text format ["OCAPLOG: Sent data from %1 with param CREATED -- 
%2", player, _marker call BIS_fnc_markerToString];
			["fnf_ocap_handleMarker", ["CREATED", _marker call BIS_fnc_markerToString, player]] call CBA_fnc_serverEvent;
		}];

		// handle marker moves/updates
		addMissionEventHandler ["MarkerUpdated", {
			params ["_marker", "_local"];

			if (!_local) exitWith {};
			diag_log text format ["OCAPLOG: Sent data from %1 with param UPDATED -- 
%2", player, _marker call BIS_fnc_markerToString];
			["fnf_ocap_handleMarker", ["UPDATED", _marker call BIS_fnc_markerToString, player]] call CBA_fnc_serverEvent;
		}];

		// handle marker deletions
		addMissionEventHandler ["MarkerDeleted", {
			params ["_marker", "_local"];

			if (!_local) exitWith {};
			diag_log text format ["OCAPLOG: Sent data from %1 with param DELETED -- 
%2", player, _marker call BIS_fnc_markerToString];
			["fnf_ocap_handleMarker", ["DELETED", _marker, player]] call CBA_fnc_serverEvent;
		}];
	} remoteExec ["call", 0, true];

};





_ocap_markers_handle = ["fnf_ocap_handleMarker", {

	params ["_eventType","_mrk_info","_mrk_owner"];

	_mrk = _mrk_info call BIS_fnc_stringToMarkerLocal;
	_mrk_color_str = markerColor _mrk;
	_mrk_color = getarray (configfile >> "CfgMarkerColors" >> _mrk_color_str >> "color") call bis_fnc_colorRGBtoHTML;
	_mrk_type = markerType _mrk;
	_mrk_text = markerText _mrk;
	_mrk_pos = markerPos _mrk;

	diag_log text format ["OCAPLOG: SERVER: Received data from %1 with param %2 -- 
%3", _mrk_owner, _eventType, _this];
	switch (_eventType) do {

		case "CREATED": {
			
			diag_log text format ["OCAPLOG: SERVER: Enter CREATED process of %1 from %2 -- 
%3", _mrk, _mrk_owner, _mrk call BIS_fnc_markerToString];
			if (_mrk in ocap_markers_tracked || _mrk_type == "") exitWith {};

			diag_log text format ["OCAPLOG: SERVER: Valid CREATED process of marker from %1, continuing -- 
%2", _mrk_owner, _mrk call BIS_fnc_markerToString];

			ocap_markers_tracked pushBack _mrk;
			_mrk_color = getarray (configfile >> "CfgMarkerColors" >> _mrk_color_str >> "color") call bis_fnc_colorRGBtoHTML;

			if (isNil "_mrk_color") then {
				_mrk_color = "#000000";
			};

			if (((side _mrk_owner) call BIS_fnc_sideID) == 4) then {
				diag_log format["Side ID was unknown for %1", _mrk];
			};
			diag_log text format ["OCAPLOG: SERVER: Valid CREATED process of %1, sending to extension -- 
%2", _mrk, _mrk call BIS_fnc_markerToString];
			[":MARKER:CREATE:", [_mrk, 0, _mrk_type, _mrk_text, ocap_captureFrameNo, -1, _mrk_owner getVariable ["ocap_id", 0], _mrk_color, [1,1], (side _mrk_owner) call BIS_fnc_sideID, _mrk_pos]] call ocap_fnc_extension;



			// if (isNull _mrk_owner) then {
			// 	[":MARKER:CREATE:", [_mrk, 0, _mrk_type, _mrk_text, ocap_captureFrameNo, -1, 0, _mrk_color, [1,1], 7, _mrk_pos]] call ocap_fnc_extension;
			// };
		};

		case "UPDATED": {
// 			diag_log format ["OCAPLOG: SERVER: Enter UPDATED process of %1 from %2 -- 
// %3", _mrk, _mrk_owner, _mrk call BIS_fnc_markerToString];

			if (_mrk in ocap_markers_tracked) then {
// 				diag_log format ["OCAPLOG: SERVER: Valid UPDATED process of %1, sending to extension -- 
// %2", _mrk, _mrk call BIS_fnc_markerToString];
				[":MARKER:MOVE:", [_mrk, ocap_captureFrameNo, _mrk_pos]] call ocap_fnc_extension;
			};
		};

		case "DELETED": {
// diag_log format ["OCAPLOG: SERVER: Enter DELETED process of %1 from %2 -- 
// %3", _mrk_info, _mrk_owner, _mrk call BIS_fnc_markerToString];

			if (_mrk_info in ocap_markers_tracked) then {
// 				diag_log format ["OCAPLOG: SERVER: Valid DELETED process of %1, sending to extension -- 
// %2", _mrk_info, _mrk call BIS_fnc_markerToString];
				[":MARKER:DELETE:", [_mrk_info, ocap_captureFrameNo]] call ocap_fnc_extension;
				ocap_markers_tracked = ocap_markers_tracked - [_mrk_info];
			};
			deleteMarkerLocal _mrk;
		};
	};
}] call CBA_fnc_addEventHandler;