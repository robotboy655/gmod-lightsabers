
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

if ( SERVER ) then
	util.AddNetworkString( "rb655_holdtype" )
	resource.AddWorkshop( "111412589" )
	CreateConVar( "rb655_lightsaber_infinite", "0" )
end

SWEP.PrintName = "Lightsaber"
SWEP.Author = "Robotboy655"
SWEP.Category = "Robotboy655's Weapons"
SWEP.Contact = "http://steamcommunity.com/profiles/76561197996891752"
SWEP.Purpose = "To slice off each others limbs and heads."
SWEP.Instructions = "Use the force, Luke."
SWEP.RenderGroup = RENDERGROUP_BOTH

SWEP.Slot = 0
SWEP.SlotPos = 4

SWEP.Spawnable = true
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.DrawWeaponInfoBox = false

SWEP.ViewModel = "models/weapons/v_crowbar.mdl"
SWEP.WorldModel = "models/sgg/starwars/weapons/w_anakin_ep2_saber_hilt.mdl"
SWEP.ViewModelFOV = 55

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"

SWEP.IsLightsaber = true

-- We have NPC support, but it SUCKS
list.Add( "NPCUsableWeapons", { class = "weapon_lightsaber", title = SWEP.PrintName } )

-- --------------------------------------------------------- Helper functions --------------------------------------------------------- --

function SWEP:PlayWeaponSound( snd, vol )
	if ( CLIENT ) then return end
	if ( IsValid( self:GetOwner() ) && IsValid( self:GetOwner():GetActiveWeapon() ) && self:GetOwner():GetActiveWeapon() != self ) then return end

	if ( snd == self:GetOnSound() || snd == self:GetOffSound() ) then vol = 0.4 end

	if ( !IsValid( self.Owner ) ) then return self:EmitSound( snd, nil, nil, vol ) end
	self.Owner:EmitSound( snd, nil, nil, vol )
end

function SWEP:SelectTargets( num )
	local t = {}
	local dist = 512

	--[[local tr = util.TraceLine( {
		start = self.Owner:GetShootPos(),
		endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * dist,
		filter = self.Owner
	} )]]

	local p = {}
	for id, ply in pairs( ents.GetAll() ) do
		if ( !ply:GetModel() or ply:GetModel() == "" or ply == self.Owner or ply:Health() < 1 ) then continue end
		if ( string.StartWith( ply:GetModel() or "", "models/gibs/" ) ) then continue end
		if ( string.find( ply:GetModel() or "", "chunk" ) ) then continue end
		if ( string.find( ply:GetModel() or "", "_shard" ) ) then continue end
		if ( string.find( ply:GetModel() or "", "_splinters" ) ) then continue end

		local tr = util.TraceLine( {
			start = self.Owner:GetShootPos(),
			endpos = ply.GetShootPos && ply:GetShootPos() or ply:GetPos(),
			filter = self.Owner,
		} )

		if ( tr.Entity != ply && IsValid( tr.Entity ) or tr.Entity == game.GetWorld() ) then continue end

		local pos1 = self.Owner:GetPos() + self.Owner:GetAimVector() * dist
		local pos2 = ply:GetPos()
		local dot = self.Owner:GetAimVector():Dot( ( self.Owner:GetPos() - pos2 ):GetNormalized() )

		if ( pos1:Distance( pos2 ) <= dist && ply:EntIndex() > 0 && ply:GetModel() && ply:GetModel() != "" ) then
			table.insert( p, { ply = ply, dist = tr.HitPos:Distance( pos2 ), dot = dot, score = -dot + ( ( dist - pos1:Distance( pos2 ) ) / dist ) * 50 } )
		end
	end

	for id, ply in SortedPairsByMemberValue( p, "dist" ) do
		table.insert( t, ply.ply )
		if ( #t >= num ) then return t end
	end

	return t
end

-- --------------------------------------------------------- Force Powers --------------------------------------------------------- --

function SWEP:GetActiveForcePowers()
	local ForcePowers = {}
	for id, t in pairs( rb655_GetForcePowers() ) do
		local ret = hook.Run( "CanUseLightsaberForcePower", self:GetOwner(), t.name )
		if ( ret == false ) then continue end

		table.insert( ForcePowers, t )
	end
	return ForcePowers
end

function SWEP:GetActiveForcePowerType( id )
	local ForcePowers = self:GetActiveForcePowers()
	return ForcePowers[ id ]
end

if ( SERVER ) then
	concommand.Add( "rb655_select_force", function( ply, cmd, args )
		if ( !IsValid( ply ) or !IsValid( ply:GetActiveWeapon() ) or !rb655_IsLightsaber( ply:GetActiveWeapon() ) or !tonumber( args[ 1 ] ) ) then return end

		local wep = ply:GetActiveWeapon()
		local ForcePowers = #wep:GetActiveForcePowers()
		local typ = math.Clamp( tonumber( args[ 1 ] ), 1, ForcePowers )
		wep:SetForceType( typ )
	end )

	concommand.Add( "rb655_select_next", function( ply, cmd, args )
		if ( !IsValid( ply ) or !IsValid( ply:GetActiveWeapon() ) or !rb655_IsLightsaber( ply:GetActiveWeapon() ) or !tonumber( args[ 1 ] ) ) then return end

		local wep = ply:GetActiveWeapon()
		local ForcePowers = #wep:GetActiveForcePowers()

		local current = wep:GetForceType()
		current = current + math.Clamp( tonumber( args[ 1 ] ), -1, 1 )
		if ( current < 1 ) then current = ForcePowers end
		if ( current > ForcePowers ) then current = 1 end

		local typ = math.Clamp( current, 1, ForcePowers )
		wep:SetForceType( typ )
	end )
end

hook.Add( "GetFallDamage", "rb655_lightsaber_no_fall_damage", function( ply, speed )
	if ( IsValid( ply ) && IsValid( ply:GetActiveWeapon() ) && rb655_IsLightsaber( ply:GetActiveWeapon() ) ) then
		local wep = ply:GetActiveWeapon()

		if ( ply:KeyDown( IN_DUCK ) ) then
			ply:SetNWFloat( "SWL_FeatherFall", CurTime() ) -- Hate on me for NWVars!
			wep:SetNextAttack( 0.5 )
			ply:ViewPunch( Angle( speed / 32, 0, math.random( -speed, speed ) / 128 ) )
			return 0
		end
	end
end )

function SWEP:OnRestore()
	self.Owner:SetNWFloat( "SWL_FeatherFall", 0 )
end

hook.Add( "CreateMove", "rb655_lightsaber_no_fall_damage", function( cmd )
	if ( CurTime() - LocalPlayer():GetNWFloat( "SWL_FeatherFall", CurTime() - 2 ) < 1 ) then
		cmd:ClearButtons() -- No attacking, we are busy
		cmd:ClearMovement() -- No moving, we are busy
		cmd:SetButtons( IN_DUCK ) -- Force them to crouch
	end
end )

function SWEP:SetNextAttack( delay )
	self:SetNextPrimaryFire( CurTime() + delay )
	self:SetNextSecondaryFire( CurTime() + delay )
end

function SWEP:ForceJumpAnim()
	self.Owner.m_bJumping = true

	self.Owner.m_bFirstJumpFrame = true
	self.Owner.m_flJumpStartTime = CurTime()

	self.Owner:AnimRestartMainSequence()
end

-- --------------------------------------------------------- Initialize --------------------------------------------------------- --

function SWEP:SetupDataTables()
	self:NetworkVar( "Float", 0, "LengthAnimation" )
	self:NetworkVar( "Float", 1, "MaxLength" )
	self:NetworkVar( "Float", 2, "BladeWidth" )
	self:NetworkVar( "Float", 3, "Force" )

	self:NetworkVar( "Bool", 0, "DarkInner" )
	self:NetworkVar( "Bool", 1, "Enabled" )
	self:NetworkVar( "Bool", 2, "WorksUnderwater" )
	self:NetworkVar( "Int", 0, "ForceType" )
	self:NetworkVar( "Int", 1, "IncorrectPlayerModel" )
	self:NetworkVar( "Int", 2, "MaxForce" )

	self:NetworkVar( "Vector", 0, "CrystalColor" )
	self:NetworkVar( "String", 0, "WorldModel" )
	self:NetworkVar( "String", 1, "OnSound" )
	self:NetworkVar( "String", 2, "OffSound" )

	if ( SERVER ) then
		self:SetLengthAnimation( 0 )
		self:SetBladeWidth( 2 )
		self:SetMaxLength( 42 )
		self:SetDarkInner( false )
		self:SetWorksUnderwater( true )
		self:SetEnabled( false )

		self:SetForceType( 1 )
		self:SetMaxForce( 100 )
		self:SetForce( self:GetMaxForce() )
		self:SetOnSound( "lightsaber/saber_on" .. math.random( 1, 4 ) .. ".wav" )
		self:SetOffSound( "lightsaber/saber_off" .. math.random( 1, 4 ) .. ".wav" )
		self:SetCrystalColor( Vector( math.random( 0, 255 ), math.random( 0, 255 ), math.random( 0, 255 ) ) )

		local _, k = table.Random( list.Get( "LightsaberModels" ) )
		self:SetWorldModel( k or "models/sgg/starwars/weapons/w_anakin_ep2_saber_hilt.mdl" )
		--self:SetWorldModel( "models/sgg/starwars/weapons/w_anakin_ep2_saber_hilt.mdl" )

		self:NetworkVarNotify( "Force", self.OnForceChanged )
		self:NetworkVarNotify( "Enabled", self.OnEnabledOrDisabled )
	end
end

function SWEP:GetBladeLength()
	return self:GetLengthAnimation() * self:GetMaxLength()
end

function SWEP:SetBladeLength( val )
	self:SetLengthAnimation( val / self:GetMaxLength() )
	MsgN( "Lightsaber.SetBladeLength is deprecated!" )
end

function SWEP:LoadToolValues( ply )
	local maxLen = ply:GetInfoNum( "rb655_lightsaber_bladel", 42 )
	local bldWidth = ply:GetInfoNum( "rb655_lightsaber_bladew", 2 )
	if ( !game.SinglePlayer() ) then
		maxLen = math.Clamp( maxLen, 32, 64 )
		bldWidth = math.Clamp( bldWidth, 2, 4 )
	end

	self:SetMaxLength( maxLen )
	self:SetBladeWidth( bldWidth )
	self:SetCrystalColor( Vector( ply:GetInfo( "rb655_lightsaber_red" ), ply:GetInfo( "rb655_lightsaber_green" ), ply:GetInfo( "rb655_lightsaber_blue" ) ) )
	self:SetDarkInner( ply:GetInfo( "rb655_lightsaber_dark" ) == "1" )
	self:SetWorldModel( ply:GetInfo( "rb655_lightsaber_model" ) )
	self:SetModel( self:GetWorldModel() )
	self.WorldModel = self:GetWorldModel()
	--self:PhysicsInit( SOLID_VPHYSICS )

	self.LoopSound = ply:GetInfo( "rb655_lightsaber_humsound" )
	self.SwingSound = ply:GetInfo( "rb655_lightsaber_swingsound" )
	self:SetOnSound( ply:GetInfo( "rb655_lightsaber_onsound" ) )
	self:SetOffSound( ply:GetInfo( "rb655_lightsaber_offsound" ) )
	--self:SetEnabled( ply:GetInfo( "rb655_lightsaber_starton" ) )

	self.WeaponSynched = true

	-- Start it if we spawned it using the spawnmenu!
	if ( !IsValid( self.Owner ) || self.Owner:IsPlayer() ) then
		-- Gotta wait a tick so we don't play double sounds!
		timer.Simple( 0, function() if ( !IsValid( self ) ) then return end self:SetEnabled( true ) end )
	end
end

hook.Add( "PlayerSpawnedNPC", "rb655_lightsaber_npc_sync", function( ply, npc )
	if ( !npc:IsNPC() or !IsValid( npc:GetActiveWeapon() ) or !rb655_IsLightsaber( npc:GetActiveWeapon() ) ) then return end
	npc:GetActiveWeapon():LoadToolValues( ply )
end )

hook.Add( "PlayerSpawnedSWEP", "rb655_lightsaber_swep_sync", function( ply, wep )
	if ( !rb655_IsLightsaber( wep ) ) then return end

	wep:LoadToolValues( ply )
end )

function SWEP:Initialize()
	self.LoopSound = self.LoopSound or "lightsaber/saber_loop" .. math.random( 1, 8 ) .. ".wav"
	self.SwingSound = self.SwingSound or "lightsaber/saber_swing" .. math.random( 1, 2 ) .. ".wav"

	self:SetWeaponHoldType( self:GetTargetHoldType() )

	if ( self.Owner && self.Owner:IsNPC() && SERVER ) then -- NPC Weapons
		--self.Owner:Fire( "GagEnable" )

		if ( self.Owner:GetClass() == "npc_citizen" ) then
			self.Owner:Fire( "DisableWeaponPickup" )
		end

		self.Owner:SetKeyValue( "spawnflags", "256" )

		hook.Add( "Think", self, self.NPCThink )

		timer.Simple( 0.5, function()
			if ( !IsValid( self ) or !IsValid( self.Owner ) ) then return end
			self.Owner:SetCurrentWeaponProficiency( 4 )
			self.Owner:CapabilitiesAdd( CAP_FRIENDLY_DMG_IMMUNE )
			self.Owner:CapabilitiesRemove( CAP_WEAPON_MELEE_ATTACK1 )
			self.Owner:CapabilitiesRemove( CAP_INNATE_MELEE_ATTACK1 )
		end )
	end
end

-- --------------------------------------------------------- NPC Weapons --------------------------------------------------------- --

function SWEP:SetupWeaponHoldTypeForAI( t )
	if ( !self.Owner:IsNPC() ) then return end

	self.ActivityTranslateAI = {}

	self.ActivityTranslateAI[ ACT_IDLE ]					= ACT_IDLE
	self.ActivityTranslateAI[ ACT_IDLE_ANGRY ]				= ACT_IDLE_ANGRY_MELEE
	self.ActivityTranslateAI[ ACT_IDLE_RELAXED ]			= ACT_IDLE
	self.ActivityTranslateAI[ ACT_IDLE_STIMULATED ]			= ACT_IDLE_ANGRY_MELEE
	self.ActivityTranslateAI[ ACT_IDLE_AGITATED ]			= ACT_IDLE_ANGRY_MELEE
	self.ActivityTranslateAI[ ACT_IDLE_AIM_RELAXED ]		= ACT_IDLE_ANGRY_MELEE
	self.ActivityTranslateAI[ ACT_IDLE_AIM_STIMULATED ]		= ACT_IDLE_ANGRY_MELEE
	self.ActivityTranslateAI[ ACT_IDLE_AIM_AGITATED ]		= ACT_IDLE_ANGRY_MELEE

	self.ActivityTranslateAI[ ACT_RANGE_ATTACK1 ]			= ACT_RANGE_ATTACK_THROW
	self.ActivityTranslateAI[ ACT_RANGE_ATTACK1_LOW ]		= ACT_MELEE_ATTACK_SWING
	self.ActivityTranslateAI[ ACT_MELEE_ATTACK1 ]			= ACT_MELEE_ATTACK_SWING
	self.ActivityTranslateAI[ ACT_MELEE_ATTACK2 ]			= ACT_MELEE_ATTACK_SWING
	self.ActivityTranslateAI[ ACT_SPECIAL_ATTACK1 ]			= ACT_RANGE_ATTACK_THROW

	self.ActivityTranslateAI[ ACT_RANGE_AIM_LOW ]			= ACT_IDLE_ANGRY_MELEE
	self.ActivityTranslateAI[ ACT_COVER_LOW ]				= ACT_IDLE_ANGRY_MELEE

	self.ActivityTranslateAI[ ACT_WALK ]					= ACT_WALK
	self.ActivityTranslateAI[ ACT_WALK_RELAXED ]			= ACT_WALK
	self.ActivityTranslateAI[ ACT_WALK_STIMULATED ]			= ACT_WALK
	self.ActivityTranslateAI[ ACT_WALK_AGITATED ]			= ACT_WALK

	self.ActivityTranslateAI[ ACT_RUN_CROUCH ]				= ACT_RUN
	self.ActivityTranslateAI[ ACT_RUN_CROUCH_AIM ]			= ACT_RUN
	self.ActivityTranslateAI[ ACT_RUN ]						= ACT_RUN
	self.ActivityTranslateAI[ ACT_RUN_AIM_RELAXED ]			= ACT_RUN
	self.ActivityTranslateAI[ ACT_RUN_AIM_STIMULATED ]		= ACT_RUN
	self.ActivityTranslateAI[ ACT_RUN_AIM_AGITATED ]		= ACT_RUN
	self.ActivityTranslateAI[ ACT_RUN_AIM ]					= ACT_RUN
	self.ActivityTranslateAI[ ACT_SMALL_FLINCH ]			= ACT_RANGE_ATTACK_PISTOL
	self.ActivityTranslateAI[ ACT_BIG_FLINCH ]				= ACT_RANGE_ATTACK_PISTOL

	if ( self.Owner:GetClass() == "npc_metropolice" ) then

	self.ActivityTranslateAI[ ACT_IDLE ]					= ACT_IDLE
	self.ActivityTranslateAI[ ACT_IDLE_ANGRY ]				= ACT_IDLE_ANGRY_MELEE
	self.ActivityTranslateAI[ ACT_IDLE_RELAXED ]			= ACT_IDLE
	self.ActivityTranslateAI[ ACT_IDLE_STIMULATED ]			= ACT_IDLE
	self.ActivityTranslateAI[ ACT_IDLE_AGITATED ]			= ACT_IDLE_ANGRY_MELEE

	self.ActivityTranslateAI[ ACT_MP_RUN ]					= ACT_HL2MP_RUN_SUITCASE
	self.ActivityTranslateAI[ ACT_WALK ]					= ACT_WALK_SUITCASE
	self.ActivityTranslateAI[ ACT_MELEE_ATTACK1 ]			= ACT_MELEE_ATTACK_SWING
	self.ActivityTranslateAI[ ACT_RANGE_ATTACK1 ]			= ACT_MELEE_ATTACK_SWING
	self.ActivityTranslateAI[ ACT_SPECIAL_ATTACK1 ]			= ACT_RANGE_ATTACK_THROW
	self.ActivityTranslateAI[ ACT_SMALL_FLINCH ]			= ACT_RANGE_ATTACK_PISTOL
	self.ActivityTranslateAI[ ACT_BIG_FLINCH ]				= ACT_RANGE_ATTACK_PISTOL

	return end

	if ( self.Owner:GetClass() == "npc_combine_s2" ) then

	self.ActivityTranslateAI[ ACT_IDLE ]					= ACT_IDLE
	self.ActivityTranslateAI[ ACT_IDLE_ANGRY ]				= ACT_IDLE_ANGRY_MELEE
	self.ActivityTranslateAI[ ACT_IDLE_RELAXED ]			= ACT_IDLE
	self.ActivityTranslateAI[ ACT_IDLE_STIMULATED ]			= ACT_IDLE_ANGRY_MELEE
	self.ActivityTranslateAI[ ACT_IDLE_AGITATED ]			= ACT_IDLE_ANGRY_MELEE
	self.ActivityTranslateAI[ ACT_IDLE_AIM_RELAXED ]		= ACT_IDLE_ANGRY_MELEE
	self.ActivityTranslateAI[ ACT_IDLE_AIM_STIMULATED ]		= ACT_IDLE_ANGRY_MELEE
	self.ActivityTranslateAI[ ACT_IDLE_AIM_AGITATED ]		= ACT_IDLE_ANGRY_MELEE

	self.ActivityTranslateAI[ ACT_RANGE_ATTACK1 ]			= ACT_RANGE_ATTACK_THROW
	self.ActivityTranslateAI[ ACT_RANGE_ATTACK1_LOW ]		= ACT_MELEE_ATTACK_SWING
	self.ActivityTranslateAI[ ACT_MELEE_ATTACK1 ]			= ACT_MELEE_ATTACK_SWING
	self.ActivityTranslateAI[ ACT_MELEE_ATTACK2 ]			= ACT_MELEE_ATTACK_SWING
	self.ActivityTranslateAI[ ACT_SPECIAL_ATTACK1 ]			= ACT_RANGE_ATTACK_THROW


	self.ActivityTranslateAI[ ACT_RANGE_AIM_LOW ]			 = ACT_IDLE_ANGRY_MELEE
	self.ActivityTranslateAI[ ACT_COVER_LOW ]				= ACT_IDLE_ANGRY_MELEE

	self.ActivityTranslateAI[ ACT_WALK ]					= ACT_WALK
	self.ActivityTranslateAI[ ACT_WALK_RELAXED ]			= ACT_WALK
	self.ActivityTranslateAI[ ACT_WALK_STIMULATED ]			= ACT_WALK
	self.ActivityTranslateAI[ ACT_WALK_AGITATED ]			= ACT_WALK

	self.ActivityTranslateAI[ ACT_RUN ]						= ACT_RUN
	self.ActivityTranslateAI[ ACT_RUN_AIM_RELAXED ]			= ACT_RUN
	self.ActivityTranslateAI[ ACT_RUN_AIM_STIMULATED ]		= ACT_RUN
	self.ActivityTranslateAI[ ACT_RUN_AIM_AGITATED ]		= ACT_RUN
	self.ActivityTranslateAI[ ACT_RUN_AIM ]					= ACT_RUN
	self.ActivityTranslateAI[ ACT_SMALL_FLINCH ]			= ACT_RANGE_ATTACK_PISTOL
	self.ActivityTranslateAI[ ACT_BIG_FLINCH ]				= ACT_RANGE_ATTACK_PISTOL

	return end

	if ( self.Owner:GetClass() == "npc_combine_s" ) then

	self.ActivityTranslateAI[ ACT_IDLE ]					= ACT_IDLE_UNARMED
	self.ActivityTranslateAI[ ACT_IDLE_ANGRY ]				= ACT_IDLE_SHOTGUN
	self.ActivityTranslateAI[ ACT_IDLE_RELAXED ]			= ACT_IDLE_SHOTGUN
	self.ActivityTranslateAI[ ACT_IDLE_STIMULATED ]			= ACT_IDLE_SHOTGUN
	self.ActivityTranslateAI[ ACT_IDLE_AGITATED ]			= ACT_IDLE_SHOTGUN
	self.ActivityTranslateAI[ ACT_IDLE_AIM_RELAXED ]		= ACT_IDLE_SHOTGUN
	self.ActivityTranslateAI[ ACT_IDLE_AIM_STIMULATED ]		= ACT_IDLE_SHOTGUN
	self.ActivityTranslateAI[ ACT_IDLE_AIM_AGITATED ]		= ACT_IDLE_SHOTGUN

	self.ActivityTranslateAI[ ACT_RANGE_ATTACK1 ]			= ACT_MELEE_ATTACK1
	self.ActivityTranslateAI[ ACT_RANGE_ATTACK1_LOW ]		= ACT_MELEE_ATTACK1
	self.ActivityTranslateAI[ ACT_MELEE_ATTACK1 ]			= ACT_MELEE_ATTACK1
	self.ActivityTranslateAI[ ACT_MELEE_ATTACK2 ]			= ACT_MELEE_ATTACK1
	self.ActivityTranslateAI[ ACT_SPECIAL_ATTACK1 ]			= ACT_MELEE_ATTACK1

	self.ActivityTranslateAI[ ACT_RANGE_AIM_LOW ]			 = ACT_IDLE_SHOTGUN
	self.ActivityTranslateAI[ ACT_COVER_LOW ]				= ACT_IDLE_SHOTGUN

	self.ActivityTranslateAI[ ACT_WALK ]					= ACT_WALK_UNARMED
	self.ActivityTranslateAI[ ACT_WALK_RELAXED ]			= ACT_WALK_UNARMED
	self.ActivityTranslateAI[ ACT_WALK_STIMULATED ]			= ACT_WALK_UNARMED
	self.ActivityTranslateAI[ ACT_WALK_AGITATED ]			= ACT_WALK_UNARMED

	self.ActivityTranslateAI[ ACT_RUN ]						= ACT_RUN_AIM_SHOTGUN
	self.ActivityTranslateAI[ ACT_RUN_AIM_RELAXED ]			= ACT_RUN_AIM_SHOTGUN
	self.ActivityTranslateAI[ ACT_RUN_AIM_STIMULATED ]		= ACT_RUN_AIM_SHOTGUN
	self.ActivityTranslateAI[ ACT_RUN_AIM_AGITATED ]		= ACT_RUN_AIM_SHOTGUN
	self.ActivityTranslateAI[ ACT_RUN_AIM ]					= ACT_RUN_AIM_SHOTGUN

	return end
end

function SWEP:GetCapabilities()
	return bit.bor( CAP_WEAPON_MELEE_ATTACK1 )
end

function SWEP:NPC_NextLogic()
	if ( !IsValid( self ) or !IsValid( self.Owner ) ) then return end
	if ( self.Owner:IsCurrentSchedule( SCHED_CHASE_ENEMY ) ) then return end
	self.NPC_NextLogicTimer = true
	self:NPC_ChaseEnemy()

	timer.Simple( math.Rand( 0.7, 1 ), function()
		self.NPC_NextLogicTimer = false
	end )
end

function SWEP:NPC_ChaseEnemy()
	if ( !IsValid( self ) or !IsValid( self.Owner ) ) then return end
	if ( self.Owner:GetEnemy():GetPos():Distance( self:GetPos() ) > 70 ) then
		self.Owner:SetSchedule( SCHED_CHASE_ENEMY )
	end

	if ( self.Owner:GetEnemy() == self.Owner ) then self.Owner:SetEnemy( NULL ) return end
	if ( !self.CooldownTimer && self.Owner:GetEnemy():GetPos():Distance( self:GetPos() ) <= 70 ) then
		self.Owner:SetSchedule( SCHED_MELEE_ATTACK1 )
		self:NPCShoot_Primary( ShootPos, ShootDir )
	end
end

function SWEP:NPCThink()
	if ( !IsValid( self.Owner ) or !IsValid( self ) or !self.Owner:IsNPC() ) then return end

	if ( self:GetEnabled() != IsValid( self.Owner:GetEnemy() ) ) then self:SetEnabled( IsValid( self.Owner:GetEnemy() ) ) end

	--self.Owner:RemoveAllDecals()
	self.Owner:ClearCondition( 13 )
	self.Owner:ClearCondition( 17 )
	self.Owner:ClearCondition( 18 )
	self.Owner:ClearCondition( 20 )
	self.Owner:ClearCondition( 48 )
	self.Owner:ClearCondition( 42 )
	self.Owner:ClearCondition( 45 )

	if ( !self.NPC_NextLogicTimer && IsValid( self.Owner:GetEnemy() ) ) then
		self:NPC_NextLogic()
	end

	self:Think()
end

function SWEP:NPCShoot_Primary( ShootPos, ShootDir )
	if ( !IsValid( self ) or !IsValid( self.Owner ) ) then return end
	if ( !self.Owner:GetEnemy() ) then return end

	self.CooldownTimer = true
	local seqtimer = 0.4
	if self.Owner:GetClass() == "npc_alyx" then
		seqtimer = 0.8
	end

	timer.Simple( seqtimer, function()
		if ( !IsValid( self ) or !IsValid( self.Owner ) ) then return end
		--[[if ( self.Owner:IsCurrentSchedule( SCHED_MELEE_ATTACK1 ) ) then
			self:PrimaryAttack()
		end]]
		self.CooldownTimer = false
	end )
end

-- --------------------------------------------------------- Attacks --------------------------------------------------------- --

-- TODO: HOOK THIS
function SWEP:PrimaryAttack()
	if ( !IsValid( self.Owner ) ) then return end

	self:SetNextAttack( 0.5 )

	if ( !self.Owner:IsNPC() && self:GetEnabled() ) then
		self.Owner:AnimResetGestureSlot( GESTURE_SLOT_CUSTOM )
		self.Owner:SetAnimation( PLAYER_ATTACK1 )
	end
end

function SWEP:SecondaryAttack()
	if ( !IsValid( self.Owner ) or !self:GetActiveForcePowerType( self:GetForceType() ) ) then return end
	if ( game.SinglePlayer() && SERVER ) then self:CallOnClient( "SecondaryAttack", "" ) end

	local selectedForcePower = self:GetActiveForcePowerType( self:GetForceType() )
	if ( !selectedForcePower ) then return end

	local ret = hook.Run( "CanUseLightsaberForcePower", self.Owner, selectedForcePower.name )
	if ( ret == false ) then return end

	if ( selectedForcePower.action ) then
		selectedForcePower.action( self, self.Owner )
		if ( GetConVarNumber( "rb655_lightsaber_infinite" ) != 0 ) then self:SetForce( self:GetMaxForce() ) end
	end
end

function SWEP:Reload()
	if ( !self.Owner:KeyPressed( IN_RELOAD ) ) then return end
	if ( self.Owner:WaterLevel() > 2 && !self:GetWorksUnderwater() ) then return end

	self:SetEnabled( !self:GetEnabled() )
end

-- --------------------------------------------------------- Hold Types --------------------------------------------------------- --

function SWEP:GetTargetHoldType()
	--if ( !self:GetEnabled() ) then return "normal" end
	if ( self:GetWorldModel() == "models/weapons/starwars/w_maul_saber_staff_hilt.mdl" ) then return "knife" end
	if ( self:LookupAttachment( "blade2" ) && self:LookupAttachment( "blade2" ) > 0 ) then return "knife" end

	return "melee2"
end

-- --------------------------------------------------------- Drop / Deploy / Holster / Enable / Disable --------------------------------------------------------- --

function SWEP:OnEnabled( bDeploy )
	if ( ( !self:GetEnabled() or bDeploy ) and IsValid( self.Owner ) ) then self:PlayWeaponSound( self:GetOnSound() ) end

	if ( CLIENT or ( self:GetEnabled() and !bDeploy ) ) then return end

	self:SetHoldType( self:GetTargetHoldType() )
	timer.Remove( "rb655_ls_ht" .. self:EntIndex() )

	-- Don't (re)create the sounds if we don't have an owner or we already have the sounds
	if ( !IsValid( self.Owner ) || self.SoundLoop ) then return end

	self.SoundLoop = CreateSound( self.Owner, Sound( self.LoopSound ) )
	if ( self.SoundLoop ) then self.SoundLoop:Play() self.SoundLoop:ChangeVolume( 0, 0 ) end

	self.SoundSwing = CreateSound( self.Owner, Sound( self.SwingSound ) )
	if ( self.SoundSwing ) then self.SoundSwing:Play() self.SoundSwing:ChangeVolume( 0, 0 ) end

	self.SoundHit = CreateSound( self.Owner, Sound( self.HitSound || "lightsaber/saber_hit.wav" ) )
	if ( self.SoundHit ) then self.SoundHit:Play() self.SoundHit:ChangeVolume( 0, 0 ) end
end

function SWEP:OnDisabled( bRemoved )
	if ( CLIENT ) then
		if ( bRemoved ) then rb655_SaberClean( self:EntIndex() ) end
		return true
	end

	if ( self.SoundLoop ) then self.SoundLoop:Stop() self.SoundLoop = nil end
	if ( self.SoundSwing ) then self.SoundSwing:Stop() self.SoundSwing = nil end
	if ( self.SoundHit ) then self.SoundHit:Stop() self.SoundHit = nil end

	return true
end

function SWEP:OnEnabledOrDisabled( name, old, new )
	if ( old == new ) then return end

	if ( new ) then
		self:OnEnabled()
	else
		self:PlayWeaponSound( self:GetOffSound() )

		-- Fancy extinguish animations?
		timer.Create( "rb655_ls_ht" .. self:EntIndex(), 0.4, 1, function() if ( IsValid( self ) ) then self:SetHoldType( "normal" ) end end )

		self:OnDisabled()
	end
end

function SWEP:OnDrop()
	if ( self:GetEnabled() ) then self:PlayWeaponSound( self:GetOffSound() ) end
	self:OnDisabled( true )
end

function SWEP:OnRemove()
	if ( self:GetEnabled() && IsValid( self.Owner ) ) then self:PlayWeaponSound( self:GetOffSound() ) end
	self:OnDisabled( true )
end

function SWEP:Deploy()

	local ply = self.Owner

	if ( ply:IsPlayer() && !ply:IsBot() && !self.WeaponSynched && SERVER && GAMEMODE.IsSandboxDerived ) then
		self:LoadToolValues( ply )
	end

	-- We only want to do this in Sandbox, not any derivatives
	if ( GAMEMODE.Name == "Sandbox" ) then
		ply:SendLua( 'GAMEMODE:AddHint( "LightsaberCustomizationHint", 7 )' )
	end

	if ( self:GetEnabled() ) then self:OnEnabled( true ) else self:SetHoldType( "normal" ) end

	if ( CLIENT ) then return end

	if ( ply:IsPlayer() && ply:FlashlightIsOn() ) then ply:Flashlight( false ) end

	self:SetLengthAnimation( 0 ) -- Reinitialize the effect

	return true
end

function SWEP:Holster()
	if ( self:GetEnabled() ) then self:PlayWeaponSound( self:GetOffSound() ) end

	self:SetLengthAnimation( 0 ) -- For the effect

	return self:OnDisabled( true )
end

-- --------------------------------------------------------- Think --------------------------------------------------------- --

function SWEP:GetSaberPosAng( num, side )
	num = num or 1

	if ( SERVER ) then self:SetIncorrectPlayerModel( 0 ) end

	if ( IsValid( self.Owner ) ) then
		local bone = self.Owner:LookupBone( "ValveBiped.Bip01_R_Hand" )
		local attachment = self:LookupAttachment( "blade" .. num )
		if ( side ) then
			attachment = self:LookupAttachment( "quillon" .. num )
		end

		if ( !bone && SERVER ) then
			self:SetIncorrectPlayerModel( 1 )
		end

		if ( attachment && attachment > 0 ) then
			local PosAng = self:GetAttachment( attachment )

			if ( !bone && SERVER ) then
				PosAng.Pos = PosAng.Pos + Vector( 0, 0, 36 )
				if ( SERVER && IsValid( self.Owner ) && self.Owner:IsPlayer() && self.Owner:Crouching() ) then PosAng.Pos = PosAng.Pos - Vector( 0, 0, 18 ) end
				PosAng.Ang.p = 0
			end

			return PosAng.Pos, PosAng.Ang:Forward()
		end

		if ( bone ) then
			local pos, ang = self.Owner:GetBonePosition( bone )
			if ( pos == self.Owner:GetPos() ) then
				local matrix = self.Owner:GetBoneMatrix( bone )
				if ( matrix ) then
					pos = matrix:GetTranslation()
					ang = matrix:GetAngles()
				else
					self:SetIncorrectPlayerModel( 1 )
				end
			end

			ang:RotateAroundAxis( ang:Forward(), 180 )
			ang:RotateAroundAxis( ang:Up(), 30 )
			ang:RotateAroundAxis( ang:Forward(), -5.7 )
			ang:RotateAroundAxis( ang:Right(), 92 )

			pos = pos + ang:Up() * -3.3 + ang:Right() * 0.8 + ang:Forward() * 5.6

			return pos, ang:Forward()
		end

		self:SetIncorrectPlayerModel( 1 )
	else
		self:SetIncorrectPlayerModel( 2 )
	end

	if ( self:GetIncorrectPlayerModel() == 0 ) then self:SetIncorrectPlayerModel( 1 ) end

	local defAng = self:GetAngles()
	defAng.p = 0

	local defPos = self:GetPos() + defAng:Right() * 0.6 - defAng:Up() * 0.2 + defAng:Forward() * 0.8
	if ( SERVER ) then defPos = defPos + Vector( 0, 0, 36 ) end
	if ( SERVER && IsValid( self.Owner ) && self.Owner:Crouching() ) then defPos = defPos - Vector( 0, 0, 18 ) end

	return defPos, -defAng:Forward()
end

function SWEP:OnForceChanged( name, old, new )
	if ( old > new ) then
		self.NextForce = CurTime() + 4
	end
end

function SWEP:Think()
	self.WorldModel = self:GetWorldModel()
	self:SetModel( self:GetWorldModel() )

	local selectedForcePower = self:GetActiveForcePowerType( self:GetForceType() )
	if ( selectedForcePower && selectedForcePower.think && !self.Owner:KeyDown( IN_USE ) ) then
		local ret = hook.Run( "CanUseLightsaberForcePower", self.Owner, selectedForcePower.name )
		if ( ret != false && selectedForcePower.think ) then
			selectedForcePower.think( self )
		end
	end

	if ( CLIENT ) then return true end

	if ( ( self.NextForce or 0 ) < CurTime() ) then
		self:SetForce( math.min( self:GetForce() + 0.5, self:GetMaxForce() ) )
	end

	if ( !self:GetEnabled() && self:GetLengthAnimation() != 0 ) then
		self:SetLengthAnimation( math.Approach( self:GetLengthAnimation(), 0, FrameTime() * 3 ) )
	elseif ( self:GetEnabled() && self:GetLengthAnimation() != 1 ) then
		self:SetLengthAnimation( math.Approach( self:GetLengthAnimation(), 1, FrameTime() * 10 ) )
	end

	if ( self:GetEnabled() && !self:GetWorksUnderwater() && self.Owner:WaterLevel() > 2 ) then
		self:SetEnabled( false )
		--self:EmitSound( self:GetOffSound() )
	end

	if ( self:GetBladeLength() <= 0 ) then return end

	-- ------------------------------------------------- DAMAGE ------------------------------------------------- --

	-- This whole system needs rework

	-- Up
	local isTrace1Hit = false
	local pos, ang = self:GetSaberPosAng()
	local trace = util.TraceLine( {
		start = pos,
		endpos = pos + ang * self:GetBladeLength(),
		filter = { self, self.Owner },
		--mins = Vector( -1, -1, -1 ) * self:GetBladeWidth() / 8,
		--maxs = Vector( 1, 1, 1 ) * self:GetBladeWidth() / 8
	} )
	local traceBack = util.TraceLine( {
		start = pos + ang * self:GetBladeLength(),
		endpos = pos,
		filter = { self, self.Owner },
		--mins = Vector( -1, -1, -1 ) * self:GetBladeWidth() / 8,
		--maxs = Vector( 1, 1, 1 ) * self:GetBladeWidth() / 8
	} )

	--if ( SERVER ) then debugoverlay.Line( trace.StartPos, trace.HitPos, .1, Color( 255, 0, 0 ), false ) end

	-- When the blade is outside of the world
	if ( trace.HitSky or ( trace.StartSolid && trace.HitWorld ) ) then trace.Hit = false end
	if ( traceBack.HitSky or ( traceBack.StartSolid && traceBack.HitWorld ) ) then traceBack.Hit = false end

	self:DrawHitEffects( trace, traceBack )
	isTrace1Hit = trace.Hit or traceBack.Hit

	-- Don't deal the damage twice to the same entity
	if ( traceBack.Entity == trace.Entity && IsValid( trace.Entity ) ) then traceBack.Hit = false end

	if ( trace.Hit ) then rb655_LS_DoDamage( trace, self ) end
	if ( traceBack.Hit ) then rb655_LS_DoDamage( traceBack, self ) end

	-- Down
	local isTrace2Hit = false
	if ( self:LookupAttachment( "blade2" ) > 0 ) then -- TEST ME
		local pos2, dir2 = self:GetSaberPosAng( 2 )
		local trace2 = util.TraceLine( {
			start = pos2,
			endpos = pos2 + dir2 * self:GetBladeLength(),
			filter = { self, self.Owner },
			--mins = Vector( -1, -1, -1 ) * self:GetBladeWidth() / 8,
			--maxs = Vector( 1, 1, 1 ) * self:GetBladeWidth() / 8
		} )
		local traceBack2 = util.TraceLine( {
			start = pos2 + dir2 * self:GetBladeLength(),
			endpos = pos2,
			filter = { self, self.Owner },
			--mins = Vector( -1, -1, -1 ) * self:GetBladeWidth() / 8,
			--maxs = Vector( 1, 1, 1 ) * self:GetBladeWidth() / 8
		} )

		if ( trace2.HitSky or ( trace2.StartSolid && trace2.HitWorld ) ) then trace2.Hit = false end
		if ( traceBack2.HitSky or ( traceBack2.StartSolid && traceBack2.HitWorld ) ) then traceBack2.Hit = false end

		self:DrawHitEffects( trace2, traceBack2 )
		isTrace2Hit = trace2.Hit or traceBack2.Hit

		if ( traceBack2.Entity == trace2.Entity && IsValid( trace2.Entity ) ) then traceBack2.Hit = false end

		if ( trace2.Hit ) then rb655_LS_DoDamage( trace2, self ) end
		if ( traceBack2.Hit ) then rb655_LS_DoDamage( traceBack2, self ) end

	end

	if ( ( isTrace1Hit or isTrace2Hit ) && self.SoundHit ) then
		self.SoundHit:ChangeVolume( math.Rand( 0.1, 0.1 ), 0 )
	elseif ( self.SoundHit ) then
		self.SoundHit:ChangeVolume( 0, 0 )
	end

	-- ------------------------------------------------- SOUNDS ------------------------------------------------- --

	-- Avoid these sounds when we first turn on the saber
	local soundMask = 1
	if ( self:GetBladeLength() < self:GetMaxLength() ) then soundMask = 0 end

	if ( self.SoundSwing ) then

		if ( self.LastAng != ang ) then
			self.LastAng = self.LastAng or ang

			self.SoundSwing:ChangeVolume( math.Clamp( ang:Distance( self.LastAng ) / 2, 0, soundMask ), 0 )
		end

		self.LastAng = ang
	end

	if ( self.SoundLoop ) then
		pos = pos + ang * self:GetBladeLength()

		if ( self.LastPos != pos ) then
			self.LastPos = self.LastPos or pos

			self.SoundLoop:ChangeVolume( 0.1 + math.Clamp( pos:Distance( self.LastPos ) / 128, 0, soundMask * 0.9 ), 0 )
		end
		self.LastPos = pos
	end
end

function SWEP:DrawHitEffects( trace, traceBack )
	if ( self:GetBladeLength() <= 0 ) then return end

	if ( trace.Hit ) then
		rb655_DrawHit( trace.HitPos, trace.HitNormal )
	end

	if ( traceBack && traceBack.Hit ) then
		rb655_DrawHit( traceBack.HitPos, traceBack.HitNormal )
	end
end

-- ------------------------------------------------------------- Fluid holdtype changes ----------------------------------------------------------------- --

local index = ACT_HL2MP_IDLE_KNIFE
local KnifeHoldType = {}
KnifeHoldType[ ACT_MP_STAND_IDLE ] = index
KnifeHoldType[ ACT_MP_WALK ] = index + 1
KnifeHoldType[ ACT_MP_RUN ] = index + 2
KnifeHoldType[ ACT_MP_CROUCH_IDLE ] = index + 3
KnifeHoldType[ ACT_MP_CROUCHWALK ] = index + 4
KnifeHoldType[ ACT_MP_ATTACK_STAND_PRIMARYFIRE ] = index + 5
KnifeHoldType[ ACT_MP_ATTACK_CROUCH_PRIMARYFIRE ] = index + 5
KnifeHoldType[ ACT_MP_RELOAD_STAND ] = index + 6
KnifeHoldType[ ACT_MP_RELOAD_CROUCH ] = index + 6
KnifeHoldType[ ACT_MP_JUMP ] = index + 7
KnifeHoldType[ ACT_RANGE_ATTACK1 ] = index + 8
KnifeHoldType[ ACT_MP_SWIM ] = index + 9

function SWEP:TranslateActivity( act )

	if ( self.Owner:IsNPC() ) then
		if ( self.ActivityTranslateAI[ act ] ) then return self.ActivityTranslateAI[ act ] end
		return -1
	end

	if ( self.Owner:Crouching() ) then
		local tr = util.TraceHull( {
			start = self.Owner:GetShootPos(),
			endpos = self.Owner:GetShootPos() + Vector( 0, 0, 20 ),
			mins = self.Owner:OBBMins(),
			maxs = self.Owner:OBBMaxs(),
			filter = self.Owner
		} )

		if ( self:GetEnabled() && tr.Hit && act == ACT_MP_ATTACK_CROUCH_PRIMARYFIRE ) then return ACT_HL2MP_IDLE_KNIFE + 5 end

		if ( ( !self:GetEnabled() && self:GetHoldType() == "normal" ) && self.Owner:Crouching() && act == ACT_MP_CROUCH_IDLE ) then return ACT_HL2MP_IDLE_KNIFE + 3 end
		if ( ( ( !self:GetEnabled() && self:GetHoldType() == "normal" ) or ( self:GetEnabled() && tr.Hit ) ) && act == ACT_MP_CROUCH_IDLE ) then return ACT_HL2MP_IDLE_KNIFE + 3 end
		if ( ( ( !self:GetEnabled() && self:GetHoldType() == "normal" ) or ( self:GetEnabled() && tr.Hit ) ) && act == ACT_MP_CROUCHWALK ) then return ACT_HL2MP_IDLE_KNIFE + 4 end

	end

	if ( self.Owner:WaterLevel() > 1 && self:GetEnabled() ) then
		return KnifeHoldType[ act ]
	end

	if ( self.ActivityTranslate[ act ] != nil ) then return self.ActivityTranslate[ act ]end
	return -1
end

-- ------------------------------------------------------------- Clientside stuff ----------------------------------------------------------------- --

if ( SERVER ) then return end

killicon.Add( "weapon_lightsaber", "lightsaber/lightsaber_killicon", color_white )

local WepSelectIcon = Material( "lightsaber/selection.png" )
local Size = 96

function SWEP:DrawWeaponSelection( x, y, w, h, a )
	surface.SetDrawColor( 255, 255, 255, a )
	surface.SetMaterial( WepSelectIcon )

	render.PushFilterMag( TEXFILTER.ANISOTROPIC )
	render.PushFilterMin( TEXFILTER.ANISOTROPIC )

	surface.DrawTexturedRect( x + ( ( w - Size ) / 2 ), y + ( ( h - Size ) / 2.5 ), Size, Size )

	render.PopFilterMag()
	render.PopFilterMin()
end

function SWEP:DrawWorldModel()
	self:DrawWorldModelTranslucent()
end

function SWEP:DrawWorldModelTranslucent()
	self.WorldModel = self:GetWorldModel()
	self:SetModel( self:GetWorldModel() )

	self:DrawModel()
	if ( !IsValid( self:GetOwner() ) or halo.RenderedEntity() == self ) then return end

	local clr = self:GetCrystalColor()
	clr = Color( clr.x, clr.y, clr.z )

	local bladesFound = false -- true if the model is OLD and does not have blade attachments
	local blades = 0
	for id, t in pairs( self:GetAttachments() or {} ) do
		if ( !string.match( t.name, "blade(%d+)" ) && !string.match( t.name, "quillon(%d+)" ) ) then continue end

		local bladeNum = string.match( t.name, "blade(%d+)" )
		local quillonNum = string.match( t.name, "quillon(%d+)" )

		if ( bladeNum && self:LookupAttachment( "blade" .. bladeNum ) > 0 ) then
			blades = blades + 1
			local pos, dir = self:GetSaberPosAng( bladeNum )
			rb655_RenderBlade( pos, dir, self:GetBladeLength(), self:GetMaxLength(), self:GetBladeWidth(), clr, self:GetDarkInner(), self:EntIndex(), self:GetOwner():WaterLevel() > 2, false, blades )
			bladesFound = true
		end

		if ( quillonNum && self:LookupAttachment( "quillon" .. quillonNum ) > 0 ) then
			blades = blades + 1
			local pos, dir = self:GetSaberPosAng( quillonNum, true )
			rb655_RenderBlade( pos, dir, self:GetBladeLength(), self:GetMaxLength(), self:GetBladeWidth(), clr, self:GetDarkInner(), self:EntIndex(), self:GetOwner():WaterLevel() > 2, true, blades )
		end

	end

	if ( !bladesFound ) then
		local pos, dir = self:GetSaberPosAng()
		rb655_RenderBlade( pos, dir, self:GetBladeLength(), self:GetMaxLength(), self:GetBladeWidth(), clr, self:GetDarkInner(), self:EntIndex(), self:GetOwner():WaterLevel() > 2 )
	end
end

-- --------------------------------------------------------- 3rd Person Camera --------------------------------------------------------- --

--[[
hook.Add( "ShouldDrawLocalPlayer", "rb655_lightsaber_weapon_draw", function()
	if ( IsValid( LocalPlayer() ) && LocalPlayer().GetActiveWeapon && IsValid( LocalPlayer():GetActiveWeapon() ) && rb655_IsLightsaber( LocalPlayer():GetActiveWeapon() ) && !LocalPlayer():InVehicle() && LocalPlayer():Alive() && LocalPlayer():GetViewEntity() == LocalPlayer() ) then return true end
end )

function SWEP:CalcView( ply, pos, ang, fov )
	if ( !IsValid( ply ) or !ply:Alive() or ply:InVehicle() or ply:GetViewEntity() != ply ) then return end

	local trace = util.TraceHull( {
		start = pos,
		endpos = pos - ang:Forward() * 100,
		filter = { ply:GetActiveWeapon(), ply },
		mins = Vector( -4, -4, -4 ),
		maxs = Vector( 4, 4, 4 ),
	} )

	if ( trace.Hit ) then pos = trace.HitPos else pos = pos - ang:Forward() * 100 end

	return pos, ang, fov
end]]

local isCalcViewFuckedUp2 = true
hook.Add( "CalcView", "111!!!_rb655_lightsaber_3rdperson", function( ply, pos, ang )
	if ( !IsValid( ply ) or !ply:Alive() or ply:InVehicle() or ply:GetViewEntity() != ply ) then return end
	if ( !LocalPlayer().GetActiveWeapon or !IsValid( LocalPlayer():GetActiveWeapon() ) or !rb655_IsLightsaber( LocalPlayer():GetActiveWeapon() ) ) then return end

	isCalcViewFuckedUp2 = false

	local trace = util.TraceHull( {
		start = pos,
		endpos = pos - ang:Forward() * 100,
		filter = { ply:GetActiveWeapon(), ply },
		mins = Vector( -4, -4, -4 ),
		maxs = Vector( 4, 4, 4 ),
	} )

	if ( trace.Hit ) then pos = trace.HitPos else pos = pos - ang:Forward() * 100 end

	return {
		origin = pos,
		angles = ang,
		drawviewer = true
	}
end )

-- --------------------------------------------------------- HUD --------------------------------------------------------- --

surface.CreateFont( "SelectedForceType", {
	font	= "Roboto Cn",
	size	= ScreenScale( 16 ),
	weight	= 600
} )

surface.CreateFont( "SelectedForceHUD", {
	font	= "Roboto Cn",
	size	= ScreenScale( 6 )
} )

local ForceSelectEnabled = false
hook.Add( "PlayerBindPress", "rb655_sabers_force", function( ply, bind, pressed )
	if ( LocalPlayer():InVehicle() or ply != LocalPlayer() or !LocalPlayer():Alive() or !IsValid( LocalPlayer():GetActiveWeapon() ) or !rb655_IsLightsaber( LocalPlayer():GetActiveWeapon() ) ) then ForceSelectEnabled = false return end

	local ret = hook.Run( "LightsaberPlayerBindPress", ply, bind, pressed )
	if ( ret != nil ) then ForceSelectEnabled = false return end

	if ( bind == "impulse 100" && pressed ) then
		ForceSelectEnabled = !ForceSelectEnabled
		return true
	end

	if ( !ForceSelectEnabled ) then return end

	if ( bind:StartWith( "slot" ) ) then
		RunConsoleCommand( "rb655_select_force", bind:sub( 5 ) )
		return true
	end

	if ( bind == "invprev" && pressed ) then
		RunConsoleCommand( "rb655_select_next", "-1" )
		return true
	end
	if ( bind == "invnext" && pressed ) then
		RunConsoleCommand( "rb655_select_next", "1" )
		return true
	end
end )

local rb655_lightsaber_hud_blur = CreateClientConVar( "rb655_lightsaber_hud_blur", "0" )

local grad = Material( "gui/gradient_up" )
local matBlurScreen = Material( "pp/blurscreen" )
matBlurScreen:SetFloat( "$blur", 3 )
matBlurScreen:Recompute()
local function DrawHUDBox( x, y, w, h, b )

	x = math.floor( x )
	y = math.floor( y )
	w = math.floor( w )
	h = math.floor( h )

	surface.SetMaterial( matBlurScreen )
	surface.SetDrawColor( 255, 255, 255, 255 )

	if ( rb655_lightsaber_hud_blur:GetBool() ) then
		render.SetScissorRect( x, y, w + x, h + y, true )
			for i = 0.33, 1, 0.33 do
				matBlurScreen:SetFloat( "$blur", 5 * i )
				matBlurScreen:Recompute()
				render.UpdateScreenEffectTexture()
				surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )
			end
		render.SetScissorRect( 0, 0, 0, 0, false )
	else
		draw.NoTexture()
		surface.SetDrawColor( Color( 0, 0, 0, 128 ) )
		surface.DrawTexturedRect( x, y, w, h )
	end

	surface.SetDrawColor( Color( 0, 0, 0, 128 ) )
	surface.DrawRect( x, y, w, h )

	if ( b ) then
		surface.SetMaterial( grad )
		surface.SetDrawColor( Color( 0, 128, 255, 4 ) )
		surface.DrawTexturedRect( x, y, w, h )
	end

end

local isCalcViewFuckedUp = true
function SWEP:ViewModelDrawn()
	isCalcViewFuckedUp = true -- Clever girl!
end

function SWEP:DrawHUDTargetSelection()
	local selectedForcePower = self:GetActiveForcePowerType( self:GetForceType() )
	if ( !selectedForcePower ) then return end

	local isTarget = selectedForcePower.target
	if ( isTarget ) then
		for id, ent in pairs( self:SelectTargets( isTarget ) ) do
			if ( !IsValid( ent ) ) then continue end
			local maxs = ent:OBBMaxs()
			local p = ent:GetPos()
			p.z = p.z + maxs.z

			local pos = p:ToScreen()
			local x, y = pos.x, pos.y
			local size = 16

			surface.SetDrawColor( 255, 0, 0, 255 )
			draw.NoTexture()
			surface.DrawPoly( {
				{ x = x - size, y = y - size },
				{ x = x + size, y = y - size },
				{ x = x, y = y }
			} )
		end
	end
end

local patched = {}
local function patchCalcViewHook( str )
	if ( !isstring( str ) || patched[ str ] || str == "111!!!_rb655_lightsaber_3rdperson" ) then return end
	patched[ str ] = true

	local originalFunc = hook.GetTable()[ "CalcView" ][ str ]

	hook.Add( "CalcView", str, function( ply, ... )
		local ls = rb655_GetLightsaber( ply )
		if ( IsValid( ply ) && IsValid( ls ) && ply:GetActiveWeapon() == ls ) then
			return
		end
		return originalFunc( ply, ... )
	end )
end

function SWEP:DrawHUD_FuckedUpHooks( y )
	if ( ForceSelectEnabled ) then return end

	local x = ScrW() / 2
	local gap = 5

	----------------------------------- PlayerBindPress ERROR

	local isGood = hook.Call( "PlayerBindPress", nil, LocalPlayer(), "this_bind_doesnt_exist", true )
	if ( isGood == true ) then
		local txt = "Some addon is breaking the PlayerBindPress hook!"
		for name, func in pairs( hook.GetTable()[ "PlayerBindPress" ] ) do txt = txt .. "\n" .. tostring( name ) end
		local tW, tH = surface.GetTextSize( txt )

		y = y - tH - gap

		local id = 1
		DrawHUDBox( x - tW / 2 - 5, y, tW + 10, tH )
		draw.SimpleText( string.Explode( "\n", txt )[ 1 ], "SelectedForceHUD", x, y + 0, Color( 255, 230, 230 ), 1 )

		for str, func in pairs( hook.GetTable()[ "PlayerBindPress" ] ) do
			local clr = Color( 255, 255, 128 )
			if ( ( isstring( str ) && func( LocalPlayer(), "this_bind_doesnt_exist", true ) == true ) or ( !isstring( str ) && func( str, LocalPlayer(), "this_bind_doesnt_exist", true ) == true ) ) then
				clr = Color( 255, 128, 128 )
			end
			if ( !isstring( str ) ) then str = tostring( str ) end
			if ( str == "" ) then str = "<empty string hook>" end
			local _, lineH = surface.GetTextSize( str )
			draw.SimpleText( str, "SelectedForceHUD", x, y + id * lineH, clr, 1 )
			id = id + 1
		end
	end

	----------------------------------- CalcView ERROR

	if ( isCalcViewFuckedUp or isCalcViewFuckedUp2 ) then
		local txt = "Some addon is breaking the CalcView hook! See the hook names in red."
		for name, func in pairs( hook.GetTable()[ "CalcView" ] ) do txt = txt .. "\n" .. tostring( name ) end
		local tW, tH = surface.GetTextSize( txt )

		y = y - tH - gap

		local id = 1
		DrawHUDBox( x - tW / 2 - 5, y, tW + 10, tH )
		draw.SimpleText( string.Explode( "\n", txt )[ 1 ], "SelectedForceHUD", x, y + 0, Color( 255, 230, 230 ), 1 )

		for str, func in pairs( hook.GetTable()[ "CalcView" ] ) do
			local clr = Color( 255, 255, 128 )
			if ( ( isstring( str ) && func( LocalPlayer(), EyePos(), EyeAngles(), 90, 4, 16000 ) != nil ) or ( !isstring( str ) && func( str, LocalPlayer(), EyePos(), EyeAngles(), 90, 4, 16000 ) != nil ) ) then
				clr = Color( 255, 128, 128 )

				-- Automatically patch the offender, this is BAD but what can I do about BAD addons?
				patchCalcViewHook( str )
			end
			if ( !isstring( str ) ) then str = tostring( str ) end
			if ( str == "" ) then str = "<empty string hook>" end
			local _, lineH = surface.GetTextSize( str )
			draw.SimpleText( str, "SelectedForceHUD", x, y + id * lineH, clr, 1 )
			id = id + 1
		end

		isCalcViewFuckedUp = false
	end

	if ( !isCalcViewFuckedUp2 ) then
		isCalcViewFuckedUp2 = true
	end

	----------------------------------- PLAYERMODEL ERROR

	if ( self:GetIncorrectPlayerModel() != 0 ) then
		local txt = "Server is missing the player model files!\nPlayer model: " .. self.Owner:GetModel()
		if ( self:GetIncorrectPlayerModel() == 2 ) then txt = "The weapon is somehow missing owner!\nPlayer model: " .. self.Owner:GetModel() end
		local tW, tH = surface.GetTextSize( txt )

		y = y - tH - gap

		DrawHUDBox( x - tW / 2 - 5, y, tW + 10, tH )
		for id, str in pairs( string.Explode( "\n", txt ) ) do
			local _, lineH = surface.GetTextSize( str )
			draw.SimpleText( str, "SelectedForceHUD", x, y + ( id - 1 ) * lineH, Color( 255, 200, 200 ), 1 )
		end
	end
end

local Color_White = Color( 255, 255, 255 )
local Color_BLU = Color( 0, 128, 255 )
local ForceBar = 100
local function DrawForceSelectionHUD( ForceSelectEnabled, Force, MaxForce, SelectedPower, ForcePowers )

	local icon = 52
	local gap = 5

	local bar = 4
	local bar2 = 16

	if ( ForceSelectEnabled ) then
		icon = 128
		bar = 8
		bar2 = 24
	end

	----------------------------------- Force Bar -----------------------------------

	ForceBar = math.min( MaxForce, Lerp( 0.1, ForceBar, math.floor( Force ) ) )

	local w = #ForcePowers * icon + ( #ForcePowers - 1 ) * gap
	local h = bar2
	local x = math.floor( ScrW() / 2 - w / 2 )
	local y = ScrH() - gap - bar2

	DrawHUDBox( x, y, w, h )

	local barW = math.ceil( w * ( ForceBar / MaxForce ) )
	if ( Force <= 1 && barW <= 1 ) then barW = 0 end
	draw.RoundedBox( 0, x, y, barW, h, Color_BLU )

	draw.SimpleText( math.floor( Force / MaxForce * 100 ) .. "%", "SelectedForceHUD", x + w / 2, y + h / 2, Color_White, 1, 1 )

	----------------------------------- Force Icons -----------------------------------

	local y = y - icon - gap
	local h = icon

	for id, t in pairs( ForcePowers ) do
		local x = x + ( id - 1 ) * ( h + gap )
		local x2 = math.floor( x + icon / 2 )

		DrawHUDBox( x, y, h, h, SelectedPower == id )

		if ( t.material ) then
			if ( isstring( t.material ) ) then t.material = Material( t.material ) end

			surface.SetMaterial( t.material )
			surface.SetDrawColor( Color_White )

			render.PushFilterMag( TEXFILTER.ANISOTROPIC )
			render.PushFilterMin( TEXFILTER.ANISOTROPIC )
				surface.DrawTexturedRect( x, y, h, h )
			render.PopFilterMag()
			render.PopFilterMin()
		end

		if ( t.icon ) then
			draw.SimpleText( t.icon or "", "SelectedForceType", x2, math.floor( y + icon / 2 ), Color_White, 1, 1 )
		end

		if ( ForceSelectEnabled ) then
			draw.SimpleText( ( input.LookupBinding( "slot" .. id ) or "<NOT BOUND>" ):upper(), "SelectedForceHUD", x + gap, y + gap, Color_White )
		end
		if ( SelectedPower == id ) then
			local y = y + ( icon - bar )
			surface.SetDrawColor( Color_BLU )
			draw.NoTexture()
			surface.DrawPoly( {
				{ x = x2 - bar, y = y },
				{ x = x2, y = y - bar },
				{ x = x2 + bar, y = y }
			} )

			surface.DrawRect( x, y, h, bar )
		end
	end

	----------------------------------- Force Title & Description -----------------------------------

	local selectedForcePower = ForcePowers[ SelectedPower ]

	if ( selectedForcePower && ForceSelectEnabled ) then

		-- Description

		surface.SetFont( "SelectedForceHUD" )
		local tW, tH = surface.GetTextSize( selectedForcePower.description or "" )

		--[[local x = x + w + gap
		local y = y]]
		local x2 = ScrW() / 2 + gap / 2-- - tW / 2
		local y2 = y - tH - gap * 3

		DrawHUDBox( x2, y2, tW + gap * 2, tH + gap * 2 )

		for id, txt in pairs( string.Explode( "\n", selectedForcePower.description or "" ) ) do
			draw.SimpleText( txt, "SelectedForceHUD", x2 + gap, y2 + ( id - 1 ) * ScreenScale( 6 ) + gap, Color_White )
		end

		-- Label

		surface.SetFont( "SelectedForceType" )
		local txt = selectedForcePower.name or ""
		local tW2, tH2 = surface.GetTextSize( txt )

		local x = x + w / 2 - tW2 - gap * 2.5 --+ w / 2
		local y = y + gap - tH2 - gap * 2

		DrawHUDBox( x, y, tW2 + 10, tH2 )
		draw.SimpleText( txt, "SelectedForceType", x + gap, y, Color( 255, 255, 255 ) )

	end

	----------------------------------- Press F to Select -----------------------------------

	if ( !ForceSelectEnabled ) then
		surface.SetFont( "SelectedForceHUD" )
		local txt = "Press " .. ( input.LookupBinding( "impulse 100" ) or "<NOT BOUND>" ):upper() .. " to toggle Force selection"
		local tW, tH = surface.GetTextSize( txt )

		local x = x + w / 2
		local y = y - tH - gap

		DrawHUDBox( x - tW / 2 - 5, y, tW + 10, tH )
		draw.SimpleText( txt, "SelectedForceHUD", x, y, Color_White, 1 )

	end

	return y

end

function SWEP:DrawHUD()
	if ( !IsValid( self.Owner ) or self.Owner:GetViewEntity() != self.Owner or self.Owner:InVehicle() ) then return end

	-----------------------------------

	local ForcePowers = self:GetActiveForcePowers()
	if ( #ForcePowers < 1 ) then self:DrawHUDTargetSelection() return end

	local y = ScrH()

	local ret = hook.Run( "LightsaberDrawHUD", ForceSelectEnabled, self:GetForce(), self:GetMaxForce(), self:GetForceType(), ForcePowers )
	if ( ret == nil ) then
		y = DrawForceSelectionHUD( ForceSelectEnabled, self:GetForce(), self:GetMaxForce(), self:GetForceType(), ForcePowers )
	elseif ( isnumber( ret ) ) then
		y = ret
	end

	self:DrawHUD_FuckedUpHooks( y )

	----------------------------------- Force Target -----------------------------------

	self:DrawHUDTargetSelection()

end
