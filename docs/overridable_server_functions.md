# Overridable Functions

These functions can be overridden to perform various tasks. While all functions in the ground base can be overridden, it is important to note that **ONLY** the functions listed here are safe to override.

Overriding other functions might lead to broken behaviour when a new update is released.

Alongside the function documentation you can find usage examples.

## ENT:RunOnSpawn()

<details>
<summary>Click to expand!</summary>

This function gets executed when we spawn the vehicle. In here you should handle the spawning of any extra seats, assign turret operators and gunners, as well as anything else that needs to happen on spawn.

```lua
function ENT:RunOnSpawn()
    local TurretSeat = self:AddPassengerSeat( Vector(0,0,0), Angle(0,-90,0) ) -- Create a new seat
    self:SetTurretSeat( TurretSeat ) -- Set the seat as the turret operator's seat

    local ID = self:LookupAttachment( "driver_turret" )
    local Attachment = self:GetAttachment( ID )

    if Attachment then
        local Pos,Ang = LocalToWorld( Vector(0,-60,0), Angle(180,0,-90), Attachment.Pos, Attachment.Ang )

        TurretSeat:SetParent( NULL )
        TurretSeat:SetPos( Pos )
        TurretSeat:SetAngles( Ang )
        TurretSeat:SetParent( self, ID ) -- Parent the seat to the "driver_turret" attachment. This is especially useful when the turret operator needs to rotate with the turret
    end

    self:AddPassengerSeat( Vector(-68,-23,18), Angle(0,-90,15) ) -- Add a normal passenger's seat. We could also parent this seat to a bone or an attachment
end
```
</details>

## ENT:OnKeyThrottle( bPressed )

<details>
<summary>Click to expand!</summary>

This function gets executed when we press the throttle key (default FORWARD).

```lua
function ENT:OnKeyThrottle( bPressed )
end
```
</details>

## ENT:OnLandingGearToggled( bOn )

<details>
<summary>Click to expand!</summary>

This function gets executed when we press the landing gear key (default SPACE).

It is particularly useful if you want the vehicle to deploy and stow certain parts of itself, like missile launchers, or if you want to toggle lights.

```lua
function ENT:OnLandingGearToggled( bOn )
    if bOn then
        self:PlayAnimation( "rocket_hatch_open" )
    else
        self:PlayAnimation( "rocket_hatch_close" )
    end
end
```
</details>

## ENT:PrimaryAttack()

<details>
<summary>Click to expand!</summary>

This function gets executed when we press the primary fire key (default LMB) **as the driver of the vehicle**.

This is where you should handle your weapon firing logic, such as creating bullets, doing ray casts, etc.

```lua
function ENT:PrimaryAttack()
    Pod = self:GetDriverSeat()
    if not IsValid( Pod ) then return end

    Driver = Pod:GetDriver()
    if not IsValid( Driver ) or Driver:lfsGetInput( "FREELOOK" ) then return end

    if self:GetIsCarried() then return end
    if not self:CanPrimaryAttack() or not self.MainGunDir then return end

    local ID_L = self:LookupAttachment( "muzzle_left" )
    local ID_R = self:LookupAttachment( "muzzle_right" )
    local MuzzleL = self:GetAttachment( ID_L )
    local MuzzleR = self:GetAttachment( ID_R )

    if not MuzzleL or not MuzzleR then return end

    local FirePos = {
        [1] = MuzzleL,
        [2] = MuzzleR,
    }

    self.FireIndexMainWeapon = self.FireIndexMainWeapon and self.FireIndexMainWeapon + 1 or 1

    if self.FireIndexMainWeapon > #FirePos then -- This bit of code iterates through all the launchers and fires one at a time.
        self.FireIndexMainWeapon = 1
        self:SetNextPrimary( 0.3 ) -- Take 0.3 seconds between shots.
    else
        if self.FireIndexMainWeapon == #FirePos then
            self:SetNextPrimary( 0.3 ) -- We don't simulate any reloads or cool-downs, just keep firing at the same interval after we cycle through all guns
        else
            self:SetNextPrimary( 0.3 )
        end
    end

    self:EmitSound( "FIRE" )

    local Pos = FirePos[self.FireIndexMainWeapon].Pos
    local Dir =  FirePos[self.FireIndexMainWeapon].Ang:Up()

    if math.deg( math.acos( math.Clamp( Dir:Dot( self.MainGunDir ) ,-1,1) ) ) < 8 then
        Dir = self.MainGunDir
    end

    local bullet = {}
    bullet.Num      	= 1
    bullet.Src 	        = Pos
    bullet.Dir      	= Dir
    bullet.Spread 	    = Vector( 0.01,  0.01, 0 )
    bullet.Tracer	    = 1
    bullet.TracerName	= "lfs_laser_red"
    bullet.Force	    = 100
    bullet.HullSize 	= 2
    bullet.Damage	    = 25
    bullet.Attacker 	= self:GetDriver()
    bullet.AmmoType     = "Pistol"
    bullet.Callback     = function(att, tr, dmginfo)
        if tr.Entity.IsSimfphyscar then
            dmginfo:SetDamageType(DMG_DIRECT)
        else
            dmginfo:SetDamageType(DMG_AIRBOAT)
        end
    end
    self:FireBullets( bullet )

    self:TakePrimaryAmmo()

    if self:GetAmmoPrimary() <= 0 then
        self:EmitSound("CANNON_DEACTIVATE")
    end
end
```
</details>

## ENT:SecondaryAttack()

<details>
<summary>Click to expand!</summary>

This function gets executed when we press the secondary fire key (default RMB) **as the driver of the vehicle**.

This is where you should handle your secondary weapon firing logic, such as spawning rockets, creating beam lasers, etc.

```lua
function ENT:SecondaryAttack()
    if self:GetIsCarried() then return end
    if not self:CanAltSecondaryAttack() or not self.MainGunDir then return end

    local ID1 = self:LookupAttachment( "left_launch_tube_1" )
    local ID2 = self:LookupAttachment( "right_launch_tube_1" )
    local ID3 = self:LookupAttachment( "left_launch_tube_2" )
    local ID4 = self:LookupAttachment( "right_launch_tube_2" )
    local ID5 = self:LookupAttachment( "left_launch_tube_3" )
    local ID6 = self:LookupAttachment( "right_launch_tube_3" )
    local ID7 = self:LookupAttachment( "left_launch_tube_4" )
    local ID8 = self:LookupAttachment( "right_launch_tube_4" )
    local ID9 = self:LookupAttachment( "left_launch_tube_5" )
    local ID10 = self:LookupAttachment( "right_launch_tube_5" )

    local Muzzle1 = self:GetAttachment( ID1 )
    local Muzzle2 = self:GetAttachment( ID2 )
    local Muzzle3 = self:GetAttachment( ID3 )
    local Muzzle4 = self:GetAttachment( ID4 )
    local Muzzle5 = self:GetAttachment( ID5 )
    local Muzzle6 = self:GetAttachment( ID6 )
    local Muzzle7 = self:GetAttachment( ID7 )
    local Muzzle8 = self:GetAttachment( ID8 )
    local Muzzle9 = self:GetAttachment( ID9 )
    local Muzzle10 = self:GetAttachment( ID10 )

    if not Muzzle1 or not Muzzle2 or not Muzzle3 or not Muzzle4 or not Muzzle5 or not Muzzle6 or not Muzzle7 or not Muzzle8 or not Muzzle9 or not Muzzle10 then return end

    local FirePos = {
        [1] = Muzzle1,
        [2] = Muzzle2,
        [3] = Muzzle3,
        [4] = Muzzle4,
        [5] = Muzzle5,
        [6] = Muzzle6,
        [7] = Muzzle7,
        [8] = Muzzle8,
        [9] = Muzzle9,
        [10] = Muzzle10,
    }

    self.FireIndexMissiles = self.FireIndexMissiles and self.FireIndexMissiles + 1 or 1

    if self.FireIndexMissiles > #FirePos then -- This bit of code iterates through all the launchers and fires one at a time.
        self.FireIndexMissiles = 1
        self:SetNextAltSecondary( 1 ) -- Take a second between shots.
    else
        if self.FireIndexMissiles == #FirePos then
            self:SetNextAltSecondary( 6 ) -- Once we have cycled through all launchers take 6 seconds before we can fire again. Simulates a "reload" or "cool-down" of sorts
        else
            self:SetNextAltSecondary( 1 )
        end
    end

    self:EmitSound( "ROCKET" )

    local Pos = FirePos[self.FireIndexMissiles].Pos
    local Dir =  FirePos[self.FireIndexMissiles].Ang:Up()

    if math.deg( math.acos( math.Clamp( Dir:Dot( self.MainGunDir ) ,-1,1) ) ) < 8 then
        Dir = self.MainGunDir
    end

    local ent = ents.Create( "lunasflightschool_tx130_missile" )
    ent:SetPos( Pos )
    ent:SetAngles( Dir:Angle() )
    ent:Spawn()
    ent:Activate()
    ent:SetAttacker( self:GetTurretDriver() )
    ent:SetInflictor( self )

    constraint.NoCollide( ent, self, 0, 0 )

    self:TakeSecondaryAmmo()
end
```
</details>

## ENT:MainGunPoser()

<details>
<summary>Click to expand!</summary>

This function gets executed every tick.

We should use it to position the guns relative to where we are looking at. The following example demonstrates how we can make guns converge on our aiming reticule.
Please note that this is **NOT** where we need to pose turrets or guns controlled by a seat other than the driver's (unless we want to slave those things to the driver's seat).

```lua
function ENT:MainGunPoser( EyeAngles )
    self.MainGunDir = EyeAngles:Forward()

    local startpos = self:GetRotorPos()
    local TracePlane = util.TraceHull( {
        start = startpos,
        endpos = (startpos + self.MainGunDir * 50000),
        mins = Vector( -10, -10, -10 ),
        maxs = Vector( 10, 10, 10 ),
        filter = {self}
    } )

    local AimAnglesG = self:WorldToLocalAngles( (TracePlane.HitPos - self:LocalToWorld( Vector(-5,51,43) ) ):GetNormalized():Angle() )
    local AimAnglesL = self:WorldToLocalAngles( (TracePlane.HitPos - self:LocalToWorld( Vector(5,51,43) ) ):GetNormalized():Angle() )
    local AimAnglesR = self:WorldToLocalAngles( (TracePlane.HitPos - self:LocalToWorld( Vector(5,-51,43) ) ):GetNormalized():Angle() )

    self:SetPoseParameter("sidegun_pitch", AimAnglesG.p )
    self:SetPoseParameter("sidegun_left_yaw", AimAnglesL.y )
    self:SetPoseParameter("sidegun_right_yaw", AimAnglesR.y )

    local ID = self:LookupAttachment( "muzzle_left" )
    local Muzzle = self:GetAttachment( ID )

    if Muzzle then
        self:SetFrontInRange( math.deg( math.acos( math.Clamp( Muzzle.Ang:Up():Dot( self.MainGunDir ) ,-1,1) ) ) < 15 )
    end
end
```
</details>

## ENT:OnTickExtra()

<details>
<summary>Click to expand!</summary>

This function gets executed every tick.

If we need to do anything on every tick not related to turrets or guns, this is the indicated place.

```lua
function ENT:OnTickExtra()
end
```
</details>

## ENT:Turret( Driver, Pod )

<details>
<summary>Click to expand!</summary>

This function gets executed every tick.

We should use it to position the turret relative to where the operator is looking at. This is also the place where we need to handle the firing action of the turret. The following example demonstrates how we can make guns converge on our aiming reticule.

```lua
function ENT:Turret( Driver, Pod )
    if not IsValid( Pod ) or not IsValid( Driver ) then -- This is a good way of making a turret controllable by both the turret operator and the driver
        Pod = self:GetDriverSeat() -- If there is no turret operator present, we switch control to the vehicle's driver
        if not IsValid( Pod ) then return end

        Driver = Pod:GetDriver()
        if not IsValid( Driver ) or not Driver:lfsGetInput( "FREELOOK" ) then return end -- Only if the driver is in FREELOOK mode should he control the turret
    end

    local EyeAngles = Pod:WorldToLocalAngles( Driver:EyeAngles() )

    local AimDir = EyeAngles:Forward()

    local KeyAttack = Driver:KeyDown( IN_ATTACK )

    local TurretPos = self:GetBonePosition( self:LookupBone( "turret_yaw" ) )

    local startpos = Pod:GetPos() + EyeAngles:Up() * 100 -- We create a trace from the turret to the operator's aiming position
    local TracePlane = util.TraceLine( {
        start = startpos,
        endpos = (startpos + AimDir * 50000),
        filter = {self}
    } )

    local Ang = self:WorldToLocalAngles( (TracePlane.HitPos - TurretPos ):GetNormalized():Angle() )

    local AimRate = 100 * FrameTime()

    self.sm_ppmg_pitch = self.sm_ppmg_pitch and math.ApproachAngle( self.sm_ppmg_pitch, Ang.p, AimRate ) or 0
    self.sm_ppmg_yaw = self.sm_ppmg_yaw and math.ApproachAngle( self.sm_ppmg_yaw, Ang.y, AimRate ) or 0

    local TargetAng = Angle(self.sm_ppmg_pitch,self.sm_ppmg_yaw,0) -- We acquire the necessary turret angles to point towards the operator's cross-hair
    TargetAng:Normalize()

    self:SetPoseParameter("cannon_pitch", TargetAng.p ) -- Rotate the turret using pose parameters
    self:SetPoseParameter("cannon_yaw", TargetAng.y )

    if KeyAttack then
        self:FireTurret( Driver ) -- If the turret's operator presses the primary fire key we run the firing logic
    end

    if (self.cFireIndex or 0) > 0 and Driver:KeyDown( IN_RELOAD ) then  -- If we fire the whole clip, reload
        self.cFireIndex = 0
        self:SetNextSecondary( 2 )
        Pod:EmitSound("CANNONRELOAD")
    end
end
```
</details>

## ENT:Gunner( Driver, Pod )

<details>
<summary>Click to expand!</summary>

This function gets executed every tick.

We should use it to position the gunner's weapons relative to where the operator is looking at. This is also the place where we need to handle the firing action of the gunner.
It is basically the same as the turret code, but it should be used for any extra guns the vehicle might have (such as rear facing cannons, or a second, smaller calibre turret).

```lua
function ENT:Gunner( Driver, Pod )
end
```
</details>

## ENT:OnEngineStarted()

<details>
<summary>Click to expand!</summary>

This function gets executed when we start the vehicle's engine.

We should use it to create engine sounds, as well as handle any changes to the hover height.
We could also deploy weapons, turn on lights, etc. Your creativity is the limit.

```lua
function ENT:OnEngineStarted()
    self:EmitSound( "lfs/naboo_n1_starfighter/start.wav" )
    self.HeightOffset = 20
end
```
</details>

## ENT:OnEngineStopped()

<details>
<summary>Click to expand!</summary>

This function gets executed when we stop the vehicle's engine.

We should use it to create engine sounds, as well as handle any changes to the hover height.
We could also stow weapons, turn off lights, etc. Your creativity is the limit (again).

```lua
function ENT:OnEngineStopped()
    self:EmitSound( "lfs/naboo_n1_starfighter/start.wav" )
    self.HeightOffset = 5
end
```
</details>

## ENT:OnIsCarried( name, old, new )

<details>
<summary>Click to expand!</summary>

This function gets executed when another vehicle picks us up.

We should use this function to stow all weapons, reset all animations, etc.

```lua
function ENT:OnIsCarried( name, old, new )
    if new == old then return end

    if new then
        self:SetPoseParameter("sidegun_pitch", 0 )
        self:SetPoseParameter("sidegun_left_yaw", 0 )
        self:SetPoseParameter("sidegun_right_yaw", 0 )

        self:SetPoseParameter("cannon_pitch", 0 )
        self:SetPoseParameter("cannon_yaw", 0 )

        self:SetPoseParameter("move_x", 0 )
        self:SetPoseParameter("move_y", 0 )

        self:SetWeaponOutOfRange( true )
    end
end
```
</details>