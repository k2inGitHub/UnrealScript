class ShootPickup_Armor extends UTArmorPickup_Thighpad;

auto state Pickup
{
	/* DetourWeight()
	value of this path to take a quick detour (usually 0, used when on route to distant objective, but want to grab inventory for example)
	*/
	function float DetourWeight(Pawn P,float PathWeight)
	{
		local float Need;
		local UTPawn Other;

		Other = UTPawn(P);
		if ( Other == None )
			return 0;
		Need = CanUseShield(Other);
		if ( UTBot(Other.Controller).PriorityObjective() && (Need < 0.4 * ShieldAmount) )
			return (0.005 * MaxDesireability * Need)/PathWeight;
		if ( Need <= 0 )
		{
			if ( !WorldInfo.Game.bTeamGame )
				Need = 0.5;
			else
				return 0;
		}
		else if ( !WorldInfo.Game.bTeamGame )
			Need = FMax(Need,0.6);
		return (0.013 * MaxDesireability * Need)/PathWeight;
	}

	/* ValidTouch()
	 Validate touch (if valid return true to let other pick me up and trigger event).
	*/
	function bool ValidTouch( Pawn Other )
	{
		//////只能主角捡起
		if(!Other.IsA('UDNPawn_UpDown'))
		{
			return false;
		}

		if ( !Super.ValidTouch(Other) )
		{
			return false;
		}

		// does Other need armor?
		return ( (CanUseShield(UTPawn(Other)) > 0) || !WorldInfo.Game.bTeamGame );
	}
}

DefaultProperties
{
	bNoDelete = false;
	bStatic = false;
	/*
	ShieldAmount=100
	//TargetPawn=
	PickupSound=SoundCue'A_Pickups.Shieldbelt.Cue.A_Pickups_Shieldbelt_Activate_Cue'
	MaxDesireability=0.28

	Begin Object Name=ArmorPickUpComp
	    StaticMesh=StaticMesh'Pickups.Armor_ShieldBelt.Mesh.S_UN_Pickups_Shield_Belt'
		Scale3D=(X=1.5,Y=1.5,Z=1.5)
	End Object
	*/

}
