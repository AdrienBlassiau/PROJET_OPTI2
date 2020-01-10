include("./helpers/generate.jl")


using.Generator

for j in 1:20
	for i in 1:1000
		i=i+1000
		generate(j,j,5,0.2,0.2,(1,5),(1,20),"others/generated_tests/test1/size$j/test_time$i.input")
	end
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