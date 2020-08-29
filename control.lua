math.round = function(x) return x + 0.5 - (x + 0.5) % 1 end

local function compactify(n)
	local suffix = 1
	while n > 1000 do
		n = math.floor(n / 100) / 10
		suffix = suffix + 1
	end
	return {'big-numbers.' .. suffix, n}
end

local function setup()
	global.units = global.units or {}
end

script.on_init(setup)
script.on_configuration_changed(setup)

local function on_created(event)
	local entity = event.created_entity or event.entity
	global.units[entity.unit_number] = {
		entity = entity,
		count = 0,
		powersource = entity.surface.create_entity{
			name = 'deep-storage-unit-powersource',
			position = entity.position,
			force = entity.force
		},
		inventory = entity.get_inventory(defines.inventory.chest)
	}
end

local filter = {{filter = 'type', type = 'container'}, {filter = 'name', name = 'deep-storage-unit', mode = 'and'}}
script.on_event(defines.events.on_built_entity, on_created, filter)
script.on_event(defines.events.on_robot_built_entity, on_created, filter)
script.on_event(defines.events.on_entity_cloned, on_created, filter)
script.on_event(defines.events.script_raised_built, on_created, filter)
script.on_event(defines.events.script_raised_revive, on_created, filter)

local function on_destroyed(event)
	local entity = event.entity
	local unit_data = global.units[entity.unit_number]
	local buffer = event.buffer
	local item = unit_data.item
	local count = unit_data.count
	
	if buffer and item and count ~= 0 then
		buffer.insert{name = 'storage-data', count = 1}
		local data = buffer.find_item_stack('storage-data')
		data.tags = {name = item, count = count}
		data.custom_description = {'item-description.storage-data-active', compactify(count), item}
	end
	
	unit_data.powersource.destroy()
	global.units[entity.unit_number] = nil
end

script.on_event(defines.events.on_player_mined_entity, on_destroyed, filter)
script.on_event(defines.events.on_robot_mined_entity, on_destroyed, filter)
script.on_event(defines.events.on_entity_died, on_destroyed, filter)
script.on_event(defines.events.script_raised_destroy, on_destroyed, filter)

script.on_nth_tick(60 * 4, function()
	for _, unit_data in pairs(global.units) do
		local entity = unit_data.entity
		local powersource = unit_data.powersource
		
		if entity.valid == false or powersource.valid == false then
			error('Another mod has deleted a storage unit without telling me :(', 0)
		end
		
		if powersource.electric_buffer_size == powersource.energy then
			local item = unit_data.item
			local inventory = unit_data.inventory
			
			if item == nil then
				for i = 1, #inventory do
					local stack = inventory[i]
					if stack.valid_for_read then
						local name = stack.name
						if name == 'storage-data' and stack.tags.name and stack.tags.count then
							local tags = stack.tags
							item = tags.name
							unit_data.count = tags.count
							stack.clear()
						else
							item = name
							unit_data.count = 0
						end
						unit_data.item = item
						unit_data.stack_size = game.item_prototypes[item].stack_size
						unit_data.comfortable = unit_data.stack_size * 60
						break
					end
				end
			end
			
			if item then
				local changed = false
			
				for i = 1, #inventory do
					local stack = inventory[i]
					if stack.valid_for_read and stack.name == 'storage-data' then
						local tags = stack.tags
						if tags.name == item then
							unit_data.count = unit_data.count + tags.count
							stack.clear()
						end
					end
					changed = true
				end
			
				local comfortable = unit_data.comfortable
				local inventory_count = inventory.get_item_count(item)
				
				if inventory_count > comfortable then
					local amount_removed = inventory.remove{name = item, count = inventory_count - comfortable}
					unit_data.count = unit_data.count + amount_removed
					inventory_count = inventory_count - amount_removed
					changed = true
				elseif inventory_count < comfortable then
					local to_add = comfortable - inventory_count
					if unit_data.count < to_add then
						to_add = unit_data.count
					end
					if to_add ~= 0 then
						local amount_added = inventory.insert{name = item, count = to_add}
						unit_data.count = unit_data.count - amount_added
						inventory_count = inventory_count + amount_added
					end
					changed = true
				end
				
				if changed then
					if unit_data.text then
						rendering.set_text(unit_data.text, compactify(unit_data.count + inventory_count))
					else
						unit_data.text = rendering.draw_text
						{
							surface = entity.surface,
							target = entity,
							text = compactify(unit_data.count + inventory_count),
							alignment = 'center',
							scale = 1.5,
							only_in_alt_mode = true,
							color = {r = 1, g = 1, b = 1}
						}
					end
					
					inventory.sort_and_merge()
					
					local power_usage = 1 + math.ceil(math.sqrt(unit_data.count / unit_data.stack_size)) * 100
					powersource.power_usage = power_usage
					powersource.electric_buffer_size = power_usage
					
					if inventory_count == 0 then
						unit_data.alert = true
						for _, player in pairs(game.players) do
							if player.force == entity.force then
								player.add_custom_alert(entity, {type = 'item', name = 'deep-storage-unit'}, {'deep-storage-unit-empty', item}, true)
							end
						end
					elseif unit_data.alert then
						unit_data.alert = nil
						for _, player in pairs(game.players) do
							if player.force == entity.force then
								player.remove_alert{entity = entity}
							end
						end
					end
				end
			end
		end
	end
end)

remote.add_interface('memory-unit', {['give-storage-data'] = function(item, count, player)
	player = player or game.player
	if player == nil then error('You need to pass a player since you are not using this from the console') end
	
	if item == nil then player.print{'command-output.bad-args'} end
	if not game.item_prototypes[item] then player.print{'command-output.bad-item', item} end
	if count == nil then player.print{'command-output.bad-args'} end
	if count <= 0 then player.print{'command-output.bad-count'} end
	
	local inventory = player.get_main_inventory()
	inventory.insert{name = 'storage-data', count = 1}
	for i = 1, #inventory do
		local stack = inventory[i]
		if stack.valid_for_read and stack.name == 'storage-data' then
			local tags = stack.tags
			if next(tags) == nil then
				stack.tags = {name = item, count = count}
				stack.custom_description = {'item-description.storage-data-active', compactify(count), item}
			end
		end
	end
end})