class PoisonedZombie extends NecroMortalSkeleton
	config(satoreMonsterPack);

var int PoisonLevel;
var config int PoisonDamagePerLevel;
var Controller Necromancer;
var PoisonedZombieInv ZombieInv;

function PoisonTarget(Actor Victim)
{
	local PlagueInv Inv;
	local Pawn P;
	local MagicShieldInv MInv;

	P = Pawn(Victim);
	if (P != None)
	{
		MInv = MagicShieldInv(P.FindInventoryType(class'MagicShieldInv'));
		if (MInv == None)
		{
			Inv = PlagueInv(P.FindInventoryType(class'PlagueInv'));
			if (Inv == None)
			{
				Inv = spawn(class'PlagueInv', P,,, rot(0,0,0));
				Inv.Necromancer = Necromancer;
				Inv.FatalPlague = false;
				Inv.PlagueDamage = PoisonLevel*PoisonDamagePerLevel;
				Inv.GiveTo(P);
			}
			else
			{
				//Target alredy has Plague
				if (Inv.Necromancer != Necromancer)	//Target has a plague produced by another Necromancer. Let's add on as an infector
				{
					if (Inv.InfectorOne == None)
						Inv.InfectorOne = Necromancer.Pawn;
					else if (Inv.InfectorTwo == None)
						Inv.InfectorTwo = Necromancer.Pawn;
					else if (Inv.InfectorThree == None)
						Inv.InfectorThree = Necromancer.Pawn;
				}
			}
		}
	}
}

function bool MeleeDamageTarget(int hitdamage, vector pushdir)
{
	PoisonTarget(Controller.Target);
	
	return Super.MeleeDamageTarget(hitdamage, pushdir);
}

simulated function Destroyed()
{
	if (ZombieInv != None)
		ZombieInv.NumZombies--;
	if (ZombieInv.NumZombies < 0)
		ZombieInv.NumZombies = 0;
	Super.Destroyed();
}

defaultproperties
{
	 Health=200
	 PoisonDamagePerLevel=3
     ClawDamage=10
     GroundSpeed=510.000000
     WaterSpeed=180.000000
     AirSpeed=510.000000
     JumpZ=210.000000
}
