// load the dataset
use "S:\_Joost\2017_methods_ufl\sample_dataset.dta", clear

// make time-series
destring  gvkey, replace
tsset gvkey fyear

// Generate dummy variables
tabulate fyear, gen(dfyear)
tabulate ff12_, gen(dff12_)

// Summary statistics
sum ret beta // summary statistics
sum eps, d // detailed summary statistics
tab fyear // number of obs by year
tabstat ret beta size btm bve eps, stats (n mean min p25 p50 p75 max sd) col(stat) 

// OLS regression
reg ret beta size btm bve eps

// To install:
findit eststo // click on the link for 'st0085_1', then 'click here to install'

// Example: results for two different models exported to a csv file (you can actually click on the link)

eststo clear
eststo: reg ret beta size btm bve eps 
eststo: reg ret beta size btm bve eps dfyear*
esttab using M:\stata_output_table.csv, b(3) t(2) drop(dfyear*) star(* 0.10 ** 0.05 *** 0.01) r2

// fixed firm effects and year dummies
xtreg ret beta size btm bve eps dfyear* , fe vce(cluster gvkey)

// Logistic regression
logit loss beta size btm bve if fyear > 2012, asis robust cluster(gvkey)

// Compare the regression results of `reg` with `cluster2`:
reg ret beta size btm bve eps
cluster2 ret beta size btm bve eps, fcluster(gvkey) tcluster(fyear)