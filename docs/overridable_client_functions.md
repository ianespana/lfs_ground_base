# Overridable Functions

These functions can be overridden to perform various tasks. While all functions in the ground base can be overridden, it is important to note that **ONLY** the functions listed here are safe to override.

Overriding other functions might lead to broken behaviour when a new update is released.

Alongside the function documentation you can find usage examples.

## ENT:DrawExtra()

<details>
<summary>Click to expand!</summary>

This function gets executed every frame.

If we need to draw any 3D effects, debug information, extra models, lamps, etc. this is the place to do it.

```lua
function ENT:DrawExtra()
end
```
</details>

## ENT:LFSCalcViewFirstPerson( view, ply )

<details>
<summary>Click to expand!</summary>

This function gets executed every frame. We should use it to calculate where we should position our camera in first person.

```lua
function ENT:LFSCalcViewFirstPerson( view, ply )
    local Driver, Gunner = self:GetDriver(), self:GetTurretDriver()

    if ply == Driver then
        view.origin = self:LocalToWorld( Vector(-65,25,55) )
    elseif ply == Gunner then
        view.origin = self:LocalToWorld( Vector(-100,0,95) )
    else
        view.origin = self:LocalToWorld( Vector(-65,-25,55) )
    end

    return view
end
```
</details>

## ENT:LFSCalcViewThirdPerson( view, ply, FirstPerson )

<details>
<summary>Click to expand!</summary>

This function gets executed every frame. We should use it to calculate where we should position our camera in third person.

```lua
function ENT:LFSCalcViewThirdPerson( view, ply, FirstPerson )
    local Pod = ply:GetVehicle()

    if ply == self:GetTurretDriver() then
        local radius = 800
        radius = radius + radius * Pod:GetCameraDistance()

        local StartPos = self:LocalToWorld( Vector(-130.360611,0,111.885109) ) + view.angles:Up() * 100
        local EndPos = StartPos - view.angles:Forward() * radius

        local WallOffset = 4

        local tr = util.TraceHull( {
            start = StartPos,
            endpos = EndPos,
            filter = function( e )
                local c = e:GetClass()
                local collide = not c:StartWith( "prop_physics" ) and not c:StartWith( "prop_dynamic" ) and not c:StartWith( "prop_ragdoll" ) and not e:IsVehicle() and not c:StartWith( "gmod_" ) and not c:StartWith( "player" ) and not e.LFS

                return collide
            end,
            mins = Vector( -WallOffset, -WallOffset, -WallOffset ),
            maxs = Vector( WallOffset, WallOffset, WallOffset ),
        } )

        view.drawviewer = true
        view.origin = tr.HitPos

        if tr.Hit and not tr.StartSolid then
            view.origin = view.origin + tr.HitNormal * WallOffset
        end

    end

    return view
end
```
</details>

## ENT:LFSHudPaintInfoText( X, Y, speed, alt, AmmoPrimary, AmmoSecondary, Throttle )

<details>
<summary>Click to expand!</summary>

This function gets executed every frame.

We should use it to draw the HUD for the driver of the vehicle.

```lua
function ENT:LFSHudPaintInfoText( X, Y, speed, alt, AmmoPrimary, AmmoSecondary, Throttle )
    draw.SimpleText( "SPEED", "LFS_FONT", 10, 10, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
    draw.SimpleText( speed.."km/h", "LFS_FONT", 120, 10, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )

    draw.SimpleText( "PRI", "LFS_FONT", 10, 35, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
    draw.SimpleText( AmmoPrimary, "LFS_FONT", 120, 35, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )

    draw.SimpleText( "SEC", "LFS_FONT", 10, 60, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
    draw.SimpleText( AmmoSecondary, "LFS_FONT", 120, 60, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
end
```
</details>

## ENT:LFSHudPaintInfoText( X, Y, speed, alt, AmmoPrimary, AmmoSecondary, Throttle )

<details>
<summary>Click to expand!</summary>

This function gets executed every frame.

We should use it to draw the HUD for the driver of the vehicle.

```lua
function ENT:LFSHudPaintInfoText( X, Y, speed, alt, AmmoPrimary, AmmoSecondary, Throttle )
    draw.SimpleText( "SPEED", "LFS_FONT", 10, 10, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
    draw.SimpleText( speed.."km/h", "LFS_FONT", 120, 10, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )

    draw.SimpleText( "PRI", "LFS_FONT", 10, 35, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
    draw.SimpleText( AmmoPrimary, "LFS_FONT", 120, 35, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )

    draw.SimpleText( "SEC", "LFS_FONT", 10, 60, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
    draw.SimpleText( AmmoSecondary, "LFS_FONT", 120, 60, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
end
```
</details>

## ENT:LFSHudPaintPassenger( X, Y, ply )

<details>
<summary>Click to expand!</summary>

This function gets executed every frame.

We should use it to draw the HUD for any of the passengers of the vehicle. Here is where you should handle the HUD for the turret operator/gunner.

```lua
function ENT:LFSHudPaintPassenger( X, Y, ply )
    if ply == self:GetTurretDriver() then
        local ID = self:LookupAttachment( "lazer_cannon_muzzle" )
        local Muzzle = self:GetAttachment( ID )

        if Muzzle then
            local startpos = Muzzle.Pos
            local Trace = util.TraceHull( {
                start = startpos,
                endpos = (startpos + Muzzle.Ang:Up() * 50000),
                mins = Vector( -10, -10, -10 ),
                maxs = Vector( 10, 10, 10 ),
                filter = function( ent ) if ent == self or ent:GetClass() == "lunasflightschool_missile" then return false end return true end
            } )
            local HitPos = Trace.HitPos:ToScreen()

            local X = HitPos.x
            local Y = HitPos.y

            if self:GetIsCarried() then
                surface.SetDrawColor( 255, 0, 0, 255 )
            else
                surface.SetDrawColor( 255, 255, 255, 255 )
            end

            simfphys.LFS.DrawCircle( X, Y, 10 )
            surface.DrawLine( X + 10, Y, X + 20, Y )
            surface.DrawLine( X - 10, Y, X - 20, Y )
            surface.DrawLine( X, Y + 10, X, Y + 20 )
            surface.DrawLine( X, Y - 10, X, Y - 20 )

            -- shadow
            surface.SetDrawColor( 0, 0, 0, 80 )
            simfphys.LFS.DrawCircle( X + 1, Y + 1, 10 )
            surface.DrawLine( X + 11, Y + 1, X + 21, Y + 1 )
            surface.DrawLine( X - 9, Y + 1, X - 16, Y + 1 )
            surface.DrawLine( X + 1, Y + 11, X + 1, Y + 21 )
            surface.DrawLine( X + 1, Y - 19, X + 1, Y - 16 )
        end
    end
end
```
</details>
