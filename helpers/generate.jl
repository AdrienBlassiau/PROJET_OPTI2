"""
Author : Dimitri Watel
Projet OPTIMISATION 2 - ENSIIE - 2019-2020
"""

@doc """
Module contenant 3 fonctions de génération d'instances du problème d'annonces publicitaires sur la Lune.
  Il contient 3 fonctions
  - `generate(w, h, n, bounds_ω, bounds_ma)` génère une instance.
  - `generate(w, h, n, bounds_ω, bounds_ma, filename)` génère une instance et écrit le tout dans le fichier filename.
  - `generate(filename) renvoie l'instance décrite dans le fichier filename (généré avec la fonction précédente)

Utilisez using .Generator pour utiliser le module et son contenu dans votre code.

Utiliser ?NOM dans l'interface en ligne de commande Julia pour avoir de la documentation sur NOM.
Par exemple ?generate affiche la documetation sur les fonctions generate
""" ->
module Generator

  export generate

  include("./problem.jl")
  import .Moon: Instance
  using Distributions

  @doc """
  `generate(w::Int, h::Int, n::Int, pw::Float64, ph::Float64, bounds_ω::Tuple{Int, Int}, bounds_ma::Tuple{Int, Int})`

  - `w` >= 2
  - `h` >= 2
  - `n` >= 1
  - `pw` ∈ [0 ; 1]
  - `ph` ∈ [0 ; 1]
  - `bounds_ω = (min_ω, max_ω)` est un tuple de deux entiers supérieurs ou égaux à 1, le premier est inférieur au second
  - `bounds_ma = (min_ma, max_ma)` est un tuple de deux entiers supérieurs ou égaux à 1, le premier est inférieur au second

  Prérequis : installation du paquet Distributions de Julia
  (using Pkg ; Pkg.add("Distributions"))

  Fonction de génération d'instance.

  Cette fonction génère et renvoie une instance du problème d'annonces publicitaires sur la Lune. La Lune sera découpée en une grille de taille `w x h`. Il y a `n` annonceurs. Le poids des cases de la Lune est choisi aléatoirement uniformément entre `min_ω` et `max_ω`. Pour chaque annonceur, le nombre de lignes et de colonnes du rectangle que l'annonceur souhaite acheter sont choisies aléatoirement avec une loi Binomiale de paramètres respectivement égaux à (ph, h - 1) et (pw, w - 1) ; on ajoute 1 à la valeur obtenue pour obtenir un nombre entre 1 et h (respectivement 1 et w). La taille moyenne d'un rectangle d'un annonceur est donc `(ph x (h - 1) + 1) x (pw x (w - 1) + 1)`. Enfin, le montant maximum de l'annonceur est choisi aléatoirement uniformément entre `min_ma` et `max_ma`.
  """ ->
  function generate(w::Int, h::Int, n::Int, pw::Float64, ph::Float64, bounds_ω::Tuple{Int, Int}, bounds_ma::Tuple{Int, Int})
    inst = Instance()

    # Paramètres de base
    inst.w = w
    inst.h = h
    inst.n = n

    min_ω, max_ω = bounds_ω
    min_ma, max_ma = bounds_ma

    # Loi de probabilité
    dist_ω = Distributions.DiscreteUniform(min_ω, max_ω)
    dist_ma = Distributions.DiscreteUniform(min_ma, max_ma)
    dist_ha = Distributions.Binomial(h - 1, ph)
    dist_wa = Distributions.Binomial(w - 1, pw)

    # Poids des cases
    for i in 1:inst.h
      push!(inst.ω, [])
      for j in 1:inst.w
        push!(inst.ω[i], rand(dist_ω))
      end
    end

    # Annonceurs
    for i in 1:inst.n
      push!(inst.wa, rand(dist_wa) + 1)
      push!(inst.ha, rand(dist_ha) + 1)
      push!(inst.ma, rand(dist_ma))
    end

    return inst
  end


  @doc """
  `generate(w::Int, h::Int, n::Int, pw::Float64, ph::Float64, bounds_ω::Tuple{Int, Int}, bounds_ma::Tuple{Int, Int}, filename::String)`

  - `w` >= 2
  - `h` >= 2
  - `n` >= 1
  - `pw` ∈ [0 ; 1]
  - `ph` ∈ [0 ; 1]
  - `bounds_ω = (min_ω, max_ω)` est un tuple de deux entiers supérieurs ou égaux à 1, le premier est inférieur au second
  - `bounds_ma = (min_ma, max_ma)` est un tuple de deux entiers supérieurs ou égaux à 1, le premier est inférieur au second
  - `filename` est un chemin vers un fichier, existant ou non

  Prérequis : installation du paquet Distributions de Julia
  (using Pkg ; Pkg.add("Distributions"))

  Utilise la fonction `generate(w, h, n, pw, ph, bounds_ω, bounds_ma)` pour construire une instance puis écrit cette instance dans le fichier dont le chemin est `filename`. Enfin, elle renvoie l'instance générée.
  Le format du fichier est le suivant.
  - Une première ligne contenant un commentaire #
  - Une ligne vide
  - Une ligne contenant deux entiers `w` et `h`
  - `h` lignes contenant `w` entiers positifs séparés par des espaces
  - Une ligne contenant 1 entier `n`
  - `n` lignes contenant 3 entiers positifs séparés par des espaces

  """ ->
  function generate(w::Int, h::Int, n::Int, pw::Float64, ph::Float64, bounds_ω::Tuple{Int, Int}, bounds_ma::Tuple{Int, Int}, filename::String)
    inst = generate(w, h, n, pw, ph, bounds_ω, bounds_ma)
    open(filename, "w") do file
      write(file, "# Fichier généré avec generate.jl, avec les paramètres $w $h $n $pw $ph $bounds_ω, $bounds_ma\n")
      write(file, "\n")

      # Taille de la grille
      write(file, "$(inst.w) $(inst.h)\n")

      # Poids des cases
      for l in 1:inst.h
        for c in 1:inst.w
          write(file, "$(inst.ω[l][c]) ")
        end
        write(file, "\n")
      end

      # Annonceurs
      write(file, "$(inst.n)\n")
      for i in 1:inst.n
        write(file, "$(inst.wa[i]) $(inst.ha[i]) $(inst.ma[i])\n")
      end

    end
    return inst
  end


  @doc """
  generate(filename::String)

  Lecture fichier de données.

  Cette fonction lit un fichier dont le chemin est `filename` et renvoie un objet de type Instance contenant les informations écrites dans le fichier.
  Le fichier doit être au format généré par la fonction `generate(w::Int, h::Int, n::Int, pw::Float64, ph::Float64, bounds_ω::Tuple{Int, Int}, bounds_ma::Tuple{Int, Int}, filename::String)`
  - Une première ligne contenant un commentaire #
  - Une ligne vide
  - Une ligne contenant deux entiers w et h
  - h lignes contenant w entiers positifs séparés par des espaces
  - Une ligne contenant 1 entier n
  - n lignes contenant 3 entiers positifs séparés par des espaces
  """ ->
  function generate(filename::String)

    open(filename) do file
      lines = readlines(file)  # fichier de l'instance à resoudre

      inst = Instance()

      # Taille de la grille
      line = lines[3]
      line_decompose=split(line)
      inst.w = parse(Int64, line_decompose[1])
      inst.h = parse(Int64, line_decompose[2])

      # Lectures des informations concernant l'adjecence, les coûts et les pénalités
      for l in 1:inst.h
        line = lines[3 + l]
        line_decompose = split(line)
        push!(inst.ω, [])
        for c in 1:inst.w
          push!(inst.ω[l], parse(Int64, line_decompose[c])) # on remplit la ligne de zéros
        end
      end

      # Nombre d'annonceurs
      line = lines[3 + inst.h + 1]
      inst.n = parse(Int64, line)

      # Informations des annonceurs
      for i in 1:inst.n
        line = lines[4 + inst.h + i]
        line_decompose = split(line)
        push!(inst.wa, parse(Int64, line_decompose[1]))
        push!(inst.ha, parse(Int64, line_decompose[2]))
        push!(inst.ma, parse(Int64, line_decompose[3]))
      end

      return inst
    end

  end
end
