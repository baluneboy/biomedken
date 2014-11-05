# TODO: with processing chain, you should grow an encoded message
#       like RATFS would be nstfs would be native rate, s-axis, tapered, filtered, shifted
#       or   RATFS would be NxTfS would be Not native rate, x-axis, Not tapered, filtered, Not shifted
# AND include this RATFS as file output suffix somehow!
#
#
# R A T F S  process-chain encoding
# : : : : :
# : : : : :
# : : : : .......... SHIFT character is S for frequency-shifted data; otherwise, it's s
# : : : .................... FILTER character is F for filtered data; otherwise, it's f
# : : .............................. TAPER character is T for tapered data; otherwise, it's t
# : ........................................ AXIS character is X, Y, Z, or S; where S = X + Y + Z
# .................................................. RATE character is R for native rate; otherwise, it's r 

There are important considerations and tradeoffs that come with converting
acceleration data into sound (vibrations) audible to humans. Perhaps the most
important consideration is the human hearing system and its limitations.

Wikipedia suggests that humans can hear sound in the frequency range (pass-band)
from about 20 to 20 kHz. Some humans likely have a narrower or truncated
pass-band.

Finally, an acknowledgement to my neighbors who may have heard a few strange
chirps and squeaks coming from my general direction during testing of this code.
