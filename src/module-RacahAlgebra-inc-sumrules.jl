
    
    """
    `RacahAlgebra.sumRulesForOneW3j(rex::RacahAlgebra.RacahExpression)`  
        ... attempts to find a simplification of the given Racah expression by using sum rules for one Wigner 3j symbol. 
            Once a simplification is found, no attempt is made to find another simplifcation for this set of rules.
            A (istrue, rex)::Tuple{Bool, RacahExpression} is returned but where rex has no meaning for !istrue.
    """
    function sumRulesForOneW3j(rex::RacahAlgebra.RacahExpression)
        
        # Loop through all Wigner 3j symbols
        for  (iaW3j, aW3j) in enumerate(rex.w3js)
            aRexList = RacahAlgebra.symmetricForms(aW3j)
            for  xaRex in aRexList
                ww = xaRex.w3js[1]
                #
                #   Rule:                  -m   ( j  j J )         -j
                #   ----        Sum(m) (-1)     (        )  =  (-1)    (2j + 1)  delta(J,0)  delta(M,0)
                #                               ( m -m M )
                #
                specialW3j = W3j(ww.ja, ww.ja, ww.jc, ww.ma, -ww.ma, ww.mc)
                if  ww == specialW3j
                    newPhase  = rex.phase  + xaRex.phase;     testPhase = newPhase   + ww.ma  
                    newWeight = rex.weight * xaRex.weight;    testWeight = newWeight
                    newW3js   = W3j[];       for (ibW3j, bW3j) in enumerate(rex.w3js)  if  iaW3j != ibW3j   push!(newW3js, bW3j)   end   end
                    #
                    if  RacahAlgebra.hasIndex(ww.ma, rex.summations)          &&  RacahAlgebra.hasNoVars([ww.ma], testPhase)      &&  
                        RacahAlgebra.hasNoVars([ww.ma], testWeight)           &&  RacahAlgebra.hasNoVars([ww.ma], rex.deltas)     &&  
                        RacahAlgebra.hasNoVars([ww.ma], rex.triangles)        &&  RacahAlgebra.hasNoVars([ww.ma], newW3js)        &&  
                        RacahAlgebra.hasNoVars([ww.ma], rex.w6js)             &&  RacahAlgebra.hasNoVars([ww.ma], rex.w9js)
                        newSummations = RacahAlgebra.removeIndex(ww.ma, rex.summations)
                        newDeltas = rex.deltas;      push!( newDeltas, Kronecker(ww.jc, 0));     push!( newDeltas, Kronecker(ww.mc, 0))
                        wa = RacahExpression( newSummations, newPhase + ww.ma - ww.ja, newWeight * (2*ww.ja+1), 
                                              newDeltas, rex.triangles, newW3js, rex.w6js, rex.w9js )
                        println(">> Apply sum rule for one W3j -- Sum(m) (-1)^m ...")
                        return( (true, wa) )
                    end
                end
            end
        end
        
        return( (false, RacahExpression()) )
    end


    """
    `RacahAlgebra.sumRulesForOneW6j(rex::RacahAlgebra.RacahExpression)`  
        ... attempts to find a simplification of the given Racah expression by using sum rules for one Wigner 6-j symbol. 
            Once a simplification is found, no attempt is made to find another simplifcation for this set of rules.
            A (istrue, rex)::Tuple{Bool, RacahExpression} is returned but where rex has no meaning for !istrue.
    """
    function sumRulesForOneW6j(rex::RacahAlgebra.RacahExpression)
        
        # Loop through all Wigner 6-j symbols
        for  (iaW6j, aW6j) in enumerate(rex.w6js)
            aRexList = RacahAlgebra.symmetricForms(aW6j)
            for  xaRex in aRexList
                ww = xaRex.w6js[1]
                #
                #   Rule:                     ( a  b  X )         2c
                #   ----        Sum(X)  [X]  {(         )}  = (-1)    delta(a,b,c)
                #                             ( a  b  c )
                #
                specialW6j = W6j(ww.a, ww.b, ww.c, ww.a, ww.b, ww.f)
                if  ww == specialW6j
                    newPhase  = rex.phase  + xaRex.phase;     testPhase = newPhase  
                    newWeight = rex.weight * xaRex.weight;    testWeight = newWeight / (2*ww.c+1)
                    newW6js    = W6j[];       for (ibW6j, bW6j) in enumerate(rex.w6js)  if  iaW6j != ibW6j   push!(newW6js, bW6j)   end   end
                    #
                    if  RacahAlgebra.hasIndex(ww.c, rex.summations)           &&  RacahAlgebra.hasNoVars([ww.c], testPhase)       &&  
                        RacahAlgebra.hasNoVars([ww.c], testWeight)            &&  RacahAlgebra.hasNoVars([ww.c], rex.deltas)      &&  
                        RacahAlgebra.hasNoVars([ww.c], rex.triangles)         &&  RacahAlgebra.hasNoVars([ww.c], rex.w3js)        &&  
                        RacahAlgebra.hasNoVars([ww.c], newW6js)               &&  RacahAlgebra.hasNoVars([ww.c], rex.w9js)  
                        newSummations = RacahAlgebra.removeIndex(ww.c, rex.summations)
                        newTriangles  = rex.triangles;      push!( newTriangles, Triangle(ww.a, ww.b, ww.f) )
                        wa = RacahExpression( newSummations, newPhase + 2*ww.f, newWeight / (2*ww.c+1), rex.deltas, newTriangles, rex.w3js, newW6js, rex.w9js )
                        println(">> Apply sum rule for one W6j -- Sum(X) ...")
                        return( (true, wa) )
                    end
                end
                #
                #   Rule:                  X       ( a  b  X )          -a-b      1/2
                #   ----        Sum(X) (-1)  [X]  {(         )}  =  (-1)     [a,b]    delta(c,0)
                #                                  ( b  a  c )
                #
                specialW6j = W6j(ww.a, ww.b, ww.c, ww.b, ww.a, ww.f)
                if  ww == specialW6j
                    newPhase  = rex.phase  + xaRex.phase;     testPhase  = newPhase - ww.c - ww.a - ww.b  
                    newWeight = rex.weight * xaRex.weight;    testWeight = newWeight / (2*ww.c+1) * sqrt((2*ww.a+1)*(2*ww.b+1))
                    newW6js   = W6j[];       for (ibW6j, bW6j) in enumerate(rex.w6js)  if  iaW6j != ibW6j   push!(newW6js, bW6j)   end   end
                    #
                    if  RacahAlgebra.hasIndex(ww.c, rex.summations)           &&  RacahAlgebra.hasNoVars([ww.c], testPhase)       &&  
                        RacahAlgebra.hasNoVars([ww.c], testWeight)            &&  RacahAlgebra.hasNoVars([ww.c], rex.deltas)      &&  
                        RacahAlgebra.hasNoVars([ww.c], rex.triangles)         &&  RacahAlgebra.hasNoVars([ww.c], rex.w3js)        &&  
                        RacahAlgebra.hasNoVars([ww.c], newW6js)               &&  RacahAlgebra.hasNoVars([ww.c], rex.w9js)  
                        newSummations = RacahAlgebra.removeIndex(ww.c, rex.summations)
                        newDeltas     = rex.deltas;      push!( newDeltas, Kronecker(ww.f, 0) )
                        wa = RacahExpression( newSummations, testPhase, testWeight, newDeltas, rex.triangles, rex.w3js, newW6js, rex.w9js )
                        println(">> Apply sum rule for one W6j -- Sum(X) (-1)^X ...")
                        return( (true, wa) )
                    end
                end
            end
        end
        
        return( (false, RacahExpression()) )
    end


    """
    `RacahAlgebra.sumRulesForOneW9j(rex::RacahAlgebra.RacahExpression)`  
        ... attempts to find a simplification of the given Racah expression by using sum rules for one Wigner 9-j symbol. 
            Once a simplification is found, no attempt is made to find another simplifcation for this set of rules.
            A (istrue, rex)::Tuple{Bool, RacahExpression} is returned but where rex has no meaning for !istrue.
    """
    function sumRulesForOneW9j(rex::RacahAlgebra.RacahExpression)
        
        # Loop through all Wigner 9-j symbols
        for  (iaW9j, aW9j) in enumerate(rex.w9js)
            aRexList = RacahAlgebra.symmetricForms(aW9j)
            for  xaRex in aRexList
                ww = xaRex.w9js[1]
                #
                #   Rule:                     ( a  b  e )      1
                #   ----        Sum(X)  [X]  {( c  d  f )}  = --- d(b,c) d(a,b,e) d(b,d,f)
                #                             ( e  f  X )     [b]
                #
                specialW9j = W9j(ww.a, ww.b, ww.c, ww.d, ww.e, ww.f, ww.c, ww.f, ww.i)
                if  ww == specialW9j
                    println("+++ rex.phase = $(rex.phase)   xaRex.phase = $(xaRex.phase)")
                    newPhase  = rex.phase  + xaRex.phase
                    testPhase = rewritePhase(newPhase, Basic[2*ww.a + 2*ww.b + 2*ww.c + 2*ww.d + 2*ww.e + 
                                                              2*ww.f + 2*ww.g + 2*ww.h + 2*ww.i], [ww.i] )
                    newWeight = rex.weight * xaRex.weight;   testWeight = newWeight  / (2*ww.i+1) / (2*ww.b+1)
                    newW9js   = W9j[];    for (ibW9j, bW9j) in enumerate(rex.w9js)  if  iaW9j != ibW9j   push!(newW9js, bW9j)   end   end
                    #
                    if  RacahAlgebra.hasIndex(ww.i, rex.summations)           &&  RacahAlgebra.hasNoVars([ww.i], testPhase)       &&  
                        RacahAlgebra.hasNoVars([ww.i], testWeight)            &&  RacahAlgebra.hasNoVars([ww.i], rex.deltas)      &&  
                        RacahAlgebra.hasNoVars([ww.i], rex.triangles)         &&  RacahAlgebra.hasNoVars([ww.i], rex.w3js)        &&  
                        RacahAlgebra.hasNoVars([ww.i], rex.w6js)              &&  RacahAlgebra.hasNoVars([ww.i], newW9js)
                        newSummations = RacahAlgebra.removeIndex(ww.i, rex.summations)
                        newDeltas    = rex.deltas;         push!( newDeltas, Kronecker(ww.b, ww.d))
                        newTriangles = rex.triangles;      push!( newTriangles, Triangle(ww.a, ww.b, ww.c));      
                                                           push!( newTriangles, Triangle(ww.b, ww.e, ww.f))
                        wa = RacahExpression( newSummations, testPhase, testWeight, newDeltas, newTriangles, rex.w3js, rex.w6js, newW9js )
                        println(">> Apply sum rule for one W9j -- Sum(X) ....")
                        return( (true, wa) )
                    end
                end
                #
                #   Rule:                  -X      ( a  b  e )          -a-b-c-d   1
                #   ----        Sum(X) (-1)  [X]  {( c  d  f )}  =  (-1)          ---  d(a,d) d(d,b,e) d(a,c,f)
                #                                  ( f  e  X )                    [a]
                #
                specialW9j = W9j(ww.a, ww.b, ww.c, ww.d, ww.e, ww.f, ww.f, ww.c, ww.i)
                if  ww == specialW9j
                    newPhase   = rex.phase  + xaRex.phase;     testPhase  = newPhase   + ww.i - ww.a - ww.b - ww.d - ww.e 
                    newWeight  = rex.weight * xaRex.weight;    testWeight = newWeight / (2*ww.i+1) / (2*ww.a+1)
                    newW9js   = W9j[];       for (ibW9j, bW9j) in enumerate(rex.w9js)  if  iaW9j != ibW9j   push!(newW9js, bW9j)   end   end
                    #
                    if  RacahAlgebra.hasIndex(ww.i, rex.summations)           &&  RacahAlgebra.hasNoVars([ww.i], testPhase)       &&  
                        RacahAlgebra.hasNoVars([ww.i], testWeight)            &&  RacahAlgebra.hasNoVars([ww.i], rex.deltas)      &&  
                        RacahAlgebra.hasNoVars([ww.i], rex.triangles)         &&  RacahAlgebra.hasNoVars([ww.i], rex.w3js)        &&  
                        RacahAlgebra.hasNoVars([ww.i], rex.w6js)              &&  RacahAlgebra.hasNoVars([ww.i], newW9js)
                        newSummations = RacahAlgebra.removeIndex(ww.i, rex.summations)
                        newDeltas    = rex.deltas;         push!( newDeltas, Kronecker(ww.a, ww.e))
                        newTriangles = rex.triangles;      push!( newTriangles, Triangle(ww.e, ww.b, ww.c));      
                                                           push!( newTriangles, Triangle(ww.a, ww.d, ww.f))
                        wa = RacahExpression( newSummations, testPhase, testWeight, newDeltas, newTriangles, rex.w3js, rex.w6js, newW9js )
                        println(">> Apply sum rule for one W9j -- Sum(-X) (-1)^-X ....")
                        return( (true, wa) )
                    end
                end
            end
        end
        
        return( (false, RacahExpression()) )
    end


    """
    `RacahAlgebra.sumRulesForTwoW3j(rex::RacahAlgebra.RacahExpression)`  
        ... attempts to find a simplification of the given Racah expression by using sum rules for one Wigner 3j symbol. 
            Once a simplification is found, no attempt is made to find another simplifcation for this set of rules.
            A (istrue, rex)::Tuple{Bool, RacahExpression} is returned but where rex has no meaning for !istrue.
    """
    function sumRulesForTwoW3j(rex::RacahAlgebra.RacahExpression)
        # Make sure that the sum rule could apply at all
        if  length(rex.summations) < 2  ||  length(rex.w3js) < 2     return( (false, RacahExpression()) )    end
        
        # Loop through all Wigner 3j symbols
        for  (ibW3j, bW3j) in enumerate(rex.w3js)
            bRexList = RacahAlgebra.symmetricForms(bW3j)
            for  xbRex in bRexList
                for  (iaW3j, aW3j) in enumerate(rex.w3js)
                    if  iaW3j == ibW3j    break    end
                    aRexList = RacahAlgebra.symmetricForms(aW3j)
                    for  xaRex in aRexList
                        wwa = xaRex.w3js[1];     wwb = xbRex.w3js[1]
                        #
                        #   Rule:                       ( j1 j2 j3 ) ( j1  j2  j3 )
                        #   ----        Sum(j3,m3) [j3] (          ) (            )   =  d(m1,m1p) d(m2,m2p)
                        #                               ( m1 m2 m3 ) ( m1p m2p m3 )
                        #
                        specialaW3j = W3j(wwa.ja, wwa.jb, wwa.jc, wwa.ma, wwa.mb, wwa.mc)
                        specialbW3j = W3j(wwa.ja, wwa.jb, wwa.jc, wwb.ma, wwb.mb, wwa.mc)
                        if  wwa == specialaW3j  &&  wwb == specialbW3j 
                            newPhase   = rex.phase  + xaRex.phase  + xbRex.phase;       
                            testPhase  = rewritePhase(newPhase, [2*wwa.ja + 2*wwa.jb + 2*wwa.jc], [wwa.jc, wwa.mc] )
                            newWeight  = rex.weight * xaRex.weight * xbRex.weight
                            testWeight = newWeight / (2*wwa.jc + 1) 
                            newW3js    = W3j[];       
                            for (icW3j, cW3j) in enumerate(rex.w3js)  if  icW3j != iaW3j &&  icW3j != ibW3j   push!(newW3js, cW3j)   end   end
                            #
                            if  RacahAlgebra.hasIndex(wwa.jc, rex.summations)            &&  RacahAlgebra.hasIndex(wwa.mc, rex.summations)   &&
                                RacahAlgebra.hasNoVars([wwa.jc, wwa.mc], testPhase)      &&  
                                RacahAlgebra.hasNoVars([wwa.jc, wwa.mc], testWeight)     &&  RacahAlgebra.hasNoVars([wwa.jc, wwa.mc], rex.deltas)    &&  
                                RacahAlgebra.hasNoVars([wwa.jc, wwa.mc], rex.triangles)  &&  RacahAlgebra.hasNoVars([wwa.jc, wwa.mc], newW3js)       &&  
                                RacahAlgebra.hasNoVars([wwa.jc, wwa.mc], rex.w6js)       &&  RacahAlgebra.hasNoVars([wwa.jc, wwa.mc], rex.w9js)
                                newSummations = RacahAlgebra.removeIndex([wwa.jc, wwa.mc], rex.summations)
                                newDeltas = rex.deltas;      push!( newDeltas, Kronecker(wwa.ma, wwb.ma));     push!( newDeltas, Kronecker(wwa.mb, wwb.mb))
                                wa = RacahExpression( newSummations, testPhase, testWeight, newDeltas, rex.triangles, newW3js, rex.w6js, rex.w9js )
                                println(">> Apply sum rule for two W3j -- Sum(j3,m3) ...")
                                return( (true, wa) )
                            end
                        end
                        #
                        #   Rule:                   ( j1 j2 j3 ) ( j1 j2 j3p )      d(j3,j3p) d(m3,m3p)
                        #   ----        Sum(m1,m2)  (          ) (           )  =   ------------------- d(j1,j2,j3)
                        #                           ( m1 m2 m3 ) ( m1 m2 m3p )            [j3]
                        #
                        specialaW3j = W3j(wwa.ja, wwa.jb, wwa.jc, wwa.ma, wwa.mb, wwa.mc)
                        specialbW3j = W3j(wwa.ja, wwa.jb, wwb.jc, wwa.ma, wwa.mb, wwb.mc)
                        if  wwa == specialaW3j  &&  wwb == specialbW3j 
                            newPhase   = rex.phase  + xaRex.phase  + xbRex.phase;       testPhase  = newPhase
                            newWeight  = rex.weight * xaRex.weight * xbRex.weight;      testWeight = newWeight / (2*wwa.jc+1)
                            newW3js    = W3j[];       
                            for (icW3j, cW3j) in enumerate(rex.w3js)  if  icW3j != iaW3j &&  icW3j != ibW3j   push!(newW3js, cW3j)   end   end
                            #
                            if  RacahAlgebra.hasAllVars([wwa.ma, wwa.mb], rex.summations) &&  RacahAlgebra.hasNoVars([wwa.ma, wwa.mb], testPhase)     &&  
                                RacahAlgebra.hasNoVars([wwa.ma, wwa.mb], testWeight)      &&  RacahAlgebra.hasNoVars([wwa.ma, wwa.mb], rex.deltas)    &&  
                                RacahAlgebra.hasNoVars([wwa.ma, wwa.mb], rex.triangles)   &&  RacahAlgebra.hasNoVars([wwa.ma, wwa.mb], newW3js)       &&  
                                RacahAlgebra.hasNoVars([wwa.ma, wwa.mb], rex.w6js)        &&  RacahAlgebra.hasNoVars([wwa.ma, wwa.mb], rex.w9js)
                                newSummations = RacahAlgebra.removeIndex([wwa.ma, wwa.mb], rex.summations)
                                newDeltas    = rex.deltas;      push!( newDeltas,    Kronecker(wwa.jc, wwb.jc));     push!( newDeltas, Kronecker(wwa.mc, wwb.mc))
                                newTriangles = rex.triangles;   push!( newTriangles, Triangle(wwa.ja, wwa.jb, wwa.jc))
                                wa = RacahExpression( newSummations, testPhase, testWeight, newDeltas, newTriangles, newW3js, rex.w6js, rex.w9js )
                                println(">> Apply sum rule for two W3j -- Sum(m1,m2) ...")
                                return( (true, wa) )
                            end
                        end
                        #
                        #                                                                             a+na-p-q
                        #   Rule:                      -np-nq  (  a  p  q  ) (  p   q  a'  )      (-1)
                        #   ----        Sum(np,nq) (-1)        (           ) (             ) =   --------------  d(a,a') d(na,na') d(a,p,q)
                        #                                      ( -na np nq ) ( -np -nq na` )          [a]
                        #
                        specialaW3j = W3j(wwa.ja, wwa.jb, wwa.jc,  wwa.ma, wwa.mb, wwa.mc)
                        specialbW3j = W3j(wwa.jb, wwa.jc, wwb.jc, -wwa.mb, -wwa.mc, wwb.mc)
                        if  wwa == specialaW3j  &&  wwb == specialbW3j 
                            newPhase   = rex.phase  + xaRex.phase  + xbRex.phase;     testPhase  = newPhase + wwa.mb + wwa.mc + wwa.ja - wwa.ma - wwa.jb - wwa.jc
                            newWeight  = rex.weight * xaRex.weight * xbRex.weight;    testWeight = newWeight / (2*wwa.ja+1)
                            newW3js    = W3j[];       
                            for (icW3j, cW3j) in enumerate(rex.w3js)  if  icW3j != iaW3j &&  icW3j != ibW3j   push!(newW3js, cW3j)   end   end
                            #
                            if  RacahAlgebra.hasAllVars([wwa.mb, wwa.mc], rex.summations) &&  RacahAlgebra.hasNoVars([wwa.mb, wwa.mc], testPhase)     &&  
                                RacahAlgebra.hasNoVars([wwa.mb, wwa.mc], testWeight)      &&  RacahAlgebra.hasNoVars([wwa.mb, wwa.mc], rex.deltas)    &&  
                                RacahAlgebra.hasNoVars([wwa.mb, wwa.mc], rex.triangles)   &&  RacahAlgebra.hasNoVars([wwa.mb, wwa.mc], newW3js)       &&  
                                RacahAlgebra.hasNoVars([wwa.mb, wwa.mc], rex.w6js)        &&  RacahAlgebra.hasNoVars([wwa.mb, wwa.mc], rex.w9js)
                                newSummations = RacahAlgebra.removeIndex([wwa.mb, wwa.mc], rex.summations)
                                newDeltas    = rex.deltas;      push!( newDeltas, Kronecker(wwa.ja, wwb.jc));     push!( newDeltas, Kronecker(-wwa.ma, wwb.mc))
                                newTriangles = rex.triangles;   push!( newTriangles, Triangle(wwa.ja, wwa.jb, wwa.jc));
                                wa = RacahExpression( newSummations, testPhase, newWeight, newDeltas, newTriangles, newW3js, rex.w6js, rex.w9js )
                                println(">> Apply sum rule for two W3j -- Sum(np,nq) (-1)^(-np-nq) ...")
                                return( (true, wa) )
                            end
                        end
                    end
                end
            end
        end
        
        return( (false, RacahExpression()) )
    end


    """
    `RacahAlgebra.sumRulesForTwoW6j(rex::RacahAlgebra.RacahExpression)`  
        ... attempts to find a simplification of the given Racah expression by using sum rules for one Wigner 6-j symbol. 
            Once a simplification is found, no attempt is made to find another simplifcation for this set of rules.
            A (istrue, rex)::Tuple{Bool, RacahExpression} is returned but where rex has no meaning for !istrue.
    """
    function sumRulesForTwoW6j(rex::RacahAlgebra.RacahExpression)
        
        # Loop through all Wigner 6-j symbols
        for  (ibW6j, bW6j) in enumerate(rex.w6js)
            bRexList = RacahAlgebra.symmetricForms(bW6j)
            for  xbRex in bRexList
                for  (iaW6j, aW6j) in enumerate(rex.w6js)
                    if  iaW6j == ibW6j    break    end
                    aRexList = RacahAlgebra.symmetricForms(aW6j)
                    for  xaRex in aRexList
                        wwa = xaRex.w6js[1];     wwb = xbRex.w6js[1]
                        #
                        #   Rule:                                         2
                        #   ----                              ( X  Y  Z )
                        #               Sum(X,Y,Z)  [X,Y,Z]  {(         )}    =    [a,b,c]
                        #                                     ( a  b  c )
                        #
                        specialaW6j = W6j(wwa.a, wwa.b, wwa.c,  wwa.d, wwa.e, wwa.f)
                        specialbW6j = W6j(wwa.a, wwa.b, wwa.c,  wwa.d, wwa.e, wwa.f)
                        if  wwa == specialaW6j  &&  wwb == specialbW6j 
                            newPhase   = rex.phase  + xaRex.phase  + xbRex.phase;      testPhase  = newPhase
                            newWeight  = rex.weight * xaRex.weight * xbRex.weight;     
                            testWeight = newWeight / ((2*wwa.a+1)*(2*wwa.b+1)*(2*wwa.c+1)) *  ((2*wwa.d+1)*(2*wwa.e+1)*(2*wwa.f+1))
                            newW6js   = W6j[];       
                            for (icW6j, cW6j) in enumerate(rex.w6js)  if  icW6j != iaW6j &&  icW6j != ibW6j   push!(newW6js, cW6j)   end   end
                            #
                            if  RacahAlgebra.hasAllVars([wwa.a, wwa.b, wwa.c], rex.summations) &&  RacahAlgebra.hasNoVars([wwa.a, wwa.b, wwa.c], testPhase)     &&  
                                RacahAlgebra.hasNoVars([wwa.a, wwa.b, wwa.c], testWeight)      &&  RacahAlgebra.hasNoVars([wwa.a, wwa.b, wwa.c], rex.deltas)    &&  
                                RacahAlgebra.hasNoVars([wwa.a, wwa.b, wwa.c], rex.triangles)   &&  RacahAlgebra.hasNoVars([wwa.a, wwa.b, wwa.c], rex.w3js)      &&  
                                RacahAlgebra.hasNoVars([wwa.a, wwa.b, wwa.c], newW6js)         &&  RacahAlgebra.hasNoVars([wwa.a, wwa.b, wwa.c], rex.w9js)
                                newSummations = RacahAlgebra.removeIndex([wwa.a, wwa.b, wwa.c], rex.summations)
                                wa = RacahExpression( newSummations, testPhase, testWeight, rex.deltas, rex.triangles, rex.w3js, newW6js, rex.w9js )
                                println(">> Apply sum rule for two W6j -- Sum(X,Y,Z) [X,Y,Z] ...")
                                return( (true, wa) )
                            end
                        end
                        #
                        #   Rule:                  X     ( a  b  X )   ( c  d  X )          -p-q    ( c  a  q )
                        #   ----        Sum(X) (-1) [X] {(         )} {(         )}  =  (-1)       {(         )}
                        #                                ( c  d  p )   ( b  a  q )                  ( d  b  p )
                        #
                        specialaW6j = W6j(wwa.a, wwa.b, wwa.c,  wwa.d, wwa.e, wwa.f)
                        specialbW6j = W6j(wwa.d, wwa.e, wwa.c,  wwa.b, wwa.a, wwb.f)
                        if  wwa == specialaW6j  &&  wwb == specialbW6j 
                            newPhase  = rex.phase  + xaRex.phase  + xbRex.phase;      testPhase  = newPhase - wwa.c - wwa.f - wwb.f
                            newWeight  = rex.weight * xaRex.weight * xbRex.weight;    testWeight = newWeight / (2*wwa.c+1)
                            newW6js    = W6j[];       
                            for (icW6j, cW6j) in enumerate(rex.w6js)  if  icW6j != iaW6j &&  icW6j != ibW6j   push!(newW6js, cW6j)   end   end
                            #
                            if  RacahAlgebra.hasAllVars([wwa.c], rex.summations) &&  RacahAlgebra.hasNoVars([wwa.c], testPhase)     &&  
                                RacahAlgebra.hasNoVars([wwa.c], testWeight)      &&  RacahAlgebra.hasNoVars([wwa.c], rex.deltas)    &&  
                                RacahAlgebra.hasNoVars([wwa.c], rex.triangles)   &&  RacahAlgebra.hasNoVars([wwa.c], rex.w3js)      &&  
                                RacahAlgebra.hasNoVars([wwa.c], newW6js)         &&  RacahAlgebra.hasNoVars([wwa.c], rex.w9js)
                                newSummations = RacahAlgebra.removeIndex([wwa.c], rex.summations)
                                push!( newW6js, W6j(wwa.d, wwa.a, wwb.f, wwa.e, wwa.b, wwa.f));
                                wa = RacahExpression( newSummations, testPhase, testWeight, rex.deltas, rex.triangles, rex.w3js, newW6js, rex.w9js )
                                println(">> Apply sum rule for two W6j -- Sum(X) (-1)^X [X] ...")
                                return( (true, wa) )
                            end
                        end
                        #
                        #   Rule:                    ( a  b  X )   ( c  d  X )        1
                        #   ----        Sum(X) [X]  {(         )} {(         )}  =   ---  d(p,q) d(a,d,p) d(b,c,p)
                        #                            ( c  d  p )   ( a  b  q )       [p]
                        #
                        specialaW6j = W6j(wwa.a, wwa.b, wwa.c,  wwa.d, wwa.e, wwa.f)
                        specialbW6j = W6j(wwa.d, wwa.e, wwa.c,  wwa.a, wwa.b, wwb.f)
                        if  wwa == specialaW6j  &&  wwb == specialbW6j 
                            newPhase   = rex.phase  + xaRex.phase  + xbRex.phase;      testPhase  = newPhase
                            newWeight  = rex.weight * xaRex.weight * xbRex.weight;     testWeight = newWeight / (2*wwa.c+1) / (2*wwa.f+1)
                            newW6js    = W6j[];       
                            for (icW6j, cW6j) in enumerate(rex.w6js)  if  icW6j != iaW6j &&  icW6j != ibW6j   push!(newW6js, cW6j)   end   end
                            #
                            if  RacahAlgebra.hasAllVars([wwa.c], rex.summations) &&  RacahAlgebra.hasNoVars([wwa.c], testPhase)     &&  
                                RacahAlgebra.hasNoVars([wwa.c], testWeight)      &&  RacahAlgebra.hasNoVars([wwa.c], rex.deltas)    &&  
                                RacahAlgebra.hasNoVars([wwa.c], rex.triangles)   &&  RacahAlgebra.hasNoVars([wwa.c], rex.w3js)      &&  
                                RacahAlgebra.hasNoVars([wwa.c], newW6js)         &&  RacahAlgebra.hasNoVars([wwa.c], rex.w9js)
                                newSummations = RacahAlgebra.removeIndex([wwa.c], rex.summations)
                                newDeltas    = rex.deltas;      push!( newDeltas,    Kronecker(wwa.f, wwb.f));   
                                newTriangles = rex.triangles;   push!( newTriangles, Triangle(wwa.a, wwa.e, wwa.f));   
                                                                push!( newTriangles, Triangle(wwa.b, wwa.d, wwa.f));
                                wa = RacahExpression( newSummations, testPhase, testWeight, newDeltas, newTriangles, rex.w3js, newW6js, rex.w9js )
                                println(">> Apply sum rule for two W6j -- Sum(X) [X] ...")
                                return( (true, wa) )
                            end
                        end
                    end
                end
            end
        end
        
        return( (false, RacahExpression()) )
    end


    """
    `RacahAlgebra.sumRulesForOneW6jOneW9j(rex::RacahAlgebra.RacahExpression)`  
        ... attempts to find a simplification of the given Racah expression by using sum rules for one Wigner 6j and one 9j symbol. 
            Once a simplification is found, no attempt is made to find another simplifcation for this set of rules.
            A (istrue, rex)::Tuple{Bool, RacahExpression} is returned but where rex has no meaning for !istrue.
    """
    function sumRulesForOneW6jOneW9j(rex::RacahAlgebra.RacahExpression)
        
        # Loop through all Wigner 6j and 9j symbols
        for  (ibW6j, bW6j) in enumerate(rex.w6js)
            bRexList = RacahAlgebra.symmetricForms(bW6j)
            for  xbRex in bRexList
                for  (iaW9j, aW9j) in enumerate(rex.w9js)
                    aRexList = RacahAlgebra.symmetricForms(aW9j)
                    for  xaRex in aRexList
                        wwa = xbRex.w6js[1];     wwb = xaRex.w9js[1]
                        #
                        #   Rule:       
                        #                                     ( X  Y  Z )    ( X  Y  Z ) 
                        #               Sum(X,Y,Z)  [X,Y,Z]  {(         )}  {( a  b  c )}  =  d(a,b,c)
                        #                                     ( c  a  b )    ( b  c  a )
                        #
                        specialaW6j = W6j(wwa.a, wwa.b, wwa.c,  wwa.d, wwa.e, wwa.f)
                        specialbW9j = W9j(wwa.a, wwa.b, wwa.c,  wwa.e, wwa.f, wwa.d,  wwa.f, wwa.d, wwa.e)
                        if  wwa == specialaW6j  &&  wwb == specialbW9j
                            newPhase  = rex.phase  + xaRex.phase  + xbRex.phase;      testPhase  = newPhase
                            newWeight = rex.weight * xaRex.weight * xbRex.weight;     testWeight = newWeight / ( (2*wwa.a+1)*(2*wwa.b+1)*(2*wwa.c+1))
                            newW6js    = W6j[];    newW9js    = W9j[];      
                            for (icW6j, cW6j) in enumerate(rex.w6js)  if  icW6j != ibW6j   push!(newW6js, cW6j)   end   end
                            for (icW9j, cW9j) in enumerate(rex.w9js)  if  icW9j != iaW9j   push!(newW9js, cW9j)   end   end
                            #
                            if  RacahAlgebra.hasAllVars([wwa.a, wwa.b, wwa.c], rex.summations) &&  RacahAlgebra.hasNoVars([wwa.a, wwa.b, wwa.c], testPhase)   &&  
                                RacahAlgebra.hasNoVars([wwa.a, wwa.b, wwa.c], testWeight)      &&  RacahAlgebra.hasNoVars([wwa.a, wwa.b, wwa.c], rex.deltas)  &&  
                                RacahAlgebra.hasNoVars([wwa.a, wwa.b, wwa.c], rex.triangles)   &&  RacahAlgebra.hasNoVars([wwa.a, wwa.b, wwa.c], rex.w3js)    &&  
                                RacahAlgebra.hasNoVars([wwa.a, wwa.b, wwa.c], newW6js)         &&  RacahAlgebra.hasNoVars([wwa.a, wwa.b, wwa.c], newW9js)
                                newSummations = RacahAlgebra.removeIndex([wwa.a, wwa.b, wwa.c], rex.summations)
                                newTriangles  = rex.triangles;   push!( newTriangles, Triangle(wwa.e, wwa.f, wwa.d));
                                wa = RacahExpression( newSummations, testPhase, testWeight, rex.deltas, newTriangles, rex.w3js, newW6js, newW9js )
                                println(">> Apply sum rule for one W6j & one W9j -- Sum(X,Y,Z) [X,Y,Z] ...")
                                return( (true, wa) )
                            end
                        end
                        #
                        #   Rule:       
                        #   ----                     ( a  f  X )   ( a  f  X )           2s    ( a  b  s )   ( c  d  s )
                        #               Sum(X) [X]  {(         )} {( d  q  e )}   =  (-1)     {(         )} {(         )}
                        #                            ( e  b  s )   ( p  c  b )                 ( c  d  p )   ( e  f  q )
                        #
                        specialaW6j = W6j(wwa.a, wwa.b, wwa.c,  wwa.d, wwa.e, wwa.f)
                        specialbW9j = W9j(wwa.a, wwa.b, wwa.c,  wwb.d, wwb.e, wwa.d,  wwb.g, wwb.h, wwa.e)
                        if  wwa == specialaW6j  &&  wwb == specialbW9j
                            newPhase   = rex.phase  + xaRex.phase  + xbRex.phase;     testPhase  = newPhase + 2*wwa.f
                            newWeight  = rex.weight * xaRex.weight * xbRex.weight;    testWeight = newWeight / (2*wwa.c+1)
                            newW6js    = W6j[];    newW9js    = W9j[];      
                            for (icW6j, cW6j) in enumerate(rex.w6js)  if  icW6j != ibW6j   push!(newW6js, cW6j)   end   end
                            for (icW9j, cW9j) in enumerate(rex.w9js)  if  icW9j != iaW9j   push!(newW9js, cW9j)   end   end
                            #
                            if  RacahAlgebra.hasAllVars([wwa.c], rex.summations) &&  RacahAlgebra.hasNoVars([wwa.c], testPhase)   &&  
                                RacahAlgebra.hasNoVars([wwa.c], testWeight)      &&  RacahAlgebra.hasNoVars([wwa.c], rex.deltas)  &&  
                                RacahAlgebra.hasNoVars([wwa.c], rex.triangles)   &&  RacahAlgebra.hasNoVars([wwa.c], rex.w3js)    &&  
                                RacahAlgebra.hasNoVars([wwa.c], newW6js)         &&  RacahAlgebra.hasNoVars([wwa.c], newW9js)
                                newSummations = RacahAlgebra.removeIndex([wwa.c], rex.summations)
                                push!( newW6js, W6j(wwa.a, wwa.e, wwa.f,  wwb.h, wwb.d, wwb.g))
                                push!( newW6js, W6j(wwb.h, wwb.d, wwa.f,  wwa.d, wwa.b, wwb.e))
                                wa = RacahExpression( newSummations, testPhase, testWeight, rex.deltas, rex.triangles, rex.w3js, newW6js, newW9js )
                                println(">> Apply sum rule for one W6j & one W9j -- Sum(X) [X] ...")
                                return( (true, wa) )
                            end
                        end
                        #
                        #   Rule:       
                        #                          X      ( a  f  X )    ( a  f  X )           2s-R  ( p  q  s )   ( p  q  s )
                        #               Sum(X) (-1) [X]  {(         )}  {( d  q  e )}   =  (-1)     {(         )} {(         )}
                        #                                 ( b  e  s )    ( p  c  b )                 ( e  a  d )   ( f  b  c )
                        #
                        #   with R = a + b + c + d + e + f + p + q
                        #
                        specialaW6j = W6j(wwa.a, wwa.b, wwa.c,  wwa.d, wwa.e, wwa.f)
                        specialbW9j = W9j(wwa.a, wwa.b, wwa.c,  wwb.d, wwb.e, wwa.e,  wwb.g, wwb.h, wwa.d)
                        if  wwa == specialaW6j  &&  wwb == specialbW9j 
                            newPhase   = rex.phase  + xaRex.phase  + xbRex.phase;    
                            R          = wwa.a + wwa.d + wwb.h + wwb.d + wwa.e + wwa.b + wwb.g + wwb.e
                            testPhase  = newPhase - wwa.c + 2*wwa.f - R
                            newWeight  = rex.weight * xaRex.weight * xbRex.weight;    testWeight = newWeight / (2*wwa.c+1)
                            newW6js    = W6j[];    newW9js    = W9j[];      
                            for (icW6j, cW6j) in enumerate(rex.w6js)  if  icW6j != ibW6j   push!(newW6js, cW6j)   end   end
                            for (icW9j, cW9j) in enumerate(rex.w9js)  if  icW9j != iaW9j   push!(newW9js, cW9j)   end   end
                            #
                            if  RacahAlgebra.hasAllVars([wwa.c], rex.summations) &&  RacahAlgebra.hasNoVars([wwa.c], testPhase)   &&  
                                RacahAlgebra.hasNoVars([wwa.c], testWeight)      &&  RacahAlgebra.hasNoVars([wwa.c], rex.deltas)  &&  
                                RacahAlgebra.hasNoVars([wwa.c], rex.triangles)   &&  RacahAlgebra.hasNoVars([wwa.c], rex.w3js)    &&  
                                RacahAlgebra.hasNoVars([wwa.c], newW6js)         &&  RacahAlgebra.hasNoVars([wwa.c], newW9js)
                                newSummations = RacahAlgebra.removeIndex([wwa.c], rex.summations)
                                push!( newW6js, W6j(wwb.g, wwb.e, wwa.f,  wwb.f, wwa.a, wwb.d))
                                push!( newW6js, W6j(wwb.g, wwb.e, wwa.f,  wwa.b, wwa.d, wwb.h))
                                wa = RacahExpression( newSummations, testPhase, testWeight, rex.deltas, rex.triangles, rex.w3js, newW6js, newW9js )
                                println(">> Apply sum rule for one W6j & one W9j -- Sum(X) [X] ...")
                                return( (true, wa) )
                            end
                        end
                    end
                end
            end
        end
        
        return( (false, RacahExpression()) )
    end


    """
    `RacahAlgebra.sumRulesForTwoW9j(rex::RacahAlgebra.RacahExpression)`  
        ... attempts to find a simplification of the given Racah expression by using sum rules for two Wigner 9j symbols. 
            Once a simplification is found, no attempt is made to find another simplifcation for this set of rules.
            A (istrue, rex)::Tuple{Bool, RacahExpression} is returned but where rex has no meaning for !istrue.
    """
    function sumRulesForTwoW9j(rex::RacahAlgebra.RacahExpression)
        
        # Loop through all Wigner 6-j symbols
        for  (ibW9j, bW9j) in enumerate(rex.w9js)
            bRexList = RacahAlgebra.symmetricForms(bW9j)
            for  xbRex in bRexList
                for  (iaW9j, aW9j) in enumerate(rex.w9js)
                    if  iaW9j == ibW9j    break    end
                    aRexList = RacahAlgebra.symmetricForms(aW9j)
                    for  xaRex in aRexList
                        wwa = xaRex.w9js[1];     wwb = xbRex.w9js[1]
                        #
                        #   Rule:                                         2
                        #   ----                              ( X  Y  Z )
                        #               Sum(X,Y,Z)  [X,Y,Z]  {( a  b  c )}   =  d(a,b,c) d(d,e,f)
                        #                                     ( d  e  f )
                        #
                        specialaW9j = W9j(wwa.a, wwa.b, wwa.c,  wwa.d, wwa.e, wwa.f,  wwa.g, wwa.h, wwa.i)
                        if  wwa == specialaW9j  &&  wwb == specialaW9j 
                            newPhase   = rex.phase  + xaRex.phase  + xbRex.phase;     testPhase  = newPhase
                            newWeight  = rex.weight * xaRex.weight * xbRex.weight;    testWeight = newWeight / ( (2*wwa.a+1)*(2*wwa.b+1)*(2*wwa.c+1))
                            newW9js    = W9j[];       
                            for (icW9j, cW9j) in enumerate(rex.w9js)  if  icW9j != iaW9j &&  icW9j != ibW9j   push!(newW9js, cW9j)   end   end
                            #
                            if  RacahAlgebra.hasAllVars([wwa.a, wwa.b, wwa.c], rex.summations) &&  RacahAlgebra.hasNoVars([wwa.a, wwa.b, wwa.c], testPhase)   &&  
                                RacahAlgebra.hasNoVars([wwa.a, wwa.b, wwa.c], testWeight)      &&  RacahAlgebra.hasNoVars([wwa.a, wwa.b, wwa.c], rex.deltas)  &&  
                                RacahAlgebra.hasNoVars([wwa.a, wwa.b, wwa.c], rex.triangles)   &&  RacahAlgebra.hasNoVars([wwa.a, wwa.b, wwa.c], rex.w3js)    &&  
                                RacahAlgebra.hasNoVars([wwa.a, wwa.b, wwa.c], rex.w6js)        &&  RacahAlgebra.hasNoVars([wwa.a, wwa.b, wwa.c], newW9js)
                                newSummations = RacahAlgebra.removeIndex([wwa.a, wwa.b, wwa.c], rex.summations)
                                newTriangles = rex.triangles;   push!( newTriangles, Triangle(wwa.d, wwa.e, wwa.f))
                                                                push!( newTriangles, Triangle(wwa.g, wwa.h, wwa.i))
                                wa = RacahExpression( newSummations, testPhase, testWeight, rex.deltas, newTriangles, rex.w3js, rex.w6js, newW9js )
                                println(">> Apply sum rule for two W9j -- Sum(X,Y,Z) [X,Y,Z] ...")
                                return( (true, wa) )
                            end
                        end
                        #
                        #   Rule:  
                        #   ----                          ( a  b  X )   ( a  b  X )      d(e,g) d(f,h)
                        #               Sum(X,Y)  [X,Y]  {( c  d  Y )} {( c  d  Y )}  =  -------------  d(a,c,e) d(b,d,h) d(g,f,j)
                        #                                 ( e  f  j )   ( g  h  j )          [e,f]
                        #
                        specialaW9j = W9j(wwa.a, wwa.b, wwa.c,  wwa.d, wwa.e, wwa.f,  wwa.g, wwa.h, wwa.i)
                        specialbW9j = W9j(wwa.a, wwa.b, wwa.c,  wwa.d, wwa.e, wwa.f,  wwb.g, wwb.h, wwa.i)
                        if  wwa == specialaW9j  &&  wwb == specialbW9j 
                            newPhase   = rex.phase  + xaRex.phase  + xbRex.phase;    testPhase  = newPhase
                            newWeight  = rex.weight * xaRex.weight * xbRex.weight;   
                            testWeight = newWeight / ((2*wwa.c+1)*(2*wwa.f+1)) / ((2*wwa.g+1)*(2*wwa.h+1))
                            newW9js    = W9j[];       
                            for (icW9j, cW9j) in enumerate(rex.w9js)  if  icW9j != iaW9j &&  icW9j != ibW9j   push!(newW9js, cW9j)   end   end
                            #
                            if  RacahAlgebra.hasAllVars([wwa.c, wwa.f], rex.summations) &&  RacahAlgebra.hasNoVars([wwa.c, wwa.f], testPhase)   &&  
                                RacahAlgebra.hasNoVars([wwa.c, wwa.f], testWeight)      &&  RacahAlgebra.hasNoVars([wwa.c, wwa.f], rex.deltas)  &&  
                                RacahAlgebra.hasNoVars([wwa.c, wwa.f], rex.triangles)   &&  RacahAlgebra.hasNoVars([wwa.c, wwa.f], rex.w3js)    &&  
                                RacahAlgebra.hasNoVars([wwa.c, wwa.f], rex.w6js)        &&  RacahAlgebra.hasNoVars([wwa.c, wwa.f], newW9js)
                                newSummations = RacahAlgebra.removeIndex([wwa.c, wwa.f], rex.summations)
                                newDeltas    = rex.deltas;      push!( newDeltas, Kronecker(wwa.g, wwb.g));      push!( newDeltas, Kronecker(wwa.h, wwb.h))
                                newTriangles = rex.triangles;   push!( newTriangles, Triangle(wwa.a, wwa.d, wwa.g))
                                                                push!( newTriangles, Triangle(wwb.b, wwb.e, wwb.h))
                                                                push!( newTriangles, Triangle(wwb.g, wwa.h, wwa.i))
                                wa = RacahExpression( newSummations, testPhase, testWeight, newDeltas, newTriangles, rex.w3js, rex.w6js, newW9js )
                                println(">> Apply sum rule for two W9j -- Sum(X,Y) [X,Y] ...")
                                return( (true, wa) )
                            end
                        end
                        #
                        #   Rule:  
                        #   ----                     Y       ( a  b  X )   ( a  b  X )           2b+f+h    ( a  d  g )
                        #               Sum(X,Y) (-1) [X,Y] {( c  d  Y )} {( d  c  Y )}   =  (-1)         {( c  b  h )}
                        #                                    ( e  f  j )   ( g  h  j )                     ( e  f  j )
                        #
                        specialaW9j = W9j(wwa.a, wwa.b, wwa.c,  wwa.d, wwa.e, wwa.f,  wwa.g, wwa.h, wwa.i)
                        specialbW9j = W9j(wwa.a, wwa.b, wwa.c,  wwa.e, wwa.d, wwa.f,  wwb.g, wwb.h, wwa.i)
                        if  wwa == specialaW9j  &&  wwb == specialbW9j 
                            newPhase   = rex.phase  + xaRex.phase  + xbRex.phase;     testPhase  = newPhase - wwa.f  + 2*wwa.b + wwa.h + wwb.h
                            newWeight  = rex.weight * xaRex.weight * xbRex.weight;    testWeight = newWeight / ( (2*wwa.c+1)*(2*wwa.f+1))
                            newW9js    = W9j[];       
                            for (icW9j, cW9j) in enumerate(rex.w9js)  if  icW9j != iaW9j &&  icW9j != ibW9j   push!(newW9js, cW9j)   end   end
                            #
                            if  RacahAlgebra.hasAllVars([wwa.c, wwa.f], rex.summations) &&  RacahAlgebra.hasNoVars([wwa.c, wwa.f], testPhase)   &&  
                                RacahAlgebra.hasNoVars([wwa.c, wwa.f], testWeight)      &&  RacahAlgebra.hasNoVars([wwa.c, wwa.f], rex.deltas)  &&  
                                RacahAlgebra.hasNoVars([wwa.c, wwa.f], rex.triangles)   &&  RacahAlgebra.hasNoVars([wwa.c, wwa.f], rex.w3js)    &&  
                                RacahAlgebra.hasNoVars([wwa.c, wwa.f], rex.w6js)        &&  RacahAlgebra.hasNoVars([wwa.c, wwa.f], newW9js)
                                newSummations = RacahAlgebra.removeIndex([wwa.c, wwa.f], rex.summations)
                                push!( newW9js, W9j(wwa.a, wwa.e, wwb.g,  wwa.d, wwa.b, wwb.h,  wwa.g, wwa.h, wwa.i))
                                wa = RacahExpression( newSummations, testPhase, testWeight, rex.deltas, rex.triangles, rex.w3js, rex.w6js, newW9js )
                                println(">> Apply sum rule for two W9j -- Sum(X,Y) (-1)^Y [X,Y] ...")
                                return( (true, wa) )
                            end
                        end
                    end
                end
            end
        end
        
        return( (false, RacahExpression()) )
    end


    """
    `RacahAlgebra.sumRulesForThreeW3j(rex::RacahAlgebra.RacahExpression)`  
        ... attempts to find a simplification of the given Racah expression by using sum rules for three Wigner 3j symbols. 
            Once a simplification is found, no attempt is made to find another simplifcation for this set of rules.
            A (istrue, rex)::Tuple{Bool, RacahExpression} is returned but where rex has no meaning for !istrue.
    """
    function sumRulesForThreeW3j(rex::RacahAlgebra.RacahExpression)
        # Make sure that the sum rule could apply at all
        if  length(rex.summations) < 2  ||  length(rex.w3js) < 2     return( (false, RacahExpression()) )    end
        
        # Loop through all Wigner 3j symbols
        for  (icW3j, cW3j) in enumerate(rex.w3js)
            cRexList = RacahAlgebra.symmetricForms(cW3j)
            for  xcRex in cRexList
                for  (ibW3j, bW3j) in enumerate(rex.w3js)
                    if  icW3j == ibW3j    break    end
                    bRexList = RacahAlgebra.symmetricForms(bW3j)
                    for  xbRex in bRexList
                        for  (iaW3j, aW3j) in enumerate(rex.w3js)
                            if  iaW3j == ibW3j    ||   iaW3j == icW3j      break    end
                            aRexList = RacahAlgebra.symmetricForms(aW3j)
                            for  xaRex in aRexList
                                wwa = xaRex.w3js[1];     wwb = xbRex.w3js[1];     wwc = xcRex.w3js[1]
                                #
                                #   Rule:                         -m4-m5-m6  ( j5 j1  j6 ) ( j6 j2  j4 ) ( j4 j3  j5 )
                                #   ----        Sum(m4,m5,m6) (-1)           (           ) (           ) (           )
                                #                                            ( m5 m1 -m6 ) ( m6 m2 -m4 ) ( m4 m3 -m5 )
                                #
                                #                                                             -j4-j5-j6  (  j1  j2  j3 )  ( j1 j2 j3 )
                                #                                                      =  (-1)           (             ) {(          )}
                                #                                                                        ( -m1 -m2 -m3 )  ( j4 j5 j6 )
                                #
                                specialaW3j = W3j(wwa.ja, wwa.jb, wwa.jc, wwa.ma, wwa.mb, -wwb.ma)
                                specialbW3j = W3j(wwa.jc, wwb.jb, wwb.jc, wwb.ma, wwb.mb, -wwc.ma)
                                specialcW3j = W3j(wwb.jc, wwc.jb, wwa.ja, wwc.ma, wwc.mb, -wwa.ma)
                                if  wwa == specialaW3j  &&  wwb == specialbW3j  &&  wwc == specialcW3j 
                                    newPhase  = rex.phase  + xaRex.phase  + xbRex.phase  + xcRex.phase
                                    testPhase = newPhase + wwc.ma + wwa.ma + wwb.ma - wwb.jc - wwc.jc - wwa.jc   
                                    ## testPhase  = rewritePhase(testPhase, [wwc.ma + wwc.mb + wwc.mc], [wwc.ma, wwa.ma, wwb.ma], printout=true, from="sumRulesForThreeW3j" )
                                    newWeight  = rex.weight * xaRex.weight * xbRex.weight * xcRex.weight;    testWeight = newWeight 
                                    newW3js    = W3j[];       
                                    for (idW3j, dW3j) in enumerate(rex.w3js)  
                                        if  idW3j != iaW3j &&  idW3j != ibW3j &&  idW3j != icW3j   push!(newW3js, dW3j)   end   
                                    end
                                    #
                                    if  RacahAlgebra.hasAllVars([wwc.ma, wwa.ma, wwb.ma], rex.summations) &&  RacahAlgebra.hasNoVars([wwc.ma, wwa.ma, wwb.ma], testPhase)  &&  
                                        RacahAlgebra.hasNoVars([wwc.ma, wwa.ma, wwb.ma], testWeight)      &&  RacahAlgebra.hasNoVars([wwc.ma, wwa.ma, wwb.ma], rex.deltas) &&  
                                        RacahAlgebra.hasNoVars([wwc.ma, wwa.ma, wwb.ma], rex.triangles)   &&  RacahAlgebra.hasNoVars([wwc.ma, wwa.ma, wwb.ma], newW3js)    &&  
                                        RacahAlgebra.hasNoVars([wwc.ma, wwa.ma, wwb.ma], rex.w6js)        &&  RacahAlgebra.hasNoVars([wwc.ma, wwa.ma, wwb.ma], rex.w9js)
                                        newSummations = RacahAlgebra.removeIndex([wwc.ma, wwa.ma, wwb.ma], rex.summations)
                                        newDeltas = rex.deltas;   push!(newW3js,  W3j(wwa.jb, wwb.jb, wwc.jb, -wwa.mb, -wwb.mb, - wwc.mb))
                                        newW6js   = rex.w6js;     push!(newW6js,  W6j(wwa.jb, wwb.jb, wwc.jb,  wwc.ja, wwa.ja, wwb.ja))
                                        wa = RacahExpression( newSummations, testPhase, testWeight, newDeltas, rex.triangles, newW3js, newW6js, rex.w9js )
                                        println(">> Apply sum rule for three W3j -- Sum(m4,m5,m6) ...")
                                        return( (true, wa) )
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        
        return( (false, RacahExpression()) )
    end


    """
    `RacahAlgebra.sumRulesForTwoW3jOneW6j(rex::RacahAlgebra.RacahExpression)`  
        ... attempts to find a simplification of the given Racah expression by using sum rules for three Wigner 3j symbols. 
            Once a simplification is found, no attempt is made to find another simplifcation for this set of rules.
            A (istrue, rex)::Tuple{Bool, RacahExpression} is returned but where rex has no meaning for !istrue.
    """
    function sumRulesForTwoW3jOneW6j(rex::RacahAlgebra.RacahExpression)
        # Make sure that the sum rule could apply at all
        if  length(rex.summations) < 2  ||  length(rex.w3js) < 2  ||  length(rex.w6js) < 1     return( (false, RacahExpression()) )    end
        
        # Loop through all Wigner 3j symbols
        for  (icW6j, cW6j) in enumerate(rex.w6js)
            cRexList = RacahAlgebra.symmetricForms(cW6j)
            for  xcRex in cRexList
                for  (ibW3j, bW3j) in enumerate(rex.w3js)
                    bRexList = RacahAlgebra.symmetricForms(bW3j)
                    for  xbRex in bRexList
                        for  (iaW3j, aW3j) in enumerate(rex.w3js)
                            if  iaW3j == ibW3j    break    end
                            aRexList = RacahAlgebra.symmetricForms(aW3j)
                            for  xaRex in aRexList
                                wwa = xaRex.w3js[1];     wwb = xbRex.w3js[1];     wwc = xcRex.w6js[1]
                                #
                                #   Rule:                  l3      ( l1 j2 l3 ) ( j1 l2 l3 ) ( j1 j2 j3 )                 -j3-m1-n1  ( j1 j2 j3 ) ( l1 l2  j3 )
                                #   ----    Sum(l3,n3) (-1)   [l3] (          ) (          ){(          )} =   Sum(m3) (-1)          (          ) (           )
                                #                                  ( n1 m2 n3 ) ( m1 n2 -n3) ( l1 l2 l3 )                            ( m1 m2 m3 ) ( n1 n2 -m3 )
                                # 
                                specialaW3j = W3j(wwa.ja, wwa.jb, wwa.jc, wwa.ma, wwa.mb,  wwa.mc)
                                specialbW3j = W3j(wwb.ja, wwb.jb, wwa.jc, wwb.ma, wwb.mb, -wwa.mc)
                                specialcW6j = W6j(wwb.ja, wwa.jb, wwc.c,  wwa.ja, wwb.jb,  wwa.jc)
                                if  wwa == specialaW3j  &&  wwb == specialbW3j  &&  wwc == specialcW6j 
                                    newPhase   = rex.phase  + xaRex.phase  + xbRex.phase  + xcRex.phase;   testPhase  = newPhase - wwa.jc - wwc.c - wwb.ma - wwa.ma  
                                    newWeight  = rex.weight * xaRex.weight * xbRex.weight * xcRex.weight;  testWeight = newWeight / (2*wwb.jc+1)
                                    newW3js    = W3j[];    newW6js    = W6j[];    m3 = Basic(:m3)
                                    for (idW3j, dW3j) in enumerate(rex.w3js)  if  idW3j != iaW3j &&  idW3j != ibW3j   push!(newW3js, dW3j)   end   end
                                    for (idW6j, dW6j) in enumerate(rex.w6js)  if  idW6j != icW6j                      push!(newW6js, dW6j)   end   end
                                    #
                                    if  RacahAlgebra.hasAllVars([wwa.jc, wwa.mc], rex.summations) &&  RacahAlgebra.hasNoVars([wwa.jc, wwa.mc], testPhase)  &&  
                                        RacahAlgebra.hasNoVars([wwa.jc, wwa.mc], testWeight)      &&  RacahAlgebra.hasNoVars([wwa.jc, wwa.mc], rex.deltas) &&  
                                        RacahAlgebra.hasNoVars([wwa.jc, wwa.mc], rex.triangles)   &&  RacahAlgebra.hasNoVars([wwa.jc, wwa.mc], newW3js)    &&  
                                        RacahAlgebra.hasNoVars([wwa.jc, wwa.mc], newW6js)         &&  RacahAlgebra.hasNoVars([wwa.jc, wwa.mc], rex.w9js)
                                        newSummations = RacahAlgebra.removeIndex([wwa.jc, wwa.mc], rex.summations)
                                        push!(newSummations, m3)
                                        push!(newW3js,  W3j(wwb.ja, wwa.jb, wwc.c,  wwb.ma, wwa.mb,  m3))
                                        push!(newW3js,  W3j(wwa.ja, wwb.jb, wwc.c,  wwa.ma, wwb.mb, -m3))
                                        wa = RacahExpression( newSummations, testPhase, testWeight, rex.deltas, rex.triangles, newW3js, newW6js, rex.w9js )
                                        println(">> Apply sum rule for two W3j & one W6j -- Sum(l3, n3) ...")
                                        return( (true, wa) )
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        
        return( (false, RacahExpression()) )
    end


    """
    `RacahAlgebra.sumRulesForThreeW6j(rex::RacahAlgebra.RacahExpression)`  
        ... attempts to find a simplification of the given Racah expression by using sum rules for three Wigner 3j symbols. 
            Once a simplification is found, no attempt is made to find another simplifcation for this set of rules.
            A (istrue, rex)::Tuple{Bool, RacahExpression} is returned but where rex has no meaning for !istrue.
    """
    function sumRulesForThreeW6j(rex::RacahAlgebra.RacahExpression)
        # Make sure that the sum rule could apply at all
        if  length(rex.summations) < 1  ||  length(rex.w6js) < 3     return( (false, RacahExpression()) )    end
        
        # Loop through all Wigner 6j symbols
        for  (icW6j, cW6j) in enumerate(rex.w6js)
            cRexList = RacahAlgebra.symmetricForms(cW6j)
            for  xcRex in cRexList
                for  (ibW6j, bW6j) in enumerate(rex.w6js)
                    if  icW6j == ibW6j    break    end
                    bRexList = RacahAlgebra.symmetricForms(bW6j)
                    for  xbRex in bRexList
                        for  (iaW6j, aW6j) in enumerate(rex.w6js)
                            if  iaW6j == icW6j    ||   iaW6j == ibW6j      break    end
                            aRexList = RacahAlgebra.symmetricForms(aW6j)
                            for  xaRex in aRexList
                                wwa = xaRex.w6js[1];     wwb = xbRex.w6js[1];     wwc = xcRex.w6js[1]
                                #
                                #   Rule:               R+X     ( a  b  X )   ( c  d  X )   ( e  f  X )       ( p  q  r )   ( p  q  r )
                                #   ----     Sum(X) (-1)   [X] {(         )} {(         )} {(         )}  =  {(         )} {(         )}
                                #                               ( c  d  p )   ( e  f  q )   ( b  a  r )       ( e  a  d )   ( f  b  c )
                                #
                                #   with  R = a + b + c + d + e + f + p + q + r
                                #
                                specialaW6j = W6j(wwa.a, wwa.b, wwa.c, wwa.d, wwa.e, wwa.f)
                                specialbW6j = W6j(wwa.d, wwa.e, wwa.c, wwb.d, wwb.e, wwb.f)
                                specialcW6j = W6j(wwb.d, wwb.e, wwa.c, wwa.b, wwa.a, wwc.f)
                                if  wwa == specialaW6j  &&  wwb == specialbW6j  &&  wwc == specialcW6j 
                                    newPhase   = rex.phase  + xaRex.phase  + xbRex.phase  + xcRex.phase
                                    testPhase  = newPhase - wwa.a - wwa.b - wwa.d - wwa.e - wwb.d - wwb.e - wwa.f - wwb.f - wwc.f - wwa.c 
                                    newWeight  = rex.weight * xaRex.weight * xbRex.weight * xcRex.weight;    testWeight = newWeight / (2*wwa.c + 1)
                                    newW6js    = W6j[];       
                                    for (idW6j, dW6j) in enumerate(rex.w6js)  
                                        if  idW6j != iaW6j &&  idW6j != ibW6j &&  idW6j != icW6j   push!(newW6js, dW6j)   end   
                                    end
                                    #
                                    if  RacahAlgebra.hasAllVars([wwa.c], rex.summations) &&  RacahAlgebra.hasNoVars([wwa.c], testPhase)   &&  
                                        RacahAlgebra.hasNoVars([wwa.c], testWeight)      &&  RacahAlgebra.hasNoVars([wwa.c], rex.deltas)  &&  
                                        RacahAlgebra.hasNoVars([wwa.c], rex.triangles)   &&  RacahAlgebra.hasNoVars([wwa.c], rex.w3js)    &&  
                                        RacahAlgebra.hasNoVars([wwa.c], newW6js)         &&  RacahAlgebra.hasNoVars([wwa.c], rex.w9js)
                                        newSummations = RacahAlgebra.removeIndex([wwc.c], rex.summations)
                                        push!(newW6js,  W6j(wwa.f, wwb.f, wwc.f,  wwb.d, wwa.a, wwa.e))
                                        push!(newW6js,  W6j(wwa.f, wwb.f, wwc.f,  wwb.e, wwa.b, wwa.d))
                                        wa = RacahExpression( newSummations, testPhase, testWeight, rex.deltas, rex.triangles, rex.w3js, newW6js, rex.w9js )
                                        println(">> Apply sum rule for three W6j -- Sum(X) (-1)^R+X ...")
                                        return( (true, wa) )
                                    end
                                end
                                #
                                #   Rule:               2X     ( a  b  X )   ( c  d  X )   ( e  f  X )       ( a  f  r )
                                #   ----     Sum(X) (-1)  [X] {(         )} {(         )} {(         )}  =  {( d  q  e )}
                                #                              ( c  d  p )   ( e  f  q )   ( a  b  r )       ( p  c  b )
                                #
                                specialaW6j = W6j(wwa.a, wwa.b, wwa.c, wwa.d, wwa.e, wwa.f)
                                specialbW6j = W6j(wwa.d, wwa.e, wwa.c, wwb.d, wwb.e, wwb.f)
                                specialcW6j = W6j(wwb.d, wwb.e, wwa.c, wwa.a, wwa.b, wwc.f)
                                if  wwa == specialaW6j  &&  wwb == specialbW6j  &&  wwc == specialcW6j 
                                    newPhase   = rex.phase  + xaRex.phase  + xbRex.phase  + xcRex.phase;    testPhase  = newPhase - 2*wwa.c 
                                    newWeight  = rex.weight * xaRex.weight * xbRex.weight * xcRex.weight;   testWeight = newWeight / (2*wwa.c + 1)
                                    newW6js    = W6j[];       
                                    for (idW6j, dW6j) in enumerate(rex.w6js)  
                                        if  idW6j != iaW6j &&  idW6j != ibW6j &&  idW6j != icW6j   push!(newW6js, dW6j)   end   
                                    end
                                    #
                                    if  RacahAlgebra.hasAllVars([wwa.c], rex.summations) &&  RacahAlgebra.hasNoVars([wwa.c], testPhase)   &&  
                                        RacahAlgebra.hasNoVars([wwa.c], testWeight)      &&  RacahAlgebra.hasNoVars([wwa.c], rex.deltas)  &&  
                                        RacahAlgebra.hasNoVars([wwa.c], rex.triangles)   &&  RacahAlgebra.hasNoVars([wwa.c], rex.w3js)    &&  
                                        RacahAlgebra.hasNoVars([wwa.c], newW6js)         &&  RacahAlgebra.hasNoVars([wwa.c], rex.w9js)
                                        newSummations = RacahAlgebra.removeIndex([wwc.c], rex.summations)
                                        newW9js = rex.w9js;     push!(newW9js,  W9j(wwa.a, wwb.e, wwc.f,  wwa.e, wwb.f, wwb.d,  wwa.f, wwa.d, wwa.b))
                                        wa = RacahExpression( newSummations, testPhase, testWeight, rex.deltas, rex.triangles, rex.w3js, newW6js, newW9js )
                                        println(">> Apply sum rule for three W6j -- Sum(X) (-1)^2X [X] ...")
                                        return( (true, wa) )
                                    end
                                end
                                #   Rule:                      ( a  b  X )   ( c  d  X )   ( a  b  q )        ( a  b  q )
                                #   ----     Sum(X,Y)  [X,Y]  {(         )} {(         )} {(         )}   =  {(         )}
                                #                              ( c  d  p )   ( a  b  Y )   ( c  d  Y )        ( c  d  p )
                                #
                                specialaW6j = W6j(wwa.a, wwa.b, wwa.c, wwa.d, wwa.e, wwa.f)
                                specialbW6j = W6j(wwa.d, wwa.e, wwa.c, wwa.a, wwa.b, wwb.f)
                                specialcW6j = W6j(wwa.a, wwa.b, wwc.c, wwb.a, wwb.b, wwb.f)
                                if  wwa == specialaW6j  &&  wwb == specialbW6j  &&  wwc == specialcW6j 
                                    newPhase   = rex.phase  + xaRex.phase  + xbRex.phase  + xcRex.phase;    testPhase  = newPhase
                                    newWeight  = rex.weight * xaRex.weight * xbRex.weight * xcRex.weight
                                    testWeight = newWeight / ((2*wwa.c + 1) * (2*wwb.f + 1))
                                    newW6js    = W6j[];       
                                    for (idW6j, dW6j) in enumerate(rex.w6js)  
                                        if  idW6j != iaW6j &&  idW6j != ibW6j &&  idW6j != icW6j   push!(newW6js, dW6j)   end   
                                    end
                                    #
                                    if  RacahAlgebra.hasAllVars([wwa.c, wwb.f], rex.summations) &&  RacahAlgebra.hasNoVars([wwa.c, wwb.f], testPhase)   &&  
                                        RacahAlgebra.hasNoVars([wwa.c, wwb.f], testWeight)      &&  RacahAlgebra.hasNoVars([wwa.c, wwb.f], rex.deltas)  &&  
                                        RacahAlgebra.hasNoVars([wwa.c, wwb.f], rex.triangles)   &&  RacahAlgebra.hasNoVars([wwa.c, wwb.f], rex.w3js)    &&  
                                        RacahAlgebra.hasNoVars([wwa.c, wwb.f], newW6js)         &&  RacahAlgebra.hasNoVars([wwa.c, wwb.f], rex.w9js)
                                        newSummations = RacahAlgebra.removeIndex([wwa.c, wwb.f], rex.summations)
                                        push!(newW6js,  W6j(wwa.a, wwa.b, wwc.c,  wwa.d, wwa.e, wwa.f))
                                        wa = RacahExpression( newSummations, testPhase, testWeight, rex.deltas, rex.triangles, rex.w3js, newW6js, rex.w9js )
                                        println(">> Apply sum rule for three W6j -- Sum(X,Y) [X,Y] ...")
                                        return( (true, wa) )
                                    end
                                end
                                #
                                #   Rule:                 X+Y         ( a  b  X )   ( d  c  X )   ( a  d  q )          -p  d(p,q)
                                #   ----     Sum(X,Y) (-1)    [X,Y]  {(         )} {(         )} {(         )} =   (-1)    ------   d(a,d,p)  d(b,c,p)
                                #                                     ( c  d  p )   ( a  b  Y )   ( b  c  Y )              2p + 1
                                #
                                specialaW6j = W6j(wwa.a, wwa.b, wwa.c, wwa.d, wwa.e, wwa.f)
                                specialbW6j = W6j(wwa.e, wwa.d, wwa.c, wwa.a, wwa.b, wwb.f)
                                specialcW6j = W6j(wwa.a, wwa.e, wwc.c, wwa.b, wwa.d, wwb.f)
                                if  wwa == specialaW6j  &&  wwb == specialbW6j  &&  wwc == specialcW6j 
                                    newPhase   = rex.phase  + xaRex.phase  + xbRex.phase  + xcRex.phase;    testPhase  = newPhase - wwa.c - wwb.f - wwa.f
                                    newWeight  = rex.weight * xaRex.weight * xbRex.weight * xcRex.weight;   
                                    testWeight = newWeight / ((2*wwa.c + 1) * (2*wwb.f + 1)) / (2*wwa.f + 1)
                                    newW6js    = W6j[];       
                                    for (idW6j, dW6j) in enumerate(rex.w6js)  
                                        if  idW6j != iaW6j &&  idW6j != ibW6j &&  idW6j != icW6j   push!(newW6js, dW6j)   end   
                                    end
                                    #
                                    if  RacahAlgebra.hasAllVars([wwa.c, wwb.f], rex.summations) &&  RacahAlgebra.hasNoVars([wwa.c, wwb.f], testPhase)   &&  
                                        RacahAlgebra.hasNoVars([wwa.c, wwb.f], testWeight)      &&  RacahAlgebra.hasNoVars([wwa.c, wwb.f], rex.deltas)  &&  
                                        RacahAlgebra.hasNoVars([wwa.c, wwb.f], rex.triangles)   &&  RacahAlgebra.hasNoVars([wwa.c, wwb.f], rex.w3js)    &&  
                                        RacahAlgebra.hasNoVars([wwa.c, wwb.f], newW6js)         &&  RacahAlgebra.hasNoVars([wwa.c, wwb.f], rex.w9js)
                                        newSummations = RacahAlgebra.removeIndex([wwa.c, wwb.f], rex.summations)
                                        newDeltas     = rex.deltas;       push!(newDeltas,  Kronecker(wwa.f, wwc.c))
                                        newTriangles  = rex.triangles;    push!(newTriangles,  Triangle(wwa.a, wwa.e, wwa.f))
                                                                          push!(newTriangles,  Triangle(wwa.b, wwa.d, wwa.f))
                                        wa = RacahExpression( newSummations, testPhase, testWeight, newDeltas, newTriangles, rex.w3js, newW6js, rex.w9js )
                                        println(">> Apply sum rule for three W6j -- Sum(X,Y) (-1)^X+Y  [X,Y] ...")
                                        return( (true, wa) )
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        
        return( (false, RacahExpression()) )
    end


    """
    `RacahAlgebra.sumRulesForTwoW6jOneW9j(rex::RacahAlgebra.RacahExpression)`  
        ... attempts to find a simplification of the given Racah expression by using sum rules for three Wigner 3j symbols. 
            Once a simplification is found, no attempt is made to find another simplifcation for this set of rules.
            A (istrue, rex)::Tuple{Bool, RacahExpression} is returned but where rex has no meaning for !istrue.
    """
    function sumRulesForTwoW6jOneW9j(rex::RacahAlgebra.RacahExpression)
        # Make sure that the sum rule could apply at all
        if  length(rex.summations) < 2  ||  length(rex.w6js) < 2 ||  length(rex.w9js) < 1     return( (false, RacahExpression()) )    end
        
        # Loop through all Wigner nj symbols
        for  (icW9j, cW9j) in enumerate(rex.w9js)
            cRexList = RacahAlgebra.symmetricForms(cW9j)
            for  xcRex in cRexList
                for  (ibW6j, bW6j) in enumerate(rex.w6js)
                    bRexList = RacahAlgebra.symmetricForms(bW6j)
                    for  xbRex in bRexList
                        for  (iaW6j, aW6j) in enumerate(rex.w6js)
                            if  iaW6j == ibW6j      break    end
                            aRexList = RacahAlgebra.symmetricForms(aW6j)
                            for  xaRex in aRexList
                                wwa = xaRex.w6js[1];     wwb = xbRex.w6js[1];     wwc = xcRex.w9js[1]
                                #
                                #   Rule:                       ( p  X  Z )   ( q  Y  Z )    ( a  b  p )         2e       ( a  b  p )
                                #   ----    Sum(X,Y,Z) [X,Y,Z] {(         )} {(         )}  {( c  d  X )}  = (-1)   [d]  {(         )}
                                #                               ( d  e  c )   ( d  e  b )    ( q  Y  Z )                  ( e  c  q )
                                #
                                specialaW6j = W6j(wwa.a, wwa.b, wwa.c, wwa.d, wwa.e, wwa.f)
                                specialbW6j = W6j(wwb.a, wwb.b, wwa.c, wwa.d, wwa.e, wwb.f)
                                specialcW9j = W9j(wwc.a, wwb.f, wwa.a, wwa.f, wwb.d, wwa.b, wwb.a, wwb.b, wwa.c)
                                if  wwa == specialaW6j  &&  wwb == specialbW6j  &&  wwc == specialcW9j 
                                    newPhase   = rex.phase  + xaRex.phase  + xbRex.phase  + xcRex.phase;    testPhase  = newPhase + 2*wwa.e 
                                    newWeight  = rex.weight * xaRex.weight * xbRex.weight * xcRex.weight
                                    testWeight = newWeight / ((2*wwa.b + 1)*(2*wwb.b + 1)*(2*wwa.c + 1)) / (2*wwa.d + 1)
                                    newW6js    = W6j[];     newW9js    = W9j[];     
                                    for (idW6j, dW6j) in enumerate(rex.w6js)   if  idW6j != iaW6j &&  idW6j != ibW6j   push!(newW6js, dW6j)   end   end
                                    for (idW9j, dW9j) in enumerate(rex.w9js)   if  idW9j != icW9j                      push!(newW9js, dW9j)   end   end
                                    #
                                    if  RacahAlgebra.hasAllVars([wwa.b, wwb.b, wwa.c], rex.summations) &&  RacahAlgebra.hasNoVars([wwa.b, wwb.b, wwa.c], testPhase)   &&  
                                        RacahAlgebra.hasNoVars([wwa.b, wwb.b, wwa.c], testWeight)      &&  RacahAlgebra.hasNoVars([wwa.b, wwb.b, wwa.c], rex.deltas)  &&  
                                        RacahAlgebra.hasNoVars([wwa.b, wwb.b, wwa.c], rex.triangles)   &&  RacahAlgebra.hasNoVars([wwa.b, wwb.b, wwa.c], rex.w3js)    &&  
                                        RacahAlgebra.hasNoVars([wwa.b, wwb.b, wwa.c], newW6js)         &&  RacahAlgebra.hasNoVars([wwa.b, wwb.b, wwa.c], newW9js)
                                        newSummations = RacahAlgebra.removeIndex([wwa.b, wwb.b, wwa.c], rex.summations)
                                        push!(newW6js,  W6j(wwc.a, wwc.b, wwa.a, wwa.e, wwa.f, wwb.a))
                                        wa = RacahExpression( newSummations, testPhase, testWeight, rex.deltas, rex.triangles, rex.w3js, newW6js, newW9js )
                                        println(">> Apply sum rule for two W6j & one W9j -- Sum(X,Y,Z)  [X,Y,Z] ...")
                                        return( (true, wa) )
                                    end
                                end
                                #
                                #   Rule:                X+Y        ( c  d  X )   ( b  d  Y )    ( a  b  p )           s+t+2a  ( a  b  p )
                                #   ----    Sum(X,Y) (-1)   [X,Y]  {(         )} {(         )}  {( c  d  X )}    = (-1)       {( c  g  s )}
                                #                                   ( p  g  s )   ( q  g  t )    ( q  Y  g )                   ( q  t  d )
                                #
                                specialaW6j = W6j(wwa.a, wwa.b, wwa.c, wwa.d, wwa.e, wwa.f)
                                specialbW6j = W6j(wwb.a, wwa.b, wwb.c, wwb.d, wwa.e, wwb.f)
                                specialcW9j = W9j(wwc.a, wwb.a, wwa.d, wwa.a, wwa.b, wwa.c, wwb.d, wwb.c, wwa.e)
                                if  wwa == specialaW6j  &&  wwb == specialbW6j  &&  wwc == specialcW9j 
                                    newPhase   = rex.phase  + xaRex.phase  + xbRex.phase  + xcRex.phase;    
                                    testPhase  = newPhase - wwa.c  - wwb.c + wwa.f + wwb.f + 2*wwc.a
                                    newWeight  = rex.weight * xaRex.weight * xbRex.weight * xcRex.weight
                                    testWeight = newWeight / ((2*wwa.c + 1)*(2*wwb.c + 1))
                                    newW6js    = W6j[];     newW9js    = W9j[];     
                                    for (idW6j, dW6j) in enumerate(rex.w6js)   if  idW6j != iaW6j &&  idW6j != ibW6j   push!(newW6js, dW6j)   end   end
                                    for (idW9j, dW9j) in enumerate(rex.w9js)   if  idW9j != icW9j                      push!(newW9js, dW9j)   end   end
                                    #
                                    if  RacahAlgebra.hasAllVars([wwa.c, wwb.c], rex.summations) &&  RacahAlgebra.hasNoVars([wwa.c, wwb.c], testPhase)   &&  
                                        RacahAlgebra.hasNoVars([wwa.c, wwb.c], testWeight)      &&  RacahAlgebra.hasNoVars([wwa.c, wwb.c], rex.deltas)  &&  
                                        RacahAlgebra.hasNoVars([wwa.c, wwb.c], rex.triangles)   &&  RacahAlgebra.hasNoVars([wwa.c, wwb.c], rex.w3js)    &&  
                                        RacahAlgebra.hasNoVars([wwa.c, wwb.c], newW6js)         &&  RacahAlgebra.hasNoVars([wwa.c, wwb.c], newW9js)
                                        newSummations = RacahAlgebra.removeIndex([wwa.c, wwb.c], rex.summations)
                                        push!(newW9js,  W9j(wwc.a, wwc.b, wwc.c, wwa.a, wwa.e, wwa.f, wwb.d, wwb.f, wwa.b))
                                        wa = RacahExpression( newSummations, testPhase, testWeight, rex.deltas, rex.triangles, rex.w3js, newW6js, newW9js )
                                        println(">> Apply sum rule for two W6j & one W9j -- Sum(X,Y) (-1)X+Y   [X,Y] ...")
                                        return( (true, wa) )
                                    end
                                end
                                #
                                #   Rule:                    ( c  d  X )   ( b  d  Y )    ( a  b  p )          2s   d(s,t)            ( a  b  p )
                                #   ----    Sum(X,Y) [X,Y]  {(         )} {(         )}  {( c  d  X )}   = (-1)    -------  d(d,g,s) {(         )}
                                #                            ( g  p  s )   ( g  q  t )    ( q  Y  g )                 [s]             ( s  c  q )
                                #
                                specialaW6j = W6j(wwa.a, wwa.b, wwa.c, wwa.d, wwa.e, wwa.f)
                                specialbW6j = W6j(wwb.a, wwa.b, wwb.c, wwa.d, wwb.e, wwb.f)
                                specialcW9j = W9j(wwc.a, wwb.a, wwa.e, wwa.a, wwa.b, wwa.c, wwb.e, wwb.c, wwa.d)
                                if  wwa == specialaW6j  &&  wwb == specialbW6j  &&  wwc == specialcW9j 
                                    newPhase   = rex.phase  + xaRex.phase  + xbRex.phase  + xcRex.phase;    testPhase  = newPhase + 2*wwa.f
                                    newWeight  = rex.weight * xaRex.weight * xbRex.weight * xcRex.weight
                                    testWeight = newWeight / ((2*wwa.c + 1)*(2*wwb.c + 1)) / (2*wwa.f + 1)
                                    newW6js    = W6j[];     newW9js    = W9j[];     
                                    for (idW6j, dW6j) in enumerate(rex.w6js)   if  idW6j != iaW6j &&  idW6j != ibW6j   push!(newW6js, dW6j)   end   end
                                    for (idW9j, dW9j) in enumerate(rex.w9js)   if  idW9j != icW9j                      push!(newW9js, dW9j)   end   end
                                    #
                                    if  RacahAlgebra.hasAllVars([wwa.c, wwb.c], rex.summations) &&  RacahAlgebra.hasNoVars([wwa.c, wwb.c], testPhase)   &&  
                                        RacahAlgebra.hasNoVars([wwa.c, wwb.c], testWeight)      &&  RacahAlgebra.hasNoVars([wwa.c, wwb.c], rex.deltas)  &&  
                                        RacahAlgebra.hasNoVars([wwa.c, wwb.c], rex.triangles)   &&  RacahAlgebra.hasNoVars([wwa.c, wwb.c], rex.w3js)    &&  
                                        RacahAlgebra.hasNoVars([wwa.c, wwb.c], newW6js)         &&  RacahAlgebra.hasNoVars([wwa.c, wwb.c], newW9js)
                                        newSummations = RacahAlgebra.removeIndex([wwa.c, wwb.c], rex.summations)
                                        newDeltas     = rex.deltas;       push!(newDeltas, Kronecker(wwa.f, wwb.f))
                                        newTriangles  = rex.triangles;    push!(newTriangles, Triangle(wwa.b, wwa.d, wwa.f))
                                        push!(newW6js,  W6j(wwc.a, wwc.b, wwa.e, wwa.f, wwa.a, wwb.e))
                                        wa = RacahExpression( newSummations, testPhase, testWeight, newDeltas, newTriangles, rex.w3js, newW6js, newW9js )
                                        println(">> Apply sum rule for two W6j & one W9j -- Sum(X,Y)  [X,Y] ... (1st)")
                                        return( (true, wa) )
                                    end
                                end
                                #
                                #   Rule:                    ( a  b  X )   ( c  d  Y )    ( a  b  X )         2h   d(f,j)            ( e  j  g )
                                #   ----    Sum(X,Y) [X,Y]  {(         )} {(         )}  {( c  d  Y )}  = (-1)    -------  d(b,d,f) {(         )}
                                #                            ( Y  g  h )   ( b  h  j )    ( e  f  g )               [f]              ( h  a  c )
                                #
                                specialaW6j = W6j(wwa.a, wwa.b, wwa.c, wwa.d, wwa.e, wwa.f)
                                specialbW6j = W6j(wwb.a, wwb.b, wwa.d, wwa.b, wwa.f, wwb.f)
                                specialcW9j = W9j(wwa.a, wwa.b, wwa.c, wwb.a, wwb.b, wwb.c, wwc.g, wwc.h, wwa.e)
                                if  wwa == specialaW6j  &&  wwb == specialbW6j  &&  wwc == specialcW9j 
                                    newPhase   = rex.phase  + xaRex.phase  + xbRex.phase  + xcRex.phase;    testPhase  = newPhase + 2*wwa.f
                                    newWeight  = rex.weight * xaRex.weight * xbRex.weight * xcRex.weight
                                    testWeight = newWeight / ((2*wwa.c + 1)*(2*wwb.c + 1)) / (2*wwc.h + 1)
                                    newW6js    = W6j[];     newW9js    = W9j[];     
                                    for (idW6j, dW6j) in enumerate(rex.w6js)   if  idW6j != iaW6j &&  idW6j != ibW6j   push!(newW6js, dW6j)   end   end
                                    for (idW9j, dW9j) in enumerate(rex.w9js)   if  idW9j != icW9j                      push!(newW9js, dW9j)   end   end
                                    #
                                    if  RacahAlgebra.hasAllVars([wwa.c, wwb.c], rex.summations) &&  RacahAlgebra.hasNoVars([wwa.c, wwb.c], testPhase)   &&  
                                        RacahAlgebra.hasNoVars([wwa.c, wwb.c], testWeight)      &&  RacahAlgebra.hasNoVars([wwa.c, wwb.c], rex.deltas)  &&  
                                        RacahAlgebra.hasNoVars([wwa.c, wwb.c], rex.triangles)   &&  RacahAlgebra.hasNoVars([wwa.c, wwb.c], rex.w3js)    &&  
                                        RacahAlgebra.hasNoVars([wwa.c, wwb.c], newW6js)         &&  RacahAlgebra.hasNoVars([wwa.c, wwb.c], newW9js)
                                        newSummations = RacahAlgebra.removeIndex([wwa.c, wwb.c], rex.summations)
                                        newDeltas     = rex.deltas;         push!(newDeltas, Kronecker(wwc.h, wwb.f))
                                        newTriangles  = rex.triangles;      push!(newTriangles, Triangle(wwa.b, wwb.b, wwc.h))
                                        push!(newW6js,  W6j(wwc.g, wwb.f, wwa.e, wwa.f, wwa.a, wwb.a))
                                        wa = RacahExpression( newSummations, testPhase, testWeight, newDeltas, newTriangles, rex.w3js, newW6js, newW9js )
                                        println(">> Apply sum rule for two W6j & one W9j -- Sum(X,Y)  [X,Y] ... (2nd)")
                                        return( (true, wa) )
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        
        return( (false, RacahExpression()) )
    end


    """
    `RacahAlgebra.sumRulesForOneW6jTwoW9j(rex::RacahAlgebra.RacahExpression)`  
        ... attempts to find a simplification of the given Racah expression by using sum rules for three Wigner 3j symbols. 
            Once a simplification is found, no attempt is made to find another simplifcation for this set of rules.
            A (istrue, rex)::Tuple{Bool, RacahExpression} is returned but where rex has no meaning for !istrue.
    """
    function sumRulesForOneW6jTwoW9j(rex::RacahAlgebra.RacahExpression)
        # Make sure that the sum rule could apply at all
        if  length(rex.summations) < 2  ||  length(rex.w6js) < 1  ||  length(rex.w9js) < 2     return( (false, RacahExpression()) )    end
        
        # Loop through all Wigner 3j symbols
        for  (icW9j, cW9j) in enumerate(rex.w9js)
            cRexList = RacahAlgebra.symmetricForms(cW9j)
            for  xcRex in cRexList
                for  (ibW9j, bW9j) in enumerate(rex.w9js)
                    if  icW9j == ibW9j      break    end
                    bRexList = RacahAlgebra.symmetricForms(bW9j)
                    for  xbRex in bRexList
                        for  (iaW6j, aW6j) in enumerate(rex.w6js)
                            aRexList = RacahAlgebra.symmetricForms(aW6j)
                            for  xaRex in aRexList
                                wwa = xaRex.w6js[1];     wwb = xbRex.w9js[1];     wwc = xcRex.w9js[1]
                                #
                                #   Rule:                     ( a  h  Y )    ( a  f  X )   ( a  f  X )       ( a  b  s )   ( c  d  s )   ( e  f  s )
                                #   ----    Sum(X,Y)  [X,Y]  {(         )}  {( d  q  e )} {( h  r  e )}  =  {(         )} {(         )} {(         )}
                                #                             ( g  b  s )    ( p  c  b )   ( Y  g  b )       ( c  d  p )   ( e  f  q )   ( g  h  r )
                                #
                                specialaW6j = W6j(wwa.a, wwa.b, wwa.c, wwa.d, wwa.e, wwa.f)
                                specialbW9j = W9j(wwb.a, wwb.b, wwb.c, wwb.d, wwb.e, wwb.f, wwb.g, wwb.h, wwa.e)
                                specialcW9j = W9j(wwa.a, wwb.b, wwb.c, wwa.b, wwc.e, wwb.f, wwa.c, wwa.d, wwa.e)
                                if  wwa == specialaW6j  &&  wwb == specialbW9j  &&  wwc == specialcW9j 
                                    newPhase   = rex.phase  + xaRex.phase  + xbRex.phase  + xcRex.phase;    testPhase  = newPhase
                                    newWeight  = rex.weight * xaRex.weight * xbRex.weight * xcRex.weight;
                                    testWeight = newWeight / ((2*wwb.c + 1)*(2*wwa.c + 1))
                                    newW6js    = W6j[];     newW9js    = W9j[];     
                                    for (idW6j, dW6j) in enumerate(rex.w6js)   if  idW6j != iaW6j                      push!(newW6js, dW6j)   end   end
                                    for (idW9j, dW9j) in enumerate(rex.w9js)   if  idW9j != ibW9j &&  idW9j != icW9j   push!(newW9js, dW9j)   end   end
                                    #
                                    if  RacahAlgebra.hasAllVars([wwa.c, wwb.c], rex.summations) &&  RacahAlgebra.hasNoVars([wwa.c, wwb.c], testPhase)   &&  
                                        RacahAlgebra.hasNoVars([wwa.c, wwb.c], testWeight)      &&  RacahAlgebra.hasNoVars([wwa.c, wwb.c], rex.deltas)  &&  
                                        RacahAlgebra.hasNoVars([wwa.c, wwb.c], rex.triangles)   &&  RacahAlgebra.hasNoVars([wwa.c, wwb.c], rex.w3js)    &&  
                                        RacahAlgebra.hasNoVars([wwa.c, wwb.c], newW6js)         &&  RacahAlgebra.hasNoVars([wwa.c, wwb.c], newW9js)
                                        newSummations = RacahAlgebra.removeIndex([wwa.c, wwb.c], rex.summations)
                                        push!(newW6js,  W6j(wwa.a, wwa.e, wwa.f, wwb.h, wwb.d, wwb.g))
                                        push!(newW6js,  W6j(wwb.h, wwb.d, wwa.f, wwb.f, wwb.b, wwb.e))
                                        push!(newW6js,  W6j(wwb.f, wwb.b, wwa.f, wwc.h, wwa.b, wwc.e))
                                        wa = RacahExpression( newSummations, testPhase, testWeight, rex.deltas, rex.triangles, rex.w3js, newW6js, newW9js )
                                        println(">> Apply sum rule for one W6j & two W9j -- Sum(X,Y)  [X,Y] ...")
                                        return( (true, wa) )
                                    end
                                end
                                #
                                #   Rule:                            X+Y   ( a  b  X )    ( a  b  X )   ( g  b  Y )         e+h  d(f,j)             ( e  f  g )
                                #   ----    Sum(X,Y,Z)  [X,Y,Z]  (-1)     {(         )}  {( c  d  Z )} {( c  d  Z )}  = (-1)     ------  d(b,d,f)  {(         )}
                                #                                          ( g  Z  Y )    ( e  f  g )   ( h  j  a )              2f + 1             ( h  c  a )
                                #
                                specialaW6j = W6j(wwa.a, wwa.b, wwa.c, wwa.d, wwa.e, wwa.f)
                                specialbW9j = W9j(wwa.a, wwa.b, wwa.c, wwb.d, wwb.e, wwa.e, wwb.g, wwb.h, wwa.d)
                                specialcW9j = W9j(wwa.d, wwa.b, wwa.f, wwb.d, wwb.e, wwa.e, wwc.g, wwc.h, wwa.a)
                                if  wwa == specialaW6j  &&  wwb == specialbW9j  &&  wwc == specialcW9j 
                                    newPhase   = rex.phase  + xaRex.phase  + xbRex.phase  + xcRex.phase;    
                                    testPhase  = newPhase - wwa.c - wwa.f + wwb.g + wwc.g
                                    newWeight  = rex.weight * xaRex.weight * xbRex.weight * xcRex.weight;
                                    testWeight = newWeight / ((2*wwa.c + 1)*(2*wwa.f + 1)*(2*wwa.e + 1)) / (2*wwb.h + 1)
                                    newW6js    = W6j[];     newW9js    = W9j[];     
                                    for (idW6j, dW6j) in enumerate(rex.w6js)   if  idW6j != iaW6j                      push!(newW6js, dW6j)   end   end
                                    for (idW9j, dW9j) in enumerate(rex.w9js)   if  idW9j != ibW9j &&  idW9j != icW9j   push!(newW9js, dW9j)   end   end
                                    #
                                    if  RacahAlgebra.hasAllVars([wwa.c, wwa.f, wwa.e], rex.summations) &&  RacahAlgebra.hasNoVars([wwa.c, wwa.f, wwa.e], testPhase)   &&  
                                        RacahAlgebra.hasNoVars([wwa.c, wwa.f, wwa.e], testWeight)      &&  RacahAlgebra.hasNoVars([wwa.c, wwa.f, wwa.e], rex.deltas)  &&  
                                        RacahAlgebra.hasNoVars([wwa.c, wwa.f, wwa.e], rex.triangles)   &&  RacahAlgebra.hasNoVars([wwa.c, wwa.f, wwa.e], rex.w3js)    &&  
                                        RacahAlgebra.hasNoVars([wwa.c, wwa.f, wwa.e], newW6js)         &&  RacahAlgebra.hasNoVars([wwa.c, wwa.f, wwa.e], newW9js)
                                        newSummations = RacahAlgebra.removeIndex([wwa.c, wwa.f, wwa.e], rex.summations)
                                        newDeltas     = rex.deltas;         push!(newDeltas, Kronecker(wwb.h, wwc.h))
                                        newTriangles  = rex.triangles;      push!(newTriangles, Triangle(wwa.b, wwb.e, wwb.h))
                                        push!(newW6js,  W6j(wwb.g, wwb.h, wwa.d, wwc.g, wwb.d, wwa.a))
                                        wa = RacahExpression( newSummations, testPhase, testWeight, newDeltas, newTriangles, rex.w3js, newW6js, newW9js )
                                        println(">> Apply sum rule for one W6j & two W9j -- Sum(X,Y,Z) (-1)^X+Y  [X,Y,Z] ...")
                                        return( (true, wa) )
                                    end
                                end
                                #
                                #   Rule:                            X  ( p  X  Z )    ( a  b  p )   ( b  d  Y )          a+l-f  d(p,k)             ( a  b  p )
                                #   ----    Sum(X,Y,Z)  [X,Y,Z]  (-1)  {(         )}  {( c  d  X )} {( c  f  Z )}  = (-1)        ------  d(d,f p)  {(         )}
                                #                                       ( c  f  d )    ( q  Y  Z )   ( l  k  q )                 2k + 1             ( l  q  c )
                                #
                                specialaW6j = W6j(wwa.a, wwa.b, wwa.c, wwa.d, wwa.e, wwa.f)
                                specialbW9j = W9j(wwb.a, wwb.b, wwb.c, wwa.d, wwb.e, wwa.b, wwb.g, wwb.h, wwa.c)
                                specialcW9j = W9j(wwb.b, wwb.e, wwb.h, wwa.d, wwa.e, wwa.c, wwc.g, wwc.h, wwb.g)
                                if  wwa == specialaW6j  &&  wwb == specialbW9j  &&  wwc == specialcW9j 
                                    newPhase   = rex.phase  + xaRex.phase  + xbRex.phase  + xcRex.phase;    testPhase  = newPhase - wwa.b + wwb.a + wwc.g - wwa.e
                                    newWeight  = rex.weight * xaRex.weight * xbRex.weight * xcRex.weight;
                                    testWeight = newWeight / ((2*wwa.b + 1)*(2*wwb.h + 1)*(2*wwa.c + 1)) / (2*wwc.h + 1)
                                    newW6js    = W6j[];     newW9js    = W9j[];     
                                    for (idW6j, dW6j) in enumerate(rex.w6js)   if  idW6j != iaW6j                      push!(newW6js, dW6j)   end   end
                                    for (idW9j, dW9j) in enumerate(rex.w9js)   if  idW9j != ibW9j &&  idW9j != icW9j   push!(newW9js, dW9j)   end   end
                                    #
                                    if  RacahAlgebra.hasAllVars([wwa.b, wwb.h, wwa.c], rex.summations) &&  RacahAlgebra.hasNoVars([wwa.b, wwb.h, wwa.c], testPhase)   &&  
                                        RacahAlgebra.hasNoVars([wwa.b, wwb.h, wwa.c], testWeight)      &&  RacahAlgebra.hasNoVars([wwa.b, wwb.h, wwa.c], rex.deltas)  &&  
                                        RacahAlgebra.hasNoVars([wwa.b, wwb.h, wwa.c], rex.triangles)   &&  RacahAlgebra.hasNoVars([wwa.b, wwb.h, wwa.c], rex.w3js)    &&  
                                        RacahAlgebra.hasNoVars([wwa.b, wwb.h, wwa.c], newW6js)         &&  RacahAlgebra.hasNoVars([wwa.b, wwb.h, wwa.c], newW9js)
                                        newSummations = RacahAlgebra.removeIndex([wwa.b, wwb.h, wwa.c], rex.summations)
                                        newDeltas     = rex.deltas;         push!(newDeltas, Kronecker(wwa.a, wwc.h))
                                        newTriangles  = rex.triangles;      push!(newTriangles, Triangle(wwb.e, wwa.e, wwb.c))
                                        push!(newW6js,  W6j(wwb.a, wwb.b, wwb.c, wwc.g, wwb.g, wwa.d))
                                        wa = RacahExpression( newSummations, testPhase, testWeight, newDeltas, newTriangles, rex.w3js, newW6js, newW9js )
                                        println(">> Apply sum rule for one W6j & two W9j -- Sum(X,Y,Z) (-1)^X [X,Y,Z] ...")
                                        return( (true, wa) )
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        
        return( (false, RacahExpression()) )
    end


    """
    `RacahAlgebra.sumRulesForThreeW9j(rex::RacahAlgebra.RacahExpression)`  
        ... attempts to find a simplification of the given Racah expression by using sum rules for three Wigner 3j symbols. 
            Once a simplification is found, no attempt is made to find another simplifcation for this set of rules.
            A (istrue, rex)::Tuple{Bool, RacahExpression} is returned but where rex has no meaning for !istrue.
    """
    function sumRulesForThreeW9j(rex::RacahAlgebra.RacahExpression)
        # Make sure that the sum rule could apply at all
        if  length(rex.summations) < 3  ||  length(rex.w9js) < 3     return( (false, RacahExpression()) )    end
        
        # Loop through all Wigner nj symbols
        for  (icW9j, cW9j) in enumerate(rex.w9js)
            cRexList = RacahAlgebra.symmetricForms(cW9j)
            for  xcRex in cRexList
                for  (ibW9j, bW9j) in enumerate(rex.w9js)
                    if  icW9j == ibW9j    break    end
                    bRexList = RacahAlgebra.symmetricForms(bW9j)
                    for  xbRex in bRexList
                        for  (iaW9j, aW9j) in enumerate(rex.w9js)
                            if  iaW9j == ibW9j    ||   iaW9j == icW9j      break    end
                            aRexList = RacahAlgebra.symmetricForms(aW9j)
                            for  xaRex in aRexList
                                wwa = xaRex.w9js[1];     wwb = xbRex.w9js[1];     wwc = xcRex.w9js[1]
                                #
                                #   Rule:                        ( a  b  p )   ( c  d  X )   ( b  d  Y )       d(h,k)             ( a  b  p )
                                #   ----     Sum(X,Y,Z) [X,Y,Z] {( c  d  X )} {( e  f  Z )} {( e  f  Z )}   =  ------  d(d,f,h)  {( c  e  g )}
                                #                                ( q  Y  Z )   ( g  h  p )   ( j  k  q )        [h]               ( q  j  h )
                                #
                                specialaW9j = W9j(wwa.a, wwa.b, wwa.c, wwa.d, wwa.e, wwa.f, wwa.g, wwa.h, wwa.i) 
                                specialbW9j = W9j(wwa.d, wwa.e, wwa.f, wwb.d, wwb.e, wwa.i, wwb.g, wwb.h, wwa.c)
                                specialcW9j = W9j(wwa.b, wwb.b, wwa.h, wwb.d, wwb.e, wwa.i, wwc.g, wwc.h, wwa.g)
                                if  wwa == specialaW9j  &&  wwb == specialbW9j  &&  wwc == specialcW9j
                                    newPhase   = rex.phase  + xaRex.phase  + xbRex.phase  + xcRex.phase;    testPhase  = newPhase
                                    newWeight  = rex.weight * xaRex.weight * xbRex.weight * xcRex.weight;
                                    testWeight = newWeight / ((2*wwa.f + 1)*(2*wwa.h + 1)*(2*wwa.i + 1)) / (2*wwb.h + 1)
                                    newW9js    = W9j[];     
                                    for (idW9j, dW9j) in enumerate(rex.w9js)   if  idW9j != iaW9j &&  idW9j != ibW9j &&  idW9j != icW9j   push!(newW9js, dW9j)   end   
                                    end
                                    #
                                    if  RacahAlgebra.hasAllVars([wwa.f, wwa.h, wwa.i], rex.summations) &&  RacahAlgebra.hasNoVars([wwa.f, wwa.h, wwa.i], testPhase)   &&  
                                        RacahAlgebra.hasNoVars([wwa.f, wwa.h, wwa.i], testWeight)      &&  RacahAlgebra.hasNoVars([wwa.f, wwa.h, wwa.i], rex.deltas)  &&  
                                        RacahAlgebra.hasNoVars([wwa.f, wwa.h, wwa.i], rex.triangles)   &&  RacahAlgebra.hasNoVars([wwa.f, wwa.h, wwa.i], rex.w3js)    &&  
                                        RacahAlgebra.hasNoVars([wwa.f, wwa.h, wwa.i], rex.w6js)        &&  RacahAlgebra.hasNoVars([wwa.f, wwa.h, wwa.i], newW9js)
                                        newSummations = RacahAlgebra.removeIndex([wwa.b, wwb.h, wwa.c], rex.summations)
                                        newDeltas     = rex.deltas;         push!(newDeltas, Kronecker(wwb.h, wwc.h))
                                        newTriangles  = rex.triangles;      push!(newTriangles, Triangle(wwa.e, wwb.e, wwb.h))
                                        push!(newW9js,  W9j(wwa.a, wwa.b, wwa.c, wwa.d, wwb.d, wwb.g, wwa.g, wwc.g, wwb.h))
                                        wa = RacahExpression( newSummations, testPhase, testWeight, newDeltas, newTriangles, rex.w3js, rex.w6js, newW9js )
                                        println(">> Apply sum rule for three W9j -- Sum(X,Y,Z) [X,Y,Z] ...")
                                        return( (true, wa) )
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        
        return( (false, RacahExpression()) )
    end


    """
    `RacahAlgebra.sumRulesForFourW3j(rex::RacahAlgebra.RacahExpression)`  
        ... attempts to find a simplification of the given Racah expression by using sum rules for four Wigner 3j symbols. 
            Once a simplification is found, no attempt is made to find another simplifcation for this set of rules.
            A (istrue, rex)::Tuple{Bool, RacahExpression} is returned but where rex has no meaning for !istrue.
    """
    function sumRulesForFourW3j(rex::RacahAlgebra.RacahExpression)
        # Make sure that the sum rule could apply at all
        if  length(rex.summations) < 4  ||  length(rex.w3js) < 4     return( (false, RacahExpression()) )    end
        
        # Loop through all Wigner 3j symbols
        for  (idW3j, dW3j) in enumerate(rex.w3js)
            dRexList = RacahAlgebra.symmetricForms(dW3j)
            for  xdRex in dRexList
                for  (icW3j, cW3j) in enumerate(rex.w3js)
                    if  icW3j == idW3j    break    end
                    cRexList = RacahAlgebra.symmetricForms(cW3j)
                    for  xcRex in cRexList
                        for  (ibW3j, bW3j) in enumerate(rex.w3js)
                            if  ibW3j == icW3j   ||   ibW3j == idW3j    break    end
                            bRexList = RacahAlgebra.symmetricForms(bW3j)
                            for  xbRex in bRexList
                                for  (iaW3j, aW3j) in enumerate(rex.w3js)
                                    if  iaW3j == ibW3j    ||   iaW3j == icW3j    ||   iaW3j == idW3j      break    end
                                    aRexList = RacahAlgebra.symmetricForms(aW3j)
                                    for  xaRex in aRexList
                                        wwa = xaRex.w3js[1];     wwb = xbRex.w3js[1];     wwc = xcRex.w3js[1];     wwd = xdRex.w3js[1]
                                        #
                                        #   Rule:                        -m1-m2-m3-m4  ( j1 j5  j2 ) ( j2 j6  j3 ) ( j3 j7  j4 ) ( j4 j8  j1 )
                                        #   ----    Sum(m1,m2,m3,m4) (-1)              (           ) (           ) (           ) (           )
                                        #                                              ( m1 m5 -m2 ) ( m2 m6 -m3 ) ( m3 m7 -m4 ) ( m4 m8 -m1 )
                                        #
                                        #
                                        #                -j1-2j2-j3-j5-j8                  j9-m9            ( j5  j9 j8 ) ( j6 j9 j7 )  ( j5 j9 j8 )   ( j6 j9 j7 )
                                        #         =  (-1)                   Sum(j9,m9) (-1)      (2j9 + 1)  (           ) (          ) {(          )} {(          )}
                                        #                                                                   ( m5 -m9 m8 ) ( m6 m9 m7 )  ( j4 j1 j2 )   ( j4 j3 j2 )
                                        #
                                        specialaW3j = W3j(wwa.ja, wwa.jb, wwa.jc, wwa.ma, wwa.mb, -wwb.ma)
                                        specialbW3j = W3j(wwa.jc, wwb.jb, wwb.jc, wwb.ma, wwb.mb, -wwc.ma)
                                        specialcW3j = W3j(wwb.jc, wwc.jb, wwc.jc, wwc.ma, wwc.mb, -wwd.ma)
                                        specialdW3j = W3j(wwc.jc, wwd.jb, wwa.ja, wwd.ma, wwd.mb, -wwa.ma)
                                        if  wwa == specialaW3j  &&  wwb == specialbW3j  &&  wwc == specialcW3j  &&  wwd == specialdW3j 
                                            j9 = Basic(:j9);   m9 = Basic(:m9)
                                            newPhase  = rex.phase  + xaRex.phase  + xbRex.phase  + xcRex.phase  + xdRex.phase
                                            testPhase = newPhase + wwa.ma + wwb.ma + wwc.ma + wwd.ma - wwa.ja - 2*wwa.jc - wwb.jc - wwa.jb - wwd.jb + j9 - m9   
                                            newWeight = rex.weight * xaRex.weight * xbRex.weight * xcRex.weight * xdRex.weight;    testWeight = newWeight * (2*j9 + 1)
                                            newW3js    = W3j[];      newW6js    = W6j[];    
                                            for (ieW3j, eW3j) in enumerate(rex.w3js)  
                                                if  ieW3j != iaW3j &&  ieW3j != ibW3j &&  ieW3j != icW3j &&  ieW3j != idW3j   push!(newW3js, eW3j)   end   
                                            end
                                            #
                                            if  RacahAlgebra.hasAllVars([wwa.ma, wwb.ma, wwc.ma, wwd.ma], rex.summations)   &&  
                                                RacahAlgebra.hasNoVars([wwa.ma, wwb.ma, wwc.ma, wwd.ma], testPhase)         &&  
                                                RacahAlgebra.hasNoVars([wwa.ma, wwb.ma, wwc.ma, wwd.ma], testWeight)        &&  
                                                RacahAlgebra.hasNoVars([wwa.ma, wwb.ma, wwc.ma, wwd.ma], rex.deltas)        &&  
                                                RacahAlgebra.hasNoVars([wwa.ma, wwb.ma, wwc.ma, wwd.ma], rex.triangles)     && 
                                                RacahAlgebra.hasNoVars([wwa.ma, wwb.ma, wwc.ma, wwd.ma], newW3js)           &&  
                                                RacahAlgebra.hasNoVars([wwa.ma, wwb.ma, wwc.ma, wwd.ma], rex.w6js)          &&  
                                                RacahAlgebra.hasNoVars([wwa.ma, wwb.ma, wwc.ma, wwd.ma], rex.w9js)
                                                newSummations = RacahAlgebra.removeIndex([wwa.ma, wwb.ma, wwc.ma, wwd.ma], rex.summations)
                                                push!(newSummations, j9)
                                                push!(newW3js,  W3j(wwa.jb, j9, wwd.jb, wwa.mb, -m9, wwd.mb))
                                                push!(newW3js,  W3j(wwb.jb, j9, wwc.jb, wwb.mb,  m9, wwc.mb))
                                                push!(newW6js,  W6j(wwa.jb, j9, wwd.jb, wwd.ja,  wwa.ja, wwa.jc))
                                                push!(newW6js,  W6j(wwb.jb, j9, wwc.jb, wwc.jc,  wwb.jc, wwa.jc))
                                                wa = RacahExpression( newSummations, testPhase, testWeight, rex.deltas, rex.triangles, newW3js, newW6js, rex.w9js )
                                                println(">> Apply sum rule for four W3j -- Sum(m1,m2,m3,m4) (-1)^-m1-m2-m3-m4  ...")
                                                return( (true, wa) )
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        
        return( (false, RacahExpression()) )
    end


    """
    `RacahAlgebra.sumRulesForFiveW3j(rex::RacahAlgebra.RacahExpression)`  
        ... attempts to find a simplification of the given Racah expression by using sum rules for five Wigner 3j symbols. 
            Once a simplification is found, no attempt is made to find another simplifcation for this set of rules.
            A (istrue, rex)::Tuple{Bool, RacahExpression} is returned but where rex has no meaning for !istrue.
    """
    function sumRulesForFiveW3j(rex::RacahAlgebra.RacahExpression)
        # Make sure that the sum rule could apply at all
        if  length(rex.summations) < 5  ||  length(rex.w3js) < 5     return( (false, RacahExpression()) )    end
        
        # Loop through all Wigner 3j symbols
        for  (ieW3j, eW3j) in enumerate(rex.w3js)
            eRexList = RacahAlgebra.symmetricForms(eW3j)
            for  xeRex in eRexList
                for  (idW3j, dW3j) in enumerate(rex.w3js)
                    if  idW3j == ieW3j    break    end
                    dRexList = RacahAlgebra.symmetricForms(dW3j)
                    for  xdRex in dRexList
                        for  (icW3j, cW3j) in enumerate(rex.w3js)
                            if  icW3j == idW3j   ||   icW3j == ieW3j    break    end
                            cRexList = RacahAlgebra.symmetricForms(cW3j)
                            for  xcRex in cRexList
                                for  (ibW3j, bW3j) in enumerate(rex.w3js)
                                    if  ibW3j == icW3j   ||   ibW3j == idW3j   ||   ibW3j == ieW3j    break    end
                                    bRexList = RacahAlgebra.symmetricForms(bW3j)
                                    for  xbRex in bRexList
                                        for  (iaW3j, aW3j) in enumerate(rex.w3js)
                                            if  iaW3j == ibW3j    ||   iaW3j == icW3j    ||   iaW3j == idW3j    ||   iaW3j == ieW3j      break    end
                                            aRexList = RacahAlgebra.symmetricForms(aW3j)
                                            for  xaRex in aRexList
                                                wwa = xaRex.w3js[1];   wwb = xbRex.w3js[1];   wwc = xcRex.w3js[1];   wwd = xdRex.w3js[1];   wwe = xeRex.w3js[1]
                                                #
                                                #   Rule:                           -m1-m2-m3-m4-m5  ( j1 j6  j2 ) ( j2 j7  j3 ) ( j3 j8  j4 ) ( j4 j9  j5 ) ( j5 j10  j1 )
                                                #   ----    Sum(m1,m2,m3,m4,m5) (-1)                 (           ) (           ) (           ) (           ) (            )
                                                #                                                    ( m1 m6 -m2 ) ( m2 m7 -m3 ) ( m3 m8 -m4 ) ( m4 m9 -m5 ) ( m5 m10 -m1 )
                                                #
                                                #
                                                #                  -2j1-j7-j6-j9-j8-j2-j3-j4                      x-xi+y-eta                     
                                                #           =  (-1)                           Sum(x,xi,y,eta) (-1)            (2x + 1) (2y + 1)  *
                                                #
                                                #
                                                #                  ( j6 j7  x ) (  x  j10   y  ) (  y  j8 j9 )  ( j6 j7  x )   (  x j10 y )   (  y j8 j9 )
                                                #                  (          ) (              ) (           ) {(          )} {(          )} {(          )}
                                                #                  ( m6 m7 xi ) ( -xi m10 -eta ) ( eta m8 m9 )  ( j3 j1 j2 )   ( j5 j3 j1 )   ( j4 j5 j3 )
                                                #
                                                specialaW3j = W3j(wwa.ja, wwa.jb, wwa.jc, wwa.ma, wwa.mb, -wwb.ma)
                                                specialbW3j = W3j(wwa.jc, wwb.jb, wwb.jc, wwb.ma, wwb.mb, -wwc.ma)
                                                specialcW3j = W3j(wwb.jc, wwc.jb, wwc.jc, wwc.ma, wwc.mb, -wwd.ma)
                                                specialdW3j = W3j(wwc.jc, wwd.jb, wwd.jc, wwd.ma, wwd.mb, -wwe.ma)
                                                specialeW3j = W3j(wwd.jc, wwe.jb, wwa.ja, wwe.ma, wwe.mb, -wwa.ma)
                                                if  wwa == specialaW3j  &&  wwb == specialbW3j  &&  wwc == specialcW3j  &&  wwd == specialdW3j  &&  wwe == specialeW3j  
                                                    x = Basic(:x);   xi = Basic(:xi);   y = Basic(:y);   eta = Basic(:eta)
                                                    newPhase  = rex.phase  + xaRex.phase  + xbRex.phase  + xcRex.phase  + xdRex.phase  + xeRex.phase
                                                    testPhase = newPhase + wwa.ma + wwb.ma + wwc.ma + wwd.ma + wwe.ma - 2*wwa.ja - wwb.jb - wwa.jb - wwd.jb 
                                                    testPhase = testPhase - wwc.jb - wwb.ja - wwc.ja - wwd.ja + x - xi + y - eta
                                                    newWeight = rex.weight * xaRex.weight * xbRex.weight * xcRex.weight * xdRex.weight * xeRex.weight;    
                                                    testWeight = newWeight * (2*x + 1) * (2*y + 1)
                                                    newW3js    = W3j[];      newW6js    = W6j[];    
                                                    for (ifW3j, fW3j) in enumerate(rex.w3js)  
                                                        if  ifW3j != iaW3j &&  ifW3j != ibW3j &&  ifW3j != icW3j &&  ifW3j != idW3j &&  ifW3j != ieW3j   
                                                            push!(newW3js, eW3j)   end   
                                                    end
                                                    #
                                                    if  RacahAlgebra.hasAllVars([wwa.ma, wwb.ma, wwc.ma, wwd.ma, wwe.ma], rex.summations)   &&  
                                                        RacahAlgebra.hasNoVars([wwa.ma, wwb.ma, wwc.ma, wwd.ma, wwe.ma], testPhase)         &&  
                                                        RacahAlgebra.hasNoVars([wwa.ma, wwb.ma, wwc.ma, wwd.ma, wwe.ma], testWeight)        &&  
                                                        RacahAlgebra.hasNoVars([wwa.ma, wwb.ma, wwc.ma, wwd.ma, wwe.ma], rex.deltas)        &&  
                                                        RacahAlgebra.hasNoVars([wwa.ma, wwb.ma, wwc.ma, wwd.ma, wwe.ma], rex.triangles)     && 
                                                        RacahAlgebra.hasNoVars([wwa.ma, wwb.ma, wwc.ma, wwd.ma, wwe.ma], newW3js)           &&  
                                                        RacahAlgebra.hasNoVars([wwa.ma, wwb.ma, wwc.ma, wwd.ma, wwe.ma], rex.w6js)          &&  
                                                        RacahAlgebra.hasNoVars([wwa.ma, wwb.ma, wwc.ma, wwd.ma, wwe.ma], rex.w9js)
                                                        newSummations = RacahAlgebra.removeIndex([wwa.ma, wwb.ma, wwc.ma, wwd.ma, wwe.ma], rex.summations)
                                                        push!(newSummations, x);    push!(newSummations, xi);    push!(newSummations, y);    push!(newSummations, eta)
                                                        push!(newW3js,  W3j(wwa.jb, wwb.jb,      x, wwa.mb, wwb.mb, xi))
                                                        push!(newW3js,  W3j(     x, wwe.jb,      y,    -xi, wwe.mb, -eta))
                                                        push!(newW3js,  W3j(     y, wwc.jb, wwd.jb,    eta, wwc.mb, wwd.mb))
                                                        push!(newW6js,  W6j(wwa.jb, wwb.jb,      x, wwb.jc, wwa.ja, wwa.jc))
                                                        push!(newW6js,  W6j(     x, wwe.jb,      y, wwe.ja, wwb.jc, wwa.ja))
                                                        push!(newW6js,  W6j(     y, wwc.jb, wwd.jb, wwc.jc, wwd.jc, wwc.ja))
                                                        wa = RacahExpression( newSummations, testPhase, testWeight, rex.deltas, rex.triangles, newW3js, newW6js, rex.w9js )
                                                        println(">> Apply sum rule for five W3j -- Sum(m1,m2,m3,m4,m5) (-1)^-m1-m2-m3-m4-m5  ...")
                                                        return( (true, wa) )
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        
        return( (false, RacahExpression()) )
    end


    """
    `RacahAlgebra.sumRulesForSixW3j(rex::RacahAlgebra.RacahExpression)`  
        ... attempts to find a simplification of the given Racah expression by using sum rules for six Wigner 3j symbols. 
            Once a simplification is found, no attempt is made to find another simplifcation for this set of rules.
            A (istrue, rex)::Tuple{Bool, RacahExpression} is returned but where rex has no meaning for !istrue.
    """
    function sumRulesForSixW3j(rex::RacahAlgebra.RacahExpression)
        # Make sure that the sum rule could apply at all
        if  length(rex.summations) < 6  ||  length(rex.w3js) < 6     return( (false, RacahExpression()) )    end
        
        # Loop through all Wigner 3j symbols
        for  (ifW3j, fW3j) in enumerate(rex.w3js)
            fRexList = RacahAlgebra.symmetricForms(fW3j)
            for  xfRex in fRexList
                for  (ieW3j, eW3j) in enumerate(rex.w3js)
                    if  ieW3j == ifW3j    break    end
                    eRexList = RacahAlgebra.symmetricForms(eW3j)
                    for  xeRex in eRexList
                        for  (idW3j, dW3j) in enumerate(rex.w3js)
                            if  idW3j == ieW3j   ||   idW3j == ifW3j    break    end
                            dRexList = RacahAlgebra.symmetricForms(dW3j)
                            for  xdRex in dRexList
                                for  (icW3j, cW3j) in enumerate(rex.w3js)
                                    if  icW3j == idW3j   ||   icW3j == ieW3j   ||   icW3j == ifW3j    break    end
                                    cRexList = RacahAlgebra.symmetricForms(cW3j)
                                    for  xcRex in cRexList
                                        for  (ibW3j, bW3j) in enumerate(rex.w3js)
                                            if  ibW3j == icW3j   ||   ibW3j == idW3j   ||   ibW3j == ieW3j   ||   ibW3j == ifW3j    break    end
                                            bRexList = RacahAlgebra.symmetricForms(bW3j)
                                            for  xbRex in bRexList
                                                for  (iaW3j, aW3j) in enumerate(rex.w3js)
                                                    if  iaW3j == ibW3j  ||  iaW3j == icW3j  ||  iaW3j == idW3j  ||  iaW3j == ieW3j  ||  iaW3j == ifW3j   break    end
                                                    aRexList = RacahAlgebra.symmetricForms(aW3j)
                                                    for  xaRex in aRexList
                                                        wwa = xaRex.w3js[1];   wwb = xbRex.w3js[1];   wwc = xcRex.w3js[1];   
                                                        wwd = xdRex.w3js[1];   wwe = xeRex.w3js[1];   wwf = xfRex.w3js[1];
                #
                #   Rule: 
                #   ----                              -m1-m2-m3-m4-m5-m6  ( j1 j7  j2 ) ( j2 j8  j3 ) ( j3 j9  j4 ) ( j4 j10  j5 ) ( j5 j11  j6 ) ( j6 j12  j1 )
                #          Sum(m1,m2,m3,m4,m5,m6) (-1)                    (           ) (           ) (           ) (            ) (            ) (            )
                #                                                         ( m1 m7 -m2 ) ( m2 m8 -m3 ) ( m3 m9 -m4 ) ( m4 m10 -m5 ) ( m5 j11 -m6 ) ( m6 m12 -m1 )
                #
                #
                #                            -j1-j2-j3-j4-j5-j6                                x-xi+y-eta+z-zeta
                #                     =  (-1)                     * Sum(x,xi,y,eta,z,zeta) (-1)                    (2x + 1) (2y + 1) (2z + 1) 
                #
                #
                #              ( j7  x j8 ) ( j9  y  j10 ) ( j11   z  j12 ) (  x    y    z   )  ( j7  x j8 )   ( j9  y j10 )   ( j11  z j12 )   (  x  y  z )
                #            * (          ) (            ) (              ) (                ) {(          )} {(           )} {(            )} {(          )}
                #              ( m7 xi m8 ) ( m9 eta m10 ) ( m11 zeta m12 ) ( -xi -eta -zeta )  ( j3 j2 j1 )   ( j5 j4 j3  )   (  j1 j6  j5 )   ( j5 j1 j3 )
                #
                                                        specialaW3j = W3j(wwa.ja, wwa.jb, wwa.jc, wwa.ma, wwa.mb, -wwb.ma)
                                                        specialbW3j = W3j(wwa.jc, wwb.jb, wwb.jc, wwb.ma, wwb.mb, -wwc.ma)
                                                        specialcW3j = W3j(wwb.jc, wwc.jb, wwc.jc, wwc.ma, wwc.mb, -wwd.ma)
                                                        specialdW3j = W3j(wwc.jc, wwd.jb, wwd.jc, wwd.ma, wwd.mb, -wwe.ma)
                                                        specialeW3j = W3j(wwd.jc, wwe.jb, wwe.jc, wwe.ma, wwe.mb, -wwf.ma)
                                                        specialfW3j = W3j(wwe.jc, wwf.jb, wwa.ja, wwf.ma, wwf.mb, -wwa.ma)
                                                        if  wwa == specialaW3j   &&   wwb == specialbW3j   &&   wwc == specialcW3j   &&  
                                                            wwd == specialdW3j   &&   wwe == specialeW3j   &&   wwf == specialfW3j  
                                                            x = Basic(:x);  xi = Basic(:xi);  y = Basic(:y);  eta = Basic(:eta);  z = Basic(:z);  zeta = Basic(:zeta)
                                                            newPhase  = rex.phase + xaRex.phase + xbRex.phase + xcRex.phase + xdRex.phase + xeRex.phase + xfRex.phase
                                                            testPhase = newPhase + wwa.ma + wwb.ma + wwc.ma + wwd.ma + wwe.ma + wwf.ma - wwa.ja - wwb.ja - wwb.jc - wwd.ja 
                                                            testPhase = testPhase - wwd.jc - wwe.jc + x - xi + y - eta + z - zeta
                                                            newWeight = rex.weight * xaRex.weight * xbRex.weight * xcRex.weight * xdRex.weight * xeRex.weight * xfRex.weight  
                                                            testWeight = newWeight * (2*x + 1) * (2*y + 1) * (2*z + 1)
                                                            newW3js    = W3j[];      newW6js    = W6j[];    
                                                            for (igW3j, gW3j) in enumerate(rex.w3js)  
                                                                if  igW3j != iaW3j &&  igW3j != ibW3j &&  igW3j != icW3j &&  igW3j != idW3j &&  
                                                                    igW3j != ieW3j &&  igW3j != ifW3j    
                                                                    push!(newW3js, gW3j)   end   
                                                            end
                                                            #
                                                            if  RacahAlgebra.hasAllVars([wwa.ma, wwb.ma, wwc.ma, wwd.ma, wwe.ma, wwf.ma], rex.summations)   &&  
                                                                RacahAlgebra.hasNoVars([wwa.ma, wwb.ma, wwc.ma, wwd.ma, wwe.ma, wwf.ma], testPhase)         &&  
                                                                RacahAlgebra.hasNoVars([wwa.ma, wwb.ma, wwc.ma, wwd.ma, wwe.ma, wwf.ma], testWeight)        &&  
                                                                RacahAlgebra.hasNoVars([wwa.ma, wwb.ma, wwc.ma, wwd.ma, wwe.ma, wwf.ma], rex.deltas)        &&  
                                                                RacahAlgebra.hasNoVars([wwa.ma, wwb.ma, wwc.ma, wwd.ma, wwe.ma, wwf.ma], rex.triangles)     && 
                                                                RacahAlgebra.hasNoVars([wwa.ma, wwb.ma, wwc.ma, wwd.ma, wwe.ma, wwf.ma], newW3js)           &&  
                                                                RacahAlgebra.hasNoVars([wwa.ma, wwb.ma, wwc.ma, wwd.ma, wwe.ma, wwf.ma], rex.w6js)          &&  
                                                                RacahAlgebra.hasNoVars([wwa.ma, wwb.ma, wwc.ma, wwd.ma, wwe.ma, wwf.ma], rex.w9js)
                                                                newSummations = RacahAlgebra.removeIndex([wwa.ma, wwb.ma, wwc.ma, wwd.ma, wwe.ma, wwf.ma], rex.summations)
                                                                push!(newSummations, x);    push!(newSummations, xi);    push!(newSummations, y);    
                                                                push!(newSummations, eta);  push!(newSummations, z);     push!(newSummations, zeta)
                                                                push!(newW3js,  W3j(wwa.jb,      x, wwb.jb, wwa.mb,     xi, wwb.mb))
                                                                push!(newW3js,  W3j(wwc.jb,      y, wwd.jb, wwc.mb,    eta, wwd.mb))
                                                                push!(newW3js,  W3j(wwe.jb,      z, wwf.jb, wwe.mb,   zeta, wwf.mb))
                                                                push!(newW3js,  W3j(     x,      y,      z,    -xi,   -eta,  -zeta))
                                                                push!(newW6js,  W6j(wwa.jb,      x, wwb.jb, wwb.jc, wwa.jc, wwa.ja))
                                                                push!(newW6js,  W6j(wwc.jb,      y, wwd.jb, wwd.jc, wwd.ja, wwc.ja))
                                                                push!(newW6js,  W6j(wwe.jb,      z, wwf.jb, wwa.ja, wwe.jc, wwe.ja))
                                                                push!(newW6js,  W6j(      x,     y,      z, wwd.jc, wwa.ja, wwb.jc))
                                                                wa = RacahExpression( newSummations, testPhase, testWeight, 
                                                                                      rex.deltas, rex.triangles, newW3js, newW6js, rex.w9js )
                                                                println(">> Apply sum rule for six W3j -- Sum(m1,m2,m3,m4,m5,m6) (-1)^-m1-m2-m3-m4-m5-m6  ...")
                                                                return( (true, wa) )
                                                            end
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        
        return( (false, RacahExpression()) )
    end

    
#===================================================

Further sum rules that need to be implemented
                                 
Racah_usesumrulesfortwoYlm := proc(Rexpr::Racahexpr)

                  #  5.6.(1)
                  #  Rule:
                  #
                  #   Sum(l,m) (-1)^m  Y_(l,-m)(theta,phi)  Y_(l,m)(theta',phi')
                  #
                  #            =  diracdelta(cos(theta)-cos(theta'))  diracdelta(phi-phi')
                  #

                  #  5.10.(1)
                  #  Rule:
                  #
                  #   Sum(m)  (-1)^m  Y_(l,-m)(theta,phi)  Y_(l,m)(theta,phi)
                  #
                  #                   2 l + 1
                  #            =     ---------
                  #                     4 Pi
                  #

                  
                  #  5.10.(2)
                  #  Rule:
                  #
                  #   Sum(m)  (-1)^m   m   Y_(l,-m)(theta,phi)  Y_(l,m)(theta,phi)
                  #
                  #            =     0
                  #

                  
                  #  5.10.(3)
                  #  Rule:
                  #
                  #   Sum(m)  (-1)^m   m^2   Y_(l,-m)(theta,phi)  Y_(l,m)(theta,phi)
                  #
                  #                   l (l + 1) (2 l + 1)
                  #            =     --------------------  sin(theta)^2
                  #                          8 Pi
                  #


                                             
   
Racah_usesumrulesforfourw6j := proc(Rexpr::Racahexpr)
   
                                                         #
                                                         # Rule :
                                                         #
                                                         #                 R-X  ( a  b  X )   ( c  d  X )
                                                         #  Sum(X) [X] (-1)    {(         )} {(         )}
                                                         #                      ( c  d  p )   ( e  f  q )
                                                         #
                                                         #                      ( e  f  X )   ( g  h  X )
                                                         #                   x {(         )} {(         )}
                                                         #                      ( g  h  r )   ( b  a  s )
                                                         #
                                                         #                    2Y+a+b+e+f      ( s  h  b )
                                                         #      =  Sum(Y) (-1)           [Y] {( g  r  f )}
                                                         #                                    ( a  e  Y )
                                                         #
                                                         #                      ( b  f  Y )   ( a  e  Y )
                                                         #                   x {(         )} {(         )}
                                                         #                      ( q  p  c )   ( q  p  d )
                                                         #
                                                         #   where  R = a+b+c+d+e+f+g+h+p+q+r+s
                                                         #

                                                         
                                                         #
                                                         # Rule :
                                                         #
                                                         #               ( a  b  X )   ( c  d  X )
                                                         #  Sum(X) [X]  {(         )} {(         )}
                                                         #               ( c  d  p )   ( e  f  q )
                                                         #
                                                         #               ( e  f  X )   ( g  h  X )
                                                         #            x {(         )} {(         )}
                                                         #               ( g  h  r )   ( a  b  s )
                                                         #
                                                         #                        ( a  f  X )   ( a  f  X )
                                                         #            =  Sum(X)  {( d  q  e )} {( h  r  e )}
                                                         #                        ( p  c  b )   ( s  g  b )
                                                         #

                                                         
                                                                              #
                                                                              # Rule :
                                                                              #
                                                                              #                  X+Y+Z             ( a  b  c )   ( a  e  f )
                                                                              #  Sum(X,Y,Z)  (-1)        [X,Y,Z]  {(         )} {(         )}
                                                                              #                                    ( Z  X  Y )   ( p  X  Y )
                                                                              #
                                                                              #                                    ( c  f  d )   ( b  e  d )
                                                                              #                                 x {(         )} {(         )}
                                                                              #                                    ( p  Z  X )   ( p  Z  Y )
                                                                              #
                                                                              #
                                                                              #               -a-b-c-d-e-f-p       ( a  b  c )
                                                                              #        =  (-1)               [p]  {(         )}
                                                                              #                                    ( d  f  e )
                                                                              #

                                                                              
                                                                  #
                                                                  # Rule :
                                                                  #
                                                                  #                   ( a  b  c )   ( a  e  f )
                                                                  #  Sum(X,Y) [X,Y]  {(         )} {(         )}
                                                                  #                   ( d  X  Y )   ( g  X  Y )
                                                                  #
                                                                  #                   ( c  g  p )   ( b  g  q )
                                                                  #                x {(         )} {(         )}
                                                                  #                   ( f  d  X )   ( e  d  Y )
                                                                  #
                                                                  #           2(c+e)  ( a  b  c )   ( a  e  f )
                                                                  #     = (-1)       {(         )} {(         )}
                                                                  #                   ( g  p  q )   ( d  p  q )
                                                                  #

                                                                  
                                                                  #
                                                                  # Rule :
                                                                  #
                                                                  #                X+Y         ( a  b  c )   ( a  e  f )
                                                                  #  Sum(X,Y)  (-1)    [X,Y]  {(         )} {(         )}
                                                                  #                            ( d  X  Y )   ( g  X  Y )
                                                                  #
                                                                  #                            ( c  f  p )   ( b  e  q )
                                                                  #                         x {(         )} {(         )}
                                                                  #                            ( g  d  X )   ( g  d  Y )
                                                                  #
                                                                  #                   -a+b+c-d+e+f-g-p  d(p,q)             ( a  b  c )
                                                                  #            =  (-1)                  ------  d(d,g,p)  {(         )}
                                                                  #                                     2p + 1             ( p  f  e )
                                                                  #

                                                                  
Racah_usesumrulesforthreew6jonew9j := proc(Rexpr::Racahexpr)
        
                                                         #
                                                         # Rule :
                                                         #
                                                         #                        ( X  Y  Z )   ( X  Y  Z )
                                                         #  Sum(X,Y,Z)  [X,Y,Z]  {( d  e  f )} {(         )}
                                                         #                        ( a  b  c )   ( f  c  g )
                                                         #
                                                         #                        ( X  a  d )   ( Y  b  e )
                                                         #                     x {(         )} {(         )}
                                                         #                        ( b' g  c )   ( d' f  g )
                                                         #
                                                         #         2b+2d    d(b,b') d(d,d')
                                                         #  =  (-1)        -----------------   d(a,b,c) d(d,e,f) d(b,d,g)
                                                         #                 (2b + 1) (2d + 1)
                                                         #

                                                         
                                                         #
                                                         # Rule :
                                                         #
                                                         #                  2Z            ( a  b  X )   ( e  f  g )
                                                         #  Sum(X,Y,Z)  (-1)    [X,Y,Z]  {( c  d  Y )} {(         )}
                                                         #                                ( e' f' g )   ( X  Y  Z )
                                                         #
                                                         #                        ( a  b  X )   ( c  d  Y )
                                                         #                     x {(         )} {(         )}
                                                         #                        ( f  Z  d )   ( Z  e  a )
                                                         #
                                                         #        d(e,e') d(f,f')
                                                         #  =    -----------------   d(a,c,e) d(b,d,f) d(e,g,f)
                                                         #       (2e + 1) (2f + 1)
                                                         #
                                                         
        
                                                         #
                                                         # Rule :
                                                         #
                                                         #               Y        ( a  b  X )   ( X  Y  r )
                                                         #  Sum(X,Y) (-1)  [X,Y] {( c  d  Y )} {(         )}
                                                         #                        ( p  q  r )   ( j  h  g )
                                                         #
                                                         #                        ( a  b  X )   ( c  d  Y )
                                                         #                     x {(         )} {(         )}
                                                         #                        ( h  g  e )   ( j  g  f )
                                                         #
                                                         #         a-b+d+e-j-p+r  ( e  b  h )   ( a  c  p )
                                                         #  =  (-1)              {( f  d  j )} {(         )}
                                                         #                        ( p  q  r )   ( f  e  g )
                                                         #

                                                         
Racah_usesumrulesfortwow6jtwow9j := proc(Rexpr::Racahexpr)

                                                      #
                                                      # Rule :
                                                      #
                                                      #                 Z          ( a  d  X )   ( l  a  Z )
                                                      #  Sum(X,Y,Z) (-1)  [X,Y,Z] {( b  e  Y )} {( e  b  Y )}
                                                      #                            ( c' f  g )   ( j  c  h )
                                                      #
                                                      #                            ( a  d  X )   ( X  Y  g )
                                                      #                         x {(         )} {(         )}
                                                      #                            ( k  Z  l )   ( h  k  Z )
                                                      #
                                                      #                        2c+b-d+g+j  d(c,c')
                                                      #                  = (-1)            -------  d(a,b,c)
                                                      #                                      [c]
                                                      #
                                                      #                            ( k  j  f )   ( k  j  f )
                                                      #                         x {(         )} {(         )}
                                                      #                            ( c  g  h )   ( e  d  l )
                                                      #

                                                      
                                                      #
                                                      # Rule :
                                                      #
                                                      #                 2Y-Z          ( a  b  X )   ( g  h  X )
                                                      #  Sum(X,Y,Z) (-1)     [X,Y,Z] {( c  d  Y )} {( k  l  Y )}
                                                      #                               ( e  f  Z )   ( f  e  Z )
                                                      #
                                                      #                               ( a  b  X )   ( c  d  Y )
                                                      #                            x {(         )} {(         )}
                                                      #                               ( g  h  j )   ( k  l  j')
                                                      #
                                                      #           -b+c-h+k  d(j,j')   ( a  c  e )   ( b  d  f )
                                                      #     = (-1)          -------  {(         )} {(         )}
                                                      #                       [j]     ( l  h  j )   ( k  g  j )
                                                      #
                                                      

                                                      #
                                                      # Rule :
                                                      #
                                                      #                 Y          ( a  b  X )   ( b  d  f')
                                                      #  Sum(X,Y,Z) (-1)  [X,Y,Z] {( g  c  q )} {( c  h  j )}
                                                      #                            ( p  Z  Y )   ( Z  Y  p )
                                                      #
                                                      #                            ( a  b  X )   ( d  h  Y )
                                                      #                         x {(         )} {(         )}
                                                      #                            ( d  e  f )   ( q  X  e )
                                                      #
                                                      #                   2j+a+b+c+f+h+p-q  d(f,f')
                                                      #             = (-1)                 -------  d(b,d,f)
                                                      #                                       [f]
                                                      #
                                                      #                            ( e  g  j )   ( e  g  j )
                                                      #                         x {(         )} {(         )}
                                                      #                            ( p  f  a )   ( c  h  q )
                                                      #
                                                      
                                                         #
                                                         # Rule :
                                                         #
                                                         #               X+Y        ( a  b  X )   ( e  f  X )
                                                         #  Sum(X,Y) (-1)    [X,Y] {( c  d  Y )} {( g  h  Y )}
                                                         #                          ( p  q  s )   ( r  t  s )
                                                         #
                                                         #                          ( a  b  X )   ( c  d  Y )
                                                         #                       x {(         )} {(         )}
                                                         #                          ( f  e  k )   ( h  g  l )
                                                         #
                                                         #                k+l+a+c+p-s-h-t+Z       ( c  g  l )
                                                         #  =  Sum(Z) (-1)                   [Z] {( a  e  k )}
                                                         #                                        ( p  r  Z )
                                                         #
                                                         #                          ( f  b  k )   ( p  r  Z )
                                                         #                       x {( h  d  l )} {(         )}
                                                         #                          ( t  q  Z )   ( t  q  s )
                                                         #

                                                         
Racah_usesumrulesforonew6jthreew9j := proc(Rexpr::Racahexpr)

                                                            #
                                                            # Rule :
                                                            #
                                                            #                        ( a  b  X )   ( a  b  X )
                                                            #  Sum(X,Y,Z)  [X,Y,Z]  {( c  d  Y )} {( h  j  q )}
                                                            #                        ( t  s  r )   ( e  f  Z )
                                                            #
                                                            #                        ( k  l  p )   ( p  q  r )
                                                            #                     x {( c  d  Y )} {(         )}
                                                            #                        ( e  f  Z )   ( X  Y  Z )
                                                            #
                                                            #          ( k  l  p )   ( k  h  t )   ( l  j  s )
                                                            #     =   {( h  j  q )} {(         )} {(         )}
                                                            #          ( t  s  r )   ( a  c  e )   ( b  d  f )
                                                            #

                                                            
Racah_usesumrulesforfivew3jloop := proc(Rexpr::Racahexpr,w3jpos::list)

                                                            
Racah_usesumrulesforsixw3jloop := proc(Rexpr::Racahexpr,w3jpos::list)


====================================================#
