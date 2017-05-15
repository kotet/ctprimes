/**
    This module provides arrays of prime numbers that are available at compile-time.
    Arrays are calculated as long as you need, using CTFE.
*/
module ctprimes;

import std.traits : isIntegral;

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
        T[] result = [];
        T n = 2;
        while (result.length < length)
        {
            bool isprime = () {
                foreach (i; 2 .. n)
                {
                    if (n % i == 0)
                        return false;
                }
                return true;
            }();
            if (isprime)
                result ~= n;
            n++;
        }
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

    auto primes2 = ctPrimes!1;
    assert(primes2 == [2]);
}

/**
    Construct an array of all prime numbers less than N, using CTFE.
    The type of the array is `typeof(N)[]`.

    Params:
        N = All elements of result are less than this value
*/
public template ctPrimesLessThan(N) if (isIntegral!(typeof(N)))
{
    enum typeof(N)[] ctPrimesLessThan = () {  }();
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

    auto primes2 = ctPrimesLessThan!2;
    assert(primes2 == []);

    auto primes3 = ctPrimesLessThan!0;
    assert(primes3 == []);
}
