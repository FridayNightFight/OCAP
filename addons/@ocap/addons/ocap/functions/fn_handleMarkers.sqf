// params ["_function",["_params",[],[[]]]];


params ["_function"];

if (_function == "INIT") then {
	// diag_log ["INIT"];
	
	ocap_markers_tracked = []; // Markers which we saves into replay

	{
		// handle created markers
		addMissionEventHandler ["MarkerCreated", {
			params ["_marker", "_channelNumber", "_owner", "_local"];

			if (!_local) exitWith {};
			["fnf_ocap_handleMarker", ["CREATED", _marker call BIS_fnc_markerToString, player]] call CBA_fnc_serverEvent;
		}];

		// handle marker moves/updates
		addMissionEventHandler ["MarkerUpdated", {
			params ["_marker", "_local"];

			if (!_local) exitWith {};
			["fnf_ocap_handleMarker", ["UPDATED", _marker call BIS_fnc_markerToString, player]] call CBA_fnc_serverEvent;
		}];

		// handle marker moves/updates
		addMissionEventHandler ["MarkerDeleted", {
			params ["_marker", "_local"];

			if (!_local) exitWith {};
			["fnf_ocap_handleMarker", ["DELETED", _marker call BIS_fnc_markerToString, player]] call CBA_fnc_serverEvent;
		}];
	} remoteExec ["call", 0, true];

};





_ocap_markers_handle = ["fnf_ocap_handleMarker", {

	params ["_eventType","_mrk_info","_mrk_owner"];

	_mrk = _mrk_info call BIS_fnc_stringToMarkerLocal;
	_mrk_color_str = markerColor _marker;
	_mrk_color = getarray (configfile >> "CfgMarkerColors" >> _mrk_color_str >> "color") call bis_fnc_colorRGBtoHTML;
	_mrk_type = markerType _marker;
	_mrk_text = markerText _marker;
	_mrk_pos = markerPos _marker;

	switch (_eventType) do {

		case "CREATED": {
			
			if (_mrk in ocap_markers_tracked || _mrk_type == "Empty" || _mrk_type == "") exitWith {};

			ocap_markers_tracked pushBack _mrk;
			_mrk_color = getarray (configfile >> "CfgMarkerColors" >> _mrk_color_str >> "color") call bis_fnc_colorRGBtoHTML;

			_ignoreColorMrkTypes = ["hd_objective","mil_objective","hd_flag","mil_flag"];
			if (isNil "_mrk_color" || _mrk_type in _ignoreMrkType ) then {
				_mrk_color = "#000000";
			};

			if ((side _mrk_owner) call BIS_fnc_sideID == 4) then {
				diag_log format["Side ID was unknown for %1", _mrk];
			};
			[":MARKER:CREATE:", [_mrk, 0, _mrk_type, _mrk_text, ocap_captureFrameNo, -1, _mrk_owner getVariable ["ocap_id", 0], _mrk_color, [1,1], (side _mrk_owner) call BIS_fnc_sideID, _mrk_pos]] call ocap_fnc_extension;



			// if (isNull _mrk_owner) then {
			// 	[":MARKER:CREATE:", [_mrk, 0, _mrk_type, _mrk_text, ocap_captureFrameNo, -1, 0, _mrk_color, [1,1], 7, _mrk_pos]] call ocap_fnc_extension;
			// };
		};

		case "UPDATED": {
			if (_mrk in ocap_markers_tracked) then {
				[":MARKER:MOVE:", [_mrk, ocap_captureFrameNo, _mrk_pos]] call ocap_fnc_extension;
			};
		};

		case "DELETED": {

			if (_mrk in ocap_markers_tracked) then {
				[":MARKER:DELETE:", [_mrk, ocap_captureFrameNo]] call ocap_fnc_extension;
				ocap_markers_tracked = ocap_markers_tracked - [_mrk];
			};
			deleteMarkerLocal _mrk;
		};
	};
}] call CBA_fnc_addEventHandler;