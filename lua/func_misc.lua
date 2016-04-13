local publicClass={}
debugmode = 1

if otherdevices_idx == nil then
   otherdevices_idx = {} -- only for console launch!
end

function publicClass.idx2dev(deviceIDX)
   for i, v in pairs(otherdevices_idx) do
      if v == deviceIDX then
         return i
      end
   end
   return 0
end

return publicClass
