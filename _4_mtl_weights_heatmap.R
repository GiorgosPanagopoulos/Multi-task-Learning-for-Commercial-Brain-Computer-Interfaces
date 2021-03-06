#----------------------------------------------------------------------------------------------------------
# Plot Weights of Multi-task algorithms
#    1. Load theweights for each dataset
#    2. Take the mean value of each weight for all subjects and store it in the matrix to be ploted
#    3. Plot heatmap where the higher the weight the lighter the color
#----------------------------------------------------------------------------------------------------------

library(dplyr)
library(ggplot2)
library(plyr)
library(reshape2)

setwd("Path/to/mtl_weights")
files = dir()

results_table = data.frame(matrix(nrow=0,ncol=2))
names(results_table) = c("Algo","Acc")

dimensions=9

datasets = c("cmu","berkeley")

features = c( "Raw",
              "Delta",
              "Theta",
              "Alpha1",
              "Alpha2",
              "Beta1",
              "Beta2",
              "Gamma1",
              "Gamma2")

to_plot = data.frame(matrix(ncol=dimensions+3,nrow=0))

for(d in datasets){
  heat = matrix(ncol=dimensions,nrow=0)
  
  mean_w = matrix(ncol=dimensions,nrow=0)
  for(s in files){
    if(grepl(d,s)){
      
      weights = read.csv(s,header=F)
      
      if(dim(weights)[1]==9){
        weights = t(weights)
      }  
      
      normalized_weight_vec = sapply(data.frame(weights),mean)
      
      mean_w = rbind(mean_w,normalized_weight_vec)
      
    }
  }
  
  heat = rbind(heat,sapply(data.frame(mean_w),mean))
  
  heat = data.frame(heat)
  
   
  heat$dataset=d
  
  
  to_plot = rbind(to_plot,heat)
}

to_plot$Algorithms = "L21 Norm"
names(to_plot)[1:9] = features
to_plot[to_plot$dataset=="cmu","dataset"]="CMU"
to_plot[to_plot$dataset=="berkeley","dataset"]="Berkeley"

heat.m = melt(to_plot,id.vars=c("Algorithms","dataset"))


ggplot(data = heat.m, aes(x = variable, y = Algorithms)) +
  geom_tile(aes(fill = value))+xlab("Features")+ylab("Algorithms")+facet_grid(~dataset)+
  theme(axis.text.x = element_text(face = "bold", color = "black", size = 16,angle = 45, hjust = 1),
        axis.text.y = element_text(face = "bold", color = "black", size = 14,angle = 90, hjust = 0.5),
        axis.title.x = element_text(face = "bold", color = "black", size = 14),
        axis.title.y = element_blank(),#(face = "bold", color = "black", size = 14),
        strip.text.x =element_text(face = "bold", color = "black", size = 13),
        strip.text.y =element_text(face = "bold", color = "black", size = 13),legend.position="none")+
  scale_fill_gradient(low = "black", high= "grey")

ggsave("../../../../figures/mtl_weights_heatmap.png")
