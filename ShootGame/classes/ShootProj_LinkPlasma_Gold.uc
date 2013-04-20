/**
 * Copyright 1998-2012 Epic Games, Inc. All Rights Reserved.
 */
class ShootProj_LinkPlasma_Gold extends ShootProjectile;

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
	MomentumTransfer=100000;
	LifeSpan=12;
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
		currentDirection.Yaw+=64;
		//currentDirection.Pitch+=1;
		Velocity = Speed * vector(currentDirection);
		Velocity.Z += TossZ;
		Acceleration = AccelRate * Normal(Velocity);
		}
	}
}

defaultproperties
{
	ProjFlightTemplate=ParticleSystem'WP_LinkGun.Effects.P_FX_LinkGun_MF_Beam_Gold'
	ProjExplosionTemplate=ParticleSystem''

	Speed=400
	MaxSpeed=400

	MaxEffectDistance=5000.0
	LifeSpan=6.0


	Damage=39
	ColorLevel =(X=3.0,Y=2.3,Z=0.8)
	ExplosionColor=(X=1.2,Y=2.0,Z=0.075)
}
