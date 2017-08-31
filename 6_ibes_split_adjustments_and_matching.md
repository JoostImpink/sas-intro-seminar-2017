# Matching with IBES: Comparing `%ICLINK` with matching on CUSIP

## Match using gvkey-permno-cusip

Run the macro `getFundaWithIBESTicker` (included in [/macros/getFundaWithIBESTicker.sas](macros/getFundaWithIBESTicker.sas))

```SAS
%getFundaWithIBESTicker(dsout=a_funda_ibes, fundaVars=at sale ceq);
```

The output dataset will hold the common firm identifiers (gvkey, permno, cusip, ibes_ticker). 

Matching:

- gvkey is used to get permno using the CCM linktable
- permno is used to get Cusip using linktable crsp.dsenames 
- Cusip is used to get ibes_ticker using linktable ibes.idsum

#### Question: by year, which percentage of the firms have missing permno, missing cusip, and missing ibes_ticker?

## Match on firm name and ticker symbol

#### Question: for firms with missing ibes_ticker using gvkey-permno-cusip, attempt to match these firms by company name and ticker symbol.


> Hint: First inspect crsp.dsenames and ibes.idsum - does the company name change over time (showing the historical names), or does it show the current company name (like in Funda)?


