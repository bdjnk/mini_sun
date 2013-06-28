minetest.register_node("mini_sun:glow", {
	--tiles = { "mini_sun_glow.png" },
	--drawtype = "allfaces",
	drawtype = "airlike",
	walkable = false,
	pointable = false,
	diggable = true,
	climbable = false,
	buildable_to = true,
	paramtype = light,
	light_source = 14,
	sounds = default.node_sound_glass_defaults(),
})

minetest.register_craft({
	output = '"mini_sun:source" 2',
	recipe = {
		{'default:glass', 'default:glass', 'default:glass'},
		{'default:glass', 'default:torch', 'default:glass'},
		{'default:glass', 'default:glass', 'default:glass'},
	}
})

minetest.register_node("mini_sun:source", {
	tiles = { "mini_sun.png" },
	drawtype = "glasslike",
	groups = { cracky=3, oddly_breakable_by_hand=3 },
	sounds = default.node_sound_glass_defaults(),
	drop = "mini_sun:source",
	light_source = 14,
	paramtype = light,
	after_place_node = function(pos, placer)
		minetest.get_node_timer(pos):start(1.1)
	end,
	on_destruct = function(pos)
		minetest.get_node_timer(pos):stop()
	end,
	after_destruct = function(pos, oldnode)
		local dist = 6
		local minp = { x=pos.x-dist, y=pos.y-dist, z=pos.z-dist }
		local maxp = { x=pos.x+dist, y=pos.y+dist, z=pos.z+dist }
		local glow_nodes = minetest.find_nodes_in_area(minp, maxp, "mini_sun:glow")
		for key, npos in pairs(glow_nodes) do
			minetest.remove_node(npos)
			end
	end,
	on_timer = function(pos, elapsed)
		local dist = 6
		local pmod = (pos.x + pos.y + pos.z) %2 
		local minp = { x=pos.x-dist, y=pos.y-dist, z=pos.z-dist }
		local maxp = { x=pos.x+dist, y=pos.y+dist, z=pos.z+dist }
		local air_nodes = minetest.find_nodes_in_area(minp, maxp, "air")
		for key, npos in pairs(air_nodes) do
			if (npos.x + npos.y + npos.z) %2 == pmod then -- 3d checkerboard pattern
				if grounded(npos) then                      -- against lightable surfaces
					minetest.add_node(npos, {name = "mini_sun:glow"})
				end
			end
		end
		return true
	end,
})

grounded = function(pos)
	-- checks all nodes touching the edges and corners (but not faces) of the given pos
	for nx = -1, 1, 2 do
		for ny = -1, 1, 2 do
			for nz = -1, 1, 2 do
				local npos = { x=pos.x+nx, y=pos.y+ny, z=pos.z+nz }
				local name = minetest.get_node(npos).name
				if minetest.registered_nodes[name].walkable and name ~= "mini_sun:source" then
					return true
				end
			end
		end
  end
	return false
end
