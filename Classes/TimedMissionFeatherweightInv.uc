class TimedMissionFeatherweightInv extends TimedMissionInv;

function bool CheckMissionCondition()
{
	if (Instigator == None)
		return false;
	if (Instigator.Weapon != None && Instigator.Weapon.IsA('Translauncher') || Vehicle(Instigator) != None || Instigator.Physics != PHYS_Falling)
		return false;
	if (Instigator.Physics == PHYS_Falling)
		return true;
}

defaultproperties
{
}
