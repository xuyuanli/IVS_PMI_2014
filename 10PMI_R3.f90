!  10PMI_R3.f90
!
!  Free-Format Fortran Source File 
!  Generated by PGI Visual Fortran(R)
!  9/29/2014 4:06:41 PM

Module PMI10
use GLS
contains

!*******************************Sd of data*****************************
!Find sd
subroutine sd(a,n,sda)
implicit none
real(8),intent(in)::a(:)
integer(8),intent(in)::n
real(8),intent(out)::sda
real(8)::ave
integer(8)::i

ave=0.0
do i=1,n
   ave=ave+a(i)
end do
ave=ave/real(n)   

sda=0.0
do i=1,n
   sda=sda+(a(i)-ave)**2.0
end do
sda=dsqrt(sda/real(n-1.0))     

end subroutine  
!*******************************End sd of data******************************

!*********************************Var&Covar*********************************
!Var1D
subroutine var1d(x,n,var1) 
implicit none
real(8),intent(in)::x(:)
integer(8),intent(in)::n
real(8),intent(out)::var1
real(8)::sum1,sum2,meanx
integer(8)::i

   sum1=0.0
   do i=1,n
      sum1=sum1+x(i)
   end do
   meanx=sum1/real(n)  

   sum2=0.0
   do i=1,n
   sum2=sum2+(x(i)-meanx)**2.0
   end do
   
   var1=sum2/real(n-1.0)    
    
end subroutine
!*****************************End Var****************************************
!Cov2D
subroutine cov2d(x,y,n,var2) 
implicit none
real(8),intent(in)::x(:),y(:)
integer(8),intent(in)::n
real(8),intent(out)::var2
real(8)::sum1,sum2,xi,yi
real(8)::meanx,meany
integer(8)::i,c1

   sum1=0.0
   do i=1,n
      sum1=sum1+x(i)
   end do
   meanx=sum1/real(n)   

   sum1=0.0
   do i=1,n
      sum1=sum1+y(i)
   end do
   meany=sum1/real(n) 

   sum2=0.0
   do i=1,n
      sum2=sum2+(x(i)-meanx)*(y(i)-meany)
   end do
   
   var2=sum2/real(n-2.0)       
   
end subroutine
!*****************************End Cov**************************************

!Function factorial
integer(8) function fact(x)
implicit none
integer(8),intent(in)::x
integer(8)::i

fact=x
do i=1,(x-1)
   fact=fact*(x-i)
end do

end function
!*****************************End Fact**********************************
!Psi estimation with normal density (Wand& Jones 1995) pp.72
real(8) function psiNS(o,sd1)
implicit none
integer(8),intent(in)::o
real(8),intent(in)::sd1  !order, data standard deviation, Psi at given order

psiNS=((-1.0)**(o/2.0)*fact(o))/((2*sd1)**(o+1.0)*fact(o/2)*3.141592653**0.5)

end function
!*****************************End PsiNS*********************************
!Generl Psi estimation (Wand& Jones 1995) pp.67
!K(6),K(4) derived by XUYUAN LI
subroutine psi6(x,g,n1,psiv)
implicit none
real(8),intent(in)::x(:),g  !input, pilot bandwidth, general psi at given order
integer(8),intent(in)::n1
real(8),intent(out)::psiv   !general psi at given order
integer(8)::c1,c2
real(8)::sum1,sum2

sum1=0.0
sum2=0.0
do c1=1,n1
   do c2=1,n1
      sum1=(x(c1)-x(c2))**2.0/2.0/g**2.0   
      sum2=sum2+(-15.0*dexp(-sum1)/g**4.0+45.0*(x(c1)-x(c2))**2.0*dexp(-sum1)/g**6.0&    !K(6), checked
      -15.0*(x(c1)-x(c2))**4.0*dexp(-sum1)/g**8.0+(x(c1)-x(c2))**6.0*dexp(-sum1)/g**10.0)     
   end do
end do 
psiv=n1**(-2.0)*((2.0*3.141592653)**0.5*g**3.0)**(-1.0)*sum2   

end subroutine

subroutine psi4(x,g,n1,psiv)
implicit none
real(8),intent(in)::x(:),g  !input, pilot bandwidth, general psi at given order
integer(8),intent(in)::n1
real(8),intent(out)::psiv   !general psi at given order
integer(8)::c1,c2
real(8)::sum1,sum2

sum1=0.0
sum2=0.0
do c1=1,n1
   do c2=1,n1
      sum1=(x(c1)-x(c2))**2.0/2.0/g**2.0 
      sum2=sum2+(3.0*dexp(-sum1)/g**2.0-6.0*(x(c1)-x(c2))**2.0*dexp(-sum1)/g**4.0&       !K(4), checked
      +(x(c1)-x(c2))**4.0*dexp(-sum1)/g**6.0)            
   end do
end do
psiv=n1**(-2.0)*((2.0*3.141592653)**0.5*g**3.0)**(-1.0)*sum2   

end subroutine
!*****************************End general Psi****************************

!***********************************KDE_PDF 1D***************************
!Define effective input in AIC
subroutine KDE1D_AIC(x,n,d,h,wii)
implicit none
real(8),intent(in)::x(:),h
integer(8),intent(in)::n,d
real(8),intent(out)::wii
real(8)::sum1,sum2 !sum(K(.)),bandwidth,MPDF
integer(8)::i,j,c1 !Counter,size,dim

wii=0.0
do i=1,n
   sum2=0.0  
   do j=1,n
      sum1=(x(j)-x(i))**2.0
      sum1=sum1/2.0/(h**2.0)     
      sum2=sum2+exp(-sum1) 
    end do
    wii=wii+exp(0.0)/sum2         
end do  
  
end subroutine
!*********************************End KDE 1D******************************

!***********************************KDE_PDF 1D*****************************
!For MI
subroutine KDE1D(x,n,d,varx,sdv,fi,h)
implicit none

real(8),intent(in)::x(:),varx,sdv
integer(8),intent(in)::n,d
real(8),intent(out)::fi(:),h
real(8)::sum1,sum2 !sum(K(.)),bandwidth,MPDF
integer(8)::i,j,c1,c2 !Counter,size,dim
real(8)::g1,g2,epsi6,epsi4

!Based upon 2-stage Direct plug-in bandwidth estimator(Wand& Jones 1995) pp.72 assume L=K=N(0,1)
g1=(-2.0*(-15.0/(2.0*3.141592653)**0.5)/psiNS(8_8,sdv)/n)**(1.0/9.0)  !Pilot bandwidth for L at order 8
call psi6(x,g1,n,epsi6)    !Psi 6, K6(0)=-15/sqrt(2pi)
g2=(-2.0*(3.0/(2.0*3.141592653)**0.5)/epsi6/n)**(1.0/7.0)  !Pilot bandwidth for L at order 6
call psi4(x,g2,n,epsi4)    !Psi 4, K4(0)=3/sqrt(2pi)
h=(0.5/3.141592653**0.5/epsi4)**0.2*n**(-0.2)    !Selected bandwidth h_DPI,2=[R(K)/sdvK^4/psi4/n]**(1/5)    

if (h<0.00001) then            !Check bandwidth feasibility
    h=0.00001
    write(*,*)"warning:bandwidth is too small!"
end if 

do i=1,n
   sum2=0.0  
   do j=1,n
      sum1=(x(j)-x(i))**2.0
      sum1=sum1/2.0/(h**2.0)   
      sum2=sum2+exp(-sum1) 
    end do
    fi(i)=((2.0*3.141592653)**(d/2.0)*h**d*n)**(-1.0)*sum2      !varx  *dsqrt(abs(varx))  
end do  
 
end subroutine
!*********************************End KDE 1D******************************

!**********************************KDE_PDF 2D*****************************
subroutine KDE2D(x,y,n,d,varx,vary,varxy,hx,hy,fi)
implicit none
real(8),intent(in)::x(:),y(:),varx,vary,varxy,hx,hy
integer(8),intent(in)::n,d
real(8),intent(out)::fi(:)
real(8)::sum1,sum2,dets !sum(K(.)),bandwidth,MPDF,determinant
integer(8)::c1,i,j !Counter,size,dim
real(8)::IC(2,2),hxy

hxy=hx*hy       !Bandwidth with Gaussian Reference Rule

dets=(hx*hy)**2.0-(hxy*varxy/(varx*vary)**0.5)**2.0    !Inverse of H
IC(1,1)=hy**2.0/dets
IC(2,1)=-hxy*varxy/(varx*vary)**0.5/dets
IC(1,2)=-hxy*varxy/(varx*vary)**0.5/dets
IC(2,2)=hx**2.0/dets

do i=1,n
 sum2=0.0 
   do j=1,n
      sum1=(x(j)-x(i))*(x(j)-x(i))*IC(1,1)+(x(j)-x(i))*(y(j)-y(i))*(IC(2,1)+IC(1,2))&
      +(y(j)-y(i))*(y(j)-y(i))*IC(2,2)
      sum1=sum1/2.0
      sum2=sum2+exp(-sum1)
   end do
   fi(i)=(dsqrt(dabs(dets))*(2.0*3.141592653)**(d/2.0)*n)**(-1.0)*sum2 

end do   

end subroutine
!**********************************End KDE_PDF 2D***********************************

subroutine PA(xs,y,n,xg)!(inx,outy,nr,nc)
implicit none

real(8),intent(in)::xs(:),y(:)
integer(8),intent(in)::n
real(8),intent(out)::xg(:)
integer(8)::c1,c2,c3,c4    !counters
real(8)::num,den,aj,bw,sd,sum1,sum2,lg,ug,ag
real(8),allocatable::resx(:),resy(:)
real(8),allocatable::xord(:),xordp(:),xint(:),xintf(:),xpse(:) !ordering, interpolation, and pseudodata
integer(8)::k,k1,k2,k3

allocate(resx(n))
allocate(resy(n))
allocate(xordp(n+1))
allocate(xord(n+1))
allocate(xint(3*n+1))
allocate(xintf(3*n)) 
allocate(xpse(n))

!******************GRNN prediction (iterative 1-1 mapping)*****************

do c1=1,n
   resx(c1)=xs(c1)
end do


do c1=1,n
   resy(c1)=y(c1)
end do

! n iterative 1-1 mapping
 
   xordp(1)=0.0 
     
   do c1=1,n      
      xordp(c1+1)=resx(c1)
   end do 
    
    call dataord(xordp,(n+1),xord) !Ordering data
    call dataint(xord,(n+1),xint)  !Data Interpolation
    
    do c1=2,3*n+1      
       xintf(c1-1)=xint(c1)
    end do 
    
    call datapse(xintf,n,xpse)  !Data generation using 3-point rule

   !Estimate bandwidths (GRR)
   lg=minval(resx)+0.001
   ug=maxval(resx)
   ag=(lg+ug)/2.0
   
    call GSSSP(lg,ag,ug,resx,resy,n,bw) 
    
    k1=int(n*bw)
    k3=n
    k2=int((k1+k3)/2)
    
    call GSS_PAK(k1,k2,k3,resx,xpse,resy,n,bw,k)
    
   !For output
   do c1=1,n 
      num=0.0
      den=0.0   
      do c3=1,n 
         if (c3==c1) then
            num=num
            den=den
         else 
            if (c3<=k) then
               sum1=(resx(c3)-resx(c1))**2.0/2.0/bw**2.0
               sum2=(xpse(c3)-resx(c1))**2.0/2.0/bw**2.0
               aj=dexp(-sum1)+dexp(-sum2)
            else
               sum1=(resx(c3)-resx(c1))**2.0/2.0/bw**2.0
               aj=dexp(-sum1)
            end if
          
           num=num+resy(c3)*aj
           den=den+aj
         end if 
      end do
      
      if (dabs(den)<1.0*10.0**(-6.0)) then
         xg(c1)=num/10.0**(-6.0)     !warning: den=0.0
      else   
         xg(c1)=num/den !estimated output   
      end if   
   end do   
   
deallocate(resx)
deallocate(resy)
deallocate(xordp)
deallocate(xord)
deallocate(xint)
deallocate(xintf)
deallocate(xpse) 

end subroutine

!MI Estimation
subroutine KDE_MI(in,out,r,c,hbx,mi,ksi)
implicit none

real(8),intent(in)::in(:,:),out(:)
integer(8),intent(in)::r,c
real(8),intent(out)::hbx(:),mi(:),ksi(:)
real(8),allocatable::fx(:,:),fy(:),fxy(:,:),varx(:),varxy(:),sdx(:)
integer(8)::c1,c2,c3
real(8)::kbw,vary,sdy,hby
real(8)::ks                    !K-S value

allocate(fx(r,c))
allocate(fy(r))
allocate(fxy(r,c))
allocate(varx(c))
allocate(varxy(c))
allocate(sdx(c))

hbx=0.0
hby=0.0

!Find sdx,sdy
do c2=1,c
   if (in(1,c2)/=-9999.0) then
       call sd(in(1:r,c2),r,sdx(c2))
   end if    
end do
   call sd(out(1:r),r,sdy)
   
!Find varx, vary
do c2=1,c
   if (in(1,c2)/=-9999.0) then
      call var1d(in(1:r,c2),r,varx(c2)) 
   end if   
end do
   call var1d(out(1:r),r,vary)
   
!Find varxy
do c2=1,c
   if (in(1,c2)/=-9999.0) then
       call cov2d(in(1:r,c2),out(1:r),r,varxy(c2))
   end if    
end do  

!Kernel estimation of PDF
do c2=1,c
   if (in(1,c2)/=-9999.0) then
       call KDE1D(in(1:r,c2),r,1_8,varx(c2),sdx(c2),fx(1:r,c2),hbx(c2))
   end if    
end do
   call KDE1D(out(1:r),r,1_8,vary,sdy,fy(1:r),hby)
   
do c2=1,c
   if (in(1,c2)/=-9999.0) then
       call KDE2D(in(1:r,c2),out(1:r),r,2_8,varx(c2),vary,varxy(c2),hbx(c2),hby,fxy(1:r,c2))
   end if    
end do   

!Write out bandwidth & K-S
write(400,*)" No   K-S_D"!" No   h     K-S_D"
do c2=1,c
   if (in(1,c2)/=-9999.0) then
       call KS_value(in(1:r,c2),fx(1:r,c2),r,ks)
       ksi(c2)=ks
       write(400,'(I3,F7.3)')c2,ks!c2,hbx(c2),ks
   end if
end do
   call KS_value(out,fy,r,ks)            
   write(400,'(A3,F7.3,F7.3)')"OP",ks

!Estimate MI
do c2=1,c
   mi(c2)=0.0
end do

write(200,'(A3,A7)')"No","MI"
do c2=1,c
   if (in(1,c2)/=-9999.0) then
       do c1=1,r
          mi(c2)=mi(c2)+dlog(fxy(c1,c2)/fx(c1,c2)/fy(c1))
       end do
       mi(c2)= mi(c2)/real(r)    
   write(200,'(I3,F9.3)')c2,mi(c2) 
   end if
end do
 
deallocate(fx)
deallocate(fy)
deallocate(fxy)
deallocate(varx)
deallocate(varxy)
deallocate(sdx)

end subroutine
!*********************************End MI estimation******************************

!Estimation of PMI
subroutine PMIREPA(inx,outy,sn,ni)
implicit none

real(8),intent(inout)::inx(:,:),outy(:)
integer(8),intent(in)::sn,ni
real(8),allocatable::oinx(:,:)            !Use to keep original inputs for GRNN updating
real(8),allocatable::sinx(:),mii(:)       !Selected inputs, MI from each iteration
real(8),allocatable::gin(:),gout(:)       !Estimated input, output from GRNN
integer(8),allocatable::ord(:)            !Order
real(8),allocatable::pmi(:)               !PMI
integer(8)::c1,c2,c3                      !Counters
real(8)::maxmi                            !max(MI)
real(8)::sdx,varex                        !sd & var of the selected input during each iteration
real(8),allocatable::Z(:)                 !Hampel distance
real(8),allocatable::wnn(:)               !Effective inputs p in AIC
real(8),allocatable::err(:,:)             !Error term in AIC
real(8),allocatable::AIC1(:),AIC2(:)      !Error term in AIC
real(8),allocatable::eh(:)                !Bandwidth of inputs
integer(8)::c4,c5,c6,c7                   !****************
real(8),allocatable::ksf(:),ksr(:)        !****************
real(8)::minAIC,cea,ioada
real(8),allocatable::outyt(:),outye(:),rp(:)
real(8),allocatable::resp(:,:)

allocate(oinx(sn,ni)) 
allocate(sinx(sn))
allocate(mii(ni))
allocate(gin(sn))
allocate(gout(sn))
allocate(ord(ni))
allocate(pmi(ni))
allocate(Z(ni))
allocate(wnn(ni))
allocate(err(sn,ni))
allocate(AIC1(ni))
allocate(AIC2(ni))
allocate(eh(ni))
allocate(ksf(ni)) !*******************
allocate(ksr(ni)) !*******************
allocate(outyt(sn))
allocate(outye(sn))
allocate(rp(6))
allocate(resp(sn,ni))

ord=0
pmi=0.0
do c2=1,ni
   do c1=1,sn
     oinx(c1,c2)=inx(c1,c2)
   end do
end do

do c1=1,sn
   outyt(c1)=outy(c1)
end do

!PMI LOOP
do c2=1,ni
   sinx=0.0
   mii=0.0
   maxmi=-9999.0
   eh=0.0
   ksf=0.0     !***********
   
   write(200,*)
   write(200,'(A9,I2)')"Iteration",c2
   write(400,*)
   write(400,'(A9,I2)')"Iteration",c2
   !Update MI
   call KDE_MI(inx,outy,sn,ni,eh,mii,ksf)   
   
   if (c2==1) then    !***************
      do c7=1,ni
         ksr(c7)=ksf(c7)
      end do
   end if
      
   do c3=1,ni
      if (inx(1,c3)==-9999.0) then
          mii(c3)=-9999.0 
      end if
   end do
   
   !Define the max(MI)& selected input
   do c3=1,ni
      if (mii(c3)>maxmi) then
         maxmi=mii(c3)
         ord(c2)=c3
      else
         maxmi=maxmi
         ord(c2)=ord(c2)
      end if      
   end do
   
   !Update PMI
   pmi(c2)=maxmi
   
   !Update selected input
   do c1=1,sn
      sinx(c1)=inx(c1,ord(c2))   
      inx(c1,ord(c2))=-9999.0
   end do
   
   !Find p for AIC
   call KDE1D_AIC(sinx,sn,1_8,eh(ord(c2)),wnn(c2))
   
   
   !Update input via GRNN
   do c3=1,ni
      if (inx(1,c3)/=-9999.0) then
          call PA(sinx,inx(1:sn,c3),sn,gin)
          do c1=1,sn
             inx(c1,c3)=inx(c1,c3)-gin(c1)
          end do
          call scaling(inx(1:sn,c3),sn,inx(1:sn,c3))!>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> 
          !call sdf(inx(1:sn,c3),sn,inx(1:sn,c3)) 
      end if
   end do
   
   !Update output via GRNN 
   call PA(sinx,outy,sn,gout) 
   
   do c1=1,sn
      resp(c1,c2)=outy(c1)-gout(c1)    
      outy(c1)=outy(c1)-gout(c1)
   end do             
    
   
   !Record residuals during each iteration for AIC
   do c1=1,sn
      err(c1,c2)=outy(c1)
   end do 
 

end do


!Assess against the stopping critera 
do c3=2,ni
   wnn(c3)=wnn(c3)+wnn(c3-1)
end do

do c2=1,ni
   call AICe(wnn(c2),err(1:sn,c2),sn,c2,AIC1(c2))  !AIC
end do
  

write(200,*)
write(200,'(A7)')"Summary"
write(200,'(4A9)')"NO","ORD","PMI","AICp"
do c2=1,ni
   write(200,'(I9,I9,F9.2,F9.2)')c2, ord(c2),pmi(c2),AIC1(c2)
end do


write(200,'(A8)')"By AICp:"
minAIC=minval(AIC1)
do c2=1,ni
   if (AIC1(c2)==minAIC) then
       write(200,'(A7,I2,A24)')"Input (",ord(c2),") is the turnning point."
       c4=c2
   end if
end do  

do c1=1,sn
   gout(c1)=outyt(c1)-resp(c1,c4)
end do

   call CE(outyt,gout,sn,rp(1))
   call IoAd(outyt,gout,sn,rp(2))
   call PI(outyt,gout,sn,rp(3))
   call MCE(outyt,gout,sn,rp(4))
   call MIoAd(outyt,gout,sn,rp(5))
   call MPI(outyt,gout,sn,rp(6))
   
!"AICp","AICk","HD","ORD","PMI"
write(300,*)c4,(ord(c2),c2=1,ni),(pmi(c2),c2=1,ni) !Adjust ord & PMI format for each problem
!write(300,'(I3,X,21I3,X,21F6.3)')c4,(ord(c2),c2=1,ni)&
!,(pmi(c2),c2=1,ni) !Adjust ord & PMI format for each problem

deallocate(oinx) 
deallocate(sinx)
deallocate(mii)
deallocate(gin)
deallocate(gout)
deallocate(ord)
deallocate(pmi)
deallocate(Z)
deallocate(wnn)
deallocate(err)
deallocate(AIC1)
deallocate(AIC2)
deallocate(eh)
deallocate(ksf)  !****************
deallocate(ksr)  !****************
deallocate(outyt)
deallocate(outye)
deallocate(rp)
deallocate(resp)

end subroutine
!**********************************End PMI estimation**********************

!*********************************Stopping critera*************************>>>>>>>>>>>>>>>>>>>>>>>>>>Updated
!AIC(Concept based on May et al. 2008)
subroutine AICe(p,res,n1,n2,aicv)
implicit none
real(8),intent(in)::p,res(:)   !p, residual
integer(8),intent(in)::n1,n2
real(8),intent(out)::aicv      !AIC
real(8)::sum1
integer(8)::c7,c8

sum1=0.0
do c8=1,n1   
   sum1=sum1+res(c8)**2.0
end do
   sum1=n1*dlog(sum1/real(n1))
   
aicv=sum1+p*2.0

end subroutine

!AIC(Concept based on May et al. 2008)
subroutine AICp(k,res,n1,n2,aicv)
implicit none
real(8),intent(in)::res(:)   !p, residual
integer(8),intent(in)::k,n1,n2
real(8),intent(out)::aicv      !AIC
real(8)::sum1
integer(8)::c7,c8

sum1=0.0
do c8=1,n1   
   sum1=sum1+res(c8)**2.0
end do
   sum1=n1*dlog(sum1/real(n1))
   
aicv=sum1+(k+1.0)*2.0

end subroutine
!****************************End of AIC***********************************  

!Hampel Distance(Concept based on May et al. 2008)
subroutine hampel(n1,cpmi,Zj)
implicit none
real(8),intent(in)::cpmi(:)      !Estimated PMI
integer(8),intent(in)::n1        !no. of inputs
real(8),intent(out)::Zj(:)       !Hampel distance                
real(8),allocatable::dj(:)       !distance matrix
real(8),allocatable::dpmi(:)     !dummy PMI
real(8),allocatable::opmi(:)     !ordering PMI
integer(8)::c4,c5                !counter
real(8)::dpl,dpu                 !dummy p 
real(8)::mpmi,mdj                !median of PMI and distance
integer(8)::mp1,mp2              !median point
real(8),allocatable::ddj(:)      !dummy dj
real(8),allocatable::odj(:)      !ordering dj                 !Hampel distance

allocate(dj(n1))
allocate(ddj(n1))
allocate(odj(n1))
allocate(dpmi(n1))
allocate(opmi(n1))

!Define median of PMI
do c4=1,n1                       !Initialisation
   dpmi(c4)=cpmi(c4)
end do

dpu=maxval(cpmi)                 !set as maximum PMI
do c4=1,n1 
       dpl=minval(dpmi)          
       opmi(c4)=dpl                   !Find median of PMI
   do c5=1,n1
       if (dpmi(c5)==dpl) then
          dpmi(c5)=dpu
       end if       
   end do
end do

if (ceiling(real(n1)/2.0)==floor(real(n1)/2.0)) then !determine the median point
   mp1=floor(real(n1)/2.0)
   mp2=floor(real(n1)/2.0+1)
else
   mp1=ceiling(real(n1)/2.0)
   mp2=0
end if   
     
if (mp2==0) then
    mpmi=opmi(mp1)                        !even
else
    mpmi=(opmi(mp1)+opmi(mp2))/2.0        !odd
end if

do c4=1,n1
   dj(c4)=dabs(cpmi(c4)-mpmi)
end do

!Define hampel distance
do c4=1,n1                       !Initialisation
   ddj(c4)=dj(c4)
end do

dpu=maxval(dj)                  !set as maximum dj
do c4=1,n1                      !Find median of dj
       dpl=minval(ddj)          
       odj(c4)=dpl
   do c5=1,n1
       if (ddj(c5)==dpl) then
          ddj(c5)=dpu
       end if       
   end do
end do

if (mp2==0) then
    mdj=odj(mp1)                !even
else
    mdj=(odj(mp1)+odj(mp2))/2.0    !odd
end if

do c4=1,n1                 !work out Hampel distance
   Zj(c4)=dj(c4)/1.4826/mdj
end do

deallocate(dj)
deallocate(dpmi)
deallocate(opmi)
deallocate(ddj)
deallocate(odj)
end subroutine
!****************************End of Hampel*************************  
!****************************End stopping critera**************************

!Estimate K-S for input & output
subroutine KS_value(x1,x2,n,ksv) !records, kernel estimation of PDF, sample size,K-S value
implicit none
real(8),intent(in)::x1(:),x2(:)
integer(8),intent(in)::n
real(8),intent(out)::ksv        !kernel estimation of PDF, K-S value
real(8),allocatable::epdf(:,:),ecdf(:),kpdf(:,:),kcdf(:),test(:),d(:) !Estimated PDF,CDF; Kernel PDF,CDF; Test matrix; Difference
real(8)::lb,ub    !Upper, lower boundary, bandwidth
integer(8)::t,c1,c2,c3,c4,c5     !No. of segment, sample size, counter
real(8)::o1
real(8),allocatable::dkpdf(:,:)

allocate(epdf(n,2))

do c1=1,n         !Empirical PDF based upon uniform distribution
      epdf(c1,1)=x1(c1)
      epdf(c1,2)=real(1.0/n)       
end do
   
   lb=minval(x1)
   ub=maxval(x1)
   t=ceiling((ub-lb)/0.01+1)   !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>Changable stepsize
   
allocate(test(t))
allocate(ecdf(t))
allocate(kcdf(t))
allocate(d(t))
allocate(kpdf(n,2))
allocate(dkpdf(n,2))

do c2=1,t
   test(c2)=0.0
   ecdf(c2)=0.0
   kcdf(c2)=0.0
end do

test(1)=lb
do c2=2,t
   test(c2)=test(c2-1)+0.01   !>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>Changable stepsize
end do

!Empirical CDF
do c2=2,t
   do c1=1,n
      if(epdf(c1,1)<test(c2)) then
        ecdf(c2)=ecdf(c2)+epdf(c1,2)
      else  
        ecdf(c2)=ecdf(c2)
      end if  
   end do
end do

!Estimate Kernel PDF after ordering
do c1=1,n
   dkpdf(c1,1)=x1(c1)
   dkpdf(c1,2)=x2(c1)
end do

do c1=1,n  !Ordering
   o1=minval(dkpdf(1:n,1))
   do c3=1,n
      if (dkpdf(c3,1)==o1) then
          kpdf(c1,1)=x1(c3)
          kpdf(c1,2)=x2(c3)
          dkpdf(c3,1)=dabs(ub)*10.0
      end if
   end do 
end do

do c1=1,n
   dkpdf(c1,1)=kpdf(c1,1)
   dkpdf(c1,2)=kpdf(c1,2) 
end do

do c1=2,n
   kpdf(c1,2)=(dkpdf(c1,2)+dkpdf(c1-1,2))*dabs(dkpdf(c1,1)-dkpdf(c1-1,1))/2.0  
end do

kpdf(1,2)=0.0

do c2=2,t
   do c1=1,n
      if (kpdf(c1,1)<=test(c2)) then
          kcdf(c2)=kcdf(c2)+kpdf(c1,2)
      else
          kcdf(c2)=kcdf(c2)  
      end if
   end do  
end do

!Estimate K-S D
ksv=-9999.0
do c2=2,t
   d(c2)=max(dabs(ecdf(c2)-kcdf(c2)),dabs(ecdf(c2-1)-kcdf(c2)))     !sup of CDF difference
   
   if (d(c2)>ksv) then
      ksv=d(c2)
   else
      ksv=ksv
   end if       
end do

deallocate(epdf)   
deallocate(test)
deallocate(ecdf)
deallocate(kpdf)
deallocate(kcdf)
deallocate(dkpdf)
deallocate(d)

end subroutine
!*****************************************End of K-S value****************************

end module
