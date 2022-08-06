class TimedMissionHexedInv extends TimedMissionInv;

function bool CheckMissionCondition()
{
	local Vehicle V;
	
	if (Instigator == None)
		return false;
	V = Vehicle(Instigator);
	if (V == None)
		Instigator.TakeDamage(5, Instigator, Instigator.Location, vect(0,0,0), class'DamTypeHex');
	else
		V.Driver.TakeDamage(5, V.Driver, V.Driver.Location, vect(0,0,0), class'DamTypeHex');
	return true;
}

defaultproperties
{
}
