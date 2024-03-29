class ShootWeap_RocketLaucher_C extends ShootWeap_ShockRifleBase;

// AI properties (for shock combos)
var UTProj_ShockBall ComboTarget;
var bool bRegisterTarget;
var bool bWaitForCombo;
var vector ComboStart;

var bool bWasACombo;
var int CurrentPath;

var int ShootCount;
//-----------------------------------------------------------------
// AI InterFface
function float GetAIRating()
{
	local UTBot B;

	B = UTBot(Instigator.Controller);
	if ( (B == None) || (B.Enemy == None) || Pawn(B.Focus) == None )
		return AIRating;

	if ( bWaitForCombo )
		return 1.5;
	if ( !B.ProficientWithWeapon() )
		return AIRating;
	if ( B.Stopped() )
	{
		if ( !B.LineOfSightTo(B.Enemy) && (VSize(B.Enemy.Location - Instigator.Location) < 5000) )
			return (AIRating + 0.5);
		return (AIRating + 0.3);
	}
	else if ( VSize(B.Enemy.Location - Instigator.Location) > 1600 )
		return (AIRating + 0.1);
	else if ( B.Enemy.Location.Z > B.Location.Z + 200 )
		return (AIRating + 0.15);

	return AIRating;
}


/**
* Overriden to use GetPhysicalFireStartLoc() instead of Instigator.GetWeaponStartTraceLocation()
* @returns position of trace start for instantfire()
*/
simulated function vector InstantFireStartTrace()
{
	return GetPhysicalFireStartLoc();
}

function SetComboTarget(UTProj_ShockBall S)
{
	if ( !bRegisterTarget || (UTBot(Instigator.Controller) == None) || (Instigator.Controller.Enemy == None) )
		return;

	bRegisterTarget = false;
	bWaitForCombo = true;
	ComboStart = Instigator.Location;
	ComboTarget = S;
	ComboTarget.Monitor(UTBot(Instigator.Controller).Enemy);
}

function float RangedAttackTime()
{
	local UTBot B;

	B = UTBot(Instigator.Controller);
	if ( (B == None) || (B.Enemy == None) )
		return 0;

	if ( B.CanComboMoving() )
		return 0;

	return FMin(2,0.3 + VSize(B.Enemy.Location - Instigator.Location)/class'UTProj_ShockBall'.default.Speed);
}

function float SuggestAttackStyle()
{
	return -0.4;
}

simulated function StartFire(byte FireModeNum)
{
	if ( bWaitForCombo && (UTBot(Instigator.Controller) != None) )
	{
		if ( (ComboTarget == None) || ComboTarget.bDeleteMe )
			bWaitForCombo = false;
		else
			return;
	}
	Super.StartFire(FireModeNum);
}

function DoCombo()
{
	if ( bWaitForCombo )
	{
		bWaitForCombo = false;
		if ( (Instigator != None) && (Instigator.Weapon == self) )
		{
			StartFire(0);
		}
	}
}

function ClearCombo()
{
	ComboTarget = None;
	bWaitForCombo = false;
}

/* BestMode()
choose between regular or alt-fire
*/
function byte BestMode()
{
	local float EnemyDist;
	local UTBot B;

	bWaitForCombo = false;
	B = UTBot(Instigator.Controller);
	if ( (B == None) || (B.Enemy == None) )
		return 0;

	if (B.IsShootingObjective())
		return 0;

	if ( !B.LineOfSightTo(B.Enemy) )
	{
		if ( (ComboTarget != None) && !ComboTarget.bDeleteMe && B.CanCombo() )
		{
			bWaitForCombo = true;
			return 0;
		}
		ComboTarget = None;
		if ( B.CanCombo() && B.ProficientWithWeapon() )
		{
			bRegisterTarget = true;
			return 1;
		}
		return 0;
	}

	EnemyDist = VSize(B.Enemy.Location - Instigator.Location);

	if ( (EnemyDist > 4*class'UTProj_ShockBall'.default.Speed) || (EnemyDist < 150) )
	{
		ComboTarget = None;
		return 0;
	}

	if ( (ComboTarget != None) && !ComboTarget.bDeleteMe && B.CanCombo() )
	{
		bWaitForCombo = true;
		return 0;
	}

	ComboTarget = None;

	if ( (EnemyDist > 2500) && (FRand() < 0.5) )
		return 0;

	if ( B.CanCombo() && B.ProficientWithWeapon() )
	{
		bRegisterTarget = true;
		return 1;
	}

	// consider using altfire to block incoming enemy fire
	if (EnemyDist < 1000.0 && B.Enemy.Weapon != None && B.Enemy.Weapon.Class != Class && B.ProficientWithWeapon())
	{
		return (FRand() < 0.3) ? 0 : 1;
	}
	else
	{
		return (FRand() < 0.7) ? 0 : 1;
	}
}

// for bot combos
simulated function Projectile ProjectileFire()
{
	local Projectile p;

	p = Super.ProjectileFire();
	if (UTProj_ShockBall(p) != None)
	{
		SetComboTarget(UTProj_ShockBall(P));
	}
	return p;
}

simulated function ProjectileFire_A(){

	
	 if(ShootCount%2==0)
	{
		ProjectileFire_Circle();
	}
	
	

	if(ShootCount%4==0)
	{
		ProjectileFire_F();
		//Fire_F();
	}
	else if(ShootCount%4==1)
	{
		ProjectileFire_D();
		//Fire_D();
	}
	else if(ShootCount%4==2)
	{
		ProjectileFire_C();
		//Fire_C();
	}
	else if(ShootCount%4==3)
	{
		ProjectileFire_E();
		//Fire_E();
	}
	ShootCount++;
	//SetTimer(0.3,false,'ProjectileFire_E');
	//SetTimer(0.6,false,'ProjectileFire_D');
	//SetTimer(0.9,false,'ProjectileFire_C');

}

simulated function Fire_F(){
		local int n;//每排子弹个数
		local int i;
        local rotator MyRot;
        local ShootProj_SB_Blue MyShockBall;
		local vector		RealStartLoc;

		n=10;


		RealStartLoc = GetPhysicalFireStartLoc();//射击位置
		MyRot=GetAdjustedAim( RealStartLoc );
			
        for(i=0; i<n; i++)
        {
			MyRot.Yaw += 3276*2;
            MyShockBall = spawn(class'ShootProj_SB_Blue', /*self*/,,RealStartLoc/* Location*/);
			MyShockBall.Instigator=UTPawn(Instigator);
			MyShockBall.Init(Vector(MyRot));
        }
		
}

simulated function Fire_E(){
		local int n;//每排子弹个数
		local int i;
        local rotator MyRot;
        local ShootProj_SB_Red MyShockBall;
		local vector		RealStartLoc;

		n=10;


		RealStartLoc = GetPhysicalFireStartLoc();//射击位置
		MyRot=GetAdjustedAim( RealStartLoc );
			
        for(i=0; i<n; i++)
        {
			MyRot.Yaw += 3276*2;
            MyShockBall = spawn(class'ShootProj_SB_Red', /*self*/,,RealStartLoc/* Location*/);
			MyShockBall.Instigator=UTPawn(Instigator);
			MyShockBall.Init(Vector(MyRot));
        }
		
}

simulated function Fire_D(){
		local int n;//每排子弹个数
		local int i;
        local rotator MyRot;
        local ShootProj_SB_Gold MyShockBall;
		local vector		RealStartLoc;

		n=10;


		RealStartLoc = GetPhysicalFireStartLoc();//射击位置
		MyRot=GetAdjustedAim( RealStartLoc );
			
        for(i=0; i<n; i++)
        {
			MyRot.Yaw += 3276*2;
            MyShockBall = spawn(class'ShootProj_SB_Gold', /*self*/,,RealStartLoc/* Location*/);
			MyShockBall.Instigator=UTPawn(Instigator);
			MyShockBall.Init(Vector(MyRot));
        }
		
}

simulated function Fire_C(){
		local int n;//每排子弹个数
		local int i;
        local rotator MyRot;
        local ShootProj_SB_Green MyShockBall;
		local vector		RealStartLoc;

		n=10;


		RealStartLoc = GetPhysicalFireStartLoc();//射击位置
		MyRot=GetAdjustedAim( RealStartLoc );
			
        for(i=0; i<n; i++)
        {
			MyRot.Yaw += 3276*2;
            MyShockBall = spawn(class'ShootProj_SB_Green', /*self*/,,RealStartLoc/* Location*/);
			MyShockBall.Instigator=UTPawn(Instigator);
			MyShockBall.Init(Vector(MyRot));
        }
		
}
/*
simulated function PostBeginPlay()
{
	Super.PostBeginPlay();//在父类中执行PostBeginPlay函数

   //SetTimer(1.0,true);//启动了Timer，它将会每秒钟执行一次，并且把它设置为循环状态
   
   
   
	SetTimer(4,true,'ProjectileFire_E');
	SetTimer(1,false,'Fire_D');
	SetTimer(2,false,'Fire_C');
	SetTimer(3,false,'Fire_F');

}
function Fire_D(){
	SetTimer(4,true,'ProjectileFire_D');
}
function Fire_C(){
	SetTimer(4,true,'ProjectileFire_C');
	}
function Fire_F(){
	SetTimer(4,true,'ProjectileFire_F');
	}
*/
simulated function ProjectileFire_F(){
		local int n;//每排子弹个数
		local int i;
        local rotator MyRot;
        local ShootProj_LinkPlasma_Blue MyShockBall;
		local vector		RealStartLoc;

		n=10;


		RealStartLoc = GetPhysicalFireStartLoc();//射击位置
		//MyRot=rotator(RealStartLoc);
		MyRot=GetAdjustedAim( Location );
			
        for(i=0; i<n; i++)
        {
			MyRot.Yaw += 3276*2;
            MyShockBall = spawn(class'ShootProj_LinkPlasma_Blue_Power', /*self*/,,RealStartLoc/* Location*/);
			MyShockBall.Instigator=UTPawn(Instigator);
			MyShockBall.RotatedInit(Vector(MyRot));

        }
		
}

simulated function ProjectileFire_E(){
		local int n;//每排子弹个数
		local int i;
        local rotator MyRot;
        local ShootProj_LinkPlasma_Gold MyShockBall;
		local vector		RealStartLoc;

		n=10;


		RealStartLoc = GetPhysicalFireStartLoc();//射击位置
		//MyRot=rotator(RealStartLoc);
		MyRot=GetAdjustedAim( Location );
			
        for(i=0; i<n; i++)
        {
			MyRot.Yaw += 3276*2;
            MyShockBall = spawn(class'ShootProj_LinkPlasma_Gold_power', /*self*/,,RealStartLoc/* Location*/);
			MyShockBall.Instigator=UTPawn(Instigator);
			MyShockBall.RotatedInit(Vector(MyRot));
        }
		
}

simulated function ProjectileFire_D(){
		local int n;//每排子弹个数
		local int i;
        local rotator MyRot;
        local ShootProj_LinkPlasma_Green MyShockBall;
		local vector		RealStartLoc;

		n=10;


		RealStartLoc = GetPhysicalFireStartLoc();//射击位置
		//MyRot=rotator(RealStartLoc);
		MyRot=GetAdjustedAim( Location );
			
        for(i=0; i<n; i++)
        {
			MyRot.Yaw += 3276*2;
            MyShockBall = spawn(class'ShootProj_LinkPlasma_Green', /*self*/,,RealStartLoc/* Location*/);
			MyShockBall.Instigator=UTPawn(Instigator);
			MyShockBall.RotatedInit(Vector(MyRot));
        }
		
}

simulated function ProjectileFire_C(){
		local int n;//每排子弹个数
		local int i;
        local rotator MyRot;
        local ShootProj_LinkPlasma_Red MyShockBall;
		local vector		RealStartLoc;

		n=10;


		RealStartLoc = GetPhysicalFireStartLoc();//射击位置
		//MyRot=rotator(RealStartLoc);
		MyRot=GetAdjustedAim( Location );
			
        for(i=0; i<n; i++)
        {
			MyRot.Yaw += 3276*2;
            MyShockBall = spawn(class'ShootProj_LinkPlasma_Red_Power', /*self*/,,RealStartLoc/* Location*/);
			MyShockBall.Instigator=UTPawn(Instigator);
			MyShockBall.RotatedInit(Vector(MyRot));
        }
		
}
simulated function ProjectileFire_B(){
	ProjectileFire_Circle();
	//SetTimer(0.5,false,'ProjectileFire_Circle');	
}

function ProjectileFire_Circle(){
		local int n;//每排子弹个数
		local int range;
		local int i;
        local rotator MyRot;
        local ShootProj_Ball MyShockBall;
		//local vector offset;
		//local UTProj_LinkPlasma Proj_L;
		//local UTProj_Rocket Rocket;
		local vector		RealStartLoc;

		n=3;
		range=3072;


		RealStartLoc = GetPhysicalFireStartLoc();//射击位置
		MyRot=GetAdjustedAim( RealStartLoc );
		//GetAxes(MyRot, CamDirX, CamDirY, CamDirZ);//获得坐标方向
		MyRot.Yaw-=range/2+range/(n-1);	
			
			

        for(i=0; i<n; i++)
        {
			MyRot.Yaw+=range/(n-1);
            MyShockBall = spawn(class'ShootProj_Ball', /*self*/,,(RealStartLoc)/* Location*/);
			MyShockBall.Instigator=UTPawn(Instigator);
			MyShockBall.MomentumInit(Vector(MyRot));
            //MyRocket.Init(normal(Enemy.Location - Location)); // To shoot at player location
            }
		

}


simulated function rotator GetAdjustedAim( vector StartFireLoc )
{
	local rotator ComboAim;

	// if ready to combo, aim at shockball
	if (UTBot(Instigator.Controller) != None && CurrentFireMode == 0 && ComboTarget != None && !ComboTarget.bDeleteMe)
	{
		// use bot yaw aim, so bots with lower skill/low rotation rate may miss
		ComboAim = rotator(ComboTarget.Location - StartFireLoc);
		ComboAim.Yaw = Instigator.Rotation.Yaw;
		return ComboAim;
	}

	return Super.GetAdjustedAim(StartFireLoc);
}

simulated state WeaponFiring
{
	/**
	 * Called when the weapon is done firing, handles what to do next.
	 */
	simulated event RefireCheckTimer()
	{
		if ( bWaitForCombo && (UTBot(Instigator.Controller) != None) )
		{
			if ( (ComboTarget == None) || ComboTarget.bDeleteMe )
				bWaitForCombo = false;
			else
			{
				StopFire(CurrentFireMode);
				GotoState('Active');
				return;
			}
		}

		Super.RefireCheckTimer();
	}
}

simulated function ImpactInfo CalcWeaponFire(vector StartTrace, vector EndTrace, optional out array<ImpactInfo> ImpactList, optional vector Extent)
{
	local ImpactInfo II;
	II = Super.CalcWeaponFire(StartTrace, EndTrace, ImpactList, Extent);
	bWasACombo = (II.HitActor != None && UTProj_ShockBall(II.HitActor) != none );
	return ii;
}

function SetFlashLocation( vector HitLocation )
{
	local byte NewFireMode;
	if( Instigator != None )
	{
		if (bWasACombo)
		{
			NewFireMode = 3;
		}
		else
		{
			NewFireMode = CurrentFireMode;
		}
		Instigator.SetFlashLocation( Self, NewFireMode , HitLocation );
	}
}


simulated function SetMuzzleFlashParams(ParticleSystemComponent PSC)
{
	local float PathValues[3];
	local int NewPath;
	Super.SetMuzzleFlashparams(PSC);
	if (CurrentFireMode == 0)
	{
		if ( !bWasACombo )
		{
			NewPath = Rand(3);
			if (NewPath == CurrentPath)
			{
				NewPath++;
			}
			CurrentPath = NewPath % 3;

			PathValues[CurrentPath % 3] = 1.0;
			PSC.SetFloatParameter('Path1',PathValues[0]);
			PSC.SetFloatParameter('Path2',PathValues[1]);
			PSC.SetFloatParameter('Path3',PathValues[2]);
		}
		else
		{
			PSC.SetFloatParameter('Path1',1.0);
			PSC.SetFloatParameter('Path2',1.0);
			PSC.SetFloatParameter('Path3',1.0);
		}
	}
	else
	{
		PSC.SetFloatParameter('Path1',0.0);
		PSC.SetFloatParameter('Path2',0.0);
		PSC.SetFloatParameter('Path3',0.0);
	}

}

simulated function PlayFireEffects( byte FireModeNum, optional vector HitLocation )
{
	if (FireModeNum>1)
	{
		Super.PlayFireEffects(0,HitLocation);
	}
	else
	{
		Super.PlayFireEffects(FireModeNum, HitLocation);
	}
}

defaultproperties
{
	// Weapon SkeletalMesh
	Begin Object class=AnimNodeSequence Name=MeshSequenceA
	End Object

	// Weapon SkeletalMesh
	Begin Object Name=FirstPersonMesh
		SkeletalMesh=SkeletalMesh'WP_RocketLauncher.Mesh.SK_WP_RocketLauncher_1P'
		PhysicsAsset=None
		AnimTreeTemplate=AnimTree'WP_RocketLauncher.Anims.AT_WP_RocketLauncher_1P_Base'
		AnimSets(0)=AnimSet'WP_RocketLauncher.Anims.K_WP_RocketLauncher_1P_Base'
		Translation=(X=0,Y=0,Z=0)
		Rotation=(Yaw=0)
		scale=1.0
		FOV=60.0
		bUpdateSkelWhenNotRendered=true
	End Object
	AttachmentClass=class'UTGameContent.UTAttachment_RocketLauncher'

	Begin Object Name=PickupMesh
		SkeletalMesh=SkeletalMesh'WP_RocketLauncher.Mesh.SK_WP_RocketLauncher_3P'
	End Object

	InstantHitMomentum(0)=+60000.0


	WeaponFireTypes(0)=EWFT_Custom//EWFT_InstantHit
	WeaponFireTypes(1)=EWFT_Projectile//Projectile
	WeaponProjectiles(1)=class'UTProj_ShockBall'

	InstantHitDamage(0)=45
	FireInterval(0)=+0.8
	FireInterval(1)=+4.0
	InstantHitDamageTypes(0)=class'UTDmgType_ShockPrimary'
	InstantHitDamageTypes(1)=None

	WeaponFireSnd[0]=SoundCue'A_Weapon_ShockRifle.Cue.A_Weapon_SR_FireCue'
	WeaponFireSnd[1]=SoundCue'A_Weapon_ShockRifle.Cue.A_Weapon_SR_AltFireCue'
	WeaponEquipSnd=SoundCue'A_Weapon_ShockRifle.Cue.A_Weapon_SR_RaiseCue'
	WeaponPutDownSnd=SoundCue'A_Weapon_ShockRifle.Cue.A_Weapon_SR_LowerCue'
	PickupSound=SoundCue'A_Pickups.Weapons.Cue.A_Pickup_Weapons_Shock_Cue'

	MaxDesireability=0.65
	AIRating=0.65
	CurrentRating=0.65
	bInstantHit=true
	bSplashJump=false
	bRecommendSplashDamage=false
	bSniping=true
	ShouldFireOnRelease(0)=0
	ShouldFireOnRelease(1)=1

	ShotCost(0)=1
	ShotCost(1)=1

	FireOffset=(X=20,Y=5)
	PlayerViewOffset=(X=17,Y=10.0,Z=-8.0)

	AmmoCount=500
	LockerAmmoCount=500
	MaxAmmoCount=500

	FireCameraAnim(1)=CameraAnim'Camera_FX.ShockRifle.C_WP_ShockRifle_Alt_Fire_Shake'

	WeaponFireAnim(1)=WeaponAltFire

	MuzzleFlashSocket=MF
	MuzzleFlashPSCTemplate=WP_ShockRifle.Particles.P_ShockRifle_MF_Alt
	MuzzleFlashAltPSCTemplate=WP_ShockRifle.Particles.P_ShockRifle_MF_Alt
	MuzzleFlashColor=(R=200,G=120,B=255,A=255)
	MuzzleFlashDuration=0.33
	MuzzleFlashLightClass=class'UTGame.UTRocketMuzzleFlashLight'
	CrossHairCoordinates=(U=256,V=0,UL=64,VL=64)
	LockerRotation=(Pitch=32768,Roll=16384)

	IconCoordinates=(U=728,V=382,UL=162,VL=45)

	WeaponColor=(R=160,G=0,B=255,A=255)

	InventoryGroup=4
	GroupWeight=0.5

	IconX=400
	IconY=129
	IconWidth=22
	IconHeight=48

	Begin Object Class=ForceFeedbackWaveform Name=ForceFeedbackWaveformShooting1
		Samples(0)=(LeftAmplitude=90,RightAmplitude=40,LeftFunction=WF_Constant,RightFunction=WF_LinearDecreasing,Duration=0.1200)
	End Object
	WeaponFireWaveForm=ForceFeedbackWaveformShooting1
}