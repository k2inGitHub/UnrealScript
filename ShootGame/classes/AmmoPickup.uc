class AmmoPickup extends UTAmmoPickupFactory;
auto state Pickup
{
	/* ValidTouch()
	 Validate touch (if valid return true to let other pick me up and trigger event).
	*/
	function bool ValidTouch( Pawn Other )
	{
		local UTWeapon W;
		W = UTWeapon(Other.FindInventoryType(TargetWeapon));
		//////只能主角捡起
		if(!Other.IsA('UDNPawn_UpDown'))
		{
			return false;
		}

		if ( !Super.ValidTouch(Other) )
		{
			return false;
		}

		if ( UTInventoryManager(Other.InvManager) != none)
		{
			//Worldinfo.Game.Broadcast(self, "Touch" );
			if(Other.IsA('UDNPawn_UpDown'))
			{
				
				//Worldinfo.Game.Broadcast(self, "P.type : " @ Other);
				if(UDNPawn_UpDown(Other).ProjLevel<3)
				{
					if(W!=None)
				{
					//Worldinfo.Game.Broadcast(self, "Interval : " @ W.FireInterval[1]);
					W.FireInterval[1]-=0.2;

				}
					UDNPawn_UpDown(Other).ProjLevel++;
				}
			}
		  return UTInventoryManager(Other.InvManager).NeedsAmmo(TargetWeapon);
		}

		return true;
	}

	/* DetourWeight()
	value of this path to take a quick detour (usually 0, used when on route to distant objective, but want to grab inventory for example)
	*/
	function float DetourWeight(Pawn P,float PathWeight)
	{
		local UTWeapon W;

		W = UTWeapon(P.FindInventoryType(TargetWeapon));
		if ( W != None )
		{
			return W.DesireAmmo(true) * MaxDesireability / PathWeight;
			
			
		}
		return 0;
	}
}

/*
simulated function float BotDesireability(Pawn P, Controller C)
{
	local UTWeapon W;
	local UTBot Bot;
	local float Result;

	

	Bot = UTBot(C);
	if (Bot != None && !Bot.bHuntPlayer)
	{
		W = UTWeapon(P.FindInventoryType(TargetWeapon));
		if ( W != None )
		{
			Result = W.DesireAmmo(false) * MaxDesireability;
			// increase desireability for the bot's favorite weapon
			if (ClassIsChildOf(TargetWeapon, Bot.FavoriteWeapon))
			{
				Result *= 1.5;
			}
			if(P.IsA('UDNPawn_UpDown'))
			{

				Worldinfo.Game.Broadcast(self, "P.type : " @ P);
				if(UDNPawn_UpDown(P).ProjLevel<3)
				UDNPawn_UpDown(P).ProjLevel++;
			}
				
		}
	}
	return Result;
}
*/

defaultproperties
{
	bNoDelete = false;
	bStatic = false;
	AmmoAmount=10
	TargetWeapon=class'ShootWeap_LinkGun'
	PickupSound=SoundCue'A_Pickups.Ammo.Cue.A_Pickup_Ammo_Link_Cue'
	MaxDesireability=0.28

	Begin Object Name=AmmoMeshComp
		StaticMesh=StaticMesh'Pickups.Ammo_Link.Mesh.S_Ammo_LinkGun'
		Translation=(X=0.0,Y=0.0,Z=-15.0)
	End Object

	Begin Object Name=CollisionCylinder
		CollisionHeight=14.4
	End Object
}