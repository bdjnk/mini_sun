minetest.register_node("mini_sun:glow", {
	tiles = { "mini_sun_glow.png" },
	drawtype = "plantlike",
	--drawtype = "airlike",
	walkable = false,
	pointable = false,
	diggable = false,
	climbable = false,
	buildable_to = true,
	sunlight_propagates = true,
	paramtype = "light",
	light_source = 14,
})

minetest.register_craft({
	output = '"mini_sun:source" 1',
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
	paramtype = "light",
	on_construct = function(pos)
		local dist = 6
		local minp = { x=pos.x-dist, y=pos.y-dist, z=pos.z-dist }
		local maxp = { x=pos.x+dist, y=pos.y+dist, z=pos.z+dist }
		
		local c_air = minetest.get_content_id("air")
		local c_sun = minetest.get_content_id("mini_sun:glow")
		 
		local manip = minetest.get_voxel_manip()
		local emin, emax = manip:read_from_map(minp, maxp)
		local area = VoxelArea:new({MinEdge=emin, MaxEdge=emax})
		local data = manip:get_data()
		for x = minp.x, maxp.x do
			for y = minp.y, maxp.y do
				for z = minp.z, maxp.z do
					local vi = area:index(x, y, z)
					if data[vi] == c_air then
						--if (x + y + z) %2 == pmod then -- 3d checkerboard pattern
							--if grounded({x=x, y=y, z=z}) then -- against lightable surfaces
								data[vi] = c_sun
							--end
						--end
					end
				end
			end
		end
		manip:set_data(data)
		manip:write_to_map()
		manip:update_map()

	end,
	on_destruct = function(pos)
		local dist = 6
		local minp = { x=pos.x-dist, y=pos.y-dist, z=pos.z-dist }
		local maxp = { x=pos.x+dist, y=pos.y+dist, z=pos.z+dist }
		
		local c_air = minetest.get_content_id("air")
		local c_sun = minetest.get_content_id("mini_sun:glow")
		 
		local manip = minetest.get_voxel_manip()
		local emin, emax = manip:read_from_map(minp, maxp)
		local area = VoxelArea:new({MinEdge=emin, MaxEdge=emax})
		local data = manip:get_data()
		for x = minp.x, maxp.x do
			for y = minp.y, maxp.y do
				for z = minp.z, maxp.z do
					local vi = area:index(x, y, z)
					if data[vi] == c_sun then
						data[vi] = c_air
					end
				end
			end
		end
		manip:set_data(data)
		manip:write_to_map()
		manip:update_map()
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
