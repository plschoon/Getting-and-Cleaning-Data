## The following R script (run_analysis.R) is part of the course project for "Getting and Cleaning Data" and uses
## data collected from the accelerometers from the Samsung Galaxy S smartphone.  
## The script is supposed to fullfill the following steps:
##    1. Merges the training and the test sets to create one data set.
##    2. Extracts only the measurements on the mean and standard deviation for each measurement.
##    3. Uses descriptive activity names to name the activities in the data set
##    4. Appropriately labels the data set with descriptive activity names.
##    5. Creates a second, independent tidy data set with the average of each variable for each activity and each subject.


if (!require("data.table")) {
      install.packages("data.table")
}

if (!require("dplyr")) {
      install.packages("dplyr")
}

require("data.table")
require("dplyr")


## Downloading and unzipping file into folder "./data" 
if(!file.exists("./data")) {
      dir.create("./data")
}
Url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(Url, destfile = "./data/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip", method = "curl")

## The unzipped files are located in the folder "UCI HAR Dataset". 
## The data is randomly partitioned into 2 datasets (training and test), which are split into 3 different 
## categories: subject = ID, X = features, y = activities

# Reading in training dataset
subject_train <- read.table("./UCI HAR Dataset/train/subject_train.txt")
X_train <- read.table("./UCI HAR Dataset/train/X_train.txt")
y_train <- read.table("./UCI HAR Dataset/train/y_train.txt")
      
## Reading in test dataset 
subject_test <- read.table("./UCI HAR Dataset/test/subject_test.txt")
X_test <- read.table("./UCI HAR Dataset/test/X_test.txt")
y_test <- read.table("./UCI HAR Dataset/test/y_test.txt")

## Reading in activity lables
activities <- read.table("./UCI HAR Dataset/activity_labels.txt")
names(activities) <- c("activity", "activities")

## Reading in complete list of variables and relabling with understandable descriptive names
features <- read.table("./UCI HAR Dataset/features.txt")
features_names <- gsub("-", ".", features$V2)
features_names <- gsub("\\(|\\)", "", features_names)
features_names <- gsub("^t", "time", features_names)
features_names <- gsub("^f", "frequency", features_names)
features_names <- gsub("Acc", "Accel", features_names)
features_names <- gsub("Mag", "Magn", features_names)
features_names <- gsub("meanFreq", "average.frequency", features_names)
features_names <- gsub("BodyBody", "Body", features_names)

# Merging the data tables within each category
subject <- rbind(subject_train, subject_test)
X <- rbind(X_train, X_test)
y <- rbind(y_train, y_test)

# renaming variables
names(subject) <- "ID"
names(X) <- features_names
names(y) <- "activity"

## Extracting only the measurements on the mean and the standard deviation
all_means <- grep("mean", features_names, value=TRUE)
all_stds <- grep("std", features_names, value=TRUE)
means_stds <- c(all_means, all_stds)
new_X <- X[, means_stds]


## Relabeling the activities in the dataset using the descriptive activity names
new_y <- as.character(y$activity)
for (i in 1:6) {
      new_y[new_y == i] <- as.character(activities[i,2])
}

## Setting the activity variable in the data as a factor
new_y <- as.factor(new_y)
names(new_y) <- "activities"

## Merging the datasets by column in one large dataset 
merged_Xy <- cbind(new_X,new_y) 
merged_data <- cbind(merged_Xy,subject)

## Renaming activity column in dataset
colnames(merged_data)[colnames(merged_data)=="new_y"] <- "activities"

## Creating an independent tidy dataset containing the averages of each variable sorted by activity and subject
merged_data_averages <- aggregate(. ~ID + activities, merged_data, mean)
tidy_data <- merged_data_averages[order(merged_data_averages$ID, merged_data_averages$activities),]

write.table(tidy_data, file = "tidydata.txt", row.name = FALSE)

