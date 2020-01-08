include("./helpers/generate.jl")


using.Generator

for i in 5:100
	i=i+100
	generate(5,5,10,0.2,0.2,(1,1),(1,5),"generated_test/test5/size2/test_ecart$i.input")
end

"""
  - `w` >= 2 => taille de l'instance
  - `h` >= 2 => taille de l'instance
  - `n` >= 1 => nombre d'anonceurs
  - `pw` ∈ [0 ; 1] => hauteur demandée
  - `ph` ∈ [0 ; 1] => largeur demandée ((ph x (h - 1) + 1) x (pw x (w - 1) + 1))
  - `bounds_ω = (min_ω, max_ω)` => poids des cases de la lune
  - `bounds_ma = (min_ma, max_ma)` => montant maximum
"""