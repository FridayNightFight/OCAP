ocap_markers_tracked = []; // Markers which we saves into replay

// create CBA event handler to be called on server
ocap_markers_handle = ["ocap_handleMarker", {

	params["_eventType", "_mrk_name", "_mrk_owner","_pos", "_type", "_shape", "_size", "_dir", "_brush", "_color", "_alpha", "_text", "_forceGlobal"];


	diag_log text format["OCAPLOG: SERVER: Received data --
%1 ",_this];

	switch (_eventType) do {

		case "CREATED":{

			"debug_console" callExtension (format["OCAPLOG: SERVER: Entered CREATED %1 with details:
dir: %2
color: %3
type: %4
text: %5
pos: %6
size: %7
shape: %8",
_mrk_name,
_dir,
_color,
_type,
_text,
_pos,
_size,
_shape
]);

			// if (_mrk in ocap_markers_tracked || _mrk_type == "") exitWith {};

			diag_log text format["OCAPLOG: SERVER: Valid CREATED process of marker from %1 for ""%2""", _mrk_owner, _mrk_name];

			if (_type isEqualTo "") then {_type = "nullType"};
			ocap_markers_tracked pushBackUnique _mrk_name;

			_mrk_color = getarray (configfile >> "CfgMarkerColors" >> _color >> "color") call bis_fnc_colorRGBtoHTML;


			private ["_sideOfMarker"];
			if (_mrk_owner isEqualTo objNull) then {
				_forceGlobal = true;
				_mrk_owner = -1;
				_sideOfMarker = -1;
			} else {
				_sideOfMarker = (side _mrk_owner) call BIS_fnc_sideID;
				_mrk_owner = _mrk_owner getVariable["ocap_id", 0];
			};

			if (_sideOfMarker isEqualTo 4 || 
			(["Projectile#", _mrk_name] call BIS_fnc_inString) || 
			(["Detonation#", _mrk_name] call BIS_fnc_inString) || 
			(["Mine#", _mrk_name] call BIS_fnc_inString) ||
			(["ObjectMarker", _mrk_name] call BIS_fnc_inString) ||
			(["moduleCoverMap", _mrk_name] call BIS_fnc_inString) ||
			(!isNil "_forceGlobal")) then {_sideOfMarker = -1;};

			private ["_polylinePos"];
			if (count _pos > 2) then {
				_polylinePos = [];
				for [{_i = 0}, {_i < ((count _pos) - 1)}, {_i = _i + 1}] do {
					_polylinePos pushBack [_pos # (_i), _pos # (_i + 1)];
					_i = _i + 1;
				};
				_pos = _polylinePos;
			};

			if (isNil "_dir") {
				_dir = 0;
			};
			if (_dir == "") then {_dir = 0};
			


			diag_log text format["OCAPLOG: SERVER: Valid CREATED process of %1, sending to extension --
%2 ", _mrk_name, [_mrk_name, _dir, _type, _text, ocap_captureFrameNo, -1, _mrk_owner, _mrk_color, _size, _sideOfMarker, _pos, _shape]];

			[":MARKER:CREATE:", [_mrk_name, _dir, _type, _text, ocap_captureFrameNo, -1, _mrk_owner, _mrk_color, _size, _sideOfMarker, _pos, _shape]] call ocap_fnc_extension;

		};

		case "UPDATED":{

			// diag_log format ["OCAPLOG: SERVER: Enter UPDATED process of %1 from %2 --
			// %3", _mrk, _mrk_owner, _mrk call BIS_fnc_markerToString];

			if (_mrk_name in ocap_markers_tracked) then {
				// 				diag_log format ["OCAPLOG: SERVER: Valid UPDATED process of %1, sending to extension --
				// %2", _mrk, _mrk call BIS_fnc_markerToString];
				[":MARKER:MOVE:", [_mrk_name, ocap_captureFrameNo, _pos, _dir, _alpha]] call ocap_fnc_extension;
			};
		};

		case "DELETED":{
			// diag_log format ["OCAPLOG: SERVER: Enter DELETED process of %1 from %2 --
			// %3", _mrk_info, _mrk_owner, _mrk call BIS_fnc_markerToString];

			if (_mrk_name in ocap_markers_tracked) then {
				// 				diag_log format ["OCAPLOG: SERVER: Valid DELETED process of %1, sending to extension --
				// %2", _mrk_info, _mrk call BIS_fnc_markerToString];
				[":MARKER:DELETE:", [_mrk_name, ocap_captureFrameNo]] call ocap_fnc_extension;
				ocap_markers_tracked = ocap_markers_tracked - [_mrk_name];
			};
		};
	};
}] call CBA_fnc_addEventHandler;





// handle created markers
{
	addMissionEventHandler["MarkerCreated", {
		params["_marker", "_channelNumber", "_owner", "_local"];

		if (!_local) exitWith {};

		_pos = markerPos _marker;
		_type = markerType _marker;
		_shape = markerShape _marker;
		_size = markerSize _marker;
		_dir = markerDir _marker;
		_brush = markerBrush _marker;
		_color = markerColor _marker;
		_text = markerText _marker;
		_alpha = markerAlpha _marker;
		_polyline = markerPolyline _marker;
		if (count _polyline != 0) then {
			_pos = _polyline;
		} else {
			_pos resize 2;
		};

		diag_log text format["OCAPLOG: Sending data from %1 with param CREATED and name ""%2""", _owner, _marker];

		// "_eventType", "_mrk_name", "_mrk_owner","_pos", "_type", "_shape", "_size", "_dir", "_brush", "_color", "_alpha", "_text", "_forceGlobal"
		["ocap_handleMarker", ["CREATED", _marker, _owner, _pos, _type, _shape, _size, _dir, _brush, _color, _alpha, _text]] call CBA_fnc_serverEvent;
	}];

	// handle marker moves/updates
	addMissionEventHandler["MarkerUpdated", {
		params["_marker", "_local"];

		if (!_local) exitWith {};
		diag_log text format["OCAPLOG: Sent data from %1 with param UPDATED and name ""%2""", player, _marker];
		// "_eventType", "_mrk_name", "_mrk_owner","_pos", "_type", "_shape", "_size", "_dir", "_brush", "_color", "_alpha", "_text", "_forceGlobal"
		["ocap_handleMarker", ["UPDATED", _marker, player, markerPos _marker, "", "", "", markerDir _marker, "", "", markerAlpha _marker]] call CBA_fnc_serverEvent;
	}];

	// handle marker deletions
	addMissionEventHandler["MarkerDeleted", {
		params["_marker", "_local"];

		if (!_local) exitWith {};
		diag_log text format["OCAPLOG: Sent data from %1 with param DELETED and name ""%2""", player, _marker];

		// "_eventType", "_mrk_name", "_mrk_owner","_pos", "_type", "_shape", "_size", "_dir", "_brush", "_color", "_alpha", "_text", "_forceGlobal"
		["ocap_handleMarker", ["DELETED", _marker, player]] call CBA_fnc_serverEvent;
	}];
} remoteExec["call", 0, true];



// wait 10 seconds for any scripted init markers to finalize
// then collect all initial markers & add event handlers to clients
[
	{count allPlayers > 0},
	{
		_exclude = [
			"bis_fnc_moduleCoverMap_0",
			"bis_fnc_moduleCoverMap_90",
			"bis_fnc_moduleCoverMap_180",
			"bis_fnc_moduleCoverMap_270",
			"bis_fnc_moduleCoverMap_border",
			"respawn",
			"respawn_west",
			"respawn_east",
			"respawn_guerrila",
			"respawn_civilian"
		];
		// _randomizedOwner = allPlayers # 0;
		_randomizedOwner = objNull;
		{
			_marker = _x;
			// "Started polling starting markers" remoteExec ["hint", 0];
			// get intro object markers
			_pos = markerPos _marker;
			_type = markerType _marker;
			_shape = markerShape _marker;
			_size = markerSize _marker;
			_dir = markerDir _marker;
			_brush = markerBrush _marker;
			_color = markerColor _marker;
			_text = markerText _marker;
			_alpha = markerAlpha _marker;
			_polyline = markerPolyline _marker;
			if (count _polyline != 0) then {
				_pos = _polyline;
			} else {
				_pos resize 2;
			};

			if (isNil "_dir") then {_dir = 0};

			// if (["ObjectMarker", _marker] call BIS_fnc_inString) then {
			// 	_type = "ObjectMarker";
			// 	_colour = "ColorBlack";
			// };
			if (["moduleCoverMap_dot", _marker] call BIS_fnc_inString) then {
				_type = "moduleCoverMap";
				_colour = "ColorBlack";
			};
			// if (["safeMarker", _marker] call BIS_fnc_inString) then {
			// 	_type = "safeStart";
			// 	_colour = "ColorBlack";
			// };
			
			_forceGlobal = true;

			// "_eventType", "_mrk_name", "_mrk_owner","_pos", "_type", "_shape", "_size", "_dir", "_brush", "_color", "_alpha", "_text", "_forceGlobal"
			["ocap_handleMarker", ["CREATED", _marker, objNull, _pos, _type, _shape, _size, _dir, _brush, _color, _alpha, _text, _forceGlobal]] call CBA_fnc_localEvent;

			// ["ocap_handleMarker", ["CREATED", _marker, _randomizedOwner, _position, _type, _shape, _size, _dir, _brush, _colour, 1, _text, _forceGlobal]] call CBA_fnc_localEvent;
			// "debug_console" callExtension (str [_marker, _randomizedOwner, _pos, _type, _shape, _size, _dir, _brush, _color, 1, _text, _forceGlobal] + "#0100");

		} forEach (allMapMarkers);
	}
] call CBA_fnc_waitUntilAndExecute;