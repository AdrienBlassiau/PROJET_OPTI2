"""
Author : Dimitri Watel
Projet OPTIMISATION 2 - ENSIIE - 2019-2020
"""

# Ne pas enlever
include("./main.jl")

######
# VOTRE CODE


println("Chargement de JuMP")
using JuMP
println("Chargement de Cbc")
using Cbc
println("Chargé")

######

@doc """
Modifie la solution sol de l'instance inst avec l'algorithme suivant

Cette fonction fait n'importe quoi, c'est juste un exempel de programme linéaire.

Cette fonction peut renvoyer n'importe quel type de variable (dont rien du tout), qui sera ensuite traité dans post_process.
""" ->
function run(inst, sol)
  ω = inst.ω
  ma = inst.ma
  wa = inst.wa
  ha = inst.ha
  n = inst.n
  h = inst.h
  w = inst.w

  m = Model(with_optimizer(Cbc.Optimizer,logLevel = 0))

  @variable(m, P[1:n])
  @variable(m, y[1:n, 1:h, 1:w], Bin)
  @variable(m, z[1:n, 1:h, 1:w], Bin)
  @variable(m, c[1:n], Bin)

  ## Constraint C1
  for i in 1:n
    @constraint(m, P[i] <= ma[i])
  end

  ## Constraint C2
  for i in 1:n
    @constraint(m, P[i] <= sum(sum(ω[l][c]*y[i,l,c] for l in 1:h) for c in 1:w))
  end

  ## Constraint C3
  for l in 1:h
    for c in 1:w
      @constraint(m, sum(y[i,l,c] for i in 1:n) <= 1)
    end
  end

  ## Constraint C4
  for i in 1:n
    @constraint(m, sum(sum(z[i,l,c] for l in 1:h) for c in 1:w) <= 1)
  end

  ## Constraint C5
  for i in 1:n
    for l1 in 1:h
      for c1 in 1:w
        @constraint(m, z[i,l1,c1] <= y[i,l1,c1])
      end
    end
  end

  ## Constraint C6
  for i in 1:n
    for l2 in 1:h
      for c2 in 1:w
        @constraint(m, y[i,l2,c2] <= sum(sum(z[i,l1,c1] for l1 in max(l2-ha[i]+1,1):l2) for c1 in max(c2-wa[i]+1,1):c2))
      end
    end
  end

  ## Constraint C7
  for i in 1:n
    for l1 in 1:h
      for c1 in 1:w
        @constraint(m, z[i,l1,c1] <= c[i])
      end
    end
  end

  ## Constraint C8
  for i in 1:n
    @constraint(m, sum(sum(y[i,l,c] for l in 1:h) for c in 1:w) == wa[i]*ha[i]*c[i])
  end


  @objective(m, Max, sum(P[i] for i in 1:n))
  optimize!(m)

  return (m, P, y, z, c)
end

@doc """
Cette fonction est appelée après la fonction `run` et permet de faire de l'affichage et des traitement sur la sortie de la fonction `run` ; sans pour autant affecter son temps de calcul.

Le paramètre cpu time est le temps de calcul de `run`. Les valeurs de `inst` et `sol` sont les mêmes qu’à la sortie de la fonction run. Enfin, `others` est ce qui est renvoyé par la fonction `run`. Vous pouvez ainsi effectuer des tests et afficher des résultats sans affecter le temps de calcul.
""" ->
function post_process(cpu_time::Float64, inst, sol, others)

  # Run a renvoyé le modèle et ses variables, qui ont été mis dans others.
  m, P, y, z, c = others

  # print(m)

  # println()

  # println("TERMINAISON : ", termination_status(m))
  println("OBJECTIF : $(objective_value(m))")
  # println("VALEURS de P : $(value.(P))")
  # println("VALEURS de y : $(value.(y))")
  # println("VALEURS de z : $(value.(z))")
  # println("VALEURS de c : $(value.(c))")

  println("Temps de calcul : $cpu_time.")

end

# Ne pas enlever
if length(ARGS) > 0
  input_file = ARGS[1]
  main(input_file)
end

