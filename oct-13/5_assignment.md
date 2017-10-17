# Assignment


## Construct dataset

First create the following variables in Stata:


`z1`: Normally distributed with mean 0, stdev 1
`e1` and `e2`: Bivariate normal distribution, mean 0, stdev 1, with correlation > 0

`x1`: Normally distributed with mean 0.5, stdev 1, correlation `e2` > 0
`y`: sum of `x1` and `e1`


### Code in Stata

```Stata
// generete z1
drawnorm z1, n(1000) 
// generating e1, e2, and x1
// means
matrix M = 0, 0, 0.5
// e1 and e2 highly correlated, x1 correlated with e2 (not e1)
matrix V = ( 1, 0.75 , 0 \ 0.75, 1, 0.5 \ 0, 0.5, 1)
// create
drawnorm e1 e2 x1, n(1000) cov(V) means(M)

// inspect
matrix list V
summ
corr 
```

## Introduce self selection

Create `y*`, and set it `y` if `z1+e2` is positive, otherwise zero. 

```Stata
// dependent variable 
gen y = x1 + e1
// create self-selection 
gen ystar = y
replace ystar = . if z1 + e2 < 0
```

## Required

Run OLS regressions: `reg y x1` and `reg ystar x1` and explain the regression results of `y` versus `y*`. Use the Heckman procedure to control for self-selection.

