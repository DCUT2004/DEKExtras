class ArtifactMissionAquaman extends ArtifactMission
		config(UT2004RPG);

function Activate()
{
	Super(ArtifactMission).Activate();
	
	if ((Instigator != None) && (Instigator.Controller != None))
	{
		if (Inv == None || M1Inv == None || M2Inv == None || M3Inv == None)
		{
			Instigator.ReceiveLocalizedMessage(MessageClass, 1000, None, None, Class);
			bActive = false;
			GotoState('');
			return;
		}
		if (!M1Inv.Stopped && !M2Inv.Stopped && !M3Inv.Stopped)
		{
			Instigator.ReceiveLocalizedMessage(MessageClass, 2000, None, None, Class);
			bActive = false;
			GotoState('');
			return;
		}
		if (M1Inv.AquamanActive || M2Inv.AquamanActive || M3Inv.AquamanActive)
		{
			Instigator.ReceiveLocalizedMessage(MessageClass, 4000, None, None, Class);
			bActive = false;
			GotoState('');
			return;
		}
		if (Inv.AquamanComplete)
		{
			Instigator.ReceiveLocalizedMessage(MessageClass, 6000, None, None, Class);
			bActive = false;
			GotoState('');
			return;
		}
		else
		{
			if (M1Inv.stopped)
			{
				M1Inv.Stopped = False;
				M1Inv.MissionXP = XPReward;
				M1Inv.MissionGoal = MissionGoal;
				M1Inv.AquamanActive = True;
				M1Inv.MissionName = default.ItemName;
				M1Inv.SetTimer(M1Inv.CheckInterval, True);
			}
			else if (M2Inv.stopped)
			{
				M2Inv.Stopped = False;
				M2Inv.MissionXP = XPReward;
				M2Inv.MissionGoal = MissionGoal;
				M2Inv.AquamanActive = True;
				M2Inv.MissionName = default.ItemName;
				M2Inv.SetTimer(M2Inv.CheckInterval, True);
			}
			else if (M3Inv.stopped)
			{
				M3Inv.Stopped = False;
				M3Inv.MissionXP = XPReward;
				M3Inv.MissionGoal = MissionGoal;
				M3Inv.AquamanActive = True;
				M3Inv.MissionName = default.ItemName;
				M3Inv.SetTimer(M3Inv.CheckInterval, True);
			}
			Instigator.ReceiveLocalizedMessage(MessageClass, 7000, None, None, Class);
			if (PlayerController(Instigator.Controller) != None)
			PlayerController(Instigator.Controller).ClientPlaySound(Sound'AssaultSounds.HumanShip.HnShipFireReadyl01');
			SetTimer(0.2,True);
		}
	}
	bActive = false;
	GotoState('');
	return;		
}

static function string GetLocalString(optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2)
{
	if (Switch == 1000)
		return "Cannot access mission.";
	else if (Switch == 2000)
		return "You currently have too many active missions.";
	else if (Switch == 3000)
		return "Mission activated!";
	if (Switch == 4000)
		return "Mission is already active.";
	else if (Switch == 5000)
		return "Mission forfeited.";
	else if (Switch == 6000)
		return "Mission already completed.";
	else if (Switch == 7000)
		return "Make kills while underwater!";
}

defaultproperties
{
     XPReward=50
     MissionGoal=50
     Description="Make kills while underwater."
     PickupClass=Class'DEKExtras999X.ArtifactMissionAquamanPickup'
     IconMaterial=Texture'MissionsTex6.MiscellaneousMissions.AquamanMission'
     ItemName="Aquaman"
}
