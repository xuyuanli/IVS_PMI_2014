IVS_PMI_2014
============

Partial mutual information based input variable selection

Overview:

The Water Systems research group at the University of Adelaide School of Engineering has been researching the use of artificial neural networks (ANNs) for water resources modeling applications, such as flow forecasting, water quality forecasting and water treatment process modeling since the early 1990s. Consideration of the methods used in the steps in the development of ANNs, which consist of data collection, data processing, input variable selection, data division, calibration and validation, are vitally important, as ANN model development is based on data. 

Among these methods, input variable selection (IVS) plays a significant role, as the performance of the developed model can be compromised if inputs having a pronounced relationship with the modelled output are omitted. In contrast, calibration becomes extremely challenging and modelling validation, as well as knowledge extraction, are problematic if redundant or superfluous inputs are included. 

Partial mutual information (PMI) is one of the most promising approaches to IVS, as it has a number of desirable properties, such as the ability to account for input relevance, the ability to cater to both linear and non-linear input-output relationships and the ability to check the redundancy of selected inputs. Although PMI IVS has already been applied successfully to a number of studies in hydrological and water resource modelling, present implementations predominantly depend on the assumption that the data used to develop the model follow a Gaussian distribution.  This assumption has the potential (bandwidth and boundary issues) to affect two steps in the PMI process, including the estimation of MI/PMI and the estimation of the residuals. 

In order to overcome such impacts due to the Gaussian assumption and implement PMI IVS in a more robust and rigorous way for research purposes, software code for improved PMI IVS has been developed in PGI Visual Fortran 2008. 



Features:

The primary feature of the code for developing PMI IVS is that is caters to sixteen (16) different methods. Of these 16 approaches, three are benchmark approaches without consideration of the boundary issue (B1 to B3), two aim to improve the boundary issue in MI estimation (M1 to M2), seven aim to minimise the effect of the boundary issue in residual estimation (R1 to R7), and four take into account the boundary issue in both MI and residual estimations (C1 to C4). The benchmark studies represent the most commonly used approach applied in previous studies (B1) and the proposed approaches for data with non-Gaussian distributions (B2 and B3). The methods that only address the boundary issue in MI estimation include the refection correction and boundary kernel based MI estimations. The approaches that only investigate the boundary issue in residual estimation contain kernel based (modification of kernel function, kernel bandwidth, and kernel type) and kernel free methods. The techniques that consider the boundary issue in both MI and residual estimations are a combination of one boundary corrector used in MI (RK) and four boundary resistant algorithms. These 16 approaches cover the different combinations of approaches for dealing with the boundary issue in PMI IVS, although there are other combinations of methods that are likely to result in similar outcomes. 

Different approaches used for PMI IVS by considering bandwidth and boundary issues 

 	MI	                RE	                       
 	      
Method/ Bandwidth/ Kernel/ Bandwidth/ Kernel/ Regression/ Module Name

B1/	    GRR/	      CK/	    GRR/	      CK/	    GRNN/	      *1PMI_B1

B2/	    DPI/	      CK/	    GRR/	      CK/	    GRNN/	      *2PMI_B2

B3/	    DPI/	      CK/	    SVO/	      CK/	    GRNN/	       5PMI_B3

M1/	    DPI/	      RC/	    SVO/              CK/	    GRNN/	       6PMI_M1

M2/	    DPI/	      BK/	    SVO/	      CK/	    GRNN/	       7PMI_M1

R1/	    DPI/	      CK/	    SVO/	      RC/     	    GRNN/	       8PMI_R1

R2/	    DPI/	      CK/	    SVO/	      BK/	    GRNN/	       9PMI_R2

R3/	    DPI/	      CK/	    SVO/	      PA/	    GRNN/	       10PMI_R3

R4/	    DPI/	      CK/	    SVO/	      CK/	    LBR/	       11PMI_R4

R5/	    DPI/	      CK/	    SVO/	      CK/	    LLP/	      *3PMI_R5

R6/	    DPI/	      CK/	    SVO/	      CK/	    LQP/	       12PMI_R6

R7/	    DPI/              CK/	     -/	              -/	    MLPANN/	      *4PMI_R7

C1/	    DPI/	      RK/	    SVO/	      RC/	    GRNN/	       13PMI_C1

C2/	    DPI/	      RK/	    SVO/	      CK/	    LBR/	       14PMI_C2

C3/	    DPI/	      RK/	    SVO/	      CK/	    LLP/	       15PMI_C3

C4/	    DPI/	      RK/	     -/	              -/	     MLPANN/	       16PMI_C4

(B: benchmark approach; M: boundary correction in MI estimation; R: reducing boundary impact in residual estimation; C: combination of methods resistant to boundary issue, used in both MI and residual estimations; CK: conventional kernel with symmetric Gaussian kernel and GRR based bandwidth; * recommended approaches for distinct scenarios and already linked in the main program)

Approaches used for MI and RE:

	The Gaussian reference rule (GRR) (Scott, 1992) 
	Biased cross validation (BCV) (Scott and Terrell, 1987)
	2-stage direct plug-in (DPI) (Park and Marron, 1992)
	A combination of BCV and DPI (BCVDPI) (Wand and Jones, 1995)
	Smoothed cross validation (SCV) (Hall et al., 1992) 
	Single variable optimisation (SVO) (Gibbs et al., 2006; Press et al., 1992; Poli et al., 2007)
	Reflection correction (RC) (Schuster, 1985; Silverman, 1986)
	Boundary kernel (BK) (Gasser and Müller, 1979; Marshall and Hazelton, 2010; Zhang and Karunamuni, 2000)
	Pseudo-data approach (PA) (Cowling and Hall, 1996)
	Local bandwidth (reducing) (LBR) (Dai and Sperlich, 2010)
	Local linear polynomial (LLP) (Wand and Jones, 1995; Fan, 1992; Fan and Gijbels, 1996)
	Local quadratic polynomial (LQP) (Wand and Jones, 1995; Fan, 1992; Fan and Gijbels, 1996)

Reference:

	Cowling, A., Hall, P., 1996. On pseudodata methods for removing boundary effects in kernel density estimation. Journal of the Royal Statistical Society. Series B (Methodological) 58(3) 551-563.
	
	Fan, J., 1992. Design-adaptive nonparametric regression. Journal of the American Statistical Association 87(420) 998-1004.
	
	Fan, J., Gijbels, I., 1996. Local polynomial modelling and its applications: monographs on statistics and applied probability 66. CRC Press, London, UK.
	
	Gibbs, MS, Morgan, N, Maier, HR, Dandy, GC, Nixon, J & Holmes, M 2006, 'Investigation into the relationship between chlorine decay and water distribution parameters using data driven methods', Mathematical and Computer Modelling, vol. 44, no. 5, pp. 485-498.
	
	Hall, P, Marron, J & Park, BU 1992, 'Smoothed cross-validation', Probability Theory and Related Fields, vol. 92, no. 1, pp. 1-20.
	
	Marshall, J.C., Hazelton, M.L., 2010. Boundary kernels for adaptive density estimators on regions with irregular boundaries. Journal of Multivariate Analysis 101(4) 949-963.
	
	Park, BU & Marron, J 1992, 'On the use of pilot estimators in bandwidth selection', Journal of Nonparametric Statistics, vol. 1, no. 3, pp. 231-240.
	
	Poli, R, Kennedy, J & Blackwell, T 2007, 'Particle swarm optimization', Swarm Intelligence, vol. 1, no. 1, pp. 33-57.
	Press, WH, Flannery, BP, Teukolsky, SA & Vetterling, WT 1992, Numerical Recipes in FORTRAN 77: Volume 1 of Fortran Numerical Recipes: The Art of Scientific Computing, vol. 1, Cambridge University Press.
	
	Schuster, E.F., 1985. Incorporating support constraints into nonparametric estimators of densities. Communications in Statistics-Theory and Methods 14(5) 1123-1136.
	
	Scott, DW & Terrell, GR 1987, 'Biased and unbiased cross-validation in density estimation', Journal of the American Statistical Association, vol. 82, no. 400, pp. 1131-1146.
	
	Scott, DW 1992, 'Multivariate density estimation and visualization', Handbook of Computational Statistics. New York: Springer.
	
	Silverman, B.W., 1986. Density estimation for statistics and data analysis. CRC press, London, UK.
	
	Wand, M.P., Jones, M.C., 1995. Kernel smoothing. Chapman & Hall, London, UK.
	
	Zhang, S., Karunamuni, R.J., 2000. On nonparametric density estimation at the boundary. Journal of Nonparametric Statistics 12(2) 197-221.
	
The four recommended methods are:

	B1 (If the input/output data are mainly, or nearly, Gaussian (average s≤1.3 and k≤3))
	B2 (If the input/output data follow moderately non-Gaussian (average 1.3< s≤5 and 3< k≤30) distributions
	R5 (If most of the input/output data follow extremely non-Gaussian (average s>5 and k>30) distributions and the problem is linear or slightly non-linear
	B7 (If most of the input/output data follow extremely non-Gaussian (average s>5 and k>30) distributions and the problem is extremely non-linear)
	
Other tested methods include:

	B3, M1, M2 (need R-Fortran), R1, R2, R3, R4, R6, C1, C2, C3, C4
	
For the detail of each method, please refer to Li et al. (2014).


	Li, X., Zecchin, A.C., Maier, H.R., 2014b. Improving Partial Mutual Information-based input variable selection by consideration of boundary issues associated with bandwidth estimation. Environmental Modelling and Software, submitted on 04/12/2014.



Download

Requirements
The software requires: 

64-bit AMD64, 64-bit Intel 64 or 32-bit x86 processor-based workstation or server with one or more single core or multi-core microprocessors ; all versions of Visual Studio 2012, 2010 and 2008 are supported except Visual Studio Express; 256 MB RAM
Operating Platform
Either PGI Visual Fortran 2003 (or later version) or Linux can be used as the operating Platform



Terms of Use:

The software is freely available to use under the terms and conditions of the Creative Commons license.
If you intend to use this software for an academic publication or report, we would appreciate your acknowledgement of the origin of the software by referencing the following article:

	Li, X., Maier, H.R., Zecchin, A.C., 2014a. Improved PMI-based input variable selection approach for artificial neural network and other data driven environmental and water resource models. Environmental Modelling and Software, accepted on 28/11/2014.
	
	Li, X., Zecchin, A.C., Maier, H.R., 2014b. Improving Partial Mutual Information-based input variable selection by consideration of boundary issues associated with bandwidth estimation. Environmental Modelling and Software, submitted on 04/12/2014.
	
	Li, X., Zecchin, A.C., Maier, H.R., 2014c. Selection of smoothing parameter estimators for general regression neural networks - Applications to hydrological and water resources modelling. Environmental Modelling and Software 59 162-186 DOI: 110.1016/j.envsoft. 2014.1005.1010.



Related Publications:

For further information on the application of artificial neural networks to water resources modeling and the methods used in their development, please refer to the following articles:

Application of General Regression Neural Networks

	Bowden G.J, Nixon J.B., Dandy G.C., Maier H.R. and Holmes M. (2006) Forecasting chlorine residuals in a water distribution system using a general regression neural network. Mathematical and Computer Modelling, 44(5-6), 469-484.
	
	Gibbs M.S., Morgan N., Maier H.R., Dandy G.C., Nixon J.B. and Holmes M. (2006) Investigation into the relationship between chlorine decay and water distribution parameters using data driven methods. Mathematical and Computer Modelling, 44(5-6), 485-498.
	
	May R.J., Dandy G.C., Maier H.R. and Nixon J.B. (2008) Application of partial mutual information variable selection to ANN forecasting of water quality in water distribution systems. Environmental Modelling and Software, 23(10-11), 1289-1299, doi:10.1016/j.envsoft.2008.03.008.
	
	May R.J., Maier H.R. and Dandy G.C. (2010) Data splitting for artificial neural networks using SOM-based stratified sampling, Neural Networks, 23(2), 283-294, doi:10.1016/j.neunet.2009.11.009.
	
	Wu W., May R.J., Maier H.R. and Dandy G.G. (2013) A benchmarking approach for comparing data splitting methods for modeling water resources parameters using artificial neural networks, Water Resources Research, 49(11), 7598-7614, DOI: 10.1002/2012WR012713.
	
Overview / Review Papers

	Maier, H.R., Jain A., Dandy, G.C. and Sudheer, K.P. (2010) Methods used for the development of neural networks for the prediction of water resource variables in river systems: Current status and future directions, Environmental Modelling & Software, 25(8), 891-909, 2010 10.1016/j.envsoft.2010.02.003.
	
	Maier H.R. and Dandy G.C. (2000) Neural networks for the prediction and forecasting of water resources variables: a review of modelling issues and applications. Environmental Modelling and Software, 15(1), 101-124.
	
	Wu W., Dandy G.C. and Maier H.R. (2014) Protocol for developing ANN models and its application to the assessment of the quality of the ANN model development process in drinking water quality modeling, Environmental Modelling and Software, 54, 108-127, http://dx.doi.org/10.1016/j.envsoft.2013.12.016.
	
Input Variable Selection

	Bowden G.J., Dandy G.C. and Maier H.R. (2005) Input determination for neural network models in water resources applications: Part 1 - Background and methodology. Journal of Hydrology, 301(1-4), 75-92.
	
	Bowden G.J., Maier H.R. and Dandy G.C.(2005) Input determination for neural network models in water resources applications: Part 2 - Case study: Forecasting salinity in a river. Journal of Hydrology, 301(1-4), 93-107.
	
	Fernando T.M.K.G., Maier H.R. and Dandy G.C. (2009) Selection of input variables for data driven models: An average shifted histogram partial mutual information estimator approach. Journal of Hydrology, 367(3-4), 165-176, doi:10.1016/j.jhydrol.2008.10.019.
	
	May R.J., Dandy G.C., Maier H.R. and Nixon J.B. (2008) Application of partial mutual information variable selection to ANN forecasting of water quality in water distribution systems. Environmental Modelling and Software, 23(10-11), 1289-1299, doi:10.1016/j.envsoft.2008.03.008.
	
Data Splitting

	Bowden G.J., Maier H.R. and Dandy G.C. (2002) Optimal division of data for neural network models in water resources applications. Water Resources Research, 38(2), 2.1-2.11.
	
	Wu W., May R.J., Maier H.R. and Dandy G.G. (2013) A benchmarking approach for comparing data splitting methods for modeling water resources parameters using artificial neural networks, Water Resources Research, 49(11), 7598-7614, DOI: 10.1002/2012WR012713.
	
ANN Training / Model Selection

	Kingston G.B., Maier H.R. and Lambert M.F. (2008) Bayesian model selection applied to artificial neural networks used for water resources modeling, Water Resources Research, 44, W04419, doi:10.1029/2007WR006155.
	
	Kingston G.B., Maier H.R. and Lambert M.F. (2006) A probabilistic method to assist knowledge extraction from artificial neural networks used for hydrological prediction. Mathematical and Computer Modelling, 44(5-6), 499-512.
	
	Kingston G.B., Lambert M.F and Maier H.R. (2005) Bayesian training of artificial neural networks used for water resources modeling. Water Resources Research, 41, W12409, doi:10.1029/2005WR004152.
	
	Kingston G.B., Maier H.R. and Lambert M.F. (2005) Calibration and validation of neural networks to ensure physically plausible hydrological modeling. Journal of Hydrology, 314(1-4), 158-176.
	
	Maier H.R. and Dandy G.C. (1999) Empirical comparison of various methods for training feedforward neural networks for salinity forecasting. Water Resources Research, 35(8), 2591-2596.
	
	Maier H.R. and Dandy G.C. (1998) The effect of internal parameters and geometry on the performance of back-propagation neural networks: an empirical study. Environmental Modelling and Software, 13(2), 193-209.
	
	Maier H.R. and Dandy G.C. (1998) Understanding the behaviour and optimising the performance of back-propagation neural networks: an empirical study. Environmental Modelling and Software, 13(2), 179-191.
	
ANN Model Deployment

Bowden G.J., Maier H.R. and Dandy G.C. (2012) Real-time deployment of artificial neural network forecasting models - understanding the range of applicability, Water Resources Research, 48(10), doi:10.1029/2012WR011984.
