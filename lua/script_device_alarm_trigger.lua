commandArray = {}

local motion1  = 'BWM5 - Wohnzimmer'
local motion2  = 'BWM2 - Keller'
local motion3  = 'BWM4 - Waschraum'
local sw_alarm = 'Alarmschalter'
local sw_alarm_hot = 'Alarm scharf'

-- switch on via PIM
if (devicechanged[motion1] == 'On') or
   (devicechanged[motion2] == 'On') or
   (devicechanged[motion3] == 'On') then
   if otherdevices[sw_alarm_hot] == 'On' then
      if otherdevices[sw_alarm] == 'Off' then
	 commandArray[sw_alarm]='On'
      end
   end
elseif devicechanged[sw_alarm_hot] == 'Off' then   
   commandArray[sw_alarm]='Off'
end

return commandArray
