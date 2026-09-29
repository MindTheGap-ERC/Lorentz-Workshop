

install.packages("remotes")
remotes::install_github("fossilsim/morphsim")
remotes::install_github("fossilsim/FossilSim")
remotes::install_github("MindTheGap-ERC/admtools")
remotes::install_github("MindTheGap-ERC/StratPal")
install.packages("TreeSim")

library(TreeSim)
library(ape)

set.seed(12)

tree_list <- sim.bd.taxa(
  n        = 10,   # number of extant tips
  numbsim  = 1,    # number of trees to simulate
  lambda   = 1,    # speciation rate
  mu       = 0.5,  # extinction rate
  complete = TRUE # if set to false drop all extinct lineages and keep only extant tips
)

tree <- tree_list[[1]]
# total tip count, including BOTH extant and extinct lineages
# (this will be > 10, since n only controls extant tips)morpho_mk <- sim.morpho(k = 3, time.tree = tree, br.rates = 0.1, trait.num = 15)

library(MorphSim)

morpho_mk <- sim.morpho(k = 3, time.tree = tree, br.rates = 0.1, trait.num = 15)
plotMorphoGrid(morpho_mk)
morpho_mkv <- sim.morpho(k = 3, time.tree = tree, br.rates = 0.1,
                         trait.num = 15, variable = TRUE)
# tolerate autapomorphies
morpho_pars_standard <- sim.morpho(k = 3, time.tree = tree, br.rates = 0.1,
                                   trait.num = 15, variable = TRUE,
                                   parsimony = "standard")

# every state must occur in 2+ taxa = stricter
morpho_pars_strict <- sim.morpho(k = 3, time.tree = tree, br.rates = 0.1,
                                 trait.num = 15, variable = TRUE,
                                 parsimony = "strict")
morpho_acrv <- sim.morpho(k = 3, time.tree = tree, br.rates = 0.1, trait.num = 15,
                          variable = TRUE, ACRV = "gamma", alpha.gamma = 1, ACRV.ncats = 4)

plotMorphoGrid(morpho_acrv)

ord_Q <- matrix(c(-0.5, 0.5, 0.0,
                  0.3333333, -0.6666667, 0.3333333,
                  0.0, 0.5, -0.5),
                nrow = 3, byrow = TRUE)

morpho_ordered <- sim.morpho(k = 3, time.tree = tree, br.rates = 0.1, trait.num = 15,
                             variable = TRUE, ACRV = "gamma", alpha.gamma = 1,
                             ACRV.ncats = 4, define.Q = ord_Q)

plot(morpho_ordered, trait = 1, box.cex = 2)
part_data <- sim.morpho(
  time.tree  = tree,
  k          = c(2, 3, 4),
  trait.num  = 20,
  partition  = c(10, 5, 5),
  br.rates   = 0.1
)

# model specification per partition
part_data$model$Specified
# partition 1: unordered binary characters with MkV + gamma ACRV, present/absent, assumed to change less frequently
partition_1 <- sim.morpho(time.tree = tree, k = 2, trait.num = 72,
                          br.rates = 0.1, variable = TRUE,
                          ACRV = "gamma", alpha.gamma = 1, ACRV.ncats = 4)

# partition 2: ordered three-state characters with a custom Q matrix
partition_2 <- sim.morpho(time.tree = tree, k = 3, trait.num = 8, variable = TRUE,
                          br.rates = 0.3, define.Q = ord_Q)

# partition 3: unordered three-state characters with MkV + gamma ACRV
partition_3 <- sim.morpho(time.tree = tree, k = 3, trait.num = 13,
                          br.rates = 0.3, variable = TRUE,
                          ACRV = "gamma", alpha.gamma = 1, ACRV.ncats = 4)


combined <- combine.morpho(partition_1, partition_2, partition_3)

# 100 traits total, model info from both partitions preserved
length(combined$sequences$tips[[1]])
combined$model$Specified
# partition 1: 30% missing
# partition 2: 70% missing
# partition 3: 70% missing
missing_part <- sim.missing.data(
  data = combined, method = "partition",
  seq = "tips", probability = c(0.3, 0.7, 0.7)
)

missing_extinct <- sim.missing.data(
  data = combined , method = "extinct",
  seq = "tips", probability = 0.5
)

