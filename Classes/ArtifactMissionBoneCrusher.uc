class ArtifactMissionBoneCrusher extends ArtifactMissionBETA
		config(Missions);

defaultproperties
{
	 ObjectiveClasses(0)=Class'DEKMonsters999X.NecroMortalSkeleton'
	 ObjectiveClasses(1)=Class'DEKMonsters999X.NecroSkull'
     XPReward=20
     MissionGoal=30
     Description="Kill skeletons and skulls."
     PickupClass=Class'DEKExtras999X.ArtifactMissionBoneCrusherPickup'
     IconMaterial=Texture'MissionsTex6.HuntMissions.BoneCrusherMission'
     ItemName="Bone Crusher"
}
