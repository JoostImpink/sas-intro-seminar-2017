# Assignment


## Construct dataset

First create the following variables in Stata:

`x1`: Normally distributed with mean 1, stdev 1
`z1`: Normally distributed with mean 1, stdev 1
`e1` and `e2`: Bivariate normal distribution, mean 0, stdev 1, with correlation > 0
`y`: sum of `x1` and `e1`


### Code in Stata

```Stata
// generete x1
drawnorm x1 z1, n(1000) means(1, 1)
// generating e1 and e2
// means
matrix M = 0,0
// Variance matrix
matrix V = ( 1, 0.5 \ 0.5, 1)
// create
drawnorm e1 e2 , n(1000) cov(V) means(M)

// inspect
matrix list V
summ

// check correlation
corr e1 e2

gen y = x1 + e1
```

## Run regression, Introduce self selection

Run an OLS regression: `reg y = x1`

Create `y*`, and set it `y` if `z1+e2` is positive, otherwise zero. 

Re-run the regression on `y*`.

## Required

Explain the regression results of `y` versus `y*`.

