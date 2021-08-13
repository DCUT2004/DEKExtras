class AbilityMissions extends CostRPGAbility
	config(UT2004RPG)
	abstract;
	
var config float NullifyIceDamageChance;
var config float NullifyFireDamageChance;
var config float NullifyEarthDamageChance;
var config int GenomeMaxDamage;
var config Array < class < Monster > > BoneMonsters;
var config Array < class < Monster > > GhostMonsters;
var config Array < class < Monster > > TechMonsters;
var config Array < class < Monster > > CosmicMonsters;

static function ScoreKill(Controller Killer, Controller Killed, bool bOwnedByKiller, int AbilityLevel)
{
	local MissionInv Inv;
	local Mission1Inv M1Inv;
	local Mission2Inv M2Inv;
	local Mission3Inv M3Inv;
	local MissionMultiplayerHUDInv MMPI;
	local Weapon W;
	local Monster M;
	local NecroSorcererResurrectedInv ZombieInv;
	local NecroGhostPossessorMonsterInv PossessorInv;
	local Pawn P;
	local int x;
	
	if (!bOwnedByKiller)
		return;
		
	if ( Killed == P || Killed == None || Killed.Pawn == None || Killer.Pawn == None || Killed.Level == None || Killed.Level.Game == None)
		return;
		
	P = Killer.Pawn;
	
	if (P != None && P.IsA('Vehicle'))
		P = Vehicle(P).Driver;
	
	if (P != None)
	{
		Inv = MissionInv(P.FindInventoryType(class'MissionInv'));
		M1Inv = Mission1Inv(P.FindInventoryType(class'Mission1Inv'));
		M2Inv = Mission2Inv(P.FindInventoryType(class'Mission2Inv'));
		M3Inv = Mission3Inv(P.FindInventoryType(class'Mission3Inv'));
		MMPI = MissionMultiplayerHUDInv(P.FindInventoryType(class'MissionMultiplayerHUDInv'));
		ZombieInv = NecroSorcererResurrectedInv(Killed.Pawn.FindInventoryType(class'NecroSorcererResurrectedInv'));
		PossessorInv = NecroGhostPossessorMonsterInv(Killed.Pawn.FindInventoryType(class'NecroGhostPossessorMonsterInv'));
	}
		
	M = Monster(Killed.Pawn);
	
	if (RPGWeapon(P.Weapon) != None)
		W = RPGWeapon(P.Weapon).ModifiedWeapon;
	else
		W = P.Weapon;
	
	if (Killer != None && P != None && Killed != None && Killed.Pawn != None && !Killed.SameTeamAs(Killer))
	{
		//Kills Not Allowed.
		if (M != None && M.ControllerClass == class'DEKFriendlyMonsterController')
			return;
		if (Killed.Pawn.IsA('HealerNali') || Killed.Pawn.IsA('MissionCow'))
			return;
			
		//Team Missions
		if (MMPI != None && !MMPI.Stopped)
		{
			if (MMPI.MusicalWeaponsActive)
			{
				if (MMPI.ActiveWeapon != None && W != None)
				{
					if (W.Class == MMPI.ActiveWeapon)
						MMPI.UpdateCount(1);
					if (RPGWeapon(P.Weapon) != None && RPGWeapon(P.Weapon).IsA('RW_EngineerLink') && MMPI.ActiveWeapon == class'RPGLinkGun')
						MMPI.UpdateCount(1);			
				}
			}
		}
			
		//M1
		if (M1Inv != None && !M1Inv.Stopped)
		{
			if (M1Inv.AquamanActive && !Inv.AquamanComplete)
			{
				if (P.PhysicsVolume.bWaterVolume && P.Physics == PHYS_Swimming)
				{
					M1Inv.MissionCount++;
				}
			}
			else if (M1Inv.BoneCrusherActive && !Inv.BoneCrusherComplete)
			{
				for (x = 0; x < default.BoneMonsters.Length; x++)
				{
					if (M.Class == default.BoneMonsters[x])
					{
						M1Inv.MissionCount++;
						break;
					}
				}
			}
			else if (M1Inv.BugHuntActive && !Inv.BugHuntComplete)
			{
				if (!M.IsA('NecroSkull') && (ClassIsChildOf(M.Class, class'SkaarjPupae') || ClassIsChildOf(M.Class, class'Razorfly') || ClassIsChildOf(M.Class, class'Manta') || ClassIsChildOf(M.Class, class'Tarantula')))
				{
						M1Inv.MissionCount++;					
				}
			}
			else if (M1Inv.KrallHuntActive && !Inv.KrallHuntComplete)
			{
				if (ClassIsChildOf(M.Class, class'Krall') || ClassIsChildOf(M.Class, class'DCKrall'))
				{
					M1Inv.MissionCount++;
				}
			}
			else if (M1Inv.GhostBusterActive && !Inv.GhostBusterComplete)
			{
				for (x = 0; x < default.GhostMonsters.Length; x++)
				{
					if (M.Class == default.GhostMonsters[x])
					{
						M1Inv.MissionCount++;
						break;
					}
				}
			}
			else if (M1Inv.GlacialHuntActive && !Inv.GlacialHuntComplete)
			{
				if (IceInv(M.FindInventoryType(class'IceInv')) != None)
				M1Inv.MissionCount++;
			}
			else if (M1Inv.NaniteCrashActive && !Inv.NaniteCrashComplete)
			{
				for (x = 0; x < default.TechMonsters.Length; x++)
				{
					if (M.Class == default.TechMonsters[x])
					{
						M1Inv.MissionCount++;
						break;
					}
				}
			}
			else if (M1Inv.RootedStanceActive && !Inv.RootedStanceComplete)
			{
				if (VSize(P.Velocity) ~= 0)
				{
					M1Inv.MissionCount++;
				}
			}
			else if (M1Inv.SharpShotFlyActive && !Inv.SharpShotFlyComplete)
			{
				if (M.IsA('VampireGnat') && (SniperRifle(W) != None || ClassicSniperRifle(W) != None || DEKRailGun(W) != None ))
				{
					M1Inv.MissionCount++;
				}
			}
			else if (M1Inv.SkaarjHuntActive && !Inv.SkaarjHuntComplete)
			{
				if (ClassIsChildOf(M.Class, class'Skaarj') || ClassIsChildOf(M.Class, class'FireSkaarj') || ClassIsChildOf(M.Class, class'IceSkaarj') || ClassIsChildOf(M.Class, class'SMPSkaarjSniper') || ClassIsChildOf(M.Class, class'SMPSkaarjTrooper'))
				{
					M1Inv.MissionCount++;
				}
			}
			else if (M1Inv.SpidermanActive && !Inv.SpidermanComplete)
			{
				if (P.Physics == PHYS_Spider)
				{
					M1Inv.MissionCount++;
				}
			}
			else if (M1Inv.StarHuntActive && !Inv.StarHuntComplete)
			{
				for (x = 0; x < default.CosmicMonsters.Length; x++)
				{
					if (M.Class == default.CosmicMonsters[x])
					{
						M1Inv.MissionCount++;
						break;
					}
				}
			}
			else if (M1Inv.SupermanActive && !Inv.SupermanComplete)
			{
				if (P.Physics == PHYS_Flying || P.Physics == PHYS_Falling)
				{
					M1Inv.MissionCount++;
				}
			}
			else if (M1Inv.VolcanicHuntActive && !Inv.VolcanicHuntComplete)
			{
				if (FireInv(M.FindInventoryType(class'FireInv')) != None)
				M1Inv.MissionCount++;
			}
			else if (M1Inv.ForestHuntActive && !Inv.ForestHuntComplete)
			{
				if (EarthInv(M.FindInventoryType(class'EarthInv')) != None)
				M1Inv.MissionCount++;
			}
			else if (M1Inv.WarlordHuntActive && !Inv.WarlordHuntComplete)
			{
				if (ClassIsChildOf(M.Class, class'Warlord') || ClassIsChildOf(M.Class, class'DCWarlord'))
				{
					M1Inv.MissionCount++;
				}
			}
			else if (M1Inv.ZombieSlayerActive && !Inv.ZombieSlayerComplete)
			{
				if (ZombieInv != None)
				{
					M1Inv.MissionCount++;
				}
			}
			else if (M1Inv.EmeraldShatterActive && !Inv.EmeraldShatterComplete)
			{
				if (PossessorInv != None)
				{
					M1Inv.MissionCount++;
				}
				if (Killed.Pawn.IsA('NecroGhostPossessor'))
				{
					M1Inv.MissionCount++;
					M1Inv.MissionCount++;
				}
			}
		}
		//M2
		if (M2Inv != None && !M2Inv.Stopped)
		{
			if (M2Inv.AquamanActive && !Inv.AquamanComplete)
			{
				if (P.PhysicsVolume.bWaterVolume && P.Physics == PHYS_Swimming)
				{
					M2Inv.MissionCount++;
				}
			}
			else if (M2Inv.BoneCrusherActive && !Inv.BoneCrusherComplete)
			{
				for (x = 0; x < default.BoneMonsters.Length; x++)
				{
					if (M.Class == default.BoneMonsters[x])
					{
						M2Inv.MissionCount++;
						break;
					}
				}
			}
			else if (M2Inv.KrallHuntActive && !Inv.KrallHuntComplete)
			{
				if (ClassIsChildOf(M.Class, class'Krall') || ClassIsChildOf(M.Class, class'DCKrall'))
				{
					M2Inv.MissionCount++;
				}
			}
			else if (M2Inv.BugHuntActive && !Inv.BugHuntComplete)
			{
				if (!M.IsA('NecroSkull') && (ClassIsChildOf(M.Class, class'SkaarjPupae') || ClassIsChildOf(M.Class, class'Razorfly') || ClassIsChildOf(M.Class, class'Manta') || ClassIsChildOf(M.Class, class'Tarantula')))
				{
					M2Inv.MissionCount++;
				}
			}
			else if (M2Inv.GhostBusterActive && !Inv.GhostBusterComplete)
			{
				for (x = 0; x < default.GhostMonsters.Length; x++)
				{
					if (M.Class == default.GhostMonsters[x])
					{
						M2Inv.MissionCount++;
						break;
					}
				}
			}
			else if (M2Inv.GlacialHuntActive && !Inv.GlacialHuntComplete)
			{
				if (IceInv(M.FindInventoryType(class'IceInv')) != None)
				M2Inv.MissionCount++;
			}
			else if (M2Inv.NaniteCrashActive && !Inv.NaniteCrashComplete)
			{
				for (x = 0; x < default.TechMonsters.Length; x++)
				{
					if (M.Class == default.TechMonsters[x])
					{
						M2Inv.MissionCount++;
						break;
					}
				}
			}
			else if (M2Inv.RootedStanceActive && !Inv.RootedStanceComplete)
			{
				if (VSize(P.Velocity) ~= 0)
				{
					M2Inv.MissionCount++;
				}
			}
			else if (M2Inv.SharpShotFlyActive && !Inv.SharpShotFlyComplete)
			{
				if (M.IsA('VampireGnat') && (SniperRifle(W) != None || ClassicSniperRifle(W) != None || DEKRailGun(W) != None ))
				{
					M2Inv.MissionCount++;
				}
			}
			else if (M2Inv.SkaarjHuntActive && !Inv.SkaarjHuntComplete)
			{
				if (ClassIsChildOf(M.Class, class'Skaarj') || ClassIsChildOf(M.Class, class'FireSkaarj') || ClassIsChildOf(M.Class, class'IceSkaarj') || ClassIsChildOf(M.Class, class'SMPSkaarjSniper') || ClassIsChildOf(M.Class, class'SMPSkaarjTrooper'))
				{
					M2Inv.MissionCount++;
				}
			}
			else if (M2Inv.SpidermanActive && !Inv.SpidermanComplete)
			{
				if (P.Physics == PHYS_Spider)
				{
					M2Inv.MissionCount++;
				}
			}
			else if (M2Inv.StarHuntActive && !Inv.StarHuntComplete)
			{
				for (x = 0; x < default.CosmicMonsters.Length; x++)
				{
					if (M.Class == default.CosmicMonsters[x])
					{
						M2Inv.MissionCount++;
						break;
					}
				}
			}
			else if (M2Inv.SupermanActive && !Inv.SupermanComplete)
			{
				if (P.Physics == PHYS_Flying || P.Physics == PHYS_Falling)
				{
					M2Inv.MissionCount++;
				}
			}
			else if (M2Inv.VolcanicHuntActive && !Inv.VolcanicHuntComplete)
			{
				if (FireInv(M.FindInventoryType(class'FireInv')) != None)
				M2Inv.MissionCount++;
			}
			else if (M2Inv.ForestHuntActive && !Inv.ForestHuntComplete)
			{
				if (EarthInv(M.FindInventoryType(class'EarthInv')) != None)
				M2Inv.MissionCount++;
			}
			else if (M2Inv.WarlordHuntActive && !Inv.WarlordHuntComplete)
			{
				if (ClassIsChildOf(M.Class, class'Warlord') || ClassIsChildOf(M.Class, class'DCWarlord'))
				{
					M2Inv.MissionCount++;
				}
			}
			else if (M2Inv.ZombieSlayerActive && !Inv.ZombieSlayerComplete)
			{
				if (ZombieInv != None)
				{
					M2Inv.MissionCount++;
				}
			}
			else if (M2Inv.EmeraldShatterActive && !Inv.EmeraldShatterComplete)
			{
				if (PossessorInv != None)
				{
					M2Inv.MissionCount++;
				}
				if (Killed.Pawn.IsA('NecroGhostPossessor'))
				{
					M2Inv.MissionCount++;
					M2Inv.MissionCount++;
				}
			}
		}
		//M3
		if (M3Inv != None && !M3Inv.Stopped)
		{
			if (M3Inv.AquamanActive && !Inv.AquamanComplete)
			{
				if (P.PhysicsVolume.bWaterVolume && P.Physics == PHYS_Swimming)
				{
					M3Inv.MissionCount++;
				}
			}
			else if (M3Inv.BoneCrusherActive && !Inv.BoneCrusherComplete)
			{
				for (x = 0; x < default.BoneMonsters.Length; x++)
				{
					if (M.Class == default.BoneMonsters[x])
					{
						M3Inv.MissionCount++;
						break;
					}
				}
			}
			else if (M3Inv.KrallHuntActive && !Inv.KrallHuntComplete)
			{
				if (ClassIsChildOf(M.Class, class'Krall') || ClassIsChildOf(M.Class, class'DCKrall'))
				{
					M3Inv.MissionCount++;
				}
			}
			else if (M3Inv.BugHuntActive && !Inv.BugHuntComplete)
			{
				if (!M.IsA('NecroSkull') && (ClassIsChildOf(M.Class, class'SkaarjPupae') || ClassIsChildOf(M.Class, class'Razorfly') || ClassIsChildOf(M.Class, class'Manta') || ClassIsChildOf(M.Class, class'Tarantula')))
				{
					M3Inv.MissionCount++;
				}
			}
			else if (M3Inv.GhostBusterActive && !Inv.GhostBusterComplete)
			{
				for (x = 0; x < default.GhostMonsters.Length; x++)
				{
					if (M.Class == default.GhostMonsters[x])
					{
						M3Inv.MissionCount++;
						break;
					}
				}
			}
			else if (M3Inv.GlacialHuntActive && !Inv.GlacialHuntComplete)
			{
				if (IceInv(M.FindInventoryType(class'IceInv')) != None)
				M3Inv.MissionCount++;
			}
			else if (M3Inv.NaniteCrashActive && !Inv.NaniteCrashComplete)
			{
				for (x = 0; x < default.TechMonsters.Length; x++)
				{
					if (M.Class == default.TechMonsters[x])
					{
						M3Inv.MissionCount++;
						break;
					}
				}
			}
			else if (M3Inv.RootedStanceActive && !Inv.RootedStanceComplete)
			{
				if (VSize(P.Velocity) ~= 0)
				{
					M3Inv.MissionCount++;
				}
			}
			else if (M3Inv.SharpShotFlyActive && !Inv.SharpShotFlyComplete)
			{
				if (M.IsA('VampireGnat') && (SniperRifle(W) != None || ClassicSniperRifle(W) != None || DEKRailGun(W) != None ))
				{
					M3Inv.MissionCount++;
				}
			}
			else if (M3Inv.SkaarjHuntActive && !Inv.SkaarjHuntComplete)
			{
				if (ClassIsChildOf(M.Class, class'Skaarj') || ClassIsChildOf(M.Class, class'FireSkaarj') || ClassIsChildOf(M.Class, class'IceSkaarj') || ClassIsChildOf(M.Class, class'SMPSkaarjSniper') || ClassIsChildOf(M.Class, class'SMPSkaarjTrooper'))
				{
					M3Inv.MissionCount++;
				}
			}
			else if (M3Inv.SpidermanActive && !Inv.SpidermanComplete)
			{
				if (P.Physics == PHYS_Spider)
				{
					M3Inv.MissionCount++;
				}
			}
			else if (M3Inv.StarHuntActive && !Inv.StarHuntComplete)
			{
				for (x = 0; x < default.CosmicMonsters.Length; x++)
				{
					if (M.Class == default.CosmicMonsters[x])
					{
						M3Inv.MissionCount++;
						break;
					}
				}
			}
			else if (M3Inv.SupermanActive && !Inv.SupermanComplete)
			{
				if (P.Physics == PHYS_Flying || P.Physics == PHYS_Falling)
				{
					M3Inv.MissionCount++;
				}
			}
			else if (M3Inv.VolcanicHuntActive && !Inv.VolcanicHuntComplete)
			{
				if (FireInv(M.FindInventoryType(class'FireInv')) != None)
				M3Inv.MissionCount++;
			}
			else if (M3Inv.ForestHuntActive && !Inv.ForestHuntComplete)
			{
				if (EarthInv(M.FindInventoryType(class'EarthInv')) != None)
				M3Inv.MissionCount++;
			}
			else if (M3Inv.WarlordHuntActive && !Inv.WarlordHuntComplete)
			{
				if (ClassIsChildOf(M.Class, class'Warlord') || ClassIsChildOf(M.Class, class'DCWarlord'))
				{
					M3Inv.MissionCount++;
				}
			}
			else if (M3Inv.ZombieSlayerActive && !Inv.ZombieSlayerComplete)
			{
				if (ZombieInv != None)
				{
					M3Inv.MissionCount++;
				}
			}
			else if (M3Inv.EmeraldShatterActive && !Inv.EmeraldShatterComplete)
			{
				if (PossessorInv != None)
				{
					M3Inv.MissionCount++;
				}
				if (Killed.Pawn.IsA('NecroGhostPossessor'))
				{
					M3Inv.MissionCount++;
					M3Inv.MissionCount++;
				}
			}
		}
	}
	else
		return;
}

static function HandleDamage(out int Damage, Pawn Injured, Pawn Instigator, out vector Momentum, class<DamageType> DamageType, bool bOwnedByInstigator, int AbilityLevel)
{
	local MissionInv Inv;
	local Mission1Inv M1Inv;
	local Mission2Inv M2Inv;
	local Mission3Inv M3Inv;
	local MissionMultiplayerHUDInv MMPI;
	local Pawn P;
	
	P = Instigator;
	if (P != None && P.IsA('Vehicle'))
		P = Vehicle(P).Driver;
	if (P != None)
	{
		Inv = MissionInv(P.FindInventoryType(class'MissionInv'));
		M1Inv = Mission1Inv(P.FindInventoryType(class'Mission1Inv'));
		M2Inv = Mission2Inv(P.FindInventoryType(class'Mission2Inv'));
		M3Inv = Mission3Inv(P.FindInventoryType(class'Mission3Inv'));
		MMPI = MissionMultiplayerHUDInv(P.FindInventoryType(class'MissionMultiplayerHUDInv'));
	}
	
	if (Inv != None && Damage > 0 && bOwnedByInstigator && P != None && Injured != None && Injured != P && Injured.GetTeam() != P.GetTeam() && P.GetTeam() != None)
	{
		if (MMPI != None && !MMPI.Stopped)
		{
			if (MMPI.PowerPartyActive)
				MMPI.UpdateCount(Damage);
		}
		if (M1Inv != None && !M1Inv.Stopped)
		{
			if (M1Inv.AVRiLAmityActive && !Inv.AVRiLAmityComplete)
			{
				if (DamageType == class'DEKWeapons208AG.DamTypeDEKAVRiLRocket')
					M1Inv.MissionCount++;
			}
			else if (M1Inv.BioBerserkActive && !Inv.BioBerserkComplete)
			{
				if (DamageType == class'XWeapons.DamTypeBioGlob' || DamageType == class'DEKWeapons208AG.DamTypeUpgradeBioGlob')
					M1Inv.MissionCount++;
			}
			else if (M1Inv.FlakFrenzyActive && !Inv.FlakFrenzyComplete)
			{
				if (DamageType == class'XWeapons.DamTypeFlakChunk' || DamageType == class'XWeapons.DamTypeFlakShell')
					M1Inv.MissionCount++;
			}
			else if (M1Inv.LinkLunaticActive && !Inv.LinkLunaticComplete)
			{
				if (DamageType == class'XWeapons.DamTypeLinkPlasma' || DamageType == class'XWeapons.DamTypeLinkShaft')
					M1Inv.MissionCount++;
			}
			else if (M1Inv.MightyLightningActive && !Inv.MightyLightningComplete)
			{
				if (DamageType == class'XWeapons.DamTypeSniperShot')
					M1Inv.MissionCount++;
				else if (DamageType == class'XWeapons.DamTypeSniperHeadShot')
				{
					M1Inv.MissionCount++;
					M1Inv.MissionCount++;
					M1Inv.MissionCount++;
				}
			}
			else if (M1Inv.MinigunMayhemActive && !Inv.MinigunMayhemComplete)
			{
				if (DamageType == class'XWeapons.DamTypeMinigunAlt' || DamageType == class'XWeapons.DamTypeMinigunBullet')
					M1Inv.MissionCount++;
			}
			else if (M1Inv.RocketRageActive && !Inv.RocketRageComplete)
			{
				if (DamageType == class'XWeapons.DamTypeRocket' || DamageType == class'XWeapons.DamTypeRocketHoming')
					M1Inv.MissionCount++;
			}
			else if (M1Inv.ShockSlaughterActive && !Inv.ShockSlaughterComplete)
			{
				if (DamageType == class'XWeapons.DamTypeShockBeam' || DamageType == class'XWeapons.DamTypeShockBall')
					M1Inv.MissionCount++;
				else if (DamageType == class'XWeapons.DamTypeShockCombo')
				{
					M1Inv.MissionCount++;
					M1Inv.MissionCount++;
					M1Inv.MissionCount++;
				}
			}
			else if (M1Inv.UtilityMutilityActive && !Inv.UtilityMutilityComplete)
			{
				if (DamageType == class'DEKWeapons208AG.DamTypeProAssBullet' || DamageType == class'DEKWeapons208AG.DamTypeProAssGrenadeChunk')
					M1Inv.MissionCount++;
				else if (DamageType == class'DEKWeapons208AG.DamTypeProAssGrenade')
				{
					M1Inv.MissionCount++;
					M1Inv.MissionCount++;
					M1Inv.MissionCount++;
				}
			}
		}
		if (M2Inv != None && !M2Inv.Stopped)
		{
			if (M2Inv.AVRiLAmityActive && !Inv.AVRiLAmityComplete)
			{
				if (DamageType == class'DEKWeapons208AG.DamTypeDEKAVRiLRocket')
					M2Inv.MissionCount++;
			}
			else if (M2Inv.BioBerserkActive && !Inv.BioBerserkComplete)
			{
				if (DamageType == class'XWeapons.DamTypeBioGlob' || DamageType == class'DEKWeapons208AG.DamTypeUpgradeBioGlob')
					M2Inv.MissionCount++;
			}
			else if (M2Inv.FlakFrenzyActive && !Inv.FlakFrenzyComplete)
			{
				if (DamageType == class'XWeapons.DamTypeFlakChunk' || DamageType == class'XWeapons.DamTypeFlakShell')
					M2Inv.MissionCount++;
			}
			else if (M2Inv.LinkLunaticActive && !Inv.LinkLunaticComplete)
			{
				if (DamageType == class'XWeapons.DamTypeLinkPlasma' || DamageType == class'XWeapons.DamTypeLinkShaft')
					M2Inv.MissionCount++;
			}
			else if (M2Inv.MightyLightningActive && !Inv.MightyLightningComplete)
			{
				if (DamageType == class'XWeapons.DamTypeSniperShot')
					M2Inv.MissionCount++;
				else if (DamageType == class'XWeapons.DamTypeSniperHeadShot')
				{
					M2Inv.MissionCount++;
					M2Inv.MissionCount++;
					M2Inv.MissionCount++;
				}
			}
			else if (M2Inv.MinigunMayhemActive && !Inv.MinigunMayhemComplete)
			{
				if (DamageType == class'XWeapons.DamTypeMinigunAlt' || DamageType == class'XWeapons.DamTypeMinigunBullet')
					M2Inv.MissionCount++;
			}
			else if (M2Inv.RocketRageActive && !Inv.RocketRageComplete)
			{
				if (DamageType == class'XWeapons.DamTypeRocket' || DamageType == class'XWeapons.DamTypeRocketHoming')
					M2Inv.MissionCount++;
			}
			else if (M2Inv.ShockSlaughterActive && !Inv.ShockSlaughterComplete)
			{
				if (DamageType == class'XWeapons.DamTypeShockBeam' || DamageType == class'XWeapons.DamTypeShockBall')
					M2Inv.MissionCount++;
				else if (DamageType == class'XWeapons.DamTypeShockCombo')
				{
					M2Inv.MissionCount++;
					M2Inv.MissionCount++;
					M2Inv.MissionCount++;
				}
			}
			else if (M2Inv.UtilityMutilityActive && !Inv.UtilityMutilityComplete)
			{
				if (DamageType == class'DEKWeapons208AG.DamTypeProAssBullet' || DamageType == class'DEKWeapons208AG.DamTypeProAssGrenadeChunk')
					M2Inv.MissionCount++;
				else if (DamageType == class'DEKWeapons208AG.DamTypeProAssGrenade')
				{
					M2Inv.MissionCount++;
					M2Inv.MissionCount++;
					M2Inv.MissionCount++;
				}
			}
		}
		if (M3Inv != None && !M3Inv.Stopped)
		{
			if (M3Inv.AVRiLAmityActive && !Inv.AVRiLAmityComplete)
			{
				if (DamageType == class'DEKWeapons208AG.DamTypeDEKAVRiLRocket')
					M3Inv.MissionCount++;
			}
			else if (M3Inv.BioBerserkActive && !Inv.BioBerserkComplete)
			{
				if (DamageType == class'XWeapons.DamTypeBioGlob' || DamageType == class'DEKWeapons208AG.DamTypeUpgradeBioGlob')
					M3Inv.MissionCount++;
			}
			else if (M3Inv.FlakFrenzyActive && !Inv.FlakFrenzyComplete)
			{
				if (DamageType == class'XWeapons.DamTypeFlakChunk' || DamageType == class'XWeapons.DamTypeFlakShell')
					M3Inv.MissionCount++;
			}
			else if (M3Inv.LinkLunaticActive && !Inv.LinkLunaticComplete)
			{
				if (DamageType == class'XWeapons.DamTypeLinkPlasma' || DamageType == class'XWeapons.DamTypeLinkShaft')
					M3Inv.MissionCount++;
			}
			else if (M3Inv.MightyLightningActive && !Inv.MightyLightningComplete)
			{
				if (DamageType == class'XWeapons.DamTypeSniperShot')
					M3Inv.MissionCount++;
				else if (DamageType == class'XWeapons.DamTypeSniperHeadShot')
				{
					M3Inv.MissionCount++;
					M3Inv.MissionCount++;
					M3Inv.MissionCount++;
				}
			}
			else if (M3Inv.MinigunMayhemActive && !Inv.MinigunMayhemComplete)
			{
				if (DamageType == class'XWeapons.DamTypeMinigunAlt' || DamageType == class'XWeapons.DamTypeMinigunBullet')
					M3Inv.MissionCount++;
			}
			else if (M3Inv.RocketRageActive && !Inv.RocketRageComplete)
			{
				if (DamageType == class'XWeapons.DamTypeRocket' || DamageType == class'XWeapons.DamTypeRocketHoming')
					M3Inv.MissionCount++;
			}
			else if (M3Inv.ShockSlaughterActive && !Inv.ShockSlaughterComplete)
			{
				if (DamageType == class'XWeapons.DamTypeShockBeam' || DamageType == class'XWeapons.DamTypeShockBall')
					M3Inv.MissionCount++;
				else if (DamageType == class'XWeapons.DamTypeShockCombo')
				{
					M3Inv.MissionCount++;
					M3Inv.MissionCount++;
					M3Inv.MissionCount++;
				}
			}
			else if (M3Inv.UtilityMutilityActive && !Inv.UtilityMutilityComplete)
			{
				if (DamageType == class'DEKWeapons208AG.DamTypeProAssBullet' || DamageType == class'DEKWeapons208AG.DamTypeProAssGrenadeChunk')
					M3Inv.MissionCount++;
				else if (DamageType == class'DEKWeapons208AG.DamTypeProAssGrenade')
				{
					M3Inv.MissionCount++;
					M3Inv.MissionCount++;
					M3Inv.MissionCount++;
				}
			}
		}
	}
	if (Inv != None && Damage > 0 && !bOwnedByInstigator && P != None && Injured != None)
	{
		if (Inv.GlacialHuntComplete && Rand(100) <= default.NullifyIceDamageChance)
		{
			if (DamageType == class'DamTypeIceKrall' ||
			DamageType == class'DamTypeArcticBioSkaarjGlob' ||
			DamageType == class'DamTypeIceBrute' ||
			DamageType == class'DamTypeIceGasbag' ||
			DamageType == class'DamTypeIceGiantGasbag' ||
			DamageType == class'DamTypeIceMercenary' ||
			DamageType == class'DamTypeIceQueen' ||
			DamageType == class'DamTypeIceSkaarjFreezing' ||
			DamageType == class'DamTypeIceSlith' ||
			DamageType == class'DamTypeIceSlug' ||
			DamageType == class'DamTypeIceTitan' ||
			DamageType == Class'DamTypeIceTentacle' ||
			DamageType == class'DamTypeIceWarlord')
				Damage = 1;
		}
		if (Inv.VolcanicHuntComplete && Rand(100) <= default.NullifyFireDamageChance)
		{
			if (
			DamageType == class'DamTypeSuperHeat'||
			DamageType == class'DamTypeLavaBioSkaarjGlob' ||
			DamageType == class'DamTypeFireBrute' ||
			DamageType == class'DamTypeFireGasbag' ||
			DamageType == class'DamTypeFireGiantGasbag' ||
			DamageType == class'DamTypeFireKrall' ||
			DamageType == class'DamTypeFireLord' ||
			DamageType == class'DamTypeFireMercenary' ||
			DamageType == class'DamTypeFireQueen' ||
			DamageType == class'DamTypeFireSkaarjSuperHeat' ||
			DamageType == class'DamTypeFireSlith' ||
			DamageType == class'DamTypeFireSlug' ||
			DamageType == class'DamTypeFireTentacle' ||
			DamageType == class'DamTypeFireTitanSuperHeat')
				Damage = 1;
		}
		if (Inv.ForestHuntComplete && Rand(100) <= default.NullifyEarthDamageChance)
		{
			if (DamageType == class'DamTypeEarthBehemoth' ||
			DamageType == class'DamTypeEarthBrute'||
			DamageType == class'DamTypeEarthEliteKrall' ||
			DamageType == class'DamTypeEarthEliteMercenaryRocket' ||
			DamageType == class'DamTypeEarthEliteMercenaryThorn' ||
			DamageType == class'DamTypeEarthGasbag' ||
			DamageType == class'DamTypeEarthGiantGasbag' ||
			DamageType == class'DamTypeEarthKrall' ||
			DamageType == class'DamTypeEarthMercenaryRocket' ||
			DamageType == class'DamTypeEarthMercenaryThorn' ||
			DamageType == class'DamTypeEarthQueenThorn' ||
			DamageType == class'DamTypeEarthSkaarj' ||
			DamageType == class'DamTypeEarthSkaarjSniper' ||
			DamageType == class'DamTypeEarthSkaarjTrooper' ||
			DamageType == class'DamTypeEarthSlith' ||
			DamageType == class'DamTypeEarthSlug' ||
			DamageType == class'DamTypeEarthTentacle' ||
			DamageType == class'DamTypeEarthTitan' ||
			DamageType == class'DamTypeEarthWarlordBeam' )
				Damage = 1;
		}
	}
}

defaultproperties
{
     NullifyIceDamageChance=10.000000
     NullifyFireDamageChance=10.000000
     NullifyEarthDamageChance=10.000000
     GenomeMaxDamage=30
     BoneMonsters(0)=Class'DEKMonsters208AG.NecroMortalSkeleton'
     BoneMonsters(1)=Class'DEKMonsters208AG.NecroSkull'
     GhostMonsters(0)=Class'DEKMonsters208AG.NecroAdrenWraith'
     GhostMonsters(1)=Class'DEKMonsters208AG.NecroGhostExp'
     GhostMonsters(2)=Class'DEKMonsters208AG.NecroGhostIllusion'
     GhostMonsters(3)=Class'DEKMonsters208AG.NecroGhostMisfortune'
     GhostMonsters(4)=Class'DEKMonsters208AG.NecroGhostPoltergeist'
     GhostMonsters(5)=Class'DEKMonsters208AG.NecroGhostPossessor'
     GhostMonsters(6)=Class'DEKMonsters208AG.NecroGhostPriest'
     GhostMonsters(7)=Class'DEKMonsters208AG.NecroGhostShaman'
     GhostMonsters(8)=Class'DEKMonsters208AG.NecroPhantom'
     GhostMonsters(9)=Class'DEKMonsters208AG.NecroSorcerer'
     GhostMonsters(10)=Class'DEKMonsters208AG.NecroSoulWraith'
     TechMonsters(0)=Class'DEKMonsters208AG.TechBehemoth'
     TechMonsters(1)=Class'DEKMonsters208AG.TechKrall'
     TechMonsters(2)=Class'DEKMonsters208AG.TechPupae'
     TechMonsters(3)=Class'DEKMonsters208AG.TechQueen'
     TechMonsters(4)=Class'DEKMonsters208AG.TechRazorfly'
     TechMonsters(5)=Class'DEKMonsters208AG.TechSkaarj'
     TechMonsters(6)=Class'DEKMonsters208AG.TechSlith'
     TechMonsters(7)=Class'DEKMonsters208AG.TechSlug'
     TechMonsters(8)=Class'DEKMonsters208AG.TechSniper'
     TechMonsters(9)=Class'DEKMonsters208AG.TechTitan'
     TechMonsters(10)=Class'DEKMonsters208AG.TechWarlord'
     TechMonsters(11)=Class'DEKMonsters208AG.GiantManta'
     TechMonsters(12)=Class'DEKBossMonsters208AG.MinionTechKrall'
     TechMonsters(13)=Class'DEKBossMonsters208AG.MinionTechSniper'
     CosmicMonsters(0)=Class'DEKMonsters208AG.CosmicBrute'
     CosmicMonsters(1)=Class'DEKMonsters208AG.CosmicKrall'
     CosmicMonsters(2)=Class'DEKMonsters208AG.CosmicMercenary'
     CosmicMonsters(3)=Class'DEKMonsters208AG.CosmicNali'
     CosmicMonsters(4)=Class'DEKMonsters208AG.CosmicQueen'
     CosmicMonsters(5)=Class'DEKMonsters208AG.CosmicSkaarj'
     CosmicMonsters(6)=Class'DEKMonsters208AG.CosmicTitan'
     CosmicMonsters(7)=Class'DEKMonsters208AG.CosmicWarlord'
     AbilityName="Missions"
     Description="This ability tracks the kills and damage you make for mission purposes. Activating certain missions without this ability will not track data.||You can forfeit a mission any time by keybinding these commands:|'exitmissionone' to forfeit mission one;|'exitmissiontwo' to forfeit mission two;|'exitmissionthree' to forfeit mission three.|See the F12 menu for more info on keybinding instructions as well as a list of available missions and their descriptions.||Cost: 1."
     StartingCost=1
     MaxLevel=1
}
