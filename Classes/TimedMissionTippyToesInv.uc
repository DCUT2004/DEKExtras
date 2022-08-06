class TimedMissionTippyToesInv extends TimedMissionInv;

function bool CheckMissionCondition()
{
	if (Instigator == None)
		return false;
	return !(VSize(Instigator.Velocity) ~= 0);
}

defaultproperties
{
}
