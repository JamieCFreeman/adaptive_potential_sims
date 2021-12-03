#!/usr/bin/env Rscript

# 2021-10-25 JCF

# Input is a file containing paths to replicate sim results files
args = commandArgs(trailingOnly=TRUE)

# test if there is at least one argument: if not, return an error
if (length(args)==0) {
	  stop("At least one argument must be supplied (input file).n", call.=FALSE)
} else if (length(args)==1) {
	  # default output file
	  args[2] = "out.txt"
}

# Read in list of files
#input_file ="./results/processed/slopes_10n_0.0ratio_0.5adapt_freq_8lines.tsv"
input_file=args[1]
file_list = read.table(input_file, header=FALSE, stringsAsFactors = FALSE)

# Want to see what happens running for 15 gen
n_gen = 15

# Number of replicates of each exp pop simulated
n_rep_pops = 5

sim_lm_data = matrix(nrow = nrow(file_list), ncol = 3*n_rep_pops)

for (i in 1:nrow(file_list) ) {
	data.wide = read.table( file_list[i,1], header=F, sep=" ")
  	# There is a trailing space at the end of the data, so R adds col NAs
	data.wide = data.wide[,-ncol(data.wide)]
	colnames(data.wide) <- c("Generation", paste(rep("p", n_rep_pops*3), 3:(2+(n_rep_pops*3)), sep="") )
    
	cutoff_point = data.wide[1,"Generation"] + n_gen

	data.wide = data.wide[data.wide[,"Generation"]<= cutoff_point,]
       
	# Loop over each pop
	for (j in 1:(ncol(sim_lm_data))) {
		sim_lm_data[i,j] = coefficients(lm(data.wide[,j+1]~data.wide$Generation))[[2]]
	 }
}

write.table(sim_lm_data, file=args[2], sep="\t", quote=FALSE, row.names=FALSE, col.names=FALSE)
