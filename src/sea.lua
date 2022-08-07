local ascii85 = require(script.Parent.ascii85)

function seAlgorithm(secret)
    local usedSeeds = {};

    local random = Random.new();

	local secret_key_6 =  secret[1]
	local secret_key_7 =  secret[2]
	local secret_key_44 =  secret[3]
	local secret_key_8 = secret[4]

    local secret_donotshare = table.concat(secret, ":")

	local floor = math.floor

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
		local seed;
		repeat
			seed = random:NextNumber(0, 35184372088832);
		until not usedSeeds[seed];
		return seed;
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
		local seed = gen_seed();
		set_seed(seed)
		local len = string.len(str)
		local out = {}
		local prevVal = secret_key_8;
		for i = 1, len do
			local byte = string.byte(str, i);
			out[i] = string.char((byte - (get_next_pseudo_random_byte() + prevVal)) % 256);
			prevVal = byte;
		end
		return ascii85.encode(table.concat(out)), seed;
	end

   
    local charmap = {};
	local i = 0;
	local nums = {};
	for i = 1, 256 do
		nums[i] = i;
	end
	repeat
		local idx = random:NextNumber(1, #nums);
		local n = table.remove(nums, idx);
		charmap[n] = string.char(n - 1);
	until #nums == 0;

    local function decrypt(str, seed)
        str = ascii85.decode(str)
		set_seed(seed)
		local len = string.len(str)
		local out = {}
		local prevVal = secret_key_8;
		for i = 1, len do
			local byte = (string.byte(str, i) + (get_next_pseudo_random_byte() + prevVal)) % 256;
			out[i] = string.char(byte+1);
			prevVal = byte;
		end
		return table.concat(out);
	end
    
    return {
        encrypt = encrypt,
        secret = secret_donotshare,
        decrypt = decrypt,
    }

end

return {
    new = seAlgorithm,
}