class ArtifactTimedMission extends ArtifactMissionBETA
		config(Missions);
		
var Class<TimedMissionInv> TimedMissionClass;
var TimedMissionInv TimedMission;

function Activate()
{
	local MissionInvBETA MissionInv;
	
	if (Instigator == None || Instigator.Controller == None)
		return;
		
	MissionInv = class'MissionInvBETA'.static.GetMissionInv(Instigator.Controller);
	
	if (MissionInv == None)
	{
		Instigator.ReceiveLocalizedMessage(MessageClass, 1, None, None, Class);
		bActive = false;
		GotoState('');
		return;	
	}
	
	//Check if all missions slots are alaready active
	if (MissionInv.IsAllMissionsActive())
	{
		Instigator.ReceiveLocalizedMessage(MessageClass, 2, None, None, Class);
		bActive = false;
		GotoState('');
		return;				
	}
	
	//Check if this mission is already active
	if (MissionInv.IsMissionActive(ItemName))
	{
		Instigator.ReceiveLocalizedMessage(MessageClass, 4, None, None, Class);
		bActive = false;
		GotoState('');
		return;			
	}
	
	//Check if this mission was already completed
	if (MissionInv.IsMissionCompleted(ItemName))
	{
		Instigator.ReceiveLocalizedMessage(MessageClass, 6, None, None, Class);
		bActive = false;
		GotoState('');
		return;		
	}
	
	AdjustRewardAndGoalValues(GetRPGLevel(Instigator));
	
	if (!MissionInv.SetMission(ItemName, MissionGoal, XPReward, ObjectiveClasses))
	{
		Instigator.ReceiveLocalizedMessage(MessageClass, 1, None, None, Class);
		bActive = false;
		GotoState('');
		return;
	}
	
	
	TimedMission = TimedMissionInv(Instigator.FindInventoryType(TimedMissionClass));
	if (TimedMission == None)
	{
		TimedMission = Instigator.Spawn(TimedMissionClass);
		TimedMission.Instigator = Instigator;
		TimedMission.Goal = MissionGoal;
		TimedMission.MissionName = ItemName;
		TimedMission.GiveTo(Instigator);
		Instigator.ReceiveLocalizedMessage(MessageClass, 7, None, None, Class);
		if (PlayerController(Instigator.Controller) != None)
			PlayerController(Instigator.Controller).ClientPlaySound(Sound'AssaultSounds.HumanShip.HnShipFireReadyl01');
		SetTimer(0.2,True);
	}
}

function Timer()
{
	setTimer(0, false);
	Destroy();
	Instigator.NextItem();
}

defaultproperties
{
}
