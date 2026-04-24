#' FuncSlide: Sliding Window Tools for Three-Dimensional Time Series
#'
#' @description
#' FuncSlide provides a small set of tools for processing sequential
#' three-dimensional data using sliding window methods. The package is designed
#' for data stored in CSV format with three numeric dimensions, such as x, y,
#' and z axes. It supports Euclidean vector construction, window-based
#' smoothing, binary direction detection, threshold-based filtering, and
#' visualization of raw and processed signals.
#'
#' @details
#' The package workflow is built around three main steps:
#'
#' \enumerate{
#'   \item Import a CSV file and construct a combined vector using the
#'   Euclidean norm.
#'   \item Apply window functions to consecutive sub-vectors of the time series.
#'   \item Visualize the original and processed series using ggplot2.
#' }
#'
#' FuncSlide separates the window operation from the sliding loop. This means
#' that functions such as \code{window_mean()}, \code{window_binary()}, and
#' \code{window_threshold()} operate on one window at a time, while
#' \code{sliding_window()} applies the selected window function
#' iteratively across the full series.
#'
#' @section Main functions:
#' \describe{
#'   \item{\code{acceleration_vector()}}{
#'   Reads a CSV file, converts the selected time column to POSIXct, and
#'   computes the Euclidean norm from three selected numeric columns.
#'   }
#'   \item{\code{window_mean()}}{
#'   Returns the mean value of a numeric window.
#'   }
#'   \item{\code{window_binary()}}{
#'   Returns +1 if the window increases and -1 if it decreases.
#'   }
#'   \item{\code{window_threshold()}}{
#'   Returns a threshold-based change value when positive or negative change
#'   exceeds a user-defined threshold.
#'   }
#'   \item{\code{sliding_window()}}{
#'   Iteratively applies a selected window function across a numeric column.
#'   }
#'   \item{\code{plot_sliding_window()}}{
#'   Plots the raw Euclidean vector and selected processed outputs.
#'   }
#' }
#'
#' @section Typical workflow:
#' \preformatted{
#' data <- acceleration_vector(
#'   file_path = "Example_window.csv",
#'   time_col = "time",
#'   x_col = "x",
#'   y_col = "y",
#'   z_col = "z"
#' )
#'
#' data <- sliding_window(
#'   data = data,
#'   column = "acceleration",
#'   window_size = 1000,
#'   window_fun = window_threshold,
#'   output_col = "threshold",
#'   threshold = 0.5
#' )
#'
#' plot_sliding_window(
#'   data = data,
#'   time_col = "time_posix",
#'   raw_col = "acceleration",
#'   show_threshold = TRUE
#' )
#' }
#'
#' @section Assumptions:
#' Input data should be sequential and contain three numeric columns
#' representing the dimensions to be combined. The time column should be either
#' numeric Unix time or otherwise convertible to POSIXct.
#'
#' @section Dependencies:
#' The plotting function uses ggplot2.
#'
#' @keywords internal
"_PACKAGE"

