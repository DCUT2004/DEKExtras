class RW_SolarPower extends RW_SuperHeat
   HideDropDown
   CacheExempt
   config(UT2004RPG);

function PostBeginPlay()
{
	Local GameRules G;
	super.PostBeginPlay();
	for(G = Level.Game.GameRulesModifiers; G != None; G = G.NextGameRules)
	{
		if(G.isA('RPGRules'))
		{
			RPGRules = RPGRules(G);
			break;
		}
	}

	if(RPGRules == None)
		Log("WARNING: Unable to find RPGRules in GameRules. EXP will not be properly awarded");
}

static function bool AllowedFor(class<Weapon> Weapon, Pawn Other)
{
	local int x;
	local RPGStatsInv StatsInv;
	
	if ( Weapon.default.FireModeClass[0] != None && Weapon.default.FireModeClass[0].default.AmmoClass != None
	          && class'MutUT2004RPG'.static.IsSuperWeaponAmmo(Weapon.default.FireModeClass[0].default.AmmoClass) )
		return false;

	if(instr(caps(Weapon), "LINK") > -1)
		return false;	
	if(instr(caps(Weapon), "MINE LAYER") > -1)
		return false;		
	if(instr(caps(Weapon), "UTILITY RIFLE") > -1)
		return false;	
	if(instr(caps(Weapon), "PROASS") > -1)
		return false;		
	if(instr(caps(Weapon), "GRAVITY") > -1)
		return false;	
	if(instr(caps(Weapon), "SHIELD") > -1)
		return false;	
	if(instr(caps(Weapon), "SINGULARITY") > -1)
		return false;
	if(instr(caps(Weapon), "RAIL GUN") > -1)
		return false;
		
	StatsInv = RPGStatsInv(Other.FindInventoryType(class'RPGStatsInv'));

	for (x = 0; StatsInv != None && x < StatsInv.Data.Abilities.length; x++)
		if (StatsInv.Data.Abilities[x] == class'AbilityMagicVault' && StatsInv.Data.AbilityLevels[x] >= 3)
		return true;

	return false;
}

simulated function bool StartFire(int Mode)
{
	if (!bIdentified && Role == ROLE_Authority)
		Identify();

	return Super.StartFire(Mode);
}

function bool ConsumeAmmo(int Mode, float Load, bool bAmountNeededIsMax)
{
	if (!bIdentified)
		Identify();

	return true;
}

simulated function WeaponTick(float dt)
{
	MaxOutAmmo();

	Super.WeaponTick(dt);
}

simulated function int MaxAmmo(int mode)
{
	if (bNoAmmoInstances && HolderStatsInv != None)
		return (ModifiedWeapon.MaxAmmo(mode) * (1.0 + 0.01 * HolderStatsInv.Data.AmmoMax));

	return ModifiedWeapon.MaxAmmo(mode);
}

function AdjustTargetDamage(out int Damage, Actor Victim, Vector HitLocation, out Vector Momentum, class<DamageType> DamageType)
{
	local Pawn P;
	Local Actor A;
	local IceInv Inv;

	if (!bIdentified)
		Identify();

	if (!class'OneDropRPGWeapon'.static.CheckCorrectDamage(ModifiedWeapon, DamageType))
		return;
	
	P = Pawn(Victim);

	if (Damage > 0)
	{
		if (P != None && P.Health > 0)
		{
			Inv = IceInv(P.FindInventoryType(class'IceInv'));
			if (Inv != None)
			{
				Damage *= (1.0 + FireOnIceDamageBonus* Modifier);
				Momentum *= 1.0 + FireOnIceDamageBonus * Modifier;
				A = P.spawn(class'FireMercenaryPlasmaHitEffect', P,, P.Location);
				if (A != None)
					A.RemoteRole = ROLE_SimulatedProxy;
			}
			else
			{
				Damage = Max(1, Damage * (1.0 + DamageBonus * Modifier));
				Momentum *= 1.0 + DamageBonus * Modifier;
			}
			Burn(P);
		}
		
	}
	Super(RPGWeapon).AdjustTargetDamage(Damage, Victim, HitLocation, Momentum, DamageType);	
}

defaultproperties
{
	 DamageBonus=0.04000000
     MaxModifier=5
     PostfixPos=" of Solar Power"
     ModifierOverlay=TexPanner'Bastien_02.Lava.01B_PanLava'
}
