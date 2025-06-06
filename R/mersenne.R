if (!require("bitops", quietly = TRUE)) {
  install.packages("bitops")
  library(bitops)
}

.mt_env <- new.env()

mt_init <- function(seed = 5489) {
  .mt_env$mt <- numeric(624)
  .mt_env$idx <- 1L
  .mt_env$mt[1] <- as.numeric(bitwAnd(as.integer(seed), 0xFFFFFFFF))
  
  for (i in 2:624) {
    temp <- bitwXor(.mt_env$mt[i-1], bitwShiftR(.mt_env$mt[i-1], 30))
    .mt_env$mt[i] <- as.numeric(bitwAnd(1812433253 * temp + (i-1), 0xFFFFFFFF))
  }
}

mt_generate <- function(n = 1) {
  if (.mt_env$idx > 624) {
    for (i in 1:624) {
      x <- bitwOr(
        bitwAnd(as.integer(.mt_env$mt[i]), 0x80000000),
        bitwAnd(as.integer(.mt_env$mt[i %% 624 + 1]), 0x7FFFFFFF)
      )
      xA <- bitwShiftR(x, 1)
      if (bitwAnd(x, 1)) xA <- bitwXor(xA, 0x9908B0DF)
      .mt_env$mt[i] <<- bitwXor(as.integer(.mt_env$mt[(i + 396) %% 624 + 1]), xA)
    }
    .mt_env$idx <<- 1
  }
  
  res <- numeric(n)
  for (i in 1:n) {
    y <- as.integer(.mt_env$mt[.mt_env$idx])
    y <- bitwXor(y, bitwShiftR(y, 11))
    y <- bitwXor(y, bitwAnd(bitwShiftL(y, 7), 0x9D2C5680))
    y <- bitwXor(y, bitwAnd(bitwShiftL(y, 15), 0xEFC60000))
    y <- bitwXor(y, bitwShiftR(y, 18))
    res[i] <- min(y / 4294967296.0, 0.999999999)
    .mt_env$idx <<- .mt_env$idx + 1
  }
  res
}

mt_set_seed <- function(seed) {
  if (!is.numeric(seed)) stop("La semilla debe ser numérica")
  mt_init(seed)
}
