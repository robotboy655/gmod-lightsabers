
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

	local particle = emitter:Add( "effects/rb655_splash_warpring1", pos )
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

	/*local particle = emitter:Add( "effects/select_ring", pos )
	if ( particle ) then
		particle:SetLifeTime( 0 )
		particle:SetDieTime( .5 )

		particle:SetGravity( Vector( 0, 0, 0 ) )
		particle:SetVelocity( Vector( 0, 0, 0 ) )

		particle:SetStartSize( 0 )
		particle:SetEndSize( rad )--math.random( 1000, 2000 ) )

		particle:SetStartAlpha( 255 )
		particle:SetEndAlpha( 0 )

		particle:SetColor( 0, 255, 255 )
		--particle:SetAngleVelocity( Angle( math.Rand( -180, 180 ), math.Rand( -180, 180 ), math.Rand( -180, 180 ) ) )
	end*/

	emitter:Finish()
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end
