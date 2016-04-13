package.path    = package.path .. ";/home/pi/domoticz/scripts/lua/?.lua"
local SchClass  = require("func_scheduler")
local MiscClass = require("func_misc")
local sch_path  = "/home/pi/domoticz/scripts/lua/"

if (commandArray == nil) then -- for console run
   commandArray = {}
end

local schedules = {}
schedules [666] = 'temp_debug.txt'
schedules [157] = 'switch_Stecker2.txt'
schedules [145] = 'temp_arbeitszimmer.txt'
schedules [120] = 'temp_badezimmer.txt'
schedules [123] = 'temp_dusche.txt'

print("Table")
local ERR = {}
local cnt = 1
for idx, sched in pairs( schedules ) do
   local device = MiscClass.idx2dev(idx)
   print(cnt .. ": Schedule " .. sched .. " for device id " .. idx .. " -> " .. device)
   ERR [idx] = SchClass.schedule(sch_path .. sched, idx, cnt)
   cnt = cnt + 1
end

return commandArray
