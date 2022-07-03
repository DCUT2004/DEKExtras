class PoisonedZombieInv extends Inventory
	config(UT2004RPG);
	
var int AbilityLevel;
var int NumZombies;
var config int MaxZombies;
	
function PostBeginPlay()
{
	Super.PostBeginPlay();
	NumZombies = 0;
	SetTimer(10.0, true);
}

function GiveTo(Pawn Other, optional Pickup Pickup)
{
	Super.GiveTo(Other, Pickup);
}

function Timer()
{
	local Vector SpawnLocation;
	local Rotator SpawnRotation;
	local Monster Zombie;
	
	if (Instigator == None || Instigator.Health <= 0 || Instigator.Controller == None)
	{
		Destroy();
		return;
	}

	if (NumZombies >= MaxZombies)
		return;
	SpawnLocation = getSpawnLocation(class'PoisonedZombie');
	SpawnRotation = getSpawnRotator(SpawnLocation);
	Zombie = SpawnZombie(SpawnLocation, SpawnRotation);
	if (Zombie != None)
		NumZombies++;
}

function vector getSpawnLocation(Class<Monster> ChosenMonster)
{
	local float Dist, BestDist;
	local vector SpawnLocation;
	local NavigationPoint N, BestDest;

	BestDist = 50000.f;
	for (N = Level.NavigationPointList; N != None; N = N.NextNavigationPoint)
	{
		Dist = VSize(N.Location - Instigator.Location);
		if (Dist < BestDist && Dist > ChosenMonster.default.CollisionRadius * 2)
		{
			BestDest = N;
			BestDist = VSize(N.Location - Instigator.Location);
		}
	}

	if (BestDest != None)
		SpawnLocation = BestDest.Location + (ChosenMonster.default.CollisionHeight - BestDest.CollisionHeight) * vect(0,0,1);
	else
		SpawnLocation = Instigator.Location + ChosenMonster.default.CollisionHeight * vect(0,0,1.5); //is this why monsters spawn on heads?

	return SpawnLocation;	
}

function rotator getSpawnRotator(Vector SpawnLocation)
{
	local rotator SpawnRotation;

	SpawnRotation.Yaw = rotator(SpawnLocation - Instigator.Location).Yaw;
	return SpawnRotation;
}

function Monster SpawnZombie(Vector SpawnLocation, Rotator SpawnRotation)
{
	local PoisonedZombie M;
	local FriendlyMonsterInv FriendlyInv;
	local DEKFriendlyMonsterController FMC;
	local Inventory Inv;
	local RPGStatsInv StatsInv;
	local int x;
	
	M = spawn(Class'PoisonedZombie',,, SpawnLocation, SpawnRotation);

	if (M != None)
	{
		if (M.Controller != None)
			M.Controller.Destroy();

		FriendlyInv = M.spawn(class'FriendlyMonsterInv');

		if(FriendlyInv == None)
			M.Destroy();
		FriendlyInv.MasterPRI = Instigator.Controller.PlayerReplicationInfo;
		FriendlyInv.Skill = 7.000;
		FriendlyInv.giveTO(M);
		
		FMC = spawn(class'DEKFriendlyMonsterController',,, SpawnLocation, SpawnRotation);
		if(FMC == None)
		{
			FriendlyInv.Destroy();
			M.Destroy();
		}
		FMC.Possess(M); //do not call InitializeSkill before this line.
		FMC.SetMaster(Instigator.Controller);
		FMC.InitializeSkill(7);
		
		M.SummonedMonster = true;
		M.PoisonLevel = AbilityLevel;
		M.Necromancer = Instigator.Controller;
		M.ZombieInv = self;
		
		//allow Instigator's abilities to affect the monster
		for (Inv = Instigator.Controller.Inventory; Inv != None; Inv = Inv.Inventory)
		{
			StatsInv = RPGStatsInv(Inv);
			if (StatsInv != None)
				break;
		}
		if (StatsInv == None) //fallback, should never happen
			StatsInv = RPGStatsInv(Instigator.FindInventoryType(class'RPGStatsInv'));
		if (StatsInv != None) //this should always be the case
		{
			for (x = 0; x < StatsInv.Data.Abilities.length; x++)
			{
				if(ClassIsChildOf(StatsInv.Data.Abilities[x], class'MonsterAbility'))
					class<MonsterAbility>(StatsInv.Data.Abilities[x]).static.ModifyMonster(M, StatsInv.Data.AbilityLevels[x]);
				else
					StatsInv.Data.Abilities[x].static.ModifyPawn(M, StatsInv.Data.AbilityLevels[x]);
			}

			if (FMC.Inventory == None) //should never be the case.
				FMC.Inventory = StatsInv;
			else
			{
				for (Inv = FMC.Inventory; Inv.Inventory != None; Inv = Inv.Inventory)
				{}
				Inv.Inventory = StatsInv;
			}
		}
		return M;
	}
	return None;
}

simulated function Destroyed()
{
	local Controller C, NextC;
	local PoisonedZombie Zombie;
	
	C = Level.ControllerList;
	while (C != None)
	{
		NextC = C.NextController;
		if (C.Pawn != None && C.Pawn.Health > 0 && C.Pawn.IsA('PoisonedZombie'))
		{
			Zombie = PoisonedZombie(C.Pawn);
			if (Zombie.ZombieInv == Self || Zombie.Necromancer == Instigator.Controller)
			{
				Zombie.Died(Zombie.Controller, class'DamageType', Vect(0,0,0));
			}
			
		}
		C = NextC;
	}
	
	Super.Destroyed();
}

defaultproperties
{
	MaxZombies=1
}
