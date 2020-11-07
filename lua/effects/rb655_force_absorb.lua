
function EFFECT:Init( data )
	local pos = data:GetOrigin()
	local emitter = ParticleEmitter( pos )

	if ( !emitter ) then return end

	local particle = emitter:Add( "hud/health_over_bg", pos + Vector( math.random( -16, 16 ), math.random( -16, 16 ), math.random( 0, 72 ) ) )
	if ( particle ) then
		particle:SetLifeTime( 0 )
		particle:SetDieTime( 2 )

		particle:SetGravity( Vector( 0, 0, 100 ) )
		particle:SetVelocity( Vector( 0, 0, 0 ) )

		particle:SetStartSize( math.random( 1, 5 ) )
		particle:SetEndSize( math.random( 0, 1 ) )

		particle:SetStartAlpha( math.random( 200, 255 ) )
		particle:SetEndAlpha( 0 )

		particle:SetColor( 255, 64, 64 )
		--particle:SetAngleVelocity( Angle( math.Rand( -180, 180 ), math.Rand( -180, 180 ), math.Rand( -180, 180 ) ) )
	end

	emitter:Finish()
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end
