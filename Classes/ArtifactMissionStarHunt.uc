class ArtifactMissionStarHunt extends ArtifactMissionBETA
		config(Missions);

defaultproperties
{
	 ObjectiveClasses(0)=Class'DEKRPG999X.CosmicInv'
	 TickAmount=1
     XPReward=50
     MissionGoal=20
     Description="Kill Cosmic monsters."
     PickupClass=Class'DEKExtras999X.ArtifactMissionStarHuntPickup'
     IconMaterial=Texture'MissionsTex6.HuntMissions.StarHuntMission'
     ItemName="Star Hunt"
}
