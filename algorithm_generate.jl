include("./helpers/generate.jl")


using.Generator

for i in 2:5
	generate(i,i,2,0.5,0.5,(2,3),(2,3),"generated_test/test_wh$i.input")
end
