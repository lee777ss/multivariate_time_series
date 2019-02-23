Data Challenge Report

Problem description 
A multivariate time series (MTS) is produced when multiple interconnected streams of data are recorded over time. They are commonly found in manufacturing processes that have several interconnected sensors collecting the data in over time. In this problem, we have a similar multivariate time series data from a pulp-and-paper industry with a rare event associated with them. It is an unwanted event in the process—a paper break, in our case—that should be prevented. The objective of the problem is 

  1.	predict the event before it occurs, and
  2.	identify the variables that are expected to cause the event (in order to be able to prevent it). 

Challenges in the problem
The data that we received is the Multivariate time series data which contains the information on the breaks that are rarely occurred. The number of breaks in the data is only 124 which is not enough to find the features to predict the occurrences in other test data. Most radical changes are occurred right at the time when it breaks. It is hard to find the distinct feature for early detection. Also, the data has a  number of variables which we didn’t have any information about.

Approach to address the challenges

Feature extraction (1-NN)
To extract the feature of the time series data, we measure the similarity between two temporal sequences. Even though we tried both DTW (Dynamic Time Warping) and Euclidean distance, we chose to use Euclidean distance considering model performance, time to analyze and efficiency based on the multivariate time series.
Early detection (Moving the y column)
The model that we submit is to detect one-step (2 min) earlier by moving the y column (class) up by 1 row. Also, we took the second derivate of variables to capture the abrupt change in time series.
Classification (Decision Tree)
We gained train data set and test data set as a result of 1-NN Euclidean distance. For the purpose of  classification, the decision tree model was applied to these data set. To improve the model performance, adaptive boosting and cost matrix are used.

Classification Result

The model is designed to detect the break one-step earlier (2 minutes). Because of the lack of data which has only 124 breaks and the fact that events are rarely occurred during operation, it’s hard to truly evaluate the model performance. We divided data into train and test (0.9 train, 0.1 test) as instruction asked and estimated the model performance (Precision, Recall, False Positive Rate and F-1 measure).
