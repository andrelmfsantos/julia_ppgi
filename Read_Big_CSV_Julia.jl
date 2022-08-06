using Pkg
Pkg.add("CSV")

using Pkg
Pkg.add("DataFrames")

using CSV
using DataFrames

df = CSV.read("SUP_ALUNO_2019.CSV", DataFrame)

df1 = first(df, 4000000)
df1

df2 = df[4000000:8000000, :]
df2

df3 = df[8000000:end, :]
df3

# modifying the content of myfile.csv using write method
CSV.write("sup_aluno_2019p3.csv", df3)


