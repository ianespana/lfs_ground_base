# Code Overview

All ground base vehicles follow the basic [Garry's Mod SENT structure](https://wiki.facepunch.com/gmod/Scripted_Entities) and are comprised of 3 main parts:

    entity_identifier/    # The unique ID for this entity.
        shared.lua  # Code that executes on the server and on the client.
        init.lua  # Code that executes on the server.
        cl_init.lua  # Code that executes on the client.

Entities can also be created using a single Lua file, however it is recommended to keep them separate to reduce the chances of confusion and to keep the code cleaner.

## [shared.lua](../shared_lua)

This file is where the majority of the configuration is defined. In here we define our vehicle's name, model, category, and other things. This is also where we tell our code to utilize the ground base.

This documentation will not go into all the options associated with creating SENTs, but rather the specific options that can be configured with the ground base.

It is important to note that you do **NOT** need to change all of these settings! Most of them come preconfigured by default, and changing them is only necessary if you want to tweak their values.

## [init.lua](../overridable_server_functions)

This file is where all the server-side code is processed. It is responsible for handling vehicle movement, weapons, animations, etc.

## [cl_init.lua](../overridable_client_functions)

This file is where all the client-side code is processed. It is responsible for handling HUD painting, VFX, lights, etc.