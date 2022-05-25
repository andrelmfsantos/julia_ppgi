# Adicionar Pacotes
#using Pkg
#Pkg.add("CSV"); Pkg.add("DataFrames"); Pkg.add("HTTP"); Pkg.add("Plots"); Pkg.add("PyPlot"); Pkg.add("StatsPlots"); Pkg.add("GLMakie"); Pkg.add("CairoMakie"); Pkg.add("Distributions")

# Usar pacotes
using DataFrames, HTTP, CSV, Dates, Statistics, Plots, StatsPlots, CairoMakie, Distributions

# Ler arquivo csv no github
#using DataFrames, HTTP, CSV
resp = HTTP.request("GET", "https://raw.githubusercontent.com/andrelmfsantos/df/main/TweetsTratados_HBM_DatasetTweets48281Label1.csv?accessType=DOWNLOAD")
data = CSV.read(IOBuffer(String(resp.body)), DataFrame);
first(data,5)

# Subset com variáveis de interesse
df = select(data, :DATE, :N9SYMPTOMS, :N9FOLLOWERS, :N9FRIENDS);
colnames = ["period", "symptoms","followers","friends"]
rename!(df, Symbol.(colnames))
last(df,5)

# Remove dados faltantes
df = dropmissing(df, :)
last(df,5)

# Transformar series "period" em datetime
df.period = Date.(df.period, "yyyy-mm-dd HH:MM:SS")
first(df,5)

# Criar coluna mês
df = transform(df, :period => ByRow(month) => :mes)
# Remover a coluna "period"
df = select(df, Not(:period))
first(df,5)

# Agrupar colunas pela soma (followers, friends)
gdf = groupby(df, :mes)
sdf = combine(gdf, [:symptoms, :followers, :friends] .=> sum; renamecols=false)
sdf

#import Pkg
#Pkg.add("GLMakie"); Pkg.add("CairoMakie"); Pkg.add("Distributions")

#using CairoMakie, Distributions

#using CairoMakie

x = sdf.mes
y1 = sdf.followers
y2 = sdf.friends

lines(x, y1, color = :red, markersize = 5, label = "Seguidores")
lines!(x, y2, color = :blue, markersize = 10, label = "Amigos")
axislegend()
current_figure()

# Base para histograma
println(nrow(data))
dh = select(data, :DATE, :N9SYMPTOMS, :N9FOLLOWERS, :N9FRIENDS)
colnames = ["period", "symptoms","followers","friends"]
rename!(dh, Symbol.(colnames))
dh = dropmissing(dh, :)
println(nrow(dh))
# Transformar series "period" em datetime
dh.period = Date.(dh.period, "yyyy-mm-dd HH:MM:SS")
# Criar coluna mês
dh = transform(dh, :period => ByRow(month) => :mes)
dh = transform(dh, :period => ByRow(dayofweek) => :DiaSemana)
dh = transform(dh, :period => ByRow(dayofmonth) => :DiaMes)
first(dh,5)

#using CairoMakie

x = dh.DiaMes

w = pdf.(Normal(), x)

fig = Figure()
hist(fig[1,1], x)
hist(fig[1,2], x, weights = w)

fig

# Boxplot
#using CairoMakie

xs = dh.DiaMes
ys = dh.friends

CairoMakie.boxplot(xs, ys)

@df dh StatsPlots.corrplot(
    cols([:DiaMes, :followers, :friends]);
    size=(800,600),
    plot_title="Correlation Plot"
)

#using CairoMakie, Distributions

x = dh.mes
y = dh.DiaSemana

w = pdf.(Normal(), x .- y)

fig = Figure()

CairoMakie.violin(fig[1,1], x, y)
CairoMakie.violin(fig[1,2], x, y, weights = w)

fig
