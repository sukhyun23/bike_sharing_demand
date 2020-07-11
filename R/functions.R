day_profile_plot <- function(data, group, y, figsize = c(1,2)) {
  par(mfrow = figsize)
  data <- data[order(data$hour), ]
  for (i in sort(unique(data[[group]]))) {
    
    # plain plot
    plot(
      data$hour, data[[y]], 'n',
      main = paste(y, '\n', group, ' : ', i, ccollapse = ''),
      xlab = 'hour', ylab = y, xaxt='n'
    )
    axis(1, 0:23)
    
    # functions
    fill_na <- function(df) {
      h <- 0:23
      h_na <- h[!h %in% df$hour]
      if (length(h_na) >= 1) {
        na_dat <- data.frame(hour = h_na, y = NA, date = df$date[1])
        names(na_dat)[2] <- y
        df <- rbind(df, na_dat)
        df <- df[order(df$hour), ]
      } 
      return(df)
    }
    linef <- function(d) {
      lines(d$hour, d[[y]], col=alpha(1, 0.3))
    }
    
    # split by day
    dat_sub <- data[data[[group]] == i, c('hour', y, 'date'), with = F]
    d_list <- split(dat_sub, dat_sub$date)
    d_list <- lapply(d_list, fill_na)
    
    # plot
    lapply(d_list, linef)
    means <- tapply(dat_sub[[y]], dat_sub$hour, mean)
    lines(0:23, means, lwd=5, col='dodgerblue1')
  }
}

surface <- function(object, ...) UseMethod('surface')
surface.gam <- function(
  object, view = NULL, n.grid = 30, type = c('link', 'response')
) {
  # arguments
  type <- match.arg(type)
  varnames <- names(object$var.summary)
  if (is.null(view)) {
    view <- varnames[1:2]
  }
  others <- varnames[!varnames %in% view]
  viewclass <- sapply(object$var.summary[view], class)
  
  # others, central tendency
  # qualitative : mode, quantitative : median
  center <- function(x) {
    if (length(x) >= 2) return(x[2]) else return(x[1])
  }
  design_others <- as.data.frame(lapply(object$var.summary[others], center))
  
  # view, making grid matrix
  # qualitative : all, quantitative : expand min to max as many as n.grid
  expand <- function(x) {
    if (class(x) %in% c('integer', 'numeric')) {
      return(seq(x[1], x[3], length.out = n.grid)) # min, max
    } else { # (class(x) %in% c('factor', 'character'))
      return(x)
    }
  }
  
  grid <- lapply(object$var.summary[view], expand)
  v1 <- grid[[view[1]]]
  v2 <- grid[[view[2]]]
  
  design <- do.call(expand.grid, grid)
  if (nrow(design_others) >= 1) {
    design <- cbind(design, design_others)  
  }
  design$lp <- predict(object = object, newdata = design, type = type)
  z <- t(matrix(design$lp, ncol = n.grid, nrow = n.grid))
  
  # matrix
  plotly_obj <- plotly::plot_ly(x = v1, y = v2) 
  plotly_obj <- plotly::add_surface(p = plotly_obj, z = z)
  plotly_obj <- plotly::layout(
    p = plotly_obj,
    scene = list(
      xaxis = list(title = view[1]), 
      yaxis = list(title = view[2]),
      zaxis = list(title = type)
    )
  )
  return(plotly_obj)
}
