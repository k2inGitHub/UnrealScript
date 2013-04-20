/**
 * Copyright 1998-2012 Epic Games, Inc. All Rights Reserved.
 */
class ShootProj_LinkPlasma extends ShootProjectile;




/*
simulated function Init(vector Direction)
{
	SetRotation(rotator(Direction));

	Velocity = Speed * Direction;
	Velocity.Z += TossZ;
	Acceleration = AccelRate * Normal(Velocity);
}

simulated function MyInit(vector Direction)
{
	//Worldinfo.Game.Broadcast(self, "Init");
	// Set the rotation the same as the direction
	SetRotation(Rotator(Direction));
	// Set the velocity and give it a little Z kick as well to simulate a toss
	Velocity = Normal(Direction) * Speed;
	//Velocity.Z += TossZ + (FRand() * TossZ / 2.f) - (TossZ / 4.f);
}


simulated function Tick(float DeltaTime)
{
	local vector Direction;
	//Worldinfo.Game.Broadcast(self, "tick:"@DeltaTime);
	Worldinfo.Game.Broadcast(self, "Tick V:"@Velocity);
	Super.Tick(DeltaTime);

	Direction=Velocity/speed;
	
	
	//子弹角度变更
	if(self.aspeed != 0){
		self.angle += self.aspeed;
		//子弹角度变更后，重新计算xy轴速度
		//self.xspeed = self.speed*Math.sin(self.angle * Math.PI / 180);
		//self.yspeed = self.speed*Math.cos(self.angle * Math.PI / 180);
		
		Velocity=speed*Direction;


	}
}
*/

defaultproperties
{
	
	ProjFlightTemplate=ParticleSystem'WP_LinkGun.Effects.P_WP_Linkgun_Projectile'//ParticleSystem'WP_LinkGun.Effects.P_FX_LinkGun_MF_Primary'//ParticleSystem'WP_LinkGun.Effects.P_FX_LinkGun_MF_Primary'//'WP_LinkGun.Effects.P_WP_Linkgun_Projectile'
	ProjExplosionTemplate=ParticleSystem'WP_LinkGun.Effects.P_WP_Linkgun_Impact'//'WP_LinkGun.Effects.P_WP_Linkgun_Beam_Impact_Red'//ParticleSystem'WP_LinkGun.Effects.P_WP_Linkgun_Beam_Impact'//ParticleSystem'WP_LinkGun.Effects.P_WP_Linkgun_Impact'

	Speed=800
	MaxSpeed=800

	MaxEffectDistance=5000.0
	LifeSpan=6

	/*
	MomentumTransfer=85000
	MyDamageType=class'UTDmgType_Rocket'
	DecalWidth=128.0
	DecalHeight=128.0
	bCollideWorld=true
	CheckRadius=42.0
	//bCheckProjectileLight=true
	*/

	Damage=9
	ColorLevel =(X=3.0,Y=2.3,Z=0.8)
	ExplosionColor=(X=1.2,Y=2.0,Z=0.075)

	RotationRateA=(3000,3000,0)
	//TossZ=245.f
	bNetTemporary=false
	bReplicateMovement=true
	bUpdateSimulatedPosition=true
	

	/*
	ProjFlightTemplate=ParticleSystem'WP_RocketLauncher.Effects.P_WP_RocketLauncher_RocketTrail'
	ProjExplosionTemplate=ParticleSystem'WP_RocketLauncher.Effects.P_WP_RocketLauncher_RocketExplosion'
	ExplosionDecal=MaterialInstanceTimeVarying'WP_RocketLauncher.Decals.MITV_WP_RocketLauncher_Impact_Decal01'
	DecalWidth=128.0
	DecalHeight=128.0
	speed=1350.0
	MaxSpeed=1350.0
	Damage=5//100.0
	DamageRadius=220.0
	MomentumTransfer=85000
	MyDamageType=class'UTDmgType_Rocket'
	LifeSpan=8.0
	AmbientSound=SoundCue'A_Weapon_RocketLauncher.Cue.A_Weapon_RL_Travel_Cue'
	ExplosionSound=SoundCue'A_Weapon_RocketLauncher.Cue.A_Weapon_RL_Impact_Cue'
	RotationRate=(Roll=50000)
	bCollideWorld=true
	CheckRadius=42.0
	bCheckProjectileLight=true
	ProjectileLightClass=class'UTGame.UTRocketLight'
	ExplosionLightClass=class'UTGame.UTRocketExplosionLight'

	bWaitForEffects=true
	bAttachExplosionToVehicles=false*/
}
