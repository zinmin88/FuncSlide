#' Sum Function
#'
#' Adds three numeric vectors element-wise.
#'
#' @param x Numeric vector.
#' @param y Numeric vector.
#' @param z Numeric vector.
#'
#' @return Numeric vector representing the sum of x, y, and z.
#' @examples
#' testing_1(1, 2, 3)
#' testing_1(c(1, 2), c(3, 4), c(5, 6))
#' @export
testing_1 <- function(x, y, z) {
  x + y + z
}

#' Multiplication Function
#'
#' Multiplies two numeric vectors element-wise.
#'
#' @param x Numeric vector.
#' @param y Numeric vector.
#'
#' @return Numeric vector representing the product of x and y.
#' @examples
#' testing_2(2, 3)
#' testing_2(c(1, 2), c(3, 4))
#' @export
testing_2 <- function(x, y) {
  x * y
}
