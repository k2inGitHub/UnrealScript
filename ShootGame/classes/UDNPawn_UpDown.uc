class UDNPawn_UpDown extends UTPawn;

var Int RegenPerSecond;//每秒回血的数值

var float CamOffsetDistance; //相机在玩家上方偏移的距离
var bool bFollowPlayerRotation; //如果是真，相机会与玩家一起旋转

var bool bNotInSlowMotion;//真，可以做慢动作
var bool bNotInSpeedUp;//真，可以加速
var int ProjLevel;//子弹伤害等级0-3

// members for the custom mesh
var SkeletalMesh defaultMesh;
//var MaterialInterface defaultMaterial0;
var AnimTree defaultAnimTree;
var array<AnimSet> defaultAnimSet;
var PhysicsAsset defaultPhysicsAsset;


/*********
 * *  第三人称视角***锁定攻击方向  *** 
 */
//覆盖使默认情况下的玩家网格物体可见
simulated event BecomeViewTarget( PlayerController PC )
{
   local UTPlayerController UTPC;

   Super.BecomeViewTarget(PC);

   if (LocalPlayer(PC.Player) != None)
   {
      UTPC = UTPlayerController(PC);
      if (UTPC != None)
      {
         //将玩家控制器设置在视图后面，并使网格物体可见
         UTPC.SetBehindView(true);
         SetMeshVisibility(UTPC.bBehindView); 
         UTPC.bNoCrosshair = true;
      }
   }
}

simulated function bool CalcCamera( float fDeltaTime, out vector out_CamLoc, out rotator out_CamRot, out float out_FOV )
{
 

	local vector CamStart, HitLocation, HitNormal, CamDirX, CamDirY, CamDirZ, CurrentCamOffset;
	local float DesiredCameraZOffset;

	CamStart = Location;
	CurrentCamOffset = CamOffset;

	DesiredCameraZOffset = (Health > 0) ? 1.2 * GetCollisionHeight() + Mesh.Translation.Z : 0.f;
	CameraZOffset = (fDeltaTime < 0.2) ? DesiredCameraZOffset * 5 * fDeltaTime + (1 - 5*fDeltaTime) * CameraZOffset : DesiredCameraZOffset;
  
	if ( Health <= 0 )
	{
		CurrentCamOffset = vect(0,0,0);
		CurrentCamOffset.X = GetCollisionRadius();
	}

	CamStart.Z += CameraZOffset;
	GetAxes(out_CamRot, CamDirX, CamDirY, CamDirZ);//获得坐标方向
	CamDirX *= CurrentCameraScale;

	if ( (Health <= 0) || bFeigningDeath )
	{
		// 调整相机位置，确保它没有剪切到世界中
		// @todo fixmesteve.  注意：如果 FindSpot 失败，您仍然可以获得剪切（很少发生）
		FindSpot(GetCollisionExtent(),CamStart);
	}
	if (CurrentCameraScale < CameraScale)
	{
		CurrentCameraScale = FMin(CameraScale, CurrentCameraScale + 5 * FMax(CameraScale - CurrentCameraScale, 0.3)*fDeltaTime);
	}
	else if (CurrentCameraScale > CameraScale)
	{
		CurrentCameraScale = FMax(CameraScale, CurrentCameraScale - 5 * FMax(CameraScale - CurrentCameraScale, 0.3)*fDeltaTime);
	}

	if (CamDirX.Z > GetCollisionHeight())
	{
		CamDirX *= square(cos(out_CamRot.Pitch * 0.0000958738)); // 0.0000958738 = 2*PI/65536
	}

	out_CamLoc = CamStart - 5*CamDirX*CurrentCamOffset.X + 2*CurrentCamOffset.Y*CamDirY -10*CurrentCamOffset.Z*CamDirZ;//最终相机视角，调整角色位置

	if (Trace(HitLocation, HitNormal, out_CamLoc, CamStart, false, vect(12,12,12)) != None)
	{
		out_CamLoc = HitLocation;

	}
	out_CamRot.Pitch = -4096;

	return true;
}

simulated singular event Rotator GetBaseAimRotation()
{
   local rotator   POVRot, tempRot;

   tempRot = Rotation;
   tempRot.Pitch = 0;
   SetRotation(tempRot);
   POVRot = Rotation;
   POVRot.Pitch = 0; 

   return POVRot;
}   

/**********
 * ***每秒自动回血***** 
 */
simulated function PostBeginPlay()//所有的Actors中有一个称为PostBeginPlay的函数，它基本会在游戏启动后立即执行。
{
   Super.PostBeginPlay();//在父类中执行PostBeginPlay函数

   SetTimer(1.0,true);//启动了Timer，它将会每秒钟执行一次，并且把它设置为循环状态
   
}

function Timer()
{
   if (Controller.IsA('PlayerController') && !IsInPain() && Health<SuperHealthMax)
   {
      Health = Min(Health+RegenPerSecond, SuperHealthMax);
   }


}



/**慢动作**/
exec function SlowMotion()
{
    //这是你的关键地方，你想做什么行为就写什么代码，比如你想自爆什么的
    //worldinfo.game.BroadCast(self,bNotInSlowMotion);
	if(bNotInSlowMotion){
	WorldInfo.Game.SetGameSpeed(0.375);
	bNotInSlowMotion=false;
	}else{
	WorldInfo.Game.SetGameSpeed(1);
	bNotInSlowMotion=true;
	}

  }
  /**加速**/
exec function SpeedUp()
{
	if(bNotInSpeedUp){
	StartSpeedUp();
	bNotInSpeedUp=false;
	}else{
	StopSpeedUp();
	bNotInSpeedUp=true;
	}
}
function StartSpeedUp()
{
	WorldInfo.Game.Broadcast(self,"SpeedUp");
	GroundSpeed=GroundSpeed*2;
}

function StopSpeedUp()
{
	WorldInfo.Game.Broadcast(self,"SpeedDown");
	GroundSpeed=600;
}


  simulated function SetCharacterClassFromInfo(class<UTFamilyInfo> Info)
{
	Mesh.SetSkeletalMesh(defaultMesh);
	//Mesh.SetMaterial(0,defaultMaterial0);
	Mesh.SetPhysicsAsset(defaultPhysicsAsset);
	Mesh.AnimSets=defaultAnimSet;
	Mesh.SetAnimTreeTemplate(defaultAnimTree);

}



defaultproperties
{
	defaultMesh=SkeletalMesh'CH_Man.Mesh.SK_Male'//SkeletalMesh'CH_IronGuard_Male.Mesh.SK_CH_IronGuard_MaleA'//SkeletalMesh'TDDUP_Animations.Animations.Character'
	defaultAnimTree=AnimTree'CH_AnimHuman_Tree.AT_CH_Human'
	defaultAnimSet(0)=AnimSet'CH_AnimHuman.Anims.K_AnimHuman_BaseMale'
	defaultPhysicsAsset=PhysicsAsset'CH_AnimCorrupt.mesh.SK_CH_Corrupt_Male_Physics'
	
	ProjLevel=0;

	bNotInSlowMotion=true;//不在慢动作
	bNotInSpeedUp=true;//不在加速状态

	bFollowPlayerRotation = true;
	CamOffsetDistance=300.0//384高度
	CurrentCameraScale=0.4;//缩放大小

	RegenPerSecond=10
}



