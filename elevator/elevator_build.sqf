private ["_args","_option","_obj","_id","_elevatorStop","_dist"];

if (DZE_ActionInProgress) exitWith { cutText ["Upgrade already in progress." , "PLAIN DOWN"]; };
DZE_ActionInProgress = true;

player removeAction s_player_elevator_upgrade;
s_player_elevator_upgrade = 1;
player removeAction s_player_elevator_upgrade_stop;
s_player_elevator_upgrade_stop = 1;

// check for near plot
_canBuildOnPlot = false;
_distance = DZE_PlotPole select 0;
_needText = localize "str_epoch_player_246";
_findNearestPoles = nearestObjects [(vehicle player), ["Plastic_Pole_EP1_DZ"], _distance];
_findNearestPole = [];


{
if (alive _x) then {
_findNearestPole set [(count _findNearestPole),_x];
};
} foreach _findNearestPoles;


_IsNearPlot = count (_findNearestPole);


if(_IsNearPlot == 0) then {
_canBuildOnPlot = true;
} else {
// Since there are plots nearby we check for ownership and then for friend status 
// check nearby plots ownership and then for friend status
_nearestPole = _findNearestPole select 0;
// Find owner 
_ownerID = _nearestPole getVariable["CharacterID","0"];
// diag_log format["DEBUG BUILDING: %1 = %2", dayz_characterID, _ownerID];
// check if friendly to owner
if(dayz_characterID == _ownerID) then {  //Keep ownership
// owner can build anything within his plot except other plots
_canBuildOnPlot = true; 
} else {
_friendlies = player getVariable ["friendlyTo",[]];
// check if friendly to owner
if(_ownerID in _friendlies) then {
_canBuildOnPlot = true;
};
};
};
if(!_canBuildOnPlot) exitWith {  DZE_ActionInProgress = false; cutText [format[(localize "STR_EPOCH_PLAYER_135"),_needText,_distance] , "PLAIN DOWN"]; };

_args = _this select 3;
_option = _args select 0;
switch (_option) do {
	case "build": {
		_obj = _args select 1;
		_id = [_obj] call ELE_fnc_generateElevatorId;
		if (_id == "") exitWith { cutText ["invalid elevator ID generated", "PLAIN"] };
		if ((ELE_RequiredBuildTools call AC_fnc_hasTools) && {ELE_RequiredBuildItems call AC_fnc_checkAndRemoveRequirements}) then {
			["Medic", ELE_MaxRange] call AC_fnc_doAnimationAndAlertZombies;
			ELE_elevator = [_obj, _id] call AC_fnc_swapObject;
			titleText ["Elevator Built", "PLAIN"];
		};
	};
	case "build_stop": {
		_obj = _args select 1;
		if (isNil "ELE_elevator") exitWith { cutText ["no elevator selected", "PLAIN"] };
		_dist = _obj distance ELE_elevator;
		if (_dist > ELE_MaxRange) exitWith { cutText [format["Elevator Stop is to far away from Elevator (%1 > %2)", _dist, ELE_MaxRange], "PLAIN"] };
		_id = [ELE_elevator] call ELE_fnc_getNextStopId;
		if (_id == "") exitWith { cutText ["Elevator Stop already exists or to many (max. 9 per Elevator)", "PLAIN"] };
		if ((ELE_RequiredBuildTools call AC_fnc_hasTools) && {ELE_RequiredBuildStopItems call AC_fnc_checkAndRemoveRequirements}) then {
			["Medic", ELE_MaxRange] call AC_fnc_doAnimationAndAlertZombies;
			_elevatorStop = [_obj, _id, ELE_StopClass] call AC_fnc_swapObject;
			titleText ["Elevator Stop Built", "PLAIN"];
		};
	};
};

DZE_ActionInProgress = false;
s_player_elevator_upgrade = -1;
s_player_elevator_upgrade_stop = -1;
