local flammable_types = 
  {
    ["crude-oil"] = true,
    ["heavy-oil"] = true,
    ["light-oil"] = true,
    ["lubricant"] = true,
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
    ["petroleum-gas"] = true
  }

script.on_event(defines.events.on_entity_died, function(event)

  local entity = event.entity
  local boxes = entity.fluidbox
  local num_pots = #boxes
  if num_pots == 0 then return end
  for k = 1, num_pots do
    local pot = boxes[k]
    if pot then 
      if flammable_types[pot.type] then
        local fraction = pot.amount/boxes.get_capacity(k)
        if fraction > 0.025 then 
          flammable_explosion(entity, fraction)
          return
        end
      end
    end
  end
  
end)

function flammable_explosion(entity,fraction)

  if not entity.valid then return end
  local pos = entity.position
  local surface = entity.surface
  local radius = 0.5*((entity.bounding_box.right_bottom.x - pos.x)+(entity.bounding_box.right_bottom.y - pos.y))
  local width = radius * 2
  local area = {{pos.x-(radius+0.5),pos.y-(radius+0.5)},{pos.x+(radius+0.5),pos.y+(radius+0.5)}}
  local damage = (math.random(10,30)+10)*fraction
  
  if width <= 1 then
    entity.surface.create_entity{name = "explosion", position = pos}
    entity.surface.create_entity{name = "oil-fire-flame", position = pos}
  else
    surface.create_entity{name = "medium-explosion", position = {pos.x+math.random(-radius,radius), pos.y+math.random(-radius,radius)}}
    for k = 1, math.ceil(width) do
      surface.create_entity{name = "oil-fire-flame", position = {pos.x+math.random(-radius,radius), pos.y+math.random(-radius,radius)}}
      for j = 1, math.ceil(4*fraction) do
        local burst = width+(2*fraction)
        surface.create_entity{name = "oil-fire-flame", position = {pos.x+math.random(-burst,burst), pos.y+math.random(-burst,burst)}}
      end
    end
  end
  
  if entity.type == "pipe-to-ground" then
    if entity.neighbours then
      local neighbour = entity.neighbours[2]
      if neighbour then
        if neighbour.valid then
          if neighbour.type == "pipe-to-ground" then
            surface.create_entity{name = "oil-fire-flame", position = neighbour.position}
            neighbour.damage(damage,entity.force,"explosion")
          end
        end
      end
    end
  end
  
  for k, nearby in pairs (surface.find_entities(area)) do
    if nearby.valid then
      if nearby.health then
        nearby.damage(damage,entity.force,"explosion")
      end
    end
  end

end