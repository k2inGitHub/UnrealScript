class ShootWeapon extends UTWeapon;


simulated function FireAmmunition()
{
	
	if (CurrentFireMode >= bZoomedFireMode.Length || bZoomedFireMode[CurrentFireMode] == 0)
	{
		// if this is the local player, play the firing effects
		PlayFiringSound();
////////////////////////////////////////////////
		// Use ammunition to fire
	ConsumeAmmo( CurrentFireMode );

	// Handle the different fire types
	switch( WeaponFireTypes[CurrentFireMode] )
	{
		case EWFT_InstantHit:
			InstantFire();
			break;

		case EWFT_Projectile:
			ProjectileFire_B();
			break;

		case EWFT_Custom:
			//CustomFire();
			ProjectileFire_A();
			break;

	

	}

	NotifyWeaponFired( CurrentFireMode );
	/////////////////////////////////////////////////
		
		

		if (UTPawn(Instigator) != None)
		{
			UTPawn(Instigator).DeactivateSpawnProtection();
		}

		UTInventoryManager(InvManager).OwnerEvent('FiredWeapon');
	}
}



Function ProjectileFire_A(){
}

Function ProjectileFire_B(){
}
   function Attack()
    {
        local int i;
        local rotator MyRot;
        local UTProj_Rocket MyRocket;
		local vector		RealStartLoc;
		//local vector		test;
		//local vector		sh;

		RealStartLoc = GetPhysicalFireStartLoc();
		//test=Vector(GetAdjustedAim( RealStartLoc ));
		MyRot=GetAdjustedAim( RealStartLoc );
		MyRot.Yaw-=3/2*2048;
		//sh.x=0.2;
		//sh.Y=0.75;
		//test=test-sh;
		
        for(i=0; i<3; i++)
        {
			
			/*
			if(i==0)
				MyRot.Yaw =-2048;
			else
				MyRot.Yaw += 2048;
				*/
			`log(3/2);
			//test=test+sh;  
			MyRot.Yaw += 2048;
            MyRocket = spawn(class'UTProj_Rocket', /*self*/,,RealStartLoc/* Location*/);
			MyRocket.Instigator=UTPawn(Instigator);
			MyRocket.Init(Vector(MyRot));
            //MyRocket.Init(normal(Enemy.Location - Location)); // To shoot at player location
        }
    }


DefaultProperties
{

}
