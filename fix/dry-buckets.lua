local argparse = require("argparse")

local quiet = false

local emptied = 0
local in_building = 0
local water_type = dfhack.matinfo.find('WATER').type

argparse.processArgsGetopt({...}, {
    {'q', 'quiet', handler=function() quiet = true end},
})

for _,item in ipairs(df.global.world.items.other.IN_PLAY) do
    local container = dfhack.items.getContainer(item)
    if container
        and container:getType() == df.item_type.BUCKET
        and not (container.flags.in_job)
        and item:getMaterial() == water_type
        and item:getType() == df.item_type.LIQUID_MISC
        and not (item.flags.in_job)
    then
        if container.flags.in_building or item.flags.in_building then
            in_building = in_building + 1
        end
        dfhack.items.remove(item)
        emptied = emptied + 1
    end
end

if not quiet then
    print('Emptied '..emptied..' buckets.')
    if emptied > 0 then
        print(('Unclogged %d wells.'):format(in_building))
    end
end
