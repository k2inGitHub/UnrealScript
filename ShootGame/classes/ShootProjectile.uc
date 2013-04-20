class ShootProjectile extends UTProjectile;

simulated function ProcessTouch (Actor Other, vector HitLocation, vector HitNormal)
{
	if ( Other != Instigator )
	{
		if ( !Other.IsA('Projectile') || Other.bProjTarget )
		{
			///////////////////����ֻ�ܹ������ǣ�����Ҳֻ�ܹ�������
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
