# Instalar pacotes
using Pkg
Pkg.add("JuMP") # pacote para otimização matemática
Pkg.add("GLPK") # solver

# Carregar pacotes
using JuMP
using GLPK

# Definir o modelo
BM = Model() # Modelo

# Configurar o otimizador
set_optimizer(BM,GLPK.Optimizer)

# Definir variáveis
@variable(BM, x1>=0)
@variable(BM, x2>=0)
@variable(BM, x3>=0)
@variable(BM, x4>=0)
@variable(BM, x5>=0)

# Definir restrições
@constraint(BM, x1+x2+x3+x4+x5<=12)
@constraint(BM, 0.4x1+0.4x2+0.4x3-0.6x4-0.6x5<=0)
@constraint(BM, 0.5x1+0.5x2-x3<=0)
@constraint(BM, 0.06x1+0.03x2-0.01x3+0.01x4-0.02x5<=0)

# Definir função objetivo
@objective(BM, Max, 0.026x1+0.0509x2+0.0864x3+0.06875x4+0.078x5)

# Executar modelo
optimize!(BM)

# Saída do modelo:
BM

# Valor da função objetivo (lucro do banco em milhões de dólares):
objective_value(BM)

# Sensibilidade
objective_sense(BM)

# Variáveis otimizadas:
println("x1 = ", value.(x1),
    "\n","x2 = ",value.(x2),
    "\n", "x3 = ",value.(x3),
    "\n", "x4 = ",value.(x4),
    "\n", "x5 = ",value.(x5))
