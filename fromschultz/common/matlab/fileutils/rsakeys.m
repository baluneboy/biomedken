function varargout=rsakeys(varargin)
% RSAKEYS - rapidly generate RSA private and public keys up to 2048 bits
%
% [prikey,pubkey]=rsakeys
% [prikey,pubkey]=rsakeys(strength)
% [prikey,pubkey,details]=rsakeys(...)
%
% prikey  = struct with fields "modulus" and "exponent" where the
%           exponent has significant length, plus a field "intent" which
%           is set to 'private' as a reminder
% pubkey  = struct with fields "modulus" and "exponent" where the
%           exponent is always 65537, and a field "intent" which is
%           set to the string 'public' as a reminder
% strength = an RSA strength of 512, 1024, or 2048 bits (default = 2048)
% details  = optional output string containing computational details about
%            the key pair
%
% Notes: (1) This function uses Java, which contains the calculation
%            routines
%        (2) An RSA "key" consists of two quatities: a modulus and an
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
%        (3) RSA modulus and exponent selection have certain nuances
%            beyond the basic numerical calculations. In particular,
%            certain values for various components of the key generation
%            can result in encryption weaknesses. For this reason, you
%            may choose to avoid generating RSA key pairs yourself and
%            instead rely upon "official" key generation code.
%        (4) As of 2005, "RSA Laboratories currently recommends key
%            sizes of 1024 bits for corporate use and 2048 bits for
%            extremely valuable keys...." For more information, see
%            http://www.rsasecurity.com/rsalabs/node.asp?id=2218
%        (5) As of 2005, the US National Institue of Standards and
%            Technology claims that 2048 bit keys for RSA will remain
%            resistant to cracking until about 2030.
%        (6) Tested but no warranty; use at your own risk.
%        (7) Michael Kleder, Nov 2005
%
% EXAMPLE
%
% [pr,pu,d]=rsakeys(1024)

strength=2048;
if nargin > 0
    strength=varargin{1};
    if ~any(ismember(strength,[512 1024 2048]))
        error('Supported RSA strengths are 512, 1024, and 2048 bits')
    end
end
kpg=java.security.KeyPairGenerator.getInstance('RSA');
kpg.initialize(strength,java.security.SecureRandom.getInstance('SHA1PRNG'));
kp=kpg.generateKeyPair;
pubkey.modulus=char(kp.getPublic.getModulus.toString);
pubkey.exponent=char(kp.getPublic.getPublicExponent.toString);
pubkey.intent='public';
prikey.modulus=pubkey.modulus;
prikey.exponent=char(kp.getPrivate.getPrivateExponent.toString);
prikey.intent='private';
varargout{1}=prikey;
varargout{2}=pubkey;
if nargout > 2
    varargout{3}=char(kp.getPrivate.toString);
end
return