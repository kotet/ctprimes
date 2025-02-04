/**
    This module provides arrays of prime numbers that are available at compile-time.
    Arrays are calculated as long as you need, using CTFE.

    This module uses the Sieve of Eratosthenes to find primes and so is
    reasonably performant, but care should be taken with memory usage. For
    example, with dmd without -lowmem, an array of only 26k primes will cost 3
    GB of memory during compilation.
*/
module ctprimes;

import std.traits : isIntegral;

pure size_t nth_prime_upper_bound(size_t n)
{
    import std.math : log;

    if (n > 6)
        return cast(size_t)(n * log(cast(float)n) + n * log(log(cast(float)n)));
    else
        return 11;
}

pure bool[] composites(size_t length)
{
    bool[] sieve; // false = prime. ignore indexes < 2
    sieve.length = length;
    foreach (i; 2 .. length)
    {
        if (!sieve[i])
        {
            size_t j = i + i;
            while (j < length)
            {
                sieve[j] = true;
                j += i;
            }
        }
    }
    return sieve;
}

/**
    Construct an array of prime number using CTFE.
    The length of the array is `length`, and the type is `T[length]`.

    Params:
        length = Length of array
        T = The type of the elements of the array
*/
public template ctPrimes(size_t length, T = size_t) if (isIntegral!T && 0 < length)
{
    enum T[length] ctPrimes = () {
        T[] result;
        result.reserve(length);
        auto sieve = composites(nth_prime_upper_bound(length));
        foreach (i; 2 .. sieve.length)
        {
            if (!sieve[i])
                result ~= cast(T) i;
        }
        result.length = length;
        return result;
    }();
}

///
@safe unittest
{
    import std.random : uniform;

    auto runtimevalue = uniform(0, 5);
    static assert(!__traits(compiles, {
            ctPrimes!runtimevalue; // Error: variable runtimevalue cannot be read at compile time
        }));

    static assert(__traits(compiles, {
            auto a = ctPrimes!(5, byte);
            auto b = ctPrimes!(5, ubyte);
            auto c = ctPrimes!(5, short);
            auto d = ctPrimes!(5, int);
            auto e = ctPrimes!(5, long);
        }));

    static assert(!__traits(compiles, {
            auto a = ctPrimes!(5, bool);
            auto b = ctPrimes!(5, char);
            auto c = ctPrimes!(5, double);
        }));

    auto primes1 = ctPrimes!(10);
    static assert(is(typeof(primes1) == size_t[10]));
    assert(primes1 == [2, 3, 5, 7, 11, 13, 17, 19, 23, 29]);

    auto primes2 = ctPrimes!(1);
    assert(primes2 == [2]);

    auto primes3 = ctPrimes!(10_000);
    assert(primes3[$ - 1] == 104_729);
}

/**
    Construct an array of all prime numbers less than N, using CTFE.
    The type of the array is `typeof(N)[]`.

    Params:
        N = All elements of result are less than this value
*/
public template ctPrimesLessThan(alias N) if (isIntegral!(typeof(N)))
{
    enum typeof(N)[] ctPrimesLessThan = () {
        typeof(N)[] result;
        result.reserve(N);
        auto sieve = composites(N);
        foreach (i; 2 .. sieve.length)
        {
            if (!sieve[i])
                result ~= cast(typeof(N)) i;
        }
        return result;
    }();
}

@safe unittest
{
    import std.random : uniform;

    auto runtimevalue = uniform(0, 5);
    static assert(!__traits(compiles, {
            ctPrimes!runtimevalue; // Error: variable runtimevalue cannot be read at compile time
        }));

    static assert(__traits(compiles, {
            auto a = ctPrimesLessThan!(cast(byte) 5);
            auto b = ctPrimesLessThan!(cast(ubyte) 5);
            auto c = ctPrimesLessThan!(cast(short) 5);
            auto d = ctPrimesLessThan!(cast(int) 5);
            auto e = ctPrimesLessThan!(cast(long) 5);
        }));

    static assert(!__traits(compiles, {
            auto a = ctPrimesLessThan!(true);
            auto b = ctPrimesLessThan!('a');
            auto c = ctPrimesLessThan!(5f);
        }));

    auto primes1 = ctPrimesLessThan!(10);
    static assert(is(typeof(primes1) == typeof([1])));
    assert(primes1 == [2, 3, 5, 7]);

    auto primes2 = ctPrimesLessThan!(2);
    assert(primes2 == []);

    auto primes3 = ctPrimesLessThan!(0);
    assert(primes3 == []);

    auto primes4 = ctPrimesLessThan!(104_730);
    assert(primes4[$ - 1] == 104_729);
}
