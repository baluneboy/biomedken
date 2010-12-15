function outp = rsadec(inp,key)
% RSADEC - rapidly decrypt a short message using RSA
%
% pt=rsadec(ct,key)
%
% ct  = cyphertext (uint8 vector) created by RSAENC
% key = private or public key created by the RSAKEYS function
% pt  = plaintext message (a vector of type uint8) which you may
%       wish to convert to text using "char(pt)"
%
% Notes: (1) This function uses Java, which contains the calculation
%            routines
%        (2) The usual use of RSA is for encryption of keys in a "key
%            exchange," so the plaintext size limits provided by the Java
%            routines (which are adequate for that purpose) have not been
%            expanded here. (For example, a 128-bit AES encryption key
%            requires only 16 bytes.) See the RSAENC function.
%        (3) An RSA "key" consists of two quatities: a modulus and an
%            exponent. RSA keys always come in pairs, with one key denoted
%            "public" and the other as "private." A message that is
%            encrypted using EITHER key must be decrypted using the OTHER
%            key. You keep the private key secret and broadcast the public
%            key. Anyone can then encrypt any message to you using the
%            public key, but no one but you can decrypt it (not even the
%            sender) since only you have the secret key. Also, you can
%            encrypt a message using your private key, and anyone can
%            decrypt it using the public key. The benefit is that they then
%            know for sure that you are the person who generated the
%            message.
%        (4) RSA modulus and exponent selection have certain nuances
%            beyond the basic numerical calculations. In particular,
%            certain values for various components of the key generation
%            can result in encryption weaknesses. For this reason, you
%            may choose to avoid generating RSA key pairs yourself and
%            instead rely upon "official" key generation code such as the
%            Java routines used in this function.
%        (5) As of 2005, "RSA Laboratories currently recommends key
%            sizes of 1024 bits for corporate use and 2048 bits for
%            extremely valuable keys...." For more information, see
%            http://www.rsasecurity.com/rsalabs/node.asp?id=2218
%        (6) As of 2005, the US National Institue of Standards and
%            Technology claims that 2048 bit keys for RSA will remain
%            resistant to cracking until about 2030.
%        (7) Tested but no warranty; use at your own risk.
%        (8) Michael Kleder, Nov 2005
%
% EXAMPLE:
%
% [pri,pub]=rsakeys(1024);
% char(rsadec(rsaenc('This is a secret.',pub),pri))
% char(rsadec(rsaenc('This is a secret.',pri),pub))

if ischar(inp) | islogical(inp)
    inp=uint8(inp(:));
else
    inp=typecast(inp(:),'uint8');
end
modulus = java.math.BigInteger(key.modulus);
pubexp = java.math.BigInteger(key.exponent);
kfac = java.security.KeyFactory.getInstance('RSA');
% For consistency, always use Java public key decryptor. We are not doing
% key intent verification here (we just want the math):
pubkey=kfac.generatePublic(java.security.spec.RSAPublicKeySpec(modulus,pubexp));
c=javax.crypto.Cipher.getInstance('RSA');
c.init(2,pubkey);
ct=typecast(c.doFinal(inp),'uint8');
outp=typecast(ct,'uint8');
outp=outp(:)';
return
