class ArtifactMissionHalt extends ArtifactTimedMission
		config(Missions);

defaultproperties
{
	TimedMissionClass=Class'TimedMissionHaltInv'
	XPReward=50
	MissionGoal=30
	Description="Survive while frozen!"
	PickupClass=Class'DEKExtras999X.ArtifactMissionHaltPickup'
	IconMaterial=Texture'MissionsTex6.MiscellaneousMissions.HaltMission'
	ItemName="Halt!"
}
