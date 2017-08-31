/* 
	This macro creates a dataset based on Funda and adds permno, cusip and ibes_ticker

*/

%macro getFundaWithIBESTicker(dsout=, fundaVars=, year1=2010, year2=2015);

/* having an empty rsubmit-endrsubmit forces the connection to either pass or fail */
rsubmit;endrsubmit;
%let wrds = wrds.wharton.upenn.edu 4016;options comamid = TCP remote=WRDS;signon username=_prompt_;

/* syslput pushes macro variables to the remote connection */
%syslput dsout = &dsout;
%syslput year1 = &year1;
%syslput year2 = &year2;
%syslput fundaVars = &fundaVars;

rsubmit;

/* Funda data */
data getf_1 (keep = key gvkey fyear datadate sich &fundaVars);
set comp.funda;
if &year1 <= fyear <= &year2;
if indfmt='INDL' and datafmt='STD' and popsrc='D' and consol='C' ;
key = gvkey || fyear;
run;

/* if sich is missing, use the one of last year (note sorted descending by fyear) */
data getf_1 (drop = sich_prev);
set getf_1;
retain sich_prev;
by gvkey;
if first.gvkey then sich_prev = .;
if missing(sich) then sich = sich_prev;
sich_prev = sich;
run;

/* Permno as of datadate*/
proc sql; 
  create table getf_2 as 
  select a.*, b.lpermno as permno
  from getf_1 a left join crsp.ccmxpf_linktable b 
    on a.gvkey eq b.gvkey 
    and b.lpermno ne . 
    and b.linktype in ("LC" "LN" "LU" "LX" "LD" "LS") 
    and b.linkprim IN ("C", "P")  
    and ((a.datadate >= b.LINKDT) or b.LINKDT eq .B) and  
       ((a.datadate <= b.LINKENDDT) or b.LINKENDDT eq .E)   ; 
quit; 

/* retrieve historic cusip */
proc sql;
  create table getf_3 as
  select a.*, b.ncusip
  from getf_2 a left join crsp.dsenames b
  on 
        a.permno = b.PERMNO
    and b.namedt <= a.datadate <= b.nameendt
    and b.ncusip ne "";
  quit;
 
/* force unique records */
proc sort data=getf_3 nodupkey; by key;run;
 
/* get ibes ticker */
proc sql;
  create table getf_4 as
  select distinct a.*, b.ticker as ibes_ticker
  from getf_3 a left join ibes.idsum b
  on 
        a.NCUSIP = b.CUSIP
    and a.datadate > b.SDATES ;
quit;

/* force unique records */
proc sort data=getf_4 nodupkey; by key;run;

proc download data=getf_4 out = &dsout;run;

endrsubmit;

%mend;
