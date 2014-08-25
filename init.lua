minetest.register_node("mini_sun:glow", {
	tiles = { "mini_sun_glow.png" },
	--drawtype = "plantlike",
	drawtype = "airlike",
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
	
		local pmod = (pos.x + pos.y + pos.z) % 2 

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
						if (x + y + z) % 2 == pmod then -- 3d checkerboard pattern
							if grounded({x=x, y=y, z=z}) then -- against lightable surfaces
								data[vi] = c_sun
							end
						end
					end
				end
			end
		end
		manip:set_data(data)
		manip:write_to_map()
		manip:update_map()

		local glow_nodes = minetest.find_nodes_in_area(minp, maxp, "mini_sun:glow")
		for key, npos in pairs(glow_nodes) do
			if (npos.x + npos.y + npos.z) % 2 == pmod then -- 3d checkerboard pattern
				local meta = minetest.get_meta(npos)
				
				local src_str = meta:get_string("sources")
				local src_tbl = minetest.deserialize(src_str)
				if not src_tbl then src_tbl = {} end
				
				src_tbl[minetest.pos_to_string(pos)] = true
				src_str = minetest.serialize(src_tbl)

				meta:set_string("sources", src_str)
			end
		end
	end,
	on_destruct = function(pos)
		local dist = 6
		local minp = { x=pos.x-dist, y=pos.y-dist, z=pos.z-dist }
		local maxp = { x=pos.x+dist, y=pos.y+dist, z=pos.z+dist }
		
		local positions = {}

		local pmod = (pos.x + pos.y + pos.z) % 2 
		
		local glow_nodes = minetest.find_nodes_in_area(minp, maxp, "mini_sun:glow")
		for key, npos in pairs(glow_nodes) do
			if (npos.x + npos.y + npos.z) % 2 == pmod then -- 3d checkerboard pattern
				local meta = minetest.get_meta(npos)

				local src_str = meta:get_string("sources")
				local src_tbl = minetest.deserialize(src_str)
				if not src_tbl then src_tbl = {} end

				src_tbl[minetest.pos_to_string(pos)] = nil
				if next(src_tbl) == nil then
					table.insert(positions, npos)
				end
				src_str = minetest.serialize(src_tbl)
				meta:set_string("sources", src_str)
			end
		end

		dist = 12
		minp = { x=pos.x-dist, y=pos.y-dist, z=pos.z-dist }
		maxp = { x=pos.x+dist, y=pos.y+dist, z=pos.z+dist }

		local c_air = minetest.get_content_id("air")
		local c_sun = minetest.get_content_id("mini_sun:glow")
		 
		local manip = minetest.get_voxel_manip()
		local emin, emax = manip:read_from_map(minp, maxp)
		local area = VoxelArea:new({MinEdge=emin, MaxEdge=emax})
		local data = manip:get_data()
		for i, npos in ipairs(positions) do
			local vi = area:indexp(npos)
			if data[vi] == c_sun then
				data[vi] = c_air
			end
		end
		manip:set_data(data)
		manip:write_to_map()
		manip:update_map()
	end,
})

minetest.register_on_dignode(function(pos, oldnode, digger)
		local dist = 6
		local minp = { x=pos.x-dist, y=pos.y-dist, z=pos.z-dist }
		local maxp = { x=pos.x+dist, y=pos.y+dist, z=pos.z+dist }

		local pmod = (pos.x + pos.y + pos.z) % 2
		local lit = false

		local sun_nodes = minetest.find_nodes_in_area(minp, maxp, "mini_sun:source")
		for key, npos in pairs(sun_nodes) do
			if (npos.x + npos.y + npos.z) % 2 == pmod then -- 3d checkerboard pattern
				if not lit and grounded(pos) then -- against lightable surfaces
					minetest.set_node(pos, {name = "mini_sun:glow"})
					lit = true
				end
				if lit then
					local meta = minetest.get_meta(pos)
					
					local src_str = meta:get_string("sources")
					local src_tbl = minetest.deserialize(src_str)
					if not src_tbl then src_tbl = {} end
					
					src_tbl[minetest.pos_to_string(npos)] = true
					src_str = minetest.serialize(src_tbl)

					meta:set_string("sources", src_str)	
				end
			end
		end
end)

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

minetest.register_chatcommand("ms_clear", {
	func = function(name, param)
		local pos = minetest.get_player_by_name(name):getpos()

		dist = 12
		minp = { x=pos.x-dist, y=pos.y-dist, z=pos.z-dist }
		maxp = { x=pos.x+dist, y=pos.y+dist, z=pos.z+dist }

		for x = minp.x, maxp.x do
			for y = minp.y, maxp.y do
				for z = minp.z, maxp.z do
					minetest.get_meta(pos):set_string("sources", nil)	
				end
			end
		end

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
	end
})
