
AddCSLuaFile()
AddCSLuaFile( "effects/rb655_nyan_tracer.lua" )
AddCSLuaFile( "effects/rb655_nyan_bounce.lua" )

if ( SERVER ) then resource.AddWorkshop( "123277559" ) end

--[[ --------------------------------- Customization Settings ---------------------------------- ]]

SWEP.Slot = 2
SWEP.SlotPos = 5
SWEP.DrawWeaponInfoBox = false

SWEP.Base = "weapon_base"
SWEP.PrintName = "Nyan Gun"
SWEP.Category = "Robotboy655's Weapons"
SWEP.ViewModel = "models/weapons/c_smg1.mdl"
SWEP.WorldModel = "models/weapons/w_smg1.mdl"
SWEP.Spawnable = true
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.ViewModelFOV = 54
SWEP.UseHands = true
SWEP.HoldType = "smg"

SWEP.IdleLoopSound = "weapons/nyan/nyan_loop.wav"
SWEP.ShootLoopSound = "weapons/nyan/nyan_beat.wav"
SWEP.TracerBounceEffect = "rb655_nyan_bounce"

SWEP.Primary.ClipSize = 10
SWEP.Primary.Delay = 0.1
SWEP.Primary.Damage = 16
SWEP.Primary.Pellets = 1
SWEP.Primary.DefaultClip = 10
SWEP.Primary.Infinite = true
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "rb655_nyan"
SWEP.Primary.Enabled = true
SWEP.Primary.TracerEffect = "rb655_nyan_tracer"

SWEP.Secondary.Delay = 0.5
SWEP.Secondary.Damage = 8
SWEP.Secondary.Pellets = 6
SWEP.Secondary.Infinite = true
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "rb655_nyan"
SWEP.Secondary.Enabled = true
SWEP.Secondary.TracerEffect = "rb655_nyan_tracer"

-- Reload attack
SWEP.Tertiary = {}
SWEP.Tertiary.Enabled = true
SWEP.Tertiary.Projectile = "ent_nyan_bomb"
-- TODO: SWEP.Tertiary.Ammo ?

function SWEP:ReloadSound()
	self:EmitSound( "weapons/nyan/nya" .. math.random( 1, 2 ) .. ".wav", 100, math.random( 60, 80 ) )
end
function SWEP:SecondarySound()
	self:EmitSound( "weapons/nyan/nya" .. math.random( 1, 2 ) .. ".wav", 100, math.random( 85, 100 ) )
end
function SWEP:PrimaryNPCSound()
	self:EmitSound( "weapons/nyan/nya" .. math.random( 1, 2 ) .. ".wav", 100, math.random( 60, 80 ) )
end

--[[ --------------------------------- Custom Ammo Type ---------------------------------- ]]

game.AddAmmoType( { name = "rb655_nyan" } )
if ( CLIENT ) then language.Add( "rb655_nyan_ammo", "Annoying Ammo" ) end

--[[ --------------------------------- TTT ---------------------------------- ]]

SWEP.EquipMenuData = {
	type = "item_weapon",
	desc = [[The Nyan Gun. Provides:
	* Blown cover
	* Annoying sounds
	* Kind of a lot of ammo
	* Annoyingly small damage]]
}

SWEP.Icon = "nyan/ttt_icon.png"

SWEP.Kind = WEAPON_EQUIP2
SWEP.CanBuy = { ROLE_TRAITOR }
SWEP.LimitedStock = true

if ( GAMEMODE.Name == "Trouble in Terrorist Town" ) then
	SWEP.Primary.Damage = 5
	SWEP.Primary.ClipSize = 128
	SWEP.Primary.DefaultClip = 128
	SWEP.Primary.ClipMax = 128
	SWEP.Primary.Infinite = false

	SWEP.Secondary.Enabled = false
	SWEP.Secondary.Infinite = false

	SWEP.Tertiary.Enabled = false

	SWEP.Slot = 6
end

function SWEP:IsEquipment() return false end
function SWEP:GetHeadshotMultiplier() return 1 end

--[[ ------------------------------ END OF TTT ------------------------------ ]]

function SWEP:SetupDataTables()
	self:NetworkVar( "Float", 1, "NextIdle" )
end

function SWEP:Initialize()
	self:SetHoldType( self.HoldType )
end

function SWEP:PrimaryAttack()

	if ( not self.Primary.Enabled ) then return end
	if ( not self:CanPrimaryAttack() ) then return end

	local owner = self:GetOwner()

	if ( owner:IsNPC() ) then
		self:PrimaryNPCSound()
	else
		if ( self.LoopSound ) then
			self.LoopSound:ChangeVolume( 1, 0.1 )
		else
			self.LoopSound = CreateSound( owner, self.IdleLoopSound )
			if ( self.LoopSound ) then self.LoopSound:Play() end
		end
		if ( self.BeatSound ) then self.BeatSound:ChangeVolume( 0, 0.1 ) end
	end

	if ( IsFirstTimePredicted() ) then

		local bullet = {}
		bullet.Num = self.Primary.Pellets
		bullet.Src = owner:GetShootPos()
		bullet.Dir = owner:GetAimVector()
		bullet.Spread = Vector( 0.01, 0.01, 0 )
		bullet.Tracer = 1
		bullet.Force = 5
		bullet.Damage = self.Primary.Damage
		--bullet.AmmoType = "Ar2AltFire" -- For some extremely stupid reason this breaks the tracer effect
		bullet.TracerName = self.Primary.TracerEffect
		owner:FireBullets( bullet )

		self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
		owner:SetAnimation( PLAYER_ATTACK1 )

		if ( not self.Primary.Infinite ) then
			self:TakePrimaryAmmo( 1 )
		end
	end

	self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	self:SetNextSecondaryFire( CurTime() + self.Primary.Delay )

	self:Idle()

end

function SWEP:SecondaryAttack()

	if ( not self.Secondary.Enabled ) then return end
	if ( not self:CanPrimaryAttack() ) then return end

	local owner = self:GetOwner()

	if ( IsFirstTimePredicted() ) then
		self:SecondarySound()

		local bullet = {}
		bullet.Num = self.Secondary.Pellets
		bullet.Src = owner:GetShootPos()
		bullet.Dir = owner:GetAimVector()
		bullet.Spread = Vector( 0.10, 0.1, 0 )
		bullet.Tracer = 1
		bullet.Force = 10
		bullet.Damage = self.Secondary.Damage
		--bullet.AmmoType = "Ar2AltFire"
		bullet.TracerName = self.Secondary.TracerEffect
		owner:FireBullets( bullet )

		self:SendWeaponAnim( ACT_VM_SECONDARYATTACK )
		owner:SetAnimation( PLAYER_ATTACK1 )

		if ( not self.Secondary.Infinite ) then
			self:TakePrimaryAmmo( 1 )
		end
	end

	self:SetNextPrimaryFire( CurTime() + self.Secondary.Delay )
	self:SetNextSecondaryFire( CurTime() + self.Secondary.Delay )

	self:Idle()

end

function SWEP:Reload()

	if ( not self.Tertiary.Enabled ) then return end
	if ( self:GetNextPrimaryFire() > CurTime() ) then return end

	local owner = self:GetOwner()
	if ( not owner:KeyPressed( IN_RELOAD ) ) then return end

	if ( SERVER ) then
		local ang = owner:EyeAngles()
		local ent = ents.Create( self.Tertiary.Projectile )
		if ( IsValid( ent ) ) then
			ent:SetPos( owner:GetShootPos() + ang:Forward() * 28 + ang:Right() * 24 - ang:Up() * 8 )
			ent:SetAngles( ang )
			ent:SetOwner( owner )
			ent:Spawn()
			ent:Activate()

			local phys = ent:GetPhysicsObject()
			if ( IsValid( phys ) ) then phys:Wake() phys:AddVelocity( ent:GetForward() * 1337 ) end
		end
	end

	self:SendWeaponAnim( ACT_VM_SECONDARYATTACK )
	owner:SetAnimation( PLAYER_ATTACK1 )

	self:ReloadSound()

	self:SetNextPrimaryFire( CurTime() + 1 )
	self:SetNextSecondaryFire( CurTime() + 1 )

	self:Idle()

end

function SWEP:DoImpactEffect( trace, damageType )

	local effectdata = EffectData()
	effectdata:SetStart( trace.HitPos )
	effectdata:SetOrigin( trace.HitNormal + Vector( math.Rand( -0.5, 0.5 ), math.Rand( -0.5, 0.5 ), math.Rand( -0.5, 0.5 ) ) )
	util.Effect( self.TracerBounceEffect, effectdata )

	return true

end

function SWEP:FireAnimationEvent( pos, ang, event )

	return true

end

function SWEP:KillSounds()

	if ( self.BeatSound ) then self.BeatSound:Stop() self.BeatSound = nil end
	if ( self.LoopSound ) then self.LoopSound:Stop() self.LoopSound = nil end

end

function SWEP:OnRemove()

	self:KillSounds()

end

function SWEP:OnDrop()

	self:KillSounds()

end

function SWEP:Deploy()

	self:SendWeaponAnim( ACT_VM_DRAW )
	self:SetNextPrimaryFire( CurTime() + self:SequenceDuration() )

	if ( CLIENT ) then return true end

	self:Idle()

	self.BeatSound = CreateSound( self:GetOwner(), self.ShootLoopSound )
	if ( self.BeatSound ) then self.BeatSound:Play() end

	return true

end

function SWEP:Holster()

	self:KillSounds()
	return true

end

function SWEP:Think()

	if ( self:Clip1() <= 0 and self:GetNextPrimaryFire() < CurTime() ) then

		self:DefaultReload( ACT_VM_RELOAD )
		self:Idle()

		return
	end

	if ( self:GetNextIdle() > 0 and CurTime() > self:GetNextIdle() ) then

		self:DoIdleAnimation()
		self:Idle()

	end

	local owner = self:GetOwner()
	if ( owner:IsPlayer() and ( owner:KeyReleased( IN_ATTACK ) or not owner:KeyDown( IN_ATTACK ) or self:Clip1() <= 0 ) ) then
		if ( self.LoopSound ) then self.LoopSound:ChangeVolume( 0, 0.1 ) end
		if ( self.BeatSound ) then self.BeatSound:ChangeVolume( 1, 0.1 ) end
	end

	if ( CLIENT ) then
		self.DrawAmmo = not self.Primary.Infinite or not self.Secondary.Infinite
	end

end

function SWEP:DoIdleAnimation()

	self:SendWeaponAnim( ACT_VM_IDLE )

end

function SWEP:Idle()

	self:SetNextIdle( CurTime() + self:GetAnimationTime() )

end

function SWEP:GetAnimationTime()

	local owner = self:GetOwner()

	local time = self:SequenceDuration()
	if ( time == 0 and IsValid( owner ) and not owner:IsNPC() and IsValid( owner:GetViewModel() ) ) then time = owner:GetViewModel():SequenceDuration() end

	return time

end

if ( SERVER ) then return end

killicon.Add( "weapon_nyangun", "nyan/killicon", color_white )

SWEP.WepSelectIcon = Material( "nyan/selection.png" )

function SWEP:DrawWeaponSelection( x, y, w, h, a )

	surface.SetDrawColor( 255, 255, 255, a )
	surface.SetMaterial( self.WepSelectIcon )

	local size = math.min( w, h )
	surface.DrawTexturedRect( x + w / 2 - size / 2, y, size, size )

end

function SWEP:CustomAmmoDisplay()

	self.AmmoDisplay = self.AmmoDisplay or {}
	self.AmmoDisplay.Draw = true
	self.AmmoDisplay.PrimaryClip = self:Clip1()
	self.AmmoDisplay.PrimaryAmmo = self:Ammo1()

	-- TODO: Ammo for the bombs?

	return self.AmmoDisplay

end