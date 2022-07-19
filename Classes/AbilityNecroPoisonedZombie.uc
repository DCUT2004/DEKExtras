class AbilityNecroPoisonedZombie extends CostRPGAbility
	config(UT2004RPG)
	abstract;
	
var config int PoisonMageLevel;
	
static simulated function ModifyPawn(Pawn Other, int AbilityLevel)
{
	local PoisonedZombieInv M;
	local PlagueSpreader Inv;
	local PoisonShieldInv PInv;
	local ArtifactMakePoisonInfinity A;

	if (Other.Role != ROLE_Authority || Other.Controller == None || !Other.Controller.bIsPlayer)
		return;
		
	Inv = PlagueSpreader(Other.FindInventoryType(class'PlagueSpreader'));
	if (Inv == None)
	{
		Inv = Other.Spawn(class'DEKRPG999X.PlagueSpreader', Other);
		Inv.GiveTo(Other);
	}


	M = PoisonedZombieInv(Other.FindInventoryType(class'PoisonedZombieInv'));
	if (M != None)
	{
		if (M.AbilityLevel != AbilityLevel)
		{
			M.AbilityLevel = AbilityLevel;
		}
		return;
	}

	M = Other.spawn(class'PoisonedZombieInv', Other,,,rot(0,0,0));
	M.AbilityLevel = AbilityLevel;
	M.GiveTo(Other);
	
	if (AbilityLevel >= default.PoisonMageLevel)
	{
		if (M != None)
			M.MaxZombies = M.default.MaxZombies + 1;
		PInv = PoisonShieldInv(Other.FindInventoryType(class'PoisonShieldInv'));
		A = ArtifactMakePoisonInfinity(Other.FindInventoryType(class'ArtifactMakePoisonInfinity'));
		if (A == None)
		{
			A = Other.Spawn(class'ArtifactMakePoisonInfinity');
			A.GiveTo(Other);
		}
		if (PInv == None)
		{
			PInv = Other.Spawn(class'PoisonShieldInv');
			PInv.GiveTo(Other);
		}
	}
}

static function HandleDamage(out int Damage, Pawn Injured, Pawn Instigator, out vector Momentum, class<DamageType> DamageType, bool bOwnedByInstigator, int AbilityLevel)
{
	// need to check that summoned monsters do not get xp for not doing damage to same species
	local DEKFriendlyMonsterController C;
	
	if (Instigator == None || Injured == None)
		return;

	if(!bOwnedByInstigator)
	{   // this is hitting a pet, so the pet will not get xp.
	    // while we are here, let's make sure the pet is not hurt by the spawner. This is a deliberate ommission in RPGRules
		C = DEKFriendlyMonsterController(injured.Controller);
		if (C != None && C.Master != None && C.Master == Instigator.Controller)
		{
			Damage *= TeamGame(injured.Level.Game).FriendlyFireScale;
		}
		return;
 	}

	if (Monster(Instigator) == None || Monster(Injured) == None)
		return;
		
	// now know this is damage done by a monster on a pet
	if ( Monster(Injured).SameSpeciesAs(Instigator) )
		Damage = 0;
}

defaultproperties
{
     PoisonMageLevel=7
     AbilityName="Poisoned Zombie"
     Description="Summons a Poisoned Zombie pet.||Attacks from a zombie will give a plague infection to its target. Enemies that come near the plague will become infected, and infected enemies can also infect other enemies.||You can also help spread the plague by standing near a plague cloud for several seconds. Once obtained, you can spread the plague by coming into contact with enemies.||Each level of this ability increases the plague damage from a zombie by 3 per level.||Poison Mage level 7 summons an extra zombie, provides you with resistance against poison ailments, and grants you a Poisoned Infinity maker.||Cost (per level): 5,10,15,20..."
     StartingCost=5
     CostAddPerLevel=5
     MaxLevel=10
}
