
local function GetRandomPositionInBox( mins, maxs, ang )
	return ang:Up() * math.random( mins.z, maxs.z ) + ang:Right() * math.random( mins.y, maxs.y ) + ang:Forward() * math.random( mins.x, maxs.x )
end

local function GenerateLighting( from, to, deviations, power )
	local start = from
	if ( isentity( start ) ) then start = from:GetPos() end
	local endpos = to:GetPos()

	--render.DrawWireframeBox( start, Angle(0, 0, 0),from:OBBMins(), from:OBBMaxs(), Color(255, 0, 0), true )
	--render.DrawWireframeBox( start, to:GetAngles(),from:OBBMins(), from:OBBMaxs(), Color(0, 255, 0), true )

	--start = start + GetRandomPositionInBox( from:OBBMins(), from:OBBMaxs(), from:GetAngles() )
	endpos = endpos + GetRandomPositionInBox( to:OBBMins(), to:OBBMaxs(), to:GetAngles() )

	local right = (start - endpos):Angle():Right()
	local up = (start - endpos):Angle():Up()
	local segments = {
		{ start, endpos }
	}
	for i = 0, power do
		local newsegs = {}
		for id, seg in pairs( segments ) do
			local mid = Vector( (seg[1].x + seg[2].x) / 2, (seg[1].y + seg[2].y) / 2, (seg[1].z + seg[2].z) / 2 )
			local offsetpos = mid + right * math.random( -deviations, deviations ) + up * math.random( -deviations, deviations )
			table.insert( newsegs, {seg[1], offsetpos} )
			table.insert( newsegs, {offsetpos, seg[2]} )
		end
		segments = newsegs
	end
	return segments
end

local function GenerateLightingSegs( from, to, deviations, segs )
	local start = from
	if ( isentity( start ) ) then start = from:GetPos() end
	local endpos = to:GetPos()

	--render.DrawWireframeBox( start, Angle(0, 0, 0),from:OBBMins(), from:OBBMaxs(), Color(255, 0, 0), true )
	--render.DrawWireframeBox( start, to:GetAngles(),from:OBBMins(), from:OBBMaxs(), Color(0, 255, 0), true )

	--start = start + GetRandomPositionInBox( from:OBBMins(), from:OBBMaxs(), from:GetAngles() )
	endpos = endpos + GetRandomPositionInBox( to:OBBMins(), to:OBBMaxs(), to:GetAngles() )

	local right = (start - endpos):Angle():Right()
	local up = (start - endpos):Angle():Up()
	local fwd = (start - endpos):Angle():Forward()
	local step = (1 / segs) * start:Distance( endpos )

	local lastpos = start
	local segments = {}
	for i = 1, segs do
		local a = lastpos - fwd * step
		table.insert( segments, { lastpos, a } )
		lastpos = a
	end

	for k, v in pairs( segments ) do
		if ( k == 1 || k == #segments ) then continue end

		segments[ k ][ 1 ] = segments[ k ][ 1 ] + right * math.random( -deviations, deviations ) + up * math.random( -deviations, deviations )
		segments[ k - 1 ][ 2 ] = segments[ k ][ 1 ]
	end

	for k, v in pairs( segments ) do
		if ( k == 1 || k == #segments ) then continue end

		if ( math.random( 0, 100 ) > 75 ) then
			local dir = AngleRand():Forward()
			table.insert( segments, { segments[ k ][ 1 ], segments[ k ][ 1 ] + dir * ( step * math.Rand( 0.2, 0.6 ) ) } )
		end
	end

	return segments
end

local mats = {
	(Material( "cable/blue_elec" )),
	/*(Material( "cable/hydra" )),
	(Material( "cable/redlaser" )),
	(Material( "cable/crystal_beam1" )),
	(Material( "cable/physbeam" )),
	(Material( "cable/smoke" )),
	(Material( "cable/xbeam" )),*/
}

local segments = {}
--local n = 0
local tiem = .2
hook.Add( "PostDrawTranslucentRenderables", "", function()
	--if ( #segments < 1 || n < CurTime() ) then
		--
		/*for i = 0, 1 do
			table.insert( segments, {
				segs = GenerateLighting( table.Random( ents.FindByClass( "prop_physics" ) ), table.Random( ents.FindByClass( "prop_physics" ) ), math.random( 10, 20 ), 3 ),
				mat = table.Random( mats ),
				time = CurTime() + tiem,
				w = math.random( 20, 50 )
			} )
		end*/
		--n = CurTime() + .01
	--end

	for id, t in pairs( segments ) do
		if ( t.time < CurTime() ) then table.remove( segments, id ) continue end
		render.SetMaterial( t.mat )
		for id, seg in pairs( t.segs ) do
			render.DrawBeam( seg[1], seg[2], ( math.max( t.startpos:Distance( t.endpos ) - seg[1]:Distance( t.endpos ), 20) / ( t.startpos:Distance( t.endpos ) ) * t.w ) * ( (t.time - CurTime() ) / tiem ), 0, seg[1]:Distance( seg[2] ) / 25, Color( 255, 255, 255 ) )
			--render.DrawBeam( seg[1], seg[2], (id / #t.segs * t.w ) * ((t.time - CurTime()) / tiem), 0, seg[1]:Distance( seg[2] ) / 25, Color( 255, 255, 255 ) )
		end
	end
end )


function EFFECT:Init( data )
	local pos = data:GetOrigin()
	local ent = data:GetEntity()

	if ( !IsValid( ent ) ) then return end

	table.insert( segments, {
		--segs = GenerateLighting( pos, ent, math.random( 10, 20 ), 3 ),
		segs = GenerateLightingSegs( pos, ent, math.random( 10, 20 ), pos:Distance( ent:GetPos() ) / 48 ), --math.random( 5, 10 ) ),
		mat = table.Random( mats ),
		time = CurTime() + tiem,
		w = math.random( 20, 50 ),
		startpos = pos,
		endpos = ent:GetPos()
	} )
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
	/*for id, t in pairs( segments ) do
		if (t.time < CurTime() ) then table.remove( segments, id ) continue end
		render.SetMaterial( t.mat )
		for id, seg in pairs( t.segs ) do
			render.DrawBeam( seg[1], seg[2], (id / #t.segs * t.w ) * ((t.time - CurTime()) / tiem), 0, seg[1]:Distance( seg[2] ) / 25, Color( 255, 255, 255 ) )
		end
	end*/
end
