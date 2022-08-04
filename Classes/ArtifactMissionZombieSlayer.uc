class ArtifactMissionZombieSlayer extends ArtifactMissionBETA
		config(Missions);

defaultproperties
{
	 ObjectiveClasses(0)=Class'DEKMonsters999X.NecroSorcerer'
	 ObjectiveClasses(1)=Class'DEKMonsters999X.NecroSorcererResurrectedInv'	
	 TickAmount=1
     MissionGoal=5
     Description="Kill monsters resurrected by a Sorcerer."
     PickupClass=Class'DEKExtras999X.ArtifactMissionZombieSlayerPickup'
     IconMaterial=Texture'MissionsTex6.MiscellaneousMissions.ZombieSlayerMission'
     ItemName="Zombie Slayer"
}
