## Create one R script called run_analysis.R that does the following:
## 1. Merges the training and the test sets to create one data set.
## 2. Extracts only the measurements on the mean and standard deviation for each measurement.
## 3. Uses descriptive activity names to name the activities in the data set
## 4. Appropriately labels the data set with descriptive activity names.
## 5. Creates a second, independent tidy data set with the average of each variable for each activity and each subject.

if (!require("data.table")) {
      install.packages("data.table")
}

if (!require("reshape2")) {
      install.packages("reshape2")
}

require("data.table")
require("reshape2")

# reading labels of the activity
activity_labels <- read.table("./UCI HAR Dataset/activity_labels.txt")[,2]

# reading labels of the features,
features <- read.table("./UCI HAR Dataset/features.txt")[,2]

# selecting only those feature-labels, which match "mean" or "std" patterns
selected_feature_labels <- grepl("mean|std", features)

# Load and process X_test & y_test data.
X_test <- read.table("./UCI HAR Dataset/test/X_test.txt")
y_test <- read.table("./UCI HAR Dataset/test/y_test.txt")
subject_test <- read.table("./UCI HAR Dataset/test/subject_test.txt")
# setting names for the X_test vars
names(X_test) = features

# Load and process X_train & y_train data.
X_train <- read.table("./UCI HAR Dataset/train/X_train.txt")
y_train <- read.table("./UCI HAR Dataset/train/y_train.txt")
subject_train <- read.table("./UCI HAR Dataset/train/subject_train.txt")

# setting names for the X_train vars
names(X_train) = features

# UNION of the test and train data frames
X_union <- rbind(X_train, X_test)

# Extract only the measurements on the mean and standard deviation for each measurement.
X_union = X_union[,selected_feature_labels]

# UNION of the subject datasets (the same train -> test order)
subject_union <- rbind(subject_train, subject_test)

# setting name for subject
subject_union_t <- as.data.table(subject_union)
setnames(subject_union_t, "subject_num")

# UNION of the activity-numbers datasets (the same train -> test order)
y_union <- rbind(y_train, y_test)

# adding activity labels
y_union[, 2] = activity_labels[y_union[, 1]]

# setting names to y_union vars
names(y_union) <- c("activity_num", "activity_label")

# creating resulting data
data <- cbind(subject_union_t, y_union, X_union)

# preparing id-vector for melting
id_labels <- c("subject_num", "activity_num", "activity_label")

# melting data
meltData <- melt(data, id.vars = id_labels,
                 measure.vars = setdiff(colnames(data), id_labels))

# Creating tidy data
tidy_data   = dcast(meltData, subject_num + activity_label ~ variable, mean)

#writing tidy dataset to the file
write.table(tidy_data, file = "./tidy_data.txt")
