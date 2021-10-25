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


sim_lm_data = matrix(nrow = nrow(file_list), ncol = 3)

for (i in 1:nrow(file_list) ) {
	data.wide = read.table( file_list[i,1], header=F, sep=" ")
  	colnames(data.wide) <- c("Generation", "p3", "p4", "p5")
    
	cutoff_point = data.wide[1,"Generation"] + n_gen

	data.wide = data.wide[data.wide[,"Generation"]<= cutoff_point,]
      
	 sim_lm_data[i,] = c(
			     "p3_slope"= coefficients(lm(data.wide$p3~data.wide$Generation))[[2]],
			     "p4_slope"= coefficients(lm(data.wide$p4~data.wide$Generation))[[2]],
			     "p5_slope"= coefficients(lm(data.wide$p5~data.wide$Generation))[[2]]
			     )
}

write.table(sim_lm_data, file=args[2], sep="\t", quote=FALSE, row.names=FALSE, col.names=FALSE)
