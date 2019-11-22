"""
Author : Dimitri Watel
Projet OPTIMISATION 2 - ENSIIE - 2019-2020
"""

@doc """
Module contenant les types relatifs aux instances et aux solutions du problème d'annonce publicitaire sur la Lune.
Il contient les types et les fonctions suivants:

- Instance
- Solution
- get_cost
- collide
- place
- remove
- is_placed
- place_of
- profit

Utilisez using .Moon pour utiliser le module et son contenu dans votre code.

Utiliser ?NOM dans l'interface en ligne de commande Julia pour avoir de la documentation sur NOM.
Par exemple ?Instance affiche la documetation sur le type Instance


""" -> 
module Moon

  export Instance, get_cost, collide, Solution, place, remove, is_placed, place_of, profit

  @doc """
  Type représentant une entrée du problème d'annonces publicitaires sur la Lune.

  Il contient 6 attributs:
  - `w` est le nombre de colonnes de la grilles disposée sur la Lune
  - `h` est le nombre de lignes de la grilles disposée sur la Lune
  - `ω` est un tableau 2D de `w x h` entiers, `ω[l][c]` est le poids de la case de la Lune située sur la ligne l et sur la colonne c
  - `n` est le nombre d'annonceurs publicitaires
  - `wa` est un tableau de `n` entiers, `wa[i]` est le nombre de colonnes du rectangle que l'annonceur souhaite acheter.
  - `ha` est un tableau de `n` entiers, `ha[i]` est le nombre de lignes du rectangle que l'annonceur souhaite acheter.
  - `ma` est un tableau de `n` entiers, `ma[i]` est le montant maximum que l'annonceur est prêt à payer.
  
  Il n'est pas nécessaire de construire vous même les entrées.
  Utilisez le fichier generate.jl pour cela.

  """
  mutable struct Instance
    w::Int # nbre colonnes
    h::Int # nbre lignes
    ω::Array{Array{Int}} # matrice couts
    n::Int # nbre annonceurs
    wa::Array{Int} # nb colonnes des annonceurs
    ha::Array{Int} # nb lignes des annonceurs 
    ma::Array{Int} # montant max des annonceurs
  end
  Instance() = Instance(0, 0, [], 0, [], [], []) # Constructeur par défaut


  @doc """
  `valid_placement(inst::Instance, i::Int, l::Int, c::Int)`

  Renvoie vrai s'il est possible de placer la case en haut à guache du rectangle que souhaite acheter le i-ieme annonceur sur la ligne l et la colonne c sans déborder du rectangle et faux sinon. Si le i-ieme annonceur n'existe pas, renvoie faux. 
  Autrement dit renvoie vrai si
  - `l` : entier entre 1 et `inst.h` - `inst.ha[i]`
  - `c` : entier entre 1 et `inst.w` - `inst.wa[i]`
  - `i` : entier entre 1 et `inst.n`
  """ ->
  function valid_placement(inst, i::Int, l::Int, c::Int)
    if i < 1 || i > inst.n
      return false
    end
    if c < 1 || c > inst.w - inst.wa[i] + 1
      return false
    end
    if l < 1 || l > inst.h - inst.ha[i] + 1
      return false
    end
    return true
  end

  @doc """
  `get_cost(inst::Instance, i::Int, l::Int, c::Int)`

  Renvoie le coût que paierait le i-ieme annonceur si on plaçait la case en haut à gauche du rectangle que souhaite acheter cet annonceur sur la ligne l et la colonne c.
  Renvoie -1 si le placement n'est pas valide (selon la fonction valid_placement).
  """ ->
  function get_cost(inst, i::Int, l::Int, c::Int)
    if !valid_placement(inst, i, l, c)
      return -1
    end

    s = sum(inst.ω[lp][cp] for lp in l:(l+inst.ha[i] - 1) for cp in c:(c + inst.wa[i] - 1))
    return min(s, inst.ma[i])
    
  end
  
  
  @doc """
  `collide(inst::Instance, i1::Int, l1::Int, c1::Int, i2::Int, l2::Int, c2::Int)`

   En supposant qu'on place la case en haut à gauche du rectangle que souhaite acheter le i1-eme annonceur (respectivement i2-ieme) sur la ligne l1 (resp. l2) et la colonne c1 (resp. c2), renvoie vrai si les deux rectangles ont une intersection non vide. 
  Renvoie nothing si les placements ne sont pas valides (selon la fonction valid_placement).

  """ ->
  function collide(inst, i1::Int, l1::Int, c1::Int, i2::Int, l2::Int, c2::Int)
    if !valid_placement(inst, i1, l1, c1)
      return nothing
    end
    if !valid_placement(inst, i2, l2, c2)
      return nothing
    end

    return !(l1 + inst.ha[i1] - 1 < l2 || l2 + inst.ha[i2] - 1 < l1 || c1 + inst.wa[i1] - 1 < c2 || c2 + inst.wa[i2] - 1 < c1)
    
  end

  @doc """
  Type représentant une solution du problème d'annonces publicitaires sur la Lune.

  Il contient 3 attribut:
  - `inst` est une instance dont cet objet est la solution
  - `la` est un tableau de `n` entiers, `la[i]` est la première ligne du rectangle acheté par l'annonceur i. Si on ne vend rien à l'annonceur i, alors cette valeur est `nothing`.
  - `ca` est un tableau de `n` entiers, `ca[i]` est la première colonne du rectangle acheté par l'annonceur i. Si on ne vend rien à l'annonceur i, alors cette valeur est `nothing`.
  
  Vous n'avez pas à construire une solution à la main. Vous pouvez utiliser 3 fonctions pour cela:
  - Solution(inst::Instance)
  - place(sol::Solution, i::Int, l::Int, c::Int) qui place un annonceur sur la grille
  - remove(sol::Solution, i::Int)  qui retire un annonceur de la grille

  Vous pouvez utiliser la fonction profit(sol::Solution) pour connaître le gain de vente d'une solution.
  """
  mutable struct Solution
    inst
    la::Array{Union{Int, Nothing}}
    ca::Array{Union{Int, Nothing}}
  end

  @doc """
  `Solution(inst::Instance)`

  Construit une solution vide pour l'instance inst.
  Vous n'avez normalement pas besoin d'appeler cette fonction, vos algorithmes reçoivent en entrée une solution déjà initialisée avec cette fonction.
  """ ->
  function Solution(inst)
    la = Array{Union{Nothing, String}}(nothing, inst.n)
    ca = Array{Union{Nothing, String}}(nothing, inst.n)
    return Solution(inst, la, ca)
  end


  @doc """
  `place(sol::Solution, i::Int, l::Int, c::Int)`

  Essaie de placer le i-ieme annonceur dans la grille de sorte que la case en haut à gauche du rectangle que souhaite acheter cet annonceur soit sur la ligne l et la colonne c.
  Si le rectangle de l'annonceur n'est pas placé complètement dans la grille de la Lune (typiquement si `c + inst.wa[i]` > `inst.w`). La fonction ne fait rien et renvoie faux. Ce cas arrive si les 3 conditions suivantes ne sont pas vérifiées.
  - `l` : entier entre 1 et `inst.h` - `inst.ha[i]`
  - `c` : entier entre 1 et `inst.w` - `inst.wa[i]`
  - `i` : entier entre 1 et `inst.n`

  Si le rectangle renctre en collision avec celui d'un autre annonceur précédemment placé, la fonction ne fait rien et renvoie faux. 
  Sinon la fontion place l'annonceur et renvoie vrai. 
  """ ->
  function place(sol, i::Int, l::Int, c::Int)
    if !valid_placement(sol.inst, i, l, c)
      return false
    end

    if any(collide(sol.inst, i, l, c, j, sol.la[j], sol.ca[j]) for j in 1:sol.inst.n if i != j && !isnothing(sol.la[j]))
      return false
    end

    sol.la[i] = l
    sol.ca[i] = c
    return true

  end

  @doc """
  `remove(sol::Solution, i::Int)`

  Retire le i-ieme annonceur dans la grille.

  La fonction ne fait rien et renvoie faux si l'annonceur n'existe pas, autrement dit si la condition suivante n'est pas respectée.
  - `i` : entier entre 1 et `inst.n`

  Si l'annonceur n'était pas palcé dans la grille avant l'appel de cette fonction, elle ne fait rien mais renvoie vrai.
  Sinon la fontion retire l'annonceur et renvoie vrai. 
  """ ->
  function remove(sol, i)
    if i < 1 || i > sol.inst.n
      return false
    end
    sol.la[i] = nothing
    sol.ca[i] = nothing
    return true
  end

  @doc """
  `is_placed(sol::Solution, i::Int)`

  Renvoie vrai si et seulement si l'annonceur `i` est placé dans la solution `sol`.
  La fonction renvoie faux si l'annonceur n'existe pas, autrement dit si la condition suivante n'est pas respectée.
  - `i` : entier entre 1 et `inst.n`
  """ ->
  function is_placed(sol, i)
    if i < 1 || i > sol.inst.n
      return false
    end
    return !isnothing(sol.la[i])
  end

  @doc """
  `place_of(sol::Solution, i::Int)`

  Renvoie les coordonnées de la case en haut à gauche du rectangle du i-ieme annonceur s'il est placé dans la solution `sol` sous la forme (ligne, colonne). La fonction renvoie (nothing, nothing) si l'annonceur n'est placé; ou s'il n'existe pas, autrement dit si la condition suivante n'est pas respectée.
  - `i` : entier entre 1 et `inst.n`
  """ ->
  function place_of(sol, i)
    if i < 1 || i > sol.inst.n
      return (nothing, nothing)
    end
    return (sol.la[i], sol.ca[i])
  end

  @doc """
  `profit(sol::Solution)`
  Renvoie la somme des profits de cette solution.

  """ ->
  function profit(sol)
    return sum(Int[get_cost(sol.inst, i, sol.la[i], sol.ca[i]) for i in 1:sol.inst.n if !isnothing(sol.la[i])])
  end

end




