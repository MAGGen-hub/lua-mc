--Bit32 libruary prepare section
local bit32        = bit32 or pcall(require,"bit32")and require"bit32"or print"Warning! Bit32 libruary not found! Bitwize operators module disabled!"and nil
if bit32 then
    local b = {}
    for k,v in pairs(bit32)do b32[k]=v end
    b.shl=b.lshift
    b.shr=b.rshift
    b.lshift,brshift=nil --optimisation
    bit32=b
end