
local Cat = Material( "nyan/cat" )
local Rainbow = Material( "nyan/rainbow" )

function EFFECT:Init( data )

	self.StartPos = data:GetStart()
	self.Direction = data:GetOrigin()

	self.Dist = math.random( 32, 64 )
	self.EndPos = self.StartPos + self.Direction * self.Dist
	self:SetRenderBoundsWS( self.StartPos, self.EndPos )

	self.LifeTime = 1
	self.DieTime = CurTime() + self.LifeTime

end

function EFFECT:Think()

	if ( CurTime() > self.DieTime ) then return false end
	return true

end

function EFFECT:Render()

	local v1 = ( CurTime() - self.DieTime ) / self.LifeTime
	local v2 = ( self.DieTime - CurTime() ) / self.LifeTime
	local a = self.EndPos + self.Direction * math.min( v1 * self.Dist, 0 )

	render.SetMaterial( Rainbow )
	render.DrawBeam( self.StartPos, a, v2 * 6, 0, self.StartPos:Distance( self.EndPos ) / 10, Color( 255, 255, 255, v2 * 255 ) )
	render.SetMaterial( Cat )
	render.DrawBeam( a + self.Direction * 8, a + self.Direction * -8, 16, 0, 1, Color( 255, 255, 255, math.min( ( v2 * 3 ) * 200, 255 ) ) )

end
