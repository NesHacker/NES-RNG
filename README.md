# NES-RNG
An NES RNG Utility Library written in 6502 assembly.

## Overview
NES-RNG is a library that implements higher order RNG methods for NES games in
6502 assembly.

This library expands on [Brad Smith's general purpose PRNG library](https://github.com/bbbradsmith/prng_6502/tree/master)
by providing easy to use routines for generating random numbers over
various ranges.

It also provides quality of life macros for handling seeding and generating
many random numbers between render frames.
