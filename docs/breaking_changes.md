# Breaking Changes

This is an ordered list of braking changes. Changes in this section will probably break your code if you overrode any functions not specified as overridable in this documentation.

## 7/6/2022 - V 2.0.0
* Changes to the vector math used to align vehicles with the ground. Vehicles now correctly rotate to match the ground's inclination.
* Vehicles now use more than one trace to calculate a smoother rotation between surfaces. This should result in smoother riding and better transitions from one surface to another.
* The default shadow params for movement were updated, giving a faster response for vehicles with no custom params.