

# test data to evaluate the model
my_test <- function(.csv) {
  
  # implement the library belows
  library(caret)
  library(dtw) # this needs to be loaded to use dist function with method="DTW"
  library(C50) # C5.0 decision tress
  library(gmodels) # crosstable
  library(kernlab)  # SVM (Support Vector Machine)
  
  # ts_test
  
  ts <- read.csv(.csv, stringsAsFactors = FALSE)
  
  ts_var <- data.matrix(ts[,c(-1,-2)])
  
  diff1 <- matrix(nrow = nrow(ts_var), ncol = ncol(ts_var))
  diff2 <- matrix(nrow = nrow(ts_var), ncol = ncol(ts_var))
  
  
  for (i in 1:ncol(ts_var)) {
    
    diff1[,i] <- c(0, diff(ts_var[,i], leg = 1, differneces = 1))
    
    diff2[,i] <- c(0, 0, diff(ts_var[,i], leg = 1, differences = 2))
  } 
  
  ts_diff <- cbind(ts, diff1, diff2)
  
  # write.csv(ts_diff,"ts_diff.csv")
  
  # Choosing data
  
  ts <- ts_diff[,c(1,2,125:185)] # diff2
  
  ts_test <- ts
  
  # Choosing y, y-1, y-2
  
  # new_y <- c(ts_train$y[2:nrow(ts_train)], 0) # moving column y up by 1
  # ts_train$y <- c(ts_train$y[2:nrow(ts_train)], 0)
  ts_test$y <- c(ts_test$y[2:nrow(ts_test)], 0)
  
  
  ts_test_61 <- ts_test[,-c(1,2)]
  
  predict_t2 <- matrix(nrow = (nrow(ts_test_61) - t + 1), ncol = ncol(ts_test_61))
  
  for (m in 1:ncol(ts_test_61)) {
    
    # for (m in 1:3) {
    
    x <- data.frame(ts_test_61[,m])
    
    # Generating test window: window_t2
    
    window_t2 <- data.frame(matrix(nrow = (nrow(x) - t + 1), ncol = t))
    
    a <- 1 # counter
    
    for (i in t:nrow(x)) {
      window_t2[a,] <- x[(i-t+1):i,]
      a <- a + 1
    }
    
    
    for (i in 1:nrow(window_t2)) {
      
      newTS <- window_t2[i,]
      distances <- dist(newTS, window_list[[m]], method="euclidean") 
      s <- sort(as.vector(distances), index.return=TRUE) # s$x, s$ix after doing "sort" function
      predict_t2[i,m] <- classId[s$ix[1:k]] 
      
    }
    
  }
  
  # Decision Tree
  
  
  predict_matrix <- as.data.frame(predict_matrix)
  predict_t2 <- as.data.frame(predict_t2)
  
  col_name <- paste("x", 1:ncol(predict_matrix), sep="")
  
  names(predict_matrix) <- col_name
  names(predict_t2) <- col_name
  
  # cost matrix
  matrix_dimensions <- list(c(0,1), c(0,1))
  names(matrix_dimensions) <- c("predicted", "actual")
  error_cost <- matrix(c(0,1,5,0), nrow =2, dimnames = matrix_dimensions)
  
  # no option
  # model <- C5.0(predict_matrix, as.factor(actual), costs = NULL)
  
  # boosting
  # model <- C5.0(predict_matrix, as.factor(actual), trials = 10, costs = NULL)
  
  # boosting & cost matrix
  model <- C5.0(predict_matrix, as.factor(actual), trials = 10, costs = error_cost)
  
  
  ts_predict <- predict(model, predict_t2)
  
  ts_actual <- ts_test$y[(t):nrow(ts_test)]
  
  # ts_predict: final from decision tree
  confu <- confusionMatrix(as.factor(ts_predict), as.factor(ts_actual))
  confu
  
  # predict_t2: 1NN result, which has the results of all variables
  # confusionMatrix(as.factor(predict_t2[,2]), as.factor(ts_actual))
  
  # precision
  precision <- posPredValue(as.factor(ts_predict), as.factor(ts_actual), positive = 1)
  print(c("precision is ", round(precision,2)))
  
  # sensitivity = recall
  recall <- sensitivity(as.factor(ts_predict), as.factor(ts_actual), positive = 1)
  print(c("recall is ", round(recall,2)))
  
  
  # False positive rate
  TN <- confu$table[1,1]
  FP <- confu$table[2,1]
  FPR <- FP / (FP + TN)
  print(c("FPR is ", round(FPR,2)))
  
  
  # F-measure
  f_measure <- (2*precision*recall)/(recall+precision)
  print(c("f_measure is ", round(f_measure,2)))
  
  
}



