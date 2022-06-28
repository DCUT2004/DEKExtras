class ArtifactPossess extends EnhancedRPGArtifact
		config(UT2004RPG);

var RPGRules Rules;
var config float PossessRange;
var class<xEmitter> HitEmitterClass;
var config Array< class<Monster> > InvalidMonster, ValidMonster, BannedMonsters;
var int AbilityLevel;
var config int MaxAdrenaline, MaxPoints;
var Monster M;

function BotConsider()
{
	if ( !bActive && NoArtifactsActive() && FRand() < 0.3 && BotFireBeam())
		Activate();
}

function bool BotFireBeam()
{
	local Vector FaceDir;
	local Vector BeamEndLocation;
	local Vector StartTrace;
	local vector HitLocation;
	local vector HitNormal;
	local Pawn  HitPawn;
	local Actor AHit;

	FaceDir = Vector(Instigator.Controller.GetViewRotation());
	StartTrace = Instigator.Location + Instigator.EyePosition();
	BeamEndLocation = StartTrace + (FaceDir * PossessRange);

	AHit = Trace(HitLocation, HitNormal, BeamEndLocation, StartTrace, true);
	if ((AHit == None) || (Pawn(AHit) == None) || (Pawn(AHit).Controller == None))
		return false;

	HitPawn = Pawn(AHit);
	if ( HitPawn != Instigator && HitPawn.Health > 0 && !HitPawn.Controller.SameTeamAs(Instigator.Controller)
		&& VSize(HitPawn.Location - StartTrace) < PossessRange && HitPawn.Controller.bGodMode == False)
	{
		return true;
	}

	return false;
}

simulated function Activate()
{
	local Vehicle V;
	local Vector FaceDir;
	local Vector BeamEndLocation;
	local vector HitLocation;
	local vector HitNormal;
	local Actor AHit;
	local Pawn  HitPawn;
	local Vector StartTrace;
	local Monster Mo;
	local MonsterPointsInv MP;
	local xEmitter HitEmitter;
	local int PointsRequired, x;
	local PossessFX FX1, FX2;
	
	Super(EnhancedRPGArtifact).Activate();

	if ((Instigator == None) || (Instigator.Controller == None))
	{
		bActive = false;
		GotoState('');
		return;	// really corrupt
	}

	if (LastUsedTime  + (TimeBetweenUses*AdrenalineUsage) > Instigator.Level.TimeSeconds)
	{
		Instigator.ReceiveLocalizedMessage(MessageClass, 5000, None, None, Class);
		bActive = false;
		GotoState('');
		return;	// cannot use yet
	}

	V = Vehicle(Instigator);
	if (V != None )
	{
		Instigator.ReceiveLocalizedMessage(MessageClass, 3000, None, None, Class);
		bActive = false;
		GotoState('');
		return;	// can't use in a vehicle
	}
	
	//We should already have MP;
	MP = MonsterPointsInv(Instigator.FindInventoryType(class'MonsterPointsInv'));
	if (MP == None)
	{
		bActive = false;
		GotoState('');
		return;	//what?
	}
	
	// lets see what we hit then
	FaceDir = Vector(Instigator.Controller.GetViewRotation());
	StartTrace = Instigator.Location + Instigator.EyePosition();
	BeamEndLocation = StartTrace + (FaceDir * PossessRange);

	// See if we hit something.
	AHit = Trace(HitLocation, HitNormal, BeamEndLocation, StartTrace, true);
	if ((AHit == None) || (Pawn(AHit) == None) || (Pawn(AHit).Controller == None))
	{
		bActive = false;
		GotoState('');
		return;
	}
	
	if (M != None && M.Health > 0)
	{
		Instigator.ReceiveLocalizedMessage(MessageClass, 6000, None, None, Class);
		bActive = false;
		GotoState('');
		return;
	}

	HitPawn = Pawn(AHit);
	if ( HitPawn != Instigator && HitPawn.Health > 0 && HitPawn.IsA('Monster') && !HitPawn.Controller.SameTeamAs(Instigator.Controller)
	     && VSize(HitPawn.Location - StartTrace) < PossessRange && !HitPawn.IsA('HealerNali') && !HitPawn.IsA('MissionCow'))
	{
		Mo = Monster(HitPawn);
		for(x = 0; x < default.BannedMonsters.length; x++)	//check for monsters not allowed
		{
			if (Mo.class == default.BannedMonsters[x])
			{
				Instigator.ReceiveLocalizedMessage(MessageClass, 8000, None, None, Class);
				bActive = false;
				GotoState('');
				return;	// this monster is not allowed
				break;				
			}
		}
		for(x = 0; x < default.InvalidMonster.length; x++)
		{
			if (Mo.class == default.InvalidMonster[x])	//we have a match and we can spawn the monster, but we need to make an exception
			{
				AdrenalineRequired = Mo.ScoringValue*10;
				if (AdrenalineRequired > default.MaxAdrenaline)
					AdrenalineRequired = default.MaxAdrenaline;
				PointsRequired = Mo.ScoringValue;
				if (PointsRequired > default.MaxPoints)
					PointsRequired = default.MaxPoints;
				if (AdrenalineRequired > Instigator.Controller.Adrenaline)
				{
					Instigator.ReceiveLocalizedMessage(MessageClass, AdrenalineRequired*AdrenalineUsage, None, None, Class);
					bActive = false;
					GotoState('');
					return;
					break;
				}
				if (PointsRequired > (MP.TotalMonsterPoints - MP.UsedMonsterPoints))
				{
					Instigator.ReceiveLocalizedMessage(MessageClass, 7000, None, None, Class);
					bActive = false;
					GotoState('');
					return;
					break;
				}
				if (AbilityLevel < PointsRequired)
				{
					Instigator.ReceiveLocalizedMessage(MessageClass, 9000, None, None, Class);
					bActive = false;
					GotoState('');
					return;		
					break;
				}
				M = MP.SummonMonster(default.ValidMonster[x], AdrenalineRequired, PointsRequired);
				if (M != None)
				{
					//First, kill the monster
					FX1 = Mo.spawn(class'PossessFX', Mo,, Mo.Location, Mo.Rotation);
					Mo.Died(Instigator.Controller, class'DamTypePossess', HitPawn.Location);
					Mo.SetCollision(false,false,false);
					Mo.bHidden = true;
					FX2 = M.spawn(class'PossessFX', M,, M.Location, M.Rotation);
					HitEmitter = spawn(HitEmitterClass,,, (StartTrace + Instigator.Location)/2, rotator(HitLocation - ((StartTrace + Instigator.Location)/2)));
					if (HitEmitter != None)
					{
						HitEmitter.mSpawnVecA = Mo.Location;
					}
					Instigator.PlaySound(Sound'XEffects.LightningSound', SLOT_None, 400.0);
					SetRecoveryTime(TimeBetweenUses*AdrenalineUsage);
					Mo = None;
					AdrenalineRequired = 0;
					PointsRequired = 0;
				}
				else
				{
					bActive = false;
					GotoState('');
					return;	// didn't hit an enemy
					break;
				}
				bActive = false;
				GotoState('');
				return;
				break;
			}
		}	//otherwise, this will handle most other monsters
		if (Mo != None)
		{
			AdrenalineRequired = Mo.ScoringValue*10;
			if (AdrenalineRequired > default.MaxAdrenaline)
				AdrenalineRequired = default.MaxAdrenaline;
			PointsRequired = Mo.ScoringValue;
			if (PointsRequired > default.MaxPoints)
				PointsRequired = default.MaxPoints;
			if (AdrenalineRequired > Instigator.Controller.Adrenaline)
			{
				Instigator.ReceiveLocalizedMessage(MessageClass, AdrenalineRequired*AdrenalineUsage, None, None, Class);
				bActive = false;
				GotoState('');
				return;
			}
			if (PointsRequired > (MP.TotalMonsterPoints - MP.UsedMonsterPoints))
			{
				Instigator.ReceiveLocalizedMessage(MessageClass, 7000, None, None, Class);
				bActive = false;
				GotoState('');
				return;
			}
			if (AbilityLevel < PointsRequired)
			{
				Instigator.ReceiveLocalizedMessage(MessageClass, 9000, None, None, Class);
				bActive = false;
				GotoState('');
				return;			
			}
		}
		//Summon that monster
		M = MP.SummonMonster(Mo.Class, AdrenalineRequired, PointsRequired);
		if (M != None)
		{
			//First, kill the monster
			FX1 = Mo.spawn(class'PossessFX', Mo,, Mo.Location, Mo.Rotation);
			Mo.Died(Instigator.Controller, class'DamTypePossess', HitPawn.Location);
			Mo.SetCollision(false,false,false);
			Mo.bHidden = true;
			FX2 = M.spawn(class'PossessFX', M,, M.Location, M.Rotation);
			HitEmitter = spawn(HitEmitterClass,,, (StartTrace + Instigator.Location)/2, rotator(HitLocation - ((StartTrace + Instigator.Location)/2)));
			if (HitEmitter != None)
			{
				HitEmitter.mSpawnVecA = HitPawn.Location;
			}
			Instigator.PlaySound(Sound'XEffects.LightningSound', SLOT_None, 400.0);
			SetRecoveryTime(TimeBetweenUses*AdrenalineUsage);
			Mo = None;
			AdrenalineRequired = 0;
			PointsRequired = 0;
		}
		else
		{
			bActive = false;
			GotoState('');
			return;	// didn't hit an enemy			
		}
	}
	bActive = false;
	GotoState('');
	return;
}

static function string GetLocalString(optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2)
{
	if (Switch == 3000)
		return "Cannot use this artifact inside a vehicle.";
	else if (Switch == 5000)
		return "Cannot use this artifact again yet.";
	else if (Switch == 6000)
		return "You currently have a possessed monster.";
	else if (Switch == 7000)
		return "Insufficent monster points available to possess this monster.";
	else if (Switch == 8000)
		return "Possessing this particular monster is not allowed.";
	else if (Switch == 9000)
		return "You are not a high enough level to possess this monster.";
	else
		return switch @ "adrenaline required for this monster.";
}

exec function TossArtifact()
{
	//do nothing. This artifact cant be thrown
}

function DropFrom(vector StartLocation)
{
	if (bActive)
		GotoState('');
	bActive = false;

	Destroy();
	Instigator.NextItem();
}

defaultproperties
{
     PossessRange=4000.000000
     HitEmitterClass=Class'DEKExtras209D.PossessBoltFX'
     InvalidMonster(0)=Class'DEKMonsters209D.DCGiantGasbag'
     InvalidMonster(1)=Class'DEKMonsters209D.DCQueen'
     InvalidMonster(2)=Class'DEKMonsters209D.FireGiantGasbag'
     InvalidMonster(3)=Class'DEKMonsters209D.IceGiantGasbag'
     InvalidMonster(4)=Class'DEKMonsters209D.PoisonQueen'
     InvalidMonster(5)=Class'DEKMonsters209D.NecroMortalSkeleton'
     InvalidMonster(6)=Class'DEKMonsters209D.EarthGiantGasbag'
     InvalidMonster(7)=Class'DEKMonsters209D.EarthQueen'
     InvalidMonster(8)=Class'DEKMonsters209D.FireQueen'
     InvalidMonster(9)=Class'DEKMonsters209D.IceQueen'
     ValidMonster(0)=Class'DEKMonsters209D.PossessedGreaterGasbag'
     ValidMonster(1)=Class'DEKMonsters209D.PossessedPrincess'
     ValidMonster(2)=Class'DEKMonsters209D.PossessedFireGreaterGasbag'
     ValidMonster(3)=Class'DEKMonsters209D.PossessedIceGreaterGasbag'
     ValidMonster(4)=Class'DEKMonsters209D.PossessedPoisonPrincess'
     ValidMonster(5)=Class'DEKMonsters209D.PetImmortalSkeleton'
     ValidMonster(6)=Class'DEKMonsters209D.PossessedEarthGreaterGasbag'
     ValidMonster(7)=Class'DEKMonsters209D.EarthPrincess'
     ValidMonster(8)=Class'DEKMonsters209D.FirePrincess'
     ValidMonster(9)=Class'DEKMonsters209D.IcePrincess'
     BannedMonsters(0)=Class'DEKMonsters209D.DCNaliFighter'
     BannedMonsters(1)=Class'DEKMonsters209D.FireNaliFighter'
     BannedMonsters(2)=Class'DEKMonsters209D.IceNaliFighter'
     BannedMonsters(3)=Class'DEKMonsters209D.NecroGhostExp'
     BannedMonsters(4)=Class'DEKMonsters209D.NecroGhostIllusion'
     BannedMonsters(5)=Class'DEKMonsters209D.NecroGhostMisfortune'
     BannedMonsters(6)=Class'DEKMonsters209D.NecroGhostPoltergeist'
     BannedMonsters(7)=Class'DEKMonsters209D.NecroGhostPriest'
     BannedMonsters(8)=Class'DEKMonsters209D.NecroGhostShaman'
     BannedMonsters(9)=Class'DEKMonsters209D.NecroSorcerer'
     BannedMonsters(10)=Class'DEKMonsters209D.RPGNali'
     BannedMonsters(11)=Class'DEKMonsters209D.TechSlith'
     BannedMonsters(12)=Class'DEKMonsters209D.TechSlug'
     BannedMonsters(13)=Class'DEKMonsters209D.TechTitan'
     BannedMonsters(14)=Class'DEKMonsters209D.VampireGnat'
     BannedMonsters(15)=Class'DEKMonsters209D.NecroGhostPossessor'
     BannedMonsters(16)=Class'DEKMonsters209D.GiantCosmicBunny'
     BannedMonsters(17)=Class'DEKMonsters209D.GiantIceBunny'
     BannedMonsters(18)=Class'DEKMonsters209D.GiantPoisonBunny'
     BannedMonsters(19)=Class'DEKMonsters209D.GiantRageBunny'
     BannedMonsters(20)=Class'DEKMonsters209D.GiantShockBunny'
     BannedMonsters(21)=Class'DEKMonsters209D.GiantWarBunny'
     BannedMonsters(22)=Class'DEKBossMonsters209D.DEKLucifer'
     BannedMonsters(23)=Class'DEKBossMonsters209D.DEKGlass'
     BannedMonsters(24)=Class'DEKBossMonsters209D.DEKTentator'
     BannedMonsters(25)=Class'DEKBossMonsters209D.DEKAldebaran'
     BannedMonsters(26)=Class'DEKBossMonsters209D.IceNaliBoss'
     BannedMonsters(27)=Class'DEKBossMonsters209D.Gaia'
     BannedMonsters(28)=Class'DEKBossMonsters209D.DEKGlassClone'
     MaxAdrenaline=250
     maxpoints=15
     TimeBetweenUses=20.000000
     MinActivationTime=0.000001
     IconMaterial=FinalBlend'AS_FX_TX.Icons.OBJ_Hold_FB'
     ItemName="Possess"
}
