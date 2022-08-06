class ArtifactMissionFeatherweight extends ArtifactTimedMission
		config(Missions);

defaultproperties
{
	TimedMissionClass=Class'TimedMissionFeatherweightInv'
	XPReward=50
	MissionGoal=5
	Description="Remain airbone without boots or translocator."
	PickupClass=Class'DEKExtras999X.ArtifactMissionFeatherweightPickup'
	IconMaterial=Texture'MissionsTex6.MiscellaneousMissions.FeatherWeightMission'
	ItemName="Featherweight"
}
