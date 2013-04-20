/**
 * Copyright 1998-2012 Epic Games, Inc. All Rights Reserved.
 */
class ShootWeap_LinkGun extends ShootWeapon;

// AI properties (for shock combos)
var UTProj_ShockBall ComboTarget;
var bool bRegisterTarget;
var bool bWaitForCombo;
var vector ComboStart;

var bool bWasACombo;
var int CurrentPath;

var int AmmoRegenPerSecond ;



function AddAmmoTimer()
{
    // defined in UTWeapon, copy it into your class if you dont extend from UTGame classes
    AddAmmo( AmmoRegenPerSecond );
}
/**********
 * ***ÿ���Զ������ӵ�***** 
 */
simulated function PostBeginPlay()//���е�Actors����һ����ΪPostBeginPlay�ĺ�����������������Ϸ����������ִ�С�
{
   Super.PostBeginPlay();//�ڸ�����ִ��PostBeginPlay����

   SetTimer(1,true,'AddAmmoTimer');
   
}

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
////////////////////������
simulated function ProjectileFire_A(){

		local int n;//ÿ���ӵ�����
		local int range;
		local int i;
        local rotator MyRot;
        local ShootProj_LinkPlasma MyShockBall;
		//local UTProj_Rocket MyShockBall;
		//local vector offset;
		//local UTProj_LinkPlasma Proj_L;
		//local UTProj_Rocket Rocket;
		local vector		RealStartLoc;

		n=UDNPawn_UpDown(instigator).ProjLevel+2;
		range=256;


		RealStartLoc = GetPhysicalFireStartLoc();//���λ��
		MyRot=GetAdjustedAim( RealStartLoc );
		//GetAxes(MyRot, CamDirX, CamDirY, CamDirZ);//������귽��
		if(n%2==0){
			MyRot.Yaw-=(n/2+0.5)*range;
		}else{
			MyRot.Yaw-=(n/2+1)*range;
		}
			
        for(i=0; i<n; i++)
        {
			MyRot.Yaw+=range;
            MyShockBall = spawn(class'ShootProj_LinkPlasma', /*self*/,,(RealStartLoc)/* Location*/);
			MyShockBall.Instigator=UTPawn(Instigator);
			//Worldinfo.Game.Broadcast(self, MyShockBall.Instigator);
			
			MyShockBall.Init(Vector(MyRot));
            //MyRocket.Init(normal(Enemy.Location - Location)); // To shoot at player location
            }
		
}
////////////////////////������
simulated function ProjectileFire_B(){
	ProjectileFire_Circle();
	//SetTimer(0.5,false,'ProjectileFire_Circle');
}



function ProjectileFire_Circle(){
		local int n;//ÿ���ӵ�����
		local int i;
        local rotator MyRot;
        local ShootProj_LinkPlasma_Green MyShockBall;
		//local UTProj_Rocket MyShockBall;
		//local UTProj_LinkPlasma Proj_L;
		//local UTProj_Rocket Rocket;
		local vector		RealStartLoc;

		n=10;


		RealStartLoc = GetPhysicalFireStartLoc();//���λ��
	
		
		MyRot=GetAdjustedAim( RealStartLoc );
			
		//Worldinfo.Game.Broadcast(self, "Instigator :"@ UDNPawn_UpDown(Instigator).ProjLevel);
        for(i=0; i<n; i++)
        {
			 
			//Proj_L = spawn(class'UTProj_LinkPlasma', /*self*/,,RealStartLoc/* Location*/);
			//Proj_L.Init(Vector(MyRot));

			//Rocket = spawn(class'UTProj_Rocket', /*self*/,,RealStartLoc/* Location*/);
			//Rocket.Init(Vector(MyRot));
			MyRot.Yaw += 3276*2;

            MyShockBall = spawn(class'ShootProj_LinkPlasma_Green', /*self*/,,RealStartLoc/* Location*/);
			MyShockBall.Instigator=UTPawn(Instigator);
	
			MyShockBall.Init(Vector(MyRot));
			//MyShockBall.MyInit(Vector(MyRot));
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
		//SkeletalMesh=SkeletalMesh'WP_ShockRifle.Mesh.SK_WP_ShockRifle_1P'
		//AnimSets(0)=AnimSet'WP_ShockRifle.Anim.K_WP_ShockRifle_1P_Base'
		SkeletalMesh=SkeletalMesh'WP_LinkGun.Mesh.SK_WP_Linkgun_1P'
		AnimSets(0)=AnimSet'WP_LinkGun.Anims.K_WP_LinkGun_1P_Base'
		Animations=MeshSequenceA
		Rotation=(Yaw=-16384)
		FOV=60.0
	End Object

	//AttachmentClass=class'UTGameContent.UTAttachment_ShockRifle'
	AttachmentClass=class'UTAttachment_Linkgun'

	Begin Object Name=PickupMesh
		//SkeletalMesh=SkeletalMesh'WP_ShockRifle.Mesh.SK_WP_ShockRifle_3P'
		SkeletalMesh=SkeletalMesh'WP_LinkGun.Mesh.SK_WP_LinkGun_3P'
	End Object

	AmmoRegenPerSecond =5;

	InstantHitMomentum(0)=+60000.0

	WeaponFireTypes(0)=EWFT_Custom//EWFT_InstantHit
	WeaponFireTypes(1)=EWFT_Projectile
	WeaponProjectiles(1)=class'UTProj_ShockBall'

	InstantHitDamage(0)=45
	FireInterval(0)=+0.2
	FireInterval(1)=+1.6
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

	AmmoCount=200
	LockerAmmoCount=200
	MaxAmmoCount=400

	FireCameraAnim(1)=CameraAnim'Camera_FX.ShockRifle.C_WP_ShockRifle_Alt_Fire_Shake'

	WeaponFireAnim(1)=WeaponAltFire

	MuzzleFlashSocket=MF
	MuzzleFlashPSCTemplate=WP_ShockRifle.Particles.P_ShockRifle_MF_Alt
	MuzzleFlashAltPSCTemplate=WP_ShockRifle.Particles.P_ShockRifle_MF_Alt
	MuzzleFlashColor=(R=200,G=120,B=255,A=255)
	MuzzleFlashDuration=0.33
	//MuzzleFlashLightClass=class'UTGame.UTShockMuzzleFlashLight'
	MuzzleFlashLightClass=class'UTGame.UTLinkGunMuzzleFlashLight'


	CrossHairCoordinates=(U=256,V=0,UL=64,VL=64)
	LockerRotation=(Pitch=32768,Roll=16384)

	IconCoordinates=(U=728,V=382,UL=162,VL=45)

	WeaponColor=(R=160,G=0,B=255,A=255)

	InventoryGroup=1
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