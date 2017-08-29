# Dealing with dates

## Importing a txt file with a date

File: (datasets/volume.txt)[datasets/volume.txt] contains the following data: 

```
Permno|Date|vol_bmo|vol_amc|rev_bmo|rev_amc
87604|2005/01/10|0|914|0|1919.4
90925|2009/01/20|0|401627|0|6552574.728
89044|2011/02/04|0|10791|0|61088.55
81564|2005/07/07|0|423|0|26128.71
13777|2011/06/02|100|469|731|3428.39
11884|2011/09/16|0|108770|0|1704129.5253
89960|2011/05/26|100|5881|2784|163219.96
39917|2013/03/28|100|543640|3100|17058632.4011
92205|2011/02/24|300|50298|3582|618259.2675
```

Download and save this file into a folder, for example `C:\temp`.

```SAS
filename MYFILE "C:\temp\volume.txt";

/* load dataset */
data myData;
infile MYFILE dsd delimiter="|"  firstobs=2 LRECL=32767 missover;
length date_temp $ 10;
input Permno Date_temp $  vol_bmo vol_amc rev_bmo rev_amc;
run;

/* convert date from string to date format */
data myData (drop = date_temp);
set myData;
date = input(date_temp, YYMMDD10.);
format date date9.;
run;
```

> Note: the import does not work if in the first datastep the date format is used (instead of the $10 format); hence the import is split over two datasteps. The first one loads the date as a string, the second one converts the string to a date.

## Other date formats

Similarly, a dataset that has dates in a format like MMDDYYYY can be imported.

```SAS
data myDates;
date = "08242017"; output;
date = "07111972"; output;
run; 

data myDates2;
set myDates;
date2 = input(date, MMDDYY8.);
format date2 date9.;
run;
```

### Overview

See the SAS manual for an overview of various Date formats: [https://v8doc.sas.com/sashtml/lrcon/zenid-63.htm](https://v8doc.sas.com/sashtml/lrcon/zenid-63.htm)


### Format vs informat

"SAS Formats and Informats. An informat is a specification for how raw data should be read. A format is a layout specification for how a variable should be printed or displayed. SAS contains many internal formats and informats, or user defined formats and informats can be constructed using PROC FORMAT.", see [http://www.pauldickman.com/teaching/sas/formats.php](http://www.pauldickman.com/teaching/sas/formats.php)

