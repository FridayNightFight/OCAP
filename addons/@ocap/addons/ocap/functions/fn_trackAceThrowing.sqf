trackThrows = ["ace_throwableThrown", {
    _this spawn {

        params["_unit", "_projectile"];

        // systemChat str _this;

        // limits trigger to only thrown short-fuse ACE explosives, instead of also counting chemlights/frags/smokes
        // note that thrown objects outside of ACE explosives do not include a "default magazine" property in their config.
        // this script will attempt to find a matching classname in CfgMagazines, as some chemlights and smokes are built this way.
        // if not found, a default magazine value will be assigned (m67 frag, white smoke, green chemlight)

        // systemChat str call compile "_projectile isKindOf ""ACE_SatchelCharge_Remote_Ammo_Thrown""";
        // if (!(_projectile isKindOf "ACE_SatchelCharge_Remote_Ammo_Thrown")) exitWith {};

        _projType = typeOf _projectile;
        _projConfig = configOf _projectile;
        _projName = getText(configFile >> "CfgAmmo" >> _projType >> "displayName");

        systemChat format["Config name: %1", configOf _projectile];

        _ammoSimType = getText(configFile >> "CfgAmmo" >> _projType >> "simulation");
        systemChat format["Projectile type: %1", _ammoSimType];

        _markerType = "";
        _markColor = "";
        _magDisp = "";
        _magPic = "";

        _magType = getText(_projConfig >> "defaultMagazine");
        if (_magType == "") then {
            _magType = configName(configfile >> "CfgMagazines" >> _projType)
        };

        if (!(_magType isEqualTo "")) then {
            systemChat format["Mag type: %1", _magType];

            _magDisp = getText(configFile >> "CfgMagazines" >> _magType >> "displayNameShort");
            if (_magDisp == "") then {
                _magDisp = getText(configFile >> "CfgMagazines" >> _magType >> "displayName")
            };
            if (_magDisp == "") then {
                _magDisp = _projName;
            };

            _magPic = (getText(configfile >> "CfgMagazines" >> _magType >> "picture"));
            hint parseText format["Projectile fired:<br/><img image='%1'/>", _magPic];
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
            hint parseText format["Projectile fired:<br/><img image='%1'/>", _magPic];
            _magPicSplit = _magPic splitString "\";
            _magPic = _magPicSplit#((count _magPicSplit) - 1);
            _markerType = format["magIcons/%1", _magPic];
            _markColor = "ColorWhite";
        };




        if (!(_ammoSimType isEqualTo "shotBullet")) then {

			_int = random 2000;
			
            // non-bullet handling
            _markTextLocal = format["%1", _magDisp];
            _markName = format["Projectile#%1", _int];
            _markStr = format["|%1|%2|%3|%4|%5|%6|%7|%8|%9|%10",
                _markName,
                _throwerPosRaw,
                "mil_triangle",
                "ICON", [1, 1],
                0,
                "Solid",
                _markColor,
                1,
                _markTextLocal
            ];
            _markStr call BIS_fnc_stringToMarker;

			_throwerPosRaw = getPos _unit;
			_throwerPos = parseSimpleArray (format["[%1,%2]", _throwerPosRaw # 0, _throwerPosRaw # 1]);
			
			["fnf_ocap_handleMarker", ["CREATED", _markName, _unit, _throwerPos, _markerType, "ICON", [1,1], 0, "Solid", _markColor, 1, _markTextLocal]] call CBA_fnc_localEvent;

            private _lastPos = [];
			waitUntil {
				_pos = getPosATL _projectile;
				if (((_pos select 0) isEqualTo 0) || isNull _projectile) exitWith {
					true
				};
				_lastPos = _pos;
				["fnf_ocap_handleMarker", ["UPDATED", _markName, _unit, [_pos # 0, _pos # 1]]] call CBA_fnc_localEvent;
				false;
			};
        };
    };
}] call CBA_fnc_addEventHandler;