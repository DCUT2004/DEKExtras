class ArtifactTimedMission extends ArtifactMissionBETA
		config(Missions);
		
var Class<TimedMissionInv> TimedMissionClass;
var TimedMissionInv TimedMission;

function Activate()
{
	local MissionInvBETA MissionInv;
	
	Super.Activate();
	
	if (Instigator == None || Instigator.Controller == None)
		return;
	
	MissionInv = Class'MissionInvBETA'.static.GetMissionInv(Instigator.Controller);
	
	if (MissionInv == None)
		return;
		
	if (MissionInv.IsMissionCompleted(ItemName))
		return;		//So we don't give another inventory item if mission is already active or completed
	
	TimedMission = TimedMissionInv(Instigator.FindInventoryType(TimedMissionClass));
	if (TimedMission == None)
	{
		TimedMission = Instigator.Spawn(TimedMissionClass);
		TimedMission.Instigator = Instigator;
		TimedMission.Goal = MissionGoal;
		TimedMission.MissionName = ItemName;
		TimedMission.GiveTo(Instigator);
	}
}

defaultproperties
{
}
