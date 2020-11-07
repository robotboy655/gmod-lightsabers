
function EFFECT:Init( data )
	local pos = data:GetOrigin()
	--local rad = data:GetRadius()
	local emitter = ParticleEmitter( pos )

	if ( !emitter ) then return end

	local particle = emitter:Add( "effects/rb655_splash_warpring1", pos )
	if ( particle ) then
		particle:SetLifeTime( 0 )
		particle:SetDieTime( 0.5 )

		particle:SetGravity( Vector( 0, 0, 0 ) )
		particle:SetVelocity( Vector( 0, 0, 0 ) )

		particle:SetStartSize( 100 )
		particle:SetEndSize( 0 )

		particle:SetStartAlpha( 0 )
		particle:SetEndAlpha( 200 )

		particle:SetColor( 255, 255, 255 )
		--particle:SetAngleVelocity( Angle( math.Rand( -180, 180 ), math.Rand( -180, 180 ), math.Rand( -180, 180 ) ) )
	end

	--[[local particle = emitter:Add( "effects/select_ring", pos )
	if ( particle ) then
		particle:SetLifeTime( 0 )
		particle:SetDieTime( 0.3 )

		particle:SetGravity( Vector( 0, 0, 0 ) )
		particle:SetVelocity( Vector( 0, 0, 0 ) )

		particle:SetStartSize( math.random( 38, 42 ) )
		particle:SetEndSize( math.random( 48, 52 ) )

		particle:SetStartAlpha( 255 )
		particle:SetEndAlpha( 255 )

		particle:SetColor( 0, 255, 255 )
		--particle:SetAngleVelocity( Angle( math.Rand( -180, 180 ), math.Rand( -180, 180 ), math.Rand( -180, 180 ) ) )
	end]]

	emitter:Finish()
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end
