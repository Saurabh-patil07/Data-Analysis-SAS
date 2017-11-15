/*
____________________________________________________________________________________
#- Author name: Saurabh Patil                              
#- Last updated: 11/13/2017
#- Title : Customer Behaviour Analysis for Barnes and Noble
#- Code version: v0.02
#- Type: SAS source code
#
#- © All rights are reserved.
 ___________________________________________________________________________________
*/

LIBNAME ABA 'H:\ABA_Workspace\ABA_Project'; RUN;

/* Import given dataset */
proc import datafile='H:\ABA_Workspace\ABA_Project\ABI_Project2_data_books.csv'
     out=ABA.book2
     dbms='CSV';
RUN;

proc import datafile='H:\ABA_Workspace\ABA_Project\rawdata.xlsx'
     out=ABA.social;
RUN;

/* Poisson regression */
data book_new ;
set aba.social;
lna = log(age);
run;

  proc genmod data=book_new;
      class income education region hhsz race;
      model lcount = income education age country region hhsz child race/ dist= poisson
                                offset = lna
                                link   = log dscale ;                       
  run;

/* Negative Binomial Regression (NBD)  */
 proc genmod data = book_new;
  class income education region hhsz race (param=ref ref=first);
  model lcount = income education age country region hhsz child race / type3 dist=negbin;
run;

/* Adding new column BN to all customers count data (BN=1 for barnesandnoble and BN=0 for amazon.com ) */
proc sql;
   create table aba.allcust as
select userid, 
SUM(CASE WHEN domain="barnesandn" and qty > 0 THEN 1 ELSE 0 END)         as count 'count', 
avg(income) as income 'income', 
avg(age) as age 'age',
avg(education) as education 'education',
avg(hhsz) as hhsz 'hhsz',
avg(child) as child 'child',
avg(race) as race 'race',
avg(country) as country 'country',
min(region) as region 'region'
from aba.book2
group by userid ;
order by userid ;
quit;

proc import datafile='E:\Users\sap160730\Downloads\books_allcust.csv'
     out=aba.allcust
     dbms='CSV';
RUN;

data aba.allcust;
	set aba.allcust;
	bn=0;
	if count ne 0 then bn=1;
run;

proc means data=aba.allcust; run;
proc contents data=aba.allcust; run;

/* Logistic regresion*/
proc logistic descending data = aba.allcust;
class region;
model bn = income education age region country hhsz child race/  
pprob=  0.1917 ctable;					/* Mean of dependent variable (bn) = 0.1917 */
output out = logit_pred p = phat;
run;
