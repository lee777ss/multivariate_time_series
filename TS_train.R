library(caret)
library(dtw) # this needs to be loaded to use dist function with method="DTW"
library(C50) # C5.0 decision tress
library(gmodels) # crosstable
library(kernlab)  # SVM (Support Vector Machine)


## import Data

setwd("C:/Users/Wonjae Lee/OneDrive - University of Missouri/01_Mizzou/00_Research/00_QCRE Data Challege 2019/04_Submission/R/TS")
ts <- read.csv("processminer-rare-event-mts.csv", 
               stringsAsFactors = FALSE)

ts_var <- data.matrix(ts[,c(-1,-2)])

diff1 <- matrix(nrow = nrow(ts_var), ncol = ncol(ts_var))
diff2 <- matrix(nrow = nrow(ts_var), ncol = ncol(ts_var))


for (i in 1:ncol(ts_var)) {
  
  diff1[,i] <- c(0, diff(ts_var[,i], leg = 1, differneces = 1))
  
  diff2[,i] <- c(0, 0, diff(ts_var[,i], leg = 1, differences = 2))
} 

ts_diff <- cbind(ts, diff1, diff2)


# Choosing data

ts <- ts_diff[,c(1,2,125:185)] # diff2

# Dividing Data

ts_train <- ts
# ts_test2 <- ts[(round(nrow(ts)*0.9)+1):nrow(ts),]  # 10# of the orginal data


# Choosing y, y-1, y-2

new_y <- c(ts_train$y[2:nrow(ts_train)], 0) # moving column y up by 1
ts_train$y <- c(ts_train$y[2:nrow(ts_train)], 0)
# ts_test$y <- c(ts_test$y[2:nrow(ts_test)], 0)

# ts_train


t <- 20 # window size
n <- 500 # the number of windows
# when t =10, got the same result betwen n = 500 and n = 1000
num_y <- sum(new_y)
first_y <- which(new_y == 1)[1]
ts_train_61 <- ts_train[,-c(1,2)]

window_list <- list()
predict_list <- list()
actual_list <- list()

for (m in 1:ncol(ts_train_61)) {
  # for (m in 1:1) {
  
  x <- data.frame(ts_train_61[,m])
  
  # Generating windows when y is 1
  a <- 1 # counter
  
  if (t < first_y) { # In case window size t is less than the first y
    window_y <- matrix(nrow = num_y, ncol = t) # 113 x 50 matrix
    for (i in first_y:length(new_y)) {
      if (new_y[i] == 1) {
        # if (sum(new_y[(i-t+1):i]) == 1) { # In case there are more than one y=1, we ignore that window
        window_y[a,] <- x[(i-t+1):i,]
        # }
        a <- a + 1
      }
    }
  } else { # In case window size t is more than the first y, first y is ignored
    window_y <- matrix(nrow = (num_y-1), ncol = t)
    for (i in (first_y+1):length(new_y)) {
      if (new_y[i] == 1) {
        # if (sum(new_y[(i-t+1):i]) == 1) { # In case there are more than one y=1, we ignore that window
        window_y[a,] <- x[(i-t+1):i,]
        # }
        a <- a + 1
      }
    }
  }
  
  # index_NA <- which(is.na(window_y[,1]))
  # window_y <- window_y[-c(index_NA),]
  
  # Generating random n windows when y is zero which are not overlapped with window_y
  
  set.seed(1234)
  
  s <- sample((1+t):(nrow(ts_train_61)-t), n, replace = F) # s: n random observation
  
  window_ran <- matrix(nrow = n, ncol = t) # n: the number of windows, t: window size
  
  for (i in 1:length(s)) {
    if (sum(new_y[(s[i]-(t-1)):(s[i]+t)]) == 0) { # select the windows which do not have y = 1 ranging from -t to +t
      window_ran[i,] <- x[(s[i]-(t-1)):s[i],]
    }
    
  }
  
  index_NA <- which(is.na(window_ran[,1]))
  window_r <- window_ran[-c(index_NA),]
  
  # Combining widows (windows for y = 1 + windows for y = 0)
  window_t <- data.frame(rbind(window_y, window_r))
  
  # making the length of window_t a multiple of 10
  
  rm <- nrow(window_t) %% 10
  
  window_t <- window_t[1:(nrow(window_t)-rm),]
  
  
  window_list[[m]] <- window_t
  
  
  # Generating classId
  classId <- c(rep(1, nrow(window_y)), rep(0, (nrow(window_t) - nrow(window_y))))
  
  # 10-fold Cross Validation
  set.seed(1024)
  folds <- createFolds(classId) # creating 10-folds
  
  k <- 1 # 1-NN
  
  predict <- matrix(nrow = length(folds), ncol = length(folds[[1]]))
  actual  <- matrix(nrow = length(folds), ncol = length(folds[[1]]))
  
  
  for (j in 1:length(folds)) {
    
    window_test <- window_t[folds[[j]],]
    
    window_train <- window_t[-folds[[j]],]
    classId_train <- classId[-folds[[j]]]
    
    # predicted data
    
    for (i in 1:nrow(window_test)) {
      
      newTS <- window_test[i,]
      distances <- dist(newTS, window_train, method="euclidean")
      # newTs: test data, data: existing data (model)
      # distances <- dist(newTS, window_train, method="DTW")
      # DTW takes too much time compared to euclidean. I gave up after one and half hours
      
      s <- sort(as.vector(distances), index.return=TRUE) # s$x, s$ix after doing "sort" function
      predict[j,i] <- classId_train[s$ix[1:k]]
      
    }
    
    actual[j,] <- classId[folds[[j]]]
  }
  
  predict_list[[m]] <- as.factor(predict)
  
  actual_list[[m]] <- as.factor(actual)
  
}

predict_matrix <- do.call(cbind, predict_list)

predict_matrix <- predict_matrix -1

actual_matrix <- do.call(cbind, actual_list)

actual_matrix <- actual_matrix -1

confusionMatrix(as.factor(predict_matrix[,2]), as.factor(actual_matrix[,2]))
