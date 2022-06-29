class AbilityNecroPoisonedZombie extends CostRPGAbility
	config(UT2004RPG)
	abstract;
	
static simulated function ModifyPawn(Pawn Other, int AbilityLevel)
{
	local PoisonedZombieInv M;

	if (Other.Role != ROLE_Authority || Other.Controller == None || !Other.Controller.bIsPlayer)
		return;


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
     AbilityName="Poisoned Zombie"
     Description="Summons up to two Poisoned Zombies. Attacks from a zombie will give a poison similar to the Plague ability to its target.||Each level of this ability increases the plague damage from a zombie by 3 per level.||Cost (per level): 5,10,15,20..."
     StartingCost=5
     CostAddPerLevel=5
     MaxLevel=10
}
