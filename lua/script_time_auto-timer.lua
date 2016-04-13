function timedifference (s)
   year = string.sub(s, 1, 4)
   month = string.sub(s, 6, 7)
   day = string.sub(s, 9, 10)
   hour = string.sub(s, 12, 13)
   minutes = string.sub(s, 15, 16)
   seconds = string.sub(s, 18, 19)
   t1 = os.time()
   t2 = os.time{year=year, month=month, day=day, hour=hour, min=minutes, sec=seconds}
   difference = os.difftime (t1, t2)
   return difference
end

commandArray = {}

local t_waku    = tonumber(uservariables["t_wasch"])
local sw_waku   = 'Waschraum Licht'
local t_aussen  = tonumber(uservariables["t_aussenbeleuchtung"])
local sw_ausbel = 'Aussenbeleuchtung Vorne'
local sw_alarm  = 'Alarmschalter'
local t_alarm   = tonumber(uservariables["t_alarm"])
local motion1   = 'BWM4 - Waschraum'
local motion2   = 'BWM1 - Eingang'

--print('Waku?')
--if otherdevices[sw_waku] == 'On' then
--   print('Waku on')
--   if ((timedifference(otherdevices_lastupdate[sw_waku]) > t_waku) and (otherdevices[motion1] == 'Off' )) then
--      print('Waku Waku!')
--   end
--end

if otherdevices[sw_waku] == 'On' then
--   print('Waku is ein!')
   if ((timedifference(otherdevices_lastupdate[sw_waku]) > t_waku) and (otherdevices[motion1] == 'Off' )) then
      commandArray[sw_waku]='Off'     
   end
end

if otherdevices[sw_ausbel] == 'On' then
   if ((timedifference(otherdevices_lastupdate[sw_ausbel]) > t_aussen) and (otherdevices[motion2] == 'Off' )) then
      commandArray[sw_ausbel]='Off'
   end
end

if otherdevices[sw_alarm] == 'On' then
   if (timedifference(otherdevices_lastupdate[sw_alarm]) > t_alarm) then
      commandArray[sw_alarm]='Off'
   end
end

return commandArray
