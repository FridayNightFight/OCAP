// params ["_function",["_params",[],[[]]]];
params ["_function","_params"];

switch (_function) do {
	case "INIT": {
		// diag_log ["INIT"];
		
		ocap_markers_tracked = []; // Markers which we saves into replay

		// ["SWT_fnc_createMarker", { ["CREATE",_this] call ocap_fnc_handleMarkers; }] call CBA_fnc_addEventHandler;
		// ["SWT_fnc_removeMarker", { ["DELETE",_this] call ocap_fnc_handleMarkers; }] call CBA_fnc_addEventHandler;
		// ["SWT_fnc_moveMarker", { ["MOVE",_this] call ocap_fnc_handleMarkers; }] call CBA_fnc_addEventHandler;


		// handle all markers from editor, created on init
		{
			_mrk_name = _x;
			_marker = _x;
			_mrk_color_str = markerColor _marker;
			_mrk_color = getarray (configfile >> "CfgMarkerColors" >> _mrk_color_str >> "color") call bis_fnc_colorRGBtoHTML;
			_mrk_type = markerType _marker;
			_mrk_text = markerText _marker;
			_mrk_pos = markerPos _marker;
			_mrk_owner = allPlayers select 0;

			_createdMarker = [
				_mrk_name,
				_mrk_color_str,
				_mrk_color,
				_mrk_type,
				_mrk_text,
				_mrk_pos,
				_mrk_owner
				];

			["CREATE", _createdMarker] call ocap_fnc_handleMarkers;

		} forEach allMapMarkers;
		
		// handle server-side created markers
		addMissionEventHandler ["MarkerCreated", {
			params ["_marker", "_channelNumber", "_owner", "_local"];
			_mrk_name = _marker;
			_mrk_color_str = markerColor _marker;
			_mrk_color = getarray (configfile >> "CfgMarkerColors" >> _mrk_color_str >> "color") call bis_fnc_colorRGBtoHTML;
			_mrk_type = markerType _marker;
			_mrk_text = markerText _marker;
			_mrk_pos = markerPos _marker;
			_mrk_owner = _owner;

			_createdMarker = [
				_mrk_name,
				_mrk_color_str,
				_mrk_color,
				_mrk_type,
				_mrk_text,
				_mrk_pos,
				_mrk_owner
				];
			
			["CREATE", _createdMarker] call ocap_fnc_handleMarkers;
		}];

		// handle marker moves/updates
		addMissionEventHandler ["MarkerUpdated", {
			params ["_marker", "_local"];
			_mrk_name = _marker;
			_mrk_color_str = markerColor _marker;
			_mrk_color = getarray (configfile >> "CfgMarkerColors" >> _mrk_color_str >> "color") call bis_fnc_colorRGBtoHTML;
			_mrk_type = markerType _marker;
			_mrk_text = markerText _marker;
			_mrk_pos = markerPos _marker;

			_createdMarker = [
				_mrk_name,
				_mrk_color_str,
				_mrk_color,
				_mrk_type,
				_mrk_text,
				_mrk_pos
				];
			
			["MOVE", _createdMarker] call ocap_fnc_handleMarkers;
		}];
		
		// handle marker deletions
		addMissionEventHandler ["MarkerDeleted", {
			params ["_marker", "_local"];
			_mrk_name = _marker;
			_mrk_color_str = markerColor _marker;
			_mrk_color = getarray (configfile >> "CfgMarkerColors" >> _mrk_color_str >> "color") call bis_fnc_colorRGBtoHTML;
			_mrk_type = markerType _marker;
			_mrk_text = markerText _marker;
			_mrk_pos = markerPos _marker;

			_createdMarker = [
				_mrk_name,
				_mrk_color_str,
				_mrk_color,
				_mrk_type,
				_mrk_text,
				_mrk_pos
				];
			
			["DELETE", _createdMarker] call ocap_fnc_handleMarkers;
		}];

		diag_log ["initialized marker system"];


	};
	case "CREATE" : {
		// handle SWT_fnc_createMarker
		// _params params ["_pl","_arr"];
		// _arr params ["_mname", "_side", "_mtext", "_mpos","_type","_color","_dir","","_author"];
		// if (_type >= 0 && _side == "S") then {
		// 	ocap_markers_tracked pushBack _mname;
		// 		private _mrk_color = getarray (configfile >> "CfgMarkerColors" >> (swt_cfgMarkerColors_names select _color) >> "color") call bis_fnc_colorRGBtoHTML;
		// 		if !(_mrk_color isEqualType "") then {
		// 			[":LOG:", ["ERROR",__FILE__, _color, swt_cfgMarkerColors_names select _color,getarray (configfile >> "CfgMarkerColors" >> (swt_cfgMarkerColors_names select _color) >> "color")]] call ocap_fnc_extension;
		// 			_mrk_color = "#000000";
		// 		};
		// 	[":MARKER:CREATE:", [_mname, 0, swt_cfgMarkers_names select _type, _mtext, ocap_captureFrameNo, -1, _pl getVariable ["ocap_id", 0],
		// 		_mrk_color, [1,1], side _pl call BIS_fnc_sideID, _mpos]] call ocap_fnc_extension;
		// };

		_params params ["_mrk_name","_mrk_color_str","_mrk_color","_mrk_type","_mrk_text","_mrk_pos","_mrk_owner"];
		if (_mrk_name in ocap_markers_tracked || _mrk_type == "Empty" || _mrk_type == "") exitWith {};
		ocap_markers_tracked pushBack _mrk_name;

		if (isNil "_mrk_color" || _mrk_type == "hd_objective" || _mrk_type == "mil_objective") then {
			_mrk_color = "#000000";
		};

		// diag_log "Processing marker details marker creation";

		// diag_log "Processing extension marker creation";
		// diag_log str _mrk_type;
		[":MARKER:CREATE:", [_mrk_name, 0, _mrk_type, _mrk_text, ocap_captureFrameNo, -1, _mrk_owner getVariable ["ocap_id", 0], _mrk_color, [1,1], side _mrk_owner call BIS_fnc_sideID, _mrk_pos]] call ocap_fnc_extension;

		// ["Processed marker creation on server"] remoteExec ["hint", _mrk_owner];

		// diag_log "Processed marker creation";
		// diag_log str _params;

	};
	case "DELETE" : {
		// _params params ["_mname","_pl"];
		_params params ["_mrk_name","_mrk_color_str","_mrk_color","_mrk_type","_mrk_text","_mrk_pos"];

		// handle SWT_fnc_removeMarker
		// if (_mname in ocap_markers_tracked) then {
		// 	[":MARKER:DELETE:", [_mname, ocap_captureFrameNo]] call ocap_fnc_extension;
		// 	ocap_markers_tracked = ocap_markers_tracked - [_mname];
		// };

		if (_mrk_name in ocap_markers_tracked) then {
			[":MARKER:DELETE:", [_mrk_name, ocap_captureFrameNo]] call ocap_fnc_extension;
			ocap_markers_tracked = ocap_markers_tracked - [_mrk_name];
		};

		// diag_log "Processed marker deletion";
		// diag_log str _params;

	};
	case "MOVE" : {
		// _params params ["_mname", "_coord"];
		_params params ["_mrk_name","_mrk_color_str","_mrk_color","_mrk_type","_mrk_text","_mrk_pos"];
		if (_mrk_type == "Empty") exitWith {};
		_newCoord = _mrk_pos;

		// if (_mname in ocap_markers_tracked) then {
		// 	[":MARKER:MOVE:", [_mname, ocap_captureFrameNo, _coord]] call ocap_fnc_extension;
		// };

		if (_mrk_name in ocap_markers_tracked) then {
			[":MARKER:MOVE:", [_mrk_name, ocap_captureFrameNo, _newCoord]] call ocap_fnc_extension;
		};

		// diag_log "Processed marker move";
		// diag_log str _params;
	};
	default {
		diag_log [__FILE__,"unknown function",_function, _params];
	 };
};