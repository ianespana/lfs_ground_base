ENT.Type            = "anim"
DEFINE_BASECLASS( "lunasflightschool_basescript" )

ENT.PrintName = "Hover Base"
ENT.Author = "Heracles421"
ENT.Information = ""
ENT.Category = "[LFS] Galactica Networks"

ENT.Spawnable		= false
ENT.AdminSpawnable	= false

ENT.LAATC_PICKUPABLE = false
ENT.LAATC_PICKUP_POS = Vector(0,0,0)
ENT.LAATC_PICKUP_Angle = Angle(0,0,0)

ENT.StoredForwardVector = Vector(0,-1,0)

ENT.deltaV = Vector(0,0,0)
ENT.deltaVZ = Vector(0,0,0)

ENT.RotorPos = Vector(0,0,0)

ENT.MassCenterOffset = Vector(0,0,0)

ENT.MDL = "models/hunter/blocks/cube1x3x1.mdl"

ENT.MaxPrimaryAmmo = 400
ENT.MaxSecondaryAmmo = 10

ENT.AITEAM = 2

ENT.Mass = 500

ENT.SeatPos = Vector(0,0,0)
ENT.SeatAng = Angle(0,-90,0)

ENT.MaxHealth = 2000

ENT.MoveSpeed = 60
ENT.BoostSpeed = 100
ENT.LerpMultiplier = 1
ENT.ZLerpMultiplier = ENT.LerpMultiplier
ENT.HeightOffset = 80
ENT.TraceDistance = 150
ENT.IgnoreWater = true
ENT.CanMoveSideways = true
ENT.InertiaMultiplier = 0.1
ENT.LookAheadMultiplier = 1E-10 -- This value needs to be REALLY small. Like 10^-8 small
ENT.TraceSubdivision = 1
ENT.MaxAngle = 70

ENT.DebugMode = false
ENT.HitBoxMultiplier = 1

ENT.LastTraceTime = CurTime()
ENT.TraceTimeMin = 0.05

function ENT:AddDataTables()
	self:NetworkVar( "Entity",23, "TurretDriver" )
	self:NetworkVar( "Entity",24, "TurretSeat" )

	self:NetworkVar( "Float",22, "Move" )

	self:NetworkVar( "Bool",19, "IsMoving" )
	self:NetworkVar( "Bool",20, "IsCarried" )
	self:NetworkVar( "Bool",21, "FrontInRange" )
	self:NetworkVar( "Bool",22, "RearInRange" )

	self:NetworkVar( "Vector",1, "MassCenter" )
	self:NetworkVar( "Vector",2, "DeltaV" )

	self:ExtraDataTables()
end

function ENT:ExtraDataTables()
end

function ENT:TraceFilter( ent )
	if ent == self or ent:IsPlayer() or ent:IsNPC() or ent:IsVehicle() or self.GroupCollide[ ent:GetCollisionGroup() ] or self.EntityFilter[ ent:GetClass() ] then
		return false
	end

	return true
end

function ENT:DoTrace()
	if CurTime() < self.LastTraceTime + self.TraceTimeMin then return end

	self.LastTraceTime = CurTime()

	local Up = self:GetUp()
	local localOrigin = self:OBBCenter()
	local Mins, Maxs = self:OBBMins(), self:OBBMaxs()
	local velocity = self:GetVelocity()
	
	Mins = Vector(Mins.x * self.HitBoxMultiplier * (velocity:Length2DSqr() * self.LookAheadMultiplier + 1), Mins.y * self.HitBoxMultiplier * (velocity:Length2DSqr() * self.LookAheadMultiplier + 1), 0)
	Maxs = Vector(Maxs.x * self.HitBoxMultiplier * (velocity:Length2DSqr() * self.LookAheadMultiplier + 1), Maxs.y * self.HitBoxMultiplier * (velocity:Length2DSqr() * self.LookAheadMultiplier + 1), 0)

	local xSize = (Maxs.x - Mins.x) / (self.TraceSubdivision + 1)
	local ySize = (Maxs.y - Mins.y) / (self.TraceSubdivision + 1)

	local xSizeDiv = xSize/2
	local ySizeDiv = ySize/2

	local groundTraceRes = {}
	local waterTraceRes = {}

	local avgGroundHit, avgWaterHit = false, false
	local avgGroundHitPos, avgWaterHitPos = Vector(), Vector()
	local avgGroundHitNormal, avgWaterHitNormal = Vector(), Vector()

	local totalGroundHits, totalWaterHits = 0, 0

	for i = 0, self.TraceSubdivision do
		groundTraceRes[i] = {}
		waterTraceRes[i] = {}

		for j = 0, self.TraceSubdivision do
			local cornerPos = localOrigin + Vector(Mins.x + (i * xSize), Mins.y + (j * ySize), 0)
			local centerOffset = Vector(xSizeDiv, ySizeDiv, 0)
			local traceStart = self:LocalToWorld(cornerPos + centerOffset)

			groundTraceRes[i][j] = util.TraceHull( {
				start = traceStart,
				endpos = traceStart - Up * (self.TraceDistance),
				filter = function(ent) return self:TraceFilter(ent) end,
				mins = -centerOffset,
				maxs = centerOffset,
				mask = MASK_SOLID,
			})

			waterTraceRes[i][j] = util.TraceHull( {
				start = traceStart,
				endpos = traceStart - Up * (self.TraceDistance),
				filter = function(ent) return self:TraceFilter(ent) end,
				mins = -centerOffset,
				maxs = centerOffset,
				mask = MASK_WATER,
			})

			avgGroundHit = avgGroundHit or groundTraceRes[i][j].Hit
			if groundTraceRes[i][j].Hit then
				avgGroundHitPos = avgGroundHitPos + groundTraceRes[i][j].HitPos
				avgGroundHitNormal = avgGroundHitNormal + groundTraceRes[i][j].HitNormal
				totalGroundHits = totalGroundHits + 1
			end

			avgWaterHit = avgWaterHit or waterTraceRes[i][j].Hit
			if waterTraceRes[i][j].Hit then
				avgWaterHitPos = avgWaterHitPos + waterTraceRes[i][j].HitPos
				avgWaterHitNormal = avgWaterHitNormal + waterTraceRes[i][j].HitNormal
				totalWaterHits = totalWaterHits + 1
			end
		end
	end

	self.GroundTrace = table.Copy(groundTraceRes[math.ceil(self.TraceSubdivision / 2)][math.ceil(self.TraceSubdivision / 2)])
	self.WaterTrace = table.Copy(waterTraceRes[math.ceil(self.TraceSubdivision / 2)][math.ceil(self.TraceSubdivision / 2)])

	avgGroundHitPos = avgGroundHitPos / totalGroundHits
	avgGroundHitNormal = avgGroundHitNormal / totalGroundHits

	avgWaterHitPos = avgWaterHitPos / totalWaterHits
	avgWaterHitNormal = avgWaterHitNormal / totalWaterHits

	self.GroundTrace.Hit = avgGroundHit
	self.WaterTrace.Hit = avgWaterHit

	self.GroundTrace.HitPos = avgGroundHitPos
	self.GroundTrace.HitNormal = avgGroundHitNormal
	self.GroundTrace.TraceTable = groundTraceRes


	self.WaterTrace.HitPos = avgWaterHitPos
	self.WaterTrace.HitNormal = avgWaterHitNormal
	self.WaterTrace.TraceTable = waterTraceRes
end

function ENT:AngleBetween(from, to)
	local denominator = math.sqrt(from:LengthSqr() * to:LengthSqr())
	if (denominator < 1e-15) then
		return 0
	end
	
	local dot = math.clamp(from:Dot(to) / denominator, -1, 1)
	return math.Rad2Deg(acos(dot))
end

function ENT:FromToRotation(from, to)
	local axis = from:Cross(to)
	local angle = self:Angle(from, to)
	if (angle >= 179.9196) then
		local r = from:Cross(Vector(1,0,0))
		axis = r:Cross(from)
		if (axis:LengthSqr() < 0.000001) then
			axis = Vector(0,0,1)
		end
	end
	return angle, axis:Normalize()
end

function ENT:LookRotation( lookAt, upDirection )
	if not (isvector( lookAt ) and isvector( upDirection )) then return end

	local Forward = lookAt
	local Up = upDirection

	-- Prepare input vectors to be used
	Forward = Forward:GetNormalized()
	Up = Up:GetNormalized()

	local vector = Forward:GetNormalized()
	local vector2 = Up:Cross(vector)
	local vector3 = vector:Cross(vector2)

	local m00 = vector2.x
	local m01 = vector2.y
	local m02 = vector2.z

	local m10 = vector3.x
	local m11 = vector3.y
	local m12 = vector3.z

	local m20 = vector.x
	local m21 = vector.y
	local m22 = vector.z

	local num8 = (m00 + m11) + m22
	local quat = Quaternion.new(0,0,0,0)

	if (num8 > 0) then
		local num = math.sqrt(num8 + 1.0)
		quat[1] = num * 0.5
		num = 0.5 / num
		quat[2] = (m12 - m21) * num
		quat[3] = (m20 - m02) * num
		quat[4] = (m01 - m10) * num
		return quat:toAngle()
	end

	if (m00 >= m11) and (m00 >= m22) then
		local num7 = math.sqrt(((1 + m00) - m11) - m22)
		local num4 = 0.5 / num7
		quat[1] = (m12 - m21) * num4
		quat[2] = 0.5 * num7
		quat[3] = (m01 + m10) * num4
		quat[4] = (m02 + m20) * num4

		return quat:toAngle()
	end

	if (m11 > m22) then
		local num6 = math.sqrt(((1 + m11) - m00) - m22)
		local num3 = 0.5 / num6
		quat[1] = (m20 - m02) * num3
		quat[2] = (m10+ m01) * num3
		quat[3] = 0.5 * num6
		quat[4] = (m21 + m12) * num3
		return quat:toAngle()
	end

	local num5 = math.sqrt(((1 + m22) - m00) - m11)
	local num2 = 0.5 / num5
	quat[1] = (m01 - m10) * num2
	quat[2] = (m20 + m02) * num2
	quat[3] = (m21 + m12) * num2
	quat[4] = 0.5 * num5
	return quat:toAngle()
end

function ENT:FindLookAtRotation(startVector, targetVector)
	return self:WorldToLocalAngles((targetVector - startVector):GetNormalized():Angle())
end

ENT.ShadowParams = {
	secondstoarrive		= 0.001,
	maxangular			= 50000,
	maxangulardamp		= 100000,
	maxspeed			= 1000000,
	maxspeeddamp		= 500000,
	dampfactor			= 1,
	teleportdistance	= 0,
}

ENT.GroupCollide = {
	[COLLISION_GROUP_DEBRIS] = true,
	[COLLISION_GROUP_DEBRIS_TRIGGER] = true,
	[COLLISION_GROUP_PLAYER] = true,
	[COLLISION_GROUP_WEAPON] = true,
	[COLLISION_GROUP_VEHICLE_CLIP] = true,
	[COLLISION_GROUP_WORLD] = true,
}

ENT.EntityFilter = {}
