#' Combination chart for missing value
#'
#' @description
#' Visualize distribution of missing value by combination of variables.
#'
#' @details Rows are variables containing missing values, and columns are observations. 
#' These data structures were grouped into similar groups by applying hclust. 
#' So, it was made possible to visually examine how the missing values are distributed 
#' for each combination of variables.
#' 
#' @param x data frames, or objects to be coerced to one.
#' @param main character. Main title.
#' @param col.left character. The color of left legend that is frequency of NA. default is "#009E73".
#' @param col.right character. The color of right legend that is percentage of NA. default is "#56B4E9".
#' @examples
#' # Generate data for the example
#' carseats <- ISLR::Carseats
#' carseats[sample(seq(NROW(carseats)), 20), "Income"] <- NA
#' carseats[sample(seq(NROW(carseats)), 5), "Urban"] <- NA
#' 
#' # Visualize pareto chart for variables with missing value.
#' plot_na_hclust(carseats)
#' plot_na_hclust(airquality)
#'   
#' 
#' # Visualize pareto chart for variables with missing value.
#' plot_na_hclust(mice::boys)
#' 
#' # Change the main title.
#' plot_na_hclust(mice::boys, main = "Distribution of missing value")
#' 
#' @importFrom reshape2 melt
#' @import ggplot2
#' @export
#' 
plot_na_hclust <- function (x, main = NULL, col.left = "#009E73", col.right = "#56B4E9")
{
  N <- nrow(x)
  
  na_obs <- x %>% 
    apply(1, function(x) any(is.na(x)))
  na_obs <- which(na_obs)
  
  na_variable <- x %>% 
    apply(2, function(x) any(is.na(x))) 
  na_variable <- names(na_variable[na_variable == TRUE])
  
  x <- x[na_obs, ] %>% 
    select_at(vars(na_variable)) %>% 
    is.na() %>% 
    as.matrix() + 0
  
  nr <- nrow(x)
  nc <- ncol(x)
  
  if (nr <= 1 || nc <= 1) 
    stop("'x' must have at least 2 rows and 2 columns")
  
  mean_row <- rowMeans(x, na.rm = TRUE)
  mean_col <- colMeans(x, na.rm = TRUE)
  
  dendro_row <- hclust(dist(x)) %>% 
    as.dendrogram() %>% 
    reorder(mean_row)
  
  if (nr != length(idx_row <- order.dendrogram(dendro_row))) 
    stop("row dendrogram ordering gave index of wrong length")
  
  dendro_col <- hclust(dist(t(x))) %>% 
    as.dendrogram() %>% 
    reorder(mean_col)
  
  if (nc != length(idx_col <- order.dendrogram(dendro_col))) 
    stop("column dendrogram ordering gave index of wrong length")
  
  x <- x[rev(idx_row), idx_col]
  
  dimnames(x)[[1]] <- seq(nr)
  
  na_cnt <- colSums(x)
  label_info <- data.frame(pos_x = 0, 
                           pos_y = seq(na_cnt), 
                           na_cnt = na_cnt,
                           na_pct = paste0(round(na_cnt / N * 100, 1), "%"))
  
  dframe <- reshape2::melt(t(x))
  dframe <- dframe[dframe$value != 0, ]
  
  if (is.null(main)) 
    main = "Distribution of missing value by combination of variables"
  
  ggplot(dframe, aes(x = Var2, y = Var1)) + 
    geom_raster(aes(fill = value)) + 
    scale_fill_gradient(low = "grey", high = "red") +
    geom_label(data = label_info, aes(x = 0, y = pos_y, label = na_cnt), 
               hjust = 1, fill = col.left, size = 3, colour = "white", 
               fontface = "bold") +
    geom_label(data = label_info, aes(x = nr + 2, y = pos_y, label = na_pct), 
               hjust = 0, fill = col.right, size = 3, colour = "white", 
               fontface = "bold") +
    labs(y = "Variables containing missing values", 
         x = "Observations", title = main) +
    theme(axis.text.x = element_text(size = 9, angle = 0, vjust = 0.3),
          axis.text.y = element_text(size = 10),
          plot.title = element_text(size = 11),
          legend.position = "none")
}


#' Pareto chart for missing value
#'
#' @description
#' Visualize pareto chart for variables with missing value.
#'
#' @param x data frames, or objects to be coerced to one.
#' @param only_na logical. The default value is FALSE. 
#' If TRUE, only variables containing missing values are selected for visualization. 
#' If FALSE, all variables are included.
#' @param relative logical. If this argument is TRUE, it sets the unit of the left y-axis to relative frequency. 
#' In case of FALSE, set it to frequency.
#' @param grade list. Specifies the cut-off to set the grade of the variable according to the ratio of missing values.
#' The default values are Good: [0, 0.05], OK: (0.05, 0.4], Bad: (0.4, 0.8], Remove: (0.8, 1].
#' @param main character. Main title.
#' @param col character. The color of line for display the cumulative percentage.
#' @param plot logical. If this value is TRUE then visualize plot. else if FALSE, return aggregate information about missing values.
#' @examples
#' # Generate data for the example
#' carseats <- ISLR::Carseats
#' carseats[sample(seq(NROW(carseats)), 20), "Income"] <- NA
#' carseats[sample(seq(NROW(carseats)), 5), "Urban"] <- NA
#'
#' # Diagnose the data with missing_count using diagnose() function
#' library(dplyr)
#' carseats %>% 
#'   diagnose %>% 
#'   arrange(desc(missing_count))
#' 
#' # Visualize pareto chart for variables with missing value.
#' plot_na_pareto(carseats)
#' plot_na_pareto(airquality)
#'   
#' # Diagnose the data with missing_count using diagnose() function
#' mice::boys %>% 
#'   diagnose %>% 
#'   arrange(desc(missing_count))
#' 
#' # Visualize pareto chart for variables with missing value.
#' plot_na_pareto(mice::boys, col = "darkorange")
#' 
#' # Visualize only variables containing missing values
#' plot_na_pareto(mice::boys, only_na = TRUE)
#' 
#' # Display the relative frequency 
#' plot_na_pareto(mice::boys, relative = TRUE)
#' 
#' # Change the grade
#' plot_na_pareto(mice::boys, grade = list(High = 0.1, Middle = 0.6, Low = 1))
#' 
#' # Change the main title.
#' plot_na_pareto(mice::boys, relative = TRUE, only_na = TRUE, 
#' main = "Pareto Chart for mice::boys")
#' 
#' # Return the aggregate information about missing values.
#' plot_na_pareto(mice::boys, only_na = TRUE, plot = FALSE)
#' 
#' @importFrom purrr map_int
#' @importFrom tibble enframe
#' @importFrom dplyr rename
#' @importFrom forcats fct_reorder
#' @import ggplot2
#' @export
plot_na_pareto <- function (x, only_na = FALSE, relative = FALSE, main = NULL, col = "black",
                            grade = list(Good = 0.05, OK = 0.4, Bad = 0.8, Remove = 1),
                            plot = TRUE)
{
  if (sum(is.na(x)) == 0) {
    stop("Data have no missing value.")
  }
  
  info_na <- purrr::map_int(x, function(x) sum(is.na(x))) %>% 
    tibble::enframe() %>% 
    dplyr::rename(variable = name, frequency = value) %>% 
    arrange(desc(frequency), variable) %>% 
    mutate(ratio = frequency / nrow(x)) %>% 
    mutate(grade = cut(ratio, breaks = c(-1, unlist(grade)), labels = names(grade))) %>% 
    mutate(cumulative = cumsum(frequency) / sum(frequency) * 100) %>% 
    mutate(variable = forcats::fct_reorder(variable, frequency, .desc = TRUE)) 
  
  if (only_na) {
    info_na <- info_na %>% 
      filter(frequency > 0)
    xlab <- "Variable Names with Missing Value"
  } else {
    xlab <- "All Variable Names"
  }
  
  if (relative) {
    info_na$frequency <- info_na$frequency / nrow(x)
    ylab <- "Relative Frequency of Missing Values"
  } else {
    ylab <- "Frequency of Missing Values"
  }
  
  if (is.null(main)) 
    main = "Pareto chart of variables with missing values"
  
  scaleRight <- max(info_na$cumulative) / info_na$frequency[1]
  
  if (!plot) {
    return(info_na)
  }
  
  ggplot(info_na, aes(x = variable)) +
    geom_bar(aes(y = frequency, fill = grade), stat = "identity") +
    geom_text(aes(y = frequency, 
                  label = paste(round(ratio * 100, 1), "%")),
              position = position_dodge(width = 0.9), vjust = -0.25) + 
    geom_path(aes(y = cumulative / scaleRight, group = 1), 
              colour = col, size = 0.4) +
    geom_point(aes(y = cumulative / scaleRight, group = 1), 
               colour = col, size = 1.5) +
    scale_y_continuous(sec.axis = sec_axis(~.*scaleRight, name = "Cumulative (%)")) +
    labs(title = main, x = xlab, y = ylab) + 
    theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust = 1),
          legend.position = "top")
}


#' Plot the combination variables that is include missing value
#'
#' @description
#' Visualize the combinations of missing value across cases.
#'
#' @details 
#' The visualization consists of four parts.
#' The bottom left, which is the most basic, visualizes the case of cross(intersection)-combination. 
#' The x-axis is the variable including the missing value, and the y-axis represents the case of a combination of variables.
#' And on the marginal of the two axes, the frequency of the case is expressed as a bar graph. 
#' Finally, the visualization at the top right expresses the number of variables including missing values in the data set, 
#' and the number of observations including missing values and complete cases .
#' 
#' @param x data frames, or objects to be coerced to one.
#' @param only_na logical. The default value is FALSE. 
#' If TRUE, only variables containing missing values are selected for visualization. 
#' If FALSE, included complete case.
#' @param n_intersacts integer. Specifies the number of combinations of variables including missing values. 
#' The combination of variables containing many missing values is chosen first.
#' @param n_vars integer. Specifies the number of variables that contain missing values to be visualized. 
#' The default value is NULL, which visualizes variables containing all missing values. 
#' If this value is greater than the number of variables containing missing values, 
#' all variables containing missing values are visualized. Variables containing many missing values are chosen first.
#' @param main character. Main title.
#' @examples
#' # Generate data for the example
#' carseats <- ISLR::Carseats
#' carseats[sample(seq(NROW(carseats)), 20), "Income"] <- NA
#' carseats[sample(seq(NROW(carseats)), 5), "Urban"] <- NA
#' 
#' # Visualize the combination variables that is include missing value.
#' plot_na_intersect(carseats)
#'   
#' # Diagnose the data with missing_count using diagnose() function
#' mice::boys %>% 
#'   diagnose %>% 
#'   arrange(desc(missing_count))
#' 
#' # Visualize the combination variables that is include missing value
#' plot_na_intersect(mice::boys)
#' 
#' # Visualize variables containing missing values and complete case
#' plot_na_intersect(mice::boys, only_na = FALSE)
#' 
#' # Using n_vars argument
#' plot_na_intersect(mice::boys, n_vars = 5) 
#' 
#' # Using n_intersacts argument
#' plot_na_intersect(mice::boys, only_na = FALSE, n_intersacts = 7)
#' 
#' @importFrom purrr map_int
#' @importFrom tibble enframe
#' @importFrom gridExtra grid.arrange
#' @importFrom reshape2 melt
#' @import ggplot2
#' @import dplyr
#' @export
plot_na_intersect <- function (x, only_na = TRUE, n_intersacts = NULL, 
                               n_vars = NULL, main = NULL)
{
  N <- nrow(x)
  
  if (sum(is.na(x)) == 0) {
    stop("Data have no missing value.")
  }
  
  if (only_na) {
    na_obs <- x %>% 
      apply(1, function(x) any(is.na(x))) %>% 
      which()
    
    x <- x[na_obs, ]
  } 
  
  marginal_var <- purrr::map_int(x, function(x) sum(is.na(x))) %>% 
    tibble::enframe(name = "name_var", value = "n_var") %>% 
    filter(n_var > 0) %>% 
    arrange(desc(n_var)) %>% 
    mutate(Var1 = seq(name_var))
  
  N_var_na <- nrow(marginal_var)
  
  if (!is.null(n_vars)) {
    marginal_var <- marginal_var %>% 
      head(n = n_vars)
  }
  
  na_variable <- marginal_var$name_var
  
  if (length(na_variable) == 1) {
    stop("Supported only when the number of variables including missing values is 2 or more.")
  }  
  
  x <- x %>% 
    select_at(vars(all_of(na_variable))) %>% 
    is.na() %>% 
    as.data.frame() %>% 
    group_by_at(na_variable) %>% 
    tally() %>% 
    arrange(desc(n))
  
  N_na <- sum(x$n[which(apply(select(x, -n), 1, sum) > 0)])
  
  if (!is.null(n_intersacts)) {
    if (n_intersacts < nrow (x)) {
      x <- x[seq(n_intersacts), ]
      x <- x[, which(apply(x, 2, function(x) sum(x) > 0))]
      
      marginal_var <- marginal_var %>% 
        filter(name_var %in% names(x)) %>% 
        mutate(Var1 = seq(name_var))
      
      na_variable <- setdiff(names(x), "n")
    }  
  }
  
  dframe <- reshape2::melt(t(x)) %>% 
    filter(value > 0) %>% 
    filter(!Var1 %in% c("n")) %>% 
    mutate(Var1 = as.numeric(Var1))
  
  flag <- x %>% 
    select(-n) %>% 
    apply(1, function(x) factor(ifelse(sum(x), "#F8766D", "#00BFC4")))
  
  marginal_obs <- data.frame(Var2 = seq(x$n), n_obs = x$n)
  
  N_complete <- N - N_na
  
  breaks <- pretty(marginal_obs$n_obs)
  
  if (is.null(main)) 
    main = "Missing information for intersection of variables"
  
  # Create center plot
  body <- ggplot(dframe, aes(x = Var1, y = Var2)) + 
    geom_tile(aes(fill = value), color = "black", size = 0.5) + 
    scale_fill_gradient(low = "grey", high = "red") +
    scale_x_continuous(breaks = seq(length(na_variable)), 
                       labels = na_variable,
                       limits = c(0, length(na_variable)) + 0.5) +
    scale_y_continuous(breaks = seq(nrow(marginal_obs)), 
                       labels = marginal_obs$Var2,
                       limits = c(0, nrow(marginal_obs)) + 0.5) +    
    xlab("Variables") +
    theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust = 1,
                                     family = "mono"),
          axis.title.y = element_blank(), axis.text.y = element_blank(),
          axis.ticks.y = element_blank(),
          legend.position = "none")
  
  # Create plot of top
  top <- ggplot(marginal_var, aes(x = Var1, y = n_var)) +
    geom_col(fill = "#F8766D") +
    scale_y_continuous(position = "right") + 
    scale_x_continuous(breaks = seq(marginal_var$Var1), 
                       labels = marginal_var$n_var,
                       limits = c(0, length(na_variable)) + 0.5) +
    ylab("Frequency") +
    theme(axis.ticks.x = element_blank(), axis.title.x = element_blank(),
          axis.title.y = element_blank(), axis.text.y = element_blank(),
          axis.ticks.y = element_blank())
  
  # for display the axis label
  max_char <- max(nchar(na_variable))
  
  formula <- paste0("%", max_char , "s")
  breaks_label <- sprintf(formula, breaks)
  
  # Create plot of right
  right <- ggplot(marginal_obs, aes(x = Var2, y = n_obs)) +
    geom_col(fill = flag) +
    coord_flip() +
    scale_x_continuous(breaks = seq(marginal_obs$Var2), 
                       labels = marginal_obs$n_obs,
                       limits = c(0, nrow(marginal_obs)) + 0.5) +    
    scale_y_continuous(breaks = breaks, 
                       labels = breaks_label,
                       limits = range(c(0, breaks))) +    
    ylab("Frequency") +
    theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust = 1, 
                                     family = "mono"),
          axis.ticks.y = element_blank(), axis.title.y = element_blank(),
          legend.position = "none")
  
  legend_txt <- paste(c("#Missing Vars:", "#Missing Obs:", "#Complete Obs:"), 
                      c(N_var_na, N_na, N_complete))
  legend_df <- data.frame(x = c(0.1, 0.1, 0.1), y = c(0.1, 0.3, 0.5), 
                          txt = factor(legend_txt, labels = legend_txt))
  
  # Create information plot
  blank <- ggplot(data = legend_df, aes(x, y, label = txt)) + 
    geom_label(fill = c("#00BFC4", "#F8766D", "#F8766D"), colour = "white", 
               fontface = "bold", size = 3, hjust = 0) + 
    xlim(c(0, 1)) +
    ylim(c(0, 0.6)) +
    theme(legend.position = "none",
          plot.background = element_blank(), 
          panel.grid.major = element_blank(),
          panel.grid.minor = element_blank(), 
          panel.border = element_blank(),
          panel.background = element_blank(),
          axis.title.x = element_blank(),
          axis.title.y = element_blank(),
          axis.text.x = element_blank(), 
          axis.text.y = element_blank(),
          axis.ticks = element_blank(),
          axis.line = element_blank()
    )
  
  gridExtra::grid.arrange(top, blank, body, right,
               ncol = 2, nrow = 2, widths = c(8, 2), heights = c(1, 5),
               top = main)
}  
