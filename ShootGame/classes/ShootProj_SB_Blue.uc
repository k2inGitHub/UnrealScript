class ShootProj_SB_Blue extends ShootProjectile;

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

simulated event Tick(float deltaTime)
{
	if(self.Location!=InitialLocation)
	{
	currentDirection.Yaw+=400;
	//currentDirection.Pitch+=10;
	Velocity = Speed * vector(currentDirection);
	Velocity.Z += TossZ;
	Acceleration = AccelRate * Normal(Velocity);
	}
}

DefaultProperties
{
	ProjFlightTemplate=ParticleSystem'WP_LinkGun.Effects.P_FX_LinkGun_3P_Beam_MF_Blue'
	ProjExplosionTemplate=ParticleSystem''
	Speed=400
	MaxSpeed=400
	MaxEffectDistance=7000.0

	Damage=49
	DamageRadius=120
	MomentumTransfer=0
	CheckRadius=40.0

	bCheckProjectileLight=true
	//ProjectileLightClass=class'UTGame.UTShockBallLight'

	//MyDamageType=class'UTDmgType_ShockBall'
	LifeSpan=6.0

	bNetTemporary=false
	//AmbientSound=SoundCue'A_Weapon_ShockRifle.Cue.A_Weapon_SR_AltFireTravelCue'
	//ExplosionSound=SoundCue'A_Weapon_ShockRifle.Cue.A_Weapon_SR_AltFireImpactCue'
	//ComboExplosionSound=SoundCue'A_Weapon_ShockRifle.Cue.A_Weapon_SR_ComboExplosionCue'
	//ComboExplosionEffect=class'UTEmit_ShockCombo'
}
