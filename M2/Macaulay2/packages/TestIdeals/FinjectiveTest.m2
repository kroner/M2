TEST /// --Fedder's original F-injective not F-pure, deformation examples
    S = ZZ/2[x,y,z,u,v];
    I =  minors(2, matrix {{x^2, z, v}, {u, z, y^2}});
    J = I + ideal(x,y);
    assert(isFInjective(S/I));
    assert(isFInjective(S/J));
    assert(isFPure(S/J));
    assert(not isFPure(S/I));
///

TEST /// --cone over P1 times supersingular elliptic curve (non CM)
    S = ZZ/3[xs, ys, zs, xt, yt, zt];
    EP1 = ZZ/3[x,y,z,s,t]/ideal(x^3+y^2*z-x*z^2); --supersingular elliptic curve
    f = map(EP1, S, {x*s, y*s, z*s, x*t, y*t, z*t});
    R = S/(ker f);
    assert(not isFInjective(R));
///

TEST /// --cone over P1 times ordinary elliptic curve (non CM)
    S = ZZ/3[xs, ys, zs, xt, yt, zt];
    EP1 = ZZ/3[x,y,z,s,t]/ideal(y^2*z-x^3+x*y*z); --ordinary elliptic curve
    f = map(EP1, S, {x*s, y*s, z*s, x*t, y*t, z*t});
    R = S/(ker f);
    assert( isFInjective(R) );
///

TEST /// --HSLGModule cone over ordinary elliptic curve
    R = ZZ/7[x,y,z]/ideal(x^3+y^3+z^3);
    HSLmod = HSLGModule(R);
    assert(HSLmod#0 == HSLmod#1);
///

TEST /// --the isLocal option
    R = ZZ/5[x,y,z]/ideal((x-2)^3 + y^3 + z^3); --supersingular
    assert( isFInjective(R, IsLocal=>true) );
    assert( not isFInjective(R) );
///

TEST /// --HSLGModule cone over supersingular elliptic curve
    R = ZZ/5[x,y,z]/ideal(x^3+y^3+z^3);
    HSLmod = HSLGModule(R);
    assert(not (HSLmod#0 == HSLmod#1));
///

TEST /// --HSLGModule cone over supersingular elliptic curve
    R = ZZ/7[x,y]
    HSLmod = HSLGModule(5/6, y^2-x^3);
    assert((HSLmod#0 == HSLmod#1));
///

TEST /// --isFInjective of a ring with no variables
    R = ZZ/17[];
    assert(isFInjective(R));
///

TEST /// --checking brute force F-injective vs canonicalStrategy
    R = ZZ/3[x,y,z]/ideal(y^2*z-x^3+x*y*z); --ordinary
    assert(isFInjective(R));
    assert(isFInjective(R, CanonicalStrategy=>null));
    S = ZZ/3[x,y,z]/ideal(x^3+y^2*z-x*z^2); --supersingular
    assert(not isFInjective(S));
    assert(not isFInjective(S, CanonicalStrategy=>null));
///
