class UDNPawn_UpDown extends UTPawn;

var Int RegenPerSecond;//ÿ���Ѫ����ֵ

var float CamOffsetDistance; //���������Ϸ�ƫ�Ƶľ���
var bool bFollowPlayerRotation; //������棬����������һ����ת

var bool bNotInSlowMotion;//�棬������������
var bool bNotInSpeedUp;//�棬���Լ���
var int ProjLevel;//�ӵ��˺��ȼ�0-3

// members for the custom mesh
var SkeletalMesh defaultMesh;
//var MaterialInterface defaultMaterial0;
var AnimTree defaultAnimTree;
var array<AnimSet> defaultAnimSet;
var PhysicsAsset defaultPhysicsAsset;


/*********
 * *  �����˳��ӽ�***������������  *** 
 */
//����ʹĬ������µ������������ɼ�
simulated event BecomeViewTarget( PlayerController PC )
{
   local UTPlayerController UTPC;

   Super.BecomeViewTarget(PC);

   if (LocalPlayer(PC.Player) != None)
   {
      UTPC = UTPlayerController(PC);
      if (UTPC != None)
      {
         //����ҿ�������������ͼ���棬��ʹ��������ɼ�
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
	GetAxes(out_CamRot, CamDirX, CamDirY, CamDirZ);//������귽��
	CamDirX *= CurrentCameraScale;

	if ( (Health <= 0) || bFeigningDeath )
	{
		// �������λ�ã�ȷ����û�м��е�������
		// @todo fixmesteve.  ע�⣺��� FindSpot ʧ�ܣ�����Ȼ���Ի�ü��У����ٷ�����
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

	out_CamLoc = CamStart - 5*CamDirX*CurrentCamOffset.X + 2*CurrentCamOffset.Y*CamDirY -10*CurrentCamOffset.Z*CamDirZ;//��������ӽǣ�������ɫλ��

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
 * ***ÿ���Զ���Ѫ***** 
 */
simulated function PostBeginPlay()//���е�Actors����һ����ΪPostBeginPlay�ĺ�����������������Ϸ����������ִ�С�
{
   Super.PostBeginPlay();//�ڸ�����ִ��PostBeginPlay����

   SetTimer(1.0,true);//������Timer��������ÿ����ִ��һ�Σ����Ұ�������Ϊѭ��״̬
   
}

function Timer()
{
   if (Controller.IsA('PlayerController') && !IsInPain() && Health<SuperHealthMax)
   {
      Health = Min(Health+RegenPerSecond, SuperHealthMax);
   }


}



/**������**/
exec function SlowMotion()
{
    //������Ĺؼ��ط���������ʲô��Ϊ��дʲô���룬���������Ա�ʲô��
    //worldinfo.game.BroadCast(self,bNotInSlowMotion);
	if(bNotInSlowMotion){
	WorldInfo.Game.SetGameSpeed(0.375);
	bNotInSlowMotion=false;
	}else{
	WorldInfo.Game.SetGameSpeed(1);
	bNotInSlowMotion=true;
	}

  }
  /**����**/
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

	bNotInSlowMotion=true;//����������
	bNotInSpeedUp=true;//���ڼ���״̬

	bFollowPlayerRotation = true;
	CamOffsetDistance=300.0//384�߶�
	CurrentCameraScale=0.4;//���Ŵ�С

	RegenPerSecond=10
}



