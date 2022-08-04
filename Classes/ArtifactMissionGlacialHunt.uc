class ArtifactMissionGlacialHunt extends ArtifactMissionBETA
		config(Missions);

defaultproperties
{
	 ObjectiveClasses(0)=Class'DEKRPG999X.IceInv'
	 TickAmount=1
     XPReward=20
     MissionGoal=25
     Description="Kill Ice monsters."
     PickupClass=Class'DEKExtras999X.ArtifactMissionGlacialHuntPickup'
     IconMaterial=Texture'MissionsTex6.HuntMissions.GlacialHuntMission'
     ItemName="Glacial Hunt"
}
