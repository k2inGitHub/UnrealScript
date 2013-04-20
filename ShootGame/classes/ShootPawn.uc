class ShootPawn extends UTPawn;

simulated function ThrowWeaponOnDeath()
{
	/*»”µÙ”µ”–µƒŒ‰∆˜*/
	//ThrowActiveWeapon();

	//µÙ¬‰µØ“©
	local AmmoPickup Ammo;
	Ammo = Spawn(Class'ShootGame.AmmoPickup', self); 
	Ammo.LifeSpan=30;

}






DefaultProperties
{
}
