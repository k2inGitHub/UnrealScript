class UDNPlayerController_UpDown extends UTPlayerController;

state PlayerWalking
{
ignores SeePlayer, HearNoise, Bump;

   function ProcessMove(float DeltaTime, vector NewAccel, eDoubleClickDir DoubleClickMove, rotator DeltaRot)
   {
      if( Pawn == None )
      {
         return;
      }

      if (Role == ROLE_Authority)
      {
         // 为远程客户端更新 ViewPitch
         Pawn.SetRemoteViewPitch( Rotation.Pitch );
      }

      Pawn.Acceleration = NewAccel;

      CheckJumpOrDuck();
   }
}

function UpdateRotation( float DeltaTime )
{
   local Rotator   DeltaRot, newRotation, ViewRotation;

   ViewRotation = Rotation;
   if (Pawn!=none)
   {
      Pawn.SetDesiredRotation(ViewRotation);
   }

   // 计算将会应用在 ViewRotation 上的 Delta
   DeltaRot.Yaw   = PlayerInput.aTurn;
   DeltaRot.Pitch   = 0;

   ProcessViewRotation( DeltaTime, ViewRotation, DeltaRot );
   SetRotation(ViewRotation);

   NewRotation = ViewRotation;
   NewRotation.Roll = Rotation.Roll;

   if ( Pawn != None )
      Pawn.FaceRotation(NewRotation, deltatime);
}  

defaultproperties
{

}
