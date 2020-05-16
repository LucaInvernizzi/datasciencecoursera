### INTRO

# Basically, all the stuff in CAPS:
# RAW DATA->PROCESSING SCRIPT->TIDY DATA->Data Analysis->Data Communication

### RAW AND PROCESSED DATA

# "Data are values of qual or quant variables, belonging to a set of items" WIKI

## Raw data:
# often hard to analyse
# data analysis includes tidy up data
# original source of the data, but there are levels
# you know they are the raw data if:

## Processed data
# ready to process
# processing can include merging/subsetting/transforming etc
# there are often standard for processing (example, genomics)
# steps should be recorded (preprocessing often is the most important step)

### COMPONENTS OF TIDY DATA

## At the end of the process you should have 4 things:

# 1 # The RAW data:
# YOU run no software on the data
# YOU did not manipulate any of the number in the data
# Not even summarize or remove some data

# 2 # A TIDY dataset:
# Each variable 1 coloumn
# each observation 1 row
# 1 table for every "kind" of variable
# if multiple tables, a coloumn in each that allows them to be linked

# 3 # A CODE BOOK describing each variables in the tidy dataset (metadata)
# Info in variables (with units!)
# Info on summary choice (mean or median for a variable, for example)
# A section "STUDY DESIGN" (how data were collected)
# can be word/markdown etc etc

# 4 # An explicit and exact recipe from row to tidy, The INSTRUCTION LIST
# An R script (or python)
# the input is the raw data
# the output is the tidy data
# Everything is fixed like you did it, no parameter
# If something is not scripeted, add the list with the steps

## Useful tips:
# Include row at the top with variable names
# Make variables readable
# Data 1 file per table (not double tab in excel for example)

### DOWNLOADING FILES
# It's better to use R to download (so you can put in code book)
download.file() # important arguments are url, destfile and method
# url from where
# destfile to where
# method: with http not needed, if https usually ok, but use "curl"

# in general
fileUrl <- "right click on the file online and get link"
download.file(fileUrl, destfile = "./banana.ext", method = "curl")
# you can decide the extension, and he put it into that format
list.files("./banana")

# utile fare anche
dateDownloaded <- date()
dateDownloaded

getwd() #tell wd

# relative pathway
setwd("../") # up one directory (the superseder)
setwd("./data") # the folder data in the current wd
# absolute pathway
setwd("C:/Users/Banana/Downloads") # or
setwd("C:\\Users\\Banana\\Downloads") #windows gives \ but R need \\

if (!file.exists("Banana")) {
  dir.create("Banana")
} # check if "Banana" exists and if not create it

### READING LOCAL FILES

read.table() # robust, read into ram (proble big datya), can be slow
# Check sep and header if problems
# Some important parameters:
# na.string
# quote -> solves random " or ' placed around vales quote = "" usually solves it
# nrows
# skip

read.csv() # very common data format
read.csv2()

### READ EXCEL FILES
# better not to use excel if possible

library(xlsx)
# not only library, XLConnect can be useful, too

read.xlsx()
read.xlsx2() #faster but unstable
# can pass the sheet as argument, for example
# can read specific coloumns and rows

write.xlsx()
write.xlsx() # write an excel file

### READING XML
## Extensible markup language:
# everything is labeled -> it's readable but you can use the tag for programming
# often used for structured data
# common on the internet, see Wikipedia for more info
# composed of Markup and Actual Text

## Markup 
# start tags <banana> 
# end tags </banana>
# empty tags (you don't need to open and close) <line-break />
# specific examples of tags are called Elements
# tags can have components called attributes, see example below
# <img src="banana.jpg" alt="fruit" />
# or <step number="3"> Cut the banana </step>

library(XML)

doc <- xmlTreeParse(fileUrl, useInternal = T)
# this loads document into R so you can have access to different parts of it
# it's still structured, we need to have function to access diffeerent parts
rootNode <- xmlRoot(doc)
xmlName(rootNode)
# the "root" element contains all other elements
names(rootNode) # access name of the elements
rootNode[[1]] # you can access elements like a list
rootNode[[1]][[1]] # first element of first element

xmlSApply(rootNode, xmlValue) # SApply applied to xml

# to access different nodes with these commands you need the xpath language

# You can do similar things with the HTML, with equivalent commands

### READING JSON
# structured and used on the internet (like xml) but different syntax
# data from stuff like facebook and twitter
# see wikipedia

library(jsonlite)
jsonData <- fromJSON("the api of the website") #not clear but whatever
names(jsonData) # to see things like a list

myjon <- toJSON(iris, pretty = T) # save as JSON
iris2 <- fromJSON(myjson) #back to JSON

### DATA.TABLE
# all function that accept dataframe should accept data.table
# in C, so faster at subsetting, grouping and updating variables
# it has a bit of a different grammar

DF = data.frame(x = rnorm(9), y = rep(c("a", "b", "c"), each = 3), z = rnorm(9))
# normal data.frame (you can use = to create, non only <-)
head(DF, 3)

DT = data.table(x = rnorm(9), y = rep(c("a", "b", "c"), each = 3), z = rnorm(9))
# same variable
head(DT, 10)

tables()
# differente then table!
# gives NAME, NROW, MB (MegaBytes), COLS, KEY

## Subsetting ROWS mostly the same way as DFrame
DT[2,]
DT[DT$y=="a",]
DT[c(2,3)] # subset with only 1 index (no ",") -> subset rows

## Subsetting COLOUMNS is different
# uses EXPRESSIONS to allow to summarize the data in different ways
## expressions are between {}
# example
k = {print(10); 5}

# instead of index in second position you can use list of function
DT[, list(mean(x), sum(z))]
# variables are applied on variables named by coloumn
# NB: No need tio use "", it recognizes them automatically
# check to confirm:
mean(DT$x)
sum(DT$z)
# pretty much any function, another example:
DT[, table(y)]

# adding new coloumn is really fast:
DT[, w:=z^2]
# be careful! if you assign the DT to another variable,
# every change is gonna be passed over
DT2 <- DT
DT[, y:=2]
# you need to use:
DT3 <- copy(DT)
DT[, y := rep(c("a", "b", "c"), each = 3)]
DT
DT2
DT3 #to check this doesnt change

# you can pass complex expression like this:
DT[, m:= {tmp <- (x + z); log2(tmp + 5)}] # tmp is just a temporary values
# in expression only the last thing is returned so only m appear
DT[, a := x > 0] # logical TRUE FALSE coloumn

# plyr like operations!
DT[, b:= mean(x + w), by = a]
# group by "a" ( 2 factors),
# for every row x+w where a = F
# then mean() of the values,
# then makes a coloumn b and put the value in rows where a = F
# the same with a = T

#easier esample of same thing
testtable <- data.table(a = c(1,2,3), b = c(10, 20, 30), c = c("A", "A", "B"))
testtable[, d:= mean(a + b), by = c]
testtable

# there are also special variables, example: .N
set.seed(123);
NewDT <- data.table(x = sample(letters[1:3], 1E5, TRUE))
# sampled 100 000 times between a,b,c
NewDT[, .N, by = x] # count number of times something appear grouped by x

## keys
setkey(DT, y)
DT["a"] #it knows "a" refers to the y coloumn, cause that's the key!
# can be used to merge (fuse 2 DT or DF common coloumn or rows)
