local flammable_types = {}

-- Initialize the local flammable_types table
local init_flammable_types = function()
  if not flammable_types or next(flammable_types) == nil then
    flammable_types = {
      ["crude-oil"] = true,
      ["heavy-oil"] = true,
      ["light-oil"] = true,
      ["lubricant"] = false,
      ["gas-hydrogen"] = true,
      ["gas-methane"] = true,
      ["gas-ethane"] = true,
      ["gas-butane"] = true,
      ["gas-propene"] = true,
      ["liquid-naphtha"] = true,
      ["liquid-mineral-oil"] = true,
      ["liquid-fuel-oil"] = true,
      ["gas-methanol"] = true,
      ["gas-ethylene"] = true,
      ["gas-benzene"] = true,
      ["gas-synthesis"] = true,
      ["gas-butadiene"] = true,
      ["gas-phenol"] = true,
      ["gas-ethylbenzene"] = true,
      ["gas-styrene"] = true,
      ["gas-formaldehyde"] = true,
      ["gas-polyethylene"] = true,
      ["gas-glycerol"] = true,
      ["gas-natural-1"] = true,
      ["liquid-multi-phase-oil"] = true,
      ["gas-raw-1"] = true,
      ["liquid-condensates"] = true,
      ["liquid-ngl"] = true,
      ["gas-chlor-methane"] = true,
      ["hydrogen"] = true,
      ["liquid-fuel"] = true,
      ["diesel-fuel"] = true,
      ["petroleum-gas"] = true,
      ["water"] = false,
      ["sulfuric-acid "] = false,
      ["molten-tiberium"] = true,
      ["tiberium-waste"] = false,
      ["tiberium-sludge"] = false,
      ["tiberium-slurry"] = false,
      ["liquid-tiberium"] = true,
      ["tiberium-slurry-blue"] = false,
    }
  end
end

-- Initialize when the mod is first loaded
script.on_init(function()
  init_flammable_types()
end)

-- Reinitialize if configuration changes
script.on_configuration_changed(function()
  init_flammable_types()
end)

-- Reinitialize if the game is reloaded
script.on_load(function()
  init_flammable_types()
end)

-- Remote interface for adding/removing/fluid queries
remote.add_interface("flammable_oils", {
  add_flammable_type = function(name)
    flammable_types[name] = true
  end,
  remove_flammable_type = function(name)
    flammable_types[name] = nil
  end,
  get_flammable_types = function()
    return flammable_types
  end
})

-- Event handler for entities that died
script.on_event(defines.events.on_entity_died, function(event)
  local entity = event.entity
  local boxes = entity.fluidbox
  local num_pots = #boxes
  if num_pots == 0 then return end
  local fluids = prototypes.fluid
  for k = 1, num_pots do
    local pot = boxes[k]
    if pot and flammable_types[pot.name] then
      local fluid = fluids[pot.name]
      -- Boiler produces 0.5 pollution per second at 1.8 MW power
      -- Calculate pollution as if this was being burned in a boiler
      local pollution = fluid.fuel_value / 1.8e6 * 0.5 * fluid.emissions_multiplier * pot.amount / 1.5
      local fraction = pot.amount / boxes.get_capacity(k)
      if fraction > 0.025 then
        return flammable_explosion(entity, fraction, pollution)
      end
    end
  end
end)

-- Function to handle flammable explosions
function flammable_explosion(entity, fraction, pollution)
  if not entity.valid then return end
  local pos = entity.position
  local surface = entity.surface
  local radius = 0.5 * ((entity.bounding_box.right_bottom.x - pos.x) + (entity.bounding_box.right_bottom.y - pos.y))
  local width = radius * 2
  local area = {{pos.x - (radius + 0.5), pos.y - (radius + 0.5)}, {pos.x + (radius + 0.5), pos.y + (radius + 0.5)}}
  local damage = math.random(20, 40) * fraction
  
  surface.pollute(pos, pollution)
  
	if width <= 1 then
		
		surface.create_entity{name = "explosion", position = pos}
		surface.create_entity{name = "fire-flame", position = pos, raise_built = true}
	else
		
		surface.create_entity{name = "medium-explosion", position = {pos.x + math.random(-radius, radius), pos.y + math.random(-radius, radius)}}

		
		for k = 1, math.ceil(width) do
			local offset_x = math.random(-radius, radius)
			local offset_y = math.random(-radius, radius)
			surface.create_entity{name = "fire-flame", position = {pos.x + offset_x, pos.y + offset_y}, raise_built = true}

			
			for j = 1, math.ceil(4 * fraction) do
				local burst_radius = width + (2 * fraction)
				local burst_x = math.random(-burst_radius, burst_radius)
				local burst_y = math.random(-burst_radius, burst_radius)
				surface.create_entity{name = "fire-flame", position = {pos.x + burst_x, pos.y + burst_y}, raise_built = true}
			end
		end
	end

  
  if entity.type == "pipe-to-ground" then
    if entity.neighbours then
      for k, neighbour in pairs(entity.neighbours[1]) do
        if neighbour and neighbour.valid and neighbour.type == "pipe-to-ground" then
          surface.create_entity{name = "fire-flame", position = neighbour.position, raise_built = true}
          neighbour.damage(damage, entity.force, "explosion")
          break
        end
      end
    end
  end
  
  for k, nearby in pairs(surface.find_entities(area)) do
    if nearby.valid and nearby.health then
      nearby.damage(damage, entity.force, "explosion")
    end
  end
end
