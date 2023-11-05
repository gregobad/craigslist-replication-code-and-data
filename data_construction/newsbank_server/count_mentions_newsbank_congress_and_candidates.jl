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

function index_mentions(pattern::Regex, texts::Array{String, 1})
  findall(occursin.(pattern, texts))
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

function memberregex(chamber, searchname)
    occursin("sen", chamber) ? Regex("sen([.]|at[a-z.,]*) $searchname", "i") : Regex("(congres[a-z.,]*|rep([.]|resentative)|member( of the house)?) $searchname", "i")
end

function get_articles(xml)
    try
        xroot = LightXML.root(xml)
        xroot["doc"]
    catch
        LightXML.XMLElement[]
    end 
end


function count_mentions_in_file(f::String, st::String, people::DataFrame)
    if (occursin(r".*(\d{4}-\d{2}-\d{2})[.]xml$", f))
        dt = Dates.Date(replace(f, r".*(\d{4}-\d{2}-\d{2})[.]xml$" => s"\g<1>"), Dates.DateFormat("y-m-d"))
    else
        dt = Dates.Date("1900-01-01", Dates.DateFormat("y-m-d"))
    end

    to_include = filter([:start_date, :end_date] => (x, y) -> (x <= dt) & (y >= dt), people)
    filter!(:state => s -> s == st, to_include)  # limit to members / candidates in the same state

    to_include_inc = filter(:incumbent => ==(1), to_include)
    transform!(to_include_inc, 
        [:office, :searchname] => ByRow(memberregex) => :pattern)

    select!(to_include, [:id, :office, :state, :district, :incumbent, :searchname])
    select!(to_include_inc, [:id, :office, :state, :district, :incumbent, :searchname, :pattern])

    parsed = safe_parse(f)

    arts = get_articles(parsed)

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

    # for incumbents, search with title in all articles
    found = [index_mentions(p, texts) for p in to_include_inc.pattern]

    to_include_inc[!,:found] = found

    # for incumbents + challengers, search name only in articles containing key words
    congress_arts = findall(occursin.(r"congress|senat|us house"i, texts))

    found = [congress_arts[index_mentions(p, texts[congress_arts])] for p in Regex.(to_include.searchname, "i")]

    to_include[!,:found] = found

    LightXML.free(parsed)

    # append the two search types
    select!(to_include_inc, Not(:pattern))
    append!(to_include, to_include_inc)

    # output, collapsing to member level
    to_include[!,:date] .= dt
    filter!(:found => inds -> length(inds) > 0, to_include) ### exclude implicit zeros

    select(
        combine(groupby(to_include, [:id, :office, :state, :district, :incumbent, :date]),
                :found => x -> Ref(unique(reduce(append!, x, init = Int[]))); renamecols = false),
        [:id, :office, :state, :district, :incumbent, :date],
        :found => (inds -> length.(inds)) => :article_count,
        :found => (inds -> join.([sects[i] for i in inds], "|")) => :article_sects,
        :found => (inds -> join.(inds, "|")) => :article_inds)
end

function count_mentions_in_dir(d::DataFrameRow)

  xmls = get_xml_files(d.year_folder)

  results = vcat([count_mentions_in_file(xml, d.state, cands) for xml in xmls]...)

  fname = string(temp_save_dir, "/", replace(replace(d.year_folder, r"^[.]/" => s""), r"/" => s"_"), ".csv")
  
  CSV.write(fname, results)

end


### BEGIN MAIN LOOP ###

cd(local_dir)

cands = CSV.File("congressional_candidate_and_incumbent_names.csv") |> DataFrame

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

## main loop
@threads for f in eachrow(file_index)
  print(string("Folder: ", f.year_folder, "\n"))
  count_mentions_in_dir(f)
end

## to combine & output as a single CSV
cd(temp_save_dir)
all_files = readdir()

joined_file = "$local_dir/newsbank_congress_and_candidate_mentions.csv"

function read_output(f::String)
  one_table = CSV.File(f) |> DataFrame
  select!(one_table, [:id, :office, :state, :district, :incumbent, :date, :article_count, :article_inds, :article_sects])
  one_table[!,:PBI] .= replace(f, r"([A-Z0-9]+)_([A-Z0-9]+)_(\d+).csv" => s"\g<1>")
  one_table
end

t0 = read_output(all_files[1]);
CSV.write(joined_file, t0);

for f in all_files[2:end]
  t = read_output(f);
  CSV.write(joined_file, t; append=true);
end
