class ShootWeap_ShockRifle_B_Power extends ShootWeap_ShockRifle_B;

simulated function ProjectileFire_B(){

		
		local int n;//每排子弹个数
		local int range;
		local int i;
        local rotator MyRot;
        local ShootProj_LinkPlasma_Gold_Power MyShockBall;
		//local vector offset;
		//local UTProj_LinkPlasma Proj_L;
		//local UTProj_Rocket Rocket;
		local vector		RealStartLoc;

		n=3;
		range=3072;


		RealStartLoc = GetPhysicalFireStartLoc();//射击位置
		MyRot=GetAdjustedAim( RealStartLoc );
		//GetAxes(MyRot, CamDirX, CamDirY, CamDirZ);//获得坐标方向
		MyRot.Yaw-=range/2+range/(n-1);	
			
			

        for(i=0; i<n; i++)
        {
			MyRot.Yaw+=range/(n-1);
            MyShockBall = spawn(class'ShootProj_LinkPlasma_Gold_Power', /*self*/,,(RealStartLoc)/* Location*/);
			MyShockBall.Instigator=UTPawn(Instigator);
			MyShockBall.Init(Vector(MyRot));
            //MyRocket.Init(normal(Enemy.Location - Location)); // To shoot at player location
            }
		
}
defaultproperties
{
	FireInterval(0)=+1.25
   
}