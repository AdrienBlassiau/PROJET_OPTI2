include("./helpers/generate.jl")


using.Generator

for i in 2:4
	generate(i,i,2,0.5,0.5,(2,3),(2,3),"test_wh$i.input")
end
