params ["_function",["_params",[],[[]]]];

switch (_function) do {
	case "INIT": {
		diag_log ["INIT"];
		
		ocap_markers_tracked = []; // Markers which we saves into replay

		["SWT_fnc_createMarker", { ["CREATE",_this] call ocap_fnc_handleMarkers; }] call CBA_fnc_addEventHandler;
		["SWT_fnc_removeMarker", { ["DELETE",_this] call ocap_fnc_handleMarkers; }] call CBA_fnc_addEventHandler;
		["SWT_fnc_moveMarker", { ["MOVE",_this] call ocap_fnc_handleMarkers; }] call CBA_fnc_addEventHandler;


	};
	case "CREATE" : {
		// handle SWT_fnc_createMarker
		_params params ["_pl","_arr"];
		_arr params ["_mname", "_side", "_mtext", "_mpos","_type","_color","_dir","","_author"];
		if (_type >= 0 && _side == "S") then {
			ocap_markers_tracked pushBack _mname;
				private _mrk_color = getarray (configfile >> "CfgMarkerColors" >> (swt_cfgMarkerColors_names select _color) >> "color") call bis_fnc_colorRGBtoHTML;
				if !(_mrk_color isEqualType "") then {
					[":LOG:", ["ERROR",__FILE__, _color, swt_cfgMarkerColors_names select _color,getarray (configfile >> "CfgMarkerColors" >> (swt_cfgMarkerColors_names select _color) >> "color")]] call ocap_fnc_extension;
					_mrk_color = "#000000";
				};
			[":MARKER:CREATE:", [_mname, 0, swt_cfgMarkers_names select _type, _mtext, ocap_captureFrameNo, -1, _pl getVariable ["ocap_id", 0],
				_mrk_color, [1,1], side _pl call BIS_fnc_sideID, _mpos]] call ocap_fnc_extension;
		};
	};
	case "DELETE" : {
		_params params ["_mname","_pl"];
		// handle SWT_fnc_removeMarker
		if (_mname in ocap_markers_tracked) then {
			[":MARKER:DELETE:", [_mname, ocap_captureFrameNo]] call ocap_fnc_extension;
			ocap_markers_tracked = ocap_markers_tracked - [_mname];
		};

	};
	case "MOVE" : {
		_params params ["_mname", "_coord"];
		if (_mname in ocap_markers_tracked) then {
			[":MARKER:MOVE:", [_mname, ocap_captureFrameNo, _coord]] call ocap_fnc_extension;
		};
	};
	default {
		diag_log [__FILE__,"unknown function",_function, _params];
	 };
};