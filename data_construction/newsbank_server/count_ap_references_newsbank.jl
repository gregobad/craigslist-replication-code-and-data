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

function count_mentions(pattern::Regex, texts::Array{String, 1})
  sum(occursin.(pattern, texts))
end

function safe_parse(f::String) 
  try 
    LightXML.parse_file(f)
  catch
    LightXML.XMLDocument()
  end
end

function safe_content(el::LightXML.XMLElement)
  LightXML.content(el)
end

function safe_content(el::Nothing)
  ""::String
end

function get_articles(xml)
  try
      xroot = LightXML.root(xml)
      xroot["doc"]
  catch
      LightXML.XMLElement[]
  end 
end

function get_counts_by_section(parsedXML, res)

  arts = get_articles(parsedXML)

  sects = replace.([LightXML.find_element(LightXML.find_element(a, "sourceInfo"), "section") |> safe_content for a in arts],
        r"\s+" => s" ")
  texts = [LightXML.find_element(a, "maintext") |> safe_content for a in arts]
                     
  auths = [LightXML.find_element(LightXML.find_element(a, "sourceInfo"), "author") |> safe_content for a in arts]

  
  fstparas = [split(t, "\n";limit=2)[1] for t in texts]


  # apply filters
  keep_inds = collect(1:length(arts))
  filter!(i -> texts[i] != "", keep_inds)    # nonmissing main text
  filter!(i -> !(occursin(r"Obit|Sport|Art|Entertain|Auto|Estate"i, sects[i])), keep_inds)  # exclude sports, obits, etc
  unique!(i -> texts[i], keep_inds)          # drop any duplicate articles

  sects = sects[keep_inds]
  texts = texts[keep_inds]
  auths = auths[keep_inds]
  fstparas = fstparas[keep_inds]

  fstpara_found = [occursin.(re, fstparas) for re in res]
  auth_found = [occursin.(re, auths) for re in res]

  any_found = max.(max.(fstpara_found...), max.(auth_found...))
  congress = occursin.(r"congress|senat|us house"i, texts)

  combine(groupby(DataFrame(section = sects, found = any_found, cong = congress), :section),
          :found => sum => :articles_wire_service,
          :found => length => :articles_searched,
          :cong => sum => :articles_congress)

end

function count_mentions_in_file(f::String, res::Array{Regex,1})

  if (occursin(r".*(\d{4}-\d{2}-\d{2})[.]xml$", f))
    dt = Dates.Date(replace(f, r".*(\d{4}-\d{2}-\d{2})[.]xml$" => s"\g<1>"), Dates.DateFormat("y-m-d"))
  else
    dt = Dates.Date("1900-01-01", Dates.DateFormat("y-m-d"))
  end

  parsed = safe_parse(f)
  
  counts = get_counts_by_section(parsed, res)

  LightXML.free(parsed)

  counts[!,:date] .= dt

  counts[counts.articles_searched .> 0,:]

end

function count_mentions_in_dir(d::String, res::Array{Regex, 1})

  print(string("Folder: ", d, "\n"))
  xmls = get_xml_files(d)

  results = vcat([count_mentions_in_file(xml, res) for xml in xmls]...)

  if(nrow(results) > 0)
    fname = string(temp_save_dir, "/", replace(replace(d, r"^[.]/" => s""), r"/" => s"_"), ".csv")
    CSV.write(fname, results)
  end

end


### BEGIN MAIN LOOP ###

cd(local_dir)

wire_res = [r"\bAP\b"i,
            r"Reuters"i,
            r"Associated Press"i]

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

@threads for f in loop_folders
  count_mentions_in_dir(f, wire_res)
end


## combine & output as a single CSV
cd(temp_save_dir)
all_files = readdir()

joined_file = "$local_dir/newsbank_ap_references.csv"

function read_output(f::String)
  one_table = CSV.File(f) |> DataFrame
  one_table[:,:PBI] .= replace(f, r"([A-Z0-9]+)_([A-Z0-9]+)_(\d+).csv" => s"\g<1>")
  one_table
end

t0 = read_output(all_files[1]);
CSV.write(joined_file, t0);

for f in all_files[2:end]
  t = read_output(f);
  CSV.write(joined_file, t; append=true);
end
