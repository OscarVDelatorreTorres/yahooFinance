# This function is a wrape and alterative of the merge function in the base R library.
# The purpose of this function is to merge two data frames by a common column: the first one.
# Because this function is part of an R quantitative library, the first columns of both data.frames
# must be a date vector. 

#I created the first version of the mergeTSDataFrames function to merge two multivariate 
# data.frames with different or equal periodicities

mergeTSDataFrame=function(df1,df2,timeUnits){
  # Check if the first column of both data frames is a date vector
  if (!inherits(df1[[1]], "Date") || !inherits(df2[[1]], "Date")) {
    stop("Atention! The first column of both data frames must be a date vector.")
  }
  
  # Convert the first column of both data frames to the same format
  df1[[1]] <- as.Date(df1[[1]])
  df2[[1]] <- as.Date(df2[[1]])
  getOption("lubridate.week.start", 7)
  
  nDates=nrow(df1)
  df1[[1]]=floor_date(df1[[1]],unit=timeUnits,week_start=7) 
  merged_df=cbind(df1,data.frame(matrix(NA,nrow=nDates,ncol=ncol(df2)-1)))
  colnames(merged_df)=c(names(df1),colnames(df2)[-1])
  mergedDfStartCol=ncol(df1)+1
  
  # Fill the merged data frame with the values from df1
  for (a in 1:nDates){
    merged_df[a,mergedDfStartCol:ncol(df2)]=tail(df1[max(which(df2[,1]<=df2[a,1])),2:ncol(df2)],1)
  }
  
  # If there are remaining NA values in the merged data frame, 
  # fill them with the last non-NA value:
  for (a in 2:ncol(merged_df)){
    merged_df[,a]=na_locf(merged_df[,a])
  }
  
  # Return the merged data frame
  return(merged_df)
}



