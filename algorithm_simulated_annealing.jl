"""
Author : Adrien BLASSIAU Corentin JUVIGNY Jiahui XU
Projet OPTIMISATION 2 - ENSIIE - 2019-2020
"""

# Ne pas enlever
include("./main.jl")
include("./customlibs/neighbourhood.jl")

println("Chargement de Random")
using Random
println("Random chargée")
println("Chargement de Plots")
using Plots
println("Plots de chargée")


function plot_grid(inst, sol, p)
	for j in 1:inst.h
		for k in 1:inst.w
			price = inst.ω[j][k]
			p = plot!(annotation=[(k+0.5,j+0.5,text("$price",11,RGBA(1,0,0, 0.5),:left))])
		end
	end
	display(p)
end

function plot_solution(inst, sol)

	rectangle(w, h, x, y) = Plots.Shape([(x,y),(x+w,y),(x+w,y+h),(x,y+h)])
	w = inst.w
	h = inst.h

	g = profit(sol)
	p = plot(lims=(1,w+1), xticks = 1:1:w+1, yticks = 1:1:h+1, mirror=true, yflip=true,title="Gain : $g")
	display(p)
	plot_grid(inst, sol, p)
	for i in 1:inst.n
		if (is_placed(sol,i))
			place_i = place_of(sol, i)
			y=place_i[1]
			x=place_i[2]
			w=inst.wa[i]
			h=inst.ha[i]
			c=get_cost(inst,i,y,x)
			p = plot!(rectangle(w,h,x,y), opacity=.5, label="A$i", annotation=[(x+0.2,y+0.2,text("$c",5,RGBA(0,0,0,1),:left))])
		end
	end
	display(p)
	# sleep(0.1)
	sleep(2)
end

function energie_proba_distrib(delta_E,T)
	return exp(delta_E/T)
end


@doc """
Cette fonction réalise un recuit simulé
""" ->
function simulated_annealing(inst, sol)
	gr()
	################ PARAMÈTRES ################
	t1 = time();
	t2 = time();

	phi = 0.9995
	D_step = 2
	T_init = 40
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

	# plot_solution(inst, current_sol)

	while (T > epsilon)

		# println("########## NOUVEAU PALIER $k(CURRENT BEST : $meilleur_gain )##########")

		for i in 0:D_step-1
			# plot_solution(inst, current_sol)
			# println("########## ITERATION n°$i ##########")

			# Selection d'un voisin et application de ce voisin sur la solution
			# courante
			delta_gain,neighbour = apply_neighbour(inst, current_sol)
			nouveau_gain = profit(current_sol)

			# Si la nouvelle solution améliore la précédente
			if (delta_gain>=0)
				current_gain = nouveau_gain
				if (current_gain > meilleur_gain)
					meilleur_gain = current_gain
					meilleur_sol = deepcopy(current_sol)
					t2 = time();
					elapsed_time = (t2-t1)
					println("TEMPS ÉCOULÉ  : $elapsed_time")
					println("NOUVEAU MINIMUM : $meilleur_gain")
					plot_solution(inst, current_sol)
				end
			else
				rand_double = rand()
				energy_p = energie_proba_distrib(delta_gain,T)
				# println("ENERGIE : $energy_p et K : $rand_double")

				if(rand_double <= energy_p)
					# println("ON REVERT\n")
					revert_neighbour(inst, current_sol, neighbour);
				end
			end
  		end

  		T = T*phi

  		# println("T courante : $T")
		k = k+1
	end

	return meilleur_sol, t1
end

@doc """
Cette fonction lance un recuit simulé.
""" ->
function run(inst, sol)

	meilleur_sol, t1 = simulated_annealing(inst, sol)

	t2 = time();
	elapsed_time = (t2-t1)
	println("TEMPS ÉCOULÉ  : $elapsed_time")
	println("OBJECTIF  : $(profit(meilleur_sol))")

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