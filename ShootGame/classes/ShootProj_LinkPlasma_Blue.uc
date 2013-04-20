/**
 * Copyright 1998-2012 Epic Games, Inc. All Rights Reserved.
 */
class ShootProj_LinkPlasma_Blue extends ShootProjectile;

var bool IsRotated;
var vector InitialLocation; 
var int BackCount;
var rotator currentDirection;


function Init(vector Direction)
{
  SetRotation(rotator(Direction));
  Velocity = Speed * Direction;
  Velocity.Z += TossZ;
  Acceleration = AccelRate * Normal(Velocity);
  InitialLocation = self.Location;
  currentDirection=rotator(Direction);

}

function RotatedInit(vector Direction)
{
	LifeSpan=12;
	MomentumTransfer=100000;

	IsRotated=true;
	SetRotation(rotator(Direction));

	Velocity = Speed * Direction;
	Velocity.Z += TossZ;
	Acceleration = AccelRate * Normal(Velocity);

	InitialLocation = self.Location;
	//InitialDirection=rotator(Direction);
	currentDirection=rotator(Direction);

}

simulated event Tick(float deltaTime)
{
	if(IsRotated)
	{
		if(self.Location!=InitialLocation)
		{
		//currentDirection.Yaw+=64;
		currentDirection.Yaw+=64;
		//currentDirection.Pitch+=1;
		Velocity = Speed * vector(currentDirection);
		Velocity.Z += TossZ;
		Acceleration = AccelRate * Normal(Velocity);
		}
	}
}

simulated event HitWall(vector HitNormal, Actor Wall, PrimitiveComponent WallComp)
{
	MomentumTransfer = 1.0;


	ProjectileFire_B();
	Super.HitWall(HitNormal, Wall, WallComp);

}

simulated function ProjectileFire_B(){

		local int n;//每排子弹个数
		//local int range;
		local int i;
        local rotator MyRot;
        local ShootProj_LinkPlasma MyShockBall;
		//local vector offset;
		//local UTProj_LinkPlasma Proj_L;
		//local UTProj_Rocket Rocket;
		local vector		RealStartLoc;

		n=16;
		//range=3600;


		RealStartLoc = self.Location;//射击位置
		
		//GetAxes(MyRot, CamDirX, CamDirY, CamDirZ);//获得坐标方向
		//MyRot.Yaw-=range/2+range/(n-1);	
			
			

        for(i=0; i<n; i++)
        {
			MyRot.Yaw+=4096;
            MyShockBall = spawn(class'ShootProj_LinkPlasma', /*self*/,,(RealStartLoc)/* Location*/);
			MyShockBall.Instigator=self.Instigator;
			MyShockBall.Init(Vector(MyRot));
            //MyRocket.Init(normal(Enemy.Location - Location)); // To shoot at player location
            }
		
}



defaultproperties
{
	ProjFlightTemplate=ParticleSystem'WP_LinkGun.Effects.P_FX_LinkGun_MF_Beam_Blue'
	ProjExplosionTemplate=ParticleSystem''

	Speed=400
	MaxSpeed=400

	MaxEffectDistance=5000.0
	LifeSpan=6.0


	Damage=39
	ColorLevel =(X=3.0,Y=2.3,Z=0.8)
	ExplosionColor=(X=1.2,Y=2.0,Z=0.075)
}
