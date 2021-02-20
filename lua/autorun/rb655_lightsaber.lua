
--[[

Editing the Lightsabers.

Once you unpack the lightsaber addon, you are voided of any support as to why it doesn't work.
I can't possibly provide support for all the edits and I can't know what your edits broke or whatever.

-------------------------------- DO NOT REUPLOAD THIS ADDON IN ANY SHAPE OF FORM --------------------------------
-------------------------------- DO NOT REUPLOAD THIS ADDON IN ANY SHAPE OF FORM --------------------------------
-------------------------------- DO NOT REUPLOAD THIS ADDON IN ANY SHAPE OF FORM --------------------------------
-------------------------------- DO NOT REUPLOAD THIS ADDON IN ANY SHAPE OF FORM --------------------------------
-------------------------------- DO NOT REUPLOAD THIS ADDON IN ANY SHAPE OF FORM --------------------------------

-------------------------- DO NOT EDIT ANYTHING DOWN BELOW OR YOU LOSE SUPPORT FROM ME --------------------------
-------------------------- DO NOT EDIT ANYTHING DOWN BELOW OR YOU LOSE SUPPORT FROM ME --------------------------
-------------------------- DO NOT EDIT ANYTHING DOWN BELOW OR YOU LOSE SUPPORT FROM ME --------------------------
-------------------------- DO NOT EDIT ANYTHING DOWN BELOW OR YOU LOSE SUPPORT FROM ME --------------------------
-------------------------- DO NOT EDIT ANYTHING DOWN BELOW OR YOU LOSE SUPPORT FROM ME --------------------------
-------------------------- DO NOT EDIT ANYTHING DOWN BELOW OR YOU LOSE SUPPORT FROM ME --------------------------

]]

AddCSLuaFile()

-- -------------------------------------------------- Lightsaber effects -------------------------------------------------- --

-- game.AddDecal( "LSScorch", "effects/rb655_scorch" ) -- Why doesn't it work?

function rb655_DrawHit( pos, dir )
	local effectdata = EffectData()
	effectdata:SetOrigin( pos )
	effectdata:SetNormal( dir )
	util.Effect( "StunstickImpact", effectdata, true, true )

	--util.Decal( "LSScorch", pos + dir, pos - dir )
	util.Decal( "FadingScorch", pos + dir, pos - dir )
end

function rb655_IsLightsaber( ent )
	if ( !IsValid( ent ) ) then return false end
	if ( ent.IsLightsaber ) then return true end
	return false
end

function rb655_GetLightsaber( ply )
	if ( !IsValid( ply ) ) then return end

	for i, wep in pairs( ply:GetWeapons() ) do
		if ( wep.IsLightsaber ) then return wep end
	end
end

-------------------------------------------------- FORCE POWERS --------------------------------------------------

rb655_gForcePowers = /*rb655_gForcePowers ||*/ {}

function rb655_AddForcePower( t )
	table.insert( rb655_gForcePowers, t )
end

rb655_AddForcePower( {
	name = "Force Leap",
	material = Material( "lightsaber_icons/leap.png" ),
	description = "Jump longer and higher.\nAim higher to jump higher/further.\nHold CTRL to negate fall damage, but stop moving for 1 sec",
	action = function( self, ply )
		if ( self:GetForce() < 10 or !ply:IsOnGround() or CLIENT ) then return end
		self:SetForce( self:GetForce() - 10 )

		self:SetNextAttack( 0.5 )

		ply:SetVelocity( ply:GetAimVector() * 512 + Vector( 0, 0, 512 ) )

		self:PlayWeaponSound( "lightsaber/force_leap.wav" )

		-- Trigger the jump animation, yay
		self:CallOnClient( "ForceJumpAnim", "" )
	end
} )

rb655_AddForcePower( {
	name = "Force Absorb",
	material = Material( "lightsaber_icons/absorb.png" ),
	description = "Hold Mouse 2 to protect yourself from harm",
	action = function( self, ply )
		if ( self:GetForce() < 1 --[[ or !ply:IsOnGround()]] or CLIENT ) then return end
		self:SetForce( self:GetForce() - 0.1 )

		self:SetNextAttack( 0.3 )
	end
} )

hook.Add( "EntityTakeDamage", "rb655_sabers_armor", function( victim, dmg )

	local ply = victim
	if ( !ply.GetActiveWeapon or !ply:IsPlayer() or !ply:KeyDown( IN_ATTACK2 ) --[[or !ply:IsOnGround()]] ) then return end

	local wep = ply:GetActiveWeapon()
	if ( !IsValid( wep ) or !rb655_IsLightsaber( wep ) or wep:GetActiveForcePowerType( wep:GetForceType() ).name != "Force Absorb" ) then return end

	local force = wep:GetForce()
	if ( force < 1 ) then return end

	local damage = dmg:GetDamage() / 5
	if ( force < damage ) then
		wep:SetForce( 0 )
		dmg:SetDamage( ( damage - force ) * 5 )
	else
		wep:SetForce( force - damage )
		dmg:SetDamage( 0 )
	end

end )

rb655_AddForcePower( {
	name = "Force Repulse",
	material = Material( "lightsaber_icons/repulse.png" ),
	description = "Hold to charge for greater distance/damage.\nKill everybody close to you.\nPush back everybody who is a bit farther away but still close enough.",
	think = function( self )
		if ( self:GetNextSecondaryFire() > CurTime() ) then return end
		if ( self:GetForce() < 1 or CLIENT ) then return end
		if ( !self.Owner:KeyDown( IN_ATTACK2 ) && !self.Owner:KeyReleased( IN_ATTACK2 ) ) then return end
		if ( !self._ForceRepulse && self:GetForce() < 16 ) then return end

		if ( !self.Owner:KeyReleased( IN_ATTACK2 ) ) then
			if ( !self._ForceRepulse ) then self:SetForce( self:GetForce() - 16 ) self._ForceRepulse = 1 end

			if ( !self.NextForceEffect or self.NextForceEffect < CurTime() ) then
				local ed = EffectData()
				ed:SetOrigin( self.Owner:GetPos() + Vector( 0, 0, 36 ) )
				ed:SetRadius( 128 * self._ForceRepulse )
				util.Effect( "rb655_force_repulse_in", ed, true, true )

				self.NextForceEffect = CurTime() + math.Clamp( self._ForceRepulse / 20, 0.1, 0.5 )
			end

			self._ForceRepulse = self._ForceRepulse + 0.025
			self:SetForce( self:GetForce() - 0.5 )
			if ( self:GetForce() > 0.99 ) then return end
		else
			if ( !self._ForceRepulse ) then return end
		end

		local maxdist = 128 * self._ForceRepulse

		for i, e in pairs( ents.FindInSphere( self.Owner:GetPos(), maxdist ) ) do
			if ( e == self.Owner ) then continue end

			local dist = self.Owner:GetPos():Distance( e:GetPos() )
			local mul = ( maxdist - dist ) / 256

			local v = ( self.Owner:GetPos() - e:GetPos() ):GetNormalized()
			v.z = 0

			if ( e:IsNPC() && util.IsValidRagdoll( e:GetModel() or "" ) ) then

				local dmg = DamageInfo()
				dmg:SetDamagePosition( e:GetPos() + e:OBBCenter() )
				dmg:SetDamage( 48 * mul )
				dmg:SetDamageType( DMG_GENERIC )
				if ( ( 1 - dist / maxdist ) > 0.8 ) then
					dmg:SetDamageType( DMG_DISSOLVE )
					dmg:SetDamage( e:Health() * 3 )
				end
				dmg:SetDamageForce( -v * math.min( mul * 40000, 80000 ) )
				dmg:SetInflictor( self.Owner )
				dmg:SetAttacker( self.Owner )
				e:TakeDamageInfo( dmg )

				if ( e:IsOnGround() ) then
					e:SetVelocity( v * mul * -2048 + Vector( 0, 0, 64 ) )
				elseif ( !e:IsOnGround() ) then
					e:SetVelocity( v * mul * -1024 + Vector( 0, 0, 64 ) )
				end

			elseif ( e:IsPlayer() && e:IsOnGround() ) then
				e:SetVelocity( v * mul * -2048 + Vector( 0, 0, 64 ) )
			elseif ( e:IsPlayer() && !e:IsOnGround() ) then
				e:SetVelocity( v * mul * -384 + Vector( 0, 0, 64 ) )
			elseif ( e:GetPhysicsObjectCount() > 0 ) then
				for i = 0, e:GetPhysicsObjectCount() - 1 do
					e:GetPhysicsObjectNum( i ):ApplyForceCenter( v * mul * -512 * math.min( e:GetPhysicsObject():GetMass(), 256 ) + Vector( 0, 0, 64 ) )
				end
			end
		end

		local ed = EffectData()
		ed:SetOrigin( self.Owner:GetPos() + Vector( 0, 0, 36 ) )
		ed:SetRadius( maxdist )
		util.Effect( "rb655_force_repulse_out", ed, true, true )

		self._ForceRepulse = nil

		self:SetNextAttack( 1 )

		self:PlayWeaponSound( "lightsaber/force_repulse.wav" )
	end
} )

rb655_AddForcePower( {
	name = "Force Heal",
	material = Material( "lightsaber_icons/healing.png" ),
	description = "Hold Mouse 2 to slowly heal yourself",
	action = function( self, ply )
		if ( self:GetForce() < 1 --[[|| !ply:IsOnGround()]] or ply:Health() >= 100 or CLIENT ) then return end
		self:SetForce( self:GetForce() - 1 )

		self:SetNextAttack( 0.2 )

		local ed = EffectData()
		ed:SetOrigin( ply:GetPos() )
		util.Effect( "rb655_force_heal", ed, true, true )

		ply:SetHealth( ply:Health() + 1 )
		ply:Extinguish()
	end
} )

rb655_AddForcePower( {
	name = "Force Combust",
	material = Material( "lightsaber_icons/combust.png" ),
	target = 1,
	description = "Ignite stuff infront of you.",
	action = function( self, ply )
		if ( CLIENT ) then return end

		local ent = self:SelectTargets( 1 )[ 1 ]

		if ( !IsValid( ent ) or ent:IsOnFire() ) then self:SetNextAttack( 0.2 ) return end

		local time = math.Clamp( 512 / ply:GetPos():Distance( ent:GetPos() ), 1, 16 )
		local neededForce = math.ceil( math.Clamp( time * 2, 10, 32 ) )

		if ( self:GetForce() < neededForce ) then self:SetNextAttack( 0.2 ) return end

		ent:Ignite( time, 0 )
		self:SetForce( self:GetForce() - neededForce )

		self:SetNextAttack( 1 )
	end
} )

rb655_AddForcePower( {
	name = "Force Lightning",
	material = Material( "lightsaber_icons/lighting.png" ),
	target = 3,
	description = "Torture people ( and monsters ) at will.",
	action = function( self )
		if ( self:GetForce() < 3 or CLIENT ) then return end

		local foundents = 0
		for id, ent in pairs( self:SelectTargets( 3 ) ) do
			if ( !IsValid( ent ) ) then continue end

			foundents = foundents + 1
			local ed = EffectData()
			ed:SetOrigin( self:GetSaberPosAng() )
			ed:SetEntity( ent )
			util.Effect( "rb655_force_lighting", ed, true, true )

			local dmg = DamageInfo()
			dmg:SetAttacker( self.Owner or self )
			dmg:SetInflictor( self.Owner or self )

			dmg:SetDamage( math.Clamp( 512 / self.Owner:GetPos():Distance( ent:GetPos() ), 1, 10 ) )
			if ( ent:IsNPC() ) then dmg:SetDamage( 4 ) end
			ent:TakeDamageInfo( dmg )

		end

		if ( foundents > 0 ) then
			self:SetForce( self:GetForce() - foundents )
			if ( !self.SoundLightning ) then
				self.SoundLightning = CreateSound( self.Owner, "lightsaber/force_lightning" .. math.random( 1, 2 ) .. ".wav" )
				self.SoundLightning:Play()
			else
				self.SoundLightning:Play()
			end

			timer.Create( "rb655_force_lighting_soundkill", 0.2, 1, function() if ( self.SoundLightning ) then self.SoundLightning:Stop() self.SoundLightning = nil end end )
		end
		self:SetNextAttack( 0.1 )
	end
} )

/*
rb655_AddForcePower( {
	name = "Force Push",
	icon = "P",
	description = "Push obstacles out of your way !Work In Progress!",
	action = function( self )
		if ( self:GetForce() < 16 or CLIENT ) then return end

		for id, ent in pairs( ents.FindInCone( self.Owner:GetShootPos(), self.Owner:GetAimVector(), 500, .01 ) ) do--self:SelectTargets( 5 ) ) do

		if ( ent == self.Owner or ent:GetParent() == self.Owner or ent:GetMoveType() == 0 ) then continue end
		print( id, ent, ent:GetMoveType() )
			ent:SetVelocity( self.Owner:GetAimVector() * 5000 )
			if ( IsValid( ent:GetPhysicsObject() ) ) then
				for i = 0, ent:GetPhysicsObjectCount() - 1 do
					ent:GetPhysicsObjectNum( i ):SetVelocity( self.Owner:GetAimVector() * 5000 )
				end
			end
		end

		self:SetNextAttack( 1 )
	end
} )

rb655_AddForcePower( {
	name = "Force Choke",
	icon = "CH",
	target = 3,
	description = "Vader it up! !WILL NEVER WORK!",
	action = function( self )
		if ( self:GetForce() < 3 or CLIENT ) then return end

		for id, ent in pairs( self:SelectTargets( 3 ) ) do
			if ( !IsValid( ent ) or ent:GetClass() != "npc_metropolice" or ent.Chocked ) then continue end
			ent.Chocked = true
			--print( ent, ent:LookupSequence("Choked_Barnacle") )
			--PrintTable( ent:GetSequenceList() )
			ent:ResetSequence( ent:LookupSequence("Choked_Barnacle") )
			--ent:ResetSequence( ent:LookupAttachment("") )

			local elev = 100
			local time = 1
			timer.Simple( 0.1, function() if ( !IsValid( ent ) ) then return end
				ent:SetPos( ent:GetPos() + Vector( 0, 0, elev / 3 * 1 ) )
			end )
			timer.Simple( 0.2, function() if ( !IsValid( ent ) ) then return end
				ent:SetPos( ent:GetPos() + Vector( 0, 0, elev / 3 * 1 ) )
			end )
			timer.Simple( 0.3, function() if ( !IsValid( ent ) ) then return end
				ent:SetPos( ent:GetPos() + Vector( 0, 0, elev / 3 * 1 ) )
			end )

			timer.Create( "test_22_" .. ent:EntIndex(), time + 3, 1, function() if ( !IsValid( ent ) ) then return end
				local dmg = DamageInfo()
				dmg:SetAttacker( self.Owner or self )
				dmg:SetInflictor( self.Owner or self )

				dmg:SetDamage( 400 )
				ent:TakeDamageInfo( dmg )
			end )

		end

		self:SetNextAttack( 0.1 )
	end
} )*/

function rb655_GetForcePowers()
	return rb655_gForcePowers
end

---------------------------------------------------

if ( CLIENT ) then return end

-- -------------------------------------------------- Prevent +use pickup some users were reporting -------------------------------------------------- --

hook.Add( "AllowPlayerPickup", "rb655_lightsaber_prevent_use_pickup", function( ply, ent )
	if ( ent:GetClass() == "ent_lightsaber" ) then return false end
end )

-- -------------------------------------------------- "Slice" or kill sounds -------------------------------------------------- --

local function DoSliceSound( victim, inflictor )
	if ( !IsValid( victim ) or !IsValid( inflictor ) ) then return end
	if ( string.find( inflictor:GetClass(), "_lightsaber" ) ) then
		victim:EmitSound( "lightsaber/saber_hit_laser" .. math.random( 1, 5 ) .. ".wav" )
	end
end

hook.Add( "EntityTakeDamage", "rb655_lightsaber_kill_snd", function( ent, dmg )
	if ( !IsValid( ent ) or !dmg or ent:IsNPC() or ent:IsPlayer() ) then return end
	if ( ent:Health() > 0 && ent:Health() - dmg:GetDamage() <= 0 ) then
		local infl = dmg:GetInflictor()
		if ( !IsValid( infl ) && IsValid( dmg:GetAttacker() ) && dmg:GetAttacker().GetActiveWeapon ) then -- Ugly fucking haxing workaround, thanks VOLVO
			infl = dmg:GetAttacker():GetActiveWeapon()
		end
		DoSliceSound( ent, infl )
	end
end )

hook.Add( "PlayerDeath", "rb655_lightsaber_kill_snd_ply", function( victim, inflictor, attacker )
	if ( !IsValid( inflictor ) && IsValid( attacker ) && attacker.GetActiveWeapon ) then inflictor = attacker:GetActiveWeapon() end -- Ugly fucking haxing workaround, thanks VOLVO
	DoSliceSound( victim, inflictor )
end )

hook.Add( "OnNPCKilled", "rb655_lightsaber_kill_snd_npc", function( victim, attacker, inflictor )
	if ( !IsValid( inflictor ) && IsValid( attacker ) && attacker.GetActiveWeapon ) then inflictor = attacker:GetActiveWeapon() end -- Ugly fucking haxing workaround, thanks VOLVO
	DoSliceSound( victim, inflictor )
end )

-- -------------------------------------------------- Lightsaber Damage -------------------------------------------------- --

local cvar
if ( SERVER ) then
	cvar = CreateConVar( "rb655_lightsaber_allow_knockback", "1" )
end

local function IsKickbackAllowed()
	if ( cvar && cvar:GetBool() ) then return true end
	return false
end

-- A list of entities that we should not even try to deal damage to, due to them not taking dealt damage
local rb655_ls_nodamage = {
	npc_rollermine = true, -- Sigh, Lua could use arrays
	npc_turret_floor = true,
	npc_combinedropship = true,
	npc_helicopter = true,
	monster_tentacle = true,
	monster_bigmomma = true,
}
function rb655_LS_DoDamage( tr, wep )
	local ent = tr.Entity

	if ( !IsValid( ent ) or ( ent:Health() <= 0 && ent:GetClass() != "prop_ragdoll" ) or rb655_ls_nodamage[ ent:GetClass() ] ) then return end

	local dmg = hook.Run( "CanLightsaberDamageEntity", ent, wep, tr )
	if ( isbool( dmg ) && dmg == false ) then return end

	local dmginfo = DamageInfo()
	dmginfo:SetDamageForce( tr.HitNormal * -13.37 )

	if ( dmg ) then
		dmginfo:SetDamage( tonumber( dmg ) )
	else
		dmginfo:SetDamage( 25 )
	end

	if ( ( !ent:IsPlayer() or !wep:IsWeapon() ) || IsKickbackAllowed() ) then
		-- This causes the damage to apply force the the target, which we do not want
		-- For now, only apply it to the SENT
		dmginfo:SetInflictor( wep )
	end

	if ( ent:GetClass() == "npc_zombie" or ent:GetClass() == "npc_fastzombie" ) then
		dmginfo:SetDamageType( bit.bor( DMG_SLASH, DMG_CRUSH ) )
		dmginfo:SetDamageForce( tr.HitNormal * 0 )
		dmginfo:SetDamage( math.max( dmginfo:GetDamage(), 30 ) ) -- Make Zombies get cut in half
	end

	if ( !IsValid( wep.Owner ) ) then
		dmginfo:SetAttacker( wep )
	else
		dmginfo:SetAttacker( wep.Owner )
	end

	ent:TakeDamageInfo( dmginfo )
end
