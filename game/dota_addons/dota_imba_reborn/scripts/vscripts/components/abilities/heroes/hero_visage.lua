-- Creator:
--	   AltiV, August 6th, 2019

LinkLuaModifier("modifier_imba_visage_grave_chill_buff", "components/abilities/heroes/hero_visage", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_visage_grave_chill_debuff", "components/abilities/heroes/hero_visage", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_visage_grave_chill_aura", "components/abilities/heroes/hero_visage", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_visage_grave_chill_aura_modifier", "components/abilities/heroes/hero_visage", LUA_MODIFIER_MOTION_NONE)

LinkLuaModifier("modifier_imba_visage_soul_assumption", "components/abilities/heroes/hero_visage", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_visage_soul_assumption_stacks", "components/abilities/heroes/hero_visage", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_visage_soul_assumption_counter", "components/abilities/heroes/hero_visage", LUA_MODIFIER_MOTION_NONE)

LinkLuaModifier("modifier_imba_visage_gravekeepers_cloak", "components/abilities/heroes/hero_visage", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_visage_gravekeepers_cloak_secondary", "components/abilities/heroes/hero_visage", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_visage_gravekeepers_cloak_secondary_ally", "components/abilities/heroes/hero_visage", LUA_MODIFIER_MOTION_NONE)

LinkLuaModifier("modifier_imba_visage_summon_familiars", "components/abilities/heroes/hero_visage", LUA_MODIFIER_MOTION_NONE)

LinkLuaModifier("modifier_imba_visage_summon_familiars_stone_form", "components/abilities/heroes/hero_visage", LUA_MODIFIER_MOTION_NONE)

imba_visage_grave_chill									= class({})
modifier_imba_visage_grave_chill_buff					= class({})
modifier_imba_visage_grave_chill_debuff					= class({})
modifier_imba_visage_grave_chill_aura					= class({})
modifier_imba_visage_grave_chill_aura_modifier			= class({})

imba_visage_soul_assumption								= class({})
modifier_imba_visage_soul_assumption					= class({})
modifier_imba_visage_soul_assumption_stacks				= class({})
modifier_imba_visage_soul_assumption_counter			= class({})

imba_visage_gravekeepers_cloak							= class({})
modifier_imba_visage_gravekeepers_cloak					= class({})
modifier_imba_visage_gravekeepers_cloak_secondary		= class({})
modifier_imba_visage_gravekeepers_cloak_secondary_ally	= class({})

imba_visage_stone_form_self_cast						= class({})

imba_visage_summon_familiars							= class({})
modifier_imba_visage_summon_familiars					= class({})

imba_visage_summon_familiars_stone_form					= class({})
modifier_imba_visage_summon_familiars_stone_form		= class({})

-----------------
-- GRAVE CHILL --
-----------------

function imba_visage_grave_chill:GetIntrinsicModifierName()
	return "modifier_imba_visage_grave_chill_aura"
end

function imba_visage_grave_chill:OnSpellStart()
	local target = self:GetCursorTarget()
	
	-- Blocked by Linken's
	if target:TriggerSpellAbsorb(self) then return end
		
	self:GetCaster():EmitSound("Hero_Visage.GraveChill.Cast")
	target:EmitSound("Hero_Visage.GraveChill.Target")
	
	local chill_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_visage/visage_grave_chill_cast_beams.vpcf", PATTACH_POINT_FOLLOW, self:GetCaster())
	ParticleManager:SetParticleControlEnt(chill_particle, 0, target, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(chill_particle, 1, self:GetCaster(), PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin(), true)
	ParticleManager:ReleaseParticleIndex(chill_particle)
	
	local chill_buff_modifier	= self:GetCaster():AddNewModifier(target, self, "modifier_imba_visage_grave_chill_buff", {duration = self:GetSpecialValueFor("chill_duration")})
	
	if chill_buff_modifier then
		chill_buff_modifier:SetDuration(self:GetSpecialValueFor("chill_duration") * (1 - target:GetStatusResistance()), true)
	end	
	
	-- TODO: Apply buff to familiars within 1200 range
	
	local chill_debuff_modifier = target:AddNewModifier(self:GetCaster(), self, "modifier_imba_visage_grave_chill_debuff", {duration = self:GetSpecialValueFor("chill_duration")})
	
	if chill_debuff_modifier then
		chill_debuff_modifier:SetDuration(self:GetSpecialValueFor("chill_duration") * (1 - target:GetStatusResistance()), true)
	end
end

-------------------------------
-- GRAVE CHILL BUFF MODIFIER --
-------------------------------

function modifier_imba_visage_grave_chill_buff:IsDebuff()	return false end

function modifier_imba_visage_grave_chill_buff:OnCreated()
	self.movespeed_bonus					= self:GetAbility():GetSpecialValueFor("movespeed_bonus")
	self.attackspeed_bonus					= self:GetAbility():GetSpecialValueFor("attackspeed_bonus")
	self.deaths_enticement_bonus_per_sec	= self:GetAbility():GetSpecialValueFor("deaths_enticement_bonus_per_sec")
	
	self.deaths_enticement_stacks			= self:GetCaster():GetModifierStackCount("modifier_imba_visage_grave_chill_aura_modifier", self:GetParent())
	
	if not IsServer() then return end
	
	local chill_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_visage/visage_grave_chill_caster.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	-- I have no god damn idea what connects to where
	ParticleManager:SetParticleControlEnt(chill_particle, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_attack1", self:GetParent():GetAbsOrigin(), true)
	
	if self:GetParent():GetName() == "npc_dota_hero_visage" then
		ParticleManager:SetParticleControlEnt(chill_particle, 2, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_tail_tip", self:GetParent():GetAbsOrigin(), true)ParticleManager:SetParticleControlEnt(chill_particle, 3, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_wingtipL", self:GetParent():GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(chill_particle, 4, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_wingtipR", self:GetParent():GetAbsOrigin(), true)
	else
		ParticleManager:SetParticleControlEnt(chill_particle, 2, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)ParticleManager:SetParticleControlEnt(chill_particle, 3, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(chill_particle, 4, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)	
	end
	
	self:AddParticle(chill_particle, false, false, -1, false, false)
end

function modifier_imba_visage_grave_chill_buff:DeclareFunctions()
	local decFuncs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
	}
	
	return decFuncs
end

function modifier_imba_visage_grave_chill_buff:GetModifierMoveSpeedBonus_Percentage()
	return self.movespeed_bonus
end

function modifier_imba_visage_grave_chill_buff:GetModifierAttackSpeedBonus_Constant()
	return self.attackspeed_bonus + (self.deaths_enticement_stacks * self.deaths_enticement_bonus_per_sec)
end

---------------------------------
-- GRAVE CHILL DEBUFF MODIFIER --
---------------------------------

function modifier_imba_visage_grave_chill_debuff:OnCreated()
	self.movespeed_bonus					= self:GetAbility():GetSpecialValueFor("movespeed_bonus")
	self.attackspeed_bonus					= self:GetAbility():GetSpecialValueFor("attackspeed_bonus")
	self.deaths_enticement_bonus_per_sec	= self:GetAbility():GetSpecialValueFor("deaths_enticement_bonus_per_sec")
	
	self.deaths_enticement_stacks			= self:GetParent():GetModifierStackCount("modifier_imba_visage_grave_chill_aura_modifier", self:GetCaster())
	
	if not IsServer() then return end
	
	local chill_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_visage/visage_grave_chill_tgt.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	ParticleManager:SetParticleControlEnt(chill_particle, 2, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
	self:AddParticle(chill_particle, false, false, -1, false, false)
end

function modifier_imba_visage_grave_chill_debuff:DeclareFunctions()
	local decFuncs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
	}
	
	return decFuncs
end

function modifier_imba_visage_grave_chill_debuff:GetModifierMoveSpeedBonus_Percentage()
	return self.movespeed_bonus * (-1)
end

function modifier_imba_visage_grave_chill_debuff:GetModifierAttackSpeedBonus_Constant()
	return (self.attackspeed_bonus + self.deaths_enticement_stacks * self.deaths_enticement_bonus_per_sec) * (-1)
end

-------------------------------
-- GRAVE CHILL AURA MODIFIER --
-------------------------------

-- Assuming this line will be required in case it gets duplicated through something like Grimstroke's Soulbind, which would then otherwise remove this modifier
function modifier_imba_visage_grave_chill_aura:GetAttributes()			return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_imba_visage_grave_chill_aura:IsAura() 				return true end
function modifier_imba_visage_grave_chill_aura:IsAuraActiveOnDeath() 	return true end

function modifier_imba_visage_grave_chill_aura:GetAuraRadius()			return FIND_UNITS_EVERYWHERE end
function modifier_imba_visage_grave_chill_aura:GetAuraSearchFlags()		return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD end

function modifier_imba_visage_grave_chill_aura:GetAuraSearchTeam()		return DOTA_UNIT_TARGET_TEAM_BOTH end
function modifier_imba_visage_grave_chill_aura:GetAuraSearchType()		return DOTA_UNIT_TARGET_ALL end
function modifier_imba_visage_grave_chill_aura:GetModifierAura()		return "modifier_imba_visage_grave_chill_aura_modifier" end

----------------------------------------
-- GRAVE CHILL AURA MODIFIER MODIFIER --
----------------------------------------

function modifier_imba_visage_grave_chill_aura_modifier:IsPurgable()	return false end

function modifier_imba_visage_grave_chill_aura_modifier:OnCreated()
	if not IsServer() then return end

	self:StartIntervalThink(1)
end

function modifier_imba_visage_grave_chill_aura_modifier:OnIntervalThink()
	self:IncrementStackCount()
end

---------------------
-- SOUL ASSUMPTION --
---------------------

function imba_visage_soul_assumption:GetIntrinsicModifierName()
	return "modifier_imba_visage_soul_assumption"
end

function imba_visage_soul_assumption:OnUpgrade()
	if not IsServer() then return end
	
	if self:GetLevel() >= 1 and self:GetCaster():FindModifierByNameAndCaster(self:GetIntrinsicModifierName(), self:GetCaster()) and not self:GetCaster():FindModifierByNameAndCaster(self:GetIntrinsicModifierName(), self:GetCaster()).particle then
		self:GetCaster():FindModifierByNameAndCaster(self:GetIntrinsicModifierName(), self:GetCaster()).particle = ParticleManager:CreateParticle("particles/units/heroes/hero_visage/visage_soul_overhead.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetCaster())
		self:GetCaster():FindModifierByNameAndCaster(self:GetIntrinsicModifierName(), self:GetCaster()):AddParticle(self:GetCaster():FindModifierByNameAndCaster(self:GetIntrinsicModifierName(), self:GetCaster()).particle, false, false, -1, false, false)
	end
end

function imba_visage_soul_assumption:OnSpellStart()
	local target = self:GetCursorTarget()
	
	self:GetCaster():EmitSound("Hero_Visage.SoulAssumption.Cast")
	
	local assumption_counter_modifier	= self:GetCaster():FindModifierByNameAndCaster("modifier_imba_visage_soul_assumption_counter", self:GetCaster())
	local damage_bars					= 0
	local effect_name					= "particles/units/heroes/hero_visage/visage_soul_assumption_bolt.vpcf"
	
	if assumption_counter_modifier then	
		damage_bars = math.min(math.floor(assumption_counter_modifier:GetStackCount() / self:GetSpecialValueFor("damage_limit")), self:GetSpecialValueFor("stack_limit"))
		
		if damage_bars > 0 then
			effect_name	="particles/units/heroes/hero_visage/visage_soul_assumption_bolt"..damage_bars..".vpcf"
		end
		
		local assumption_stack_modifiers = self:GetCaster():FindAllModifiersByName("modifier_imba_visage_soul_assumption_stacks")
		
		for _, mod in pairs(assumption_stack_modifiers) do
			mod:Destroy()
		end
		
		assumption_counter_modifier:Destroy()
	end
	
	local projectile =
	{
		Target 				= target,
		Source 				= self:GetCaster(),
		Ability 			= self,
		EffectName 			= effect_name,
		iMoveSpeed			= self:GetSpecialValueFor("bolt_speed"),
		vSourceLoc 			= self:GetCaster():GetAbsOrigin(),
		bDrawsOnMinimap 	= false,
		bDodgeable 			= true,
		bIsAttack 			= false,
		bVisibleToEnemies 	= true,
		bReplaceExisting 	= false,
		flExpireTime 		= GameRules:GetGameTime() + 10.0,
		bProvidesVision 	= false,
		
		iSourceAttachment	= DOTA_PROJECTILE_ATTACHMENT_ATTACK_1,
		
		ExtraData = {
			charges			= damage_bars
		}
	}
	
	--particles/units/heroes/hero_visage/visage_soul_assumption_bolt.vpcf
	--particles/units/heroes/hero_visage/visage_soul_assumption_bolt1.vpcf
	--particles/units/heroes/hero_visage/visage_soul_assumption_bolt2.vpcf
	--particles/units/heroes/hero_visage/visage_soul_assumption_bolt3.vpcf
	--particles/units/heroes/hero_visage/visage_soul_assumption_bolt4.vpcf
	--particles/units/heroes/hero_visage/visage_soul_assumption_bolt5.vpcf
	--particles/units/heroes/hero_visage/visage_soul_assumption_bolt6.vpcf
		
	ProjectileManager:CreateTrackingProjectile(projectile)
	
				-- "01"
			-- {
				-- "var_type"					"FIELD_INTEGER"
				-- "bolt_speed"				"1000"
			-- }
			-- "02"
			-- {
				-- "var_type"					"FIELD_INTEGER"
				-- "soul_base_damage"			"20"
			-- }
			-- "03"
			-- {
				-- "var_type"					"FIELD_INTEGER"
				-- "soul_charge_damage"		"75"
				-- "LinkedSpecialBonus"		"special_bonus_unique_visage_4"
			-- }
			-- "04"
			-- {
				-- "var_type"					"FIELD_INTEGER"
				-- "stack_limit"				"3 4 5 6"
			-- }
			-- "05"
			-- {
				-- "var_type"					"FIELD_FLOAT"
				-- "stack_duration"			"6.0"
			-- }
			-- "06"
			-- {
				-- "var_type"					"FIELD_INTEGER"
				-- "damage_limit"				"110"
			-- }
			-- "07"
			-- {
				-- "var_type"					"FIELD_INTEGER"
				-- "radius"					"1375"
			-- }
			-- "08"
			-- {
				-- "var_type"					"FIELD_FLOAT"
				-- "damage_min"				"2.0"
			-- }
			-- "09"
			-- {
				-- "var_type"					"FIELD_FLOAT"
				-- "damage_max"				"3000.0"
			-- }
end

function imba_visage_soul_assumption:OnProjectileHit_ExtraData(target, location, data)
	if target and not target:TriggerSpellAbsorb(self) then
		target:EmitSound("Hero_Visage.SoulAssumption.Target")
	
		-- TODO: play sound and particles if applicable
		local damageTable = {
			victim 			= target,
			damage 			= self:GetSpecialValueFor("soul_base_damage") + (self:GetTalentSpecialValueFor("soul_charge_damage") * data.charges),
			damage_type		= self:GetAbilityDamageType(),
			damage_flags 	= DOTA_DAMAGE_FLAG_NONE,
			attacker 		= self:GetCaster(),
			ability 		= self
		}

		ApplyDamage(damageTable)
	end
end

-------------------------------
-- SOUL ASSUMPTION MODIFIER --
------------------------------

function modifier_imba_visage_soul_assumption:GetAttributes()	return MODIFIER_ATTRIBUTE_MULTIPLE end

-- This shouldn't really happen but in case it gets ported in already leveled
function modifier_imba_visage_soul_assumption:OnCreated()
	if not IsServer() then return end
	
	if self:GetAbility() and self:GetAbility():GetLevel() >= 1 and not self.particle then
		self.particle = ParticleManager:CreateParticle("particles/units/heroes/hero_visage/visage_soul_overhead.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent())
		self:AddParticle(self.particle, false, false, -1, false, false)
	end
end

function modifier_imba_visage_soul_assumption:OnDestroy()
	if IsServer() and self.particle then
		ParticleManager:DestroyParticle(self.particle, true)
		ParticleManager:ReleaseParticleIndex(self.particle)
	end
end

function modifier_imba_visage_soul_assumption:DeclareFunctions()
	local decFuncs = {
		MODIFIER_EVENT_ON_TAKEDAMAGE
	}
	
	return decFuncs
end

function modifier_imba_visage_soul_assumption:OnTakeDamage(keys)
	-- "Only counts damage dealt by players (including their summons) and Roshan."
	-- "Only counts when the damage was dealt to a hero (excluding illusions and creep-heroes)."
	-- "Does not count self-inflicted damage, or damage less than 2 or greater than 3000 (after reductions)."
	
	if (keys.unit:GetAbsOrigin() - self:GetParent():GetAbsOrigin()):Length2D() <= self:GetAbility():GetSpecialValueFor("radius") and
	((keys.attacker.GetPlayerID and keys.attacker:GetPlayerID()) or keys.attacker:IsRoshan()) and
	keys.unit:IsRealHero() and
	keys.unit ~= keys.attacker and
	keys.damage >= self:GetAbility():GetSpecialValueFor("damage_min") and
	keys.damage <= self:GetAbility():GetSpecialValueFor("damage_max") and
	-- Seems like Soul Assumption damage doesn't feed into its own stacks
	keys.inflictor ~= self:GetAbility() then	
		self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_imba_visage_soul_assumption_counter", 
		{
			duration	= self:GetAbility():GetSpecialValueFor("stack_duration"),
			stacks		= keys.damage
		})
	
		self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_imba_visage_soul_assumption_stacks", 
		{
			duration	= self:GetAbility():GetSpecialValueFor("stack_duration"),
			stacks		= keys.damage
		})
	end
end

-------------------------------------
-- SOUL ASSUMPTION STACKS MODIFIER --
-------------------------------------

function modifier_imba_visage_soul_assumption_stacks:IsHidden()				return true end
function modifier_imba_visage_soul_assumption_stacks:GetAttributes()		return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_imba_visage_soul_assumption_stacks:OnCreated(params)
	if not IsServer() then return end

	self.damage_limit	= self:GetAbility():GetSpecialValueFor("damage_limit")
	self.stack_limit	= self:GetAbility():GetSpecialValueFor("stack_limit")

	self:SetStackCount(params.stacks)

	local assumption_modifier			= self:GetParent():FindModifierByNameAndCaster("modifier_imba_visage_soul_assumption", self:GetCaster())
	local assumption_counter_modifier 	= self:GetParent():FindModifierByNameAndCaster("modifier_imba_visage_soul_assumption_counter", self:GetCaster())
	
	if assumption_modifier and assumption_modifier.particle and assumption_counter_modifier then
		assumption_counter_modifier:SetStackCount(assumption_counter_modifier:GetStackCount() + params.stacks)
	
		for bar = 1, self.stack_limit do
			ParticleManager:SetParticleControl(assumption_modifier.particle, bar, Vector(assumption_counter_modifier:GetStackCount() - (self.damage_limit * bar), 0, 0))
		end
	end
end

function modifier_imba_visage_soul_assumption_stacks:OnDestroy()
	if not IsServer() then return end
	
	local assumption_modifier			= self:GetParent():FindModifierByNameAndCaster("modifier_imba_visage_soul_assumption", self:GetCaster())
	local assumption_counter_modifier 	= self:GetParent():FindModifierByNameAndCaster("modifier_imba_visage_soul_assumption_counter", self:GetCaster())
	
	if assumption_counter_modifier then
		assumption_counter_modifier:SetStackCount(assumption_counter_modifier:GetStackCount() - self:GetStackCount())
		
		if assumption_modifier and assumption_modifier.particle then
			for bar = 1, 6 do
				ParticleManager:SetParticleControl(assumption_modifier.particle, bar, Vector(assumption_counter_modifier:GetStackCount() - (self.damage_limit * bar), 0, 0))
			end
		end
	end
end

------------------------------------
-- SOUL ASSUMPTION COUNT MODIFIER --
------------------------------------

function modifier_imba_visage_soul_assumption_counter:IsPurgable()	return false end

-------------------------
-- GRAVEKEEPER'S CLOAK --
-------------------------

function imba_visage_gravekeepers_cloak:GetIntrinsicModifierName()
	return "modifier_imba_visage_gravekeepers_cloak"
end

-- Hmm...
function imba_visage_gravekeepers_cloak:OnSpellStart()

end

----------------------------------
-- GRAVEKEEPER'S CLOAK MODIFIER --
----------------------------------

function modifier_imba_visage_gravekeepers_cloak:OnCreated()
	if not IsServer() then return end

	self.max_layers			= self:GetAbility():GetSpecialValueFor("max_layers")
	self.damage_reduction	= self:GetAbility():GetSpecialValueFor("damage_reduction")
	self.minimum_damage		= self:GetAbility():GetSpecialValueFor("minimum_damage")
	self.radius				= self:GetAbility():GetSpecialValueFor("radius")

	self:StartIntervalThink(self:GetAbility():GetTalentSpecialValueFor("recovery_time"))
end

function modifier_imba_visage_gravekeepers_cloak:OnRefresh()
	if not IsServer() or not self:GetAbility() then return end
	
	self:StartIntervalThink(self:GetAbility():GetTalentSpecialValueFor("recovery_time"))
end

function modifier_imba_visage_gravekeepers_cloak:OnIntervalThink()
	if self:GetStackCount() < self.max_layers then
		self:IncrementStackCount()
	end
end

function modifier_imba_visage_gravekeepers_cloak:DeclareFunctions()
	local decFuncs = {
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE
	}
end

function modifier_imba_visage_gravekeepers_cloak:GetModifierIncomingDamage_Percentage(keys)
	if not self:GetParent():PassivesDisabled() and keys.attacker.GetPlayerID and keys.attacker:GetPlayerID() and keys.damage > self.minimum_damage and self:GetStackCount() > 0 then
		self:DecrementStackCount()
		return self.damage_reduction * (self:GetStackCount() + 1) * (-1)
	else
		return 0
	end
end

function modifier_imba_visage_gravekeepers_cloak:IsAura()						return true end
function modifier_imba_visage_gravekeepers_cloak:IsAuraActiveOnDeath() 			return false end

function modifier_imba_visage_gravekeepers_cloak:GetAuraRadius()				return self:GetAbility():GetSpecialValueFor("radius") end
function modifier_imba_visage_gravekeepers_cloak:GetAuraSearchFlags()			return DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD + DOTA_UNIT_TARGET_FLAG_PLAYER_CONTROLLED end

function modifier_imba_visage_gravekeepers_cloak:GetAuraSearchTeam()			return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_imba_visage_gravekeepers_cloak:GetAuraSearchType()			return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_imba_visage_gravekeepers_cloak:GetModifierAura()				return "modifier_imba_visage_gravekeepers_cloak_secondary" end

function modifier_imba_visage_gravekeepers_cloak:GetAuraEntityReject(hTarget)	return self:GetCaster():PassivesDisabled() or not hTarget:GetOwner() or not hTarget:GetOwner() == self:GetCaster() or not string.find(hTarget:GetDebugName(), "npc_dota_visage_familiar") end

--------------------------------------------
-- GRAVEKEEPER'S CLOAK SECONDARY MODIFIER --
--------------------------------------------

function modifier_imba_visage_gravekeepers_cloak_secondary:DeclareFunctions()
	local decFuncs = {
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE
	}
end

function modifier_imba_visage_gravekeepers_cloak_secondary:GetModifierIncomingDamage_Percentage(keys)
	return self:GetCaster():GetModifierStackCount("modifier_imba_visage_gravekeepers_cloak", self:GetCaster())
end

			-- "01"
			-- {
				-- "var_type"							"FIELD_INTEGER"
				-- "max_layers"						"4"
			-- }
			-- "02"
			-- {
				-- "var_type"							"FIELD_INTEGER"
				-- "damage_reduction"					"8 12 16 20"
			-- }
			-- "03"
			-- {
				-- "var_type"							"FIELD_INTEGER"
				-- "recovery_time"						"6 5 4 3"
				-- "LinkedSpecialBonus"	"special_bonus_unique_visage_5"
			-- }
			-- "04"
			-- {
				-- "var_type"							"FIELD_INTEGER"
				-- "minimum_damage"					"40"
			-- }
			-- "05"
			-- {
				-- "var_type"							"FIELD_INTEGER"
				-- "radius"							"1200"
			-- }

-------------------------------------------------
-- GRAVEKEEPER'S CLOAK SECONDARY ALLY MODIFIER --
-------------------------------------------------

--------------------------
-- STONE FORM SELF CAST --
--------------------------

----------------------
-- SUMMON FAMILIARS --
----------------------
--familiars take 4 hp damage if all the damage is blocked by a right click (but still does 0 from magic???)

function imba_visage_summon_familiars:OnSpellStart()

end

-------------------------------
-- SUMMON FAMILIARS MODIFIER --
-------------------------------

function modifier_imba_visage_summon_familiars:OnCreated()

end

---------------------------------
-- SUMMON FAMILIARS STONE FORM --
---------------------------------

function imba_visage_summon_familiars_stone_form:OnSpellStart()

end

------------------------------------------
-- SUMMON FAMILIARS STONE FORM MODIFIER --
------------------------------------------

function modifier_imba_visage_summon_familiars_stone_form:OnCreated()

end

-- LinkLuaModifier("modifier_imba_puck_illusory_orb", "components/abilities/heroes/hero_puck", LUA_MODIFIER_MOTION_NONE)

-- LinkLuaModifier("modifier_imba_puck_waning_rift", "components/abilities/heroes/hero_puck", LUA_MODIFIER_MOTION_NONE)

-- LinkLuaModifier("modifier_imba_puck_phase_shift", "components/abilities/heroes/hero_puck", LUA_MODIFIER_MOTION_NONE)
-- LinkLuaModifier("modifier_imba_puck_phase_shift_handler", "components/abilities/heroes/hero_puck", LUA_MODIFIER_MOTION_NONE)

-- LinkLuaModifier("modifier_imba_puck_dream_coil", "components/abilities/heroes/hero_puck", LUA_MODIFIER_MOTION_NONE)
-- LinkLuaModifier("modifier_imba_puck_dream_coil_thinker", "components/abilities/heroes/hero_puck", LUA_MODIFIER_MOTION_NONE)
-- LinkLuaModifier("modifier_imba_puck_dream_coil_visionary", "components/abilities/heroes/hero_puck", LUA_MODIFIER_MOTION_NONE)

-- imba_puck_illusory_orb					= class({})
-- modifier_imba_puck_illusory_orb			= class({})
	
-- imba_puck_waning_rift					= class({})
-- modifier_imba_puck_waning_rift			= class({})

-- imba_puck_phase_shift					= class({})
-- modifier_imba_puck_phase_shift			= class({})
-- modifier_imba_puck_phase_shift_handler	= class({})

-- imba_puck_ethereal_jaunt				= class({})

-- imba_puck_dream_coil					= class({})
-- modifier_imba_puck_dream_coil			= class({})
-- modifier_imba_puck_dream_coil_thinker	= class({})
-- modifier_imba_puck_dream_coil_visionary	= class({})

-- ------------------
-- -- ILLUSORY ORB --
-- ------------------

-- function imba_puck_illusory_orb:GetAssociatedSecondaryAbilities()
	-- return "imba_puck_ethereal_jaunt"
-- end

-- function imba_puck_illusory_orb:OnUpgrade()
	-- local jaunt_ability = self:GetCaster():FindAbilityByName("imba_puck_ethereal_jaunt")

	-- if jaunt_ability and not self.jaunt_ability then
		-- self.jaunt_ability	= jaunt_ability
		
		-- if not jaunt_ability:IsTrained() then
			-- self.jaunt_ability:SetLevel(1)
		-- end
	-- end
-- end

-- function imba_puck_illusory_orb:OnSpellStart()
	-- -- In reality this small block would never be called, but this was just during testing with ability replacements
	-- local jaunt_ability = self:GetCaster():FindAbilityByName("imba_puck_ethereal_jaunt")

	-- if jaunt_ability and not self.jaunt_ability then
		-- self.jaunt_ability	= jaunt_ability
		
		-- if not jaunt_ability:IsTrained() then
			-- self.jaunt_ability:SetLevel(1)
		-- end
	-- end

	-- -- Keep track of orbs for better ability handling (rather than not getting to jaunt to a second orb if a first expires while both are in flight)
	-- if not self.orbs then
		-- self.orbs = {}
	-- end

	-- self.talent_cast_range_increases = 0
	
	-- for ability = 0, 23 do
		-- local found_ability = self:GetCaster():GetAbilityByIndex(ability)
	
		-- if found_ability and string.find(found_ability:GetName(), "cast_range") and self:GetCaster():HasTalent(found_ability:GetName()) then
			-- self.talent_cast_range_increases = self.talent_cast_range_increases + self:GetCaster():FindTalentValue(found_ability:GetName())
		-- end
	-- end

	-- -- Preventing projectiles getting stuck in one spot due to potential 0 length vector
	-- if self:GetCursorPosition() == self:GetCaster():GetAbsOrigin() then
		-- self:GetCaster():SetCursorPosition(self:GetCursorPosition() + self:GetCaster():GetForwardVector())
	-- end

	-- -- IMBAfication: Dichotomous
	-- -- Reverse Orb
	-- self:FireOrb(self:GetCaster():GetAbsOrigin() - self:GetCursorPosition())
	-- -- Main Orb
	-- self:FireOrb(self:GetCursorPosition() - self:GetCaster():GetAbsOrigin())
	
	-- if self.jaunt_ability then
		-- self.jaunt_ability:SetActivated(true)
	-- end
	
	-- -- IMBAfication: Eternal Jaunt
	-- self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_imba_puck_illusory_orb", {duration = ((self:GetSpecialValueFor("max_distance") * math.max(self:GetCaster():FindTalentValue("special_bonus_imba_puck_illusory_orb_speed"), 1)) + GetCastRangeIncrease(self:GetCaster()) + self.talent_cast_range_increases) / (self:GetSpecialValueFor("orb_speed") * math.max(self:GetCaster():FindTalentValue("special_bonus_imba_puck_illusory_orb_speed"), 1))})
-- end

-- function imba_puck_illusory_orb:OnProjectileThink_ExtraData(location, data)
	-- if not IsServer() then return end
	
	-- if data.orb_thinker then
		-- EntIndexToHScript(data.orb_thinker):SetAbsOrigin(location)
	-- end
	
	-- -- "The orb leaves behind a trail of flying vision, with a radius of 450. The vision lingers for 5 seconds."
	-- -- IDK why the specialvalue is 3.34 but I guess vanilla doesn't use it, also vanilla vision circles are more segmented it seems...
	-- self:CreateVisibilityNode(location, self:GetSpecialValueFor("orb_vision"), 5)
-- end

-- function imba_puck_illusory_orb:FireOrb(position)
	-- -- Create thinker for position and sound handling
	-- local orb_thinker = CreateModifierThinker(
		-- self:GetCaster(),
		-- self,
		-- nil, -- Maybe add one later
		-- {},
		-- self:GetCaster():GetOrigin(),
		-- self:GetCaster():GetTeamNumber(),
		-- false		
	-- )
	
	-- orb_thinker:EmitSound("Hero_Puck.Illusory_Orb")

	-- -- Create linear projectile
	-- local projectile_info = {
		-- Source				= self:GetCaster(),
		-- Ability				= self,
		-- vSpawnOrigin		= self:GetCaster():GetOrigin(),
		
	    -- bDeleteOnHit 		= false,
	    
	    -- iUnitTargetTeam	 	= DOTA_UNIT_TARGET_TEAM_ENEMY,
	    -- iUnitTargetType 	= DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
	    
	    -- EffectName 			= "particles/units/heroes/hero_puck/puck_illusory_orb.vpcf",
	    -- fDistance 			= (self:GetSpecialValueFor("max_distance") * math.max(self:GetCaster():FindTalentValue("special_bonus_imba_puck_illusory_orb_speed"), 1)) + GetCastRangeIncrease(self:GetCaster()) + self.talent_cast_range_increases,
	    -- fStartRadius 		= self:GetSpecialValueFor("radius"),
	    -- fEndRadius 			= self:GetSpecialValueFor("radius"),
		-- vVelocity 			= position:Normalized() * self:GetSpecialValueFor("orb_speed") * math.max(self:GetCaster():FindTalentValue("special_bonus_imba_puck_illusory_orb_speed"), 1),
	
		-- bReplaceExisting 	= false,
		
		-- bProvidesVision 	= true,
		-- iVisionRadius 		= self:GetSpecialValueFor("orb_vision"),
		-- iVisionTeamNumber 	= self:GetCaster():GetTeamNumber(),
		
		-- ExtraData = {
			-- orb_thinker		= orb_thinker:entindex(),
		-- }
	-- }
	
	-- local projectile = ProjectileManager:CreateLinearProjectile(projectile_info)
	
	-- -- Shove the thinker's entity index into orb table (would probably be marginally nicer to shove the projectile id but it seems messy trying to get that into ExtraData
	-- table.insert(self.orbs, orb_thinker:entindex())
-- end

-- function imba_puck_illusory_orb:OnProjectileHit_ExtraData(target, location, data)
	-- if not IsServer() then return end
	
	-- if target then
		-- target:EmitSound("Hero_Puck.IIllusory_Orb_Damage")
		
		-- local damageTable = {
			-- victim 			= target,
			-- damage 			= self:GetAbilityDamage(),
			-- damage_type		= self:GetAbilityDamageType(),
			-- damage_flags 	= DOTA_DAMAGE_FLAG_NONE,
			-- attacker 		= self:GetCaster(),
			-- ability 		= self
		-- }

		-- ApplyDamage(damageTable)
	-- else
		-- if data.orb_thinker then
			-- table.remove(self.orbs, 1)
			-- EntIndexToHScript(data.orb_thinker):StopSound("Hero_Puck.Illusory_Orb")
			-- EntIndexToHScript(data.orb_thinker):RemoveSelf()
		-- end

		-- if self.jaunt_ability and #self.orbs == 0 then
			-- self.jaunt_ability:SetActivated(false)
		-- end
	-- end
-- end

-- ---------------------------
-- -- ILLUSORY ORB MODIFIER --
-- ---------------------------

-- function modifier_imba_puck_illusory_orb:IsHidden()	return true end

-- function modifier_imba_puck_illusory_orb:OnRefresh()
	-- if not IsServer() then return end

	-- self:SetStackCount(0)
-- end

-- -----------------
-- -- WANING RIFT --
-- -----------------

-- function imba_puck_waning_rift:GetCooldown(level)
	-- return self.BaseClass.GetCooldown(self, level) - self:GetCaster():FindTalentValue("special_bonus_imba_puck_waning_rift_cooldown")
-- end

-- function imba_puck_waning_rift:OnSpellStart()
	-- self:GetCaster():EmitSound("Hero_Puck.Waning_Rift")

	-- if self:GetCaster():GetName() == "npc_dota_hero_puck" then
		-- self:GetCaster():EmitSound("puck_puck_ability_rift_0"..RandomInt(1, 3))
	-- end
	
	-- local rift_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_puck/puck_waning_rift.vpcf", PATTACH_ABSORIGIN, self:GetCaster())
	-- ParticleManager:SetParticleControl(rift_particle, 1, Vector(self:GetSpecialValueFor("radius"), 0, 0))
	-- ParticleManager:ReleaseParticleIndex(rift_particle)
	
	-- local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, self:GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	
	-- for _, enemy in pairs(enemies) do
		-- -- "Waning Rift first applies the damage, then the debuff."
	
		-- local damageTable = {
			-- victim 			= enemy,
			-- damage 			= self:GetTalentSpecialValueFor("damage"),
			-- damage_type		= self:GetAbilityDamageType(),
			-- damage_flags 	= DOTA_DAMAGE_FLAG_NONE,
			-- attacker 		= self:GetCaster(),
			-- ability 		= self
		-- }

		-- ApplyDamage(damageTable)
		
		-- local debuff_modifier = enemy:AddNewModifier(self:GetCaster(), self, "modifier_imba_puck_waning_rift", {duration = self:GetSpecialValueFor("silence_duration")})
		
		-- if debuff_modifier then
			-- debuff_modifier:SetDuration(self:GetSpecialValueFor("silence_duration") * (1 - enemy:GetStatusResistance()), true)
		-- end
	-- end
-- end

-- --------------------------
-- -- WANING RIFT MODIFIER --
-- --------------------------

-- function modifier_imba_puck_waning_rift:GetEffectName()
	-- if not self:GetParent():IsCreep() then
		-- return "particles/generic_gameplay/generic_silenced.vpcf"
	-- else
		-- return "particles/generic_gameplay/generic_silenced_lanecreeps.vpcf"
	-- end
-- end

-- function modifier_imba_puck_waning_rift:GetEffectAttachType()
	-- return PATTACH_OVERHEAD_FOLLOW
-- end

-- function modifier_imba_puck_waning_rift:OnCreated()
	-- self.glitter_vision_reduction	= self:GetAbility():GetSpecialValueFor("glitter_vision_reduction")
	
	-- if not IsServer() then return end
	
	-- self:SetStackCount(self:GetAbility():GetSpecialValueFor("trickster_null_instances"))
-- end

-- function modifier_imba_puck_waning_rift:CheckState()
	-- local state = {[MODIFIER_STATE_SILENCED] = true}
	
	-- return state
-- end

-- -- IMBAfication: Pocket Glitter
-- -- IMBAfication: Trickster's Inhibition
-- function modifier_imba_puck_waning_rift:DeclareFunctions()
	-- local decFuncs = {
		-- MODIFIER_PROPERTY_BONUS_VISION_PERCENTAGE,
		-- MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE,
	-- }
	
	-- return decFuncs
-- end

-- function modifier_imba_puck_waning_rift:GetBonusVisionPercentage()
	-- return self.glitter_vision_reduction
-- end

-- function modifier_imba_puck_waning_rift:GetModifierTotalDamageOutgoing_Percentage(keys)
	-- if not IsServer() then return end
	
	-- if self:GetStackCount() > 0 then
		-- self:DecrementStackCount()
		-- return -100
	-- end
-- end

-- -----------------
-- -- PHASE SHIFT --
-- -----------------

-- -- Man this is messy...
-- function imba_puck_phase_shift:CastFilterResultTarget(hTarget)
	-- if not IsServer() or not self:GetAutoCastState() then return end
	
	-- if PlayerResource:IsDisableHelpSetForPlayerID(hTarget:GetPlayerOwnerID(), self:GetCaster():GetPlayerOwnerID()) then 	
		-- return UF_FAIL_DISABLE_HELP
	-- end
		
	-- local nResult = UnitFilter( hTarget, self:GetAbilityTargetTeam(), self:GetAbilityTargetType(), self:GetAbilityTargetFlags(), self:GetCaster():GetTeamNumber() )
	
	-- return nResult
-- end

-- function imba_puck_phase_shift:GetAbilityTargetFlags()
	-- if self:GetCaster():GetModifierStackCount("modifier_imba_puck_phase_shift_handler", self:GetCaster()) == 0 then
		-- return DOTA_UNIT_TARGET_FLAG_NONE
	-- else
		-- return DOTA_UNIT_TARGET_FLAG_INVULNERABLE -- Doesn't seem like this works
	-- end
-- end


-- function imba_puck_phase_shift:GetAbilityTargetTeam()
	-- if self:GetCaster():GetModifierStackCount("modifier_imba_puck_phase_shift_handler", self:GetCaster()) == 0 then
		-- return DOTA_UNIT_TARGET_TEAM_NONE
	-- else
		-- return DOTA_UNIT_TARGET_TEAM_FRIENDLY
	-- end
-- end

-- function imba_puck_phase_shift:GetAbilityTargetType()
	-- if self:GetCaster():GetModifierStackCount("modifier_imba_puck_phase_shift_handler", self:GetCaster()) == 0 then
		-- return DOTA_UNIT_TARGET_NONE
	-- else
		-- return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
	-- end
-- end


-- function imba_puck_phase_shift:GetBehavior()
	-- if self:GetCaster():GetModifierStackCount("modifier_imba_puck_phase_shift_handler", self:GetCaster()) == 0 then
		-- return self.BaseClass.GetBehavior(self) + DOTA_ABILITY_BEHAVIOR_AUTOCAST
	-- else
		-- return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_OPTIONAL_POINT + DOTA_ABILITY_BEHAVIOR_AUTOCAST
	-- end
-- end

-- function imba_puck_phase_shift:GetCastRange(location, target)
	-- if self:GetCaster():GetModifierStackCount("modifier_imba_puck_phase_shift_handler", self:GetCaster()) == 0 or IsClient() then
		-- return self.BaseClass.GetCastRange(self, location, target)
	-- else
		-- self.talent_cast_range_increases = 0
		
		-- for ability = 0, 23 do
			-- local found_ability = self:GetCaster():GetAbilityByIndex(ability)
		
			-- if found_ability and string.find(found_ability:GetName(), "cast_range") and self:GetCaster():HasTalent(found_ability:GetName()) then
				-- self.talent_cast_range_increases = self.talent_cast_range_increases + self:GetCaster():FindTalentValue(found_ability:GetName())
			-- end
		-- end	
	
		-- return self:GetSpecialValueFor("sinusoid_cast_range") - GetCastRangeIncrease(self:GetCaster()) - self.talent_cast_range_increases
	-- end
-- end

-- function imba_puck_phase_shift:GetIntrinsicModifierName()
	-- return "modifier_imba_puck_phase_shift_handler"
-- end

-- function imba_puck_phase_shift:OnSpellStart()
	-- self:GetCaster():EmitSound("Hero_Puck.Phase_Shift")

	-- if self:GetCaster():GetName() == "npc_dota_hero_puck" then
		-- self:GetCaster():EmitSound("puck_puck_ability_phase_0"..RandomInt(1, 7))
	-- end
	
	-- if self:GetAutoCastState() then
		-- -- IMBAfication: Sinusoid
		-- if self:GetCursorPosition() and not self:GetCursorTarget() then
			-- FindClearSpaceForUnit(self:GetCaster(), self:GetCursorPosition(), true)
		-- elseif self:GetCursorTarget() then	
			-- if self:GetCursorTarget() ~= self:GetCaster() then
				-- self:GetCursorTarget():AddNewModifier(self:GetCaster(), self, "modifier_imba_puck_phase_shift", {duration = self:GetSpecialValueFor("duration") + FrameTime()})
			-- end
			
			-- -- Kinda hacky way to allow Puck to self-cast channel (cause I don't think there's any existing ability that actually lets you do that normally)
			-- self:GetCaster():SetCursorCastTarget(nil)
			-- self:GetCaster():SetCursorPosition(self:GetCaster():GetAbsOrigin())
			-- self:OnSpellStart()
		-- end
	-- end
	
	-- -- "The buff lingers for one server tick once the channeling ends or is interrupted, which allows using items while still invulnerable and hidden."
	-- self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_imba_puck_phase_shift", {duration = self:GetSpecialValueFor("duration") + FrameTime()})
-- end

-- function imba_puck_phase_shift:OnChannelFinish(interrupted)
	-- self:GetCaster():StopSound("Hero_Puck.Phase_Shift")

	-- local phase_modifier = self:GetCaster():FindModifierByNameAndCaster("modifier_imba_puck_phase_shift", self:GetCaster())
	
	-- -- "The buff lingers for one server tick once the channeling ends or is interrupted, which allows using items while still invulnerable and hidden."
	-- if phase_modifier then
		-- phase_modifier:StartIntervalThink(FrameTime())
	-- end
-- end

-- --------------------------
-- -- PHASE SHIFT MODIFIER --
-- --------------------------

-- -- Yeah this doesn't work so just gotta call it manually I guess
-- -- function modifier_imba_puck_phase_shift:GetEffectName()
	-- -- return "particles/units/heroes/hero_puck/puck_phase_shift.vpcf"
-- -- end

-- -- function modifier_imba_puck_phase_shift:GetEffectAttachType()
	-- -- return PATTACH_WORLDORIGIN
-- -- end


-- -- Turns Puck green or something a frame before disappearing? This probably isn't actually used
-- function modifier_imba_puck_phase_shift:GetStatusEffectName()
	-- return "particles/status_fx/status_effect_phase_shift.vpcf"
-- end

-- function modifier_imba_puck_phase_shift:OnCreated()
	-- if not IsServer() then return end
	
	-- ProjectileManager:ProjectileDodge(self:GetParent())
	
	-- local phase_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_puck/puck_phase_shift.vpcf", PATTACH_WORLDORIGIN, self:GetParent())
	-- -- This doesn't seem to match the vanilla particle affect properly...the standard is more diffused, but "particles/units/heroes/hero_puck/puck_phase_shift.vpcf" leaves a focused dot which kinda overlaps with the space
	-- ParticleManager:SetParticleControl(phase_particle, 0, self:GetParent():GetAbsOrigin())
	-- self:AddParticle(phase_particle, false, false, -1, false, false)
	
	-- self:GetParent():AddNoDraw()
	
	-- if self:GetParent() ~= self:GetCaster() then
		-- self:StartIntervalThink(FrameTime())
	-- end
-- end

-- function modifier_imba_puck_phase_shift:OnRefresh()
	-- self:OnCreated()
-- end

-- function modifier_imba_puck_phase_shift:OnIntervalThink()
	-- if not IsServer() then return end

	-- if not self:GetAbility() or not self:GetAbility():IsChanneling() then
		-- self:Destroy()
	-- end
-- end

-- function modifier_imba_puck_phase_shift:OnDestroy()
	-- if not IsServer() then return end

	-- self:GetParent():RemoveNoDraw()
-- end

-- function modifier_imba_puck_phase_shift:CheckState()
	-- local state =
	-- {
		-- [MODIFIER_STATE_INVULNERABLE] 	= true,
		-- [MODIFIER_STATE_OUT_OF_GAME]	= true,
		-- [MODIFIER_STATE_UNSELECTABLE]	= true
	-- }
	
	-- if self:GetParent() ~= self:GetCaster() then
		-- state[MODIFIER_STATE_STUNNED]	= true
	-- end
	
	-- return state
-- end

-- ----------------------------------
-- -- PHASE SHIFT HANDLER MODIFIER --
-- ----------------------------------

-- function modifier_imba_puck_phase_shift_handler:IsHidden()	return true end

-- function modifier_imba_puck_phase_shift_handler:DeclareFunctions()
	-- local decFuncs = {MODIFIER_EVENT_ON_ORDER}
	
	-- return decFuncs
-- end

-- function modifier_imba_puck_phase_shift_handler:OnOrder(keys)
	-- if not IsServer() or keys.unit ~= self:GetParent() or keys.order_type ~= DOTA_UNIT_ORDER_CAST_TOGGLE_AUTO or keys.ability ~= self:GetAbility() then return end
	
	-- -- Due to logic order, this is actually reversed
	-- if self:GetAbility():GetAutoCastState() then
		-- self:SetStackCount(0)
	-- else
		-- self:SetStackCount(1)
	-- end
-- end


-- --------------------
-- -- ETHEREAL JAUNT --
-- --------------------

-- function imba_puck_ethereal_jaunt:GetAssociatedPrimaryAbilities()
	-- return "imba_puck_illusory_orb"
-- end

-- -- IMBAfication: Eternal Jaunt
-- -- Putting mana cost on this so it doesn't get (too) out of hand
-- function imba_puck_ethereal_jaunt:GetManaCost(level)
	-- if not self:GetCaster():GetModifierStackCount("modifier_imba_puck_illusory_orb", self:GetCaster()) or self:GetCaster():GetModifierStackCount("modifier_imba_puck_illusory_orb", self:GetCaster()) <= 0 then
		-- return 0
	-- else
		-- return self:GetCaster():GetMaxMana() * self:GetSpecialValueFor("eternal_max_mana_pct") * 0.01
	-- end
-- end

-- function imba_puck_ethereal_jaunt:OnUpgrade()
	-- -- This shouldn't result in bugs because an orb can't even be in flight before this ability is leveled
	-- self:SetActivated(false)

	-- local orb_ability = self:GetCaster():FindAbilityByName(self:GetAssociatedPrimaryAbilities())

	-- if orb_ability then
		-- self.orb_ability	= orb_ability
	-- end
-- end

-- function imba_puck_ethereal_jaunt:OnSpellStart()
	-- if self.orb_ability and self.orb_ability.orbs and #self.orb_ability.orbs >= 1 then
		-- self:GetCaster():EmitSound("Hero_Puck.EtherealJaunt")
	
		-- local jaunt_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_puck/puck_illusory_orb_blink_out.vpcf", PATTACH_ABSORIGIN, self:GetCaster())
		-- ParticleManager:ReleaseParticleIndex(jaunt_particle)
	
		-- FindClearSpaceForUnit(self:GetCaster(), EntIndexToHScript(self.orb_ability.orbs[#self.orb_ability.orbs]):GetAbsOrigin(), true)
		-- ProjectileManager:ProjectileDodge(self:GetCaster())
		
		-- if self:GetCaster():GetName() == "npc_dota_hero_puck" and (not self:GetCaster():GetModifierStackCount("modifier_imba_puck_illusory_orb", self:GetCaster()) or self:GetCaster():GetModifierStackCount("modifier_imba_puck_illusory_orb", self:GetCaster()) <= 0) then
			-- self:GetCaster():EmitSound("puck_puck_ability_orb_0"..RandomInt(1, 3))
		-- end
		
		-- -- IMBAfication: Eternal Jaunt
		-- if self:GetCaster():FindModifierByNameAndCaster("modifier_imba_puck_illusory_orb", self:GetCaster()) then
			-- self:GetCaster():FindModifierByNameAndCaster("modifier_imba_puck_illusory_orb", self:GetCaster()):IncrementStackCount()
		-- end
	-- end
-- end

-- ----------------
-- -- DREAM COIL --
-- ----------------

-- function imba_puck_dream_coil:GetAOERadius()
	-- return self:GetSpecialValueFor("coil_radius")
-- end

-- -- The variable fed into the method is if the ability is recast via the Midsummer's Nightmare IMBAfication
-- function imba_puck_dream_coil:OnSpellStart(refreshDuration)
	-- EmitSoundOnLocationWithCaster(self:GetCursorPosition(), "Hero_Puck.Dream_Coil", self:GetCaster())
	
	-- if not refreshDuration then
		-- if self:GetCaster():GetName() == "npc_dota_hero_puck" then
			-- self:GetCaster():EmitSound("puck_puck_ability_dreamcoil_0"..RandomInt(1, 2))
		-- end
	-- end
	
	-- -- "When upgraded [with Aghanim's scepter], latches on spell immune enemies without stunning them . . ."
	-- local target_flag		= DOTA_UNIT_TARGET_FLAG_NONE
	-- local latch_duration	= self:GetSpecialValueFor("coil_duration")
	
	-- if self:GetCaster():HasScepter() then
		-- target_flag		= DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
		-- latch_duration	= self:GetSpecialValueFor("coil_duration_scepter")
	-- end
	
	-- -- IMBAfication: Midsummer's Nightmare
	-- if refreshDuration then
		-- latch_duration = refreshDuration
	-- end
	
	-- -- Create thinker for...I guess just the particle effects?
	-- local coil_thinker = CreateModifierThinker(
		-- self:GetCaster(),
		-- self,
		-- "modifier_imba_puck_dream_coil_thinker",
		-- {duration = latch_duration},
		-- self:GetCursorPosition(),
		-- self:GetCaster():GetTeamNumber(),
		-- false
	-- )
	
	-- local target_type = DOTA_UNIT_TARGET_HERO
	
	-- if self:GetCaster():HasTalent("special_bonus_imba_puck_dream_coil_targets") then
		-- target_type = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
	-- end
	
	-- local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCursorPosition(), nil, self:GetSpecialValueFor("coil_radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, target_type, target_flag, FIND_ANY_ORDER, false)

	-- for _, enemy in pairs(enemies) do
		-- local stun_modifier = enemy:AddNewModifier(self:GetCaster(), self, "modifier_stunned", {duration = self:GetSpecialValueFor("stun_duration")}):SetDuration(self:GetSpecialValueFor("stun_duration") * (1 - enemy:GetStatusResistance()), true)
	
		-- local coil_modifier = enemy:AddNewModifier(self:GetCaster(), self, "modifier_imba_puck_dream_coil", 
		-- {
			-- duration		= latch_duration,
			-- coil_thinker	= coil_thinker:entindex()
		-- })
		
		-- if not refreshDuration then			
			-- coil_modifier:SetDuration(latch_duration * (1 - enemy:GetStatusResistance()), true)
		-- end
		
		-- -- IMBAfication: Visionary
		-- for index = 0, 23 do
			-- local ability = enemy:GetAbilityByIndex(index)
			
			-- if ability and ability:GetAbilityType() == ABILITY_TYPE_ULTIMATE then
				-- self:GetCaster():AddNewModifier(self:GetCaster(), ability, "modifier_imba_puck_dream_coil_visionary", {duration	= latch_duration})
			-- end
		-- end
	-- end
-- end

-- function imba_puck_dream_coil:OnProjectileHit_ExtraData(target, location, data)
	-- if not IsServer() then return end
	
	-- if target then
		-- EmitSoundOnLocationWithCaster(target:GetAbsOrigin(), "Hero_Puck.ProjectileImpact", self:GetCaster())
	
		-- self:GetCaster():PerformAttack(target, false, true, true, false, false, false, false)
	-- end
-- end

-- -------------------------
-- -- DREAM COIL MODIFIER --
-- -------------------------

-- function modifier_imba_puck_dream_coil:IsPurgable()		return not self:GetCaster():HasScepter() end
-- function modifier_imba_puck_dream_coil:GetAttributes()	return MODIFIER_ATTRIBUTE_MULTIPLE end

-- function modifier_imba_puck_dream_coil:OnCreated(params)
	-- self.coil_break_radius			= self:GetAbility():GetSpecialValueFor("coil_break_radius")
	-- self.coil_stun_duration			= self:GetAbility():GetSpecialValueFor("coil_stun_duration")
	-- self.coil_break_damage			= self:GetAbility():GetSpecialValueFor("coil_break_damage")
	-- self.coil_break_damage_scepter	= self:GetAbility():GetSpecialValueFor("coil_break_damage_scepter")
	-- self.coil_stun_duration_scepter	= self:GetAbility():GetSpecialValueFor("coil_stun_duration_scepter")

	-- self.rapid_fire_interval		= self:GetAbility():GetSpecialValueFor("rapid_fire_interval")
	-- self.rapid_fire_max_distance	= self:GetAbility():GetSpecialValueFor("rapid_fire_max_distance")

	-- if not IsServer() then return end
	
	-- self.ability_damage_type		= self:GetAbility():GetAbilityDamageType()
	-- self.coil_thinker				= EntIndexToHScript(params.coil_thinker)
	-- self.coil_thinker_location		= self.coil_thinker:GetAbsOrigin()

	-- local coil_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_puck/puck_dreamcoil_tether.vpcf", PATTACH_ABSORIGIN, self.coil_thinker)
	-- ParticleManager:SetParticleControlEnt(coil_particle, 0, self.coil_thinker, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self.coil_thinker_location, true)
	-- ParticleManager:SetParticleControlEnt(coil_particle, 1, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
	-- self:AddParticle(coil_particle, false, false, -1, false, false)
	
	-- self.interval 	= 0.1
	-- self.counter	= 0
	
	-- self:StartIntervalThink(self.interval)
-- end

-- -- Supposedly should not use MODIFIER_EVENT_ON_UNIT_MOVED due to potentially massive lag, so gonna just use a 0.1s IntervalThinker
-- -- I guess conveniently this could also be used for Rapid Fire checking
-- function modifier_imba_puck_dream_coil:OnIntervalThink()
	-- if not IsServer() then return end
	
	-- self.counter = self.counter + self.interval
	
	-- if self.counter >= self.rapid_fire_interval and self:GetAbility() then
		-- self.counter = 0
		
		-- local direction	= (self:GetParent():GetAbsOrigin() - self.coil_thinker_location):Normalized()
		
		-- if (self:GetCaster():GetAbsOrigin() - self.coil_thinker_location):Length2D() <= self.rapid_fire_max_distance then
			-- EmitSoundOnLocationWithCaster(self.coil_thinker_location, "Hero_Puck.Attack", self:GetCaster())
			
			-- local projectile =
			-- {
				-- Target 				= self:GetParent(),
				-- Source 				= self.coil_thinker,
				-- Ability 			= self:GetAbility(),
				-- EffectName 			= self:GetCaster():GetRangedProjectileName() or "particles/units/heroes/hero_puck/puck_base_attack.vpcf",
				-- iMoveSpeed			= self:GetCaster():GetProjectileSpeed() or 900,
				-- -- vSourceLoc 			= self.coil_thinker_location,
				-- bDrawsOnMinimap 	= false,
				-- bDodgeable 			= true,
				-- bIsAttack 			= true, -- Does this even do anything
				-- bVisibleToEnemies 	= true,
				-- bReplaceExisting 	= false,
				-- flExpireTime 		= GameRules:GetGameTime() + 10.0,
				-- bProvidesVision 	= false,
			-- }
			
			-- ProjectileManager:CreateTrackingProjectile(projectile)
		-- end
	-- end
	
	-- if (self:GetParent():GetAbsOrigin() - self.coil_thinker_location):Length2D() >= self.coil_break_radius then
		-- self:GetParent():EmitSound("Hero_Puck.Dream_Coil_Snap")
		
		-- -- Check for scepter 
		-- local stun_duration	= self.coil_stun_duration
		-- local break_damage	= self.coil_break_damage
		
		-- if self:GetCaster():HasScepter() then
			-- stun_duration	= self.coil_stun_duration_scepter
			-- break_damage	= self.coil_break_damage_scepter
		-- end

		-- local damageTable = {
			-- victim 			= self:GetParent(),
			-- damage 			= break_damage,
			-- damage_type		= self.ability_damage_type,
			-- damage_flags 	= DOTA_DAMAGE_FLAG_NONE,
			-- attacker 		= self:GetCaster(),
			-- ability 		= self:GetAbility()
		-- }

		-- ApplyDamage(damageTable)
		
		-- -- IMBAfication: Midsummer's Nightmare
		-- if self:GetAbility() then
			-- self:GetCaster():SetCursorPosition(self:GetParent():GetAbsOrigin())
			-- self:GetAbility():OnSpellStart(self:GetRemainingTime() + (stun_duration * (1 - self:GetParent():GetStatusResistance())))
		-- end
		
		-- -- Putting the break stun modifier after the IMBAfication because it was getting overwritten by the basic lower duration stun
		-- local stun_modifier = self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_stunned", {duration = stun_duration}):SetDuration(stun_duration * (1 - self:GetParent():GetStatusResistance()), true)
		
		-- self:Destroy()
	-- end
-- end

-- function modifier_imba_puck_dream_coil:CheckState()
	-- local state = {[MODIFIER_STATE_TETHERED] = true}
	
	-- return state
-- end

-- ---------------------------------
-- -- DREAM COIL THINKER MODIFIER --
-- ---------------------------------

-- function modifier_imba_puck_dream_coil_thinker:GetEffectName()
	-- return "particles/units/heroes/hero_puck/puck_dreamcoil.vpcf"
-- end

-- -- function modifier_imba_puck_dream_coil_thinker:OnCreated()
	-- -- if not IsServer() then return end
-- -- end

-- function modifier_imba_puck_dream_coil_thinker:OnDestroy()
	-- if not IsServer() then return end
	
	-- self:GetParent():RemoveSelf()
-- end

-- -----------------------------------
-- -- DREAM COIL VISIONARY MODIFIER --
-- -----------------------------------

-- function modifier_imba_puck_dream_coil_visionary:IsDebuff()			return false end
-- function modifier_imba_puck_dream_coil_visionary:GetAttributes()	return MODIFIER_ATTRIBUTE_MULTIPLE end

-- function modifier_imba_puck_dream_coil_visionary:OnCreated()
	-- if not IsServer() then return end
	
	-- self:SetStackCount(math.ceil(self:GetAbility():GetCooldownTimeRemaining()))
	-- self:StartIntervalThink(0.1)
-- end

-- function modifier_imba_puck_dream_coil_visionary:OnIntervalThink()
	-- if self:GetAbility() then
		-- self:SetStackCount(math.ceil(self:GetAbility():GetCooldownTimeRemaining()))
	-- else
		-- self:StartIntervalThink(-1)
		-- self:Destroy()
	-- end
-- end

-- ---------------------
-- -- TALENT HANDLERS --
-- ---------------------

-- LinkLuaModifier("modifier_special_bonus_imba_puck_waning_rift_cooldown", "components/abilities/heroes/hero_puck", LUA_MODIFIER_MOTION_NONE)

-- modifier_special_bonus_imba_puck_waning_rift_cooldown	= class({})

-- function modifier_special_bonus_imba_puck_waning_rift_cooldown:IsHidden() 		return true end
-- function modifier_special_bonus_imba_puck_waning_rift_cooldown:IsPurgable() 	return false end
-- function modifier_special_bonus_imba_puck_waning_rift_cooldown:RemoveOnDeath() 	return false end

-- function imba_puck_waning_rift:OnOwnerSpawned()
	-- if not IsServer() then return end

	-- if self:GetCaster():HasTalent("special_bonus_imba_puck_waning_rift_cooldown") and not self:GetCaster():HasModifier("modifier_special_bonus_imba_puck_waning_rift_cooldown") then
		-- self:GetCaster():AddNewModifier(self:GetCaster(), self:GetCaster():FindAbilityByName("special_bonus_imba_puck_waning_rift_cooldown"), "modifier_special_bonus_imba_puck_waning_rift_cooldown", {})
	-- end
-- end
