//////////////////////////////////////
// /Development/Src/<Game>/Classes/MyPlayerController.uc
//
// A player controller that allows the player to switch to crawling mode,
// allowing him to climb walls and roofs
//
// Demo video : http://www.youtube.com/watch?v=hcomluMivVU
//
// Disclaimer : I did not write all the code myself as I picked different parts on forums and others sources.
//				(I believe most of it came from http://forums.epicgames.com/showpost.php?p=27073518&postcount=10)
// Bugs : This is an unfinished prototyping version developped with the August 2010 version of the UDK
//		  The main problem is the pawn model rotation that does not work with modern versions of the UDK (see line 191)

class MyPlayerController extends UTPlayerController;

var 		vector OldFloor;
var input 	bool bIsCrawling; // Defines if the pawn is currently crawlin
var 		bool bCanCrawl;
var vector ViewX,ViewY,ViewZ;
/* Uncomment to use 3rd person view, used to debug model rotation
event Possess(Pawn inPawn, bool bVehicleTransition)
{
	Super.Possess(inPawn, bVehicleTransition);
	SetBehindView(true);
}
*/

// Console command used to start crawling
exec function Crawl()
{
	if ( bCanCrawl )
		GotoState('PlayerSpidering');
}

// Console ocmmand used to stop crawling
exec function UnCrawl()
{
	if ( bIsCrawling )
	{
		Pawn.SetPhysics(PHYS_Walking);
		GotoState('PlayerWalking');
	}
}

// Console command used to switch crawling mode on/off (better used with a key binding for example)
exec function ToggleCrawl()
{
	//`log("toggle");

	if ( bIsCrawling )
	{
		Pawn.SetPhysics(PHYS_Walking);
		GotoState('PlayerWalking');
	}
	else if ( bCanCrawl )
		GotoState('PlayerSpidering');
}

// This method overrides the standard rotation computing.
// Needed because when we turn off the crawling mode, the camera and model will most likely
// have a wierd rotation, so here while in walking mode we smoothly rotate the view back to normal
function UpdateRotation( float DeltaTime )
{
	local Rotator	DeltaRot, newRotation, ViewRotation;

	ViewRotation = Rotation;
	if (Pawn!=none)
	{
		Pawn.SetDesiredRotation(ViewRotation);
	}

	// Calculate Delta to be applied on ViewRotation
	DeltaRot.Yaw	= PlayerInput.aTurn;
	DeltaRot.Pitch	= PlayerInput.aLookUp;

	ProcessViewRotation( DeltaTime, ViewRotation, DeltaRot );
	SetRotation(ViewRotation);

	ViewShake( deltaTime );

	NewRotation = ViewRotation;

	if( Rotation.Roll != 0)
	{
		NewRotation.Roll = Rotation.Roll - (Rotation.Roll * deltaTime * 6);
		//`log("Adjusting roll to " $ NewRotation.Roll);
	}
	else
		NewRotation.Roll = 0;

	if ( Pawn != None )
		Pawn.FaceRotation(NewRotation, deltatime);
	SetRotation(NewRotation);
}

// Crawling state
state PlayerSpidering
{
ignores SeePlayer, HearNoise, Bump;

    event bool NotifyHitWall(vector HitNormal, actor HitActor)
    {
		//`log("hit wall");

        Pawn.SetPhysics(PHYS_Spider);
        Pawn.SetBase(HitActor, HitNormal);
        return true;
    }

	// Resume crawling after a jump lands on something else than a floor
    event NotifyFallingHitWall(vector HitNormal, actor HitActor)
    {
		//`log("falling hit wall");

        Pawn.SetPhysics(PHYS_Spider);
        Pawn.SetBase(HitActor, HitNormal);
	}

    // if crawling mode, update rotation based on floor
    function UpdateRotation(float DeltaTime)
    {
        local rotator ViewRotation;
        local vector MyFloor, CrossDir, FwdDir, OldFwdDir, OldX, RealFloor;

        if ( (Pawn.Base == None) || (Pawn.Floor == vect(0,0,0)) )
        {
            MyFloor = vect(0,0,1);
        }
        else
        {
            MyFloor = Pawn.Floor;
        }
        if ( MyFloor != OldFloor )
        {
            // smoothly transition between floors
            RealFloor = MyFloor;
            MyFloor = Normal(6*DeltaTime * MyFloor + (1 - 6*DeltaTime) * OldFloor);

            if ( (RealFloor dot MyFloor) > 0.999 )
   	    	{
      	        MyFloor = RealFloor;
            }
            else
            {
            	// translate view direction
                CrossDir = Normal(RealFloor Cross OldFloor);
                FwdDir = CrossDir cross MyFloor;
                OldFwdDir = CrossDir cross OldFloor;
                ViewX = MyFloor * (OldFloor dot ViewX) + CrossDir * (CrossDir dot ViewX) + FwdDir * (OldFwdDir dot ViewX);
                ViewX = Normal(ViewX);
                ViewZ = MyFloor * (OldFloor dot ViewZ) + CrossDir * (CrossDir dot ViewZ) + FwdDir * (OldFwdDir dot ViewZ);
                ViewZ = Normal(ViewZ);
                OldFloor = MyFloor;
                ViewY = Normal(MyFloor cross ViewX);

                Pawn.mesh.SetRotation(OrthoRotation(ViewX,ViewY,ViewZ));
            }
        }

        if ( (PlayerInput.aTurn != 0) || (PlayerInput.aLookUp != 0) )
        {
            // adjust Yaw based on aTurn
            if ( PlayerInput.aTurn != 0 )
            {
                ViewX = Normal(ViewX + 2 * ViewY * Sin(0.0005*DeltaTime*PlayerInput.aTurn));
            }

            // adjust Pitch based on aLookUp
            if ( PlayerInput.aLookUp != 0 )
            {
                OldX = ViewX;
                ViewX = Normal(ViewX + 2 * ViewZ * Sin(0.0005*DeltaTime*PlayerInput.aLookUp));
                ViewZ = Normal(ViewX Cross ViewY);

                // bound max pitch
                if ( (ViewZ dot MyFloor) < 0.1   )
                {
		    		ViewX = OldX;
                }
            }

            // calculate new Y axis
            ViewY = Normal(MyFloor cross ViewX);
        }
        ViewRotation =  OrthoRotation(ViewX,ViewY,ViewZ);
        SetRotation(ViewRotation);
        if(Pawn != None)
        	Pawn.SetRotation(ViewRotation);

        //SET PAWN ROTATION WITH RESPECT TO FLOOR NORMALS HERE
		// Does not work anymore.. will need some debugging
        //Pawn.mesh.SkeletalMesh.Rotation = Pawn.Rotation;

    }

	// Resume crawling after a jump lands on a floor
    function bool NotifyLanded(vector HitNormal, Actor FloorActor)
    {
		//`log("landed");
        Pawn.SetPhysics(PHYS_Spider);
        return bUpdating;
    }

	// Do not use crawling while in water
    event NotifyPhysicsVolumeChange( PhysicsVolume NewVolume )
    {
        if ( NewVolume.bWaterVolume )
        {
            GotoState(Pawn.WaterMovementState);
        }
    }

    function ProcessMove(float DeltaTime, vector NewAccel, eDoubleClickDir DoubleClickMove, rotator DeltaRot)
    {
		if ( Pawn != None )
		{
	        if ( Pawn.Acceleration != NewAccel )
	        {
	            Pawn.Acceleration = NewAccel;
	        }
	
	        if ( bPressedJump )
	        {
	            Pawn.DoJump(bUpdating);
	        }
		}
    }

    function PlayerMove( float DeltaTime )
    {
        local vector NewAccel;
        local eDoubleClickDir DoubleClickMove;
        local rotator OldRotation, ViewRotation;
        local bool  bSaveJump;

        GroundPitch = 0;
        ViewRotation = Rotation;

        //Pawn.CheckBob(DeltaTime,vect(0,0,0));

        // Update rotation.
        SetRotation(ViewRotation);
        OldRotation = Rotation;
        UpdateRotation(DeltaTime);

        // Update acceleration.
        NewAccel = PlayerInput.aForward*Normal(ViewX - OldFloor * (OldFloor Dot ViewX)) + PlayerInput.aStrafe*ViewY;

        if ( VSize(NewAccel) < 1.0 )
        {
            NewAccel = vect(0,0,0);
        }

        if ( bPressedJump && Pawn.CannotJumpNow() )
        {
            bSaveJump = true;
            bPressedJump = false;
        }
        else
            bSaveJump = false;

        DoubleClickMove = DCLICK_None;
        ProcessMove(DeltaTime, NewAccel, DoubleClickMove, OldRotation - Rotation);
        bPressedJump = bSaveJump;
    }

    event BeginState(Name PreviousStateName)
    {
		//`log("spider with roll " $ Rotation.Roll);
        OldFloor = vect(0,0,1);
        GetAxes(Rotation,ViewX,ViewY,ViewZ);
        DoubleClickDir = DCLICK_None;
        Pawn.ShouldCrouch(false);
        bPressedJump = false;

        if (Pawn.Physics != PHYS_Falling)
        {
            Pawn.SetPhysics(PHYS_Spider);
        }

        GroundPitch = 0;
        Pawn.bCrawler = true;
        bIsCrawling = true;
    }

    event EndState(Name NextStateName)
    {
		//`log("unspider with roll" $ Rotation.Roll);
        GroundPitch = 0;
        if ( Pawn != None )
        {
            Pawn.ShouldCrouch(false);
            Pawn.bCrawler = Pawn.default.bCrawler;
        }
        bIsCrawling = false;
    }
}

defaultproperties
{
	Name="Default__MyPlayerController"

	bNotifyFallingHitWall=true

	// Crawling configuration
	bCanCrawl=true
}