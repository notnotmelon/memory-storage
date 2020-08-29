data:extend{
	{
		type = 'item-with-tags',
		name = 'storage-data',
		icon = '__deep-storage-unit__/graphics/icon/storage-data.png',
		icon_size = 32,
		stack_size = 1,
		flags = {'not-stackable'},
		order = 'a[items]-d[deep-storage-unit]-b[storage-data]',
		subgroup = 'storage'
	},
	{
		type = 'item',
		name = 'deep-storage-unit',
		icon = '__deep-storage-unit__/graphics/icon/deep-storage-unit.png',
		icon_size = 64,
		icon_mipmaps = 4,
		stack_size = 10,
		place_result = 'deep-storage-unit',
		order = 'a[items]-d[deep-storage-unit]-a[deep-storage-unit]',
		subgroup = 'storage'
	},
	{
		type = 'container',
		icon = '__deep-storage-unit__/graphics/icon/deep-storage-unit.png',
		icon_mipmaps = 4,
		icon_size = 64,
		name = 'deep-storage-unit',
		inventory_size = 120,
		picture = {layers = {
			{
				filename = '__deep-storage-unit__/graphics/entity/deep-storage-unit.png',
				height = 218,
				priority = 'high',
				width = 200,
				shift = {0, -0.15},
				hr_version = {
					filename = '__deep-storage-unit__/graphics/entity/hr-deep-storage-unit.png',
					height = 436,
					priority = 'high',
					width = 400,
					scale = 0.45,
					shift = {0, -0.3}
				},
				scale = 0.9
			},
			{
				draw_as_shadow = true,
				filename = '__deep-storage-unit__/graphics/entity/shadow.png',
				height = 146,
				priority = 'high',
				width = 100,
				shift = {2.78, 0.7},
				scale = 0.9
			}
		}},
		max_health = 3000,
		minable = {mining_time = 1, result = 'deep-storage-unit'},
		corpse = 'big-remnants',
		close_sound = {
			filename = '__base__/sound/metallic-chest-close.ogg',
			volume = 0.9
		},
		open_sound = {
			filename = '__base__/sound/metallic-chest-open.ogg',
			volume = 0.6
		},
		selection_box = {{-3, -3}, {3, 3}},
		collision_box = {{-2.7, -2.7}, {2.7, 2.7}},
		flags = {'placeable-neutral', 'player-creation'},
		enable_inventory_bar = false
	},
	{
		type = 'recipe',
		name = 'deep-storage-unit',
		ingredients = {
			{'advanced-circuit', 45},
			{'energy-shield-equipment', 4},
			{'steel-plate', 45},
			{'productivity-module', 16}
		},
		result = 'deep-storage-unit',
		enabled = false
	},
	{
		type = 'technology',
		name = 'deep-storage-unit',
		icon = '__deep-storage-unit__/graphics/technology/deep-storage-unit.png',
		icon_size = 128,
		effects = {{
			recipe = 'deep-storage-unit',
			type = 'unlock-recipe'
		}},
		prerequisites = {
			'energy-shield-equipment',
			'productivity-module',
			'logistics-2'
		},
		unit = {
			count = 200,
			ingredients = {
				{'automation-science-pack', 1},
				{'logistic-science-pack', 1},
				{'chemical-science-pack', 1},
			},
			time = 30,
		}
	},
	{
		type = 'electric-energy-interface',
		localised_name = {'entity-name.deep-storage-unit'},
		localised_description = {'entity-description.deep-storage-unit'},
		energy_source = {
			type = 'electric',
			usage_priority = 'secondary-input',
			buffer_capacity = '1J'
		},
		energy_usage = '1W',
		order = 'z',
		collision_box = {{-2.7, -2.7}, {2.7, 2.7}},
		icon = '__deep-storage-unit__/graphics/icon/deep-storage-unit.png',
		icon_size = 64,
		icon_mipmaps = 4,
		collision_mask = {},
		selectable_in_game = false,
		remove_decoratives = 'false',
		name = 'deep-storage-unit-powersource',
		flags = {'placeable-player', 'placeable-neutral', 'hidden', 'not-selectable-in-game', 'not-blueprintable', 'not-deconstructable', 'not-flammable', 'not-upgradable'}
	}
}