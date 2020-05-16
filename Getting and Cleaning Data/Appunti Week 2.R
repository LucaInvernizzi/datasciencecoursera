### READING FROM MySQL
## Free Open Source database software

## Data structured in:
# Databases
# Tables (Basically Dataframe) within databases
# fields within table (Basically "coloumn names")
# each row is called a record

# sql needs to be installed
# it uses sql programming language that you use throught R
# REVIEW IF NEEDED

### READING FROM HDF5
# Hierarchical Data Format
# Stores large datasets
# support wide range of data types
# 2 types of objects: GROUPs and DATASETs

## GROUPS containing zero or more dataset and metadata, they have:
# group header with group name and list of attributes
# group symbol table with a list of objects in a group

## DATASETS -> multidimensional array of data elements with metadata, they have:
# Header with name, datatype, dataspace and storage layout
# data array with the data

if (!requireNamespace("BiocManager", quietly = TRUE))
  install.packages("BiocManager")
BiocManager::install(version = "3.10")
# install biomanager (to update bioconductor packages)

BiocManager::install("rhdf5")
# install package for hdf5

library(rhdf5) #a lot of info in the vignette of the package

created = h5createFile("example.h5") #create an hdf5 file

created = h5createGroup("example.h5", "foo") #create groups
created = h5createGroup("example.h5", "baa")
created = h5createGroup("example.h5", "foo/foobaa") # create subgroup of foo

h5ls("example.h5") #shows groups

A = matrix(1:10, nr = 5, nc = 2) # create matrix
B = array(seq(0.1, 2.0, by = 0.1), dim = c(5, 2, 2)) #create 3D array
attr(B, "scale") <- "liter" # assign attribute to B
h5write(A, "example.h5", "foo/A")
h5write(B, "example.h5", "foo/foobaa/B")

# can also add dataframe directly
h5write(DF, "example.h5", "DF") 
# you don't pass the group -> go in the top level group

readA = h5read("example.h5", "foo/A") #read inside the file

# you can also write data DIRECTLY inside the file
h5write(c(12, 13, 14), "example.h5", "foo/A", index = list(1:3, 1))
h5read("example.h5", "foo/A")
h5read("example.h5", "foo/A", index = list(2, 1:2))
# the index can be also used to read only specific parts

### DATA FROM THE WEB

## Web scraping
# Programmatically extract data from html
# Sometime is against term of services

con = url("http://yoururl.goes/here") #open a connection
htmlCode = readLines(con) # read the data
close(con) #close the connectio!!!
htmlCode #yoy get a very long string of letters -> solution, use XML package

library(XML)
url <- "http://yoururl.goes/here"
html <- htmlTreeParse(url, useInternalNodes = T) # nodes are the structure
# to explore the code you can use:
xpathSApply(html, "//somethingsomething", xmlValue)

#another useful library is:
library(httr)
html2 = GET(url)
content2 = content(html2, as = "text") #extract content from html, as text
parsedHtml = htmlParse(content2, asText = T)
xpathSApply(parsedHtml, "//somethingsomething", xmlValue)

#some webpages have password, if you try to use GET() you get
# Status: 401 -> not authenticate
# in GET fucntion add command authenticate("MYuser", "MYpassword") and get
# Status: 200 -> authenticate and can get the info

# the command
handle()
# preserve settings and cookies, so you dont need to retype every time
google = handle("http://google.com")
pg1 = GET(handle = google, path = "/")
pg2 = GET(handle = google, path = "search/")
# you can also authenticate in the handle

# R-blogger Web Scraping have useful info on web scraping

### READING FROM API
# Application Programming Interface
# like twitter/facebook etc
# usually with GET request
# Often need to create an account with the API development team
# A Dev Account, that gives you several numbers to use

# the class uses the httr package in the example
# look at the R meeting repo done on twitter scraping

### READING FROM OTHER SOURCES
# basically there is a package for everything
# attention when you open connections, remember to close them
# there are also packages for accessing images, mp3 and geographic data (GIS)

