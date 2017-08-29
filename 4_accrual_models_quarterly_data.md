# Accrual models using quarterly data

## Modified Jones Model

Inspect the abnormal accrual code to estimate the Modified Jones Model at [https://github.com/JoostImpink/earnings_management/blob/master/earnings_management_models.sas](https://github.com/JoostImpink/earnings_management/blob/master/earnings_management_models.sas) 

## Main dataset

Abnormal accruals are estimated by industry; since Fundamental Quarterly doesn't include the industry code, we need to join with Fundamental Annual.

Run the [macro code](macros/myQuarterly.sas) and invoke it:

```SAS
%myQuarterly(dsout=a_fundq);
```

> Note: this macro forward-fills missing SICH codes (otherwise roughly 30% of the observations would be dropped because of missing industry code)


The following code invokes the macro with just a few variables:

```SAS
%myQuarterly(dsout=mydata, fundaVars=ni sale at, fundqVars=niq saleq atq);
```


## Assignment

Adapt the code to estimate using industry-quarters. 

> Note: The variable names for Fundamental Quarterly are usually the same as for Annual, but with an added `Q` (for example, `NIQ` instead of `NI`)

