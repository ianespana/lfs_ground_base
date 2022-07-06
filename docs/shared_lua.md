# shared.lua
## Specifying the ground base

<details>
<summary>Click to expand!</summary>
At the beginning of the file we must specify the entity type as well as it's base class. It is recommended all vehicles use the type "anim". We can do so by using the following code:

```lua
ENT.Type = "anim"
DEFINE_BASECLASS( "heracles421_lfs_base" )
```
</details>

## Team

<details>
<summary>Click to expand!</summary>
Specifying the vehicle's team allows us to see it on the radar as enemy or friend depending on your own team. It also allows the AI to correctly identify targets.

```lua
ENT.AITEAM = 2 -- We can choose any team from 1 to 3. Make sure to keep the number consistent for vehicles of the same faction!
```
</details>

## 3rd person view position

<details>
<summary>Click to expand!</summary>
Specifying the view position for 3rd person camera is crucial, as that is the default view for most vehicles.

```lua
ENT.RotorPos = Vector(0,0,0) -- This position is relative to the vehicle's origin!
```
</details>

## Vehicle's model and gib models

<details>
<summary>Click to expand!</summary>
Specifying the vehicle's model is critical, as that is what people will see when they spawn the vehicle.

Gibs are also important, they are the models that get spawned whenever our vehicle gets destroyed. Multiple gibs can be specified if we want to simulate the vehicle falling apart.

```lua
ENT.MDL = "models/hunter/blocks/cube1x3x1.mdl"
ENT.GibModels = {
    "models/hunter/blocks/cube1x3x1.mdl",
}
```
</details>

## Driver's seat

<details>
<summary>Click to expand!</summary>
Specifying the vehicle driver's seat position and rotation is very important. You can do so using the following code:

```lua
ENT.SeatPos = Vector(0,0,0)
ENT.SeatAng = Angle(0,-90,0)
```
</details>

## Health

<details>
<summary>Click to expand!</summary>
Specifying the vehicle's health can be done using the following code:

```lua
ENT.MaxHealth = 2000
```
</details>

## Ammo

<details>
<summary>Click to expand!</summary>
Specifying the vehicle's ammunition can be done using the following code:

```lua
ENT.MaxPrimaryAmmo = 400
ENT.MaxSecondaryAmmo = 10
```
</details>

## Mass

<details>
<summary>Click to expand!</summary>
Specifying the vehicle's mass can be done using the following code:

```lua
ENT.Mass = 500
```
</details>

## Move speed

<details>
<summary>Click to expand!</summary>
Specifying the vehicle's mass can be done using the following code:

```lua
ENT.MoveSpeed = 60 -- Normal movement speed
ENT.BoostSpeed = 100 -- Speed when the player is holding the SHIFT key
```
</details>

## Shadow params

<details>
<summary>Click to expand!</summary>

Specifying the vehicle's shadow params can tweak how fast it responds to changes in speed, how fast it turns, how much dampening the movement receives, etc.

Playing around with these values is a good idea, as it provides fine-tuning for you vehicle's motion.

```lua
ENT.ShadowParams = {
    secondstoarrive		= 0.001,
    maxangular			= 50,
    maxangulardamp		= 100000,
    maxspeed			= 500,
    maxspeeddamp		= 500000,
    dampfactor			= 1,
    teleportdistance	= 0,
}
```
</details>

## Height offset

<details>
<summary>Click to expand!</summary>
Specifying the vehicle's height offset (the distance it will hover from the ground) is done using:

```lua
ENT.HeightOffset = 80
```
</details>

## Trace distance

<details>
<summary>Click to expand!</summary>
Every vehicle utilizes ray casting to check whether it is on the ground, and how far away from the ground it should be hovering.

This value specifies the max distance we will cast that ray for. Make sure this value is big enough to handle small terrain imperfections without loosing traction.

```lua
ENT.TraceDistance = 150
```
</details>

## Water affinity

<details>
<summary>Click to expand!</summary>
Should we treat water as solid ground and allow vehicles to traverse over it?

```lua
ENT.IgnoreWater = true
```
</details>

## Movement restrictions

<details>
<summary>Click to expand!</summary>
Should we allow the vehicle to move laterally?

Disabling this is only useful if we are dealing with wheeled or tracked vehicles. Hover vehicles for the most part should be able to move laterally.

```lua
ENT.CanMoveSideways = true
```
</details>

## Other settings
### LERP

<details>
<summary>Click to expand!</summary>
How smoothly should we move between points when handling locomotion? Value must be between 0 and 1

0 for smoother motion, 1 for snappy motion. Recommended value is 1.

```lua
ENT.LerpMultiplier = 1
ENT.ZLerpMultiplier = ENT.LerpMultiplier
```
</details>

### Inertia

<details>
<summary>Click to expand!</summary>
How much inertia should we keep once we land if the vehicle lifts off the ground? This value needs to be small, otherwise the vehicle will be shot away at a great, uncontrollable speed.

```lua
ENT.InertiaMultiplier = 0.1
```
</details>

### Look Ahead

<details>
<summary>Click to expand!</summary>
How much should look ahead for terrain when moving fast. This is useful for fast moving vehicles, as it prevents them from nose diving into the ground.

This won't prevent you from crashing when the angle change is very steep, but it will help with smaller angles.

```lua
ENT.LookAheadMultiplier = 1E-10 -- This value needs to be REALLY small. Like 10^-8 small
```
</details>

### Trace Subdivision

<details>
<summary>Click to expand!</summary>
How many ray casts should we perform for this specific vehicle. Please note that this value is **NOT** linear!

The amount of ray casts is given by: `(n + 1)^2`, where `n` is the value specified below.

It is recommended you don't change this value, unless you're dealing with large vehicles, as more ray casts mean more server lag.

```lua
ENT.TraceSubdivision = 1
```
</details>

### Max Angle

<details>
<summary>Click to expand!</summary>
What is the max angle relative to the horizon that we can achieve. When the vehicle goes over this angle it looses all grip and falls down.

This is useful if you want to make vehicles capable of sticking to the ceiling or to very steep walls.

```lua
ENT.MaxAngle = 70
```
</details>

### Collision Box Multiplier

<details>
<summary>Click to expand!</summary>
How much should we multiply the vehicle's collision box by when doing ray casts. This is useful if for some reason you want to perform ray casts beyond the vehicle's edges. 

```lua
ENT.HitBoxMultiplier = 1
```
</details>

### Trace Time

<details>
<summary>Click to expand!</summary>
How much time (in seconds) should we wait between ray casts. This setting helps us reduce server lag by performing less ray cast operations without affecting vehicle performance.

Slow vehicles don't need to perform ray casts as often as fast vehicles. The default value is good enough for medium-sized vehicles, but tweaking this number can yield better results.

```lua
ENT.TraceTimeMin = 0.05
```
</details>

### Hide Driver

<details>
<summary>Click to expand!</summary>
Should we visually hide the driver of the vehicle?

```lua
ENT.HideDriver = false
```
</details>

### LAAT/c Compatibility

<details>
<summary>Click to expand!</summary>

For use with LFS' LAAT/c. Should the LAAT/c be able to carry this vehicle?

We also define what position and rotation the vehicle will occupy relative to the LAAT/c's pickup point.

```lua
ENT.LAATC_PICKUPABLE = true
ENT.LAATC_PICKUP_POS = Vector(-200,0,30)
ENT.LAATC_PICKUP_Angle = Angle(0,0,0)
```
</details>
