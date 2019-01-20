-- utils
local function CalculateBloodstoneRespawnReduction(hero, respawn_time)
	if hero and respawn_time then
		if hero.bloodstone_respawn_reduction and (respawn_time > 0) then
			return hero.bloodstone_respawn_reduction
		end
	end

	return 0
end

local function CalculateReaperScytheRespawnReduction(killer, hero, respawn_time)
	if hero and respawn_time then
		if hero:HasModifier("modifier_imba_reapers_scythe_respawn") then
			if killer:HasAbility("imba_necrolyte_reapers_scythe") then
				local reaper_scythe = killer:FindAbilityByName("imba_necrolyte_reapers_scythe"):GetSpecialValueFor("respawn_increase")
				-- Sometimes the killer is not actually Necrophos due to the respawn modifier lingering on a target, which makes reaper_scythe nil and causes massive problems
	--			print("Killed by Reaper Scythe!", reaper_scythe, respawn_time + reaper_scythe)
				if not reaper_scythe then
					reaper_scythe = 0
				end

				return reaper_scythe
			end
		end
	end

	return 0
end

local function CalculateSkeletonKingRespawnReduction(hero, respawn_time)
	if hero and respawn_time then
		if hero:HasModifier("modifier_imba_reincarnation") then
			if hero:FindModifierByName("modifier_imba_reincarnation").passive_respawn_haste then
				return hero:FindModifierByName("modifier_imba_reincarnation").passive_respawn_haste
			end
		end
	end

	return 0
end

ListenToGameEvent('entity_killed', function(keys)
	-- The Unit that was killed
	local killed_unit = EntIndexToHScript(keys.entindex_killed)
	if not killed_unit then return end

	if not killed_unit:IsRealHero() then
		-- Run non-hero scripts here

		return
	end

	local hero = killed_unit

	-- The Killing entity
	local killer = nil

	if keys.entindex_attacker then
		killer = EntIndexToHScript(keys.entindex_attacker)
	end

	-- undying reincarnation talent fix
	if hero:HasModifier("modifier_special_bonus_reincarnation") then
		if not hero.undying_respawn_timer or hero.undying_respawn_timer == 0 then
--			print(hero:FindModifierByName("modifier_special_bonus_reincarnation"):GetDuration())
			hero:SetTimeUntilRespawn(IMBA_REINCARNATION_TIME)
			hero.undying_respawn_timer = 200
			return
		end
	end

	if hero:IsImbaReincarnating() then
		hero:SetTimeUntilRespawn(IMBA_REINCARNATION_TIME)
		return
	else
		local respawn_time = 0

		-- Calculate base respawn timer, capped at IMBA_MAX_RESPAWN_TIME seconds
		if hero:GetLevel() > 25 then
			respawn_time = IMBA_MAX_RESPAWN_TIME
		else
			respawn_time = math.min(hero:GetRespawnTime() / 100 * IMBA_RESPAWN_TIME_PCT, IMBA_MAX_RESPAWN_TIME)
		end

		-- Increase respawn timer if dead by Reaper's Scythe
--		print("Reaper Scythe respawn time increase:", CalculateReaperScytheRespawnReduction(killer, hero, respawn_time))
		respawn_time = respawn_time + CalculateReaperScytheRespawnReduction(killer, hero, respawn_time)

		-- Fetch decreased respawn timer due to Bloodstone charges
--		print("Bloodstone charges respawn time decrease:", CalculateBloodstoneRespawnReduction(hero, respawn_time))
		respawn_time = math.max(respawn_time - CalculateBloodstoneRespawnReduction(hero, respawn_time), 1)

		-- Adjust respawn time for Wraith King's Reincarnation Passive Respawn Reduction
--		print("Wraith King respawn time decrease:", CalculateSkeletonKingRespawnReduction(hero, respawn_time))
		respawn_time = math.max(respawn_time - CalculateSkeletonKingRespawnReduction(hero, respawn_time), 1)

		-- this fail-safe is probably not necessary, but i don't wanna hear about that high respawn time bug anymore. Ever.
		if respawn_time == nil or not respawn_time then
--			print("Something terrible has happened...set respawn timer to something reasonable.")
			respawn_time = math.min(hero:GetRespawnTime() / 100 * IMBA_RESPAWN_TIME_PCT, 60)

			return
		else
--			print("Set time until respawn for unit " .. tostring(hero:GetUnitName()) .. " to " .. tostring(respawn_time) .. " seconds")
			hero:SetTimeUntilRespawn(respawn_time)

			return
		end
	end
end, nil)