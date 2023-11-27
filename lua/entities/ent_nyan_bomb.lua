
AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.Spawnable = false

local nyan_cat = Material( "nyan/cat.png" )
local nyan_cat_rev = Material( "nyan/cat_reversed.png" )

function ENT:Draw()
	local vel = self:GetVelocity()
	if ( vel:Length() < 0.5 ) then vel = self:GetAngles():Forward() end

	vel:Normalize()

	local vz = vel:Angle().p

	vel:Rotate( Angle( 0, 90, 0 ) )
	vel.z = 0

	surface.SetDrawColor( color_white )

	render.SetMaterial( nyan_cat )
	render.DrawQuadEasy( self:GetPos(), vel , 64, 64, color_white, -90 + vz )

	render.SetMaterial( nyan_cat_rev )
	render.DrawQuadEasy( self:GetPos(), -vel, 64, 64, color_white, -90 - vz )

end

if ( CLIENT ) then killicon.Add( "ent_nyan_bomb", "nyan/killicon_bomb", color_white ) return end

function ENT:Initialize()
	self:SetModel( "models/props_c17/SuitCase001a.mdl" )
	self:PhysicsInitSphere( 6, "metal" )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )

	local sw = 16
	local ew = 0

	self.Trail = util.SpriteTrail( self, 0, color_white, false, sw, ew, 1, 1 / ( sw + ew ) * 0.5, "nyan/rainbow.vmt" )
end

function ENT:PhysicsCollide( data, physobj )
	local ent = ents.Create( "env_explosion" )
	ent:SetPos( self:GetPos() )
	ent:SetOwner( self:GetOwner() )
	ent:SetPhysicsAttacker( self )
	ent:Spawn()
	ent:SetKeyValue( "iMagnitude", "0" )
	ent:Fire( "Explode", 0, 0 )

	util.BlastDamage( self, self:GetOwner(), self:GetPos(), 128, 90 )

	--ent:EmitSound( "siege/big_explosion.wav" )

	self:Remove()
end
