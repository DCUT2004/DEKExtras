class AbilityShieldEarth extends CostRPGAbility
	config(UT2004RPG) 
	abstract;

var config float ProtectionMultiplier;
var config Array <class <DamageType> > DamageClass;

static function HandleDamage(out int Damage, Pawn Injured, Pawn Instigator, out vector Momentum, class<DamageType> DamageType, bool bOwnedByInstigator, int AbilityLevel)
{
	local int x;
	
	if (Damage > 0 && Instigator != None && Injured != None && !bOwnedByInstigator)
	{
		for(x = 0; x < default.DamageClass.Length; x++)
		{
			if (DamageType == default.DamageClass[x])
			{
				Damage *= (abs(1-(AbilityLevel * default.ProtectionMultiplier)));
				if (Damage == 0)
					Damage = 1;
				break;
			}
		}
	}
}

defaultproperties
{
     ProtectionMultiplier=0.050000
     ExcludingAbilities(0)=Class'DEKExtras208AD.AbilityShieldFire'
     ExcludingAbilities(1)=Class'DEKExtras208AD.AbilityShieldIce'
     AbilityName="Shield: Earth"
     Description="Reduces damage from all elemental Earth monsters by 5% per level. You can not have more than one type of elemental shield at a time.|Cost (per level): 5,10,15,20..."
     StartingCost=5
     CostAddPerLevel=5
     MaxLevel=10
}
