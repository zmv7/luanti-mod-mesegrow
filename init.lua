for i=1,9 do
	local w = 0.1*i/2
	local box = {
		type = "fixed",
		fixed = {-w, -0.5, -w, w, 0.1*(i-4), w}
	}
	local light_source = math.ceil(i/2)
	core.register_node("mesegrow:crystal_"..i,{
		groups = {cracky=2,not_in_creative_inventory=1,attached_node=3},
		drop = (i == 9 and "default:mese_crystal" or "default:mese_crystal_fragment "..i),
		description = "Growing mese crystal "..i,
		light_source = light_source,
		paramtype = "light",
		drawtype = "plantlike",
		selection_box = box,
		node_box = box,
		tiles = {"mesegrow_"..i..".png"},
		on_timer = function(pos, elapsed)
			local light = core.get_node_light(pos)
			local timer = core.get_node_timer(pos)
			if light > light_source then
				timer:start(120)
				return
			end
			if i < 9 then
				core.swap_node(pos, {name = "mesegrow:crystal_"..i+1})
				timer:start(math.random(720,1000)+i*50)
			end
		end,
	})
end
core.override_item("default:mese_crystal_fragment",{
	on_place = function(itemstack, placer, pointed_thing)
		local under = pointed_thing.under
		local above = pointed_thing.above
		if not (under.x == above.x and under.z == above.z and under.y == above.y -1) then
			return
		end
		local name = placer:get_player_name()
		if core.is_protected(above, name) then
			core.record_protection_violation(above, name)
			return
		end
		local node = core.get_node_or_nil(under)
		if not node or node.name ~= "mesegrow:mese_gravel" then return end
		core.place_node(above, {name = "mesegrow:crystal_1"}, placer)
		local newnode = core.get_node_or_nil(above)
		if newnode and newnode.name == "mesegrow:crystal_1" then
			core.get_node_timer(above):start(math.random(720,1000))
			if not core.is_creative_enabled(name) then
				itemstack:take_item()
				return itemstack
			end
		end
	end,
})
core.register_node("mesegrow:mese_gravel", {
	description = "Mese gravel",
	tiles = {"default_gravel.png^[colorize:#000:100^mesegrow_gravel_mask.png"},
	groups = {crumbly = 2, falling_node = 1},
	sounds = default.node_sound_gravel_defaults()
})
minetest.register_craft({
	output = "mesegrow:mese_gravel",
	recipe = {
		{"default:mese_crystal_fragment", "bucket:bucket_water", "default:mese_crystal_fragment"},
		{"default:mese_crystal_fragment", "default:gravel", "default:mese_crystal_fragment"},
		{"default:mese_crystal_fragment", "default:mese_crystal_fragment", "default:mese_crystal_fragment"}
	},
	replacements = {{"bucket:bucket_water", "bucket:bucket_empty"}}
})
