
function EFFECT:Init( data )
	local pos = data:GetOrigin()
	local dir = data:GetNormal()
	local len = data:GetRadius()
	local emitter = ParticleEmitter( pos )

	local number_lol = 4

	if ( !emitter ) then return end

	for i = 0, len / number_lol do
		local pos2 = pos + dir * ( len - i * number_lol )
		local particle = emitter:Add( "effects/bubble", pos2 + Vector( math.random( -number_lol / 2, number_lol / 2 ), math.random( -number_lol / 2, number_lol / 2 ), math.random( -number_lol / 2, number_lol / 2 ) ) )
		if ( particle ) then
			particle:SetLifeTime( 0 )
			particle:SetDieTime( 0.3 )

			particle:SetGravity( Vector( 0, 0, math.random( 32, 128 ) ) )
			particle:SetVelocity( Vector( math.random( -8, 8 ), math.random( -8, 8 ), math.random( -8, 8 ) ) )

			particle:SetStartSize( math.random( 1, 4 ) )
			particle:SetEndSize( math.random( 1, 4 ) )

			particle:SetStartAlpha( math.random( 100, 200 ) )
			particle:SetEndAlpha( 0 )

			particle:SetColor( 255, 255, 255 )
			particle:SetAngleVelocity( Angle( math.Rand( -180, 180 ), math.Rand( -180, 180 ), math.Rand( -180, 180 ) ) )
			//particle:SetLighting( true )
		end
	end

	emitter:Finish()
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end
