# adaptive_potential_sims

Using SLiM to simulate evolution of admixed populations encountering a novel selection pressure. 
If two populations have diverged from a common ancestor, we imagine that the genetic differences that have occured since the split are either: adaptive (and thus at some intermediate/high frequency) or neutral 
 (and thus at a low frequency) in these populations.  If these populations encounter a novel selective pressure, some of these existing genetic variants may have a positive selection coefficient under this new enviornment. 

We start with two populations and give them adaptive variants of a specified number and frequency in the population, and then we split each into multiple subpopulations (specifide in n_lines) to approximate isofemale lines.  The isofemale lines are given some number of neutral variants, and then an equal number (n_lines) of isofemale lines frome each of the two original source populations are combined. Single origin populations are created with 2*n isofemale lines. The fitness of this mixed population, as well as the fitness of the single origin populations are output at each generation.  


Simulation variables: 
- n_var: the toal desired number of variants in all populations
- ratio_adaptive_rare: relative ratio of variants designated as adaptive in one of the source populations
- adaptive_freq: the frequency of adaptive mutations in the source populations
- n_lines: 

"Adaptive" and "neutral" refers to the variants previous role in the source populations.
