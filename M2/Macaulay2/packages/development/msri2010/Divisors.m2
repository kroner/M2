newPackage(
        "Divisors",
        Version => "0.1", 
        Date => "January 10, 2010",
        Authors => {
	     {    Name => "Florian Geiss", Email => "fg@math.uni-sb.de", HomePage => "http://www.math.uni-sb.de/ag/schreyer/fg/"},
	     {    Name => "Krishna Hanumanthu", Email => "khanuma@math.ku.edu", HomePage =>"http://www.math.ku.edu/~khanuma"}
	     },
        Headline => "Representation and computation of divisors",
        DebuggingMode => true
        )

export{
     purify,
     Divisor,
     divisor,
     normalForm,
     globalSections,
     sectionIdeal,
     linearlyEquivalent,
     effective,
     divisorFromModule,
     canonicalDivisor
     }


Divisor = new Type of BasicList

purify = I -> (
         -- Assuming ring I is S2, and I is not 0, returns the 
         -- pure codimension 1 part of I.
         -- Find a nonzero element of I:
         M := compress gens I;
         -- Explanation: gens I is 
         -- the matrix of generators of I; compress
         -- removes the entries that are 0
         -- and := makes M a local variable.
         if numgens source M == 0 
         then error "purify: expected nonzero ideal";
         f := ideal M_(0,0);
         -- f is the ideal generated by the first entry.
         -- Since ring I is S2, the ideal f is 
         -- pure codimension 1.  Thus
         f:(f:I)
         -- is the pure codimension 1 part. (The last 
         -- expression given in a function is the returned
         -- value, provided the semicolon is left off.)
         )
    
-- representation of divisors by pairs of ideals
divisor = method()
divisor(Ideal,Ideal) := (I,J) -> new Divisor from {purify I,purify J};
divisor Ideal        := I     -> divisor(I, ideal 1_(ring I));

-- compute the normalForm of a divisor
normalForm = method()
normalForm Divisor := D -> new Divisor from {D#0 : D#1, D#1 : D#0};

-- linear equivalence and group operations on divisors
Divisor == Divisor := (D,E) -> toList normalForm D == toList normalForm E;
Divisor + Divisor := (D,E) -> divisor(D#0 * E#0, D#1 * E#1);
- Divisor := (D) -> new Divisor from {D#1, D#0};
Divisor - Divisor := (D,E) -> D + (-E);
ZZ Divisor := ZZ * Divisor := (n,D) -> if n>=0 then divisor((D#0)^n, (D#1)^n) else - divisor((D#0)^(-n), (D#1)^(-n));

-- compute the global setions of a divisor
globalSections = method()
globalSections Divisor := (D) -> (
          -- First let's grab the parts (I,J) of D.
          I := D#0;
          J := D#1;
          -- Let 'f' be the first element of the 
          -- matrix of generators of the ideal I.
          f := (gens I)_(0,0);
          -- Now compute the basis of global sections
          -- just as above
          LD := basis(degree f, purify((f*J) : I));
          LD = super (LD ** (ring target LD));
          -- Return both this vector space and the denominator
          {LD, f});


sectionIdeal = (f,g,D) -> (
     I:=D#0;
     J:=D#1;
     purify((f*I):g):J)

linearlyEquivalent=method()
linearlyEquivalent(Divisor,Divisor):=(D,E) -> (
          F := normalForm(D-E);
          LB := globalSections F;
          L := LB#0;
          -- L is the matrix of numerators. Thus numgens source L
          -- is the dimension of the space of global sections.
          if numgens source L != 1 
          then false
          else (
              R := ring L;
              V := sectionIdeal(L_(0,0), LB#1, F);
              if V == ideal(1_R) 
                then true else false)
          );
     
linearlyEquivalent(Divisor,Divisor,Boolean):=(D,E,Section) -> (
          F := normalForm(D-E);
          LB := globalSections F;
          L := LB#0;
          -- L is the matrix of numerators. Thus numgens source L
          -- is the dimension of the space of global sections.
          if numgens source L != 1 
          then false
          else (
              R := ring L;
              V := sectionIdeal(L_(0,0), LB#1, F);
              if V == ideal(1_R) then (true,L_(0,0)/LB#1)  else false));       
     



effective = (D) -> (
          LB := globalSections D;
          L := LB#0;  -- the matrix of numerators
          if numgens source L == 0 
          then error(toString D + " does not have global sections")
          else divisor sectionIdeal(L_(0,0), LB#1, D));
  
divisorFromModule = M -> (
        -- given a module M, returns the divisor of the image
        -- of a nonzero homomorphism to R, suitably twisted.
        -- first get the presentation of M
          I1 := transpose (syz transpose presentation M)_{0};
        -- The degree is
          d := (degrees target I1)_0_0;
        -- We need to balance the degree d with a power
        -- of the first nonzero generator of the ring.
          var1 := (compress vars ring M)_{0};
        -- Now fix up the degrees.
          if d==0 then divisor ideal I1
          else if d>0 then divisor(
                        ideal (I1**dual(target I1)),
                        ideal var1^d
                       )                          
          else divisor ideal( 
                     var1^(-d)**I1**dual target I1
                     )
      );

canonicalDivisor= SX ->(
        -- Given a ring SX, computes a canonical divisor for SX
        I := ideal presentation SX;
        S := ring I;
        embcodim := codim I;
        M := Ext^embcodim(coker gens I,S^{-numgens S});
        M = coker substitute(presentation M, SX);
        divisorFromModule M
        );
   
beginDocumentation()

doc ///
Key
  Divisors
Headline 
  Representation and computation of divisors
///

doc ///
Key
 purify
Headline
 returns the pure codimension 1 part of I.
Usage
 J=purify(I)
Inputs
 I:Ideal
   an ideal
Outputs
 J:Ideal
   the codimension 1 part of I
Consequences
Description
  Text
  Example
    R = ZZ/5[a,b];
    purify ideal(a^2,a*b)
Caveat
  In the current implementation, the ring R is assumed to S2.
SeeAlso
///


doc ///
Key 
  divisor
Headline
  defines a divisor
///  



doc ///
Key
 (divisor,Ideal,Ideal)
Headline
 defines a divisor from a pair of ideals
Usage
 D=divisor(I,J)
Inputs
 I:Ideal
   locus of zeros
 J:Ideal
   locus of poles
Outputs
 D:Divisor
   Divisor associated to I and J
Consequences
Description
  Text
  Example
    kk = ZZ/31991;
    R = kk[x,y,z]/(y^2*z - x*(x-z)*(x+3*z));
    divisor(ideal (y,x-z), ideal(y-6*z,x-3*z))
Caveat
SeeAlso
///

doc ///
Key
 (divisor,Ideal)
Headline
 defines a divisor from an ideal
Usage
 D=divisor(I)
Inputs
 I:Ideal
   locus of zeros
Outputs
 D:Divisor
   Divisor associated to I
Consequences
Description
  Text
  Example
    kk = ZZ/31991;
    R = kk[x,y,z]/(y^2*z - x*(x-z)*(x+3*z));
    divisor(ideal (y,x-z))
Caveat
SeeAlso
///

doc ///
Key
 normalForm
Headline
  returns the normal form of a divisor
/// 

doc ///
Key
 (normalForm,Divisor)
Headline
 returns the normal form of a divisor
Usage
 E=normalForm(D)
Inputs
 D:Divisor
   a divisor
Outputs
 E:Divisor
   normal form of D
Consequences
Description
  Text
  Example
    R = QQ[x,y];
    I = ideal x^2;
    J = ideal x;
    D = divisor(I,J)
    E = normalForm(D)
Caveat
SeeAlso
///

doc ///
Key
 (symbol+,Divisor,Divisor)
Headline
 Addition of Divisors
Usage
 F = D + E
Inputs
 D:Divisor
   a divisor
 E:Divisor
   another divisor
Outputs
 F:Divisor
   sum of D and E
Consequences
Description
  Text
  Example
    R = QQ[x,y];
    D = divisor ideal x^2;
    E = divisor ideal y^4;
    F = D + E
Caveat
SeeAlso
///
 

 
  
doc ///
Key
 (symbol-,Divisor)
Headline
 Negation of Divisors
Usage
 F = - D
Inputs
 D:Divisor
   a divisor
Outputs
 F:Divisor
   negative of D
Consequences
Description
  Text
  Example
    R = QQ[x,y];
    D = divisor ideal x^2;
    F = - D 
Caveat
SeeAlso
///

doc ///
Key
 (symbol-,Divisor,Divisor)
Headline
 Difference of Divisors
Usage
 F = D - E
Inputs
 D:Divisor
   a divisor
 E:Divisor
   another divisor
Outputs
 F:Divisor
   difference of D and E
Consequences
Description
  Text
  Example
    R = QQ[x,y];
    D = divisor ideal x^2;
    E = divisor ideal y^4;
    F = D - E
Caveat
SeeAlso
///


doc ///
Key
 (symbol*,ZZ,Divisor)
Headline
 Multiplication of Divisors with integers
Usage
 E =  a*D
 E =  a D
Inputs
 a:ZZ
   an integer
 D:Divisor
   a divisor
Outputs
 E:Divisor
   a times D
Consequences
Description
  Text
  Example
    R = QQ[x,y];
    D = divisor ideal x^2;
    a = -2;
    E = a*D
Caveat
SeeAlso
///


doc ///
Key 
  globalSections
Headline
 computes the global sections of a divisor
///  


doc ///
Key
 (globalSections,Divisor)
Headline
 computes the global sections of a divisor
Usage
 l=globalSections(D)
Inputs
 D:Divisor
   a divisor
Outputs
 l:List
   a list with two entries. The first entry contains the numerators of a basis of the space of global sections. The second entry contains the common denominator.
Consequences
Description
  Text
  Example
    R = QQ[x,y];
    l = globalSections divisor ideal x^4
Caveat
SeeAlso
///

doc ///
Key
 sectionIdeal
Headline
 computes the zeros of a section 
Usage
 I=sectionIdeal(f,g,D)
Inputs
 f:RingElement
   numerator of the section
 g:RingElement
   denominator of the section
 D:Divisor
   related divisor
Outputs
 l:List
   a list with two entries. The first entry contains the numerators of a basis of the space of global sections. The second entry contains the common denominator.
Consequences
Description
  Text
  Example
    R = QQ[x,y];
    D = divisor ideal x^4;
    l = globalSections D
    sectionIdeal(l_0_(0,1),l_1,D)
Caveat
SeeAlso
///

doc ///
Key
  linearlyEquivalent
Headline
  checks if two divisors are linearly equivalent
///


end
