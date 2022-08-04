class ArtifactMissionEmeraldShatter extends ArtifactMissionBETA
		config(Missions);

defaultproperties
{
	 ObjectiveClasses(0)=Class'DEKMonsters999X.NecroGhostPossessor'
	 ObjectiveClasses(1)=Class'DEKMonsters999X.NecroGhostPossessorMonsterInv'
	 TickAmount=1
     XPReward=50
     MissionGoal=7
     Description="Kill monsters spawned by the emerald orb."
     PickupClass=Class'DEKExtras999X.ArtifactMissionEmeraldShatterPickup'
     IconMaterial=Texture'MissionsTex6.MiscellaneousMissions.EmeraldShatter'
     ItemName="Emerald Shatter"
}
