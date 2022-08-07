# indirectaSEA
String Encryption Algorithm Prototype

## How this works

When encrypting a string, the algorithm will generate a secret dictionary of numbers, that will be used to initialize the encryption and decryption functions.
The encrypted message encoded in ascii85 is returned, along with the seed, that is needed to decode the message along with the secret.

To decrypt a message, you need to initialize the SEA module using a secret key, and decode it using the seed

Both parties need the same secret to encrypt and decrypt messages, while for decryption the seed is needed additionally


local isea = require(game.ServerScriptService["Indirecta String Encryption Algorithm"])(); local en = {isea.encrypt("hi!! lol 3232")}; print("STRING & SEED", en[1], en[2]) print("! SECRET !",isea.secret)


STRING & SEED <~igQ2VBCc6s9<4JBiW~> 5114059046281.628
! SECRET ! 33.0925813664131:85.16011281255085:7456822026424.957:20.09582908157535


TO:DO

Find a way to compress the secret, and a way to encode the seed



00.0000000000000:11.11111111111111:2222222222222.222:33.33333333333333