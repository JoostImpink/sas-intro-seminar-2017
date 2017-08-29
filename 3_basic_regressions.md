# Basic regressions


## OLS

Example of a basic OLS regression:

```SAS
proc reg data=f_sample_wins;   
  model ret = beta size btm bve eps;  
quit;
```

Same regression, using `proc surveyreg` which gives robust standard errors by default:

```SAS
proc surveyreg data=f_sample_wins;   
  model ret = beta size btm bve eps;
  ods output 	
    ParameterEstimates = _surv_params 
    FitStatistics = _surv_fit
    DataSummary = _surv_summ;
quit;
```

### Year and industry effects

Variable 'fyear' holds the year, and 'ff12_' holds a number. With the `class` statement (and including 'fyear' and 'ff12_' as variables), SAS makes indicator variables for each year and each industry.

Run the following regression (note the change in R-squared):

```SAS
proc surveyreg data=f_sample_wins;   
  class fyear ff12_;
  model  ret = beta size btm bve eps fyear ff12_;
  ods output  
    ParameterEstimates = _surv_params 
    FitStatistics = _surv_fit
    DataSummary = _surv_summ;
quit;
```


### By group

Often you may need to do an OLS regression by group. The group can be the firm (like monthly returns to estimate beta, which is firm specific), by year, or industry (or both, industry-year). In that case, add the `BY` clause (the dataset needs to be sorted first):

```SAS
proc sort data=f_sample_wins; by fyear;run;
proc reg outest=_reg_params2 data=f_sample_wins;   
  model ret = beta size btm bve eps ff12_1 - ff12_12 / noprint ;
  by fyear;
run;

```


## Logistic regression

The output for a logistic regression (where the dependent variable is binary) is spread out over 7 tables. See the following macro that takes the dependent variable and independent variables as argument, but has year and industry effects hard-coded:


## Example

The output of a logistic regression is spread over 7 tables. Using ODS output these are captured. See ODS manual for other possible output: [https://support.sas.com/documentation/cdl/en/statug/63033/HTML/default/viewer.htm#statug_logistic_sect049.htm](https://support.sas.com/documentation/cdl/en/statug/63033/HTML/default/viewer.htm#statug_logistic_sect049.htm)

> Note: Each proc has its own ODS output table names

```SAS
/* logistic regression: let's predict losses */
	proc logistic data=myData descending  ;
	  model LOSS = MTB SIZE GROWTH  d2004-d2013 ff12_1-ff12_12 / RSQUARE SCALE=none ;
	  /* out= captures fitted, errors, etc */
	  output out = logistic_predicted  PREDICTED=predicted ;
	  	ods output	
          ParameterEstimates = _outp1
          OddsRatios = _outp2
          Association = _outp3
          RSquare = _outp4
          ResponseProfile = _outp5
          GlobalTests = _outp6			
          NObs = _outp7 ;
	quit;
```

## Example using macros

```SAS
/* logistic regression: let's predict losses */
%macro doLogistic(dsin=, dep=, vars=);
	proc logistic data=&dsin descending  ;
	  model &dep = &vars  d2004-d2013 ff12_1-ff12_12 / RSQUARE SCALE=none ;
	  /* not needed here, but out= captures fitted, errors, etc */
	  output out = logistic_predicted  PREDICTED=predicted ;
	  	ods output	
          ParameterEstimates = _outp1
          OddsRatios = _outp2
          Association = _outp3
          RSquare = _outp4
          ResponseProfile = _outp5
          GlobalTests = _outp6			
          NObs = _outp7 ;
	%runquit;
%mend;

/* helper macro to export the 7 tables for each logistic regression */
%macro exportLogit(j, k);
	%myExport(dset=_outp1, file=&exportDir\logistic_&j._&k._coef.csv);
	%myExport(dset=_outp2, file=&exportDir\logistic_&j._&k._odds.csv);
	%myExport(dset=_outp3, file=&exportDir\logistic_&j._&k._assoc.csv);
	%myExport(dset=_outp4, file=&exportDir\logistic_&j._&k._rsqr.csv);
	%myExport(dset=_outp5, file=&exportDir\logistic_&j._&k._response.csv);
	%myExport(dset=_outp6, file=&exportDir\logistic_&j._&k._globaltest.csv);
	%myExport(dset=_outp7, file=&exportDir\logistic_&j._&k._numobs.csv);
%mend;

/* set exportDir */
%let ExportDir = M:\;
```
You can then run different specifications and have the results written to disk (7 files per regression):

```SAS
/* run model 1 */
%doLogistic(dsin=h_large, dep=loss, vars=ret beta size btm );
%exportLogit(t1,col1);

/* run model 2 */
%doLogistic(dsin=h_large, dep=loss, vars=ret beta_lag size_lag btm_lag );
%exportLogit(t1,col2);
```

