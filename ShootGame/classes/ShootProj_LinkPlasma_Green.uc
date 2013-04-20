/**
 * Copyright 1998-2012 Epic Games, Inc. All Rights Reserved.
 */
class ShootProj_LinkPlasma_Green extends ShootProjectile;//ShootProj_Enemy;

var vector InitialLocation; 
var float MaxDistance;
var int BackCount;
var rotator currentDirection;
var bool IsRotated;


function Init(vector Direction)
{
	MaxDistance = 300.f;
   SetRotation(rotator(Direction));

  Velocity = Speed * Direction;
  Velocity.Z += TossZ;
  Acceleration = AccelRate * Normal(Velocity);

  InitialLocation = self.Location;

}

function RotatedInit(vector Direction)
{
	MomentumTransfer=100000;
	LifeSpan=12;
	Speed=400;
	MaxSpeed=400;
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
  local float Distance;

  if(IsRotated)
	{
		if(self.Location!=InitialLocation)
		{
		currentDirection.Yaw+=64;
		//currentDirection.Pitch+=1;
		Velocity = Speed * vector(currentDirection);
		Velocity.Z += TossZ;
		Acceleration = AccelRate * Normal(Velocity);
		}
	}
	else
	{
	
		
  
		Distance = VSize(InitialLocation - self.Location);
  
		if (Distance <= MaxDistance){
    
		} else {
			if(BackCount==0)
			{
			//ReturnToPlayer();
			//Worldinfo.Game.Broadcast(self, "I can see you!!");
			Acceleration = AccelRate * Normal(InitialLocation - self.Location);
			BackCount++;
			}
		}
	}
 
  
  
  
}
/*
simulated event Tick(float deltaTime)
{

	if(self.Location!=InitialLocation)
	{
	currentDirection.Yaw+=400;
		
	

	Velocity = Speed * vector(currentDirection);
	Velocity.Z += TossZ;
	Acceleration = AccelRate * Normal(Velocity);
	}else{
		if(BackCount==0)
		{

	Velocity = Speed * vector(InitialDirection);
	Velocity.Z += TossZ;
	Acceleration = AccelRate * Normal(Velocity);
	BackCount++;
		}
	
	}
	
		
  
  
}
*/

defaultproperties
{

	

	ProjFlightTemplate=/*ParticleSystem'WP_LinkGun.Effects.P_FX_LinkGun_3P_Beam_MF'*/ParticleSystem'WP_LinkGun.Effects.P_FX_LinkGun_MF_Beam'
	ProjExplosionTemplate=ParticleSystem''//WP_LinkGun.Effects.P_WP_Linkgun_Beam_Impact'

	Speed=600
	MaxSpeed=600

	MaxEffectDistance=5000.0
	LifeSpan=6.0

	Damage=39
	ColorLevel =(X=3.0,Y=2.3,Z=0.8)
	ExplosionColor=(X=1.2,Y=2.0,Z=0.075)
}
