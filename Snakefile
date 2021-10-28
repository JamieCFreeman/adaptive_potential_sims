
import numpy as np
from snakemake.utils import min_version
##### set minimum snakemake version #####
min_version("5.1.2")

##### load config and sample sheets #####
###configfile: "config.yaml"

# SLiM file


# Set up a smaller set of test variables:
test = False


n_var = [10, 100, 1000]
#n_var = [10, 20, 50, 100, 1000]
ratio_adaptive_rare = [0.0, 0.25, 0.50, 0.75, 1.0]
adapt_freq = [0.25, 0.50, 0.75]
n_lines = 8
n_reps = np.arange(1000)

if test == True:
        n_var = [10, 20]
        ratio_adaptive_rare = [0.25, 0.50]
        adapt_freq = [0.80]
        n_lines = 8  
        n_reps = np.arange(3)

sim_results_pattern = "results/sim_raw/sim_{n_var}n_{ratio_adaptive_rare}ratio_{adapt_freq}adapt_freq_{n_lines}lines_{n_reps}rep.tsv"
# Output file name must also be defined in SLiM file (and must match this or Snakemake will fail with errors. 

rule all:
	input:
		expand("results/sim_raw/sim_{n_var}n_{ratio_adaptive_rare}ratio_{adapt_freq}adapt_freq_{n_lines}lines_{n_reps}rep.tsv", 
			n_var=n_var, ratio_adaptive_rare=ratio_adaptive_rare, n_lines=n_lines, 
			adapt_freq=adapt_freq, n_reps=n_reps),
		"logs/current_conda_explicit.txt",
		expand("results/processed/slope_{n_var}n_{ratio_adaptive_rare}ratio_{adapt_freq}adapt_freq_{n_lines}lines.tsv",
                        n_var=n_var, ratio_adaptive_rare=ratio_adaptive_rare, n_lines=n_lines,
                        adapt_freq=adapt_freq),
		"results/slope_merged_wpars.txt"

rule slim:
# Do simulations
	output:
		sim_results_pattern
	shell:
                """
                slim -d n_var={wildcards.n_var} -d n_lines={wildcards.n_lines} \
                -d ratio_adaptive_rare={wildcards.ratio_adaptive_rare} -d adaptive_freq={wildcards.adapt_freq} \
		-d rep={wildcards.n_reps} scripts/Positive_model_JCF.slim
                """
# Ex: SliM command- define variables as "constants" in SLiM using -d
# slim -d n_var=60 -d n_lines=8 -d ratio_adaptive_rare=0.5 -d adaptive_freq=0.80 Positive_model_JCF.slim
#

rule file_list:
# Make lists of replicate sims to process
	input:
                files = expand("results/sim_raw/sim_{{n_var}}n_{{ratio_adaptive_rare}}ratio_{{adapt_freq}}adapt_freq_{{n_lines}}lines_{n_reps}rep.tsv",
                        n_reps=n_reps),
	output:
		"results/list/output_{n_var}n_{ratio_adaptive_rare}ratio_{adapt_freq}adapt_freq_{n_lines}lines.tsv"
	shell:
		"""
		PATTERN=`echo {input} | sed 's ^.*sim_raw/  ' | sed 's/lines_.*/lines/' `; 
		find ./results/sim_raw -iname "$PATTERN*" | sort -V > {output}
		"""

rule process:
# Calculate slope for replicate sims
	input:
		"results/list/output_{n_var}n_{ratio_adaptive_rare}ratio_{adapt_freq}adapt_freq_{n_lines}lines.tsv"
	output:
		"results/processed/slope_{n_var}n_{ratio_adaptive_rare}ratio_{adapt_freq}adapt_freq_{n_lines}lines.tsv"
	shell:
		"""
		 Rscript --vanilla scripts/calc_slope.R {input} {output}
		"""

rule gather:
# Combine all slope data into 1 table w parameters for analysis
	input:
                expand("results/processed/slope_{n_var}n_{ratio_adaptive_rare}ratio_{adapt_freq}adapt_freq_{n_lines}lines.tsv",
                        n_var=n_var, ratio_adaptive_rare=ratio_adaptive_rare, n_lines=n_lines,
                        adapt_freq=adapt_freq)
	output:
		"results/slope_merged_wpars.txt"
	shell:
		"""
		Rscript --vanilla scripts/Merge_data.R results/processed {output}
		"""



rule record_ev:
# Record SLim version & conda env at runtime
	output:
		#global = "logs/prog_v.txt",
		conda = "logs/current_conda_explicit.txt"
	shell:
		#"slim -v > {output.global}; 
		"conda list --explicit > {output.conda}"


