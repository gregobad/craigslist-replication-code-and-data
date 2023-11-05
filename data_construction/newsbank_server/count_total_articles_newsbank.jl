## Directory containing xml's
data_dir = "/data"

## local (writable) directory
local_dir = "/work"
temp_save_dir = "/work/mentionfiles"

## module loads
import CSV
using DataFrames
import Dates
import LightXML
import Base.Threads.@threads

## functions
function get_xml_files(d::String)
  filter(x -> occursin(r"\d{4}-\d{2}-\d{2}[.]xml", x), readdir(d; join=true))
end

function safe_parse(f::String) 
  try 
    LightXML.parse_file(f)
  catch
    LightXML.XMLDocument()
  end
end

function count_arts(xml) 
    try
        xroot = LightXML.root(xml)
        arts = xroot["doc"]
        return length(arts)
    catch
        return 0
    end
end


function count_articles_in_file(f::String)
  dt = Dates.Date(replace(f, r".*(\d{4}-\d{2}-\d{2})[.]xml$" => s"\g<1>"), Dates.DateFormat("y-m-d"))

  parsed = safe_parse(f)

  count = count_arts(parsed)
  
  LightXML.free(parsed)

  (date=dt, n = count)

end

function count_articles_in_dir(d::String)

  xmls = get_xml_files(d)

  results = [count_articles_in_file(xml) for xml in xmls] |> DataFrame

  if(nrow(results)>0)
    fname = string(temp_save_dir, "/", replace(replace(d, r"^[.]/" => s""), r"/" => s"_"), ".csv")
    CSV.write(fname, results)
  end

end


### BEGIN MAIN LOOP ###

cd(local_dir)


file_index = CSV.File("xml_directory_index.csv") |> DataFrame

file_index.year = parse.(Int, replace.(file_index.year_folder, r".*/(\d{4})$" => s"\g<1>"))
file_index.temp_save_file = string.(replace.(replace.(file_index.year_folder, r"^[.]/" => s""), r"/" => s"_"), ".csv")

# translation from newsbank to E&P
pbi_to_name = CSV.File("newsbank_folder_index.csv") |> DataFrame
nb_ep = CSV.File("nb_to_ep_all.csv") |> DataFrame
nb_ep.state = replace.(nb_ep.ep_std_name, r".*([A-Z]{2})$" => s"\1")

nb_ep = innerjoin(nb_ep, pbi_to_name, on = :paper)

# join paper info with file index 
file_index = innerjoin(file_index, nb_ep, on = :base_folder => :dir)



already_done = filter(x -> occursin(r"[.]csv$", x), readdir(temp_save_dir))

filter!(:temp_save_file => x -> !in(x, already_done), file_index)
filter!(:year => x -> x <= 2012, file_index)

loop_folders = file_index.year_folder

cd(data_dir)

## main loop
@threads for f in loop_folders
  print(string("Folder: ", f, "\n"))
  count_articles_in_dir(f)
end

## to combine & output as a single CSV
cd(temp_save_dir)
all_files = readdir()

joined_file = "$local_dir/newsbank_total_articles.csv"

function read_output(f::String)
  one_table = CSV.File(f) |> DataFrame
  select!(one_table, [:date, :n])
  one_table[!,:PBI] .= replace(f, r"([A-Z0-9]+)_([A-Z0-9]+)_(\d+).csv" => s"\g<1>")
  one_table
end

t0 = read_output(all_files[1]);
CSV.write(joined_file, t0);

for f in all_files[2:end]
  t = read_output(f);
  CSV.write(joined_file, t; append=true);
end
