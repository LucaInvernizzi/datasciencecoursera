### SUBSETTING AND SORTING ###

### SUBSETTING REVIEW

set.seed(13435)
X <- data.frame("var1" = sample(1:5), "var2" = sample(6:10), "var3" = sample(11:15))
X <- X[sample(1:5),]
X$var2[c(1,3)] = NA
X

X[,1]
X[,"var1"]
X[1:2, "var2"]

X[(X$var1 <= 3 & X$var3 > 11),] #very useful!
X[(X$var1 <= 3 | X$var3 > 15),]

X[which(X$var2 > 8),] #which treats NA as FALSE

sort(X$var1)  # report and order the values of that variable
sort(X$var2) # excludes the NA
sort(X$var2, na.last = T) # can include NA with na.last
sort(X$var3, decreasing = T) # also in decreasing order

X[order(X$var1),] # function order passed as function in subsetting
# order tells where 1st element is, where the second is, etc etc
order(c(3,1,2,5,4)) # in position 1 you should put the element in position 2
X[order(X$var1, X$var3),] #this breaks the tie using var3

X[sort(X$var1),] #this is NOT the same, doesn't work
sort(c(3,1,2,5,4))

### PLYR package

library(plyr)
arrange(X, var1) # X generated at the start of the file
arrange(X, desc(var1))

X$var4 <- rnorm(5) #add a coloumn
X
Y <- cbind(X, rnorm(5)) # generate a new data frame binding X and rnorm(5)
Y
# you can bind rows with rbind, works the same

### SUMMARIZING DATA

## get the data
if(!file.exists(".data")) {dir.create("./data")}
dataURL <- "https://data.baltimorecity.gov/api/views/k5ry-ef3g/rows.csv?accessType=DOWNLOAD"
download.file(dataURL, destfile = "./data/restaurant.csv", method = "curl")
restData <- read.csv("./data/restaurant.csv")

restData # too big to read

# first a look at the whole dataset structure
head(restData, n = 5)
View(head(restData, n = 5)) #if hard to read, View() can help
tail(restData)

nrow(restData)

summary(restData)
str(restData)

# then single variables
quantile(restData$councilDistrict, na.rm = T)
quantile(restData$councilDistrict, probs = c(0.5, 0.75, 0.9), na.rm = T)

table(restData$zipCode, useNA = "ifany") # 1 dimensional
table(restData$councilDistrict, restData$zipCode)

# check for NA
sum(is.na(restData$councilDistrict)) # false = 1, true = 0
any(is.na(restData$policeDistrict))

colSums(is.na(restData)) # rows and coloumns sums

# Value with specific characteristics
table(restData$zipCode %in% c("21212")) # value in zipCode with value 21212
table(restData$zipCode %in% c("21212", "21213"))
restData[restData$zipCode %in% c("21212", "21213"),] # subset with rule!

# cross tabs
data("UCBAdmissions") # dataframe used as example
View(UCBAdmissions)
DF = as.data.frame(UCBAdmissions)
summary(DF) # with basic esploration

xt <- xtabs(Freq ~ Gender + Admit, data = DF)
xt # freq is the value in the table, gender and admit rows and coloumn
View(xt) # to clarify the concept

# flat tables
data("warpbreaks")
warpbreaks$replicate <- rep(1:9, len = 54)
xt2 = xtabs(breaks ~., data = warpbreaks)
xt2 #same as before, but for ALL the variables -> hard to read!
ftable(xt2) # summarise the deta in smaller and compact form!

# Size of the dataset
# sometimes important
fakeData = rnorm(1e5)

object.size(fakeData)
print(object.size(fakeData), units = "Mb")

### CREATING NEW VARIABLES
# Common Variable people create
## Missingness Indicator
## Factor version of quantitative variables -> EX "over 75%"
## Transformation for data that have strange distributions

# restData created in line 47

## Creating Sequences
# Index for operations I want to do on the data

s1 <- seq(1, 10, by = 2) # from 1 to 10, jump by 2
s2 = seq(1, 10, length = 3) # from 1 to 10 with 3 jumps, 1 and 10 included

x <- c(1, 3, 8, 25, 100) # a vector you need to loop on
seq(along = x) # generate a vector that will allows you to loop over x

## actual creation of new variable

# variable for restourant in an area
restData$nearMe = restData$neighborhood %in% c("Roland Park", "Homeland")
# %in% checks if value is in the vector provided
# if you put a string, it goes over it and return T or F for every element
table(restData$nearMe) # count T and F

# variables for wrong zipcodes (negative zipcodes)
restData$zipWrong = ifelse(restData$zipCode < 0, T, F)
# if zipcode < 0 zipWrong is T
table(restData$zipWrong)

# new variable with the zipcode divided by range
restData$zipGroup = cut(restData$zipCode, breaks = quantile(restData$zipCode))
table(restData$zipGroup)
# different way to do it
library(Hmisc)
restData$zipGroup = cut2(restData$zipCode, g = 4)
# CUTTING produces FACTOR variables

# turn variables into factors
restData$zcfactor = factor(restData$zipCode) # zipcode into factors
restData[1:10]
class(restData$zcfactor)

# NEW DF with new variable
library(Hmisc)
library(plyr)
restData2 = mutate(restData, zipGroup10 = cut2(zipCode, g = 10))
# mutate add a coloumn

## list of common transformations with function
abs(x) #absolute value
sqrt(x) #square root
ceiling(x) #ceiling(3.75) is 4, the closer integer
floor(x) #floor(3.75) is 3
round(x, digits = n) #round(3,476, digits = 2) is 3.48
signif(x, digits = n) #signif(3,476, digits = 2) is 3.5
cos(x)
sin(x)
log(x)
log2(x)
log10(x)
exp(x)

### RESHAPING DATA
# Usually the first thing to do after getting data
# ID VARIABLE: Identifies the entities in the data set (cars, gear, cylinder)
# MEASURE VARIABLES: Measure stuff

library(reshape2)
head(mtcars)

## Melt
# Reshaping the data
# Melt: spread the dataset long and thin. Same entities in different rows

mtcars$carname <- rownames(mtcars) # names are not a coloumn, so we create it!
carMelt <- melt(mtcars, id = c("carname", "gear", "cyl"), 
                measure.vars = c("mpg", "hp")) 
# MELT is a very important tool!
head(carMelt)
tail(carMelt)

## Cast
# Cast: large dataset with 1 individual per row

cylData <- dcast(carMelt, cyl ~ variable) # cyliner broken down in different variables
# all the different veriables you put under measure.var when you melted the dataframe
# this summarize the variable
cylData # this shows how many mpg and hp every different cylinder have

cylDataMean <- dcast(carMelt, cyl ~ variable, mean)
cylDataMean

## Averaging Values
# avegra values in a dataframe (example of manipulating the dataframe)

head(InsectSprays)
tapply(InsectSprays$count, InsectSprays$spray, sum)
# see Apply lesson, apply "sum" to "count" with then index "spray" in "InsectSpray"

## same thing but with a split/apply/combine strategy
sprIns <- split(InsectSprays$count, InsectSprays$spray) # SPLIT
sprIns # you get a list of value for A, B, C etc
sprCount <- lapply(sprIns, sum) # APPLY
sprCount # apply the sum on a list (lapply)
unlist(sprCount) # COMBINE
# SAPPLY does the apply and combine together
sapply(sprIns, sum)

## same but with PLYR package
library(plyr)
ddply(InsectSprays, .(spray), summarize, sum = sum(count))
# the .() allows to call the object coloumn without using "" or []! USEFUL!
# DDPLY does the split/apply/combine all in one function

# using ddply you can create a new variable with the sum
spraySum <- ddply(InsectSprays, .(spray), summarize, sum = ave(count, FUN = sum))
dim(spraySum)
head(spraySum)
# ave() return a vector that is the same lenght of the one give!
# so you do the sum (FUN = sum), but you get a dataframe
# and now we can add this to the dataframe and have a new coloumn

## other useful stuff for reshaping:
acast() # cast for multidimensional array
arrange() # to reorder rows
mutate() # adding new variable

### DPLYR PACKAGE
## based around the keywords: 
# SELECT - return a subset of the column of a dataframe
# FILTER - extract a subset of row based on logical conditions
# ARRANGE - reorder row of dataframe
# RENAME - rename variables
# MUTATE - add new variable/coloumn or transform existing variables
# SUMMARISE/SUMMARIZE - generate sum statistics

## also have a print method to avoid big print in the console

## Basic structure
# First argument is the data frame
# Following arguments describe what to do
# Can refer to coloumn without the $
# Result is a dataframe
# Dataframe need to be PROPERLY FORMATTED and ANNOTATED
## Factor levels annotated
## Variables names present


