class ArtifactMissionShockSlaughter extends ArtifactMissionBETA
		config(UT2004RPG);

defaultproperties
{
	 ObjectiveClasses(0)=Class'XWeapons.DamTypeShockBeam'
	 ObjectiveClasses(1)=Class'XWeapons.DamTypeShockBall'
	 ObjectiveClasses(2)=Class'XWeapons.DamTypeShockCombo'
     XPReward=30
     MissionGoal=300
     Description="Use the Shock Rifle."
     PickupClass=Class'DEKExtras999X.ArtifactMissionShockSlaughterPickup'
     IconMaterial=Texture'MissionsTex6.WeaponMissions.MissionShockRifle'
     ItemName="Shock Slaughter"
}
