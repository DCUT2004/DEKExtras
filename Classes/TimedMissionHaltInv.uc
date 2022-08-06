class TimedMissionHaltInv extends TimedMissionInv;

function GiveTo(Pawn Other, optional Pickup Pickup)
{
	Super.GiveTo(Other);
	if (Instigator != None)
		Instigator.SetPhysics(PHYS_NONE);
}

function Tick(float deltaTime)
{
	if (Instigator != None)
	{
		if(!class'DEKRPGWeapon'.static.NullCanTriggerPhysics(Instigator))
			return;

		if(Instigator.Physics != PHYS_NONE)
			Instigator.setPhysics(PHYS_NONE);
	}
}

function bool CheckMissionCondition()
{
	if (Instigator == None)
		return false;
	if (Instigator.Physics != PHYS_None || Vehicle(Instigator) != None && Vehicle(Instigator).Driver == Instigator)
		return false;
	if (Instigator.Physics == PHYS_None)
		return true;
}

simulated function Destroyed()
{
	disable('Tick');
	if(Instigator != None && Instigator.Physics == PHYS_NONE)
		Instigator.SetPhysics(PHYS_Falling);
	Super.Destroyed();
}

defaultproperties
{
}
