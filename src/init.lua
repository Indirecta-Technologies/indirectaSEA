--[[

  `/shdmmmmmmmmmd-`ymmmddyo:`       //                sm- /h/                        --
`yNMMMMMMMMMMMMm-.dMMMMMMMMMN+     `MN  `-:::.`   .-:-hM- -o-  .-::.  .::-.   `.:::` MN--. `-::-.
yMMMMMMMMMMMMMd.:NMMMMMMMMMMMM+    `MN  yMs+oNh  oNy++mM- +Mo -Mm++:`hmo+yN+ .dmo++- MNoo/ `o+odN:
yMMMMMMMMMMMMy`+NMMMMMMMMMMMMM+    `MN  yM:  dM. MN   yM- +Mo -Mh   /Mmss    sM+     MN    +h ohMo
`yNMMMMMMMMMo`sMMMMMMMMMMMMMNo     `MN  yM:  dM. oNy//dM- +Mo -Mh   `dNs++o. -mm+//- dM+/+ mN+/sMo
  `/shddddd/ odddddddddddho:`       ::  .:`  -:   `:///-` .:. `:-     .://:`  `-///. `-//: `-///:.

Indirecta Technologies, Licensed under the "Gnu General Public License v3"

Group Link: https://www.roblox.com/groups/5717887/Indirecta

]]

local floor = math.floor
local char = string.char
local byte = string.byte


function seAlgorithm(secret)
	local usedSeeds = {}

	local random = Random.new()

	local secret_key_6 = secret[1] -- 6-bit  arbitrary integer (0..63)
	local secret_key_7 = secret[2] -- 7-bit  arbitrary integer (0..127)
	local secret_key_44 = secret[3] -- 44-bit arbitrary integer (0..17592186044415)
	local secret_key_8 = secret[4] -- 8-bit  arbitrary integer (0..255)

	local function primitive_root_257(idx)
		local g, m, d = 1, 128, 2 * idx + 1
		repeat
			g, m, d = g * g * (d >= m and 3 or 1) % 257, m / 2, d % m
		until m < 1
		return g
	end

	local param_mul_8 = primitive_root_257(secret_key_7)
	local param_mul_45 = secret_key_6 * 4 + 1
	local param_add_45 = secret_key_44 * 2 + 1

	local state_45 = 0
	local state_8 = 2

	local prev_values = {}
	local function set_seed(seed_53)
		state_45 = seed_53 % 35184372088832
		state_8 = seed_53 % 255 + 2
		prev_values = {}
	end

	local function gen_seed()
		local seed
		repeat
			seed = random:NextNumber(0, 35184372088832)
		until not usedSeeds[seed]
		return seed
	end

	local function get_random_32()
		state_45 = (state_45 * param_mul_45 + param_add_45) % 35184372088832
		repeat
			state_8 = state_8 * param_mul_8 % 257
		until state_8 ~= 1
		local r = state_8 % 32
		local n = floor(state_45 / 2 ^ (13 - (state_8 - r) / 32)) % 2 ^ 32 / 2 ^ r
		return floor(n % 1 * 2 ^ 32) + floor(n)
	end

	local function get_next_pseudo_random_byte()
		if #prev_values == 0 then
			local rnd = get_random_32()
			local low_16 = rnd % 65536
			local high_16 = (rnd - low_16) / 65536
			local b1 = low_16 % 256
			local b2 = (low_16 - b1) / 256
			local b3 = high_16 % 256
			local b4 = (high_16 - b3) / 256
			prev_values = { b1, b2, b3, b4 }
		end
		return table.remove(prev_values)
	end

	local function encrypt(str)
		local seed = gen_seed()
		set_seed(seed)
		local prevVal = secret_key_8
		return (str:gsub(".", function(m)
			m = byte(m)
			local _byte = (m - (get_next_pseudo_random_byte() + prevVal)) % 256
			prevVal = m
			return ("%02x"):format(_byte)
		end)), seed
	end

	local function decrypt(str, seed)
		set_seed(seed)
		local prevVal = secret_key_8
		return (str:gsub("%x%x", function(c)
					c = tonumber(c, 16)
					local _byte = (c + (get_next_pseudo_random_byte() + prevVal)) % 256
					prevVal = _byte
					return char(_byte)
				end))
	end

	return {
		encrypt = encrypt;
		secret = secret;
		decrypt = decrypt;
        __primitive_root_257 = primitive_root_257;
        __set_seed = set_seed;
        __gen_seed = gen_seed;
        __get_random_32 = get_random_32;
        __get_next_pseudo_random_byte = get_next_pseudo_random_byte;
	}
end

return {
	newState = seAlgorithm;
	deriveSecret = require(script["deriveSecret"]);
}
