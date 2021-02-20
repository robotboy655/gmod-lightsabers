
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

ENT.Type = "anim"
ENT.Base = "base_anim"

ENT.PrintName = "Lightsaber"
ENT.Category = "Robotboy655's Entities"

ENT.Editable = true
ENT.Spawnable = true

ENT.RenderGroup = RENDERGROUP_BOTH
ENT.AutomaticFrameAdvance = true

ENT.IsLightsaber = true

-- --------------------------------------------------------- Initialization --------------------------------------------------------- --

function ENT:SetupDataTables()
	self:NetworkVar( "Float", 0, "LengthAnimation" )
	self:NetworkVar( "Float", 1, "BladeWidth", { KeyName = "BladeWidth", Edit = { type = "Float", category = "Blade", min = 2, max = 4, order = 1 } } )
	self:NetworkVar( "Float", 2, "MaxLength", { KeyName = "MaxLength", Edit = { type = "Float", category = "Blade", min = 32, max = 64, order = 2 } } )

	self:NetworkVar( "Bool", 0, "Enabled" )
	self:NetworkVar( "Bool", 1, "DarkInner", { KeyName = "DarkInner", Edit = { type = "Boolean", category = "Blade", order = 3 } } )
	self:NetworkVar( "Bool", 2, "WorksUnderwater" )

	self:NetworkVar( "Vector", 0, "CrystalColor", { KeyName = "CrystalColor", Edit = { type = "VectorColor", category = "Hilt", order = 4 } } )

	if ( SERVER ) then
		self:SetLengthAnimation( 0 )
		self:SetBladeWidth( 2 )
		self:SetMaxLength( 42 )

		self:SetDarkInner( false )
		self:SetEnabled( false )
		self:SetWorksUnderwater( true )

		self:NetworkVarNotify( "Enabled", self.OnEnabledOrDisabldd )
	end
end

function ENT:GetBladeLength()
	return self:GetLengthAnimation() * self:GetMaxLength()
end

function ENT:SetBladeLength( val )
	self:SetLengthAnimation( val / self:GetMaxLength() )
	MsgN( "Lightsaber.SetBladeLength is deprecated!" )
end

function ENT:Initialize()

	if ( SERVER ) then
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )

		self.LoopSound = self.LoopSound or "lightsaber/saber_loop" .. math.random( 1, 8 ) .. ".wav"
		self.SwingSound = self.SwingSound or "lightsaber/saber_swing" .. math.random( 1, 2 ) .. ".wav"
		self.OnSound = self.OnSound or "lightsaber/saber_on" .. math.random( 1, 2 ) .. ".wav"
		self.OffSound = self.OffSound or "lightsaber/saber_off" .. math.random( 1, 2 ) .. ".wav"

		--self:OnEnabled()
	else
		language.Add( self.ClassName, self.PrintName )
		killicon.AddAlias( "ent_lightsaber", "weapon_lightsaber" )
	end
end

-- --------------------------------------------------------- Enable / Disable --------------------------------------------------------- --

function ENT:OnEnabled()
	if ( CLIENT ) then return end
	if ( self:WaterLevel() > 2 && !self:GetWorksUnderwater() ) then return end

	if ( !self:GetEnabled() && self.OnSound ) then self:EmitSound( self.OnSound, nil, nil, 0.4 ) end

	self.SoundLoop = CreateSound( self, Sound( self.LoopSound ) )
	if ( self.SoundLoop ) then self.SoundLoop:Play() self.SoundLoop:ChangeVolume( 0, 0 ) end

	self.SoundSwing = CreateSound( self, Sound( self.SwingSound ) )
	if ( self.SoundSwing ) then self.SoundSwing:Play() self.SoundSwing:ChangeVolume( 0, 0 ) end

	self.SoundHit = CreateSound( self, Sound( self.HitSound || "lightsaber/saber_hit.wav" ) )
	if ( self.SoundHit ) then self.SoundHit:Play() self.SoundHit:ChangeVolume( 0, 0 ) end
end

function ENT:OnDisabled( bRemove )
	if ( CLIENT ) then
		if ( bRemove ) then rb655_SaberClean( self:EntIndex() ) end
		return
	end

	if ( self:GetEnabled() && self.OffSound ) then self:EmitSound( self.OffSound, nil, nil, 0.4 ) end

	if ( self.SoundLoop ) then self.SoundLoop:Stop() self.SoundLoop = nil end
	if ( self.SoundSwing ) then self.SoundSwing:Stop() self.SoundSwing = nil end
	if ( self.SoundHit ) then self.SoundHit:Stop() self.SoundHit = nil end
end

function ENT:OnEnabledOrDisabldd( name, old, new )

	if ( old == new ) then return end

	if ( new ) then
		self:OnEnabled()
	else
		self:OnDisabled()
	end
end

function ENT:OnRemove()
	self:OnDisabled( true )
end

-- --------------------------------------------------------- Misc --------------------------------------------------------- --

function ENT:GetSaberPosAng( num, side )
	num = num or 1

	local attachment = self:LookupAttachment( "blade" .. num )
	if ( side ) then
		attachment = self:LookupAttachment( "quillon" .. num )
	end

	if ( attachment > 0 ) then
		local PosAng = self:GetAttachment( attachment )

		return PosAng.Pos, PosAng.Ang:Forward()
	end

	return self:LocalToWorld( Vector( 1, -0.58, -0.25 ) ), -self:GetAngles():Forward()

end

function ENT:UpdateRenderBounds()

	local width = self:GetBladeWidth() / 1.5
	local mins, maxs = self:GetModelBounds()
	mins = Vector( -self:GetBladeLength(), -width, -width )
	maxs = Vector( maxs.x, width, width )

	self:SetRenderBounds( mins, maxs )

end

function ENT:Draw()

	self:UpdateRenderBounds()

	--render.SetColorModulation( 1, 1, 1 )
	self:DrawModel()

	if ( halo.RenderedEntity && IsValid( halo.RenderedEntity() ) && halo.RenderedEntity() == self ) then return end

	local clr = self:GetCrystalColor() * 255
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
			rb655_RenderBlade( pos, dir, self:GetBladeLength(), self:GetMaxLength(), self:GetBladeWidth(), clr, self:GetDarkInner(), self:EntIndex(), self:WaterLevel() > 2, false, blades )
			bladesFound = true
		end

		if ( quillonNum && self:LookupAttachment( "quillon" .. quillonNum ) > 0 ) then
			blades = blades + 1
			local pos, dir = self:GetSaberPosAng( quillonNum, true )
			rb655_RenderBlade( pos, dir, self:GetBladeLength(), self:GetMaxLength(), self:GetBladeWidth(), clr, self:GetDarkInner(), self:EntIndex(), self:WaterLevel() > 2, true, blades )
		end

	end

	if ( !bladesFound ) then
		local pos, dir = self:GetSaberPosAng()
		rb655_RenderBlade( pos, dir, self:GetBladeLength(), self:GetMaxLength(), self:GetBladeWidth(), clr, self:GetDarkInner(), self:EntIndex(), self:WaterLevel() > 2 )
	end

end

if ( CLIENT ) then return end

function ENT:PostEntityPaste()
	if ( !game.SinglePlayer() ) then
		self:SetMaxLength( math.Clamp( self:GetMaxLength(), 32, 64 ) )
		self:SetBladeWidth( math.Clamp( self:GetBladeWidth(), 2, 4 ) )
	end
end

function ENT:OnTakeDamage( dmginfo )

	-- React physically when shot/getting blown
	self:TakePhysicsDamage( dmginfo )

end

function ENT:Think()

	if ( !self:GetEnabled() && self:GetLengthAnimation() != 0 ) then
		self:SetLengthAnimation( math.Approach( self:GetLengthAnimation(), 0, FrameTime() * 3 ) )
	elseif ( self:GetEnabled() && self:GetLengthAnimation() != 1 ) then
		self:SetLengthAnimation( math.Approach( self:GetLengthAnimation(), 1, FrameTime() * 10 ) )
	end

	if ( self:GetEnabled() && !self:GetWorksUnderwater() && self:WaterLevel() > 2 ) then
		self:SetEnabled( false )
		--self:EmitSound( self.OffSound )
	end

	if ( self:GetBladeLength() <= 0 ) then
		if ( self.SoundSwing ) then self.SoundSwing:ChangeVolume( 0, 0 ) end
		if ( self.SoundLoop ) then self.SoundLoop:ChangeVolume( 0, 0 ) end
		if ( self.SoundHit ) then self.SoundHit:ChangeVolume( 0, 0 ) end
		return -- Disable for commented out code below?
	end

	local pos, ang = self:GetSaberPosAng()
	local hit = self:BladeThink( pos, ang )
	if ( self:LookupAttachment( "blade2" ) > 0 ) then
		local pos2, ang2 = self:GetSaberPosAng( 2 )
		local hit_2 = self:BladeThink( pos2, ang2 )
		hit = hit or hit_2
	end

	if ( self.SoundHit ) then
		if ( hit ) then self.SoundHit:ChangeVolume( math.Rand( 0.1, 0.5 ), 0 ) else self.SoundHit:ChangeVolume( 0, 0 ) end
	end

	if ( self.SoundSwing ) then
		--local ang = self:GetAngles()
		if ( self.LastAng != ang ) then
			self.LastAng = self.LastAng or ang
			self.SoundSwing:ChangeVolume( math.Clamp( ang:Distance( self.LastAng ) / 2, 0, 1 ), 0 )
			--self.SoundSwing:ChangeVolume( math.Rand( 0, 1 ), 0 ) -- For some reason if I spam always 1, the sound doesn't loop
			--self.SoundSwing:ChangeVolume( math.min( pos:Distance( self.LastPos ) / 16, 1 ), 0 )
		end
		self.LastAng = ang
	end

	--[[if ( self.SoundSwing ) then
		--local ang = self:GetAngles()
		local dist1 = pos:Distance( self.Owner:GetShootPos() ) 
		local dist2 = (pos+ ang * self:GetBladeLength()):Distance( self.Owner:GetShootPos() )
		local val = (dist1 - dist2) / self:GetBladeLength()
		print(val,CurTime())
		--if ( self.LastAng != ang ) then
			self.LastAng = self.LastAng or ang
			self.SoundSwing:ChangeVolume( math.Clamp( val, 0, 1 ), 0 )
			--self.SoundSwing:ChangeVolume( math.Clamp( ang:Distance( self.LastAng ) / 2, 0, 1 ), 0 )
			
			
			--self.SoundSwing:ChangeVolume( math.Rand( 0, 1 ), 0 ) -- For some reason if I spam always 1, the sound doesn't loop
			--self.SoundSwing:ChangeVolume( math.min( pos:Distance( self.LastPos ) / 16, 1 ), 0 )
		--end
		self.LastAng = ang
	end]]

	local s = 1
	if ( self:GetBladeLength() < self:GetMaxLength() ) then s = 0 end

	if ( self.SoundLoop ) then
		local pos = pos + ang * self:GetBladeLength()
		if ( self.LastPos != pos ) then
			self.LastPos = self.LastPos or pos
			self.SoundLoop:ChangeVolume( 0.1 + math.Clamp( pos:Distance( self.LastPos ) / 128, 0, s * 0.9 ), 0 )
			--self.SoundLoop:ChangeVolume( 0.1 + math.Clamp( pos:Distance( self.LastPos ) / 32, 0, 0.2 ), 0 )
			--self.SoundLoop:ChangeVolume( 1 - math.min( pos:Distance( self.LastPos ) / 16, 1 ), 0 )
			--self.SoundLoop:ChangeVolume( self:GetBladeLength() / self:GetMaxLength(), 0 )
		end
		self.LastPos = pos
	end

	self:NextThink( CurTime() )
	return true
end

function ENT:BladeThink( startpos, dir )
	local trace = util.TraceHull( {
		start = startpos,
		endpos = startpos + dir * self:GetBladeLength(),
		filter = self,
		--[[mins = Vector( -1, -1, -1 ) * self:GetBladeWidth() / 2,
		maxs = Vector( 1, 1, 1 ) * self:GetBladeWidth() / 2]]
	} )

	if ( trace.Hit ) then
		rb655_DrawHit( trace.HitPos, trace.HitNormal )
		rb655_LS_DoDamage( trace, self )
	end

	return trace.Hit
end

function ENT:Use( activator, caller, useType, value )
	if ( !IsValid( activator ) or !activator:KeyPressed( IN_USE ) ) then return end
	if ( self:WaterLevel() > 2 && !self:GetWorksUnderwater() ) then return end

	--[[if ( self:GetEnabled() ) then
		self:EmitSound( self.OffSound )
	else
		self:EmitSound( self.OnSound )
	end]]

	self:SetEnabled( !self:GetEnabled() )
end

function ENT:SpawnFunction( ply, tr )
	if ( !tr.Hit or !ply:CheckLimit( "ent_lightsabers" ) ) then return end

	local ent = ents.Create( ClassName )
	ent:SetPos( tr.HitPos + tr.HitNormal * 2 )

	local ang = ply:EyeAngles()
	ang.p = 0
	ang:RotateAroundAxis( ang:Right(), 180 )
	ent:SetAngles( ang )

	-- Sync values from the tool
	ent:SetMaxLength( math.Clamp( ply:GetInfoNum( "rb655_lightsaber_bladel", 42 ), 32, 64 ) )
	ent:SetCrystalColor( Vector( ply:GetInfo( "rb655_lightsaber_red" ), ply:GetInfo( "rb655_lightsaber_green" ), ply:GetInfo( "rb655_lightsaber_blue" ) ) / 255 )
	ent:SetDarkInner( ply:GetInfo( "rb655_lightsaber_dark" ) == "1" )
	ent:SetModel( ply:GetInfo( "rb655_lightsaber_model" ) )
	ent:SetBladeWidth( math.Clamp( ply:GetInfoNum( "rb655_lightsaber_bladew", 2 ), 2, 4 ) )

	ent.LoopSound = ply:GetInfo( "rb655_lightsaber_humsound" )
	ent.SwingSound = ply:GetInfo( "rb655_lightsaber_swingsound" )
	ent.OnSound = ply:GetInfo( "rb655_lightsaber_onsound" )
	ent.OffSound = ply:GetInfo( "rb655_lightsaber_offsound" )

	ent:Spawn()
	ent:Activate()

	-- Start enabled!
	ent:SetEnabled( true )

	ent.Owner = ply
	ent.Color = ent:GetColor()

	local phys = ent:GetPhysicsObject()
	if ( IsValid( phys ) ) then phys:Wake() end

	if ( IsValid( ply ) ) then
		ply:AddCount( "ent_lightsabers", ent )
		ply:AddCleanup( "ent_lightsabers", ent )
	end

	return ent
end
