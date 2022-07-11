# 1. Paste files into files directory
# 2. CSV files will be created in specified output_directory (default: output)

library(read.gt3x)

list_files <- function(input_directory) {
    files <- list.files(paste(".", "files", sep = "/"))
    return(files)
}

transformENMO <- function(data, sample_frequency, window) {
    x <- data[, 2]
    y <- data[, 3]
    z <- data[, 4]
    ENMO <- sqrt(x^2 + y^2 + z^2) - 1
    ENMO[which(ENMO < 0)] <- 0
    ENMO2 <- cumsum(ENMO)
    ENMO3 <- diff(ENMO2[seq(1, length(ENMO), by = (sample_frequency * window))]) / (sample_frequency * window)

    return(ENMO3)
}

to_csv <- function(df, path, output_directory) {
    write.csv(df, paste(output_directory, path, sep = "/"))
}


parse_gt3x <- function(file, input_directory, output_directory) {
    split_string_v <- unlist(strsplit(file, "[.]"))
    split_filename <- split_string_v[-length(split_string_v)]

    data <- read.gt3x(paste(input_directory, file, sep = "/"))

    df <- as.data.frame(data)

    sample_rate <- attributes(df)[setdiff(names(attributes(df)), c("row.names"))]$sample_rate

    ENMO <- transformENMO(df, sample_rate, 1)

    to_csv(ENMO, paste(split_filename, ".csv", sep = ""), output_directory = output_directory)
}

main <- function(input_directory, output_directory) {
    dir.create(file.path(".", "output"), showWarnings = FALSE)

    files <- list_files(input_directory)

    sapply(files, parse_gt3x, input_directory = input_directory, output_directory = output_directory)
}

main("files", "output")
