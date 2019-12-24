"""
Author : Adrien BLASSIAU Corentin JUVIGNY Jiahui XU
Projet OPTIMISATION 2 - ENSIIE - 2019-2020
"""

# Ne pas enlever
include("./main.jl")
include("./neighbourhood.jl")

println("Chargement de Random")
using Random



function energie_proba_distrib(delta_E,T)
	return exp(-delta_E/T)
end


@doc """
Cette fonction réalise un recuit simulé
""" ->
function simulated_annealing(inst, sol)

	################ PARAMÈTRES ################
	phi = 0.99995
	D_step = 2
	T_init = 110
	epsilon = 0.0001
	k = 0
	############################################

	############## INITIALISATION ##############
	meilleur_sol = deepcopy(sol)
	meilleur_gain = profit(sol)
	current_sol = deepcopy(sol)
	current_gain = profit(sol)
	T = T_init
	############################################


	while (T > epsilon)

		println("########## NOUVEAU PALIER $k(CURRENT BEST : $meilleur_gain )##########")

		for i in 0:D_step-1
			println("########## ITERATION n°$i ##########")

			# Selection d'un voisin
			neighbour = select_neighbour(inst, current_sol)

			# Application du voisin sur la solution courante
			delta_gain = apply_neighbour(inst, current_sol, neighbour)
			nouveau_gain = profit(current_sol)

			# Si la nouvelle solution améliore la précédente
			if (delta_gain>=0)
				current_gain = nouveau_gain
				if (current_gain > meilleur_gain)
					meilleur_gain = current_gain
					meilleur_sol = deepcopy(current_sol)
					println("NOUVEAU MINIMUM : $meilleur_gain")
				end
			else
				rand_double = rand()
				energy_p = energie_proba_distrib(delta_gain,T)
				println("ENERGIE : $energy_p et K : $rand_double")

				if(rand_double > energy_p)
					println("ON REVERT\n")
					revert_neighbour(inst, current_sol, neighbour);
				end
			end
  		end

  		T = T*phi

  		println("T courante : $T")
		k = k+1
	end
end

@doc """
Cette fonction lance un recuit simulé.
""" ->
function run(inst, sol)

	simulated_annealing(inst, sol)

	return 1
end

@doc """
Cette fonction est appelée après la fonction `run` et permet de faire de l'affichage et des traitement sur la sortie de la fonction `run` ; sans pour autant affecter son temps de calcul.

Le paramètre cpu time est le temps de calcul de `run`. Les valeurs de `inst` et `sol` sont les mêmes qu’à la sortie de la fonction run. Enfin, `others` est ce qui est renvoyé par la fonction `run`. Vous pouvez ainsi effectuer des tests et afficher des résultats sans affecter le temps de calcul.
""" ->
function post_process(cpu_time::Float64, inst, sol, others)
	profit_max = others
	# println("OBJECTIF : $profit_max")
end






# Ne pas enlever
if length(ARGS) > 0
  input_file = ARGS[1]
  main(input_file)
end