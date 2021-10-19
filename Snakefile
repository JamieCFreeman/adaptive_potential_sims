
import numpy as np
from snakemake.utils import min_version
##### set minimum snakemake version #####
min_version("5.1.2")

##### load config and sample sheets #####
###configfile: "config.yaml"

# Set up a smaller set of test variables:

test = False

n_var = [10, 20, 50, 100, 1000]
ratio_adaptive_rare = [0.0, 0.01, 0.25, 0.50, 0.75, 0.99]
adapt_freq = [0.25, 0.50, 0.80]
n_lines = 8
n_reps = np.arange(100)

if test == True:
        n_var = [10, 20]
        ratio_adaptive_rare = [0.25, 0.50]
        adapt_freq = [0.80]
        n_lines = 8  
        n_reps = np.arange(3)

sim_results_pattern = "results/sim_{n_var}n_{ratio_adaptive_rare}ratio_{adapt_freq}adapt_freq_{n_lines}lines_{n_reps}rep.tsv"

rule all:
	input:
		expand("results/sim_{n_var}n_{ratio_adaptive_rare}ratio_{adapt_freq}adapt_freq_{n_lines}lines_{n_reps}rep.tsv", 
			n_var=n_var, ratio_adaptive_rare=ratio_adaptive_rare, n_lines=n_lines, 
			adapt_freq=adapt_freq, n_reps=n_reps)

rule slim:
	output:
		sim_results_pattern
	shell:
#		"""
#		echo slim -d n_var={wildcards.n_var} -d n_lines={wildcards.n_lines} \
#		-d ratio_adaptive_rare={wildcards.ratio_adaptive_rare} -d adapt_freq={wildcards.adapt_freq} > {output}
#		"""
                """
                slim -d n_var={wildcards.n_var} -d n_lines={wildcards.n_lines} \
                -d ratio_adaptive_rare={wildcards.ratio_adaptive_rare} -d adaptive_freq={wildcards.adapt_freq} \
		-d rep={wildcards.n_reps} Positive_model_JCF.slim
                """
# slim -d n_var=60 -d n_lines=8 -d ratio_adaptive_rare=0.5 -d adaptive_freq=0.80 Positive_model_JCF.slim
#

