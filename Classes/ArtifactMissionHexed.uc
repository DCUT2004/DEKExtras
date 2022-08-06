class ArtifactMissionHexed extends ArtifactTimedMission
		config(Missions);
		
defaultproperties
{
	TimedMissionClass=Class'TimedMissionHexedInv'
	XPReward=50
	MissionGoal=60
	Description="You will lose health. Survive the duration of the hex."
	PickupClass=Class'DEKExtras999X.ArtifactMissionHexedPickup'
	IconMaterial=Texture'MissionsTex6.MiscellaneousMissions.HexedMission'
	ItemName="Hexed"
}
