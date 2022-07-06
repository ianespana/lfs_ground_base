# Debugging

Debugging your ground base vehicle is simple. All you have to do is turn on developer mode. This can be done by using the `developer 1` command in the console.

Once that is done you will see the following overlay:

![image Debug overlay](../images/debug_overlay.png)

## Breakdown
### Center Plane

The white plane indicates our model's boundary box. This is where all ray casts start. The plane is positioned at center of the model's bounding box.

![image Center plane](../images/center_plane.png)

### Ray-cast Origins

The cyan/yellow spheres indicate the exact position where a ray-cast starts from. The amount of spheres varies depending on our vehicle's [trace subdivisions](../shared_lua/#trace-subdivision).

Cyan spheres indicate that the ray-cast did not hit any solid ground (or water). Yellow spheres indicate we successfully detected the ground at that position.

![image Raycast origins](../images/trace_origins.png)

### Ray-cast Hit Positions

The cyan/yellow planes indicate the exact position where a ray-cast ended. The amount of planes varies depending on our vehicle's [trace subdivisions](../shared_lua/#trace-subdivision).

Cyan planes indicate that the ray-cast did not hit any solid ground (or water). Yellow planes indicate we successfully detected the ground at that position.

![image Raycast hitpos](../images/trace_hitpos.png)

### Alignment Axes

The red/green/blue lines indicate the axes our vehicle is currently aligned with in 3D space. This is calculated by getting the average normal direction of all planes hit by our ray-casts.

The axes will only appear when at least one ray-cast successfully hit solid ground (or water), and their position indicates the average hit position of all our ray-casts.

![image Alignment axes](../images/alignment_axes.png)

## Usage

The debug overlay can be used to know how your vehicle is behaving. The center plane will expand and contract based on your [look ahead](../shared_lua/#look-ahead) configuration, the ray-cast planes will individually adjust to show you how the terrain is affecting your vehicle, and the alignment axes will be useful to know what your vehicle is considering to be ground, as well as it's rotation.

![image Usage](../images/debug_overlay_usage.png)