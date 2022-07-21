# The App
The application is located at https://double-blind.xyz.

The documentation for the app is located at https://double-blind.xyz/docs

# Development Instructions.

(this section is under construction)

```
circuits/
    inputs/ # Test inputs for example witness generation for compilation
    scripts/ # Run snarkjs ceremony to generate zkey with yarn compile
```
## CIRCOM BUILD STEPS

```
wget https://hermez.s3-eu-west-1.amazonaws.com/powersOfTau28_hez_final_21.ptau
# shasum pot21_final.ptau: e0ef07ede5c01b1f7ddabb14b60c0b740b357f70
mv powersOfTau28_hez_final_21.ptau powersoftau/powersOfTau28_hez_final_21.ptau
```

To do the steps in https://github.com/iden3/snarkjs#7-prepare-phase-2 automatically, do

```
yarn compile rsa true
```

and when the circuit doesn't change,
```
yarn compile rsa true skip-recompile
```

For production, make sure to set a beacon in .env.

Double blind circuit:
```
circom circuits/main/rsa_group_sig_verify.circom --wasm --r1cs
snarkjs zkey new ./rsa_group_sig_verify.r1cs pot21_final.ptau public/rsa_group_sig_verify_0000.zkey
snarkjs zkey export verificationkey public/rsa_group_sig_verify_0000.zkey public/rsa_group_sig_verify_0000.vkey.json
cp rsa_group_sig_verify_js/rsa_group_sig_verify.wasm public
```
