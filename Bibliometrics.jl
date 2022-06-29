#using Pkg
#Pkg.add("CSV"); Pkg.add("DataFrames"); Pkg.add("HTTP"); Pkg.add("Plots"); Pkg.add("PyPlot"); Pkg.add("StatsPlots"); Pkg.add("Distributions")

# Usar pacotes
using DataFrames, HTTP, CSV, Dates, Statistics, Plots, StatsPlots, Distributions

# Ler arquivo csv no github
#using DataFrames, HTTP, CSV
resp = HTTP.request("GET", "https://raw.githubusercontent.com/andrelmfsantos/df/main/savedrecs1.csv?accessType=DOWNLOAD")
df = CSV.read(IOBuffer(String(resp.body)), DataFrame);
first(df,5)

# Articles: total number of manuscripts
println("Manuscripts = ", nrow(df))

# Years: publication year of each manuscript
Manuscript_By_Year = combine(groupby(df, :PY), nrow)
Manuscript_By_Year = sort!(Manuscript_By_Year,:PY)
colnames = ["Year","Manuscripts"]
rename!(Manuscript_By_Year, Symbol.(colnames))

# Average publications per year
round(mean(Manuscript_By_Year.Manuscripts); digits = 2)

# Sources (Journals, Books, etc)
Source = combine(groupby(df, :SO), nrow)
Source = sort!(Source,:nrow, rev = true)
colnames = ["Source","Manuscripts"]
rename!(Source, Symbol.(colnames))

# Document Types: publications by kind of document
Document_Types = combine(groupby(df, :DT), nrow)
Document_Types = sort!(Document_Types,:nrow, rev = true)
colnames = ["Document Types","Total"]
Document_Types = rename!(Document_Types, Symbol.(colnames))

# Author by groups
AU_Group = combine(groupby(df, :AU), nrow)
AU_Group = sort!(AU_Group,:nrow, rev = true)
colnames = ["Authors","Manuscripts"]
AU_Group = rename!(AU_Group, Symbol.(colnames))

# Group of authors per document
round(mean(AU_Group.Manuscripts); digits = 2)

# Author per document
AU_Document = (split.(AU_Group.Authors,";"))
round(sum(length.(AU_Document))/nrow(AU_Group); digits = 2)

# Timespan
year_min = minimum(df.PY,dims=1)                              
year_max = maximum(df.PY,dims=1)                              
println("Timespan:\n","first year = ",year_min, "\nlast year = ",year_max)  

# Average citation per documents
round(mean(df.TC); digits = 2)
