% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/univariate.R
\name{plot.univar_numeric}
\alias{plot.univar_numeric}
\title{Visualize Information for an "univar_numeric" Object}
\usage{
\method{plot}{univar_numeric}(
  x,
  indiv = FALSE,
  viz = c("hist", "boxplot"),
  stand = ifelse(rep(indiv, 4), c("none", "robust", "minmax", "zscore"), c("robust",
    "minmax", "zscore", "none")),
  prompt = FALSE,
  ...
)
}
\arguments{
\item{x}{an object of class "univar_numeric", usually, a result of a call to univar_numeric().}

\item{indiv}{logical. Select whether to display information of all variables in one plot when there are multiple selected numeric variables. 
In case of FALSE, all variable information is displayed in one plot. 
If TRUE, the information of the individual variables is output to the individual plots. 
The default is FALSE. If only one variable is selected, TRUE is applied.}

\item{viz}{character. Describe what to plot visualization. "hist" draws a histogram and "boxplot" draws a boxplot. The default is "hist".}

\item{stand}{character. Describe how to standardize the original data. 
"robust" normalizes the raw data through transformation calculated by IQR and median.
"minmax" normalizes the original data using minmax transformation.
"zscore" standardizes the original data using z-Score transformation.
"none" does not perform data transformation.
he default is "none" if indiv is TRUE, and "robust" if FALSE.}

\item{prompt}{logical. The default value is FALSE. If there are multiple visualizations to be output, 
if this argument value is TRUE, a prompt is output each time.}

\item{...}{arguments to be passed to methods, such as graphical parameters (see par).
However, it does not support.}
}
\description{
Visualize boxplots and histogram by attribute of univar_numeric class.
}
\examples{
# Generate data for the example
carseats <- ISLR::Carseats
carseats[sample(seq(NROW(carseats)), 20), "Income"] <- NA
carseats[sample(seq(NROW(carseats)), 5), "Urban"] <- NA

# Calculates the all categorical variables
all_var <- univar_numeric(carseats)

# Print univar_numeric class object
all_var
  
# Summary the all case : Return a invisible copy of an object.
stat <- summary(all_var)

# Summary by returned object
stat

# one plot with all variables
plot(all_var)

# one plot with all normalized variables by Min-Max method
plot(all_var, stand = "minmax")

# one plot with all variables
plot(all_var, stand = "none")

# one plot with all robust standardized variables 
plot(all_var, viz = "boxplot")

# one plot with all standardized variables by Z-score method 
plot(all_var, viz = "boxplot", stand = "zscore")

# individual boxplot by variables
plot(all_var, indiv = TRUE, "boxplot")

# individual histogram by variables
plot(all_var, indiv = TRUE, "hist")

# individual histogram by robust standardized variable 
plot(all_var, indiv = TRUE, "hist", stand = "robust")

# plot all variables by prompt
plot(all_var, indiv = TRUE, "hist", prompt = TRUE)

}
\seealso{
\code{\link{univar_numeric}}, \code{\link{print.univar_numeric}}, \code{\link{summary.univar_numeric}}.
}
