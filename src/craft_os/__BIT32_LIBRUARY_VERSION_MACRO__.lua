--Bit32 libruary prepare section
local bit32 = pcall(require,"bit")and require"bit" --attempt to get bitop.dll (bit64)
or pcall(require,"bit32")and require"bit32" --attempt to get bit32.dll as replacement
or pcall(require,"bitop")and (require"bitop".bit or require"bitop".bit32) --emergency solution: bitop.lua
or print and print"Warning! Bit32/bitop libruary not found! Bitwize operators module disabled!"and nil --loading alarm
if bit32 then --reconfigure lib
    local b = {}
    for k,v in pairs(bit32)do b[k]=v end
    b.shl=b.lshift
    b.shr=b.rshift
    b.lshift,b.rshift=nil --optimisation
    bit32=b
end