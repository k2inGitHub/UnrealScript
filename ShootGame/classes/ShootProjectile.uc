class ShootProjectile extends UTProjectile;

simulated function ProcessTouch (Actor Other, vector HitLocation, vector HitNormal)
{
	if ( Other != Instigator )
	{
		if ( !Other.IsA('Projectile') || Other.bProjTarget )
		{
			///////////////////敌人只能攻击主角，主角也只能攻击敌人
			if((Other.IsA('UDNPawn_UpDown')&&Instigator.IsA('ShootAI_Pawn'))||(Other.IsA('ShootAI_Pawn')&&Instigator.IsA('UDNPawn_UpDown'))){
			//MomentumTransfer = (UTPawn(Other) != None) ? 0.0 : 1.0;
			Other.TakeDamage(Damage, InstigatorController, HitLocation, MomentumTransfer * Normal(Velocity), MyDamageType,, self);
			Explode(HitLocation, HitNormal);
			}
		}
	}
}

DefaultProperties
{
}
