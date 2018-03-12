type
  mp_digit* = distinct uint32
  mp_word* = distinct uint64

const
  MP_LT* = -1
  MP_EQ* = 0
  MP_GT* = 1
  MP_ZPOS* = 0
  MP_NEG* = 1
  MP_OKAY* = 0
  MP_MEM* = -2
  MP_VAL* = -3
  MP_RANGE* = MP_VAL
  MP_YES* = 1
  MP_NO* = 0

##  Primality generation flags

const
  LTM_PRIME_BBS* = 0x00000001
  LTM_PRIME_SAFE* = 0x00000002
  LTM_PRIME_2MSB_ON* = 0x00000008

##  you'll have to tune these...

var
  KARATSUBA_MUL_CUTOFF* {.importc: "KARATSUBA_MUL_CUTOFF".}: cint
  KARATSUBA_SQR_CUTOFF* {.importc: "KARATSUBA_SQR_CUTOFF".}: cint
  TOOM_MUL_CUTOFF* {.importc: "TOOM_MUL_CUTOFF".}: cint
  TOOM_SQR_CUTOFF* {.importc: "TOOM_SQR_CUTOFF".}: cint


type
  mp_int* {.importc: "mp_int", header: "tommath.h", bycopy.} = object
    used* {.importc: "used".}: cint
    alloc* {.importc: "alloc".}: cint
    sign* {.importc: "sign".}: cint
    dp* {.importc: "dp".}: ptr mp_digit


##  callback for mp_prime_random, should fill dst with random bytes and return how many read [upto len]

type
  ltm_prime_callback* = proc (dst: ptr cuchar; len: cint; dat: pointer): cint

template USED*(m: untyped): untyped =
  ((m).used)

template DIGIT*(m, k: untyped): untyped =
  ((m).dp[(k)])

template SIGN*(m: untyped): untyped =
  ((m).sign)

##  error code to char* string

proc mp_error_to_string*(code: cint): cstring {.importc: "mp_error_to_string".}
##  ---> init and deinit bignum functions <---
##  init a bignum

proc mp_init*(a: ptr mp_int): cint {.importc: "mp_init".}
##  free a bignum

proc mp_clear*(a: ptr mp_int) {.importc: "mp_clear".}
##  init a null terminated series of arguments

proc mp_init_multi*(mp: ptr mp_int): cint {.varargs, importc: "mp_init_multi".}
##  clear a null terminated series of arguments

proc mp_clear_multi*(mp: ptr mp_int) {.varargs, importc: "mp_clear_multi".}
##  exchange two ints

proc mp_exch*(a: ptr mp_int; b: ptr mp_int) {.importc: "mp_exch".}
##  shrink ram required for a bignum

proc mp_shrink*(a: ptr mp_int): cint {.importc: "mp_shrink".}
##  grow an int to a given size

proc mp_grow*(a: ptr mp_int; size: cint): cint {.importc: "mp_grow".}
##  init to a given number of digits

proc mp_init_size*(a: ptr mp_int; size: cint): cint {.importc: "mp_init_size".}
##  ---> Basic Manipulations <---

template mp_iszero*(a: untyped): untyped =
  (if ((a).used == 0): MP_YES else: MP_NO)

template mp_iseven*(a: untyped): untyped =
  (if (((a).used > 0) and (((a).dp[0] and 1) == 0)): MP_YES else: MP_NO)

template mp_isodd*(a: untyped): untyped =
  (if (((a).used > 0) and (((a).dp[0] and 1) == 1)): MP_YES else: MP_NO)

template mp_isneg*(a: untyped): untyped =
  (if ((a).sign != MP_ZPOS): MP_YES else: MP_NO)

##  set to zero

proc mp_zero*(a: ptr mp_int) {.importc: "mp_zero".}
##  set to a digit

proc mp_set*(a: ptr mp_int; b: mp_digit) {.importc: "mp_set".}
##  set a 32-bit const

proc mp_set_int*(a: ptr mp_int; b: culong): cint {.importc: "mp_set_int".}
##  set a platform dependent unsigned long value

proc mp_set_long*(a: ptr mp_int; b: culong): cint {.importc: "mp_set_long".}
##  set a platform dependent unsigned long long value

proc mp_set_long_long*(a: ptr mp_int; b: culonglong): cint {.
    importc: "mp_set_long_long".}
##  get a 32-bit value

proc mp_get_int*(a: ptr mp_int): culong {.importc: "mp_get_int".}
##  get a platform dependent unsigned long value

proc mp_get_long*(a: ptr mp_int): culong {.importc: "mp_get_long".}
##  get a platform dependent unsigned long long value

proc mp_get_long_long*(a: ptr mp_int): culonglong {.importc: "mp_get_long_long".}
##  initialize and set a digit

proc mp_init_set*(a: ptr mp_int; b: mp_digit): cint {.importc: "mp_init_set".}
##  initialize and set 32-bit value

proc mp_init_set_int*(a: ptr mp_int; b: culong): cint {.importc: "mp_init_set_int".}
##  copy, b = a

proc mp_copy*(a: ptr mp_int; b: ptr mp_int): cint {.importc: "mp_copy".}
##  inits and copies, a = b

proc mp_init_copy*(a: ptr mp_int; b: ptr mp_int): cint {.importc: "mp_init_copy".}
##  trim unused digits

proc mp_clamp*(a: ptr mp_int) {.importc: "mp_clamp".}
##  import binary data

proc mp_import*(rop: ptr mp_int; count: csize; order: cint; size: csize; endian: cint;
               nails: csize; op: pointer): cint {.importc: "mp_import".}
##  export binary data

proc mp_export*(rop: pointer; countp: ptr csize; order: cint; size: csize; endian: cint;
               nails: csize; op: ptr mp_int): cint {.importc: "mp_export".}
##  ---> digit manipulation <---
##  right shift by "b" digits

proc mp_rshd*(a: ptr mp_int; b: cint) {.importc: "mp_rshd".}
##  left shift by "b" digits

proc mp_lshd*(a: ptr mp_int; b: cint): cint {.importc: "mp_lshd".}
##  c = a / 2**b, implemented as c = a >> b

proc mp_div_2d*(a: ptr mp_int; b: cint; c: ptr mp_int; d: ptr mp_int): cint {.
    importc: "mp_div_2d".}
##  b = a/2

proc mp_div_2*(a: ptr mp_int; b: ptr mp_int): cint {.importc: "mp_div_2".}
##  c = a * 2**b, implemented as c = a << b

proc mp_mul_2d*(a: ptr mp_int; b: cint; c: ptr mp_int): cint {.importc: "mp_mul_2d".}
##  b = a*2

proc mp_mul_2*(a: ptr mp_int; b: ptr mp_int): cint {.importc: "mp_mul_2".}
##  c = a mod 2**b

proc mp_mod_2d*(a: ptr mp_int; b: cint; c: ptr mp_int): cint {.importc: "mp_mod_2d".}
##  computes a = 2**b

proc mp_2expt*(a: ptr mp_int; b: cint): cint {.importc: "mp_2expt".}
##  Counts the number of lsbs which are zero before the first zero bit

proc mp_cnt_lsb*(a: ptr mp_int): cint {.importc: "mp_cnt_lsb".}
##  I Love Earth!
##  makes a pseudo-random int of a given size

proc mp_rand*(a: ptr mp_int; digits: cint): cint {.importc: "mp_rand".}
##  ---> binary operations <---
##  c = a XOR b

proc mp_xor*(a: ptr mp_int; b: ptr mp_int; c: ptr mp_int): cint {.importc: "mp_xor".}
##  c = a OR b

proc mp_or*(a: ptr mp_int; b: ptr mp_int; c: ptr mp_int): cint {.importc: "mp_or".}
##  c = a AND b

proc mp_and*(a: ptr mp_int; b: ptr mp_int; c: ptr mp_int): cint {.importc: "mp_and".}
##  ---> Basic arithmetic <---
##  b = -a

proc mp_neg*(a: ptr mp_int; b: ptr mp_int): cint {.importc: "mp_neg".}
##  b = |a|

proc mp_abs*(a: ptr mp_int; b: ptr mp_int): cint {.importc: "mp_abs".}
##  compare a to b

proc mp_cmp*(a: ptr mp_int; b: ptr mp_int): cint {.importc: "mp_cmp".}
##  compare |a| to |b|

proc mp_cmp_mag*(a: ptr mp_int; b: ptr mp_int): cint {.importc: "mp_cmp_mag".}
##  c = a + b

proc mp_add*(a: ptr mp_int; b: ptr mp_int; c: ptr mp_int): cint {.importc: "mp_add".}
##  c = a - b

proc mp_sub*(a: ptr mp_int; b: ptr mp_int; c: ptr mp_int): cint {.importc: "mp_sub".}
##  c = a * b

proc mp_mul*(a: ptr mp_int; b: ptr mp_int; c: ptr mp_int): cint {.importc: "mp_mul".}
##  b = a*a

proc mp_sqr*(a: ptr mp_int; b: ptr mp_int): cint {.importc: "mp_sqr".}
##  a/b => cb + d == a

proc mp_div*(a: ptr mp_int; b: ptr mp_int; c: ptr mp_int; d: ptr mp_int): cint {.
    importc: "mp_div".}
##  c = a mod b, 0 <= c < b

proc mp_mod*(a: ptr mp_int; b: ptr mp_int; c: ptr mp_int): cint {.importc: "mp_mod".}
##  ---> single digit functions <---
##  compare against a single digit

proc mp_cmp_d*(a: ptr mp_int; b: mp_digit): cint {.importc: "mp_cmp_d".}
##  c = a + b

proc mp_add_d*(a: ptr mp_int; b: mp_digit; c: ptr mp_int): cint {.importc: "mp_add_d".}
##  c = a - b

proc mp_sub_d*(a: ptr mp_int; b: mp_digit; c: ptr mp_int): cint {.importc: "mp_sub_d".}
##  c = a * b

proc mp_mul_d*(a: ptr mp_int; b: mp_digit; c: ptr mp_int): cint {.importc: "mp_mul_d".}
##  a/b => cb + d == a

proc mp_div_d*(a: ptr mp_int; b: mp_digit; c: ptr mp_int; d: ptr mp_digit): cint {.
    importc: "mp_div_d".}
##  a/3 => 3c + d == a

proc mp_div_3*(a: ptr mp_int; c: ptr mp_int; d: ptr mp_digit): cint {.importc: "mp_div_3".}
##  c = a**b

proc mp_expt_d*(a: ptr mp_int; b: mp_digit; c: ptr mp_int): cint {.importc: "mp_expt_d".}
proc mp_expt_d_ex*(a: ptr mp_int; b: mp_digit; c: ptr mp_int; fast: cint): cint {.
    importc: "mp_expt_d_ex".}
##  c = a mod b, 0 <= c < b

proc mp_mod_d*(a: ptr mp_int; b: mp_digit; c: ptr mp_digit): cint {.importc: "mp_mod_d".}
##  ---> number theory <---
##  d = a + b (mod c)

proc mp_addmod*(a: ptr mp_int; b: ptr mp_int; c: ptr mp_int; d: ptr mp_int): cint {.
    importc: "mp_addmod".}
##  d = a - b (mod c)

proc mp_submod*(a: ptr mp_int; b: ptr mp_int; c: ptr mp_int; d: ptr mp_int): cint {.
    importc: "mp_submod".}
##  d = a * b (mod c)

proc mp_mulmod*(a: ptr mp_int; b: ptr mp_int; c: ptr mp_int; d: ptr mp_int): cint {.
    importc: "mp_mulmod".}
##  c = a * a (mod b)

proc mp_sqrmod*(a: ptr mp_int; b: ptr mp_int; c: ptr mp_int): cint {.importc: "mp_sqrmod".}
##  c = 1/a (mod b)

proc mp_invmod*(a: ptr mp_int; b: ptr mp_int; c: ptr mp_int): cint {.importc: "mp_invmod".}
##  c = (a, b)

proc mp_gcd*(a: ptr mp_int; b: ptr mp_int; c: ptr mp_int): cint {.importc: "mp_gcd".}
##  produces value such that U1*a + U2*b = U3

proc mp_exteuclid*(a: ptr mp_int; b: ptr mp_int; U1: ptr mp_int; U2: ptr mp_int;
                  U3: ptr mp_int): cint {.importc: "mp_exteuclid".}
##  c = [a, b] or (a*b)/(a, b)

proc mp_lcm*(a: ptr mp_int; b: ptr mp_int; c: ptr mp_int): cint {.importc: "mp_lcm".}
##  finds one of the b'th root of a, such that |c|**b <= |a|
##
##  returns error if a < 0 and b is even
##

proc mp_n_root*(a: ptr mp_int; b: mp_digit; c: ptr mp_int): cint {.importc: "mp_n_root".}
proc mp_n_root_ex*(a: ptr mp_int; b: mp_digit; c: ptr mp_int; fast: cint): cint {.
    importc: "mp_n_root_ex".}
##  special sqrt algo

proc mp_sqrt*(arg: ptr mp_int; ret: ptr mp_int): cint {.importc: "mp_sqrt".}
##  special sqrt (mod prime)

proc mp_sqrtmod_prime*(arg: ptr mp_int; prime: ptr mp_int; ret: ptr mp_int): cint {.
    importc: "mp_sqrtmod_prime".}
##  is number a square?

proc mp_is_square*(arg: ptr mp_int; ret: ptr cint): cint {.importc: "mp_is_square".}
##  computes the jacobi c = (a | n) (or Legendre if b is prime)

proc mp_jacobi*(a: ptr mp_int; n: ptr mp_int; c: ptr cint): cint {.importc: "mp_jacobi".}
##  used to setup the Barrett reduction for a given modulus b

proc mp_reduce_setup*(a: ptr mp_int; b: ptr mp_int): cint {.importc: "mp_reduce_setup".}
##  Barrett Reduction, computes a (mod b) with a precomputed value c
##
##  Assumes that 0 < a <= b*b, note if 0 > a > -(b*b) then you can merely
##  compute the reduction as -1 * mp_reduce(mp_abs(a)) [pseudo code].
##

proc mp_reduce*(a: ptr mp_int; b: ptr mp_int; c: ptr mp_int): cint {.importc: "mp_reduce".}
##  setups the montgomery reduction

proc mp_montgomery_setup*(a: ptr mp_int; mp: ptr mp_digit): cint {.
    importc: "mp_montgomery_setup".}
##  computes a = B**n mod b without division or multiplication useful for
##  normalizing numbers in a Montgomery system.
##

proc mp_montgomery_calc_normalization*(a: ptr mp_int; b: ptr mp_int): cint {.
    importc: "mp_montgomery_calc_normalization".}
##  computes x/R == x (mod N) via Montgomery Reduction

proc mp_montgomery_reduce*(a: ptr mp_int; m: ptr mp_int; mp: mp_digit): cint {.
    importc: "mp_montgomery_reduce".}
##  returns 1 if a is a valid DR modulus

proc mp_dr_is_modulus*(a: ptr mp_int): cint {.importc: "mp_dr_is_modulus".}
##  sets the value of "d" required for mp_dr_reduce

proc mp_dr_setup*(a: ptr mp_int; d: ptr mp_digit) {.importc: "mp_dr_setup".}
##  reduces a modulo b using the Diminished Radix method

proc mp_dr_reduce*(a: ptr mp_int; b: ptr mp_int; mp: mp_digit): cint {.
    importc: "mp_dr_reduce".}
##  returns true if a can be reduced with mp_reduce_2k

proc mp_reduce_is_2k*(a: ptr mp_int): cint {.importc: "mp_reduce_is_2k".}
##  determines k value for 2k reduction

proc mp_reduce_2k_setup*(a: ptr mp_int; d: ptr mp_digit): cint {.
    importc: "mp_reduce_2k_setup".}
##  reduces a modulo b where b is of the form 2**p - k [0 <= a]

proc mp_reduce_2k*(a: ptr mp_int; n: ptr mp_int; d: mp_digit): cint {.
    importc: "mp_reduce_2k".}
##  returns true if a can be reduced with mp_reduce_2k_l

proc mp_reduce_is_2k_l*(a: ptr mp_int): cint {.importc: "mp_reduce_is_2k_l".}
##  determines k value for 2k reduction

proc mp_reduce_2k_setup_l*(a: ptr mp_int; d: ptr mp_int): cint {.
    importc: "mp_reduce_2k_setup_l".}
##  reduces a modulo b where b is of the form 2**p - k [0 <= a]

proc mp_reduce_2k_l*(a: ptr mp_int; n: ptr mp_int; d: ptr mp_int): cint {.
    importc: "mp_reduce_2k_l".}
##  d = a**b (mod c)

proc mp_exptmod*(a: ptr mp_int; b: ptr mp_int; c: ptr mp_int; d: ptr mp_int): cint {.
    importc: "mp_exptmod".}
##  ---> Primes <---
##  number of primes

const
  PRIME_SIZE* = 256
##  table of first PRIME_SIZE primes

var ltm_prime_tab* {.importc: "ltm_prime_tab".}: array[PRIME_SIZE,
    mp_digit]

##  result=1 if a is divisible by one of the first PRIME_SIZE primes

proc mp_prime_is_divisible*(a: ptr mp_int; result: ptr cint): cint {.
    importc: "mp_prime_is_divisible".}
##  performs one Fermat test of "a" using base "b".
##  Sets result to 0 if composite or 1 if probable prime
##

proc mp_prime_fermat*(a: ptr mp_int; b: ptr mp_int; result: ptr cint): cint {.
    importc: "mp_prime_fermat".}
##  performs one Miller-Rabin test of "a" using base "b".
##  Sets result to 0 if composite or 1 if probable prime
##

proc mp_prime_miller_rabin*(a: ptr mp_int; b: ptr mp_int; result: ptr cint): cint {.
    importc: "mp_prime_miller_rabin".}
##  This gives [for a given bit size] the number of trials required
##  such that Miller-Rabin gives a prob of failure lower than 2^-96
##

proc mp_prime_rabin_miller_trials*(size: cint): cint {.
    importc: "mp_prime_rabin_miller_trials".}
##  performs t rounds of Miller-Rabin on "a" using the first
##  t prime bases.  Also performs an initial sieve of trial
##  division.  Determines if "a" is prime with probability
##  of error no more than (1/4)**t.
##
##  Sets result to 1 if probably prime, 0 otherwise
##

proc mp_prime_is_prime*(a: ptr mp_int; t: cint; result: ptr cint): cint {.
    importc: "mp_prime_is_prime".}
##  finds the next prime after the number "a" using "t" trials
##  of Miller-Rabin.
##
##  bbs_style = 1 means the prime must be congruent to 3 mod 4
##

proc mp_prime_next_prime*(a: ptr mp_int; t: cint; bbs_style: cint): cint {.
    importc: "mp_prime_next_prime".}
##  makes a truly random prime of a given size (bytes),
##  call with bbs = 1 if you want it to be congruent to 3 mod 4
##
##  You have to supply a callback which fills in a buffer with random bytes.  "dat" is a parameter you can
##  have passed to the callback (e.g. a state or something).  This function doesn't use "dat" itself
##  so it can be NULL
##
##  The prime generated will be larger than 2^(8*size).
##

template mp_prime_random*(a, t, size, bbs, cb, dat: untyped): untyped =
  mp_prime_random_ex(a, t, ((size) * 8) + 1, if (bbs == 1): LTM_PRIME_BBS else: 0, cb, dat)

##  makes a truly random prime of a given size (bits),
##
##  Flags are as follows:
##
##    LTM_PRIME_BBS      - make prime congruent to 3 mod 4
##    LTM_PRIME_SAFE     - make sure (p-1)/2 is prime as well (implies LTM_PRIME_BBS)
##    LTM_PRIME_2MSB_ON  - make the 2nd highest bit one
##
##  You have to supply a callback which fills in a buffer with random bytes.  "dat" is a parameter you can
##  have passed to the callback (e.g. a state or something).  This function doesn't use "dat" itself
##  so it can be NULL
##
##

proc mp_prime_random_ex*(a: ptr mp_int; t: cint; size: cint; flags: cint;
                        cb: ltm_prime_callback; dat: pointer): cint {.
    importc: "mp_prime_random_ex".}
##  ---> radix conversion <---

proc mp_count_bits*(a: ptr mp_int): cint {.importc: "mp_count_bits".}
proc mp_unsigned_bin_size*(a: ptr mp_int): cint {.importc: "mp_unsigned_bin_size".}
proc mp_read_unsigned_bin*(a: ptr mp_int; b: ptr cuchar; c: cint): cint {.
    importc: "mp_read_unsigned_bin".}
proc mp_to_unsigned_bin*(a: ptr mp_int; b: ptr cuchar): cint {.
    importc: "mp_to_unsigned_bin".}
proc mp_to_unsigned_bin_n*(a: ptr mp_int; b: ptr cuchar; outlen: ptr culong): cint {.
    importc: "mp_to_unsigned_bin_n".}
proc mp_signed_bin_size*(a: ptr mp_int): cint {.importc: "mp_signed_bin_size".}
proc mp_read_signed_bin*(a: ptr mp_int; b: ptr cuchar; c: cint): cint {.
    importc: "mp_read_signed_bin".}
proc mp_to_signed_bin*(a: ptr mp_int; b: ptr cuchar): cint {.
    importc: "mp_to_signed_bin".}
proc mp_to_signed_bin_n*(a: ptr mp_int; b: ptr cuchar; outlen: ptr culong): cint {.
    importc: "mp_to_signed_bin_n".}
proc mp_read_radix*(a: ptr mp_int; str: cstring; radix: cint): cint {.
    importc: "mp_read_radix".}
proc mp_toradix*(a: ptr mp_int; str: cstring; radix: cint): cint {.importc: "mp_toradix".}
proc mp_toradix_n*(a: ptr mp_int; str: cstring; radix: cint; maxlen: cint): cint {.
    importc: "mp_toradix_n".}
proc mp_radix_size*(a: ptr mp_int; radix: cint; size: ptr cint): cint {.
    importc: "mp_radix_size".}
proc mp_fread*(a: ptr mp_int; radix: cint; stream: ptr FILE): cint {.
    importc: "mp_fread".}
proc mp_fwrite*(a: ptr mp_int; radix: cint; stream: ptr FILE): cint {.
    importc: "mp_fwrite".}
template mp_read_raw*(mp, str, len: untyped): untyped =
  mp_read_signed_bin((mp), (str), (len))

template mp_raw_size*(mp: untyped): untyped =
  mp_signed_bin_size(mp)

template mp_toraw*(mp, str: untyped): untyped =
  mp_to_signed_bin((mp), (str))

template mp_read_mag*(mp, str, len: untyped): untyped =
  mp_read_unsigned_bin((mp), (str), (len))

template mp_mag_size*(mp: untyped): untyped =
  mp_unsigned_bin_size(mp)

template mp_tomag*(mp, str: untyped): untyped =
  mp_to_unsigned_bin((mp), (str))

template mp_tobinary*(M, S: untyped): untyped =
  mp_toradix((M), (S), 2)

template mp_tooctal*(M, S: untyped): untyped =
  mp_toradix((M), (S), 8)

template mp_todecimal*(M, S: untyped): untyped =
  mp_toradix((M), (S), 10)

template mp_tohex*(M, S: untyped): untyped =
  mp_toradix((M), (S), 16)
