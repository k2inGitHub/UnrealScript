class ShootPawn extends UTPawn;

simulated function ThrowWeaponOnDeath()
{
	/*�ӵ�ӵ�е�����*/
	//ThrowActiveWeapon();

	//���䵯ҩ
	local AmmoPickup Ammo;
	Ammo = Spawn(Class'ShootGame.AmmoPickup', self); 
	Ammo.LifeSpan=30;

}






DefaultProperties
{
}
