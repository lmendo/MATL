function y = hypergeom(a,b,z)
% Compute generalized hypergeometric function.
% If any entry of the numerator array is a negative integer: the sum is finite. It is computed
% directly for each entry of z, trying to avoid overflow in the products. 
% If not: call function genHyper for each entry of z, and make result real if all inputs are
if any( ~mod(a,1) & (a<=0) ) % sum is finite
    N = -max(a(~mod(a,1)));
    y = zeros(size(z)); % initiallize
    for k = 1:numel(z)
        for n = 0:N
            y(k) = y(k) + prod(prod(bsxfun(@plus, a, (0:n-1).'),2) ./ prod(bsxfun(@plus, b, (0:n-1).'),2) .* z(k) ./ (1:n).');
            % this order of operations to try to avoid overflow
        end
    end
else
    y = NaN(size(z)); % preallocate
    for k = 1:numel(z)
       y(k) = genHyper(a,b,z(k),0,0,12); % 12 significant digits, instead of the default 10. I choose
       % 12 and not 15 because the genHyper function says "If the user attempts to request more than
       % the number of bits in the mantissa allows, the program will abort with an appropriate error
       % message. The recommended value is 10."
    end
    if all(isreal(a)) && all(isreal(b)) && all(isreal(z))
        y = real(y);
    end
end
end

% The following is file `genHyper.m` from http://www.mathworks.com/matlabcentral/fileexchange/5616-generalized-hypergeometric-function
% except that 'end' statements have been added at the end of each function
function [pfq]=genHyper(a,b,z,lnpfq,ix,nsigfig);
% function [pfq]=genHyper(a,b,z,lnpfq,ix,nsigfig)
% Description : A numerical evaluator for the generalized hypergeometric
%               function for complex arguments with large magnitudes
%               using a direct summation of the Gauss series.
%               pFq isdefined by (borrowed from Maple):
%   pFq = sum(z^k / k! * product(pochhammer(n[i], k), i=1..p) /
%         product(pochhammer(d[j], k), j=1..q), k=0..infinity )
%
% INPUTS:       a => array containing numerator parameters
%               b => array containing denominator parameters
%               z => complex argument (scalar)
%           lnpfq => (optional) set to 1 if desired result is the natural
%                    log of pfq (default is 0)
%              ix => (optional) maximum number of terms in a,b (see below)
%         nsigfig => number of desired significant figures (default=10)
%
% OUPUT:      pfq => result
%
% EXAMPLES:     a=[1+i,1]; b=[2-i,3,3]; z=1.5;
%               >> genHyper(a,b,z)
%               ans =
%                          1.02992154295955 +     0.106416425916656i
%               or with more precision,
%               >> genHyper(a,b,z,0,0,15)
%               ans =
%                          1.02992154295896 +     0.106416425915575i
%               using the log option,
%               >> genHyper(a,b,z,1,0,15)
%               ans =
%                        0.0347923403326305 +     0.102959427435454i
%               >> exp(ans)
%               ans =
%                          1.02992154295896 +     0.106416425915575i
%
%
% Translated from the original fortran using f2matlab.m
%  by Ben E. Barrowes - barrowes@alum.mit.edu, 7/04.
%  

%% Original fortran documentation
%     ACPAPFQ.  A NUMERICAL EVALUATOR FOR THE GENERALIZED HYPERGEOMETRIC
%
%     1  SERIES.  W.F. PERGER, A. BHALLA, M. NARDIN.
%
%     REF. IN COMP. PHYS. COMMUN. 77 (1993) 249
%
%     ****************************************************************
%     *                                                              *
%     *    SOLUTION TO THE GENERALIZED HYPERGEOMETRIC FUNCTION       *
%     *                                                              *
%     *                           by                                 *
%     *                                                              *
%     *                      W. F. PERGER,                           *
%     *                                                              *
%     *              MARK NARDIN  and ATUL BHALLA                    *
%     *                                                              *
%     *                                                              *
%     *            Electrical Engineering Department                 *
%     *            Michigan Technological University                 *
%     *                  1400 Townsend Drive                         *
%     *                Houghton, MI  49931-1295   USA                *
%     *                     Copyright 1993                           *
%     *                                                              *
%     *               e-mail address: wfp@mtu.edu                    *
%     *                                                              *
%     *  Description : A numerical evaluator for the generalized     *
%     *    hypergeometric function for complex arguments with large  *
%     *    magnitudes using a direct summation of the Gauss series.  *
%     *    The method used allows an accuracy of up to thirteen      *
%     *    decimal places through the use of large integer arrays    *
%     *    and a single final division.                              *
%     *    (original subroutines for the confluent hypergeometric    *
%     *    written by Mark Nardin, 1989; modifications made to cal-  *
%     *    culate the generalized hypergeometric function were       *
%     *    written by W.F. Perger and A. Bhalla, June, 1990)         *
%     *                                                              *
%     *  The evaluation of the pFq series is accomplished by a func- *
%     *  ion call to PFQ, which is a double precision complex func-  *
%     *  tion.  The required input is:                               *
%     *  1. Double precision complex arrays A and B.  These are the  *
%     *     arrays containing the parameters in the numerator and de-*
%     *     nominator, respectively.                                 *
%     *  2. Integers IP and IQ.  These integers indicate the number  *
%     *     of numerator and denominator terms, respectively (these  *
%     *     are p and q in the pFq function).                        *
%     *  3. Double precision complex argument Z.                     *
%     *  4. Integer LNPFQ.  This integer should be set to '1' if the *
%     *     result from PFQ is to be returned as the natural logaritm*
%     *     of the series, or '0' if not.  The user can generally set*
%     *     LNPFQ = '0' and change it if required.                   *
%     *  5. Integer IX.  This integer should be set to '0' if the    *
%     *     user desires the program PFQ to estimate the number of   *
%     *     array terms (in A and B) to be used, or an integer       *
%     *     greater than zero specifying the number of integer pos-  *
%     *     itions to be used.  This input parameter is escpecially  *
%     *     useful as a means to check the results of a given run.   *
%     *     Specificially, if the user obtains a result for a given  *
%     *     set of parameters, then changes IX and re-runs the eval- *
%     *     uator, and if the number of array positions was insuffi- *
%     *     cient, then the two results will likely differ.  The rec-*
%     *     commended would be to generally set IX = '0' and then set*
%     *     it to 100 or so for a second run.  Note that the LENGTH  *
%     *     parameter currently sets the upper limit on IX to 777,   *
%     *     but that can easily be changed (it is a single PARAMETER *
%     *     statement) and the program recompiled.                   *
%     *  6. Integer NSIGFIG.  This integer specifies the requested   *
%     *     number of significant figures in the final result.  If   *
%     *     the user attempts to request more than the number of bits*
%     *     in the mantissa allows, the program will abort with an   *
%     *     appropriate error message.  The recommended value is 10. *
%     *                                                              *
%     *     Note: The variable NOUT is the file to which error mess- *
%     *           ages are written (default is 6).  This can be      *
%     *           changed in the FUNCTION PFQ to accomodate re-      *
%     *           of output to another file                          *
%     *                                                              *
%     *  Subprograms called: HYPER.                                  *
%     *                                                              *
%     ****************************************************************
%
%
%
%

if nargin<6
 nsigfig=10;
elseif isempty(nsigfig)
 nsigfig=10;
end
if nargin<5
 ix=0;
elseif isempty(ix)
 ix=0;
end
if nargin<4
 lnpfq=0;
elseif isempty(lnpfq)
 lnpfq=0;
end
ip=length(a);
iq=length(b);

global  zero   half   one   two   ten   eps;
[zero , half , one , two , ten , eps]=deal(0.0d0,0.5d0,1.0d0,2.0d0,10.0d0,1.0d-10);
global  nout;
%
%
%
%
a1=zeros(2,1);b1=zeros(1,1);gam1=0;gam2=0;gam3=0;gam4=0;gam5=0;gam6=0;gam7=0;hyper1=0;hyper2=0;z1=0;
argi=0;argr=0;diff=0;dnum=0;precis=0;
%
%
i=0;
%
%
%
nout=6;
if ((lnpfq~=0) & (lnpfq~=1)) ;
 ' error in input arguments: lnpfq ~= 0 or 1',
 error('stop encountered in original fortran code');
end;
if ((ip>iq) & (abs(z)>one)) ;
 ip , iq , abs(z),
 %format [,1x,'ip=',1i2,3x,'iq=',1i2,3x,'and abs(z)=',1e12.5,2x,./,' which is greater than one--series does',' not converge');
 error('stop encountered in original fortran code');
end;
if (ip==2 & iq==1 & abs(z)>0.9) ;
 if (lnpfq~=1) ;
  %
  %      Check to see if the Gamma function arguments are o.k.; if not,
  %
  %      then the series will have to be used.
  %
  %
  %
  %      PRECIS - MACHINE PRECISION
  %
  %
  precis=one;
  precis=precis./two;
  dnum=precis+one;
  while (dnum>one);
   precis=precis./two;
   dnum=precis+one;
  end;
  precis=two.*precis;
  for i=1 : 6;
   if (i==1) ;
    argi=imag(b(1));
    argr=real(b(1));
   elseif (i==2);
    argi=imag(b(1)-a(1)-a(2));
    argr=real(b(1)-a(1)-a(2));
   elseif (i==3);
    argi=imag(b(1)-a(1));
    argr=real(b(1)-a(1));
   elseif (i==4);
    argi=imag(a(1)+a(2)-b(1));
    argr=real(a(1)+a(2)-b(1));
   elseif (i==5);
    argi=imag(a(1));
    argr=real(a(1));
   elseif (i==6);
    argi=imag(a(2));
    argr=real(a(2));
   end;
   %
   %       CASES WHERE THE ARGUMENT IS REAL
   %
   %
   if (argi==0.0) ;
    %
    %        CASES WHERE THE ARGUMENT IS REAL AND NEGATIVE
    %
    %
    if (argr<=0.0) ;
     %
     %         USE THE SERIES EXPANSION IF THE ARGUMENT IS TOO NEAR A POLE
     %
     %
     diff=abs(real(round(argr))-argr);
     if (diff<=two.*precis) ;
      pfq=hyper(a,b,ip,iq,z,lnpfq,ix,nsigfig);
      return;
     end;
    end;
   end;
  end;
  gam1=cgamma(b(1),lnpfq);
  gam2=cgamma(b(1)-a(1)-a(2),lnpfq);
  gam3=cgamma(b(1)-a(1),lnpfq);
  gam4=cgamma(b(1)-a(2),lnpfq);
  gam5=cgamma(a(1)+a(2)-b(1),lnpfq);
  gam6=cgamma(a(1),lnpfq);
  gam7=cgamma(a(2),lnpfq);
  a1(1)=a(1);
  a1(2)=a(2);
  b1(1)=a(1)+a(2)-b(1)+one;
  z1=one-z;
  hyper1=hyper(a1,b1,ip,iq,z1,lnpfq,ix,nsigfig);
  a1(1)=b(1)-a(1);
  a1(2)=b(1)-a(2);
  b1(1)=b(1)-a(1)-a(2)+one;
  hyper2=hyper(a1,b1,ip,iq,z1,lnpfq,ix,nsigfig);
  pfq=gam1.*gam2.*hyper1./(gam3.*gam4)+(one-z).^(b(1)-a(1)-a(2)).*gam1.*gam5.*hyper2./(gam6.*gam7);
  return;
 end;
end;
pfq=hyper(a,b,ip,iq,z,lnpfq,ix,nsigfig);
return;
end

%     ****************************************************************
%     *                                                              *
%     *                   FUNCTION BITS                              *
%     *                                                              *
%     *                                                              *
%     *  Description : Determines the number of significant figures  *
%     *    of machine precision to arrive at the size of the array   *
%     *    the numbers must be stored in to get the accuracy of the  *
%     *    solution.                                                 *
%     *                                                              *
%     *  Subprograms called: none                                    *
%     *                                                              *
%     ****************************************************************
%
function [bits]=bits;
%
bit2=0;
%
%
%
bit=1.0;
nnz=0;
nnz=nnz+1;
bit2=bit.*2.0;
bit=bit2+1.0;
while ((bit-bit2)~=0.0);
 nnz=nnz+1;
 bit2=bit.*2.0;
 bit=bit2+1.0;
end;
bits=nnz-3;
end


%     ****************************************************************
%     *                                                              *
%     *                   FUNCTION HYPER                             *
%     *                                                              *
%     *                                                              *
%     *  Description : Function that sums the Gauss series.          *
%     *                                                              *
%     *  Subprograms called: ARMULT, ARYDIV, BITS, CMPADD, CMPMUL,   *
%     *                      IPREMAX.                                *
%     *                                                              *
%     ****************************************************************
%
function [hyper]=hyper(a,b,ip,iq,z,lnpfq,ix,nsigfig);
%
%
% PARAMETER definitions
%
sumr=[];sumi=[];denomr=[];denomi=[];final=[];l=[];rmax=[];ibit=[];temp=[];cr=[];i1=[];ci=[];qr1=[];qi1=[];wk1=[];wk2=[];wk3=[];wk4=[];wk5=[];wk6=[];cr2=[];ci2=[];qr2=[];qi2=[];foo1=[];cnt=[];foo2=[];sigfig=[];numr=[];numi=[];ar=[];ai=[];ar2=[];ai2=[];xr=[];xi=[];xr2=[];xi2=[];bar1=[];bar2=[];
length=0;
length=777;
%
%
global  zero   half   one   two   ten   eps;
global  nout;
%
%
%
%
accy=0;ai=zeros(10,1);ai2=zeros(10,1);ar=zeros(10,1);ar2=zeros(10,1);ci=zeros(10,1);ci2=zeros(10,1);cnt=0;cr=zeros(10,1);cr2=zeros(10,1);creal=0;denomi=zeros(length+2,1);denomr=zeros(length+2,1);dum1=0;dum2=0;expon=0;log2=0;mx1=0;mx2=0;numi=zeros(length+2,1);numr=zeros(length+2,1);qi1=zeros(length+2,1);qi2=zeros(length+2,1);qr1=zeros(length+2,1);qr2=zeros(length+2,1);ri10=0;rmax=0;rr10=0;sigfig=0;sumi=zeros(length+2,1);sumr=zeros(length+2,1);wk1=zeros(length+2,1);wk2=zeros(length+2,1);wk3=zeros(length+2,1);wk4=zeros(length+2,1);wk5=zeros(length+2,1);wk6=zeros(length+2,1);x=0;xi=0;xi2=0;xl=0;xr=0;xr2=0;
%
cdum1=0;cdum2=0;final=0;oldtemp=0;temp=0;temp1=0;
%
%
%
i=0;i1=0;ibit=0;icount=0;ii10=0;ir10=0;ixcnt=0;l=0;lmax=0;nmach=0;rexp=0;
%
%
%
goon1=0;
foo1=zeros(length+2,1);foo2=zeros(length+2,1);bar1=zeros(length+2,1);bar2=zeros(length+2,1);
%
%
zero=0.0d0;
log2=log10(two);
ibit=fix(bits);
rmax=two.^(fix(ibit./2));
sigfig=two.^(fix(ibit./4));
%
for i1=1 : ip;
 ar2(i1)=real(a(i1)).*sigfig;
 ar(i1)=fix(ar2(i1));
 ar2(i1)=round((ar2(i1)-ar(i1)).*rmax);
 ai2(i1)=imag(a(i1)).*sigfig;
 ai(i1)=fix(ai2(i1));
 ai2(i1)=round((ai2(i1)-ai(i1)).*rmax);
end;
for i1=1 : iq;
 cr2(i1)=real(b(i1)).*sigfig;
 cr(i1)=fix(cr2(i1));
 cr2(i1)=round((cr2(i1)-cr(i1)).*rmax);
 ci2(i1)=imag(b(i1)).*sigfig;
 ci(i1)=fix(ci2(i1));
 ci2(i1)=round((ci2(i1)-ci(i1)).*rmax);
end;
xr2=real(z).*sigfig;
xr=fix(xr2);
xr2=round((xr2-xr).*rmax);
xi2=imag(z).*sigfig;
xi=fix(xi2);
xi2=round((xi2-xi).*rmax);
%
%     WARN THE USER THAT THE INPUT VALUE WAS SO CLOSE TO ZERO THAT IT
%     WAS SET EQUAL TO ZERO.
%
for i1=1 : ip;
 if ((real(a(i1))~=0.0) & (ar(i1)==0.0) & (ar2(i1)==0.0));
  i1,
 end;
 %format (1x,'warning - real part of a(',1i2,') was set to zero');
 if ((imag(a(i1))~=0.0) & (ai(i1)==0.0) & (ai2(i1)==0.0));
  i1,
 end;
 %format (1x,'warning - imag part of a(',1i2,') was set to zero');
end;
for i1=1 : iq;
 if ((real(b(i1))~=0.0) & (cr(i1)==0.0) & (cr2(i1)==0.0));
  i1,
 end;
 %format (1x,'warning - real part of b(',1i2,') was set to zero');
 if ((imag(b(i1))~=0.0) & (ci(i1)==0.0) & (ci2(i1)==0.0));
  i1,
 end;
 %format (1x,'warning - imag part of b(',1i2,') was set to zero');
end;
if ((real(z)~=0.0) & (xr==0.0) & (xr2==0.0)) ;
 ' warning - real part of z was set to zero',
 z=complex(0.0,imag(z));
end;
if ((imag(z)~=0.0) & (xi==0.0) & (xi2==0.0)) ;
 ' warning - imag part of z was set to zero',
 z=complex(real(z),0.0);
end;
%
%
%     SCREENING OF NUMERATOR ARGUMENTS FOR NEGATIVE INTEGERS OR ZERO.
%     ICOUNT WILL FORCE THE SERIES TO TERMINATE CORRECTLY.
%
nmach=fix(log10(two.^fix(bits)));
icount=-1;
for i1=1 : ip;
 if ((ar2(i1)==0.0) & (ar(i1)==0.0) & (ai2(i1)==0.0) &(ai(i1)==0.0)) ;
  hyper=complex(one,0.0);
  return;
 end;
 if ((ai(i1)==0.0) & (ai2(i1)==0.0) & (real(a(i1))<0.0));
  if (abs(real(a(i1))-real(round(real(a(i1)))))<ten.^(-nmach)) ;
   if (icount~=-1) ;
    icount=min([icount,-round(real(a(i1)))]);
   else;
    icount=-round(real(a(i1)));
   end;
  end;
 end;
end;
%
%     SCREENING OF DENOMINATOR ARGUMENTS FOR ZEROES OR NEGATIVE INTEGERS
%     .
%
for i1=1 : iq;
 if ((cr(i1)==0.0) & (cr2(i1)==0.0) & (ci(i1)==0.0) &(ci2(i1)==0.0)) ;
  i1,
  %format (1x,'error - argument b(',1i2,') was equal to zero');
  error('stop encountered in original fortran code');
 end;
 if ((ci(i1)==0.0) & (ci2(i1)==0.0) & (real(b(i1))<0.0));
  if ((abs(real(b(i1))-real(round(real(b(i1)))))<ten.^(-nmach)) &(icount>=-round(real(b(i1))) | icount==-1)) ;
   i1,
   %format (1x,'error - argument b(',1i2,') was a negative',' integer');
   error('stop encountered in original fortran code');
  end;
 end;
end;
%
nmach=fix(log10(two.^ibit));
nsigfig=min([nsigfig,fix(log10(two.^ibit))]);
accy=ten.^(-nsigfig);
l=ipremax(a,b,ip,iq,z);
if (l~=1) ;
 %
 %     First, estimate the exponent of the maximum term in the pFq series
 %     .
 %
 expon=0.0;
 xl=real(l);
 for i=1 : ip;
  expon=expon+real(factor(a(i)+xl-one))-real(factor(a(i)-one));
 end;
 for i=1 : iq;
  expon=expon-real(factor(b(i)+xl-one))+real(factor(b(i)-one));
 end;
 expon=expon+xl.*real(log(z))-real(factor(complex(xl,0.0)));
 lmax=fix(log10(exp(one)).*expon);
 l=lmax;
 %
 %     Now, estimate the exponent of where the pFq series will terminate.
 %
 temp1=complex(one,0.0);
 creal=one;
 for i1=1 : ip;
  temp1=temp1.*complex(ar(i1),ai(i1))./sigfig;
 end;
 for i1=1 : iq;
  temp1=temp1./(complex(cr(i1),ci(i1))./sigfig);
  creal=creal.*cr(i1);
 end;
 temp1=temp1.*complex(xr,xi);
 %
 %     Triple it to make sure.
 %
 l=3.*l;
 %
 %     Divide the number of significant figures necessary by the number
 %     of
 %     digits available per array position.
 %
 %
 l=fix((2.*l+nsigfig)./nmach)+2;
end;
%
%     Make sure there are at least 5 array positions used.
%
l=max([l,5]);
l=max([l,ix]);
%     write (6,*) ' Estimated value of L=',L
if ((l<0) | (l>length)) ;
 length,
 %format (1x,['error in fn hyper: l must be < '],1i4);
 error('stop encountered in original fortran code');
end;
if (nsigfig>nmach) ;
 nmach,
 %format (1x,' warning--the number of significant figures requ','ested',./,'is greater than the machine precision--','final answer',./,'will be accurate to only',i3,' digits');
end;
%
sumr(-1+2)=one;
sumi(-1+2)=one;
numr(-1+2)=one;
numi(-1+2)=one;
denomr(-1+2)=one;
denomi(-1+2)=one;
for i=0 : l+1;
 sumr(i+2)=0.0;
 sumi(i+2)=0.0;
 numr(i+2)=0.0;
 numi(i+2)=0.0;
 denomr(i+2)=0.0;
 denomi(i+2)=0.0;
end;
sumr(1+2)=one;
numr(1+2)=one;
denomr(1+2)=one;
cnt=sigfig;
temp=complex(0.0,0.0);
oldtemp=temp;
ixcnt=0;
rexp=fix(ibit./2);
x=rexp.*(sumr(l+1+2)-2);
rr10=x.*log2;
ir10=fix(rr10);
rr10=rr10-ir10;
x=rexp.*(sumi(l+1+2)-2);
ri10=x.*log2;
ii10=fix(ri10);
ri10=ri10-ii10;
dum1=(abs(sumr(1+2).*rmax.*rmax+sumr(2+2).*rmax+sumr(3+2)).*sign(sumr(-1+2)));
dum2=(abs(sumi(1+2).*rmax.*rmax+sumi(2+2).*rmax+sumi(3+2)).*sign(sumi(-1+2)));
dum1=dum1.*10.^rr10;
dum2=dum2.*10.^ri10;
cdum1=complex(dum1,dum2);
x=rexp.*(denomr(l+1+2)-2);
rr10=x.*log2;
ir10=fix(rr10);
rr10=rr10-ir10;
x=rexp.*(denomi(l+1+2)-2);
ri10=x.*log2;
ii10=fix(ri10);
ri10=ri10-ii10;
dum1=(abs(denomr(1+2).*rmax.*rmax+denomr(2+2).*rmax+denomr(3+2)).*sign(denomr(-1+2)));
dum2=(abs(denomi(1+2).*rmax.*rmax+denomi(2+2).*rmax+denomi(3+2)).*sign(denomi(-1+2)));
dum1=dum1.*10.^rr10;
dum2=dum2.*10.^ri10;
cdum2=complex(dum1,dum2);
temp=cdum1./cdum2;
%
%     130 IF (IP .GT. 0) THEN
goon1=1;
while (goon1==1);
 goon1=0;
 if (ip<0) ;
  if (sumr(1+2)<half) ;
   mx1=sumi(l+1+2);
  elseif (sumi(1+2)<half);
   mx1=sumr(l+1+2);
  else;
   mx1=max([sumr(l+1+2),sumi(l+1+2)]);
  end;
  if (numr(1+2)<half) ;
   mx2=numi(l+1+2);
  elseif (numi(1+2)<half);
   mx2=numr(l+1+2);
  else;
   mx2=max([numr(l+1+2),numi(l+1+2)]);
  end;
  if (mx1-mx2>2.0) ;
   if (creal>=0.0) ;
    %        write (6,*) ' cdabs(temp1/cnt)=',cdabs(temp1/cnt)
    %
    if (abs(temp1./cnt)<=one) ;
     [sumr,sumi,denomr,denomi,final,l,lnpfq,rmax,ibit]=arydiv(sumr,sumi,denomr,denomi,final,l,lnpfq,rmax,ibit);
     hyper=final;
     return;
    end;
   end;
  end;
 else;
  [sumr,sumi,denomr,denomi,temp,l,lnpfq,rmax,ibit]=arydiv(sumr,sumi,denomr,denomi,temp,l,lnpfq,rmax,ibit);
  %
  %      First, estimate the exponent of the maximum term in the pFq
  %      series.
  %
  expon=0.0;
  xl=real(ixcnt);
  for i=1 : ip;
   expon=expon+real(factor(a(i)+xl-one))-real(factor(a(i)-one));
  end;
  for i=1 : iq;
   expon=expon-real(factor(b(i)+xl-one))+real(factor(b(i)-one));
  end;
  expon=expon+xl.*real(log(z))-real(factor(complex(xl,0.0)));
  lmax=fix(log10(exp(one)).*expon);
  if (abs(oldtemp-temp)<abs(temp.*accy)) ;
   [sumr,sumi,denomr,denomi,final,l,lnpfq,rmax,ibit]=arydiv(sumr,sumi,denomr,denomi,final,l,lnpfq,rmax,ibit);
   hyper=final;
   return;
  end;
  oldtemp=temp;
 end;
 if (ixcnt~=icount) ;
  ixcnt=ixcnt+1;
  for i1=1 : iq;
   %
   %      TAKE THE CURRENT SUM AND MULTIPLY BY THE DENOMINATOR OF THE NEXT
   %
   %      TERM, FOR BOTH THE MOST SIGNIFICANT HALF (CR,CI) AND THE LEAST
   %
   %      SIGNIFICANT HALF (CR2,CI2).
   %
   %
   [sumr,sumi,cr(i1),ci(i1),qr1,qi1,wk1,wk2,wk3,wk4,wk5,wk6,l,rmax]=cmpmul(sumr,sumi,cr(i1),ci(i1),qr1,qi1,wk1,wk2,wk3,wk4,wk5,wk6,l,rmax);
   [sumr,sumi,cr2(i1),ci2(i1),qr2,qi2,wk1,wk2,wk3,wk4,wk5,wk6,l,rmax]=cmpmul(sumr,sumi,cr2(i1),ci2(i1),qr2,qi2,wk1,wk2,wk3,wk4,wk5,wk6,l,rmax);
   qr2(l+1+2)=qr2(l+1+2)-1;
   qi2(l+1+2)=qi2(l+1+2)-1;
   %
   %      STORE THIS TEMPORARILY IN THE SUM ARRAYS.
   %
   %
   [qr1,qi1,qr2,qi2,sumr,sumi,wk1,l,rmax]=cmpadd(qr1,qi1,qr2,qi2,sumr,sumi,wk1,l,rmax);
  end;
  %
  %
  %     MULTIPLY BY THE FACTORIAL TERM.
  %
  foo1=sumr;
  foo2=sumr;
  [foo1,cnt,foo2,wk6,l,rmax]=armult(foo1,cnt,foo2,wk6,l,rmax);
  sumr=foo2;
  foo1=sumi;
  foo2=sumi;
  [foo1,cnt,foo2,wk6,l,rmax]=armult(foo1,cnt,foo2,wk6,l,rmax);
  sumi=foo2;
  %
  %     MULTIPLY BY THE SCALING FACTOR, SIGFIG, TO KEEP THE SCALE CORRECT.
  %
  for i1=1 : ip-iq;
   foo1=sumr;
   foo2=sumr;
   [foo1,sigfig,foo2,wk6,l,rmax]=armult(foo1,sigfig,foo2,wk6,l,rmax);
   sumr=foo2;
   foo1=sumi;
   foo2=sumi;
   [foo1,sigfig,foo2,wk6,l,rmax]=armult(foo1,sigfig,foo2,wk6,l,rmax);
   sumi=foo2;
  end;
  for i1=1 : iq;
   %
   %      UPDATE THE DENOMINATOR.
   %
   %
   [denomr,denomi,cr(i1),ci(i1),qr1,qi1,wk1,wk2,wk3,wk4,wk5,wk6,l,rmax]=cmpmul(denomr,denomi,cr(i1),ci(i1),qr1,qi1,wk1,wk2,wk3,wk4,wk5,wk6,l,rmax);
   [denomr,denomi,cr2(i1),ci2(i1),qr2,qi2,wk1,wk2,wk3,wk4,wk5,wk6,l,rmax]=cmpmul(denomr,denomi,cr2(i1),ci2(i1),qr2,qi2,wk1,wk2,wk3,wk4,wk5,wk6,l,rmax);
   qr2(l+1+2)=qr2(l+1+2)-1;
   qi2(l+1+2)=qi2(l+1+2)-1;
   [qr1,qi1,qr2,qi2,denomr,denomi,wk1,l,rmax]=cmpadd(qr1,qi1,qr2,qi2,denomr,denomi,wk1,l,rmax);
  end;
  %
  %
  %     MULTIPLY BY THE FACTORIAL TERM.
  %
  foo1=denomr;
  foo2=denomr;
  [foo1,cnt,foo2,wk6,l,rmax]=armult(foo1,cnt,foo2,wk6,l,rmax);
  denomr=foo2;
  foo1=denomi;
  foo2=denomi;
  [foo1,cnt,foo2,wk6,l,rmax]=armult(foo1,cnt,foo2,wk6,l,rmax);
  denomi=foo2;
  %
  %     MULTIPLY BY THE SCALING FACTOR, SIGFIG, TO KEEP THE SCALE CORRECT.
  %
  for i1=1 : ip-iq;
   foo1=denomr;
   foo2=denomr;
   [foo1,sigfig,foo2,wk6,l,rmax]=armult(foo1,sigfig,foo2,wk6,l,rmax);
   denomr=foo2;
   foo1=denomi;
   foo2=denomi;
   [foo1,sigfig,foo2,wk6,l,rmax]=armult(foo1,sigfig,foo2,wk6,l,rmax);
   denomi=foo2;
  end;
  %
  %     FORM THE NEXT NUMERATOR TERM BY MULTIPLYING THE CURRENT
  %     NUMERATOR TERM (AN ARRAY) WITH THE A ARGUMENT (A SCALAR).
  %
  for i1=1 : ip;
   [numr,numi,ar(i1),ai(i1),qr1,qi1,wk1,wk2,wk3,wk4,wk5,wk6,l,rmax]=cmpmul(numr,numi,ar(i1),ai(i1),qr1,qi1,wk1,wk2,wk3,wk4,wk5,wk6,l,rmax);
   [numr,numi,ar2(i1),ai2(i1),qr2,qi2,wk1,wk2,wk3,wk4,wk5,wk6,l,rmax]=cmpmul(numr,numi,ar2(i1),ai2(i1),qr2,qi2,wk1,wk2,wk3,wk4,wk5,wk6,l,rmax);
   qr2(l+1+2)=qr2(l+1+2)-1;
   qi2(l+1+2)=qi2(l+1+2)-1;
   [qr1,qi1,qr2,qi2,numr,numi,wk1,l,rmax]=cmpadd(qr1,qi1,qr2,qi2,numr,numi,wk1,l,rmax);
  end;
  %
  %     FINISH THE NEW NUMERATOR TERM BY MULTIPLYING BY THE Z ARGUMENT.
  %
  [numr,numi,xr,xi,qr1,qi1,wk1,wk2,wk3,wk4,wk5,wk6,l,rmax]=cmpmul(numr,numi,xr,xi,qr1,qi1,wk1,wk2,wk3,wk4,wk5,wk6,l,rmax);
  [numr,numi,xr2,xi2,qr2,qi2,wk1,wk2,wk3,wk4,wk5,wk6,l,rmax]=cmpmul(numr,numi,xr2,xi2,qr2,qi2,wk1,wk2,wk3,wk4,wk5,wk6,l,rmax);
  qr2(l+1+2)=qr2(l+1+2)-1;
  qi2(l+1+2)=qi2(l+1+2)-1;
  [qr1,qi1,qr2,qi2,numr,numi,wk1,l,rmax]=cmpadd(qr1,qi1,qr2,qi2,numr,numi,wk1,l,rmax);
  %
  %     MULTIPLY BY THE SCALING FACTOR, SIGFIG, TO KEEP THE SCALE CORRECT.
  %
  for i1=1 : iq-ip;
   foo1=numr;
   foo2=numr;
   [foo1,sigfig,foo2,wk6,l,rmax]=armult(foo1,sigfig,foo2,wk6,l,rmax);
   numr=foo2;
   foo1=numi;
   foo2=numi;
   [foo1,sigfig,foo2,wk6,l,rmax]=armult(foo1,sigfig,foo2,wk6,l,rmax);
   numi=foo2;
  end;
  %
  %     FINALLY, ADD THE NEW NUMERATOR TERM WITH THE CURRENT RUNNING
  %     SUM OF THE NUMERATOR AND STORE THE NEW RUNNING SUM IN SUMR, SUMI.
  %
  foo1=sumr;
  foo2=sumr;
  bar1=sumi;
  bar2=sumi;
  [foo1,bar1,numr,numi,foo2,bar2,wk1,l,rmax]=cmpadd(foo1,bar1,numr,numi,foo2,bar2,wk1,l,rmax);
  sumi=bar2;
  sumr=foo2;

  %
  %     BECAUSE SIGFIG REPRESENTS "ONE" ON THE NEW SCALE, ADD SIGFIG
  %     TO THE CURRENT COUNT AND, CONSEQUENTLY, TO THE IP ARGUMENTS
  %     IN THE NUMERATOR AND THE IQ ARGUMENTS IN THE DENOMINATOR.
  %
  cnt=cnt+sigfig;
  for i1=1 : ip;
   ar(i1)=ar(i1)+sigfig;
  end;
  for i1=1 : iq;
   cr(i1)=cr(i1)+sigfig;
  end;
  goon1=1;
 end;
end;
[sumr,sumi,denomr,denomi,final,l,lnpfq,rmax,ibit]=arydiv(sumr,sumi,denomr,denomi,final,l,lnpfq,rmax,ibit);
%     write (6,*) 'Number of terms=',ixcnt
hyper=final;
return;
end

%
%     ****************************************************************
%     *                                                              *
%     *                 SUBROUTINE ARADD                             *
%     *                                                              *
%     *                                                              *
%     *  Description : Accepts two arrays of numbers and returns     *
%     *    the sum of the array.  Each array is holding the value    *
%     *    of one number in the series.  The parameter L is the      *
%     *    size of the array representing the number and RMAX is     *
%     *    the actual number of digits needed to give the numbers    *
%     *    the desired accuracy.                                     *
%     *                                                              *
%     *  Subprograms called: none                                    *
%     *                                                              *
%     ****************************************************************
%
function [a,b,c,z,l,rmax]=aradd(a,b,c,z,l,rmax);
%
%
global  zero   half   one   two   ten   eps;
%
%
%
ediff=0;i=0;j=0;
%
%
for i=0 : l+1;
 z(i+2)=0.0;
end;
ediff=round(a(l+1+2)-b(l+1+2));
if (abs(a(1+2))<half | ediff<=-l) ;
 for i=-1 : l+1;
  c(i+2)=b(i+2);
 end;
 if (c(1+2)<half) ;
  c(-1+2)=one;
  c(l+1+2)=0.0;
 end;
 return;
else;
 if (abs(b(1+2))<half | ediff>=l) ;
  for i=-1 : l+1;
   c(i+2)=a(i+2);
  end;
  if (c(1+2)<half) ;
   c(-1+2)=one;
   c(l+1+2)=0.0;
  end;
  return;
 else;
  z(-1+2)=a(-1+2);
  goon300=1;
  goon190=1;
  if (abs(a(-1+2)-b(-1+2))>=half) ;
   goon300=0;
   if (ediff>0) ;
    z(l+1+2)=a(l+1+2);
   elseif (ediff<0);
    z(l+1+2)=b(l+1+2);
    z(-1+2)=b(-1+2);
    goon190=0;
   else;
    for i=1 : l;
     if (a(i+2)>b(i+2)) ;
      z(l+1+2)=a(l+1+2);
      break;
     end;
     if (a(i+2)<b(i+2)) ;
      z(l+1+2)=b(l+1+2);
      z(-1+2)=b(-1+2);
      goon190=0;
     end;
    end;
   end;
   %
  elseif (ediff>0);
   z(l+1+2)=a(l+1+2);
   for i=l : -1: 1+ediff ;
    z(i+2)=a(i+2)+b(i-ediff+2)+z(i+2);
    if (z(i+2)>=rmax) ;
     z(i+2)=z(i+2)-rmax;
     z(i-1+2)=one;
    end;
   end;
   for i=ediff : -1: 1 ;
    z(i+2)=a(i+2)+z(i+2);
    if (z(i+2)>=rmax) ;
     z(i+2)=z(i+2)-rmax;
     z(i-1+2)=one;
    end;
   end;
   if (z(0+2)>half) ;
    for i=l : -1: 1 ;
     z(i+2)=z(i-1+2);
    end;
    z(l+1+2)=z(l+1+2)+1;
    z(0+2)=0.0;
   end;
  elseif (ediff<0);
   z(l+1+2)=b(l+1+2);
   for i=l : -1: 1-ediff ;
    z(i+2)=a(i+ediff+2)+b(i+2)+z(i+2);
    if (z(i+2)>=rmax) ;
     z(i+2)=z(i+2)-rmax;
     z(i-1+2)=one;
    end;
   end;
   for i=0-ediff : -1: 1 ;
    z(i+2)=b(i+2)+z(i+2);
    if (z(i+2)>=rmax) ;
     z(i+2)=z(i+2)-rmax;
     z(i-1+2)=one;
    end;
   end;
   if (z(0+2)>half) ;
    for i=l : -1: 1 ;
     z(i+2)=z(i-1+2);
    end;
    z(l+1+2)=z(l+1+2)+one;
    z(0+2)=0.0;
   end;
  else;
   z(l+1+2)=a(l+1+2);
   for i=l : -1: 1 ;
    z(i+2)=a(i+2)+b(i+2)+z(i+2);
    if (z(i+2)>=rmax) ;
     z(i+2)=z(i+2)-rmax;
     z(i-1+2)=one;
    end;
   end;
   if (z(0+2)>half) ;
    for i=l : -1: 1 ;
     z(i+2)=z(i-1+2);
    end;
    z(l+1+2)=z(l+1+2)+one;
    z(0+2)=0.0;
   end;
  end;
  if (goon300==1) ;
   i=i; %here is the line that had a +1 taken from it.
   while (z(i+2)<half & i<l+1);
    i=i+1;
   end;
   if (i==l+1) ;
    z(-1+2)=one;
    z(l+1+2)=0.0;
    for i=-1 : l+1;
     c(i+2)=z(i+2);
    end;
    if (c(1+2)<half) ;
     c(-1+2)=one;
     c(l+1+2)=0.0;
    end;
    return;
   end;
   for j=1 : l+1-i;
    z(j+2)=z(j+i-1+2);
   end;
   for j=l+2-i : l;
    z(j+2)=0.0;
   end;
   z(l+1+2)=z(l+1+2)-i+1;
   for i=-1 : l+1;
    c(i+2)=z(i+2);
   end;
   if (c(1+2)<half) ;
    c(-1+2)=one;
    c(l+1+2)=0.0;
   end;
   return;
  end;
  %
  if (goon190==1) ;
   if (ediff>0) ;
    for i=l : -1: 1+ediff ;
     z(i+2)=a(i+2)-b(i-ediff+2)+z(i+2);
     if (z(i+2)<0.0) ;
      z(i+2)=z(i+2)+rmax;
      z(i-1+2)=-one;
     end;
    end;
    for i=ediff : -1: 1 ;
     z(i+2)=a(i+2)+z(i+2);
     if (z(i+2)<0.0) ;
      z(i+2)=z(i+2)+rmax;
      z(i-1+2)=-one;
     end;
    end;
   else;
    for i=l : -1: 1 ;
     z(i+2)=a(i+2)-b(i+2)+z(i+2);
     if (z(i+2)<0.0) ;
      z(i+2)=z(i+2)+rmax;
      z(i-1+2)=-one;
     end;
    end;
   end;
   if (z(1+2)>half) ;
    for i=-1 : l+1;
     c(i+2)=z(i+2);
    end;
    if (c(1+2)<half) ;
     c(-1+2)=one;
     c(l+1+2)=0.0;
    end;
    return;
   end;
   i=1;
   i=i+1;
   while (z(i+2)<half & i<l+1);
    i=i+1;
   end;
   if (i==l+1) ;
    z(-1+2)=one;
    z(l+1+2)=0.0;
    for i=-1 : l+1;
     c(i+2)=z(i+2);
    end;
    if (c(1+2)<half) ;
     c(-1+2)=one;
     c(l+1+2)=0.0;
    end;
    return;
   end;
   for j=1 : l+1-i;
    z(j+2)=z(j+i-1+2);
   end;
   for j=l+2-i : l;
    z(j+2)=0.0;
   end;
   z(l+1+2)=z(l+1+2)-i+1;
   for i=-1 : l+1;
    c(i+2)=z(i+2);
   end;
   if (c(1+2)<half) ;
    c(-1+2)=one;
    c(l+1+2)=0.0;
   end;
   return;
  end;
 end;
 %
 if (ediff<0) ;
  for i=l : -1: 1-ediff ;
   z(i+2)=b(i+2)-a(i+ediff+2)+z(i+2);
   if (z(i+2)<0.0) ;
    z(i+2)=z(i+2)+rmax;
    z(i-1+2)=-one;
   end;
  end;
  for i=0-ediff : -1: 1 ;
   z(i+2)=b(i+2)+z(i+2);
   if (z(i+2)<0.0) ;
    z(i+2)=z(i+2)+rmax;
    z(i-1+2)=-one;
   end;
  end;
 else;
  for i=l : -1: 1 ;
   z(i+2)=b(i+2)-a(i+2)+z(i+2);
   if (z(i+2)<0.0) ;
    z(i+2)=z(i+2)+rmax;
    z(i-1+2)=-one;
   end;
  end;
 end;
end;
%
if (z(1+2)>half) ;
 for i=-1 : l+1;
  c(i+2)=z(i+2);
 end;
 if (c(1+2)<half) ;
  c(-1+2)=one;
  c(l+1+2)=0.0;
 end;
 return;
end;
i=1;
i=i+1;
while (z(i+2)<half & i<l+1);
 i=i+1;
end;
if (i==l+1) ;
 z(-1+2)=one;
 z(l+1+2)=0.0;
 for i=-1 : l+1;
  c(i+2)=z(i+2);
 end;
 if (c(1+2)<half) ;
  c(-1+2)=one;
  c(l+1+2)=0.0;
 end;
 return;
end;
for j=1 : l+1-i;
 z(j+2)=z(j+i-1+2);
end;
for j=l+2-i : l;
 z(j+2)=0.0;
end;
z(l+1+2)=z(l+1+2)-i+1;
for i=-1 : l+1;
 c(i+2)=z(i+2);
end;
if (c(1+2)<half) ;
 c(-1+2)=one;
 c(l+1+2)=0.0;
end;
end

%
%
%     ****************************************************************
%     *                                                              *
%     *                 SUBROUTINE ARSUB                             *
%     *                                                              *
%     *                                                              *
%     *  Description : Accepts two arrays and subtracts each element *
%     *    in the second array from the element in the first array   *
%     *    and returns the solution.  The parameters L and RMAX are  *
%     *    the size of the array and the number of digits needed for *
%     *    the accuracy, respectively.                               *
%     *                                                              *
%     *  Subprograms called: ARADD                                   *
%     *                                                              *
%     ****************************************************************
%
function [a,b,c,wk1,wk2,l,rmax]=arsub(a,b,c,wk1,wk2,l,rmax);
%
%
global  zero   half   one   two   ten   eps;
%
%
%
i=0;
%
%
for i=-1 : l+1;
 wk2(i+2)=b(i+2);
end;
wk2(-1+2)=(-one).*wk2(-1+2);
[a,wk2,c,wk1,l,rmax]=aradd(a,wk2,c,wk1,l,rmax);
end

%
%
%     ****************************************************************
%     *                                                              *
%     *                 SUBROUTINE ARMULT                            *
%     *                                                              *
%     *                                                              *
%     *  Description : Accepts two arrays and returns the product.   *
%     *    L and RMAX are the size of the arrays and the number of   *
%     *    digits needed to represent the numbers with the required  *
%     *    accuracy.                                                 *
%     *                                                              *
%     *  Subprograms called: none                                    *
%     *                                                              *
%     ****************************************************************
%
function [a,b,c,z,l,rmax]=armult(a,b,c,z,l,rmax);
%
%
global  zero   half   one   two   ten   eps;
%
%
%
b2=0;carry=0;
i=0;
%
%
z(-1+2)=(abs(one).*sign(b)).*a(-1+2);
b2=abs(b);
z(l+1+2)=a(l+1+2);
for i=0 : l;
 z(i+2)=0.0;
end;
if (b2<=eps | a(1+2)<=eps) ;
 z(-1+2)=one;
 z(l+1+2)=0.0;
else;
 for i=l : -1: 1 ;
  z(i+2)=a(i+2).*b2+z(i+2);
  if (z(i+2)>=rmax) ;
   carry=fix(z(i+2)./rmax);
   z(i+2)=z(i+2)-carry.*rmax;
   z(i-1+2)=carry;
  end;
 end;
 if (z(0+2)>=half) ;
  for i=l : -1: 1 ;
   z(i+2)=z(i-1+2);
  end;
  z(l+1+2)=z(l+1+2)+one;
  if (z(1+2)>=rmax) ;
   for i=l : -1: 1 ;
    z(i+2)=z(i-1+2);
   end;
   carry=fix(z(1+2)./rmax);
   z(2+2)=z(2+2)-carry.*rmax;
   z(1+2)=carry;
   z(l+1+2)=z(l+1+2)+one;
  end;
  z(0+2)=0.0;
 end;
end;
for i=-1 : l+1;
 c(i+2)=z(i+2);
end;
if (c(1+2)<half) ;
 c(-1+2)=one;
 c(l+1+2)=0.0;
end;
end

%
%     ****************************************************************
%     *                                                              *
%     *                 SUBROUTINE CMPADD                            *
%     *                                                              *
%     *                                                              *
%     *  Description : Takes two arrays representing one real and    *
%     *    one imaginary part, and adds two arrays representing      *
%     *    another complex number and returns two array holding the  *
%     *    complex sum.                                              *
%     *              (CR,CI) = (AR+BR, AI+BI)                        *
%     *                                                              *
%     *  Subprograms called: ARADD                                   *
%     *                                                              *
%     ****************************************************************
%
function [ar,ai,br,bi,cr,ci,wk1,l,rmax]=cmpadd(ar,ai,br,bi,cr,ci,wk1,l,rmax);
%
%
%
%
%
%
[ar,br,cr,wk1,l,rmax]=aradd(ar,br,cr,wk1,l,rmax);
[ai,bi,ci,wk1,l,rmax]=aradd(ai,bi,ci,wk1,l,rmax);
end

%
%
%     ****************************************************************
%     *                                                              *
%     *                 SUBROUTINE CMPSUB                            *
%     *                                                              *
%     *                                                              *
%     *  Description : Takes two arrays representing one real and    *
%     *    one imaginary part, and subtracts two arrays representing *
%     *    another complex number and returns two array holding the  *
%     *    complex sum.                                              *
%     *              (CR,CI) = (AR+BR, AI+BI)                        *
%     *                                                              *
%     *  Subprograms called: ARADD                                   *
%     *                                                              *
%     ****************************************************************
%
function [ar,ai,br,bi,cr,ci,wk1,wk2,l,rmax]=cmpsub(ar,ai,br,bi,cr,ci,wk1,wk2,l,rmax);
%
%
%
%
%
%
[ar,br,cr,wk1,wk2,l,rmax]=arsub(ar,br,cr,wk1,wk2,l,rmax);
[ai,bi,ci,wk1,wk2,l,rmax]=arsub(ai,bi,ci,wk1,wk2,l,rmax);
end

%
%
%     ****************************************************************
%     *                                                              *
%     *                 SUBROUTINE CMPMUL                            *
%     *                                                              *
%     *                                                              *
%     *  Description : Takes two arrays representing one real and    *
%     *    one imaginary part, and multiplies it with two arrays     *
%     *    representing another complex number and returns the       *
%     *    complex product.                                          *
%     *                                                              *
%     *  Subprograms called: ARMULT, ARSUB, ARADD                    *
%     *                                                              *
%     ****************************************************************
%
function [ar,ai,br,bi,cr,ci,wk1,wk2,cr2,d1,d2,wk6,l,rmax]=cmpmul(ar,ai,br,bi,cr,ci,wk1,wk2,cr2,d1,d2,wk6,l,rmax);
%
%
%
%
i=0;
%
%
[ar,br,d1,wk6,l,rmax]=armult(ar,br,d1,wk6,l,rmax);
[ai,bi,d2,wk6,l,rmax]=armult(ai,bi,d2,wk6,l,rmax);
[d1,d2,cr2,wk1,wk2,l,rmax]=arsub(d1,d2,cr2,wk1,wk2,l,rmax);
[ar,bi,d1,wk6,l,rmax]=armult(ar,bi,d1,wk6,l,rmax);
[ai,br,d2,wk6,l,rmax]=armult(ai,br,d2,wk6,l,rmax);
[d1,d2,ci,wk1,l,rmax]=aradd(d1,d2,ci,wk1,l,rmax);
for i=-1 : l+1;
 cr(i+2)=cr2(i+2);
end;
end

%
%
%     ****************************************************************
%     *                                                              *
%     *                 SUBROUTINE ARYDIV                            *
%     *                                                              *
%     *                                                              *
%     *  Description : Returns the double precision complex number   *
%     *    resulting from the division of four arrays, representing  *
%     *    two complex numbers.  The number returned will be in one  *
%     *    of two different forms:  either standard scientific or as *
%     *    the log (base 10) of the number.                          *
%     *                                                              *
%     *  Subprograms called: CONV21, CONV12, EADD, ECPDIV, EMULT.    *
%     *                                                              *
%     ****************************************************************
%
function [ar,ai,br,bi,c,l,lnpfq,rmax,ibit]=arydiv(ar,ai,br,bi,c,l,lnpfq,rmax,ibit);
%
%
cdum=[];ae=[];be=[];ce=[];n1=[];e1=[];n2=[];e2=[];n3=[];e3=[];
global  zero   half   one   two   ten   eps;
%
%
%
%
ae=zeros(2,2);be=zeros(2,2);ce=zeros(2,2);dum1=0;dum2=0;e1=0;e2=0;e3=0;n1=0;n2=0;n3=0;phi=0;ri10=0;rr10=0;tenmax=0;x=0;x1=0;x2=0;
cdum=0;
%
dnum=0;
ii10=0;ir10=0;itnmax=0;rexp=0;
%
%
%
rexp=fix(ibit./2);
x=rexp.*(ar(l+1+2)-2);
rr10=x.*log10(two)./log10(ten);
ir10=fix(rr10);
rr10=rr10-ir10;
x=rexp.*(ai(l+1+2)-2);
ri10=x.*log10(two)./log10(ten);
ii10=fix(ri10);
ri10=ri10-ii10;
dum1=(abs(ar(1+2).*rmax.*rmax+ar(2+2).*rmax+ar(3+2)).*sign(ar(-1+2)));
dum2=(abs(ai(1+2).*rmax.*rmax+ai(2+2).*rmax+ai(3+2)).*sign(ai(-1+2)));
dum1=dum1.*10.^rr10;
dum2=dum2.*10.^ri10;
cdum=complex(dum1,dum2);
[cdum,ae]=conv12(cdum,ae);
ae(1,2)=ae(1,2)+ir10;
ae(2,2)=ae(2,2)+ii10;
x=rexp.*(br(l+1+2)-2);
rr10=x.*log10(two)./log10(ten);
ir10=fix(rr10);
rr10=rr10-ir10;
x=rexp.*(bi(l+1+2)-2);
ri10=x.*log10(two)./log10(ten);
ii10=fix(ri10);
ri10=ri10-ii10;
dum1=(abs(br(1+2).*rmax.*rmax+br(2+2).*rmax+br(3+2)).*sign(br(-1+2)));
dum2=(abs(bi(1+2).*rmax.*rmax+bi(2+2).*rmax+bi(3+2)).*sign(bi(-1+2)));
dum1=dum1.*10.^rr10;
dum2=dum2.*10.^ri10;
cdum=complex(dum1,dum2);
[cdum,be]=conv12(cdum,be);
be(1,2)=be(1,2)+ir10;
be(2,2)=be(2,2)+ii10;
[ae,be,ce]=ecpdiv(ae,be,ce);
if (lnpfq==0) ;
 [ce,c]=conv21(ce,c);
else;
 [ce(1,1),ce(1,2),ce(1,1),ce(1,2),n1,e1]=emult(ce(1,1),ce(1,2),ce(1,1),ce(1,2),n1,e1);
 [ce(2,1),ce(2,2),ce(2,1),ce(2,2),n2,e2]=emult(ce(2,1),ce(2,2),ce(2,1),ce(2,2),n2,e2);
 [n1,e1,n2,e2,n3,e3]=eadd(n1,e1,n2,e2,n3,e3);
 n1=ce(1,1);
 e1=ce(1,2)-ce(2,2);
 x2=ce(2,1);
 %
 %      TENMAX - MAXIMUM SIZE OF EXPONENT OF 10
 %
 %      THE FOLLOWING CODE CAN BE USED TO DETERMINE TENMAX, BUT IT
 %
 %      WILL LIKELY GENERATE AN IEEE FLOATING POINT UNDERFLOW ERROR
 %
 %      ON A SUN WORKSTATION.  REPLACE TENMAX WITH THE VALUE APPROPRIATE
 %
 %      FOR YOUR MACHINE.
 %
 %
 tenmax=320;
 itnmax=1;
 dnum=0.1d0;
 itnmax=itnmax+1;
 dnum=dnum.*0.1d0;
 while (dnum>0.0);
  itnmax=itnmax+1;
  dnum=dnum.*0.1d0;
 end;
 itnmax=itnmax-1;
 tenmax=real(itnmax);
 %
 if (e1>tenmax) ;
  x1=tenmax;
 elseif (e1<-tenmax);
  x1=0.0;
 else;
  x1=n1.*(ten.^e1);
 end;
 if (x2~=0.0) ;
  phi=atan2(x2,x1);
 else;
  phi=0.0;
 end;
 c=complex(half.*(log(n3)+e3.*log(ten)),phi);
end;
end

%
%     ****************************************************************
%     *                                                              *
%     *                 SUBROUTINE EMULT                             *
%     *                                                              *
%     *                                                              *
%     *  Description : Takes one base and exponent and multiplies it *
%     *    by another numbers base and exponent to give the product  *
%     *    in the form of base and exponent.                         *
%     *                                                              *
%     *  Subprograms called: none                                    *
%     *                                                              *
%     ****************************************************************
%
function [n1,e1,n2,e2,nf,ef]=emult(n1,e1,n2,e2,nf,ef);
%
%
global  zero   half   one   two   ten   eps;
%
%
%
nf=n1.*n2;
ef=e1+e2;
if (abs(nf)>=ten) ;
 nf=nf./ten;
 ef=ef+one;
end;
end

%
%
%     ****************************************************************
%     *                                                              *
%     *                 SUBROUTINE EDIV                              *
%     *                                                              *
%     *                                                              *
%     *  Description : returns the solution in the form of base and  *
%     *    exponent of the division of two exponential numbers.      *
%     *                                                              *
%     *  Subprograms called: none                                    *
%     *                                                              *
%     ****************************************************************
%
function [n1,e1,n2,e2,nf,ef]=ediv(n1,e1,n2,e2,nf,ef);
%
%
global  zero   half   one   two   ten   eps;
%
%
%
nf=n1./n2;
ef=e1-e2;
if ((abs(nf)<one) & (nf~=zero)) ;
 nf=nf.*ten;
 ef=ef-one;
end;
end

%
%
%     ****************************************************************
%     *                                                              *
%     *                 SUBROUTINE EADD                              *
%     *                                                              *
%     *                                                              *
%     *  Description : Returns the sum of two numbers in the form    *
%     *    of a base and an exponent.                                *
%     *                                                              *
%     *  Subprograms called: none                                    *
%     *                                                              *
%     ****************************************************************
%
function [n1,e1,n2,e2,nf,ef]=eadd(n1,e1,n2,e2,nf,ef);
%
%
global  zero   half   one   two   ten   eps;
%
ediff=0;
%
%
ediff=e1-e2;
if (ediff>36.0d0) ;
 nf=n1;
 ef=e1;
elseif (ediff<-36.0d0);
 nf=n2;
 ef=e2;
else;
 nf=n1.*(ten.^ediff)+n2;
 ef=e2;
 while (1);
  if (abs(nf)<ten) ;
   while ((abs(nf)<one) & (nf~=0.0));
    nf=nf.*ten;
    ef=ef-one;
   end;
   break;
  else;
   nf=nf./ten;
   ef=ef+one;
  end;
 end;
end;
end


%
%     ****************************************************************
%     *                                                              *
%     *                 SUBROUTINE ESUB                              *
%     *                                                              *
%     *                                                              *
%     *  Description : Returns the solution to the subtraction of    *
%     *    two numbers in the form of base and exponent.             *
%     *                                                              *
%     *  Subprograms called: EADD                                    *
%     *                                                              *
%     ****************************************************************
%
function [n1,e1,n2,e2,nf,ef]=esub(n1,e1,n2,e2,nf,ef);
%
%
global  zero   half   one   two   ten   eps;
%
%
%
[n1,e1,dumvar3,e2,nf,ef]=eadd(n1,e1,n2.*(-one),e2,nf,ef);
end

%
%
%     ****************************************************************
%     *                                                              *
%     *                 SUBROUTINE CONV12                            *
%     *                                                              *
%     *                                                              *
%     *  Description : Converts a number from complex notation to a  *
%     *    form of a 2x2 real array.                                 *
%     *                                                              *
%     *  Subprograms called: none                                    *
%     *                                                              *
%     ****************************************************************
%
function [cn,cae]=conv12(cn,cae);
%
%
global  zero   half   one   two   ten   eps;
%
%
%
%
%
cae(1,1)=real(cn);
cae(1,2)=0.0;
while (1);
 if (abs(cae(1,1))<ten) ;
  while (1);
   if ((abs(cae(1,1))>=one) | (cae(1,1)==0.0)) ;
    cae(2,1)=imag(cn);
    cae(2,2)=0.0;
    while (1);
     if (abs(cae(2,1))<ten) ;
      while ((abs(cae(2,1))<one) & (cae(2,1)~=0.0));
       cae(2,1)=cae(2,1).*ten;
       cae(2,2)=cae(2,2)-one;
      end;
      break;
     else;
      cae(2,1)=cae(2,1)./ten;
      cae(2,2)=cae(2,2)+one;
     end;
    end;
    break;
   else;
    cae(1,1)=cae(1,1).*ten;
    cae(1,2)=cae(1,2)-one;
   end;
  end;
  break;
 else;
  cae(1,1)=cae(1,1)./ten;
  cae(1,2)=cae(1,2)+one;
 end;
end;
end


%
%     ****************************************************************
%     *                                                              *
%     *                 SUBROUTINE CONV21                            *
%     *                                                              *
%     *                                                              *
%     *  Description : Converts a number represented in a 2x2 real   *
%     *    array to the form of a complex number.                    *
%     *                                                              *
%     *  Subprograms called: none                                    *
%     *                                                              *
%     ****************************************************************
%
function [cae,cn]=conv21(cae,cn);
%
%
%
global  zero   half   one   two   ten   eps;
global  nout;
%
%
%
dnum=0;tenmax=0;
itnmax=0;
%
%
%     TENMAX - MAXIMUM SIZE OF EXPONENT OF 10
%
itnmax=1;
dnum=0.1d0;
itnmax=itnmax+1;
dnum=dnum.*0.1d0;
while  (dnum>0.0);
 itnmax=itnmax+1;
 dnum=dnum.*0.1d0;
end;
itnmax=itnmax-2;
tenmax=real(itnmax);
%
if (cae(1,2)>tenmax | cae(2,2)>tenmax) ;
 %      CN=CMPLX(TENMAX,TENMAX)
 %
 itnmax,
 %format (' error - value of exponent required for summation',' was larger',./,' than the maximum machine exponent ',1i3,./,[' suggestions:'],./,' 1) re-run using lnpfq=1.',./,' 2) if you are using a vax, try using the',' fortran./g_floating option');
 error('stop encountered in original fortran code');
elseif (cae(2,2)<-tenmax);
 cn=complex(cae(1,1).*(10.^cae(1,2)),0.0);
else;
 cn=complex(cae(1,1).*(10.^cae(1,2)),cae(2,1).*(10.^cae(2,2)));
end;
return;
end

%
%
%     ****************************************************************
%     *                                                              *
%     *                 SUBROUTINE ECPMUL                            *
%     *                                                              *
%     *                                                              *
%     *  Description : Multiplies two numbers which are each         *
%     *    represented in the form of a two by two array and returns *
%     *    the solution in the same form.                            *
%     *                                                              *
%     *  Subprograms called: EMULT, ESUB, EADD                       *
%     *                                                              *
%     ****************************************************************
%
function [a,b,c]=ecpmul(a,b,c);
%
%
n1=[];e1=[];n2=[];e2=[];c2=[];
c2=zeros(2,2);e1=0;e2=0;n1=0;n2=0;
%
%
[a(1,1),a(1,2),b(1,1),b(1,2),n1,e1]=emult(a(1,1),a(1,2),b(1,1),b(1,2),n1,e1);
[a(2,1),a(2,2),b(2,1),b(2,2),n2,e2]=emult(a(2,1),a(2,2),b(2,1),b(2,2),n2,e2);
[n1,e1,n2,e2,c2(1,1),c2(1,2)]=esub(n1,e1,n2,e2,c2(1,1),c2(1,2));
[a(1,1),a(1,2),b(2,1),b(2,2),n1,e1]=emult(a(1,1),a(1,2),b(2,1),b(2,2),n1,e1);
[a(2,1),a(2,2),b(1,1),b(1,2),n2,e2]=emult(a(2,1),a(2,2),b(1,1),b(1,2),n2,e2);
[n1,e1,n2,e2,c(2,1),c(2,2)]=eadd(n1,e1,n2,e2,c(2,1),c(2,2));
c(1,1)=c2(1,1);
c(1,2)=c2(1,2);
end

%
%
%     ****************************************************************
%     *                                                              *
%     *                 SUBROUTINE ECPDIV                            *
%     *                                                              *
%     *                                                              *
%     *  Description : Divides two numbers and returns the solution. *
%     *    All numbers are represented by a 2x2 array.               *
%     *                                                              *
%     *  Subprograms called: EADD, ECPMUL, EDIV, EMULT               *
%     *                                                              *
%     ****************************************************************
%
function [a,b,c]=ecpdiv(a,b,c);
%
%
b2=[];c2=[];n1=[];e1=[];n2=[];e2=[];n3=[];e3=[];
global  zero   half   one   two   ten   eps;
%
b2=zeros(2,2);c2=zeros(2,2);e1=0;e2=0;e3=0;n1=0;n2=0;n3=0;
%
%
b2(1,1)=b(1,1);
b2(1,2)=b(1,2);
b2(2,1)=-one.*b(2,1);
b2(2,2)=b(2,2);
[a,b2,c2]=ecpmul(a,b2,c2);
[b(1,1),b(1,2),b(1,1),b(1,2),n1,e1]=emult(b(1,1),b(1,2),b(1,1),b(1,2),n1,e1);
[b(2,1),b(2,2),b(2,1),b(2,2),n2,e2]=emult(b(2,1),b(2,2),b(2,1),b(2,2),n2,e2);
[n1,e1,n2,e2,n3,e3]=eadd(n1,e1,n2,e2,n3,e3);
[c2(1,1),c2(1,2),n3,e3,c(1,1),c(1,2)]=ediv(c2(1,1),c2(1,2),n3,e3,c(1,1),c(1,2));
[c2(2,1),c2(2,2),n3,e3,c(2,1),c(2,2)]=ediv(c2(2,1),c2(2,2),n3,e3,c(2,1),c(2,2));
end

%     ****************************************************************
%     *                                                              *
%     *                   FUNCTION IPREMAX                           *
%     *                                                              *
%     *                                                              *
%     *  Description : Predicts the maximum term in the pFq series   *
%     *    via a simple scanning of arguments.                       *
%     *                                                              *
%     *  Subprograms called: none.                                   *
%     *                                                              *
%     ****************************************************************
%
function [ipremax]=ipremax(a,b,ip,iq,z);
%
%
%
global  zero   half   one   two   ten   eps;
global  nout;
%
%
%
%
%
expon=0;xl=0;xmax=0;xterm=0;
%
i=0;j=0;
%
xterm=0;
for j=1 : 100000;
 %
 %      Estimate the exponent of the maximum term in the pFq series.
 %
 %
 expon=zero;
 xl=real(j);
 for i=1 : ip;
  expon=expon+real(factor(a(i)+xl-one))-real(factor(a(i)-one));
 end;
 for i=1 : iq;
  expon=expon-real(factor(b(i)+xl-one))+real(factor(b(i)-one));
 end;
 expon=expon+xl.*real(log(z))-real(factor(complex(xl,zero)));
 xmax=log10(exp(one)).*expon;
 if ((xmax<xterm) & (j>2)) ;
  ipremax=j;
  return;
 end;
 xterm=max([xmax,xterm]);
end;
' error in ipremax--did not find maximum exponent',
error('stop encountered in original fortran code');
end

%     ****************************************************************
%     *                                                              *
%     *                   FUNCTION FACTOR                            *
%     *                                                              *
%     *                                                              *
%     *  Description : This function is the log of the factorial.    *
%     *                                                              *
%     *  Subprograms called: none.                                   *
%     *                                                              *
%     ****************************************************************
%
function [factor]=factor(z);
%
%
global  zero   half   one   two   ten   eps;
%
%
%
pi=0;
%
if (((real(z)==one) & (imag(z)==zero)) | (abs(z)==zero)) ;
 factor=complex(zero,zero);
 return;
end;
pi=two.*two.*atan(one);
factor=half.*log(two.*pi)+(z+half).*log(z)-z+(one./(12.0d0.*z)).*(one-(one./(30.d0.*z.*z)).*(one-(two./(7.0d0.*z.*z))));
end

%     ****************************************************************
%     *                                                              *
%     *                   FUNCTION CGAMMA                            *
%     *                                                              *
%     *                                                              *
%     *  Description : Calculates the complex gamma function.  Based *
%     *     on a program written by F.A. Parpia published in Computer*
%     *     Physics Communications as the `GRASP2' program (public   *
%     *     domain).                                                 *
%     *                                                              *
%     *                                                              *
%     *  Subprograms called: none.                                   *
%     *                                                              *
%     ****************************************************************
function [cgamma]=cgamma(arg,lnpfq);
%
%
%
%
%
global  zero   half   one   two   ten   eps;
global  nout;
%
%
%
argi=0;argr=0;argui=0;argui2=0;argum=0;argur=0;argur2=0;clngi=0;clngr=0;diff=0;dnum=0;expmax=0;fac=0;facneg=0;fd=zeros(7,1);fn=zeros(7,1);hlntpi=0;obasq=0;obasqi=0;obasqr=0;ovlfac=0;ovlfi=0;ovlfr=0;pi=0;precis=0;resi=0;resr=0;tenmax=0;tenth=0;termi=0;termr=0;twoi=0;zfaci=0;zfacr=0;
%
first=0;negarg=0;cgamma=0;
i=0;itnmax=0;
%
%
%
%----------------------------------------------------------------------*
%     *
%     THESE ARE THE BERNOULLI NUMBERS B02, B04, ..., B14, EXPRESSED AS *
%     RATIONAL NUMBERS. FROM ABRAMOWITZ AND STEGUN, P. 810.            *
%     *
fn=[1.0d00,-1.0d00,1.0d00,-1.0d00,5.0d00,-691.0d00,7.0d00];
fd=[6.0d00,30.0d00,42.0d00,30.0d00,66.0d00,2730.0d00,6.0d00];
%
%----------------------------------------------------------------------*
%
hlntpi=[1.0d00];
%
first=[true];
%
tenth=[0.1d00];
%
argr=real(arg);
argi=imag(arg);
%
%     ON THE FIRST ENTRY TO THIS ROUTINE, SET UP THE CONSTANTS REQUIRED
%     FOR THE REFLECTION FORMULA (CF. ABRAMOWITZ AND STEGUN 6.1.17) AND
%     STIRLING'S APPROXIMATION (CF. ABRAMOWITZ AND STEGUN 6.1.40).
%
if (first) ;
 pi=4.0d0.*atan(one);
 %
 %      SET THE MACHINE-DEPENDENT PARAMETERS:
 %
 %
 %      TENMAX - MAXIMUM SIZE OF EXPONENT OF 10
 %
 %
 itnmax=1;
 dnum=tenth;
 itnmax=itnmax+1;
 dnum=dnum.*tenth;
 while (dnum>0.0);
  itnmax=itnmax+1;
  dnum=dnum.*tenth;
 end;
 itnmax=itnmax-1;
 tenmax=real(itnmax);
 %
 %      EXPMAX - MAXIMUM SIZE OF EXPONENT OF E
 %
 %
 dnum=tenth.^itnmax;
 expmax=-log(dnum);
 %
 %      PRECIS - MACHINE PRECISION
 %
 %
 precis=one;
 precis=precis./two;
 dnum=precis+one;
 while (dnum>one);
  precis=precis./two;
  dnum=precis+one;
 end;
 precis=two.*precis;
 %
 hlntpi=half.*log(two.*pi);
 %
 for i=1 : 7;
  fn(i)=fn(i)./fd(i);
  twoi=two.*real(i);
  fn(i)=fn(i)./(twoi.*(twoi-one));
 end;
 %
 first=false;
 %
end;
%
%     CASES WHERE THE ARGUMENT IS REAL
%
if (argi==0.0) ;
 %
 %      CASES WHERE THE ARGUMENT IS REAL AND NEGATIVE
 %
 %
 if (argr<=0.0) ;
  %
  %       STOP WITH AN ERROR MESSAGE IF THE ARGUMENT IS TOO NEAR A POLE
  %
  %
  diff=abs(real(round(argr))-argr);
  if (diff<=two.*precis) ;
   ,
   argr , argi,
   %format (' argument (',1p,1d14.7,',',1d14.7,') too close to a',' pole.');
   error('stop encountered in original fortran code');
  else;
   %
   %        OTHERWISE USE THE REFLECTION FORMULA (ABRAMOWITZ AND STEGUN 6.1
   %        .17)
   %        TO ENSURE THAT THE ARGUMENT IS SUITABLE FOR STIRLING'S
   %
   %        FORMULA
   %
   %
   argum=pi./(-argr.*sin(pi.*argr));
   if (argum<0.0) ;
    argum=-argum;
    clngi=pi;
   else;
    clngi=0.0;
   end;
   facneg=log(argum);
   argur=-argr;
   negarg=true;
   %
  end;
  %
  %       CASES WHERE THE ARGUMENT IS REAL AND POSITIVE
  %
  %
 else;
  %
  clngi=0.0;
  argur=argr;
  negarg=false;
  %
 end;
 %
 %      USE ABRAMOWITZ AND STEGUN FORMULA 6.1.15 TO ENSURE THAT
 %
 %      THE ARGUMENT IN STIRLING'S FORMULA IS GREATER THAN 10
 %
 %
 ovlfac=one;
 while (argur<ten);
  ovlfac=ovlfac.*argur;
  argur=argur+one;
 end;
 %
 %      NOW USE STIRLING'S FORMULA TO COMPUTE LOG (GAMMA (ARGUM))
 %
 %
 clngr=(argur-half).*log(argur)-argur+hlntpi;
 fac=argur;
 obasq=one./(argur.*argur);
 for i=1 : 7;
  fac=fac.*obasq;
  clngr=clngr+fn(i).*fac;
 end;
 %
 %      INCLUDE THE CONTRIBUTIONS FROM THE RECURRENCE AND REFLECTION
 %
 %      FORMULAE
 %
 %
 clngr=clngr-log(ovlfac);
 if (negarg) ;
  clngr=facneg-clngr;
 end;
 %
else;
 %
 %      CASES WHERE THE ARGUMENT IS COMPLEX
 %
 %
 argur=argr;
 argui=argi;
 argui2=argui.*argui;
 %
 %      USE THE RECURRENCE FORMULA (ABRAMOWITZ AND STEGUN 6.1.15)
 %
 %      TO ENSURE THAT THE MAGNITUDE OF THE ARGUMENT IN STIRLING'S
 %
 %      FORMULA IS GREATER THAN 10
 %
 %
 ovlfr=one;
 ovlfi=0.0;
 argum=sqrt(argur.*argur+argui2);
 while (argum<ten);
  termr=ovlfr.*argur-ovlfi.*argui;
  termi=ovlfr.*argui+ovlfi.*argur;
  ovlfr=termr;
  ovlfi=termi;
  argur=argur+one;
  argum=sqrt(argur.*argur+argui2);
 end;
 %
 %      NOW USE STIRLING'S FORMULA TO COMPUTE LOG (GAMMA (ARGUM))
 %
 %
 argur2=argur.*argur;
 termr=half.*log(argur2+argui2);
 termi=atan2(argui,argur);
 clngr=(argur-half).*termr-argui.*termi-argur+hlntpi;
 clngi=(argur-half).*termi+argui.*termr-argui;
 fac=(argur2+argui2).^(-2);
 obasqr=(argur2-argui2).*fac;
 obasqi=-two.*argur.*argui.*fac;
 zfacr=argur;
 zfaci=argui;
 for i=1 : 7;
  termr=zfacr.*obasqr-zfaci.*obasqi;
  termi=zfacr.*obasqi+zfaci.*obasqr;
  fac=fn(i);
  clngr=clngr+termr.*fac;
  clngi=clngi+termi.*fac;
  zfacr=termr;
  zfaci=termi;
 end;
 %
 %      ADD IN THE RELEVANT PIECES FROM THE RECURRENCE FORMULA
 %
 %
 clngr=clngr-half.*log(ovlfr.*ovlfr+ovlfi.*ovlfi);
 clngi=clngi-atan2(ovlfi,ovlfr);
 %
end;
if (lnpfq==1) ;
 cgamma=complex(clngr,clngi);
 return;
end;
%
%     NOW EXPONENTIATE THE COMPLEX LOG GAMMA FUNCTION TO GET
%     THE COMPLEX GAMMA FUNCTION
%
if ((clngr<=expmax) & (clngr>=-expmax)) ;
 fac=exp(clngr);
else;
 ,
 clngr,
 %format (' argument to exponential function (',1p,1d14.7,') out of range.');
 error('stop encountered in original fortran code');
end;
resr=fac.*cos(clngi);
resi=fac.*sin(clngi);
cgamma=complex(resr,resi);
%
return;
end
