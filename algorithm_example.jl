"""
Author : Dimitri Watel
Projet OPTIMISATION 2 - ENSIIE - 2019-2020
"""

# Ne pas enlever
include("./main.jl")


######
# VOTRE CODE

# Exemple d'utilisation d'une bibliothèque que vous auriez codé vous même et placé dans customlibs
include("customlibs/libexample.jl")

######


@doc """
Modifie la solution sol de l'instance inst avec l'algorithme suivant

Cet algorithme place tous les annonceurs sur la première ligne ; l'annonceur j sur la colonne j ; si cela ne rentre pas en conflit avec les annonceurs précédemment placés.

Cette fonction peut renvoyer n'importe quel type de variable (dont rien du tout), qui sera ensuite traité dans post_process.
""" ->
function run(inst, sol)

  # Appel de la fonction hello dans la bibliothèque inclue plus haut
  hello()

  for i in 1:inst.n
    place(sol, i, 1, i) # On place la case en haut à gauche de l'annonceur i sur la colonne i et la ligne 1. Si ce n'est pas possible (parce qu'on sort de la grille ou parce qu'un autre annonceur a déjà réservé une partie de ces cases, cette fonction ne fait rien.
  end

end

@doc """
Cette fonction est appelée après la fonction `run` et permet de faire de l'affichage et des traitement sur la sortie de la fonction `run` ; sans pour autant affecter son temps de calcul.

Le paramètre cpu time est le temps de calcul de `run`. Les valeurs de `inst` et `sol` sont les mêmes qu’à la sortie de la fonction run. Enfin, `others` est ce qui est renvoyé par la fonction `run`. Vous pouvez ainsi effectuer des tests et afficher des résultats sans affecter le temps de calcul.
""" ->
function post_process(cpu_time::Float64, inst, sol, others)
  println("INSTANCE")

  println("Poids de la grille: ")
  display(inst.ω)
  println()
  println()
  println("W(a), H(a), M(a) pour chaque annonceur")
  display(hcat(inst.wa, inst.ha, inst.ma))
  println()
  println()


  for i in 1:inst.n
    if is_placed(sol, i)
      l, c = place_of(sol, i)
      println("ANNONCEUR $i placé sur la ligne $l et la colonne $c.")
    end
  end

  println("PROFIT : $(profit(sol))")
  println("TEMPS DE CALCUL : $(cpu_time)")
end

# Ne pas enlever
if length(ARGS) > 0
  input_file = ARGS[1]
  main(input_file)
end

