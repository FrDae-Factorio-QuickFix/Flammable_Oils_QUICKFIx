require "util"
local fire = util.table.deepcopy(data.raw.fire["fire-flame"])
fire.initial_lifetime = 600
fire.name="oil-fire-flame"
fire.damage_per_tick = {amount = 1, type = "fire"},
data:extend({fire})

local fuel_values = {
  ["crude-oil"] = "0.4MJ",
  ["light-oil"] = "0.9MJ",
  ["heavy-oil"] = "0.45MJ",
  ["petroleum-gas"] = "0.45MJ",
  ["diesel-fuel"] = "1.1MJ",
  }
local emissions = {
  ["crude-oil"] = 1.4,
  ["light-oil"] = 1.2,
  ["heavy-oil"] = 1.3,
  ["petroleum-gas"] = 1,
  ["diesel-fuel"] = 0.8,
  ["molten-tiberium"] = 2.1,
  ["tiberium-waste"] = 1.2,
  ["tiberium-sludge"] = 1.7,
  ["tiberium-slurry"] = 1.8,
  ["liquid-tiberium"] = 4,
  ["tiberium-slurry-blue"] = 3,
}

for k, fluid in pairs (data.raw.fluid) do
  if not fluid.fuel_value then
    fluid.fuel_value = fuel_values[fluid.name]
end
if not    
fluid.emissions_multiplier then
    fluid.emissions_multiplier = emissions[fluid.name]
  end
end
