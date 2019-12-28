include("./helpers/generate.jl")


using.Generator

for i in 1:20
	generate(100,100,10,0.1,0.1,(1,10),(1,100),"generated_test/test_wh$i.input")
end
