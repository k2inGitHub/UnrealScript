class ShootAI_GodPawn extends ShootAI_Pawn placeable;

defaultproperties

{

	ControllerClass=class'ShootAI_GodPawnController'

	//bIsPlayer = false

    //GroundSpeed=400
	AnimSetName="ATTACK"
	AttAcking=false

	defaultMesh=SkeletalMesh'CH_LIAM_Cathode.Mesh.SK_CH_LIAM_Cathode'//SkeletalMesh'CH_IronGuard_Male.Mesh.SK_CH_IronGuard_MaleA'//SkeletalMesh'CH_Man.Mesh.SK_Male'//SkeletalMesh'CH_IronGuard_Male.Mesh.SK_CH_IronGuard_MaleA'//SkeletalMesh'TDDUP_Animations.Animations.Character'
	defaultAnimTree=AnimTree'CH_AnimHuman_Tree.AT_CH_Human'
	defaultAnimSet(0)=AnimSet'CH_AnimHuman.Anims.K_AnimHuman_BaseMale'
	defaultPhysicsAsset=PhysicsAsset'CH_AnimCorrupt.mesh.SK_CH_Corrupt_Male_Physics'


	Begin Object Name=WPawnSkeletalMeshComponent
		bOwnerNoSee=false
		CastShadow=true

		//CollideActors=TRUE
		BlockRigidBody=true
		BlockActors=true
		BlockZeroExtent=true
		//BlockNonZeroExtent=true

		bAllowApproximateOcclusion=true
		bForceDirectLightMap=true
		bUsePrecomputedShadows=false
		LightEnvironment=MyLightEnvironment
		//Scale=0.5
		SkeletalMesh=SkeletalMesh'CH_LIAM_Cathode.Mesh.SK_CH_LIAM_Cathode'//SkeletalMesh'CH_IronGuard_Male.Mesh.SK_CH_IronGuard_MaleA'
        AnimSets(0)=AnimSet'CH_AnimHuman.Anims.K_AnimHuman_BaseMale'
		AnimTreeTemplate=AnimTree'CH_AnimHuman_Tree.AT_CH_Human'
	End Object

	mesh = WPawnSkeletalMeshComponent

	Begin Object Name=CollisionCylinder
		CollisionRadius=+0041.000000
		CollisionHeight=+0044.000000
		//BlockZeroExtent=false
	End Object
	CylinderComponent=CollisionCylinder
	CollisionComponent=CollisionCylinder

	bCollideActors=true
	bPushesRigidBodies=true
	bStatic=False
	bMovable=true

	bAvoidLedges=true
	bStopAtLedges=true

	LedgeCheckThreshold=0.5f
	
}

simulated function PostBeginPlay()
{
	super.PostBeginPlay();
	if (Controller == none)
	SpawnDefaultController();

	//if (Controller == none)
	//	SpawnDefaultController();


	/*
	SetPhysics(PHYS_Walking);
	if (MyController == none)
	{
		MyController = Spawn(class'ShootAI_PawnController', self);
		MyController.SetPawn(self);		
	}
	*/
	

    //I am not using this
	//MyAnimPlayControl = AnimNodeSequence(MyMesh.Animations.FindAnimNode('AnimAttack'));
}

function SetAttacking(bool atacar)
{
	AttAcking = atacar;
}



simulated event Tick(float DeltaTime)
{
	local UTPawn gv;

	super.Tick(DeltaTime);
	//MyController.Tick(DeltaTime);

	
	//foreach CollidingActors(class'UTPawn', gv, 200) 
	foreach VisibleCollidingActors(class'UTPawn', gv, 100)
	{
		if(AttAcking && gv != none)
		{
			if(gv.Name == 'MyPawn_0' && gv.Health > 0)
			{
				//Worldinfo.Game.Broadcast(self, "Colliding with player : " @ gv.Name);
				gv.Health -= 1;
				gv.IsInPain();
			}
		}
	}
}

simulated function ThrowWeaponOnDeath()
{
}


simulated function SetCharacterClassFromInfo(class<UTFamilyInfo> Info)
{
	Mesh.SetSkeletalMesh(defaultMesh);
	//Mesh.SetMaterial(0,defaultMaterial0);
	Mesh.SetPhysicsAsset(defaultPhysicsAsset);
	Mesh.AnimSets=defaultAnimSet;
	Mesh.SetAnimTreeTemplate(defaultAnimTree);

}