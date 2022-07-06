AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "lib_quaternions.lua" )
include("shared.lua")
include( "lib_quaternions.lua" )

function ENT:SpawnFunction( ply, tr, ClassName )
	if not tr.Hit then return end
	local spawnAngles = Angle(0, ply:EyeAngles().y, 0)
	spawnAngles:RotateAroundAxis( Vector(0,0,1), 180 )
	
	local ent = ents.Create( ClassName )
	ent.dOwnerEntLFS = ply
	ent:SetPos( tr.HitPos + tr.HitNormal * 15 )
	ent:SetAngles(spawnAngles)
	ent:Spawn()
	ent:Activate()
	
	return ent
end

function ENT:RunOnSpawn()
end

function ENT:ApplyThrustVtol( PhysObj, vDirection, fForce ) -- kill vtol function
end

function ENT:ApplyThrust( PhysObj, vDirection, fForce ) -- kill thrust
end

function ENT:CalcFlightOverride( Pitch, Yaw, Roll, Stability ) -- kill planescript handling
	return 0,0,0,0,0,0
end

function ENT:CreateAI()
end

function ENT:RemoveAI()
end

function ENT:RunAI()
	return Angle(0,0,0)
end

function ENT:OnKeyThrottle( bPressed )
end

function ENT:OnVtolMode( IsOn )
end

function ENT:OnLandingGearToggled( bOn )
end

function ENT:CanSecondaryAttack()
	self.NextSecondary = self.NextSecondary or 0

	return self.NextSecondary < CurTime() and self:GetAmmoSecondary() > 0
end

function ENT:SetNextAltPrimary( delay )
	self.NextAltPrimary = CurTime() + delay
end

function ENT:CanAltPrimaryAttack()
	self.NextAltPrimary = self.NextAltPrimary or 0
	return self.NextAltPrimary < CurTime() and self:GetAmmoPrimary() > 0
end

function ENT:SetNextAltSecondary( delay )
	self.NextAltSecondary = CurTime() + delay
end

function ENT:CanAltSecondaryAttack()
	self.NextAltSecondary = self.NextAltSecondary or 0
	return self.NextAltSecondary < CurTime() and self:GetAmmoSecondary() > 0
end

function ENT:PrimaryAttack()
end

function ENT:SecondaryAttack()
end

function ENT:MainGunPoser( EyeAngles )
end

function ENT:VeryLowTick()
	return FrameTime() > (1 / 30)
end

function ENT:OnTick()
	local Pod = self:GetDriverSeat()
	if not IsValid( Pod ) then return end
	
	local Driver = Pod:GetDriver()
	
	local FT = FrameTime()
	
	local PObj = self:GetPhysicsObject()
	local MassCenterL = PObj:GetMassCenter()	
	local MassCenter = self:LocalToWorld( MassCenterL )
	self:SetMassCenter( MassCenter )
	
	local Forward = self:GetForward()
	local Right = self:GetRight()
	local Up = self:GetUp()
	
	self:DoTrace()
	
	local Trace = self.GroundTrace
	if self.WaterTrace.Hit and self.WaterTrace.Fraction <= Trace.Fraction and not self.IgnoreWater and self:GetEngineActive() then
		Trace = self.WaterTrace
	end
	
	local IsOnGround = Trace.Hit and math.deg( math.acos( math.Clamp( Trace.HitNormal:Dot( Vector(0,0,1) ), -1, 1) ) ) < self.MaxAngle
	
	local EyeAngles = Angle(0,0,0)
	local KeyForward = false
	local KeyBack = false
	local KeyLeft = false
	local KeyRight = false
	
	local Sprint = false
	
	if IsValid( Driver ) then
		EyeAngles = Driver:EyeAngles()
		KeyForward = Driver:lfsGetInput( "+THROTTLE" ) or self.IsTurnMove
		KeyBack = Driver:lfsGetInput( "-THROTTLE" )
		if self.CanMoveSideways then
			KeyLeft = Driver:lfsGetInput( "+ROLL" )
			KeyRight = Driver:lfsGetInput( "-ROLL" )
		end
		
		if KeyBack then
			KeyForward = false
		end
		
		if KeyLeft then
			KeyRight = false
		end
		
		Sprint = Driver:lfsGetInput( "VSPEC" ) or Driver:lfsGetInput( "+PITCH" ) or Driver:lfsGetInput( "-PITCH" )
		
		self:MainGunPoser( Pod:WorldToLocalAngles( EyeAngles ) )
	end
	local MoveSpeed = Sprint and self.BoostSpeed or self.MoveSpeed
	
	if (IsOnGround) then
		local pos = Vector( self:GetPos().x, self:GetPos().y, Trace.HitPos.z + self.HeightOffset)
		local speedVector = Vector(0,0,0)
		
		if IsValid( Driver ) and not Driver:lfsGetInput( "FREELOOK" ) and self:GetEngineActive() then
			local lookAt = Vector(0,-1,0)
			lookAt:Rotate(Angle(0,Pod:WorldToLocalAngles( EyeAngles ).y,0))
			self.StoredForwardVector = lookAt
		else
			local lookAt = Vector(0,-1,0)
			lookAt:Rotate(Angle(0,self:GetAngles().y,0))
			self.StoredForwardVector = lookAt
		end
		
		local fwd = self.StoredForwardVector - (self.StoredForwardVector:Dot(Trace.HitNormal)) * Trace.HitNormal
		local ang = self:LookRotation( fwd, Trace.HitNormal ) - Angle(0,0,90)
		
		if self:GetEngineActive() then
			speedVector = Forward * ((KeyForward and MoveSpeed or 0) - (KeyBack and MoveSpeed or 0)) + Right * ((KeyLeft and MoveSpeed or 0) - (KeyRight and MoveSpeed or 0))
		end
		
		local speedVectorXY = Vector(speedVector.x, speedVector.y, 0)
		local speedVectorZ = Vector(0, 0, speedVector.z)
		self.deltaV = LerpVector( math.Clamp(self.LerpMultiplier * FT, 0, 1), self.deltaV, speedVectorXY )
		self.deltaVZ = LerpVector( math.Clamp(self.ZLerpMultiplier * FT, 0, 1), self.deltaVZ, speedVectorZ )
		self:SetDeltaV( self.deltaV + self.deltaVZ )
		pos = pos + self.deltaV + self.deltaVZ
		self:SetIsMoving(pos ~= self:GetPos())
		
		self.ShadowParams.pos = pos
		self.ShadowParams.angle = ang
		PObj:ComputeShadowControl( self.ShadowParams )
	else
		self.deltaV = Vector(self:GetVelocity().x * self.InertiaMultiplier, self:GetVelocity().y * self.InertiaMultiplier, 0)
		self.deltaVZ = Vector(0, 0, self:GetVelocity().z * 0.01)
	end
	
	local GunnerPod = self:GetGunnerSeat()
	if IsValid( GunnerPod ) then
		local Gunner = GunnerPod:GetDriver()
		if Gunner ~= self:GetGunner() then
			self:SetTurretDriver( Gunner )
		end
	end
	
	local TurretPod = self:GetTurretSeat()
	if IsValid( TurretPod ) then
		local TurretDriver = TurretPod:GetDriver()
		if TurretDriver ~= self:GetTurretDriver() then
			self:SetTurretDriver( TurretDriver )
		end
	end
	self:Gunner( self:GetGunner(), GunnerPod )
	self:Turret( self:GetTurretDriver(), TurretPod )

	self:OnTickExtra()
end

function ENT:OnTickExtra()
end

function ENT:Gunner( Driver, Pod )
end

function ENT:Turret( Driver, Pod )
end

function ENT:OnEngineStarted()
	self:EmitSound( "lfs/naboo_n1_starfighter/start.wav" )
end

function ENT:OnEngineStopped()
	self:EmitSound( "lfs/naboo_n1_starfighter/stop.wav" )
end