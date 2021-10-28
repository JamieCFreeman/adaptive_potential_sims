#!/usr/bin/env Rscript


# 2021-10-28 JCF
#############################################################################################
# Project: adaptive potential sims

# Purpose:
# For adaptive potential sims, desired data is the rate of change of fitness over time (eg the slope).
# Previous script calc_slope.R takes all replicates for a set of conditions and creates a 
# tab-delimited text file with 3 columns representing the 3 populations of one replicate and rows
# for each replicate sim. (Currently 1,000).

# The simulation paramters are contained in the file name:
# (eg slope_1000n_0.0ratio_0.25adapt_freq_8lines.tsv), so want a script to get the paramters 
# from the file names, append as columns to the data and output a single file representing 
# all data. 

#############################################################################################
# Input:
#   -Directory containing slope data
#   -Outfile name

# Output:
#   - Text file of format:
# > head(data_out)
#   n ratio adapt_freq n_lines       p3       p4       p5
# 1 1000     0       0.25       8 1407.439 1192.733 1810.256
# 2 1000     0       0.25       8 1771.821 2183.827 2076.629
# 3 1000     0       0.25       8 2113.084 2322.110 1289.402
# 4 1000     0       0.25       8 1319.089 1495.626 1174.605
# 5 1000     0       0.25       8 2586.788 1764.806 2622.380
# 6 1000     0       0.25       8 1788.365 2817.745 1530.451

#############################################################################################
# Get args from command line

# Input is a file containing paths to replicate sim results files
args = commandArgs(trailingOnly=TRUE)

# test if there is at least one argument: if not, return an error
if (length(args)==0) {
	  stop("At least one argument must be supplied (input dir).", call.=FALSE)
} else if (length(args)==1) {
	  # default output file
	  args[2] = "out.txt"
}

input_dir    <- args[1]
output_file  <- args[2]

#input_dir <- "processed"
#output_file <- "slopes_all_par.txt"

#############################################################################################

# Write a function to collect sim data for some set of pars, based on file naming convention for this set.
#   sim_list should be a vector of file names
#   all other parameters are optional- if the optional par exist, filter on them, otherwise return all
file_to_par <- function(sim.list, n=NULL, ratio=NULL, adapt_freq=NULL, n_lines=NULL) {
	  
	  # Get a list of all sets of sim data
	  cc        <- strsplit( sim.list, "_")
	  part1     <- matrix(unlist(cc), ncol=6, byrow = TRUE)
	  part1     <- part1[,-c(1,5)]
	  part1[,1] <- gsub('.{1}$', '', part1[,1]) 
	  part1[,2] <- gsub('.{5}$', '', part1[,2]) 
	  part1[,3] <- gsub('.{5}$', '', part1[,3]) 
	  part1[,3] <- gsub('.{5}$', '', part1[,3]) 
       	  part1[,4] <- gsub('.{9}$', '', part1[,4]) 
	  
	  par_mat <- matrix(as.numeric(part1), ncol=4)
	  colnames(par_mat) <- c("n", "ratio", "adapt_freq", "n_lines")
	    
	  return(par_mat)
	    
	}

#############################################################################################

# Parse file names to get matrix of sim variables
sim.data <- system(paste("find", input_dir, '-iname "*.tsv" -iname "slope*"'), intern = TRUE)

#sim.data <- system(paste("ls -p", input_dir, "| grep -v /"), intern = TRUE)

par_mat <- file_to_par(sim.data)

current_files <- sim.data
current_pars <- par_mat

data_out <- NULL

for (i in 1:length(current_files)) {
	data_temp      <- read.table(current_files[i])
  	data_temp_wpar <- cbind(n = rep(current_pars[i,"n"],nrow(data_temp)), 
			        ratio = rep(current_pars[i,"ratio"],nrow(data_temp)), 
				adapt_freq  = rep(current_pars[i,"adapt_freq"],nrow(data_temp)), 
				n_lines = rep(current_pars[i,"n_lines"],nrow(data_temp)), data_temp )
    	data_out <- rbind(data_out, data_temp_wpar)
}

colnames(data_out)[5:7] <- c("p3", "p4", "p5")

write.table(data_out, file = output_file, append = FALSE, quote = FALSE, row.names = FALSE, col.names = TRUE)


