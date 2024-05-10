// こんにちは

var seed = 1

/*
galois16:
  ldy #8
  lda seed+0
: asl
	rol seed+1
	bcc :+
	eor #$39
: dey
  bne :--
  sta seed+0
  cmp #0
  rts
*/
function galois16 () {
  for (let k = 0; k < 8; k++) {
    const lsb = seed & 0x8000
    seed = (seed << 1) & 0xFFFF
    if (lsb)
      seed ^= 0x0039
  }
  return seed & 0xFF
}

/**
 * Formats an 8-bit value as a two digit hexadecimal number.
 * @param {number} n The number to format.
 * @returns {string} The value formated as a two digit hexidecimal number.
 */
function formatHex8 (n) {
  if (typeof n !== 'number') {
    n = 0
  }
  let f = (n & 0xFF).toString(16).toUpperCase()
  return f.length < 2 ? `0${f}` : f
}

/**
 * Tests the javascript `galois16` method to ensure I've faithfully translated
 * the original 6502.
 */
function testGalois16 () {
  console.log('Testing `galois16` implementation...')
  const expected = [
    '00 39 00 41 DD 79 1B A8 DB 23 F9 89 65 4E 73 9D',
    'E5 86 CA 29 8D 78 48 BD 79 7B 59 82 9B E7 16 F3'
  ].join(' ')
  const computed = Array(32)
    .fill(0).map(() => galois16()).map(formatHex8).join(' ')
  if (expected !== computed) {
    console.log('Error: galois16 does not match 6502 implementation.')
    console.log('Expected:', expected)
    console.log('Actual:  ', computed)
  } else {
    console.log('Success! Output bytes match.')
  }
  console.log('')
}

/**
 * Tests the modulus method for generating D20 rolls with `galois16`.
 */
function testModD20 () {
  console.log('Testing modulus method for D20 rolls:')
  const MAX_ITERATIONS = Math.pow(2, 16)
  const histogram = Array(20).fill(0)
  for (let k = 0; k < MAX_ITERATIONS; k++) {
    histogram[galois16() % 20]++
  }
  histogram.forEach((n, i) => {
    console.log(`${i+1} -> ${n} (${(1.0*n/MAX_ITERATIONS).toFixed(5)}%)`)
  })
  console.log('')
}

/**
 * Tests rejection sampling method for generating D20 rolls with `galois16`.
 */
function testRejectionSamplingD20 () {
  console.log('Testing rejection sampling for D20 rolls:')
  const MAX_ITERATIONS = Math.pow(2, 16)
  const histogram = Array(20).fill(0)
  for (let k = 0; k < MAX_ITERATIONS; k++) {
    let sample = 0
    do {
      sample = galois16() & 0b00011111
    } while (sample > 19)
    histogram[sample]++
  }
  histogram.forEach((n, i) => {
    console.log(`${i+1} -> ${n} (${(1.0*n/MAX_ITERATIONS).toFixed(5)}%)`)
  })
  console.log('')
}

testGalois16()
testModD20()
testRejectionSamplingD20()
