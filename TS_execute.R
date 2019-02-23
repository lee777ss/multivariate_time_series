# install R software

# install R Studio

# open "TS" R project

# open "TS_execute.R" file

# install packages in case packages belows are not installed on your computer

install.packages("caret")
install.packages("dtw")
install.packages("C50")
install.packages("gmodels")
install.packages("kernlab")
install.packages("e1071")

# Use "setwd" function to set working directory where the test file (*.csv) is located
setwd("C:/Users/Wonjae Lee/OneDrive - University of Missouri/01_Mizzou/00_Research/00_QCRE Data Challege 2019/04_Submission/R/TS")

# implement the "my_test" function with your file name
my_test("test.csv")

# check the result (precision, recall, FPR, F-measure)

