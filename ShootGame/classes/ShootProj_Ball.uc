class ShootProj_Ball extends ShootProjectile;


 
simulated event HitWall(vector HitNormal, actor Wall, PrimitiveComponent WallComp)
{
Velocity = MirrorVectorByNormal(Velocity,HitNormal);
SetRotation(Rotator(Velocity));
}

function MomentumInit(vector Direction)
{
	MomentumTransfer=100000;
	SetRotation(rotator(Direction));
	Velocity = Speed * Direction;
	Velocity.Z += TossZ;
	Acceleration = AccelRate * Normal(Velocity);

}


DefaultProperties
{
	ProjFlightTemplate=ParticleSystem'WP_ShockRifle.Particles.P_WP_ShockRifle_Ball'
	ProjExplosionTemplate=ParticleSystem'WP_ShockRifle.Particles.P_WP_ShockRifle_Ball_Impact'
	Speed=400
	MaxSpeed=400
	MaxEffectDistance=7000.0

	Damage=55
	DamageRadius=120
	MomentumTransfer=0
	CheckRadius=40.0

	bCheckProjectileLight=true
	ProjectileLightClass=class'UTGame.UTShockBallLight'

	MyDamageType=class'UTDmgType_ShockBall'
	LifeSpan=6.0

	bNetTemporary=false
	AmbientSound=SoundCue'A_Weapon_ShockRifle.Cue.A_Weapon_SR_AltFireTravelCue'
	ExplosionSound=SoundCue'A_Weapon_ShockRifle.Cue.A_Weapon_SR_AltFireImpactCue'
	//ComboExplosionSound=SoundCue'A_Weapon_ShockRifle.Cue.A_Weapon_SR_ComboExplosionCue'
	//ComboExplosionEffect=class'UTEmit_ShockCombo'
}
