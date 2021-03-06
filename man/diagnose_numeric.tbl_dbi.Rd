% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/tbl_dbi.R
\name{diagnose_numeric.tbl_dbi}
\alias{diagnose_numeric.tbl_dbi}
\title{Diagnose data quality of numerical variables in the DBMS}
\usage{
\method{diagnose_numeric}{tbl_dbi}(.data, ..., in_database = FALSE, collect_size = Inf)
}
\arguments{
\item{.data}{a tbl_dbi.}

\item{...}{one or more unquoted expressions separated by commas.
You can treat variable names like they are positions.
Positive values select variables; negative values to drop variables.
If the first expression is negative, diagnose_numeric() will automatically
start with all variables.
These arguments are automatically quoted and evaluated in a context where column names
represent column positions.
They support unquoting and splicing.}

\item{in_database}{Specifies whether to perform in-database operations. 
If TRUE, most operations are performed in the DBMS. if FALSE, 
table data is taken in R and operated in-memory. Not yet supported in_database = TRUE.}

\item{collect_size}{a integer. The number of data samples from the DBMS to R. 
Applies only if in_database = FALSE.}
}
\value{
an object of tbl_df.
}
\description{
The diagnose_numeric() produces information
for diagnosing the quality of the numerical(INTEGER, NUMBER, etc.) column 
of the DBMS table through tbl_dbi.
}
\details{
The scope of the diagnosis is the calculate a statistic that can be
used to understand the distribution of numerical data.
min, Q1, mean, median, Q3, max can be used to estimate the distribution
of data. If the number of zero or minus is large, it is necessary to suspect
the error of the data. If the number of outliers is large, a strategy of
eliminating or replacing outliers is needed.
}
\section{Numerical diagnostic information}{

The information derived from the numerical data diagnosis is as follows.

\itemize{
\item variables : variable names
\item min : minimum
\item Q1 : 25 percentile
\item mean : arithmetic average
\item median : median. 50 percentile
\item Q3 : 75 percentile
\item max : maximum
\item zero : count of zero values
\item minus : count of minus values
\item outlier : count of outliers
}

See vignette("diagonosis") for an introduction to these concepts.
}

\examples{
library(dplyr)

# Generate data for the example
carseats <- ISLR::Carseats
carseats[sample(seq(NROW(carseats)), 20), "Income"] <- NA
carseats[sample(seq(NROW(carseats)), 5), "Urban"] <- NA

# connect DBMS
con_sqlite <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")

# copy carseats to the DBMS with a table named TB_CARSEATS
copy_to(con_sqlite, carseats, name = "TB_CARSEATS", overwrite = TRUE)

# Using pipes ---------------------------------
# Diagnosis of all numerical variables
con_sqlite \%>\% 
  tbl("TB_CARSEATS") \%>\% 
  diagnose_numeric()
  
# Positive values select variables, and In-memory mode and collect size is 200
con_sqlite \%>\% 
  tbl("TB_CARSEATS") \%>\% 
  diagnose_numeric(Sales, Income, collect_size = 200)
  
# Negative values to drop variables
con_sqlite \%>\% 
  tbl("TB_CARSEATS") \%>\% 
  diagnose_numeric(-Sales, -Income)
  
# Positions values select variables
con_sqlite \%>\% 
  tbl("TB_CARSEATS") \%>\% 
  diagnose_numeric(5)
  
# Positions values select variables
con_sqlite \%>\% 
  tbl("TB_CARSEATS") \%>\% 
  diagnose_numeric(-1, -5)

# Using pipes & dplyr -------------------------
# Information records of zero variable more than 0
con_sqlite \%>\% 
  tbl("TB_CARSEATS") \%>\% 
  diagnose_numeric()  \%>\%
  filter(zero > 0)
  
}
\seealso{
\code{\link{diagnose_numeric.data.frame}}, \code{\link{diagnose.tbl_dbi}}, \code{\link{diagnose_category.tbl_dbi}}, \code{\link{diagnose_outlier.tbl_dbi}}.
}
