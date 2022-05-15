# Adicionar Pacotes
using Pkg
Pkg.add("CSV"); Pkg.add("DataFrames"); Pkg.add("HTTP"); Pkg.add("Plots"); Pkg.add("PyPlot")

# Usar pacotes
using DataFrames, HTTP, CSV, Dates, Statistics, Plots

# Ler arquivo csv no github
using DataFrames, HTTP, CSV
resp = HTTP.request("GET", "https://raw.githubusercontent.com/andrelmfsantos/df/main/TweetsTratados_HBM_DatasetTweets48281Label1.csv?accessType=DOWNLOAD")
data = CSV.read(IOBuffer(String(resp.body)), DataFrame);
first(data,5)

# Subset com variáveis de interesse
df = select(data, :DATE, :N9SYMPTOMS, :N9FOLLOWERS, :N9FRIENDS);
last(df,5)

# Resumo 1 com dataframe transposto
permutedims(describe(df),1)

# Remove dados faltantes
df = dropmissing(df, :)
last(df,5)

# Resumo 2 com dataframe transposto
permutedims(describe(df),1)

# Renomear colunas
colnames = ["period", "symptoms","followers","friends"]
rename!(df, Symbol.(colnames))
first(df,5)

# Transformar series "period" em datetime
df.period = Date.(df.period, "yyyy-mm-dd HH:MM:SS")
first(df,5)

# Criar coluna mês
df = transform(df, :period => ByRow(month) => :mes)
first(df,5)

# Remover a coluna "period"
df = select(df, Not(:period))
first(df,5)

# Agrupar colunas pela média (symptoms) e soma (followers, friends)
gdf = groupby(df, :mes)
mdf = combine(gdf, [:symptoms, :followers, :friends] .=> mean; renamecols=false)
sdf = combine(gdf, [:symptoms, :followers, :friends] .=> sum; renamecols=false)
cdf = combine(groupby(df, [:mes]), nrow => :count)

# Remover a colunas em mdf e sdf
mdf = select!(mdf, [:mes,:symptoms]);
sdf = select!(sdf, Not(:symptoms));

# Agrupar dataframes
# mes:       Mês do tweet sobre sintomas da COVID-19
# symptoms:  Média de sintomas mencionados por tweet
# followers: Total de seguidores
# friends:   Total de amigos
# count:     Total de tweets
gdfs = innerjoin(mdf, sdf, cdf, on = :mes)

using Plots; gr()
#using Plots.PlotMeasures
axis_x1, axis_y1 = gdfs[:,:mes], gdfs[:,:count]
axis_x2, axis_y2 = gdfs[:,:mes], gdfs[:,:symptoms]
#bar(axis_x1, axis_y1, label = "Tweets", legend = :topright)
plot(axis_x1, axis_y1, ylabel = "Total de tweets no mês", color = :lightblue, right_margin=2cm, legend=(0.6, 0.9), fg_legend = :transparent, grid=false, seriestype = :bar)
plot!(twinx(), [axis_y2], ylabel = "Média de sintomas por tweet", color = :red, label = "Média de sintomas por tweet", legend=(0.6, 0.83), fg_legend = :transparent, seriestype = :line,size=(700,400))
title!("Menções de sintomas sobre Covid-19 no Twitter \n(Ano 2020)", titlefontsize = 12)
xaxis!("Mês")
#yaxis!("Tweets")


