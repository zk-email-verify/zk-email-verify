pragma circom 2.0.3;

include "../node_modules/circomlib/circuits/bitify.circom";
include "./sha.circom";
include "./rsa.circom";
include "./regex_from.circom";

template EmailVerify(max_num_bytes, n, k) {
    // max_num_bytes must be a multiple of 64
    signal input in_padded[max_num_bytes]; // prehashed email data, includes up to 512 + 64? bytes of padding pre SHA256, and padded with lots of 0s at end after the length
    signal input modulus[k]; // rsa pubkey, verified with smart contract + optional oracle
    signal input signature[k];
    signal input in_len_padded_bytes; // length of in email data including the padding, which will inform the sha256 block length

    signal output reveal_from[max_num_bytes];

    component sha = Sha256Bytes(max_num_bytes);
    for (var i = 0; i < max_num_bytes; i++) {
        sha.in_padded[i] <== in_padded[i];
    }
    sha.in_len_padded_bytes <== in_len_padded_bytes;

    var msg_len = (256+n)\n;
    component base_msg[msg_len];
    for (var i = 0; i < msg_len; i++) {
        base_msg[i] = Bits2Num(n);
    }
    for (var i = 0; i < 256; i++) {
        base_msg[i\n].in[i%n] <== sha.out[255 - i];
    }
    for (var i = 256; i < n*msg_len; i++) {
        base_msg[i\n].in[i%n] <== 0;
    }

    component rsa = RSAVerify65537(n, k);
    for (var i = 0; i < msg_len; i++) {
        rsa.base_message[i] <== base_msg[i].out;
    }
    for (var i = msg_len; i < k; i++) {
        rsa.base_message[i] <== 0;
    }
    for (var i = 0; i < k; i++) {
        rsa.modulus[i] <== modulus[i];
    }
    for (var i = 0; i < k; i++) {
        rsa.signature[i] <== signature[i];
    }

    component regex_from = RegexFrom(max_num_bytes);
    for (var i = 0; i < max_num_bytes; i++) {
        regex_from.msg[i] <== in_padded[i];
    }
    regex_from.out === 1;
    for (var i = 0; i < max_num_bytes; i++) {
        reveal_from[i] <== regex_from.reveal[i+1];
    }

    for (var i = 0; i < max_num_bytes; i++) {
        log(reveal_from[i]);
    }
}
component main { public [ in_padded, modulus, signature, in_len_padded_bytes ] } = EmailVerify(512, 121, 17);
