#' Construct vector time-series from multidimensional data
#'
#' Reads a CSV file, converts the selected time column to POSIXct,
#' and computes a combined vector magnitude using the Euclidean norm.
#'
#' @param file_path Character. Path to the CSV file.
#' @param time_col Integer or character. Column index or name for the time column.
#' @param x_col Integer or character. Column index or name for the first dimension.
#' @param y_col Integer or character. Column index or name for the second dimension.
#' @param z_col Integer or character. Column index or name for the third dimension.
#' @param tz Character. Time zone used when converting time. Default is "UTC".
#'
#' @return A data frame with added columns:
#' \describe{
#'   \item{time_posix}{Converted POSIXct time column}
#'   \item{acceleration}{Euclidean magnitude of the three dimensions}
#' }
#'
#' @examples
#' \dontrun{
#' data <- acceleration_vector(
#'   file_path = "data/Example_window.csv",
#'   time_col = "time",
#'   x_col = "x",
#'   y_col = "y",
#'   z_col = "z"
#' )
#' }
#' @export
acceleration_vector <- function(file_path, time_col, x_col, y_col, z_col, tz = "UTC") {
  #Load a time series object
  data <- read.csv(file_path)

  #Convert the “time” column to POSIXct or POSIXlt format
  data$time_posix <- as.POSIXct(data[[time_col]], origin = "1970-01-01", tz = tz)

  #Generate the combined vector from the x, y and z axes
  data$acceleration <- sqrt(data[[x_col]]^2 + data[[y_col]]^2 + data[[z_col]]^2)

  #Return a data frame
  data
}



#' Compute mean value of a window
#'
#' Calculates the mean of a numeric vector representing a window.
#'
#' @param x Numeric vector representing one window of data.
#'
#' @return Numeric value equal to the mean of the window.
#'
#' @examples
#' window_mean(c(1, 2, 3, 4))
#' window_mean(c(0.5, 0.7, 0.6))
#' @export
window_mean <- function(x) {
  mean(x, na.rm = TRUE)
}



#' Determine direction of change in a window
#'
#' Returns +1 if the window shows an increase,
#' and -1 if it shows a decrease.
#'
#' @param x Numeric vector representing one window of data.
#'
#' @return Numeric value: +1 or -1.
#'
#' @examples
#' window_binary(c(1, 2, 3))
#' window_binary(c(3, 2, 1))
#' @export
window_binary <- function(x) {

  # Ensure window has at least 2 values
  if (length(x) < 2) {
    return(NA_real_)
  }

  # Compare last and first value to assess +/- in acceleration
  if (tail(x, 1) > x[1]) {
    return(1)
  } else if (tail(x, 1) < x[1]) {
    return(-1)
  } else {
    return(0)
  }
}



#' Detect threshold-based change in a window
#'
#' Returns the largest change in the window relative to the first value
#' if it exceeds a given threshold. If both positive and negative changes
#' exceed the threshold, the largest absolute change is returned.
#' If no change exceeds the threshold, the function returns 0.
#'
#' @param x Numeric vector representing one window of data.
#' @param threshold Numeric value defining the minimum change required.
#'
#' @return Numeric value representing the largest qualifying change,
#' or 0 if no threshold is exceeded.
#'
#' @examples
#' window_threshold(c(1.0, 1.6, 1.2), threshold = 0.5)
#' window_threshold(c(1.0, 0.3, 1.7), threshold = 0.5)
#' window_threshold(c(1.0, 1.2, 1.1), threshold = 0.5)
#' @export
window_threshold <- function(x, threshold) {

  # A window needs at least 2 values
  if (length(x) < 2) {
    return(NA_real_)
  }

  # Differences relative to the first value
  diffs <- x - x[1]

  # Largest increase and largest decrease
  max_increase <- max(diffs, na.rm = TRUE)
  max_decrease <- min(diffs, na.rm = TRUE)

  # Collect qualifying candidates; Empty vector
  candidates <- c()

  if (max_increase >= threshold) {
    candidates <- c(candidates, max_increase)
  }

  if (abs(max_decrease) >= threshold) {
    candidates <- c(candidates, max_decrease)
  }

  # If nothing exceeds threshold
  if (length(candidates) == 0) {
    return(0)
  }

  # Return the largest absolute change
  candidates[which.max(abs(candidates))]
}



#' Apply a sliding window function across a series
#'
#' Iteratively applies a selected window function to consecutive windows
#' in a chosen column of a data frame and stores the results in a new column.
#'
#' @param data Data frame containing the time series.
#' @param column Character. Name of the column to process.
#' @param window_size Integer. Number of observations in each window.
#' @param window_fun Function to apply to each window.
#' @param output_col Character. Name of the output column to create.
#' @param ... Additional arguments passed to the window function.
#'
#' @return A data frame with an added output column containing the sliding
#' window results.
#'
#' @examples
#' \dontrun{
#' data <- sliding_window(
#'   data = data,
#'   column = "acceleration",
#'   window_size = 100,
#'   window_fun = window_mean,
#'   output_col = "mean"
#' )
#' }
#' @export
sliding_window <- function(data, column, window_size, window_fun, output_col, ...) {

  n <- nrow(data)

  # Fill with NA for numeric type
  data[[output_col]] <- NA_real_

  # Starting point of the last window
  last_start <- n - window_size + 1

  # Guard clause
  if (last_start < 1) {
    stop("Window_size is larger than the number of rows in the data.")
  }

  # Move a window across the data, compute something, and store the result
  for (i in 1:last_start) {

    window <- data[[column]][i:(i + window_size - 1)]

    result <- window_fun(window, ...)

    data[[output_col]][i] <- result
  }

  data
}



#' Plot raw and processed time-series signals
#'
#' Creates a line plot of the combined vector signal together with
#' selected processed columns such as mean, binary, or threshold.
#'
#' @param data Data frame containing the time series and processed columns.
#' @param time_col Character. Name of the time column to use on the x-axis.
#' @param raw_col Character. Name of the raw combined signal column.
#' @param show_mean Logical. If TRUE, plot the mean column.
#' @param show_binary Logical. If TRUE, plot the binary column.
#' @param show_threshold Logical. If TRUE, plot the threshold column.
#'
#' @return A ggplot object.
#'
#' @examples
#' \dontrun{
#' plot_sliding_window(
#'   data = data,
#'   time_col = "time_posix",
#'   raw_col = "acceleration",
#'   show_threshold = TRUE
#' )
#' }
#' @export
plot_sliding_window <- function(data,
                                time_col = "time_posix",
                                raw_col = "acceleration",
                                show_mean = FALSE,
                                show_binary = FALSE,
                                show_threshold = FALSE) {

  p <- ggplot2::ggplot(data, ggplot2::aes(x = .data[[time_col]])) +
    ggplot2::geom_line(
      ggplot2::aes(y = .data[[raw_col]], color = "Raw"),
      na.rm = TRUE
    )

  if (show_mean && "mean" %in% names(data)) {
    p <- p + ggplot2::geom_line(
      ggplot2::aes(y = mean, color = "Mean"),
      na.rm = TRUE
    )
  }

  if (show_binary && "binary" %in% names(data)) {
    p <- p + ggplot2::geom_line(
      ggplot2::aes(y = binary, color = "Binary"),
      na.rm = TRUE
    )
  }

  if (show_threshold && "threshold" %in% names(data)) {
    p <- p + ggplot2::geom_line(
      ggplot2::aes(y = threshold, color = "Threshold"),
      na.rm = TRUE
    )
  }

  # Attach scale to p; for legend
  p <- p + ggplot2::scale_color_manual(
    values = c(
      "Raw" = "black",
      "Mean" = "blue",
      "Binary" = "green",
      "Threshold" = "red"
    )
  )

  # Labels
  p <- p + ggplot2::labs(
    x = "Time",
    y = "Acceleration",
    title = "Sliding Window Analysis of Acceleration Data",
    color = "Signal"
  )

  p
}
