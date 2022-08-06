class ArtifactMissionTippyToes extends ArtifactTimedMission
		config(Missions);

defaultproperties
{
	TimedMissionClass=Class'TimedMissionTippyToesInv'
	XPReward=30
	MissionGoal=60
	Description="Keep moving!"
	PickupClass=Class'DEKExtras999X.ArtifactMissionTippyToesPickup'
	IconMaterial=Texture'MissionsTex6.MiscellaneousMissions.TippyToesMission'
	ItemName="Tippy Toes"
}
