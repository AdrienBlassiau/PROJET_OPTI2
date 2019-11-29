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
# Vous pouvez mettre des fonctions, des variables globales (attention à ne pas faire n'importe quoi), des modules, ...
#

######
sol_max = 0

function rec_run(inst,ann,sol)
	global sol_max
	if ann > inst.n
		gain=profit(sol)
		# println("Profit de la grille: ",gain,"et ",sol_max)
		if (gain >= sol_max)
			sol_max = gain
		end
	else
		for i in 1:inst.h
			for j in 1:inst.w
				if (ann==1)
					println(i,j)
				end
				place(sol, ann, i, j)
				# println(ann,"/",i,"/",j)
				rec_run(inst,ann+1,sol)
				remove(sol,ann)
			end
		end
	end
end

@doc """
Modifie la solution sol de l'instance inst avec l'algorithme suivant
*** DECRIRE VOTRE ALGORITHME ICI en quelques mots ***

Cette fonction peut renvoyer n'importe quel type de variable (dont rien du tout), qui sera ensuite traité dans post_process.
""" ->
function run(inst, sol)
	rec_run(inst,1,sol)
	println("Solution :",sol_max)
end

@doc """
Cette fonction est appelée après la fonction `run` et permet de faire de l'affichage et des traitement sur la sortie de la fonction `run` ; sans pour autant affecter son temps de calcul.

Le paramètre cpu time est le temps de calcul de `run`. Les valeurs de `inst` et `sol` sont les mêmes qu’à la sortie de la fonction run. Enfin, `others` est ce qui est renvoyé par la fonction `run`. Vous pouvez ainsi effectuer des tests et afficher des résultats sans affecter le temps de calcul.
""" ->
function post_process(cpu_time::Float64, inst, sol, others)
  # Remplir la fonction
end

# Ne pas enlever
if length(ARGS) > 0
  input_file = ARGS[1]
  main(input_file)
end

