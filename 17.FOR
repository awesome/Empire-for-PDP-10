
!SUBROUTINE COLLECTION 17
 
        SUBROUTINE TROOPM(DUMMY)
        INCLUDE 'COMMON.EMP/NOLIST'
        DIMENSION OK(5)
        DATA OK/'.',' ','O','*','X'/
C  THIS SUBROUTINE HANDLES ENEMY TROOP TRANSPORT MOVES
 
        MONKEY=0
        NUMBER(5)=0
        IF(CODER==5.) TYPE 3198
 3198   FORMAT(' TROOP TRANSPORT CODES')
 
        DO 3200 Y=1,LIMIT(13)
        Z6=S(ITT2+Y)
        IF(Z6==0) GOTO 3200
        MONKEY=Y
        DIR=MOD(Y,2)*2-1                !SET DIR TO 1 OR -1 CONSISTENTLY
        AB=A(1,Z6)
        H1=H(ITT2H+Y)
        IF(AB=='X') H1=H1+1
        IF(H1>3)    H1=3
 
C  NOW COMPUTE THE NUMBER OF ARMIES ABOARD THE TROOP TRANSPORT
        NUMARM=0
        DO 6003 I=1,LIMIT(9)
 6003   IF(Z6==S(IAR2+I)) NUMARM=NUMARM+1
        IF(NUMARM>6) NUMARM=6           !6 IS MAX. # OF ARMIES ALLOWED
 
        DO 3195 ITURN=1,2
        P=0.0
        Z7=Z6
        AB=A(1,Z6)
        IF((ITURN==2).AND.(H1<=1)) GOTO 3200
C MOVE SELECTION
        IFO=IFORM(CODE(Y+ITT2-1500))
        ILA=ILATT(CODE(Y+ITT2-1500))
 
C  6000 IS THE STATEMENT # WHERE THE IFO AND ILA ARE
C  PROCESSED TO COME UP WITH A MOVE, WHICH IS THEN FED THRU MOVCOR
C  TO COME UP WITH A FINAL MOVE.
 
C  TAKE CARE OF DAMAGED SHIPS OR JUST REPAIRED SHIPS.
C  (DAMAGED SHIPS WILL HAVE AN IFO OF 8)
 
        IF(H1<3) GOTO 5998
        IF(IFO==8) IFO=0
        GOTO 6000
 5998   IFO=8
        IF((ILA==0).OR.(A(1,ILA)#'X')) ILA=IPORT(Z6)
        GOTO 3175
 
C  IFO=10: MOVE TOWARD UNEXPLORED TERRITORY, LOCATION SPECIFIED BY ILA
C  IFO=7: MOVE IN A CONSTANT DIRECTION SPECIFIED BY ILA
C  IFO=9: MOVE TOWARD AN UNOWNED CITY SPECIFIED BY ILA
C  IFO=0-6: ILA SPECIFIES LOCATION OF WHERE TO MOVE, EITHER
C       AN ARMY PRODUCING CITY OR AN ARMY LOOKING FOR A '5'.
C       IT COULD ALSO BE A DIRECTION. IFO IS THE # OF ARMIES ON
C       BOARD THE TROOP TRANSPORT.
 
 6000   IF(IFO<7) IFO=NUMARM
        IF(NUMARM==0) IFO=0
        IF((IFO==10).AND.(A(0,ILA)#' ')) GOTO 6020
        IF(IFO==10) GOTO 3175
        IF(IFO==7) GOTO 3173
        IF(IFO#9) GOTO 6300
 
C  IFO=9
        DO 6009 I=1,70
 6009   IF(TARGET(I)==ILA) GOTO 3175
        IF((IDIST(Z6,ILA)<10).AND.(EDGER(ILA)<8.)) GOTO 3175
C       IT SEEMS THAT IT'S TARGET IS NO LONGER ON THE HIT LIST,
C       MEANING IT WAS CAPTURED.
 
 6300   IF(IFO<=2) GOTO 6301
        IF(RAN(C1)<.2) GOTO 6020        !MOVE TOWARDS UNKNOWN TERRITORY
        GOTO 6011                       !SELECT A TARGET
 
C  SELECT AN ARMY PRODUCING CITY AND MOVE TOWARDS IT.
C  PICK THE CLOSEST ONE.
 6301   IF((ILA<=500).AND.(S(IAR2+ILA)#0)) GOTO 6002
        ID=500
        DO 6006 I=1,70
        IF((X(I)==0).OR.(OWNER(I)#2).OR.(PHASE(I)#1)) GOTO 6006
        IF(IDIST(Z6,X(I))>=ID) GOTO 6006
        I1=I
        ID=IDIST(Z6,X(I1))
        ILA=X(I1)
 6006   CONTINUE
        IF(ID#500) GOTO 3175
 
C  SELECT A RANDOM TARGET CITY
 6011   IFO=9
        IA=INT(RAN(C1)*20.+1.)
        IB=IA+70
        DO 6007 IC=IA,IB
        I=IC
        IF(I>70) I=I-70
        IF(TARGET(I)==0) GOTO 6007
        ILA=TARGET(I)
        IF(EDGER(ILA)==0.) GOTO 6007            !IF SURROUNDED BY LAND
        CALL DIST(Z6,ILA)
        GOTO 3175
 6007   CONTINUE
 
C  MOVE TOWARDS UNKNOWN TERRITORY
 6020   IFO=10
        ILA=EXPL(DUMMY)
        IF(ILA==0) GOTO 6010
        CALL DIST(Z6,ILA)
        GOTO 3175
 
C  MOVE IN SPECIFIED DIRECTION (ILA SPECIFIES WHICH)
 6010   IFO=7
        ILA=INT(RAN(C1)*8.+1.)
        GOTO 3173
 
C  NOW PICK A MOVE ACCORDING TO IFO AND ILA
 6002   MOVE=0
        IF(IDIST(Z6,S(IAR2+ILA))==1) GOTO 3176
        MOVE=MOV(Z6,S(IAR2+ILA))
        GOTO 3174
 3175   MOVE=PATH(Z6,ILA,DIR,OK,FLAG)
        IF(FLAG==0) GOTO 6010
        GOTO 3174
 3173   MOVE=ILA
 3174   AGGR=FLOAT(-NUMARM)
        IF((NUMBER(5)>10).AND.(NUMARM==0)) AGGR=AGGR+2.
        IF(IABS(MOVE)>8) TYPE 7777,IFO,ILA,MOVE,CODE(Y+ITT2-1500)
 7777   FORMAT(1X,4G)
        EXPLOR=0.
        IF(IFO>6) EXPLOR=1.
        MOVE=MOVE*DIR
        MOVE=MOVCOR(IFO,ITURN,Z6,MOVE,H1,1,AGGR,'5',EXPLOR,DIR)
        MOVE=IABS(MOVE)
        IF(IFO==7) ILA=MOVE
 3176   CODE(ITT2-1500+Y)=10000*IFO+ILA
        Z6=Z6+IARROW(MOVE)
        IB=CODE(ITT2-1500+Y)
        IF(CODER==5.) TYPE 3197, IB
 3197   FORMAT(1X,G)
 
        IF(D1(Z7)#'*') CALL CHANGE(Z7,D1(Z7),1)
        IF(A(1,Z6)=='.') GOTO 3201
        IF(A(1,Z6)=='X') GOTO 3202
        IF((A(1,Z6)=='+').OR.(D1(Z6)=='*')) GOTO 3203
        AB=A(1,Z6)
        TYPE 3297,AB
 3297   FORMAT(' ATTACKING ',A1)
        IF(AB=='.') GOTO 3201
        P=1.
        H2=30
        OWN1='5'
        OWN2=A(1,Z6)
        CALL FIND(OWN2,Z6,Z8,H2)
        CALL FGHT(Z6,H1,H2,OWN1,OWN2)
        CALL FIND(OWN2,Z6,Z8,H2)
        IF(H1<=0) GOTO 3203
        IF(D1(Z6)=='+') GOTO 3203
        CALL CHITS(ITT2H+Y,H1)
 3201 CALL CHANGE(Z6,'5',1)
 3202   CALL CHAS(ITT2+Y,Z6)
        IF(ITURN==1) NUMBER(5)=NUMBER(5)+1
        GOTO 3204
 3203   CALL CHAS(ITT2+Y,0)
        CALL CHITS(ITT2H+Y,0)
 3204   N=0
        IF(P==1.) CALL SENSOR(Z6)
        DO 3205 U=IAR2+1,IAR2+LIMIT(9)
        IF(S(U)#Z7) GOTO 3205
        N=N+1
        CALL CHAS(U,Z6)
        IF(N>H1*2) CALL CHAS(U,0)
        IF(NUMARM>2*H1) NUMARM=2*H1
 3205   CONTINUE
        CALL SONAR(Z6)
 3195   CONTINUE
 3200   CONTINUE
        LIMIT(13)=MONKEY
        RETURN
        END
 
        INTEGER FUNCTION EXPL
        INCLUDE 'COMMON.EMP/NOLIST'
        DATA STEP/37/,POSIT/65/,START/102/
 
C  THIS SUBROUTINE SEARCHES FOR UNKNOWN TERRITORY AND RETURNS A VALUE
C  IN EXPL.
 
        IF(FULL==2) GOTO 300
        BEGPOS=START
        GOTO 101
  100   IF((A(0,POSIT)==' ').AND.(ORDER(POSIT)==0)) GOTO 200
  101   POSIT=POSIT+STEP
        IF(POSIT<5900) GOTO 100
        START=START+1
        POSIT=START
        IF(START==BEGPOS+37) GOTO 300
        GOTO 100
  300   EXPL=0
        FULL=2
C       CALL CURSOR(0,KURSOR)
C       TYPE 103,POSIT,STEP,START,BEGPOS,KNOWN
  103   FORMAT('+POSIT,STEP,START,BEGPOS,KNOWN:',5I5$)
        RETURN
  200   EXPL=POSIT
        RETURN
        END
 
 


.