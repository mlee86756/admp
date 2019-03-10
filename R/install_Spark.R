# Author: Livia Hull
# Date: 2 Feb 2019
# Script that installs and connects with SparkR

# install packages
# library(devtools)
# devtools::install_github("rstudio/sparklyr")
# spark_install(version = "2.3.0")
# sparklyr::spark_install(version = "2.3.0", reset = TRUE)
# spark_installed_versions()
# sessionInfo()
# system("java -version")
# spark_home_dir() 
# Sys.which("java")

# Upload library
library(sparklyr)
library(dplyr)

#set system env - change this according to your own configuration
Sys.setenv(JAVA_HOME = "C:/progra~2/Java/")
Sys.setenv(SPARK_HOME="C:/Users/Livia/AppData/Local/spark/")

# Connect to Spark
sc <- spark_connect(master = "local")
