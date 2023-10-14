
function EFFECT:Init( data )
	local pos = data:GetOrigin()
	local dir = data:GetNormal()
	local mattype = data:GetMaterialIndex()

	if ( mattype == MAT_GRATE ) then


		local effectdata = EffectData()
		effectdata:SetOrigin( pos )
		effectdata:SetNormal( dir )
		util.Effect( "StunstickImpact", effectdata, true, true )

		return
	end

	local emitter = ParticleEmitter( pos, true )
	if ( !emitter ) then return end

	local particle = emitter:Add( "decals/redglowfade", pos )
	if ( particle ) then
		particle:SetLifeTime( 0 )
		particle:SetDieTime( 1 )

		particle:SetStartSize( math.random( 20, 30 ) )
		particle:SetEndSize( 0 )

		particle:SetStartAlpha( math.random( 200, 255 ) )
		particle:SetEndAlpha( 0 )

		--particle:SetColor( 255, 255, 255 )
		particle:SetAngles( dir:Angle() )
	end

	emitter:Finish()

	if ( mattype == MAT_METAL ) then
		local effectdata = EffectData()
		effectdata:SetOrigin( pos )
		effectdata:SetNormal( dir )
		util.Effect( "StunstickImpact", effectdata, true, true )
	end
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end
