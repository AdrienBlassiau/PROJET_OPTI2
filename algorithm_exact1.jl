"""
Author : Adrien BLASSIAU Corentin JUVIGNY Jiahui XU
Projet OPTIMISATION 2 - ENSIIE - 2019-2020
"""

# Ne pas enlever
include("./main.jl")

######
# VOTRE CODE


# Vous pouvez mettre du code ici, il n'est pas nécessaire de mettre tout votre code dans la fonction run, ce serait illisible.
#
# Vous pouvez mettre des fonctions, des variables globales (attention à ne pas faire n'importe quoi, des modules, ...
#

######

@doc """
Cette fonction recherche de manière récursive la meilleur solution au problème
en explorant tout les arrangement possible de n éléments parmi H*L.

Le paramètre inst correspond à l'instance du problème, ann à l'anonceur courant que l'on essaye de placer, sol à la solution courante, profit_max au meilleur profit trouvé pour le moment et sol_max à la meilleur solution trouvée pour le moment.

Cette fonction renvoie profit_max qui est le meilleur profit trouvé pour le moment et sol_max qui est la meilleur solution trouvée pour le moment.
""" ->
function rec_classical_run(inst,ann,sol,profit_max,sol_max)
	# global profit_max
	# global sol_max

	if ann > inst.n
		gain=profit(sol)
		# println("Profit de la grille: ",gain,"et ",profit_max)
		if (gain >= profit_max)
			profit_max = gain
			sol_max = deepcopy(sol)
			return profit_max,sol_max
		else
			return profit_max,sol_max
		end
	else
		for i in 1:inst.h
			for j in 1:inst.w
				place(sol, ann, i, j)
				# println(ann,"/",i,"/",j)
				(profit_max,sol_max) = rec_classical_run(inst,ann+1,sol,profit_max,sol_max)
				remove(sol,ann)
			end
		end
		return profit_max,sol_max
	end
end

@doc """
Cette fonction recherche de manière rapide la meilleur solution au problème.
On trie tout d'abord la matrice, que l'on a redimensionnée en un vecteur, des
couts les plus élevés au plus faible. On trie les annonceurs en fonction du
prix qu'ils sont prêts à mettre dans l'ordre décroissant.
On itère sur les case de la matrice triée en essayant d'y placer l'annonceur
de cout le plus élevé. On s'arrête quand tout les annonceurs sont placés
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
println("Chargement de GLPK")
using GLPK
println("Chargé")

######

@doc """
Modifie la solution sol de l'instance inst avec l'algorithme suivant

Cette fonction fait n'importe quoi, c'est juste un exempel de programme linéaire.

Cette fonction peut renvoyer n'importe quel type de variable (dont rien du tout), qui sera ensuite traité dans post_process.
""" ->
function run(inst, sol)
  m = Model(with_optimizer(GLPK.Optimizer))
  @variable(m, x[1:10], Bin)
  @variable(m, y, Int)
  @variable(m, z[i in 1:5] >= i)

  for i in 1:10
    @constraint(m, x[i] + sum(z[j] for j in 1:5 if j % 2 == 0) <= y)
  end
  # Ou, de manière équivalente,
  # @constraint(m, cons[i in 1:10], x[i] + sum(z[j] for j in 1:5 if j % 2 == 0) <= y)


  @objective(m, Min, sum(z[j] for j in 1:5))
  optimize!(m)

  return (m, x, y, z)
end

@doc """
Cette fonction est appelée après la fonction `run` et permet de faire de l'affichage et des traitement sur la sortie de la fonction `run` ; sans pour autant affecter son temps de calcul.

Le paramètre cpu time est le temps de calcul de `run`. Les valeurs de `inst` et `sol` sont les mêmes qu’à la sortie de la fonction run. Enfin, `others` est ce qui est renvoyé par la fonction `run`. Vous pouvez ainsi effectuer des tests et afficher des résultats sans affecter le temps de calcul.
""" ->
function post_process(cpu_time::Float64, inst, sol, others)

  # Run a renvoyé le modèle et ses variables, qui ont été mis dans others.
  m, x, y, z = others

  print(m)

  println()

  println("TERMINAISON : ", termination_status(m))
  println("OBJECTIF : $(objective_value(m))")
  println("VALEURS de x : $(value.(x))")
  println("VALEURS de y : $(value.(y))")
  println("VALEURS de z : $(value.(z))")

  println("Temps de calcul : $cpu_time.")

end

# Ne pas enlever
if length(ARGS) > 0
  input_file = ARGS[1]
  main(input_file)
end


Le paramètre inst correspond à l'instance du problème et sol à la solution courante

Cette fonction renvoie profit_max qui est le meilleur profit trouvé pour le moment et sol_max qui est la meilleur solution trouvée pour le moment.
""" ->
function fast_run(inst,sol)
	ω = inst.ω
	ω = permutedims(reshape(hcat(ω...), (length(ω[1]), length(ω))))
	ω = map(tuple, ((i,j) for i=1:inst.w, j=1:inst.h), ω)
	ω = reshape(ω,1,length(ω))
	ω = sort(ω,dims=2,by =x->x[2],rev=true)

	ma = inst.ma
	ma = collect(enumerate(ma))
	ma = sort(ma, by = x -> x[2],rev=true)

	current_ann = 1

	for case in ω
		if (current_ann > inst.n)
			break
		else
			i = case[1][1]
			j = case[1][2]
			if(place(sol,ma[current_ann][1],i,j))
				current_ann +=1
			end
		end
	end
	return profit(sol),sol
end

function test_easy_case(inst)
	wa = inst.wa
	ha = inst.ha

	for i in 1:inst.n
		if (wa[i] != 1 || ha[i] != 1)
			return false
		end
	end
	return true
end

@doc """
Cette fonction modifie la solution sol de l'instance inst avec un algorithme
exact. Si l'instance d'entrée est quelconque, on applique une première méthode
itérative qui teste tout les cas possibles. Par contre, si l'instance d'entrée
est telle que tout les annonceurs demandent une seule case
(test_easy_case(inst) à true), on applique une méthode plus rapide basée sur
des tris.


Cette fonction renvoie profit_max qui est le meilleur profit trouvé pour le moment et sol_max qui est la meilleur solution trouvée pour le moment.
""" ->
function run(inst, sol)

	if test_easy_case(inst)
		profit_max,sol_max = fast_run(inst,sol)
	else
		profit_max,sol_max = rec_classical_run(inst,1,sol,0,nothing)
	end

	return profit_max, sol_max
end

@doc """
Cette fonction est appelée après la fonction `run` et permet de faire de l'affichage et des traitement sur la sortie de la fonction `run` ; sans pour autant affecter son temps de calcul.

Le paramètre cpu time est le temps de calcul de `run`. Les valeurs de `inst` et `sol` sont les mêmes qu’à la sortie de la fonction run. Enfin, `others` est ce qui est renvoyé par la fonction `run`. Vous pouvez ainsi effectuer des tests et afficher des résultats sans affecter le temps de calcul.
""" ->
function post_process(cpu_time::Float64, inst, sol, others)
	profit_max, sol_max = others
  	println("Solution :",profit_max)
	println(sol_max)
end

# Ne pas enlever
if length(ARGS) > 0
  input_file = ARGS[1]
  main(input_file)
end

