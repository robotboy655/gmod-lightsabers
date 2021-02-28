
function EFFECT:Init( data )
	local pos = data:GetOrigin()
	local rad = data:GetRadius()
	local emitter = ParticleEmitter( pos )

	if ( !emitter ) then return end

	local particle = emitter:Add( "effects/rb655_conc_warp", pos )
	if ( particle ) then
		particle:SetLifeTime( 0 )
		particle:SetDieTime( 0.25 * 5 )

		particle:SetGravity( Vector( 0, 0, 0 ) )
		particle:SetVelocity( Vector( 0, 0, 0 ) )

		particle:SetStartSize( 0 )
		particle:SetEndSize( rad * 2 ) --math.random( 1000, 2000 ) )

		particle:SetStartAlpha( math.random( 128, 200 ) )
		particle:SetEndAlpha( 0 )

		particle:SetColor( 255, 255, 255 )
	end

	local particle2 = emitter:Add( "effects/rb655_splash_warpring1", pos )
	if ( particle2 ) then
		particle2:SetLifeTime( 0 )
		particle2:SetDieTime( 0.25 * 5 )

		particle2:SetGravity( Vector( 0, 0, 0 ) )
		particle2:SetVelocity( Vector( 0, 0, 0 ) )

		particle2:SetStartSize( 0 )
		particle2:SetEndSize( rad * 2 ) --math.random( 1000, 2000 ) )

		particle2:SetStartAlpha( math.random( 128, 200 ) )
		particle2:SetEndAlpha( 0 )

		particle2:SetColor( 255, 255, 255 )
	end

	--[[local part3 = emitter:Add( "effects/select_ring", pos )
	if ( part3 ) then
		part3:SetLifeTime( 0 )
		part3:SetDieTime( .5 )

		part3:SetGravity( Vector( 0, 0, 0 ) )
		part3:SetVelocity( Vector( 0, 0, 0 ) )

		part3:SetStartSize( 0 )
		part3:SetEndSize( rad )--math.random( 1000, 2000 ) )

		part3:SetStartAlpha( 255 )
		part3:SetEndAlpha( 0 )

		part3:SetColor( 0, 255, 255 )
		--part3:SetAngleVelocity( Angle( math.Rand( -180, 180 ), math.Rand( -180, 180 ), math.Rand( -180, 180 ) ) )
	end]]

	emitter:Finish()
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end
