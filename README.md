<h1 align="center">
  <img alt="cgapp logo" src="https://raw.githubusercontent.com/Indirecta-Technologies/branding/main/logos/indirecta_logo_medium500_withPill.png" width="350px"/><br/>
  String Encryption Algorithm
</h1>
<p align="center">
  <a href="https://github.com/Indirecta-Technologies/branding">Branding</a> •
  <a href="https://github.com/Indirecta-Technologies/RFCs">RFCs</a> •
  <a href="https://github.com/Indirecta-Technologies/dob">DOB</a> •
  <a href="https://github.com/Indirecta-Technologies/fosd">FOSD</a> •
  <a href="https://github.com/Indirecta-Technologies/pcsi">pCsi</a> •
  <a href="https://github.com/Indirecta-Technologies/rtech-archive">rtech-archive</a> •
  <a href="https://github.com/Indirecta-Technologies/openlift">openlift</a> •
  <a href="https://github.com/Indirecta-Technologies/Rufus">Rufus</a>
</p>

### Adapted from the [Prometheus String Encryption Step](https://github.com/levno-710/Prometheus/blob/master/src/prometheus/steps/EncryptStrings.lua) for standalone use as a library (rojo project)

<details> 

<summary>✏️ Algorithm Design</summary>  

### (written by ChatGPT, take with a grain of salt)  

The Indirecta encryption algorithm is designed to be a symmetric encryption algorithm, meaning that the same key is used for both encryption and decryption. The algorithm takes as input a secret key, which consists of four arbitrary integers: a 6-bit integer (0..63), a 7-bit integer (0..127), a 44-bit integer (0..17592186044415), and an 8-bit integer (0..255). The algorithm then uses these integers as parameters for its encryption and decryption operations.

The algorithm first calculates a primitive root of 257 using the secret_key_7 integer. This primitive root is used to generate a multiplication parameter for the linear congruential generator used in the algorithm. The algorithm also uses the secret_key_6 integer to calculate another multiplication parameter, as well as a secret_key_44 integer to calculate an addition parameter for the linear congruential generator.

The algorithm then initializes two state variables, state_45 and state_8, with the values of zero and two, respectively. The state_45 variable is used to store the current state of the linear congruential generator, while the state_8 variable is used to generate the pseudo-random numbers.

## Encryption

The encryption process in the Indirecta algorithm takes a plaintext string as input and returns a ciphertext string and a seed value. The seed value is a randomly generated number that is used to set the initial state of the linear congruential generator.

### The encryption process consists of the following steps:

1. Generate a random seed value that has not been used before.
2. Set the initial state of the linear congruential generator using the generated seed value.
3. Initialize a previous value variable, prevVal, with the value of the secret_key_8 integer.
4. Iterate over each character in the plaintext string.
5. For each character, subtract the previous value variable and a pseudo-random byte from the character's byte value, modulo 256.
6. Set the previous value variable to the character's byte value.
7. Append the resulting byte value to the ciphertext string.
8. Return the ciphertext string and the seed value.

## Decryption

The decryption process in the Indirecta algorithm takes a ciphertext string and a seed value as input and returns a plaintext string. The seed value is used to set the initial state of the linear congruential generator.

### The decryption process consists of the following steps:

1. Set the initial state of the linear congruential generator using the given seed value.
2. Initialize a previous value variable, prevVal, with the value of the secret_key_8 integer.
3. Iterate over each pair of characters in the ciphertext string.
4. For each pair of characters, add a pseudo-random byte and the previous value variable to the byte value, modulo 256.
5. Set the previous value variable to the resulting byte value.
6. Append the resulting byte value to the plaintext string.
1. Return the plaintext string.

</details>

## 📖 Methods
> - `isea.newState(secret)` Returns a new iSEA state using a secret  
> *returns a* **`table`**
> - `isea.deriveSecret(passphrase)` Returns a new iSEA secret derived from a string passphrase  
> *returns a* **`table`**

> - `state.encrypt(string)` Encrypts a string using the current state's secret  
> *returns a* **`tuple`**
> - `state.decrypt(ciphertext, seed)` Decrypts provided ciphertext using the current state's secret and the ciphertext's seed  
> *returns a* **`string`**

## 📖 Example usage
# 🔐 Encryption
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

# 🔓 Decryption

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

# 🔑 Secret Derivation

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
