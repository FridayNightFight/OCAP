// while clients don't have to run the addon, the below is necessary to handle the locality of markers in A3. since the server can't see user defined (player placed markers) or markers created by script that are local to clients, the below will remoteexec their existence to the server for processing.

{
		_mrk_name = _x;
		_marker = _x;
		_mrk_color_str = markerColor _marker;
		_mrk_color = getarray (configfile >> "CfgMarkerColors" >> _mrk_color_str >> "color") call bis_fnc_colorRGBtoHTML;
		_mrk_type = markerType _marker;
		_mrk_text = markerText _marker;
		_mrk_pos = markerPos _marker;
		_mrk_owner = allPlayers select 0;

		if (_mrk_type == "Empty" || _mrk_type == "") exitWith {};

		_createdMarker = [
			_mrk_name,
			_mrk_color_str,
			_mrk_color,
			_mrk_type,
			_mrk_text,
			_mrk_pos,
			_mrk_owner
			];

		["CREATE", _createdMarker] remoteExec ["ocap_fnc_handleMarkers", 2];

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

		if (_mrk_type == "Empty" || _mrk_type == "") exitWith {};

		_createdMarker = [
			_mrk_name,
			_mrk_color_str,
			_mrk_color,
			_mrk_type,
			_mrk_text,
			_mrk_pos,
			_mrk_owner
			];
		
		["CREATE", _createdMarker] remoteExec ["ocap_fnc_handleMarkers", 2];
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
		
		["MOVE", _createdMarker] remoteExec ["ocap_fnc_handleMarkers", 2];
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

		if (_mrk_pos select 0 == 0) exitWith {};

		_createdMarker = [
			_mrk_name,
			_mrk_color_str,
			_mrk_color,
			_mrk_type,
			_mrk_text,
			_mrk_pos
			];
		
		["DELETE", _createdMarker] remoteExec ["ocap_fnc_handleMarkers", 2];
	}];