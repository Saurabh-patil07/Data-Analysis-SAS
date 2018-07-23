
/* Data pre-processing: To remove negative values from age and net sales */
data Project.tgif1;
	set Project.tgif;
	if age <=0 then delete;
	if net_sales_tot <=0 then delete;
run;

/* Regression to check variable significance */
proc reg data=Project.tgif1;
model net_sales_tot = email_open_rate disc_chan_gps disc_chan_value 
disc_pct_tot net_amt_p_item  
fd_cat_alcoh fd_cat_app fd_cat_burg fd_cat_h_ent fd_cat_kids fd_cat_l_ent fd_cat_side fd_cat_soupsal 
fd_cat_steak 
tenure_day age ;
run;

/*   Segmentation - total no. of clusters 5 */
proc fastclus data = project.tgif1
maxclusters = 5 maxiter = 20 out = Project.clusresults ;
var email_open_rate disc_chan_gps disc_chan_value 
disc_pct_tot net_amt_p_item  
fd_cat_alcoh fd_cat_app fd_cat_burg fd_cat_h_ent fd_cat_kids fd_cat_l_ent fd_cat_side fd_cat_soupsal 
fd_cat_steak 
tenure_day age ;
run;

proc sort data = Project.clusresults ;
by cluster ;
run ;

proc means data = Project.clusresults ;
by cluster ;
run ;
