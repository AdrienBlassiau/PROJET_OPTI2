"""
Author : Adrien BLASSIAU Corentin JUVIGNY Jiahui XU
Projet OPTIMISATION 2 - ENSIIE - 2019-2020
"""

function get_random_int(inf,sup)
	return Int(rand(Int32(inf):Int32(sup)))
end

function select_neighbour(inst, sol)

	current_profit = profit(sol)

	add_l = ajout_pub_list(inst, sol)
	add_l_size = size(add_l,1)

	ret_l = retrait_pub_list(inst, sol)
	ret_l_size = size(ret_l,1)

	dec_l = decalage_pub_list(inst, sol)
	dec_l_size = size(dec_l,1)

	total_size = add_l_size + ret_l_size + dec_l_size

	print("LISTE AJOUT : ")
	println(add_l)
	println(add_l_size)
	print("LISTE RETRAIT : ")
	println(ret_l)
	println(ret_l_size)
	print("LISTE DECALAGE : ")
	println(dec_l)
	println(dec_l_size)


	if (total_size == 0)
		return (0,(nothing,nothing,nothing))
	else
		rand_int = get_random_int(1,total_size)
	    if(rand_int <= add_l_size)
			println("ADD : $rand_int")
	    	return (1,add_l[rand_int])
		elseif(rand_int > add_l_size && rand_int <= add_l_size+ret_l_size)
			println("REMOVE : $rand_int")
			return (2,ret_l[rand_int-add_l_size])
		else
			println("DECALAGE : $rand_int")
			return (3,dec_l[rand_int-add_l_size-ret_l_size])
		end
	end
end

function apply_neighbour(inst, sol, neighour)
	current_profit = profit(sol)
	println("PROFIT AVANT:$current_profit")

	neighour_type = neighour[1]
	neighbour_data = neighour[2]
	i = neighbour_data[1]
	j = neighbour_data[2]
	k = neighbour_data[3]

	if (neighour_type==0)
		println("PROFIT APRES:",profit(sol))
		gain = profit(sol) - current_profit
		return gain
	elseif(neighour_type==1)
		place(sol,i,j,k)
		println("PROFIT APRES:",profit(sol))
		gain = profit(sol) - current_profit
		println("i : $i, j:$j, k:$k et gain:$gain")
		return gain
	elseif(neighour_type==2)
		remove(sol, i)
		println("PROFIT APRES:",profit(sol))
		gain = profit(sol) - current_profit
		println("i : $i et gain:$gain")
		return gain
	else
		remove(sol, i)
		place(sol,i,j,k)
		println("PROFIT APRES:",profit(sol))
		gain = profit(sol) - current_profit
		println("i : $i, j:$j, k:$k et gain:$gain")
		return gain
	end
end

function revert_neighbour(inst, sol, neighour)
	current_profit = profit(sol)
	println("PROFIT AVANT:$current_profit")

	neighour_type = neighour[1]
	neighbour_data = neighour[2]

	i = neighbour_data[1]
	j = neighbour_data[2]
	k = neighbour_data[3]

	if(neighour_type==1)
		remove(sol,i)

		println("PROFIT APRES:",profit(sol))
		gain = profit(sol) - current_profit

		return gain
	elseif(neighour_type==2)
		place(sol,i,j,k)

		println("PROFIT APRES:",profit(sol))
		gain = profit(sol) - current_profit

		return gain
	else
		dec_type = neighbour_data[4]

		remove(sol, i)

		if(dec_type==1)
			place(sol,i,j-1,k)
		elseif(dec_type==2)
			place(sol,i,j,k-1)
		elseif(dec_type==3)
			place(sol,i,j+1,k)
		else
			place(sol,i,j,k+1)
		end

		println("PROFIT APRES:",profit(sol))
		gain = profit(sol) - current_profit

		return gain
	end
end



function ajout_pub_list(inst, sol)

	pub_list = Array{Tuple{Int64,Int64,Int64},1}(undef, 0)

	for i in 1:inst.n
		if (!is_placed(sol,i))
			for j in 1:inst.h
				for k in 1:inst.w
					if(place(sol,i,j,k))
						remove(sol, i)
						push!(pub_list, (i,j,k))
					end
				end
			end
		end
	end

	return pub_list
end

function retrait_pub_list(inst, sol)
	pub_list = Array{Tuple{Int64,Int64,Int64},1}(undef, 0)

	for i in 1:inst.n
		if (is_placed(sol,i))
			place_i = place_of(sol, i)
			j=place_i[1]
			k=place_i[2]
			push!(pub_list,(i,j,k))
		end
	end

	return pub_list
end

function decalage_pub_list(inst, sol)

	pub_list = Array{Tuple{Int64,Int64,Int64,Int64},1}(undef, 0)
	place_i = (nothing, nothing)

	for i in 1:inst.n

		place_i = place_of(sol, i)

		if (!isnothing(place_i[1]))

			j=place_i[1]
			k=place_i[2]

			if(place(sol,i,j+1,k))
				remove(sol, i)
				place(sol,i,j,k)
				push!(pub_list, (i,j+1,k,1))
			end

			if(place(sol,i,j,k+1))
				remove(sol, i)
				place(sol,i,j,k)
				push!(pub_list, (i,j,k+1,2))
			end

			if(place(sol,i,j-1,k))
				remove(sol, i)
				place(sol,i,j,k)
				push!(pub_list, (i,j-1,k,3))
			end

			if(place(sol,i,j,k-1))
				remove(sol, i)
				place(sol,i,j,k)
				push!(pub_list, (i,j,k-1,4))
			end
		end
	end

	return pub_list
end
