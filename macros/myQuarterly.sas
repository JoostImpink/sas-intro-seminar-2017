/* 
	Use this macro to create a 'starting' dataset based on Funda and Fundq

	invoke as:
	%myQuarterly(dsout=a_funda1, fundaVars=at sale ceq csho prcc_f, fundQvars = niq atq saleq,  year1=1990, year2=2015);

*/

%macro myQuarterly(dsout=, fundaVars=, fundqVars=, year1=2006, year2=2015);

  /* having an empty rsubmit-endrsubmit forces the connection to either pass or fail */
  rsubmit;endrsubmit;
  %let wrds = wrds.wharton.upenn.edu 4016;options comamid = TCP remote=WRDS;signon username=_prompt_;

  /* syslput pushes macro variables to the remote connection */
  %syslput dsout = &dsout;
  %syslput year1 = &year1;
  %syslput year2 = &year2;
  %syslput fundaVars = &fundaVars;
  %syslput fundqVars = &fundqVars;

  rsubmit;

    /* Funda data */
    data getf_1 (keep = firmYear gvkey fyear datadate sich &fundaVars);
    set comp.funda;
    if &year1 <= fyear <= &year2;
    if indfmt='INDL' and datafmt='STD' and popsrc='D' and consol='C' ;
    firmYear = gvkey || fyear;
    run;

    /* 	Keep first record in case of multiple records; */
    proc sort data =getf_1 nodupkey; by gvkey descending fyear;run;

    /* if sich is missing, use the one of last year (note sorted descending by fyear) */
    data getf_1 (drop = sich_prev);
    set getf_1;
    retain sich_prev;
    by gvkey;
    if first.gvkey then sich_prev = .;
    if missing(sich) then sich = sich_prev;
    sich_prev = sich;
    run;

    /* fundQ */
    data getf_2 (keep = firmYear firmQuarter fqtr &fundqVars);
    set comp.fundq;
    if &year1 <= fyearq <= &year2;
    if indfmt='INDL' and datafmt='STD' and popsrc='D' and consol='C' ;
    firmYear = gvkey || fyearq;
    firmQuarter = gvkey || fyearq || fqtr;
    run;

    /* join */
    proc sql;
      create table getf_3 as select a.*, b.* from getf_1 a, getf_2 b where a.firmYear = b.firmYear;
    quit;

    /* force unique records */
    proc sort data=getf_3 nodupkey; by firmQuarter;run;

    proc download data=getf_3 out = &dsout;run;

  endrsubmit;

%mend;
