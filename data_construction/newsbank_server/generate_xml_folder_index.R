library(data.table)

source_dirs <- list.dirs(path = "/data/", recursive=F)

get_year_dirs <- function(d) {
  dirs <- list.dirs(d)
  dirs[grep("/\\d{4}$", dirs)]
}

file_index <- data.table(base_folder = source_dirs)[,
  .(year_folder = get_year_dirs(base_folder)),
  by=.(base_folder)]
file_index[,dir_id := 1:.N]

file_index[, base_folder := sub("/data//", "./", base_folder)]
file_index[, year_folder := sub("/data//", "./", year_folder)]

fwrite(file_index, "/work/xml_directory_index.csv")
