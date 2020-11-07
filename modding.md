# Star Wars Lightsabers modding.

This document describes how you can mod the [Star Wars Lightsabers](http://steamcommunity.com/sharedfiles/filedetails/?id=111412589 "Star Wars Lightsabers Workshop Page") Garry's Mod addon.

Note that I will not provide help if you do not know what you are doing ( i.e. You do not know how to program )

I will also not provide any help with extracted version of this mod ( or any other mod ), nor I will help you with editing the mod.

Please do not upload edited or not version of this mod anywhere. You should upload self contained addons that use the APIs below.

## Tool Modding

How to add new stuff to the Sandbox tool. All of the code in this section **must** be called shared - both on client and server.

### Adding models for the tool
```
list.Set( "LightsaberModels", "<pathToModel>", {} )
```
```<pathToModel>``` is your path to the model file.
Must start with ```models/``` and end with ```.mdl```, for example ```models/weapons/stuff.mdl```.

### Adding a set of ignition sounds for the tool
```
list.Set( "rb655_LightsaberIgniteSounds", "#myCustomUniqueInternalName", {
	rb655_lightsaber_onsound = "<pathToOnSound>",
	rb655_lightsaber_offsound = "<pathToOffSound>"
} )
```
```<pathToOnSound>``` is your path to the sound file for the Ignition sound.
Must **NOT** start with ```sound/```, for example ```lightsabers/myOnSound1.wav```.

```<pathToOffSound>``` is the same as above, but for the Extinguish sound.

```#myCustomUniqueInternalName``` is your internal name for the sound, that will appear in the tool UI. You should translate it to a real/proper name with [```language.Add( "#myCustomUniqueInternalName", "My Custom Sound" )```](http://wiki.garrysmod.com/page/language/Add).

File format **MUST** be compatible with Garry's Mod, so either ```.wav``` or ```.mp3``` will do. Recommended format is ```.wav```.

### Adding swing sounds
```
list.Set( "rb655_LightsaberSwingSounds", "#myCustomUniqueInternalName", {
	rb655_lightsaber_swingsound = "<pathToSwingSound>"
} )
```

```<pathToSwingSound>``` is your path to the **looping** sound file for swings. Rules from above apply.

Learn how to make looping ```.wav``` files **[here](http://wiki.garrysmod.com/page/Creating_Looping_Sounds)**.

### Adding hum sounds
```
list.Set( "rb655_LightsaberHumSounds", "#myCustomUniqueInternalName", {
	rb655_lightsaber_humsound = "<pathToHumSound>"
} )
```

```<pathToHumSound>``` is your path to the **looping** sound file for idle hum. Rules from above apply.

## Weapon & Entity Modding

This section describes ways you can affect the Weapon and Entity of the mod.

### Custom damage for lightsaber ( Weapon and Entity, Serverside )
```
hook.Add( "CanLightsaberDamageEntity", "my_unqiue_hook_name_here", function( victim, lightsaber, trace )
	return 50 -- Makes the damage twice as high for the weapon
end )
```

```
hook.Add( "CanLightsaberDamageEntity", "my_unqiue_hook_name_here", function( victim, lightsaber, trace )
	if ( lightsaber:IsWeapon() ) then return 100 end -- If the Ligthsaber is the Weapon/SWEP counterpart, deal 100 damage
	return false -- If the lightsaber is an Entity/SENT, deal no damage at all.
end )
```

### Preventing force power usage ( Weapon, Shared )
```
GM:CanUseLightsaberForcePower( Entity owner, string power ) - return false to disallow owner to use and hide given Force Power from UI
```

Serverside, prevents usage of said force power, clientside, hides the Force Power from the HUD.

Examples:
```
-- Prevents everyone from using any force powers
hook.Add( "CanUseLightsaberForcePower", "my_unqiue_hook_name_here", function( ply, power )
	return false
end )
```
```
-- Prevents NON ADMINS from using any force powers
hook.Add( "CanUseLightsaberForcePower", "my_unqiue_hook_name_here", function( ply, power )
	if ( !ply:IsAdmin() ) then return false end
end )
```
```
-- Prevents everyone from using Force Combust
hook.Add( "CanUseLightsaberForcePower", "my_unqiue_hook_name_here", function( ply, power )
	if ( power == "Force Combust" ) then return false end
end )
```

List of current Force Powers:
```
"Force Leap"
"Force Absorb"
"Force Repulse"
"Force Heal"
"Force Combust"
"Force Lightning"
```

### Adding new force powers
```
rb655_AddForcePower( {
	name = "My Force Power", -- Name of the force power, used in hooks too
	icon = "C", -- The letter that will appear on the bottom of the screen, optional
	material = Material( "icon16/cross.png" ), -- The material to display instead of the letter icon, optional
	description = "Description", -- Description, appears in the bottom of the screen
	action = function( self )
		if ( self:GetForce() < 16 or CLIENT ) then return end -- Do not run this function if our force is below 16% or on client

		-- Do your custom stuff here

		self:SetForce( self:GetForce() - 4 ) -- Take 4% force away on use
		self:SetNextAttack( 1 ) -- Sets next attack ( both swing and force power )
	end
} )
```
( ply, bind, pressed ) - return anything to block default action
### Adding custom HUD, hiding default HUD ( Weapon, Clientside )
```
GM:LightsaberDrawHUD( bool SelectionEnabled, number Force, number MaxForce, number SelectedForceID, table forcePowersTable )

Return anything but nil to hide default HUD, returning a number will make the error messages on HUD appear at that Y position. 
```

Clientside, allows you to create custom HUDs for the lightsabers mod for your server or whatever without having to edit the mod itself.

Examples:
```
-- Prevents everyone from using any force powers
hook.Add( "LightsaberDrawHUD", "my_unqiue_hud_hook_name_here", function( ForceSelectEnabled, Force, MaxForce, SelectedPower, ForcePowers  )
	-- Draw your HUD here using the passed arguments
	return ScrH() -- Return a number as an offset for error message HUD or otherwise a non nil-value 
end )
```

### Preventing default Force Power selection functionality ( Weapon, Clientside )
```
GM:LightsaberPlayerBindPress( ply, bind, pressed )

Return anything but nil to prevent the default Force Power selection functionality
```

Same as the default GM:PlayerBindPress, but returning anything non-nil will prevent the F and 1,2,3,4,5,6-etc keys from affecting the HUD, in case you want to have some custom HUD force power selection or something.

Keep in mind that people can still select Force Powers using the following console commands:

Console Command | Info
------------ | ------------- 
```rb655_select_force <number>```|Directly selects the Force Power at given slot
```rb655_select_next 1```|Selects the Force Power at the next slot
```rb655_select_next -1```|Selects the Force Power at the previous slot


### Spawning the weapon and giving it custom colors, etc ( Serverside )
```
local ply = Entity( 1 ) -- This is your player object

local wep = ply:Give( "weapon_lightsaber" )
if ( !IsValid( wep ) ) then return end -- The player already has the weapon

wep.WeaponSynched = true -- Prevent the weapon from loading settings from the Sandbox tool

wep:SetMaxLength( 420 ) -- Blade length
wep:SetCrystalColor( Vector( 255, 0, 0 ) ) -- Blade color - must be a Vector, not a Color
wep:SetDarkInner( false ) -- Whether the blade inner part is dark or not
wep:SetWorldModel( "models/sgg/starwars/weapons/w_anakin_ep2_saber_hilt.mdl" ) -- The full model path
wep:SetBladeWidth( 20 ) -- Blade width

wep.LoopSound = "lightsaber/saber_loop" .. math.random( 1, 8 ) .. ".wav" -- Hum sound, full paths
wep.SwingSound = "lightsaber/saber_swing" .. math.random( 1, 2 ) .. ".wav" -- Swing sound
wep:SetOnSound( "lightsaber/saber_on" .. math.random( 1, 4 ) .. ".wav" ) -- On sound
wep:SetOffSound( "lightsaber/saber_off" .. math.random( 1, 4 ) .. ".wav" ) -- Off sound

-- These are optional
wep:SetForceType( 1 ) -- Starting Force Type - starts from 1 to the maximum amount of Force Powers on your server
wep:SetForce( 100 ) -- Starting Amount of Force. Will autoregen to GetMaxForce().
wep:SetWorksUnderwater( false ) -- Default = true, if set to false, will auto disable upon entering water
wep:SetMaxForce( 100 ) -- Sets the maximum force amount. Default is 100.

wep.HitSound = "lightsaber/saber_hit.wav" -- Overrides the looping wall hit sound
```

## Creating Lightsaber models

* Your models MUST have a bone named ```ValveBiped.Bip01_R_Hand``` to act as a weapon model. ( So it attaches to your hand )
* Your models MUST have attachments for each blade:
 * blade1
 * blade2
 * blade3 - etc, format for normal blades
* Your models MUST have attachments for each quillon ( Kylo Ren like sideguards ):
 * quillon1
 * quillon2
 * quillon3 - etc, format for Kylo Ren-like crossguard blades.

## Console variables

Console Variable | Default | Realm | Info
------------ | ------------- | ------------- | -------------
```rb655_lightsaber_hiltonbelt``` ```1/0```|1|Server|Show the Lightsaber hilt on player models belt if you holster your Lightsaber
```rb655_lightsaber_hud_blur``` ```1/0```|0|Client|Enables the fancy blur effect on the Lightsaber SWEP HUD. It **will** kill your FPS
```rb655_lightsaber_infinite``` ```1/0```|0|Server|Enables infinite Force
```sbox_maxent_lightsabers``` ```<number>```|2|Server|Server Lightsaber Entity limit
```rb655_lightsaber_allow_knockback``` ```1/0```|1|Server|Allow Lightsaber SWEP to knock players back when they are damaged by it
