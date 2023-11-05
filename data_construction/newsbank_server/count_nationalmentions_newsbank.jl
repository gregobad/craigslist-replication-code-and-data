## Directory containing xml's
data_dir = "/data"
## local (writable) directory
local_dir = "/work"
temp_save_dir = "/work/mentionfiles"

## module loads
import Base.Threads.@threads
import CSV
using DataFrames
import Dates
import LightXML

## functions
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

function get_xml_files(d::String)
  filter(x -> occursin(r"\d{4}-\d{2}-\d{2}[.]xml", x), readdir(d; join=true))
end

function count_mentions(pattern::Regex, texts::Array{String, 1})
  sum(occursin.(pattern, texts))
end

function index_mentions(pattern::Regex, texts::Array{String, 1})
  findall(occursin.(pattern, texts))
end

function count_mentions_in_file(f::String, res::Array{Regex,1})

  dt = Dates.Date("1900-01-01", Dates.DateFormat("y-m-d"))
  try
    dt = Dates.Date(replace(f, r".*(\d{4}-\d{2}-\d{2})[.]xml$" => s"\g<1>"), Dates.DateFormat("y-m-d"))
  catch
  end

  counts = DataFrame(pattern=res)

  parsed = safe_parse(f)

  try
    xroot = LightXML.root(parsed)

    arts = xroot["doc"]
    # extract main text and section info
    sects = [LightXML.find_element(LightXML.find_element(a, "sourceInfo"), "section") |> safe_content for a in arts]
    texts = [LightXML.find_element(a, "maintext") |> safe_content for a in arts]

    # apply filters
    keep_inds = collect(1:length(arts))
    filter!(i -> texts[i] != "", keep_inds)    # nonmissing main text
    filter!(i -> !(occursin(r"Obit|Sport|Art|Entertain|Auto|Estate"i, sects[i])), keep_inds)  # exclude sports, obits, etc
    unique!(i -> texts[i], keep_inds)          # drop any duplicate articles

    sects = sects[keep_inds]
    texts = texts[keep_inds]

    found = [index_mentions(p, texts) for p in res]

    counts[!,:article_inds] = join.(found, "|")
    counts[!,:article_count] = length.(found)

  catch
    counts[!,:article_inds] .= ""
    counts[!,:article_count] .= 0
  end

  LightXML.free(parsed)
  counts[!,:date] .= dt
  filter!(:article_count => c -> c > 0, counts) ### exclude implicit zeros

end

function count_mentions_in_dir(d::String, res::Array{Regex, 1})

  print(string("Folder: ", d, "\n"))
  xmls = get_xml_files(d)

  results = vcat([count_mentions_in_file(xml, res) for xml in xmls]...)

  if(nrow(results)>0)
    fname = string(temp_save_dir, "/", replace(replace(d, r"^[.]/" => s""), r"/" => s"_"), ".csv")
    CSV.write(fname, results)
  end

end


### BEGIN MAIN LOOP ###

cd(local_dir)

national_res = [r"(Leader|Dick) Gephardt",
                r"(Speaker|Nancy) Pelosi",
                r"(Speaker|Denn(y|is)) Hastert",
                r"(Leader|Dick) Armey",
                r"(Leader|Whip|Tom) DeLay",
                r"(Whip|Roy) Blunt",
                r"(Leader|John) Boehner",
                r"(Whip|Eric) Cantor",
                r"(Whip|Steny) Hoyer",
                r"(Whip|David) Bonior",
                r"(Jim|James) Clyburn",
                r"(Leader|Whip|Harry) Reid",
                r"(Leader|Dick) Durbin",
                r"(Whip|Tom) Daschle",
                r"(Whip|Don) Nickles",
                r"(Leader|Mitch) McConnell",
                r"(Leader|Bill) Frist",
                r"(Leader|Whip|Trent) Lott",
                r"(Whip|John) Kyl",
                r"(President|Bill) Clinton",
                r"(President|George W?\.? ?)Bush",
                r"(President|Barack) Obama"]


file_index = CSV.File("xml_directory_index.csv") |> DataFrame

# translation from newsbank to E&P
pbi_to_name = CSV.File("newsbank_folder_index.csv") |> DataFrame
nb_ep = CSV.File("nb_to_ep_all.csv") |> DataFrame
nb_ep.state = replace.(nb_ep.ep_std_name, r".*([A-Z]{2})$" => s"\1")

nb_ep = innerjoin(nb_ep, pbi_to_name, on = :paper)

# join paper info with file index 
file_index = innerjoin(file_index, nb_ep, on = :base_folder => :dir)

file_index.year = parse.(Int, replace.(file_index.year_folder, r".*/(\d{4})$" => s"\g<1>"))
file_index.temp_save_file = string.(replace.(replace.(file_index.year_folder, r"^[.]/" => s""), r"/" => s"_"), ".csv")

already_done = filter(x -> occursin(r"[.]csv$", x), readdir(temp_save_dir))

filter!(:temp_save_file => x -> !in(x, already_done), file_index)
filter!(:year => x -> x <= 2012, file_index)

loop_folders = file_index.year_folder

cd(data_dir)

@threads for f in loop_folders
  count_mentions_in_dir(f, national_res)
end

## to combine & output as a single CSV
cd(temp_save_dir)
all_files = readdir()

joined_file = "$local_dir/newsbank_nationalpol_mentions.csv"

function read_output(f::String)
  one_table = CSV.File(f) |> DataFrame
  select!(one_table, [:pattern, :date, :article_count, :article_inds])
  one_table[:,:PBI] .= replace(f, r"([A-Z0-9]+)_([A-Z0-9]+)_(\d+).csv" => s"\g<1>")
  one_table
end

t0 = read_output(all_files[1]);
CSV.write(joined_file, t0);

for f in all_files[2:end]
  t = read_output(f);
  CSV.write(joined_file, t; append=true);
end
