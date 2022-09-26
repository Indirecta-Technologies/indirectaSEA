# indirectaSEA
String Encryption Algorithm  
[Prototype SUBJECT TO CHANGE]

Adapted from the [Prometheus String Encryption Step](https://github.com/levno-710/Prometheus/blob/master/src/prometheus/steps/EncryptStrings.lua) for standalone use as a library

## How to use
### Encryption

```lua
--// Generate random secret
local random = Random.new();
local secret = {
            random:NextNumber(0, 63), --// 6-bit  arbitrary integer (0..63)
            random:NextNumber(0, 127), --// 7-bit  arbitrary integer (0..127)
            random:NextNumber(0, 17592186044415), --// 44-bit arbitrary integer (0..17592186044415)
            random:NextNumber(0, 255); --// 8-bit  arbitrary integer (0..255)
        };

local isea = require(game.ServerScriptService["iSEA"]);

local state = isea.newState(secret) -- Initialize SEA using random secret
local str = "Hello metaverse!"

print("Secret 🤫: "..table.concat(state.secret,"; ")) --> 28.39305096030534; 104.46559812685938; 14484132187863.652; 11.391023692364207

local ciphertext, seed = state.encrypt(str)

print("Encrypted String: "..ciphertext) --> e680e0a92cda96cf83c239a81d85166e
print("Seed: "..seed) --> 1373726384325.5884

print("Test passed:"..tostring(state.decrypt(ciphertext, seed) == str))
```

### Decryption

```lua
local secret = ("35.84831716766803; 23.639969842435168; 3982959064904.493; 244.42364953524924"):split("; ");

local isea = require(game.ServerScriptService["iSEA"]);

local state = isea.newState(secret) -- Initialize SEA using random secret
local ciphertext = "3a7dee43cebfd7ba63011211ad813a49"
local seed = 3462364821075.735

print("Secret used 🤫: "..table.concat(state.secret,"; "))

local str = state.decrypt(ciphertext, seed)

print("Decrypted String: "..str)
print("Seed used: "..seed)
```

### Derive secret from a string

```lua
local isea = require(game.ServerScriptService["iSEA"]);

--// Generate secret from string
local passphrase = "Shhh!"
local secret = isea.deriveSecret(passphrase)

print("Passphrase used 🤫: "..passphrase)
print("Derived secret 🤫: "..game:GetService("HttpService"):JSONEncode(secret))

local state = isea.newState(secret) -- Initialize SEA using random secret
local str = "Hello metaverse!"

local ciphertext, seed = state.encrypt(str)

print("Encrypted String: "..ciphertext) --> e680e0a92cda96cf83c239a81d85166e
print("Seed: "..seed) --> 1373726384325.5884

print("Test passed:"..tostring(state.decrypt(ciphertext, seed) == str))

```
