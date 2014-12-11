!  PSOmod.f90
!
!  Free-Format Fortran Source File 
!  Generated by PGI Visual Fortran(R)
!  3/28/2013 4:23:04 PM
!  Compiled by Dr. Aaron Zcchin

 
MODULE mod_PSO
!----------------------------------------------------------------------------------------
    TYPE type_particle
	  REAL(8),ALLOCATABLE,DIMENSION(:) :: xPB ! Personal best
	  REAL(8),POINTER,    DIMENSION(:) :: xNB ! Neighbourhood best
	  REAL(8),ALLOCATABLE,DIMENSION(:) :: x   ! Current position
	  REAL(8),ALLOCATABLE,DIMENSION(:) :: v   ! Current velocity
	  REAL(8):: fPB
	  REAL(8):: f
	  REAL(8),POINTER:: fNB
	  INTEGER(8),ALLOCATABLE,DIMENSION(:):: Neighbourhood ! Neighbourhood
    END TYPE type_particle
	TYPE type_PSO_swarm
      TYPE(type_particle),ALLOCATABLE,DIMENSION(:) :: particle
	  TYPE(type_particle),ALLOCATABLE,DIMENSION(:) :: GB
	  TYPE(type_particle)                          :: Opt
	  REAL(8),            ALLOCATABLE,DIMENSION(:) :: fGB, fmin, favg, fmax
	  REAL(8),            ALLOCATABLE,DIMENSION(:) :: Dmin, Davg, Dmax
	  REAL(8),            ALLOCATABLE,DIMENSION(:) :: Velmin, Velavg, Velmax
	  REAL(8),            ALLOCATABLE,DIMENSION(:) :: optDmin, optDavg, optDmax
	  CHARACTER(LEN=20) :: NeighbourhoodFlag
	  REAL(8) :: cNB, cPB, cInertia, cInertiaMax, cInertiaMin
	  REAL(8) :: vMax
	  REAL(8) :: perturbExp, perturbProb, perturbEe, perturbEs,&
	   perturbPL, perturbPU, perturbNI
	  INTEGER(8) :: NImax, Nx, Nparticle, NGB, Nelite
	END TYPE type_PSO_swarm

    REAL(8) :: realLarge = 1E16
    REAL(8) :: realSmall = 1E-16
    
    CONTAINS
!----------------------------------------------------------------------------------------
      SUBROUTINE read_PSO_swarm_from_file(unit_PSO,swarm)

	    IMPLICIT NONE
	    TYPE(type_PSO_swarm), INTENT(OUT) :: swarm
        INTEGER(8),INTENT(IN)  :: unit_PSO
! Global, vonNeumann, vonNeumannU
		READ(unit_PSO,*) swarm%NeighbourhoodFlag
		READ(unit_PSO,*) swarm%Nparticle
		READ(unit_PSO,*) swarm%Nelite
		READ(unit_PSO,*) swarm%NImax
		READ(unit_PSO,*) swarm%cNB
		READ(unit_PSO,*) swarm%cPB
		READ(unit_PSO,*) swarm%cInertiaMax
		READ(unit_PSO,*) swarm%cInertiaMin
		READ(unit_PSO,*) swarm%vMax
		READ(unit_PSO,*) swarm%perturbExp
		READ(unit_PSO,*) swarm%perturbProb
		READ(unit_PSO,*) swarm%perturbEs
		READ(unit_PSO,*) swarm%perturbEe
		READ(unit_PSO,*) swarm%perturbNI

      END SUBROUTINE read_PSO_swarm_from_file
!----------------------------------------------------------------------------------------
      SUBROUTINE initialise_PSO_swarm(swarm)

	    IMPLICIT NONE
	    TYPE(type_PSO_swarm),INTENT(INOUT):: swarm
        INTEGER(8) :: i
        REAL(8) :: X(swarm%Nx)

		ALLOCATE(swarm%particle(swarm%Nparticle))
		DO i = 1, swarm%Nparticle
		  ALLOCATE(swarm%particle(i)%xPB(swarm%Nx))
		  ALLOCATE(swarm%particle(i)%x(swarm%Nx))
		  ALLOCATE(swarm%particle(i)%v(swarm%Nx))
	    END DO
		DO i = 1, swarm%Nparticle
		  CALL RANDOM_NUMBER(X)
		  swarm%particle(i)%x   = X
          swarm%particle(i)%fPB = realLarge
          swarm%particle(i)%xPB = X
		  CALL RANDOM_NUMBER(X)
          swarm%particle(i)%v = swarm%vMax * (2.0_8 * X - 1.0_8)
		END DO
        swarm%NGB = 10
		ALLOCATE(swarm%GB(swarm%NGB))
		DO i = 1, swarm%NGB ; ALLOCATE(swarm%GB(i)%x(swarm%Nx)) ; END DO
		DO i = 1, swarm%NGB
		  CALL RANDOM_NUMBER(X) ; swarm%GB(i)%x = X ; swarm%GB(i)%f = realLarge
		END DO
		ALLOCATE(swarm%Opt%x(swarm%Nx))
		ALLOCATE(swarm%fGB(swarm%NImax),swarm%fmin(swarm%NImax),&
		swarm%favg(swarm%NImax),swarm%fmax(swarm%NImax))
		ALLOCATE(swarm%Dmin(swarm%NImax),swarm%Davg(swarm%NImax),swarm%Dmax(swarm%NImax))
		ALLOCATE(swarm%Velmin(swarm%NImax),swarm%Velavg(swarm%NImax),swarm%Velmax(swarm%NImax))
        ALLOCATE(swarm%OptDmin(swarm%NImax),swarm%OptDavg(swarm%NImax),swarm%OptDmax(swarm%NImax))
		swarm%perturbPL = swarm%perturbProb / 2.0_8
        swarm%perturbPU = swarm%perturbProb / 2.0_8
	    CALL initialise_PSO_swarm_neighbourhoods(swarm)

      END SUBROUTINE initialise_PSO_swarm
!----------------------------------------------------------------------------------------
      SUBROUTINE initialise_PSO_swarm_neighbourhoods(swarm)
           
        IMPLICIT NONE
	    TYPE(type_PSO_swarm),TARGET,INTENT(INOUT):: swarm
        INTEGER(8) :: i, j, ii, jj, r, c, count
        REAL(8) :: cR
        INTEGER(8),ALLOCATABLE :: indices(:,:), left(:), right(:), top(:), bottom(:)
        CHARACTER(LEN=100)  :: statement
        
        IF(swarm%NeighbourhoodFlag == 'Global')         THEN
          DO i = 1, swarm%Nparticle
            swarm%particle(i)%xNB => swarm%GB(1)%x
            swarm%particle(i)%fNB => swarm%GB(1)%f
          END DO
        ELSEIF(swarm%NeighbourhoodFlag =='vonNeumann'.OR.swarm%NeighbourhoodFlag=='vonNeumannU') THEN
! Determining dimensions of toroid graph
          r  = INT(SQRT(REAL(swarm%Nparticle)))
          cR = REAL(swarm%Nparticle) / REAL(r)
          DO WHILE(cR - REAL(INT(cR)) > realSmall .AND. r >= 2)
            r  = r - 1
            cR = REAL(swarm%Nparticle) / REAL(r)
          END DO
          IF (r == 1) THEN
            statement = 'Nparticle is prime, not suitable for toriodal grid generation'
!            CALL terminal_error_control(statement)
          END IF
          c = swarm%Nparticle / r ; ALLOCATE(indices(r,c)) ; count = 0
          DO i = 1, r ; DO j = 1, c
            count = count + 1 ; indices(i,j) = count
          END DO ; END DO  
          ALLOCATE(left(count),right(count),top(count),bottom(count)) ; count = 0
          DO i = 1, r ; DO j = 1, c
            count = count + 1
            IF(j == c) THEN ; jj = 1
            ELSE            ; jj = j + 1 ; END IF
            left(count) = indices(i,jj)
            IF(j == 1) THEN ; jj = c
            ELSE            ; jj = j - 1 ; END IF
            right(count) = indices(i,jj)
            IF(i == 1) THEN ; ii = r
            ELSE            ; ii = i - 1 ; END IF
            top(count) = indices(ii,j)
            IF(i == r) THEN ; ii = 1
            ELSE            ; ii = i + 1 ; END IF
            bottom(count) = indices(ii,j)  
          END DO ; END DO  
          IF(swarm%NeighbourhoodFlag == 'vonNeumann') THEN
            DO i = 1, swarm%Nparticle
              ALLOCATE(swarm%particle(i)%Neighbourhood(5))
              swarm%particle(i)%Neighbourhood(1) = i
              swarm%particle(i)%Neighbourhood(2) = left(i)
              swarm%particle(i)%Neighbourhood(3) = right(i)
              swarm%particle(i)%Neighbourhood(4) = top(i)
              swarm%particle(i)%Neighbourhood(5) = bottom(i)
            END DO
          ELSEIF(swarm%NeighbourhoodFlag == 'vonNeumannU') THEN
            DO i = 1, swarm%Nparticle
              ALLOCATE(swarm%particle(i)%Neighbourhood(4))
              swarm%particle(i)%Neighbourhood(1) = left(i)
              swarm%particle(i)%Neighbourhood(2) = right(i)
              swarm%particle(i)%Neighbourhood(3) = top(i)
              swarm%particle(i)%Neighbourhood(4) = bottom(i)
            END DO
          END IF
        END IF
      END SUBROUTINE initialise_PSO_swarm_neighbourhoods
!----------------------------------------------------------------------------------------
      SUBROUTINE re_initialise_PSO_swarm(swarm)

	    IMPLICIT NONE
	    TYPE(type_PSO_swarm),INTENT(INOUT) :: swarm
        INTEGER(8) :: i
        REAL(8) :: X(swarm%Nx)

		DO i = 1, swarm%Nparticle
		  CALL RANDOM_NUMBER(X)
		  swarm%particle(i)%x   = X
          swarm%particle(i)%fPB = realLarge
          swarm%particle(i)%xPB = X
		  CALL RANDOM_NUMBER(X)
          swarm%particle(i)%v = swarm%vMax * (2.0_8 * X - 1.0_8)
		END DO
		DO i = 1, swarm%NGB
		  CALL RANDOM_NUMBER(X) ; swarm%GB(i)%x = X ; swarm%GB(i)%f = realLarge
		END DO

      END SUBROUTINE re_initialise_PSO_swarm
!----------------------------------------------------------------------------------------
      SUBROUTINE re_initialise_PSO_swarm_particles(swarm)

	    IMPLICIT NONE
	    TYPE(type_PSO_swarm),INTENT(INOUT) :: swarm
        INTEGER(8) :: i
        REAL(8) :: X(swarm%Nx)

		DO i = 1, swarm%Nparticle
		  CALL RANDOM_NUMBER(X)
		  swarm%particle(i)%x   = X
          swarm%particle(i)%fPB = realLarge
          swarm%particle(i)%xPB = X
		  CALL RANDOM_NUMBER(X)
          swarm%particle(i)%v = swarm%vMax * (2.0_8 * X - 1.0_8)
		END DO

      END SUBROUTINE re_initialise_PSO_swarm_particles
!---------------------------------------------------------------------------------------- 
      SUBROUTINE update_PSO_swarm_bests(swarm)

! Updating Pbest and Gbest

	    IMPLICIT NONE
	    TYPE(type_PSO_swarm),INTENT(INOUT) :: swarm
        INTEGER(8) :: i, j, k

		DO i = 1, swarm%Nparticle
		  IF(swarm%particle(i)%f < swarm%particle(i)%fPB) THEN
		    swarm%particle(i)%fPB = swarm%particle(i)%f
		    swarm%particle(i)%xPB = swarm%particle(i)%x
		    j = 0 ; DO WHILE(swarm%particle(i)%f < swarm%GB(MAX(1,swarm%NGB-j))%f.AND.j<swarm%NGB);&
		     j = j + 1 ; END DO
		    IF(j>0) THEN 
		      DO k = swarm%NGB,swarm%NGB-j+2,-1 ; swarm%GB(k) = swarm%GB(k-1) ; END DO
		      swarm%GB(swarm%NGB-j+1)%f = swarm%particle(i)%f
		      swarm%GB(swarm%NGB-j+1)%x = swarm%particle(i)%x
			END IF
		  END IF
		END DO

      END SUBROUTINE update_PSO_swarm_bests
!----------------------------------------------------------------------------------------
      SUBROUTINE update_PSO_swarm_Pbests(swarm)

! Updating Pbest

	    IMPLICIT NONE
	    TYPE(type_PSO_swarm),INTENT(INOUT) :: swarm
        INTEGER(8) :: i

		DO i = 1, swarm%Nparticle
		  IF(swarm%particle(i)%f < swarm%particle(i)%fPB) THEN
		    swarm%particle(i)%fPB = swarm%particle(i)%f
		    swarm%particle(i)%xPB = swarm%particle(i)%x
		  END IF
		END DO

      END SUBROUTINE update_PSO_swarm_Pbests
!----------------------------------------------------------------------------------------
      SUBROUTINE update_PSO_swarm_parameters(swarm,t)

	    IMPLICIT NONE
	    TYPE(type_PSO_swarm),INTENT(INOUT) :: swarm
        INTEGER(8),             INTENT(IN)    :: t

        swarm%cInertia = swarm%cInertiaMax - (swarm%cInertiaMax - swarm%cInertiaMin)/&
        REAL(swarm%NImax)*REAL(t)

      END SUBROUTINE update_PSO_swarm_parameters
!----------------------------------------------------------------------------------------
      SUBROUTINE store_PSO_iteration_data(swarm,t)

	    IMPLICIT NONE
	    TYPE(type_PSO_swarm),INTENT(INOUT) :: swarm
        INTEGER(8),INTENT(IN)    :: t
		REAL(8) :: ABSv(swarm%Nx), optD
		REAL(8) :: fmin, favg, fmax, D, Dmin, Davg, Dmax, Vmin, Vavg, Vmax, optDmin, optDavg, optDmax
        INTEGER(8) :: i,j
		       
        fmin    =  10.0_8 ** 10.0_8 ; fmax    = -10.0_8 ** 10.0_8 ; favg    =   0.0_8
        Dmin    =  10.0_8 ** 10.0_8 ; Dmax    = -10.0_8 ** 10.0_8 ; Davg    =   0.0_8
		Vmin    =  10.0_8 ** 10.0_8 ; Vmax    = -10.0_8 ** 10.0_8 ; Vavg    =   0.0_8
		optDmin =  10.0_8 ** 10.0_8 ; optDmax = -10.0_8 ** 10.0_8 ; optDavg =   0.0_8
        DO i = 1, swarm%Nparticle
          favg = favg + swarm%particle(i)%f
          IF(swarm%particle(i)%f < fmin)      THEN ; fmin = swarm%particle(i)%f
		  ELSE IF(swarm%particle(i)%f > fmax) THEN ; fmax = swarm%particle(i)%f ; END IF
		  ABSv = ABS(swarm%particle(i)%v)
          Vavg = Vavg + SUM(ABSv)
          IF(MINVAL(ABSv) < Vmin)      THEN ; Vmin = MINVAL(ABSv)
		  ELSE IF(MAXVAL(ABSv) > Vmax) THEN ; Vmax = MAXVAL(ABSv) ; END IF
          DO j = i+1, swarm%Nparticle
		    D = SQRT(SUM((swarm%particle(i)%x-swarm%particle(j)%x)**2.0_8))
            Davg = Davg + D
            IF(D < Dmin)      THEN ; Dmin = D
		    ELSE IF(D > Dmax) THEN ; Dmax = D ; END IF
		  END DO
		  optD    = SQRT(SUM((swarm%particle(i)%x - swarm%Opt%x) ** 2.0_8))
          optDavg = optDavg + optD
          IF     (optD < optDmin) THEN ; optDmin = optD
		  ELSE IF(optD > optDmax) THEN ; optDmax = optD ; END IF
        END DO
        swarm%fGB(t)     = swarm%GB(1)%f
        swarm%fmin(t)    = fmin
        swarm%favg(t)    = favg / REAL(swarm%Nparticle)
        swarm%fmax(t)    = fmax
        swarm%Dmin(t)    = Dmin
        swarm%Davg(t)    = Davg / (REAL(swarm%Nparticle) * (REAL(swarm%Nparticle) - 1.0_8) / 2.0_8)
        swarm%Dmax(t)    = Dmax
		swarm%Velmin(t)  = Vmin
        swarm%Velavg(t)  = Vavg / REAL(swarm%Nparticle * swarm%Nx) 
        swarm%Velmax(t)  = Vmax
        swarm%optDmin(t) = optDmin
        swarm%optDavg(t) = optDavg / REAL(swarm%Nparticle) 
        swarm%optDmax(t) = optDmax

      END SUBROUTINE store_PSO_iteration_data
!----------------------------------------------------------------------------------------
      SUBROUTINE update_PSO_swarm_locations(swarm)

	    IMPLICIT NONE
	    TYPE(type_PSO_swarm),TARGET,INTENT(INOUT) :: swarm
        REAL(8) :: U_NB(swarm%Nx), U_PB(swarm%Nx), v(swarm%Nx), y(swarm%Nx), c(swarm%Nx), yy(swarm%Nx)
		INTEGER(8) :: i
        REAL(8) :: X

        CALL update_PSO_swarm_neighbourhoods(swarm)
        DO i = 1, swarm%Nparticle
		  CALL RANDOM_NUMBER(U_NB)
		  CALL RANDOM_NUMBER(U_PB)
		  v = swarm%cInertia   * swarm%particle(i)%v                             & ! Computing v
		      + swarm%cNB * U_NB * (swarm%particle(i)%xNB - swarm%particle(i)%x) & ! 
		      + swarm%cPB * U_PB * (swarm%particle(i)%xPB - swarm%particle(i)%x)   !
		  WHERE(ABS(v)>swarm%vMax) v = swarm%vMax * SIGN(1.0_8,v)                  ! bounding v
! Computing v
! c is the potential multiplier for the actual v (i.e. the v that keeps the search within the [0,1] hypercube
! First approach  (90%) is to stop particle at bound (if bound is exceeded)
! However if v is very small (i.e. MIN(c) < eps), the particle is reflected from the wall
!       for this approach yy is the reflected location within the hypercube
! Second approach ( 5%) is to reflect particle from wall if bound is reached 
! Third approach  ( 5%) is to project particle along bound if bound is reached
		  y = swarm%particle(i)%x+v
		  WHERE    (y > 1.0_8) 
		    c  = (1.0_8 - swarm%particle(i)%x) / MAX(ABS(v),realSmall)
		    yy = 1.0_8 - (y - INT(y))
		  ELSEWHERE(y < 0.0_8) 
		    c  = swarm%particle(i)%x / MAX(ABS(v),realSmall)
		    yy = - (y - INT(y))
		  ELSEWHERE            
		    c  = 1.0_8 
		    yy = y
		  END WHERE
		  CALL RANDOM_NUMBER(X)
		  IF(X<0.9) THEN                                                                 ! First approach
	        IF(MINVAL(c) > realSmall) THEN                                               ! 
	          swarm%particle(i)%v = MINVAL(c) * v                                        ! 
	        ELSE                                                                         ! 
		      swarm%particle(i)%v = (yy - swarm%particle(i)%x) * swarm%cInertia ** 2.0_8 ! 
		    END IF                                                                       ! 
          ELSEIF(X<0.95) THEN                                                            ! Second approach
            swarm%particle(i)%v   = yy - swarm%particle(i)%x                             ! 
          ELSE                                                                           ! Third approach
            swarm%particle(i)%v   =  c * v                                               ! 
          END IF                                                                         ! 
          swarm%particle(i)%x = swarm%particle(i)%x + swarm%particle(i)%v
! Making sure particle is in the bounds
		  WHERE    (swarm%particle(i)%x > 1.0_8) ; swarm%particle(i)%x = 1.0_8
		  ELSEWHERE(swarm%particle(i)%x < 0.0_8) ; swarm%particle(i)%x = 0.0_8 ; END WHERE
		END DO

      END SUBROUTINE update_PSO_swarm_locations
!----------------------------------------------------------------------------------------
      SUBROUTINE update_PSO_swarm_neighbourhoods(swarm)

! Determines the Neighbourhood best for each particle

	    IMPLICIT NONE
	    TYPE(type_PSO_swarm),TARGET,INTENT(INOUT) :: swarm
	    INTEGER(8) :: i, j
	    
	    IF(swarm%NeighbourhoodFlag /= 'Global') THEN
          DO i = 1, swarm%Nparticle 
            swarm%particle(i)%xNB => swarm%particle(swarm%particle(i)%Neighbourhood(1))%xPB
            swarm%particle(i)%fNB => swarm%particle(swarm%particle(i)%Neighbourhood(1))%fPB
            DO j = 2,SIZE(swarm%particle(i)%Neighbourhood)
              IF(swarm%particle(swarm%particle(i)%Neighbourhood(j))%fPB < swarm%particle(i)%fNB) THEN
                swarm%particle(i)%xNB => swarm%particle(swarm%particle(i)%Neighbourhood(j))%xPB
                swarm%particle(i)%fNB => swarm%particle(swarm%particle(i)%Neighbourhood(j))%fPB
              END IF
            END DO
          END DO
        END IF

      END SUBROUTINE update_PSO_swarm_neighbourhoods
!----------------------------------------------------------------------------------------
      SUBROUTINE perturb_PSO_swarm_locations(swarm,it,flag)

! Randomly perturbs the swarms locations
! (i)
! The perturbation acts in the negative direction with probability 'perturbPL' and is distributed as (non-scaled)
! - U^c
! where U is a uniform (0,1) random variable and c is a parameter (related to the expectation)
! (ii)
! The perturbation acts in the positive direction with probability 'perturbPU' and is distributed as (non-scaled)
! U^c
! where U is a uniform (0,1) random variable and c is a parameter (related to the expectation)
! (iii)
! No perturbation is performed with probability 
! 1 - (perturbPL + perturbPU)

	    IMPLICIT NONE
	    TYPE(type_PSO_swarm),INTENT(INOUT) :: swarm
	    INTEGER(8),INTENT(IN)    :: it
	    LOGICAL,DIMENSION(:),INTENT(OUT)   :: flag
        REAL(8) :: U(swarm%Nx), y(swarm%Nx)
		REAL(8) :: c, Et
		INTEGER(8) :: i

! Computing the current expected value of the perturbation
! Reduces from 'perturbEs' to 'perturbEe' at a rate of 
!  a ^ perturbExp
! where 'a' in (0,1) is the proportion of iterations 
        Et = swarm%perturbEe + (swarm%perturbEs - swarm%perturbEe) * (1.0_8 - REAL(it-swarm%perturbNI)/&
         REAL(swarm%NImax-swarm%perturbNI)) ** swarm%perturbExp
        c  = Et / (1 - Et)
! Performing the perturbations
        DO i = 1, swarm%Nparticle
		  CALL RANDOM_NUMBER(U)
		  WHERE(U <= swarm%perturbPL)                                                        ! (i)
		    y = -swarm%particle(i)%x*(1.0_8-(U/swarm%perturbPL)**c)                          !
		  ELSEWHERE(U <= swarm%perturbPL + swarm%perturbPU)                                  ! (ii)
            y = (1.0_8-swarm%particle(i)%x)*(1.0_8-((U-swarm%perturbPL)/swarm%perturbPU)**c) ! 
		  ELSEWHERE                                                                          ! (iii)
            y = 0.0_8                                                                        !
          END WHERE                                                                          !
          swarm%particle(i)%x = swarm%particle(i)%x + y
! Recording if particle is perturbed              
          IF(MINVAL(U)<= swarm%perturbPL + swarm%perturbPU) THEN ; flag(i) = .TRUE.
          ELSE                                                   ; flag(i) = .FALSE. ; END IF
		END DO

      END SUBROUTINE perturb_PSO_swarm_locations
!----------------------------------------------------------------------------------------
      SUBROUTINE print_PSO_swarm_iteration_statistics(swarm, unit_PSO)

        IMPLICIT NONE
	    TYPE(type_PSO_swarm),INTENT(IN):: swarm
	    INTEGER(8),INTENT(IN):: unit_PSO
        CHARACTER(LEN=100):: string
		INTEGER(8):: i,j

        !OPEN(UNIT = unit_PSO, FILE = "PSO_output.txt")
        string = '(1X,A10,1X,13(A25,1X))'
        WRITE(*,string) 'Iteration','Global','Minimum'!,'Average','Maximum','Minimum', 'Average',  'Maximum' ,'Minimum',   'Average',   'Maximum',   'Minimum',  'Average',  'Maximum'
        WRITE(*,string) 'Number',   'Best' ,'Cost'!,'Cost',   'Cost',   'Distance','Distance', 'Distance','|Velocity|','|Velocity|','|Velocity|','Opt-Dist', 'Opt-Dist', 'Opt-Dist'
        string = '(1X,I10,1X,13(F,1X))'
        DO i = 1, swarm%NImax
          WRITE(*,string) i,swarm%fGB(i),swarm%fmin(i)!,(swarm%GB(1)%x(j),j=1,swarm%Nx) !,,swarm%favg(i),swarm%fmax(i),swarm%Dmin(i),swarm%Davg(i),swarm%Dmax(i),swarm%Velmin(i),swarm%Velavg(i),swarm%Velmax(i),swarm%optDmin(i),swarm%optDavg(i),swarm%optDmax(i) 
		END DO
        !CLOSE(unit_PSO)

      END SUBROUTINE print_PSO_swarm_iteration_statistics
!----------------------------------------------------------------------------------------
      SUBROUTINE randomise_PSO_swarm_particles(swarm)
      
        IMPLICIT NONE
        TYPE(type_PSO_swarm), INTENT(INOUT) :: swarm
        REAL(8) :: X(swarm%Nx)
        INTEGER(8) :: i
        
        DO i = 1, swarm%Nparticle
          CALL RANDOM_NUMBER(X)
          swarm%particle(i)%x = X
          CALL RANDOM_NUMBER(X)
          swarm%particle(i)%v = swarm%vMax * (2.0_8 * X - 1.0_8)
        END DO
      
      END SUBROUTINE randomise_PSO_swarm_particles
!----------------------------------------------------------------------------------------
      SUBROUTINE randomise_PSO_swarm_Pbests_and_velocities(swarm)
      
        IMPLICIT NONE
        TYPE(type_PSO_swarm), INTENT(INOUT) :: swarm
        REAL(8) :: X(swarm%Nx)
        INTEGER(8) :: i
        
        DO i = 1, swarm%Nparticle
          CALL RANDOM_NUMBER(X)
          swarm%particle(i)%xPB = X
          swarm%particle(i)%fPB = realLarge
          CALL RANDOM_NUMBER(X)
          swarm%particle(i)%v = swarm%vMax * (2.0_8 * X - 1.0_8)
        END DO
      
      END SUBROUTINE randomise_PSO_swarm_Pbests_and_velocities
!----------------------------------------------------------------------------------------
      SUBROUTINE set_PSO_swarm_elitism(swarm) 

        IMPLICIT NONE
        TYPE(type_PSO_swarm), INTENT(INOUT) :: swarm
        INTEGER(8) :: list(swarm%NGB), i

        list = select_random_integers(MIN(swarm%Nelite,swarm%NGB),swarm%Nparticle)
        DO i = 1, MIN(swarm%Nelite,swarm%NGB)
          swarm%particle(list(i))%xPB = swarm%GB(i)%x  
          swarm%particle(list(i))%fPB = swarm%GB(i)%f
        END DO
        
      END SUBROUTINE set_PSO_swarm_elitism
!----------------------------------------------------------------------------------------
      FUNCTION select_random_integers(n,m) RESULT(y)
 
 ! Randomly selects (with out replacement) n integers from a list of 1 to m 
 
        IMPLICIT NONE
        INTEGER(8) :: n, m, y(n), x(m), i, j, k
        REAL(8) :: r
 
        DO k = 1, m ; x(k) = k ; END DO
        DO j = 1, n
          CALL RANDOM_NUMBER(r)
          i    = 1 + INT(r * REAL(m-j+1) - 0.5_8)
          y(j) = x(i)
          DO k = 1, i-1   ; x(k) = x(k) ; END DO
          DO k = i, m - j ; x(k) = x(k+1) ; END DO
        END DO

      END FUNCTION select_random_integers
!----------------------------------------------------------------------------------------



END MODULE mod_PSO