
# Clearing the workspace
# rm(list=ls())
# gc()

# Setting up the working directory
# setwd("P:/ImpDocuments/Getting_and_cleaning_data_coursera_042014/GettingCleaningData/")

# Load the required packag
require(data.table)

##### Below code is for "Getting and Cleaning Data Project"
#     1. Merges the training and the test sets to create one data set.
#     2. Extracts only the measurements on the mean and standard deviation for each measurement. 
#     3. Uses descriptive activity names to name the activities in the data set
#     4. Appropriately labels the data set with descriptive activity names. 
#     5. Creates a second, independent tidy data set with the average of each variable for each activity and each subject.  

# Reading training and test set
train.data <- as.data.table( read.table("data/train/X_train.txt", colClasses="numeric", sep="") )
test.data  <- as.data.table( read.table("data/test/X_test.txt", colClasses="numeric", sep="") )

# Reading training and test subjects
train.subjects <- fread("data/train/subject_train.txt", colClasses="numeric")
test.subjects <- fread("data/test/subject_test.txt", colClasses="numeric")

# Reading training and test labels
train.labels <- fread("data/train/y_train.txt", colClasses="numeric")
test.labels <- fread("data/test/y_test.txt", colClasses="numeric")
    
# Add labels and subjects to the data
train.data$subjects <- train.subjects$V1
test.data$subjects <- test.subjects$V1

train.data$labels <- train.labels$V1
test.data$labels  <- test.labels$V1

# Reading features
features <- fread("data/features.txt")

# Ans - 1 -----------------------------------------------------------------
#
# Merge the training and the test sets to create one data set.
#

    # Combine training and test set
    train.test.merge <- rbind(train.data, test.data)


# Ans-2  -----------------------------------------------------------------
#
# Extracts only the measurements on the mean and standard deviation for each measurement. 
#

    # Assigning column names with corresponding features
    setnames(train.test.merge, c(features$V2, "subjects", "labels"))
    # Extracts only the measurements on the mean and standard deviation for each measurement. 
    # accroding to features_info.txt, set of variables that were estimated are:
    #    mean(): Mean value
    #    std(): Standard deviation
    
    # Gettign indexes of measurement names with std() and mean()
    mean_sd_indexes <- grep('mean\\(\\)|std\\(\\)', names(train.test.merge), ignore.case=T)
    # Extracting data based on above indexes
    mean.sd.data <- train.test.merge[, mean_sd_indexes, with=F]


# Ans-3  -----------------------------------------------------------------
#
# Use descriptive activity names to name the activities in the data set. 
#

    # Reading activity labels
    activity.labels <- fread("data/activity_labels.txt")

# Ans-4  -----------------------------------------------------------------
#
# Label the data set with descriptive activity names. 
#
    # Setting key for faster merge
    setkey(train.test.merge, labels)    
    setkey(activity.labels, V1)    

    # Merge labels with activity names 
    train.test.merge.activity <- train.test.merge[activity.labels, nomatch=0]
    
    # Removing original activity label colum
    train.test.merge.activity$labels <- NULL
    # Rename column V2    
    setnames(train.test.merge.activity, "V2", "label")

# Ans-5  -----------------------------------------------------------------
#
# Creating tidy data set with the average of each variable for each activity and each subject. 
#
    
    tidy.data.set <- train.test.merge.activity[, lapply(.SD,mean), by=list(label, subjects)]

    # Export results in a file
    write.table(tidy.data.set, "tidy_data.txt", row.names=F)

