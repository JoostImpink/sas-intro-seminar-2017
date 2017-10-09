# Endogeneity

An endogeneity problem occurs when an explanatory variable is correlated with the error term:

- Omitted (correlated) variable
- Measurement error 
- Simultaneity (bi-directionality)
- Selection bias (self-selection) 

Examples:

Firms that diversity (conglomerates) are found to be trading at a discount relative to 'pure' play (undiversified) firms (Berger and Ofek 1995). Is diversification the cause of the discount? Not necessarily, possibly poor performing pure play firms are more likely to diversify and diversification may have created value.

The classic example in econometrics is the wage offer of married women. In entering the labor market, people only participate if the wage exceeds their 'reservation' pay. We do not observe pay data non-participating people.

Why do firms voluntary disclose bad news? Bad news disclosures reduce the stock price. However, we do not observe the counterfactual (what would stock price do if the firms did not disclose)? Potentially there is information (unobservatble to researchers), but available to (some) market participants that make managers do this. For example, non-disclosure can be used in a class-action lawsuit if investors can show management had knowledge and did not disclose. (Jenny's dissertation!)

## Dealing with selection bias

Methods to deal with selection bias:

- Propensity score matching (PSM), by finding a matched (control) firm that is closest to the treatment firm -- based on observable data
- Heckman selection model, by adding a selection model where a bias correction term is estimated which is then included in the (second stage) regression



## Heckman selection test

The wage-offer self-selection to illustrate the mechanics of this test.

Suppose wage is modelled using education and age:

Wage: `wage = b0 + b1 education + b2 age + e1`

The problem is that wage is only available for people that participate. Workers that have withdrawn have no pay. The above regression is the joint model of:


Laborforce: `inForce = a0 + a1 ... + a2 ... + e2`, inForce = 1 if inForce > 0, and 0 otherwise (wage is missing if inForce <= 0) - the independent variables in this regression are the instruments and should explain the selection but not the outcome (wage)

If `e1` and `e2` are not correlated, there would be no issue. Self selection becomes an issue if `corr(e1,e2) = rho` does not equal 0

Under the assumption that `e1` and `e2` have a bivariate normal distribution, conditional of joining the labor force wage is:

E[wage|inForce=1] = b0 + b1 education + b2 age + E[e1 | wage, inForce = 1]



## Output Heckman selection test

The Heckman selection test can be done in two separate steps, or in a single step using Maximum Likelihood (ML) which is more efficient.

Software `Limdep` (short for limited dependent) is a well known tool to do 'exotic' regressions. The analyses can also be done with Stata ([rheckman.pdf](https://www.stata.com/manuals13/rheckman.pdf)), R ([package sampleSelection](https://cran.r-project.org/web/packages/sampleSelection/sampleSelection.pdf) and SAS. 

In Stata run:

```
use "S:\_Joost\2017_methods_ufl\wages.dta", clear

// note: 1343 obs
regress wage educ age

// note: 2000 obs, higher coefficients for educ and age
heckman wage educ age, select(married children educ age)
```

Internally, Stata does note explictily estimates rho (correlation) and sigma (standard deviation of `e1`), but instead the lovely inverse hyperbolic tangent of rho (=1/2 ln [(1+p)/(1-p)]), and ln(sigma). These latter two are reported first under `/athrho` and `/lnsigma`. For convenience, Stata reports `rho`, `sigma` and `lambda` (which is the product of `rho` and `sigma`)

Not using ML but a twostep procedure instead:

```
heckman wage educ age, select(married children educ age) twostep
```

## Test of self-selection

If the predicted inverse Mills ratio is not statistically different from 0, OLS regression results are consistent.


```
// save the inverse mills estimate as mymills
heckman wage educ age, select(married children educ age) mills(mymills)
// t-test
ttest mymills = 0
```

