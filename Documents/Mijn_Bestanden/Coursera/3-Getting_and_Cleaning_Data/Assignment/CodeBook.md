================================================================================================================================================
CODE BOOK
================================================================================================================================================
This Codebook belongs to the R-script run_analysis.R, which is part of the course project for "Getting and Cleaning Data" and uses data 
collected from the accelerometers from the Samsung Galaxy S smartphone. The R-script makes use of the R-packages: "data.table" and "dplyr". 

================================================================================================================================================
The Dataset
================================================================================================================================================
This data is obtained from "Human Activity Recognition Using Smartphones Data Set". The data linked are collected from the accelerometers from 
the Samsung Galaxy S smartphone. A full description is available at the site:

http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones.

The data set used can be downloaded from:

https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

================================================================================================================================================
The Input Files
================================================================================================================================================
The entire dataset is unzipped and the files are placed in the folder "UCI HAR Dataset". The data is randomly partitioned into 2 datasets 
(training and test), which are split into 3 different categories: subject = ID, X = features, y = activities

The following data files were used in run_analysis.R:

* subject_train.txt 	-	subject IDs belonging to X_train.txt
* X_train.txt 			-	measurements of the feature variables for the training data set
* y_train.txt 			-	non-descriptive activity labels belonging to X_train.txt
* subject_test.txt 		-	subject IDs belonging to X_test.txt
* X_test.txt 			-	measurements of the feature for the testing data set
* y_test.txt 			-	non-descriptive activity labels belonging to X_test.txt
* features.txt 			-	metadata containing the variable feature names in the data sets
* activity_labels.txt	-	metadata containing the different descriptive activity lab

The following code is used to load the data into R:
		subject_train <- read.table("./UCI HAR Dataset/train/subject_train.txt")
		X_train <- read.table("./UCI HAR Dataset/train/X_train.txt")
		y_train <- read.table("./UCI HAR Dataset/train/y_train.txt")
		subject_test <- read.table("./UCI HAR Dataset/test/subject_test.txt")
		X_test <- read.table("./UCI HAR Dataset/test/X_test.txt")
		y_test <- read.table("./UCI HAR Dataset/test/y_test.txt")
		features <- read.table("./UCI HAR Dataset/features.txt")
		activities <- read.table("./UCI HAR Dataset/activity_labels.txt")

================================================================================================================================================
The Features Variables
================================================================================================================================================
The features selected for this database come from the accelerometer and gyroscope 3-axial raw signals tAcc-XYZ and tGyro-XYZ. These time domain 
signals (prefix 't' to denote time) were captured at a constant rate of 50 Hz. Then they were filtered using a median filter and a 3rd order low 
pass Butterworth filter with a corner frequency of 20 Hz to remove noise. Similarly, the acceleration signal was then separated into body and 
gravity acceleration signals (tBodyAcc-XYZ and tGravityAcc-XYZ) using another low pass Butterworth filter with a corner frequency of 0.3 Hz.

Subsequently, the body linear acceleration and angular velocity were derived in time to obtain Jerk signals (tBodyAccJerk-XYZ and
tBodyGyroJerk-XYZ). Also the magnitude of these three-dimensional signals were calculated using the Euclidean norm (tBodyAccMag, tGravityAccMag, tBodyAccJerkMag, tBodyGyroMag, tBodyGyroJerkMag).

Finally a Fast Fourier Transform (FFT) was applied to some of these signals producing fBodyAcc-XYZ, fBodyAccJerk-XYZ, fBodyGyro-XYZ, 
fBodyAccJerkMag, fBodyGyroMag, fBodyGyroJerkMag. (Note the 'f' to indicate frequency domain signals).

These signals were used to estimate variables of the feature vector for each pattern:
'-XYZ' denotes the 3-axial signals in the X, Y and Z directions.

NOTE: some of the feature variable names have been relabeled to more readable descriptions. See below (conversion 4).

================================================================================================================================================
Conversions to the Dataset
================================================================================================================================================
The script applies the following conversions to the original dataset
 1. Merging the training and the test sets to create one data set.
	- the data sets within each category (subject, features, activities) are merged by row
	
		subject <- rbind(subject_train, subject_test)
		X <- rbind(X_train, X_test)
		y <- rbind(y_train, y_test)

	- the merged test and train dataset are merged by column
	
		merged_Xy <- cbind(new_X,new_y) 				NOTE: new_X used from step 2; new_y used from step 3
		merged_data <- cbind(merged_Xy,subject)
	
	 2. Extracting only the measurements on the mean and standard deviation for each measurement
 
		all_means <- grep("mean", features_names, value=TRUE)
		all_stds <- grep("std", features_names, value=TRUE)
		means_stds <- c(all_means, all_stds)
		new_X <- X[, means_stds]
 
 3. Using descriptive activity names to name the activities in the data set 
		new_y <- as.character(y$activity)
		for (i in 1:6) {
		new_y[new_y == i] <- as.character(activities[i,2])
		}
 
 4. Relabeling of the descriptive feature names
		- unwanted separators removed ("-" replaced by "."; () removed)
		- acronyms replaced (t = time; f = frequency; Acc = Accel; Mag = Magn) 
		- mistakes in features.txt removed (BodyBody = Body)
		
		features_names <- gsub("-", ".", features$V2)
		features_names <- gsub("\\(|\\)", "", features_names)
		features_names <- gsub("^t", "time", features_names)
		features_names <- gsub("^f", "frequency", features_names)
		features_names <- gsub("Acc", "Accel", features_names)
		features_names <- gsub("Mag", "Magn", features_names)
		features_names <- gsub("BodyBody", "Body", features_names)
		
 5. Creates a second, independent tidy data set with the average of each variable for each activity and each subject.
	
		merged_data_averages <- aggregate(. ~ID + activities, merged_data, mean)
		tidy_data <- merged_data_averages[order(merged_data_averages$ID, merged_data_averages$activities),]
		write.table(tidy_data, file = "tidydata.txt", row.name = FALSE)
================================================================================================================================================
		
