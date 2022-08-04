class ArtifactMissionBugHunt extends ArtifactMissionBETA
		config(UT2004RPG);

defaultproperties
{
	 ObjectiveClasses(0)=Class'SkaarjPack.SkaarjPupae'
	 ObjectiveClasses(1)=Class'SkaarjPack.Manta'
	 ObjectiveClasses(2)=Class'SkaarjPack.Razorfly'
	 TickAmount=1
     XPReward=20
     MissionGoal=35
     Description="Kill pupae, razorfly, and mantas."
     PickupClass=Class'DEKExtras999X.ArtifactMissionBugHuntPickup'
     IconMaterial=Texture'MissionsTex6.HuntMissions.BugHuntMission'
     ItemName="Bug Hunt"
}
