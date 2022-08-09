local INIT_0 = 0x67452301
local INIT_1 = 0xEFCDAB89
local INIT_2 = 0x98BADCFE
local INIT_3 = 0x10325476
local INIT_4 = 0xC3D2E1F0

local APPEND_CHAR = string.char(0x80)
local INT_32_CAP = 2^32

---Packs four 8-bit integers into one 32-bit integer
local function packUint32(a, b, c, d)
    return bit32.lshift(a, 24)+bit32.lshift(b, 16)+bit32.lshift(c, 8)+d
end

---Unpacks one 32-bit integer into four 8-bit integers
local function unpackUint32(int)
    return bit32.extract(int, 24, 8), bit32.extract(int, 16, 8),
           bit32.extract(int, 08, 8), bit32.extract(int, 00, 8)
end

local function F(t, A, B, C)
    if t <= 19 then
        -- C ~ (A & (B ~ C)) has less ops than (A & B) | (~A & C)
        return bit32.bxor(C, bit32.band(A, bit32.bxor(B, C)))
    elseif t <= 39 then
        return bit32.bxor(A, B, C)
    elseif t <= 59 then
        -- A | (B | C) | (B & C) has less ops than (A & B) | (A & C) | (B & C)
        return bit32.bor(bit32.band(A, bit32.bor(B, C)), bit32.band(B, C))
    else
        return bit32.bxor(A, B, C)
    end
end

local function K(t)
    if t <= 19 then
        return 0x5A827999
    elseif t <= 39 then
        return 0x6ED9EBA1
    elseif t <= 59 then
        return 0x8F1BBCDC
    else
        return 0xCA62C1D6
    end
end

local function preprocessMessage(message)
    local initMsgLen = #message*8 -- Message length in bits
    local msgLen = initMsgLen+8
    local nulCount = 4 -- This is equivalent to 32 bits.
    -- We're packing 32 bits of size, but the SHA-1 standard calls for 64, meaning we have to add at least 32 0s
    message = message..APPEND_CHAR
    while (msgLen+64)%512 ~= 0 do
        nulCount = nulCount+1
        msgLen = msgLen+8
    end
    message = message..string.rep("\0", nulCount)
    message = message..string.char(unpackUint32(initMsgLen))
  
    return message
end

local function sha1(message)
    local message = preprocessMessage(message)

    local H0 = INIT_0
    local H1 = INIT_1
    local H2 = INIT_2
    local H3 = INIT_3
    local H4 = INIT_4

    local W = {}
    for chunkStart = 1, #message, 64 do
        local place = chunkStart
        for t = 0, 15 do
            W[t] = packUint32(string.byte(message, place, place+3))
            place = place+4
        end
        for t = 16, 79 do
            W[t] = bit32.lrotate(bit32.bxor(W[t-3], W[t-8], W[t-14], W[t-16]), 1)
        end

        local A, B, C, D, E = H0, H1, H2, H3, H4

        for t = 0, 79 do
            local TEMP = ( bit32.lrotate(A, 5)+F(t, B, C, D)+E+W[t]+K(t) )%INT_32_CAP

            E, D, C, B, A = D, C, bit32.lrotate(B, 30), A, TEMP
        end

        H0 = (H0+A)%INT_32_CAP
        H1 = (H1+B)%INT_32_CAP
        H2 = (H2+C)%INT_32_CAP
        H3 = (H3+D)%INT_32_CAP
        H4 = (H4+E)%INT_32_CAP
    end
    local result = string.format("%08x%08x%08x%08x%08x", H0, H1, H2, H3, H4)

    return result
end


--  calculate any hash-function on your string (for example, MD5, SHA-1, SHA256, there exist a lot of Lua libraries to calculate hash-sums).
-- Then split the hashsum result (hexadecimal string) into 12-hex-digit chunks, convert them to numbers (up to 2^48) and apply Lua modulo operator to reduce to the size you need
--  local hash = sha1(string)
--  local hash = tonumber(hash:sub(1,12), 16) % 2^48
--  local hash = hash % 2^48
--  local hash = hash % 2^48

local function deriveSecret(str)
    --- 6-bit integer = byte % 64
	-- 7-bit integer = byte % 128
	-- 44-bit integer = byte % 17592186044416
	-- 8-bit integer = byte % 256

    local hash = sha1(str)
    local partitions = {
        -- divide hash in 4 partitions and convert to number
        tonumber(hash:sub(1,10), 16) % 2^48;
        tonumber(hash:sub(11,20), 16) % 2^48;
        tonumber(hash:sub(21,30), 16) % 2^48;
        tonumber(hash:sub(31,40), 16) % 2^48;
    }
    return {
        partitions[1] % 64,
        partitions[2] % 128,
        partitions[3] % 17592186044416,
        partitions[4] % 256,
    }
end

return deriveSecret