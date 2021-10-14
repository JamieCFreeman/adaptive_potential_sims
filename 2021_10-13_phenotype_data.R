

setwd("~/Box/Computing_resources/simulations_introgression_recombination-Simulation_scripts/directional_selection")


library("here")

library("tidyr")
library("dplyr")
library("ggplot2")


#m60_r0.25_fa0.8

setwd("~/Box/Computing_resources/simulations_introgression_recombination-Simulation_scripts/directional_selection/sim_output/m60_r0.25_fa0.8")
#sim.data = list.files(path = ".", include.dirs = FALSE) # this still includes directories!
sim.data = system('ls -p | grep -v /', intern=T)

# Set up empty data frame to store coeff
summ.data = data.frame(matrix(NA, ncol=4, nrow = length(sim.data)))
colnames(summ.data) =c("SimID", 
                       "p3_slope",
                       "p4_slope",
                       "p5_slope"
)

cutoff_points = seq(from=10, to=50, by=5)
sim_lm_data = list()

for (i in 1:length(sim.data) ) {
  data.wide = read.table( sim.data[i], header=F, sep=" ")
  colnames(data.wide) <- c("Generation", "p3", "p4", "p5")


  summ.data[i,] = c("SimID"= strsplit( sim.data[i], "_")[[1]][1], 
           "p3_slope"= coefficients(lm(data.wide$p3~data.wide$Generation))[[2]],
           "p4_slope"= coefficients(lm(data.wide$p4~data.wide$Generation))[[2]],
           "p5_slope"= coefficients(lm(data.wide$p5~data.wide$Generation))[[2]]
  )
  
  
  data.long <- gather(data.wide, pop, phenotype, p3:p5, factor_key=FALSE)
  
  
  plot.temp = ggplot(data.long , aes(Generation, phenotype)) + geom_point(aes(color=pop)) +
    theme_bw() 
  out_plot = paste( here("processed_output/2021-10-14/"), toString(strsplit( sim.data[i], "_")[[1]][1]), ".png",
                    sep="")
  #ggsave(out_plot, plot.temp, 
    #     device="png")
  
  
  # Try mult lm
  lm_data = list()
  for (j in 1:length(cutoff_points)) {
    
    lm_data[[j]] = data.long %>%
      filter(Generation <= cutoff_points[j]) %>%
      group_by(pop) %>%
      #summarise(slope50 = coefficients(lm(phenotype~Generation, data=.))[[2]])
      do(model = lm(phenotype ~ Generation, data=.)) %>%
      mutate(Intercept=coef(model)[1], Slope=coef(model)[2], cutoff = cutoff_points[j], simID=strsplit( sim.data[i], "_")[[1]][1])

    
  }
  sim_lm_data[[i]] = bind_rows(lm_data) 
}

(summ.data$p3_slope > summ.data$p4_slope) & (summ.data$p3_slope > summ.data$p5_slope)


test %>%
  filter(cutoff==50)

summ.data[2,]


test = bind_rows(sim_lm_data) 

bind_rows(sim_lm_data)   %>%
  ggplot(., aes(pop, Slope)) + geom_dotplot(binaxis = "y") + facet_wrap(vars(cutoff)) + theme_bw()


sim_lm_data %>%
  group_by(simID, cutoff) %>%
  summarise(mean(Slope))

sim_lm_data[[1]]  %>%
  group_by(simID, cutoff) %>%
  rowwise()


