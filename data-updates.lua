require "util"
local fire = util.table.deepcopy(data.raw.fire["fire-flame"])
fire.initial_lifetime = 600
fire.name="oil-fire-flame"
fire.damage_per_tick = {amount = 1, type = "fire"},
data:extend({fire})

local fuel_values = {
  ["crude-oil"] = "2.5MJ",
  ["light-oil"] = "3MJ",
  ["heavy-oil"] = "2MJ",
  ["petroleum-gas"] = "3MJ",
  ["diesel-fuel"] = "4MJ",
}

for k, fluid in pairs (data.raw.fluid) do
  if not fluid.fuel_value then
    fluid.fuel_value = fuel_values[fluid.name]
  end
end