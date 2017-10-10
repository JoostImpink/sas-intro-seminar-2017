# Endogeneity

An endogeneity problem occurs when an explanatory variable is correlated with the error term:

- Omitted (correlated) variable
- Measurement error 
- Simultaneity (bi-directionality)
- Selection bias (self-selection) 

### Examples

Firms that diversity (conglomerates) are found to be trading at a discount relative to 'pure' play (undiversified) firms (Berger and Ofek 1995). Is diversification the cause of the discount? Not necessarily, possibly poor performing pure play firms are more likely to diversify and diversification may have created value.

The classic example in econometrics is the wage offer of married women. In entering the labor market, people only participate if the wage exceeds their 'reservation' pay. We do not observe pay data non-participating people.

Why do firms voluntary disclose bad news? Bad news disclosures reduce the stock price. However, we do not observe the counterfactual (what would stock price do if the firms did not disclose)? Potentially there is information (unobservatble to researchers), but available to (some) market participants that make managers do this. For example, non-disclosure can be used in a class-action lawsuit if investors can show management had knowledge and did not disclose. (Jenny's dissertation!)

## Dealing with selection bias

Methods to deal with selection bias:

- Propensity score matching (PSM), by finding a matched (control) firm that is closest to the treatment firm -- based on observable data
- Heckman selection model, by adding a selection model where a bias correction term is estimated which is then included in the (second stage) regression 

In Heckman the correction is based on the correlation of (unobservable) error terms; this is important so there is no need to find instruments that are correlated with the error term (instruments that explain the choice, but not explain the outcome is needed).

## Heckman selection test

The wage-offer self-selection to illustrate the mechanics of this test.

Suppose wage is modelled using education and age:

`wage = b0 + b1 education + b2 age + e1`

The problem is that wage is only available for people that participate. Workers that have withdrawn have no pay. So we need to model the selection decision, in this case whether or not to join the labor force: 

`inForce = a0 + a1 ... + a2 ... + e2`

Using a probit model, inForce is 1 if the latent inForce* is positive, and 0 otherwise (wage is missing if inForce <= 0). The independent variables in this regression are the instruments and should explain the selection but not the outcome (wage).

If `e1` and `e2` are not correlated, there would be no issue. Self selection becomes an issue if `corr(e1,e2) = rho` does not equal 0

Conditional of joining the labor force [i.e. `inForce = 1`,  wage is:

`E[wage|inForce=1] = b0 + b1 education + b2 age + E[e1 | wage, inForce = 1]`

The mechanics of the Heckman model assume that `e1` and `e2` have a bivariate normal distribution.

## Output Heckman selection test

The Heckman selection test can be done in two separate steps, or in a single step using Maximum Likelihood (ML) which is more efficient.

Software Limdep (short for limited dependent) is a well known tool to do 'exotic' regressions. The analyses can also be done with Stata ([rheckman.pdf](https://www.stata.com/manuals13/rheckman.pdf)), R ([package sampleSelection](https://cran.r-project.org/web/packages/sampleSelection/sampleSelection.pdf) and SAS. 

In Stata run:

```Stata
use "S:\_Joost\2017_methods_ufl\wages.dta", clear

// note: 1343 obs
regress wage educ age

// note: 2000 obs, higher coefficients for educ and age
heckman wage educ age, select(married children educ age)
```

Internally, Stata does note explictily estimates rho (correlation) and sigma (standard deviation of `e1`), but instead the lovely inverse hyperbolic tangent of rho (=1/2 ln [(1+p)/(1-p)]), and ln(sigma). These latter two are reported first under `/athrho` and `/lnsigma`. For convenience, Stata reports `rho`, `sigma` and `lambda` (which is the product of `rho` and `sigma`)

Not using ML but a twostep procedure instead:

```Stata
heckman wage educ age, select(married children educ age) twostep mills(mills_twostep)
```

## Test of self-selection

If the predicted inverse Mills ratio is not statistically different from 0, OLS regression results are consistent.


```Stata
// save the inverse mills estimate as mymills
heckman wage educ age, select(married children educ age) mills(mills_ML)
// t-test
ttest mymills = 0
```

## Heckman selection test using SAS

SAS dataset `wages` is the same as the Stata dataset, but with an added variable `selected` which is 1 if `wage` is nomissing, 0 otherwise (this is used in the selection step).


## Maximum Likelihood

```SAS

libname ds 'S:\_Joost\2017_methods_ufl';

proc qlim data = ds.wages ;
  model selected = married children education age /discrete;
  model wage = education age /select(selected=1);
run;
```

## Two-step

First estimate the selection estimation and capture the fitted value (xbeta):

```SAS
proc logistic data=ds.wages;
   class selected ;
   model selected (event='1') = married children education age / link=probit;
   /* xbeta is the fitted value (Xb), and can be negative, used to construct lambda (inverse Mills ratio) */
   output out=step1 xbeta=xbeta ;
   title2 'First Stage:  Probit Estimates of Selection';
   run;
quit;
```

Compute `lambda`:

```SAS
/* Compute lambda -- verify that lambda equals mills_twostep computed with Stata */
data step1;
set step1;
lambda =  pdf('NORMAL', xbeta ) / cdf('NORMAL', xbeta ); /*inverse mills ratio using xbeta (not propensity_hat)*/
run;
```

Estimate the second stage including `lambda`:

```SAS
/* Second stage -- verify with Stata twostep output (standard errors are a bit off) */
proc surveyreg data=step1 ;
   model wage=education age lambda;   
   title2 'Second Stage:  OLS Estimates of Model (with lambda)';
run; 
```