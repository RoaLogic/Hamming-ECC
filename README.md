## Hamming-ECC

Hamming Codes are linear error correcting codes invented in 1950 by Richard Hamming. By adding a parity check matrix they can correct 1-bit errors and detect 2-bit errors.
The provided IP is fully parameterised and implements the Hamming encoder and decoder, either fully asynchronous or with a clock and clock-enable input.
An additional wrapper that makes the code equivalent to the Altera altecc encoder and decoder IPs is also provided.
