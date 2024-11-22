--Bit32 libruary prepare section
local bit32        = (bitop and bitop.bit or bitop.bit32)or bit32 or pcall(require,"bit32")and require"bit32"or print"Warning! Bit32/bitop libruary not found! Bitwize operators module disabled!"and nil
if bit32 then
    local b = {}
    for k,v in pairs(bit32)do b[k]=v end
    b.shl=b.lshift
    b.shr=b.rshift
    b.lshift,b.rshift=nil --optimisation
    bit32=b
end