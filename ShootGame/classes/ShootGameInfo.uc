class ShootGameInfo extends UTGame;
///¸ü¸Ä³õÊ¼ÎäÆ÷
simulated function AddDefaultInventory( pawn PlayerPawn )
{
	local int i;
	//local UTAmmoPickupFactory overShield;
	//overShield = Spawn(class'UTAmmoPickUpFactory');


	/*
	//-may give the physics gun to non-bots
	if(PlayerPawn.IsHumanControlled() )
	{
		PlayerPawn.CreateInventory(class'ShootWeap_LinkGun',true);
		//overShield.GiveTo(PlayerPawn);

	}
	*/

	for (i=0; i<DefaultInventory.Length; i++)
	{
		//-Ensure we don't give duplicate items
		if (PlayerPawn.FindInventoryType( DefaultInventory[i] ) == None)
		{
			//-Only activate the first weapon
			PlayerPawn.CreateInventory(DefaultInventory[i], (i > 0));
		}
	}
	`Log("Adding inventory");
	PlayerPawn.AddDefaultInventory();

}

DefaultProperties
{
	
	DefaultPawnClass=class'ShootGame.UDNPawn_UpDown' 

	PlayerControllerClass=class'ShootGame.UDNPlayerController_UpDown'

	Acronym="IT"
    MapPrefixes[0]="IT"
	//DefaultInventory(0)=class'ShootGame.ShootWeap_LinkGun'

	DefaultInventory(0)=class'ShootGame.ShootWeap_RocketLaucher'
}
