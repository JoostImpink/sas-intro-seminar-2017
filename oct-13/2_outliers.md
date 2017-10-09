# Outliers, leverage points

## Winsorizing 

With winsorizing (for example at 1 and 99%) the extreme values are dampened. This is done variable-by-variable. It is however possible in a regression that an observation has 'multi-dimensional' outliers. I.e., individual values are not extreme, but 'together' they are far away from the fitted values, and thus may have a large influence on the regression coefficients. This is more likely to be the case in smaller samples.

See [Wikipedia](https://en.wikipedia.org/wiki/Cook%27s_distance).

## Detecting outliers

To detect outliers/leverage points you can utilize Cook's Distance in Stata.

```Stata
// initial regression
reg ret beta size btm bve eps at ceq 
// compute cook's distance
predict cook, cooksd, if e(sample)
// rerun regression without leverage points
// cutoff: 4 / n-k, where n is number of observations and k is #independent variables (including intercept)
// number of observations in sample dataset: 46536
reg ret beta size btm bve eps at ceq if cook < 4/ (46536-8)
```

After computing the distance, you can then filter such that observations with a large value for Cook are excluded. This is a standard sensitivity test.

## Ranked regression

Another way to deal with outliers is to use ranked regression. For each variable, all values are sorted from low to high, and the ranks (1, 2, 3, ...) are assigned in that order. Indicator variables do not need to be ranked.

The rank transformation results in a variable that has a uniform distribution (it removes distance information).

```Stata
egen ret_r = rank(ret)
egen beta_r = rank(beta)
egen size_r = rank(size)
reg ret_r beta_r size_r
```

## Decile ranked variables

Instead of doing a ranked regression (where all continuous variables are ranked), you can rank a single variable. Another approach is to compute decile ranks for a variable (first 10 percent have value 1, next 10 percent value 2, etc), and then divide it by 10 (so the values are 0.1, 0.2, ..., 1).