/*
____________________________________________________________________________________
#- Author name: Saurabh Patil                              
#- Last updated: 10/02/2017
#- Title : Transaction Data Analysis for Amazon
#- Code version: v0.04
#- Type: SAS source code
#
#- © All rights are reserved.
 ___________________________________________________________________________________
*/

LIBNAME ABA 'H:\ABA_Workspace'; RUN;

/*  Adding ID variable to train dataset */
data ABA.raw;
	set ABA.Amzntrain;
	ID=_n_;
run;

/* Adding ID variable to test dataset */
data ABA.rawTest;
	set ABA.Amzntest;
	ID=_n_;
run;

/* Merge Scoring dataset and testing dataset */
DATA combined(keep=y P_y1);
 	MERGE EMWS4.Score_SCORE BA.RAWTEST;
 	BY ID;
RUN;

/* Set the cut-off value */
DATA combined;
	SET combined;
	Pred_y=0;
	If P_y1>=0.5 THEN Pred_y=1;
RUN;

/* Confusion matrix */
PROC FREQ data=combined(keep=y Pred_y);
	table y*Pred_y / out=conf_matrix;
 	title 'Confusion Matrix for Score_score';
RUN;

/* Prediction Accuracy */
DATA conf_matrix;
	SET conf_matrix;
	Match=0;
	IF y=Pred_y THEN Match=1;
RUN;
PROC MEANS data=conf_matrix mean;
	freq count;
	var Match;
	title 'Prediction Accuracy of Score_score';
RUN;

/* Lift table*/
PROC RANK data=combined out=deciles ties=low
	descending groups=10;
	var P_y1;
	ranks decile;
RUN;
PROC SQL;
	select sum(P_y1) into: total_hits
	from combined;
	create table lift as
	select sum(P_y1)/&total_hits as true_positive_rate ,decile + 1 as decile
	from deciles
	group by decile
	order by decile;
QUIT;

/* Cumulative lift table */
DATA cum_lift;
	set lift;
	cum_positive_rate + true_positive_rate;
	cum_lift=cum_positive_rate/(decile/10);
RUN;

/* Cumulative lift chart */
PROC GPLOT data=cum_lift;
	title 'Cumulative Lift Chart';
	symbol i=spline;
	plot cum_lift*decile /grid;
RUN;
QUIT;
