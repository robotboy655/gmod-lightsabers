
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
	CreateConVar( "rb655_lightsaber_hiltonbelt", "1" )

	cvars.AddChangeCallback( "rb655_lightsaber_hiltonbelt", function( cvar, old, new )
		SetGlobalBool( "rb655_lightsaber_hiltonbelt", new != "0" )
	end, "rb655_lightsaber_hiltonbelt" )

	hook.Add( "PlayerInitialSpawn", "rb655_lightsaber_hiltonbelt", function()
		SetGlobalBool( "rb655_lightsaber_hiltonbelt", GetConVarNumber( "rb655_lightsaber_hiltonbelt" ) )
	end )

	return
end

-- --------------------------------------------------------- Fix the bad sounds and models --------------------------------------------------------- --

local tr = {
	["models/sgg/starwars/weapons/w_maul_saber_hilt.mdl"] = "models/weapons/starwars/w_maul_saber_staff_hilt.mdl",
	["models/sgg/starwars/weapons/w_maul_saberstaff_hilt.mdl"] = "models/weapons/starwars/w_maul_saber_staff_hilt.mdl",
	["models/sgg/starwars/weapons/w_dooku_saber_hilt.mdl"] = "models/weapons/starwars/w_dooku_saber_hilt.mdl",

	-- Sounds
	["lightsaber/darksaberloop.wav"] = "lightsaber/darksaber_loop.wav",
	["lightsaber/darksaberoff.wav"] = "lightsaber/darksaber_on.wav",
	["lightsaber/darksaberon.wav"] = "lightsaber/darksaber_off.wav",
	["lightsaber/darksaberswing.wav"] = "lightsaber/darksaber_swing.wav",

	["lightsaber/forceleap.wav"] = "lightsaber/force_leap.wav",
	["lightsaber/forcerepulse.wav"] = "lightsaber/force_repulse.wav",
	["lightsaber/forcelightning1.wav"] = "lightsaber/force_lightning1.wav", -- Pretty sure these two shouldn't be here, but just in case
	["lightsaber/forcelightning2.wav"] = "lightsaber/force_lightning2.wav",

	["lightsaber/saberhit.wav"] = "lightsaber/saber_hit.wav",
	["lightsaber/saberhitlaser1.wav"] = "lightsaber/saber_hit_laser1.wav",
	["lightsaber/saberhitlaser2.wav"] = "lightsaber/saber_hit_laser2.wav",
	["lightsaber/saberhitlaser3.wav"] = "lightsaber/saber_hit_laser3.wav",
	["lightsaber/saberhitlaser4.wav"] = "lightsaber/saber_hit_laser4.wav",
	["lightsaber/saberhitlaser5.wav"] = "lightsaber/saber_hit_laser5.wav",

	["lightsaber/saberswing1.wav"] = "lightsaber/saber_swing1.wav",
	["lightsaber/saberswing2.wav"] = "lightsaber/saber_swing2.wav",

	["lightsaber/saberloop1.wav"] = "lightsaber/saber_loop1.wav",
	["lightsaber/saberloop2.wav"] = "lightsaber/saber_loop2.wav",
	["lightsaber/saberloop3.wav"] = "lightsaber/saber_loop3.wav",
	["lightsaber/saberloop4.wav"] = "lightsaber/saber_loop4.wav",
	["lightsaber/saberloop5.wav"] = "lightsaber/saber_loop5.wav",
	["lightsaber/saberloop6.wav"] = "lightsaber/saber_loop6.wav",
	["lightsaber/saberloop7.wav"] = "lightsaber/saber_loop7.wav",
	["lightsaber/saberloop8.wav"] = "lightsaber/saber_loop8.wav",

	["lightsaber/saberon1.wav"] = "lightsaber/saber_on1.wav",
	["lightsaber/saberon1_fast.wav"] = "lightsaber/saber_on1_fast.wav",
	["lightsaber/saberoff1.wav"] = "lightsaber/saber_off1.wav",
	["lightsaber/saberoff1_fast.wav"] = "lightsaber/saber_off1_fast.wav",
	["lightsaber/saberon2.wav"] = "lightsaber/saber_on2.wav",
	["lightsaber/saberon2_fast.wav"] = "lightsaber/saber_on2_fast.wav",
	["lightsaber/saberoff2.wav"] = "lightsaber/saber_off2.wav",
	["lightsaber/saberoff2_fast.wav"] = "lightsaber/saber_off2_fast.wav",
	["lightsaber/saberon3.wav"] = "lightsaber/saber_on3.wav",
	["lightsaber/saberon3_fast.wav"] = "lightsaber/saber_on3_fast.wav",
	["lightsaber/saberoff3.wav"] = "lightsaber/saber_off3.wav",
	["lightsaber/saberoff3_fast.wav"] = "lightsaber/saber_off3_fast.wav",
	["lightsaber/saberon4.wav"] = "lightsaber/saber_on4.wav",
	["lightsaber/saberon4_fast.wav"] = "lightsaber/saber_on4_fast.wav",
	["lightsaber/saberoff4.wav"] = "lightsaber/saber_off4.wav",
	["lightsaber/saberoff4_fast.wav"] = "lightsaber/saber_off4_fast.wav",

	["lightsaber/saberon4.mp3"] = "lightsaber/saber_on4.wav",
	["lightsaber/saberoff4.mp3"] = "lightsaber/saber_off4.wav",
}

local convars = {
	"rb655_lightsaber_model",

	"rb655_lightsaber_humsound",
	"rb655_lightsaber_swingsound",
	"rb655_lightsaber_onsound",
	"rb655_lightsaber_offsound",
}

hook.Add( "Initialize", "rb655_fix_convars", function()
	if ( !GetConVar( "rb655_lightsaber_model" ) ) then return end

	for id, cvar in pairs( convars ) do
		if ( tr[ GetConVar( cvar ):GetString():lower() ] ) then
			RunConsoleCommand( cvar, tr[ GetConVar( cvar ):GetString():lower() ] )
			print( "Fixing convar value for " .. cvar .. "!" )
		end
	end
end )

-- --------------------------------------------------------- Hilt On a Belt --------------------------------------------------------- --

hook.Add( "PostPlayerDraw", "rb655_lightsaber", function( ply )
	if ( !GetGlobalBool( "rb655_lightsaber_hiltonbelt", false ) --[[or !ply:HasWeapon( "weapon_lightsaber" )]] ) then return end

	local wep = rb655_GetLightsaber( ply ) --ply:GetWeapon( "weapon_lightsaber" )
	if ( !IsValid( wep ) or wep == ply:GetActiveWeapon() ) then return end

	if ( !IsValid( ply.LightsaberMDL ) ) then
		ply.LightsaberMDL = ClientsideModel( wep.WorldModel, RENDERGROUP_BOTH )
	end
	if ( !IsValid( ply.LightsaberMDL ) ) then return end -- We are still invalid, bail

	ply.LightsaberMDL:SetNoDraw( true )
	ply.LightsaberMDL:SetModel( wep.WorldModel )

	local pos, ang = ply:GetBonePosition( 0 )
	ang:RotateAroundAxis( ang:Up(), 80 )

	local len = ply:GetVelocity():Length()
	if ( ply:GetVelocity():Distance( ply:GetForward() * len ) < ply:GetVelocity():Distance( ply:GetForward() * -len ) ) then
		ang:RotateAroundAxis( ang:Right(), math.min( ply:GetVelocity():Length() / 8, 55 ) - 5 ) -- Forward
	else
		ang:RotateAroundAxis( ang:Right(), -math.min( ply:GetVelocity():Length() / 8, 55 ) + 5 )
	end

	if ( ply:GetVelocity():Distance( ply:GetRight() * len ) < ply:GetVelocity():Distance( ply:GetRight() * -len ) ) then
		--ang:RotateAroundAxis( ang:Right(), math.min( ply:GetVelocity():Length() / 8, 55 ) - 5 ) -- Right
	else
		ang:RotateAroundAxis( ang:Up(), -math.min( ply:GetVelocity():Length() / 16, 30 ) + 5 )
	end

	pos = pos - ang:Right() * 8 - ang:Forward() * 8
	if ( wep.WorldModel == "models/weapons/starwars/w_maul_saber_staff_hilt.mdl" ) then
		pos = pos - ang:Forward() * 5
	end
	if ( wep.WorldModel == "models/weapons/starwars/w_kr_hilt.mdl" ) then
		pos = pos + ang:Forward() * 5
	end

	ang:RotateAroundAxis( ang:Forward(), 90 )

	ply.LightsaberMDL:SetPos( pos )
	ply.LightsaberMDL:SetAngles( ang )

	ply.LightsaberMDL:DrawModel()

end )

-- --------------------------------------------------------- Lightsaber blade rendering --------------------------------------------------------- --

local HardLaser = Material( "lightsaber/hard_light" )
local HardLaserInner = Material( "lightsaber/hard_light_inner" )

local HardLaserTrail = Material( "lightsaber/hard_light_trail" )
local HardLaserTrailInner = Material( "lightsaber/hard_light_trail_inner" )

local HardLaserTrailEnd = Material( "lightsaber/hard_light_trail_end" )
local HardLaserTrailEndInner = Material( "lightsaber/hard_light_trail_end_inner" )

--[[local HardLaserTrailEnd = Material( "lightsaber/hard_light_trail" )
local HardLaserTrailEndInner = Material( "lightsaber/hard_light_trail_inner" )]]

local gOldBladePositions = {}
local gTrailLength = 1

function rb655_RenderBlade( pos, dir, length, maxlen, width, color, black_inner, eid, underwater, quillon, bladeNum )
	--render.DrawLine( pos + dir * length*-2, pos + dir * length*2, color, true )

	quillon = quillon or false
	bladeNum = bladeNum or 1

	if ( quillon ) then
		length = rb655_CalculateQuillonLength( length, maxlen )
		maxlen = rb655_CalculateQuillonMaxLength( maxlen )
		width = rb655_CalculateQuillonWidth( width )
	end

	if ( length <= 0 ) then rb655_SaberClean( eid, bladeNum ) return end

	if ( underwater ) then
		local ed = EffectData()
		ed:SetOrigin( pos )
		ed:SetNormal( dir )
		ed:SetRadius( length )
		util.Effect( "rb655_saber_underwater", ed )
	end

	local inner_color = color_white
	if ( black_inner ) then inner_color = Color( 0, 0, 0 ) end

	local bladeS = 1
	if ( quillon ) then
		bladeS = 0.25
	end

	render.SetMaterial( HardLaser )
	render.DrawBeam( pos, pos + dir * ( length * 1.01 ), width * 1.6, bladeS, 0.01, color )

	render.SetMaterial( HardLaserInner )
	render.DrawBeam( pos, pos + dir * length, width * 1, bladeS, 0.01, inner_color )

	-- Dynamic light
	if ( !quillon ) then
		local SaberLight = DynamicLight( eid + 1000 * bladeNum )
		if ( SaberLight ) then
			SaberLight.Pos = pos + dir * ( length / 2 )
			SaberLight.r = color.r
			SaberLight.g = color.g
			SaberLight.b = color.b
			SaberLight.Brightness = 0.6
			SaberLight.Size = 176 * ( length / maxlen )
			SaberLight.Decay = 0
			SaberLight.DieTime = CurTime() + 0.1
		end
	end

	if ( quillon ) then
		length = length * 0.93
	end

	local prevB = pos
	local prevT = pos + dir * length

	if ( !gOldBladePositions[ eid ] ) then gOldBladePositions[ eid ] = {} end
	if ( !gOldBladePositions[ eid ][ bladeNum ] ) then gOldBladePositions[ eid ][ bladeNum ] = {} end

	for id, prevpos in ipairs( gOldBladePositions[ eid ][ bladeNum ] ) do
		local posB = prevpos.pos
		local posT = prevpos.pos + prevpos.dir * prevpos.len
		--local posB = prevB
		--local posT = prevB + prevpos.dir * prevpos.len

		if ( id == gTrailLength ) then
			HardLaserTrailEnd:SetVector( "$color", Vector( color.r / 255, color.g / 255, color.b / 255 ) )
			render.SetMaterial( HardLaserTrailEnd )
		else
			HardLaserTrail:SetVector( "$color", Vector( color.r / 255, color.g / 255, color.b / 255 ) )
			render.SetMaterial( HardLaserTrail )
		end
		render.DrawQuad( posB, prevB, prevT, posT )

		if ( id == gTrailLength ) then
			HardLaserTrailEndInner:SetVector( "$color", Vector( inner_color.r / 255, inner_color.g / 255, inner_color.b / 255 ) )
			render.SetMaterial( HardLaserTrailEndInner )
		else
			HardLaserTrailInner:SetVector( "$color", Vector( inner_color.r / 255, inner_color.g / 255, inner_color.b / 255 ) )
			render.SetMaterial( HardLaserTrailInner )
		end
		render.DrawQuad( posB, prevB, prevT, posT )

		prevB = prevpos.pos
		prevT = prevpos.pos + prevpos.dir * prevpos.len
		--prevT = prevB + prevpos.dir * prevpos.len
	end
end

function rb655_SaberClean( eid, bladeNum )
	if ( !bladeNum ) then gOldBladePositions[ eid ] = nil return end
	if ( gOldBladePositions[ eid ] ) then
		gOldBladePositions[ eid ][ bladeNum ] = nil
	end
end

-- Extremely ugly hack workaround :(
function rb655_ProcessBlade( eid, pos, dir, len, bladeNum, quillon )
	if ( !gOldBladePositions[ eid ] ) then gOldBladePositions[ eid ] = {} end
	if ( !gOldBladePositions[ eid ][ bladeNum ] ) then gOldBladePositions[ eid ][ bladeNum ] = {} end

	if ( quillon ) then len = len * 0.93 end
	local hax = gOldBladePositions[ eid ][ bladeNum ]
	for i = 0, gTrailLength - 1 do
		hax[ gTrailLength - i ] = hax[ gTrailLength - i - 1 ]
		if ( gTrailLength - i == 1 ) then
			hax[ 1 ] = { dir = dir, len = len, pos = pos }
		end
	end
end

function rb655_CalculateQuillonMaxLength( maxLength )
	return maxLength / 6
end

function rb655_CalculateQuillonWidth( width )
	return width * 0.8
end

function rb655_CalculateQuillonLength( length, maxLength )
	local qlen = rb655_CalculateQuillonMaxLength( length )
	local maxLen = rb655_CalculateQuillonMaxLength( maxLength )
	return math.Clamp( maxLen - ( maxLength - length ), 0, qlen )
end

function rb655_ProcessLightsaberEntity( ent )
	local bladesFound = false -- true if the model is OLD and does not have blade attachments
	local blades = 0
	for id, t in pairs( ent:GetAttachments() or {} ) do -- TODO: Remove the {} part
		if ( !string.match( t.name, "blade(%d+)" ) && !string.match( t.name, "quillon(%d+)" ) ) then continue end

		local bladeNum = string.match( t.name, "blade(%d+)" )
		local quillonNum = string.match( t.name, "quillon(%d+)" )

		if ( bladeNum && ent:LookupAttachment( "blade" .. bladeNum ) > 0 ) then
			blades = blades + 1
			local pos, ang = ent:GetSaberPosAng( bladeNum )
			rb655_ProcessBlade( ent:EntIndex(), pos, ang, ent:GetBladeLength(), blades )

			bladesFound = true
		end

		if ( quillonNum && ent:LookupAttachment( "quillon" .. quillonNum ) > 0 ) then
			blades = blades + 1
			local pos, ang = ent:GetSaberPosAng( quillonNum, true )
			rb655_ProcessBlade( ent:EntIndex(), pos, ang, rb655_CalculateQuillonLength( ent:GetBladeLength(), ent:GetMaxLength() ), blades, true )
		end
	end

	if ( !bladesFound ) then
		local pos, ang = ent:GetSaberPosAng()
		rb655_ProcessBlade( ent:EntIndex(), pos, ang, ent:GetBladeLength(), 1 )
	end
end

hook.Add( "Think", "rb655_lightsaber_ugly_fixes", function()
	for id, ent in pairs( ents.FindByClass( "weapon_lightsaber*" ) ) do
		if ( !IsValid( ent:GetOwner() ) or ent:GetOwner():GetActiveWeapon() != ent or !ent.GetBladeLength or ent:GetBladeLength() <= 0 ) then continue end

		rb655_ProcessLightsaberEntity( ent )
	end

	for id, ent in pairs( ents.FindByClass( "ent_lightsaber*" ) ) do
		if ( !ent.GetBladeLength or ent:GetBladeLength() <= 0 ) then continue end

		rb655_ProcessLightsaberEntity( ent )
	end
end )
