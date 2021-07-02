trackThrows = ["ace_throwableThrown", {
    _this spawn {

        params["_unit", "_projectile"];

        if (isNull _projectile) then {
            _projectile = nearestObject [_unit, "CA_Magazine"];
        };

        // systemChat str _this;

        // note that thrown objects outside of ACE explosives do not include a "default magazine" property in their config.
        // this script will attempt to find a matching classname in CfgMagazines, as some chemlights and smokes are built this way.
        // if not found, a default magazine value will be assigned (m67 frag, white smoke, green chemlight)

        _projType = typeOf _projectile;
        _projConfig = configOf _projectile;
        _projName = getText(configFile >> "CfgAmmo" >> _projType >> "displayName");

        // systemChat format["Config name: %1", configOf _projectile];

        _ammoSimType = getText(configFile >> "CfgAmmo" >> _projType >> "simulation");
        // systemChat format["Projectile type: %1", _ammoSimType];

        _markerType = "";
        _markColor = "";
        _magDisp = "";
        _magPic = "";

        _magType = getText(_projConfig >> "defaultMagazine");
        if (_magType == "") then {
            _magType = configName(configfile >> "CfgMagazines" >> _projType)
        };

        if (!(_magType isEqualTo "")) then {
            // systemChat format["Mag type: %1", _magType];

            _magDisp = getText(configFile >> "CfgMagazines" >> _magType >> "displayNameShort");
            if (_magDisp == "") then {
                _magDisp = getText(configFile >> "CfgMagazines" >> _magType >> "displayName")
            };
            if (_magDisp == "") then {
                _magDisp = _projName;
            };

            _magPic = (getText(configfile >> "CfgMagazines" >> _magType >> "picture"));
            // hint parseText format["Projectile fired:<br/><img image='%1'/>", _magPic];
            if (_magPic == "") then {
                _markerType = "mil_triangle";
                _markColor = "ColorRed";
            } else {
                _magPicSplit = _magPic splitString "\";
                _magPic = _magPicSplit#((count _magPicSplit) - 1);
                _markerType = format["magIcons/%1", _magPic];
                _markColor = "ColorWhite";
            };
        } else {
            _markerType = "mil_triangle";
            _markColor = "ColorRed";
            // set defaults based on ammo sim type, if no magazine could be matched
            switch (_ammoSimType) do {
                case "shotGrenade":{
                        _magPic = "\A3\Weapons_F\Data\UI\gear_M67_CA.paa";
                        _magDisp = "Frag";
                    };
                case "shotSmokeX":{
                        _magPic = "\A3\Weapons_f\data\ui\gear_smokegrenade_white_ca.paa";
                        _magDisp = "Smoke";
                    };
                case "shotIlluminating":{
                        _magPic = "\A3\Weapons_F\Data\UI\gear_flare_white_ca.paa";
                        _magDisp = "Flare";
                    };
                default {
                    _magPic = "\A3\Weapons_F\Data\UI\gear_M67_CA.paa";
                    _magDisp = "Frag";
                };
            };
            // hint parseText format["Projectile fired:<br/><img image='%1'/>", _magPic];
            _magPicSplit = _magPic splitString "\";
            _magPic = _magPicSplit#((count _magPicSplit) - 1);
            _markerType = format["magIcons/%1", _magPic];
            _markColor = "ColorWhite";
        };




        if (!(_ammoSimType isEqualTo "shotBullet")) then {

			_int = random 2000;
			
            _markTextLocal = format["%1", _magDisp];
            _markName = format["Projectile#%1", _int];

			_throwerPos = getPos _unit;
			_throwerPos resize 2;
			
			["ocap_handleMarker", ["CREATED", _markName, _unit, _throwerPos, _markerType, "ICON", [1,1], 0, "Solid", _markColor, 1, _markTextLocal, true]] call CBA_fnc_serverEvent;

            private _lastPos = [];
			waitUntil {
				_pos = getPosATL _projectile;
				if (((_pos select 0) isEqualTo 0) || isNull _projectile) exitWith {
					true
				};
				_lastPos = _pos;
				["ocap_handleMarker", ["UPDATED", _markName, _unit, [_pos # 0, _pos # 1], 0, 1]] call CBA_fnc_serverEvent;
                sleep 0.1;
                false;
			};

            if !((count _lastPos) isEqualTo 0) then {
                // if (count _lastPos == 3) then {
                _lastPos resize 2;
                ["ocap_handleMarker", ["UPDATED", _markName, _unit, _lastPos, 0, 1]] call CBA_fnc_serverEvent;
            };

            sleep 10;
            ["ocap_handleMarker", ["DELETED", _markName]] call CBA_fnc_serverEvent;
        };
    };
}] call CBA_fnc_addEventHandler;