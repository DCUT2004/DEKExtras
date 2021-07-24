//Does more damage to fire monsters. Based off of WailOfSuicide's RW_SkaarjBane in DWRPG from the Death Warrant Invasion Servers

class RW_EnhancedFreeze extends OneDropRPGWeapon
	HideDropDown
	CacheExempt
	config(UT2004RPG);

var Sound FreezeSound;
var config float DamageBonus;
var config float IceOnEarthDamageBonus;

function NewAdjustTargetDamage(out int Damage, int OriginalDamage, Actor Victim, vector HitLocation, out vector Momentum, class<DamageType> DamageType)
{
	if(damage > 0)
	{
		if (Damage < (OriginalDamage * class'OneDropRPGWeapon'.default.MinDamagePercent))
			Damage = OriginalDamage * class'OneDropRPGWeapon'.default.MinDamagePercent;
	}

	Super.NewAdjustTargetDamage(Damage, OriginalDamage, Victim, HitLocation, Momentum, DamageType);
}

function AdjustTargetDamage(out int Damage, Actor Victim, Vector HitLocation, out Vector Momentum, class<DamageType> DamageType)
{
	local Pawn P;
	Local Actor A;
	local EarthInv Inv;

	if (!bIdentified)
		Identify();

	if (!class'OneDropRPGWeapon'.static.CheckCorrectDamage(ModifiedWeapon, DamageType))
		return;
	
	P = Pawn(Victim);

	if (Damage > 0)
	{
		if (P != None && P.Health > 0)
		{
			Inv = EarthInv(P.FindInventoryType(class'EarthInv'));
			if (Inv != None)
			{
				Damage *= (1.0 + IceOnEarthDamageBonus* Modifier);
				Momentum *= 1.0 + IceOnEarthDamageBonus * Modifier;
				A = P.spawn(class'IceMercenaryPlasmaHitEffect', P,, P.Location);
				if (A != None)
					A.RemoteRole = ROLE_SimulatedProxy;
			}
			else
			{
				Damage = Max(1, Damage * (1.0 + DamageBonus * Modifier));
				Momentum *= 1.0 + DamageBonus * Modifier;
			}
			Freeze(P);
		}
		
	}
}

function Freeze(Pawn P)
{
	local FreezeInv Inv;
	local Actor A;
	local MagicShieldInv MInv;
	local MissionInv MiInv;
	local Mission1Inv M1Inv;
	local Mission2Inv M2Inv;
	local MIssion3Inv M3Inv;
	local IceInv IInv;
	
	MInv = MagicShieldInv(P.FindInventoryType(class'MagicShieldInv'));
	MiInv = MissionInv(Instigator.FindInventoryType(class'MissionInv'));
	M1Inv = Mission1Inv(Instigator.FindInventoryType(class'Mission1Inv'));
	M2Inv = Mission2Inv(Instigator.FindInventoryType(class'Mission2Inv'));
	M3Inv = Mission3Inv(Instigator.FindInventoryType(class'Mission3Inv'));
	
	if (P != None && P.Health > 0 && class'RW_Freeze'.static.canTriggerPhysics(P) && (!P.Controller.SameTeamAs(Instigator.Controller) || P == Instigator))
	{
		IInv = IceInv(P.FindInventoryType(class'IceInv'));
		if (IInv != None)
			return;
		if (MInv != None)
			return;
		else
		{		
			Inv = FreezeInv(P.FindInventoryType(class'FreezeInv'));
			//dont add to the time a pawn is already frozen. It just wouldn't be fair.
			if (Inv == None)
			{
				Inv = spawn(class'FreezeInv', P,,, rot(0,0,0));
				Inv.Modifier = Modifier;
				Inv.LifeSpan = Modifier;
				Inv.GiveTo(P);
				if (Instigator != None && Instigator != P && MiInv != None && !MiInv.FrostmancerComplete)
				{
					if (M1Inv != None && !M1Inv.Stopped && M1Inv.FrostmancerActive)
					{
						if (Modifier <= 3)
						{
							M1Inv.MissionCount++;
						}
						else
						{
							M1Inv.MissionCount++;
							M1Inv.MissionCount++;
						}
					}
					if (M2Inv != None && !M2Inv.Stopped && M2Inv.FrostmancerActive)
					{
						if (Modifier <= 3)
						{
							M2Inv.MissionCount++;
						}
						else
						{
							M2Inv.MissionCount++;
							M2Inv.MissionCount++;
						}
					}
					if (M3Inv != None && !M3Inv.Stopped && M3Inv.FrostmancerActive)
					{
						if (Modifier <= 3)
						{
							M3Inv.MissionCount++;
						}
						else
						{
							M3Inv.MissionCount++;
							M3Inv.MissionCount++;
						}
					}
				}
				A = P.spawn(class'DEKEffectArctic', P,, P.Location, P.Rotation); 
				if (A != None)
				{
					A.RemoteRole = ROLE_SimulatedProxy;
						A.PlaySound(FreezeSound,,2.5*P.TransientSoundVolume,,P.TransientSoundRadius);
				}	
			}
		}
		if (!bIdentified)
			Identify();
	}
}

defaultproperties
{
     FreezeSound=Sound'Slaughtersounds.Machinery.Heavy_End'
     DamageBonus=0.020000
     IceOnEarthDamageBonus=0.100000
     ModifierOverlay=TexPanner'DEKWeaponsMaster206.fX.GreyPanner'
     MinModifier=3
     MaxModifier=6
     AIRatingBonus=0.025000
     PrefixPos="Freezing "
}
