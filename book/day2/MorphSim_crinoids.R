#MorphoSim Project
#Made by Group: Lena, Mark, Joel, Charlotte, Xianyi 

#Generating a partition that aims to capture variation in regions of the crinoid
	#body
	#Calyx = More likely to be under major body plan constraints
		#fewer character states, slower rates of state transition, & taphonomically less 
		#missing data
	#Arms = ecological traits expected to undergo more rapid evolution
		#more character states, faster rates of state transition, and taphonomically
		#more likely to have missing data



#Simulate a tree w/10 taxa
tree_list <- sim.bd.taxa(
	n        = 10,   # number of extant tips
	numbsim  = 1,    # number of trees to simulate
	lambda   = 1,    # speciation rate
	mu       = 0.5,  # extinction rate
	complete = TRUE # if set to false drop all extinct lineages and keep only extant tips
)

tree <- tree_list[[1]]


#Partition 1 = calyx

calyx_partition <- sim.morpho(k = c(2, 3), time.tree = tree, br.rates = 0.1, trait.num = 16,
															partition = c(8,8), full.states=TRUE)
#k=c(2,3) is 2 sets of chars, one with 2 states and one with 3 char states
#trait.num=c(8,8) is two sets of 8 chars each
#br.rates = pretty slow
#define.Q = ord_Q is an ordered modeled of character change
#full.states=TRUE means all char. states will be included in the simulated trait data
plotMorphoGrid(calyx_partition)

#plot transition history of an example trait
plot(calyx_partition, trait = 1, box.cex = 2)


#Partition 2 = arms
arms_partition <- sim.morpho(k=c(4,5), time.tree=tree, br.rates=0.3, trait.num=16, 
														 partition = c(8,8), full.states=TRUE)
#k=c(4,5) is 2 sets of chars, one with 4 states and one with 5 char states
#trait.num=c(8,8) is two sets of 8 chars each
#br.rates = faster than calyx
#full.states=TRUE means all char. states will be included in the simulated trait data
plotMorphoGrid(arms_partition)

#plot transition history of an example trait
plot(arms_partition, trait = 10, box.cex = 2)


#artificially set rates to 0.3 for calyx partition (error otherwise if rates don't
	#match between partitions)
calyx_partition$trees$BrRates <- rep(0.3, (length(calyx_partition$trees$BrRates)))


#combine  partitions
combined_crinoid <- combine.morpho(calyx_partition, arms_partition)


#Simulate missing data for each partition; less missing data in calyx partition,
	#more missing data in arms partition
final_crinoid_part <- sim.missing.data(
	data = combined_crinoid, method = "partition",
	seq = "tips", probability = c(0.2, 0.2, 0.5, 0.5)
)


#final combined model
combined_crinoid$model$Specified

plotMorphoGrid(final_crinoid_part)

#evaluate an example trait
plot(final_crinoid_part, trait=25, box.cex=2)



# Write data to outputs

#full tree
write.morpho(final_crinoid_part, file = "tree.tre", type = "tree",
						 reconstructed = FALSE)

# character matrix
write.morpho(final_crinoid_part, file = "matrix.nex", type = "matrix", reconstructed = FALSE)

# fossil occurrence ages (compatible with RevBayes)
write.morpho(final_crinoid_part, file = "ages.tsv", type = "ages")

# ages with associated uncertainty
write.morpho(final_crinoid_part, file = "ages.tsv", type = "ages",
						 uncertainty = 2)
