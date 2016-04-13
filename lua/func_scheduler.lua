package.path    = package.path .. ";/home/pi/domoticz/scripts/lua/?.lua"
local MiscClass = require("func_misc")

local publicClass={}
debugmode = 1

-- calculate difference in seconds between two times
function publicClass.timediff (hour1, minutes1, hour2, minutes2)
   t1 = os.time{year=2016, month=1, day=1, hour=hour1, min=minutes1}
   t2 = os.time{year=2016, month=1, day=1, hour=hour2, min=minutes2}
   difference = os.difftime (t1, t2)
   return difference
end

-- determine from a string and a day number if day is valid
function publicClass.day_current(day_s, day_curr)
   if (string.sub(day_s,day_curr,day_curr) == '1') then
      return 1
   else
      return 0
   end
end

-- do the heavy lifting
function publicClass.schedule(path, dev_id, idx)
   -- get current time and date
   local debugmode  = 1
   local switchmode = 1 --default value
   local year  = tonumber(os.date("%Y"))
   local month = tonumber(os.date("%m"))
   local day   = tonumber(os.date("%d"))
   local wday  = tonumber(os.date("%w"))
   local hour  = tonumber(os.date("%H"))
   local min   = tonumber(os.date("%M"))
   if (wday==0) then wday  = 7; end -- Mon=1, Sun=7
   if (wday==1) then pwday = 7; else pwday = wday - 1; end -- previous weekday
   ----------------------------
   local sethour = 0
   local setmin  = 0
   local newact  = 99
   local maxhour = 0
   local maxmin  = 0
   local maxact
   local lastact = ""
   local tdiffm  = 0
   local tdiff   = 86400
   local fh,err = io.open(path)
   if err then print("OOps"); return; end
   -- line by line
   while true do
      local line = fh:read()
      if line == nil then break end
      if ((string.sub(line,1,1) == '@') and (string.len(line) >= 18)) then
	 days_s  = string.sub(line,2,8)
	 timeh   = tonumber(string.sub(line,10,11))
	 timem   = tonumber(string.sub(line,13,14))
	 -- switch or temperature mode?
	 if (string.sub(line,16,17) == "on") then
	    act = "On"
	    switchmode = 1
	 elseif (string.sub(line,16,18) == "off") then
	    act = "Off"   
	    switchmode = 1
	 else
	    act = tonumber(string.sub(line,16,19))
	    switchmode = 0
	 end
	 -- calculate time differences
	 tdiffx  = publicClass.timediff(hour, min, timeh, timem)
	 tdiffy  = publicClass.timediff(0, 0, timeh, timem)
	 if ((debugmode == 1) and (switchmode == 0)) then
	    print(string.format("Days: %s @%02d:%02d -> %2.1f (%d/%d) [TD: %d]",days_s ,timeh, timem, act, publicClass.day_current(days_s, wday),wday, tdiffx))
	 elseif ((debugmode == 1) and (switchmode == 1)) then
	    print(string.format("Days: %s @%02d:%02d -> %3s (%d/%d) [TD: %d]",days_s ,timeh, timem, act, publicClass.day_current(days_s, wday),wday, tdiffx))
	 end
	 -- check if current schedule line is most recent one
	 if ((publicClass.day_current(days_s, wday) == 1) and (tdiffx >= 0)) then -- ignore future setpoints
	    if (tdiffx <= tdiff) then
	       tdiff   = tdiffx
	       sethour = timeh
	       setmin  = timem
	       newact  = act -- save last valid temperature
	    end
	 end
	 -- find latest schedule item of previous day
	 if ((publicClass.day_current(days_s, pwday) == 1) and (tdiffy <= 0)) then
	    if (tdiffy <= tdiffm) then
	       tdiffm  = tdiffy
	       maxhour = timeh
	       maxmin  = timem
	       maxact  = act -- save last valid temperature
	    end
	 end
      end
   end
   if (newact == 99) then -- no valid setpoint today, getting last one from yesterday!
      newact  = maxact
      sethour = maxhour
      setmin  = maxmin
   end
   print(string.format("Switchmode: %d, Debugmode: %d", switchmode, debugmode))
   local devicename = MiscClass.idx2dev(dev_id)
   
   if (switchmode == 0) then -- Temperature mode (temp)
      local currtemp = tonumber(otherdevices_svalues[devicename])
      if (currtemp == newact) then
	 print("Nothing to set here!")
      else
	 print(string.format("Setting new Temperature %02.1f on %s!", newact, devicename))
	 commandArray [idx] = {['UpdateDevice']= dev_id .. '|0|' .. newact}
      end
      if (debugmode == 1) then
	 print(string.format("Selected Temperature: (@%02d:%02d): %02.1f", sethour, setmin, newact))
      end
      
   elseif (switchmode == 1) then -- Switch mode (on/off)
      local currmode = otherdevices[devicename]
      if (currmode == newact) then
	 print("Nothing to switch here!")
      else
	 print(string.format("Switching device \'%s\' %s!",devicename, newact))
	 commandArray[idx]={[devicename]=newact}
--         commandArray[devicename]=newact
      end
      if (debugmode == 1) then
	 print(string.format("Selected Switchmode: (@%02d:%02d): %s", sethour, setmin, newact))	 
      end
   end
   fh:close()
end

return publicClass
