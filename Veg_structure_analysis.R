# This code is to run exploratory analyses on observational data 
# from the Summer 2013 field study in Patagonia, AZ
# This code deals with the vegetation structure data. Contact for data questions: Marisa
# Code developed by: Anusha Shankar, Sarah Supp, and Catherine Graham

## Load packages
library(ggplot2)
library(reshape)

##### CHOOSE WORKING DIRECTORY (uncomment the one you like)
## There are multiple .csv files in this folder
wd = "C://Users/Anusha/Documents/Dropbox/Hummingbirds/Pasantias_Patagonia_2013/Final_Databases_2013/Excel_CSV_versions/Vegetation_Structure_data/"
#wd = "/Users/sarah/Desktop/Dropbox/Hummingbirds/Pasantias_Patagonia_2013/Final_Databases_2013/Excel_CSV_versions/Vegetation_Structure_data/"
setwd(wd)

## Read in csv files
canopy <- read.csv("Canopy.csv")
siteveg_descrip <- read.csv("SiteVegetationDescriptors.csv")
genus_key <- read.csv("GenusKey.csv")
trees <- read.csv("trees.csv")
shrubs <- read.csv("shrubs.csv")
ground <- read.csv("Groundcover.csv")

## 2012 vegetation structure data to be appended to existing datasets
veg_12_monica <- read.csv("Vegetation_structure_Monica_AS.csv")
veg_12_gabriel <- read.csv("Vegetation_gabriel_AS.csv")

##-------- Cleaning and aggregating data

# Renaming shrubs variables
names(shrubs) <- c("Date", "Site", "Transect", "Point", "Observer", "Genus", 
                   "num_indivs", "Type", "Direction", "0to0.5m", "0.5to1m", "1to2m", "2to3m", "3plusm")

#### Loop to sum canopy, subcanopy, and branches data ####

canopy_df = data.frame(site = 1, point=1, numrows=1, meandensitometry =1, meancanopy=1, meansub=1, meanbranches=1)

### TODO ########### For future use?
#dataframe with canopy cover data only
#canopy = cover[,1:13]
#canopy[,c(10:13)] = canopy[,c(10:13)]/100
#names(canopy) = c("Day", "Month", "Year", "Site", "Transect", "Point", "Observer", "Direction", "Distance", 
                                     "densitometry","canopy", "subcanopy", "barebranches")

#### dataframe with ground cover data only
#ground = canopy[,c(1,2,3,4,5,6,7,8,9,14,15,16,17,18,19,20,21)]
#ground[,c(10:17)] = ground[,c(10:17)]/100
#names(ground) = c("Day", "Month", "Year", "Site", "Transect", "Point", "Observer", "Direction", "Distance", 
#                              "shrub", "forb", "grass", "soil", "rock", "organicmaterial", "water", "disturbance")

## To just pull transect sites and leave out  restoration crosses
#sites=c("HC", "PL/SC")
#points=sort(unique(canopy$Point))
#i=1

#for (s in 1:length(sites)){
#  for (p in 1:length(points)){
#    data = subset(canopy, Site == sites[s] & Point == points[p])
#    if (nrow(data) >0) {
#      meandens = mean(data$Densitometry)
#      meancanopy = mean(data$Canopy)
#      meansub = mean(data$Subcanopy)
#      meanbranches = mean(data$BareBranches)
#      canopy_df[i,] <- c(sites[s], points[p], nrow(data), meandens, meancanopy, meansub, meanbranches)
#      i = i+1
#    }
#  }
#}
                       
#### Melt functions ####
# melt canopy data using Site as id.vars
m_canopy <- melt(data=canopy, id.vars=c("Site", "Point"), 
                 measure.vars=c("Canopy", "Densitometry", "Subcanopy", "BareBranches"), na.rm=T)

# melt ground cover data
m_ground <- melt(data=ground, id.vars=c("Site", "Point"), 
                 measure.vars=c("Shrub", "Forb", "Grass", "Soil", "Rock", 
                                "OrganicMaterial", "Water", "Disturbance"), na.rm=T)

#reshape trees data for values per point and genus for each of the three tree variables
m_trees <- melt(data=trees, id.vars=c("Site", "Point", "Genus"), 
                    measure.vars=c("Height", "DBHclass", "CanopyRadius"), na.rm=T)

# melt shrubs data 
m_shrubs <- melt(shrubs, id.vars=c("Site", "Genus", "Point"), 
                 measure.vars=c("shrubs0to0.5m", "shrubs0.5to1m", "shrubs1to2m", "shrubs2to3m", "ocotillo3plusm"), na.rm=T)
names(m_shrubs) <- c("Site", "Genus", "Point", "size_class", "num_indivs")

#aggregate shrub data by site and size class
shb <- aggregate(num_indivs ~ Site + size_class, data = m_shrubs, FUN = sum)



##--------- Plots

## NOTE: I think there's something wrong with the fill geom_bar() plots- 
## all the component bars look the same size beacuse we are not plotting the values
## of the measurements, we were only plotting the number of measurements taken.
## Have to think about what this is doing some more. I've plotted points, but this isn't
## the best way to look at it for sure.

# Densitometry by site
densitometry_site <- ggplot(canopy, aes(x=Site, y=Densitometry)) + geom_boxplot() + theme_bw()
densitometry_site

# Canopy cover by site- boxplot
cc_site_box <- ggplot(m_canopy[!m_canopy$variable %in% "densitometry",],
                       aes(x=variable, y=value, fill=variable)) + facet_grid(~Site) + geom_boxplot() + 
  theme_bw() + theme(axis.text.x=element_text(angle=60, vjust=0.5))
cc_site_box

# Ground cover by site
ground_site <- ggplot(m_ground, aes(x=variable, y=value, fill=variable)) + theme_bw() +
  geom_boxplot() + facet_grid(~Site) + theme(axis.text.x=element_text(angle=60, vjust=0.5))
ground_site

# Plot tree height by genus
tree_genus_height <- ggplot(trees, aes(x=Genus, y=Height, fill=Genus)) + geom_boxplot() + theme_bw() + facet_grid(~Site) +
                           theme(axis.text.x=element_text(angle=90, vjust=0))
tree_genus_height

# Plot canopy radius by genus. Not in Rmd
tree_genus_canopy <-  ggplot(trees, aes(x=Genus, y=CanopyRadius)) + geom_boxplot() +
                    theme_bw() + theme(axis.text.x=element_text(angle=90, vjust=0))
tree_genus_canopy

# Plot dbh class by genus. Not in Rmd
tree_genus_dbh <- ggplot(trees, aes(x=Genus, y=DBHclass)) + geom_point(size=3, col="red") +
  theme_bw() + coord_flip() + facet_grid(~Site)
tree_genus_dbh

##### LOOKING FOR DIFFERENCES AMONG THE TWO SITES
# Plot tree height by site
tree_site_height <- ggplot(trees, aes(x=Site, y=Height, fill=Site)) + 
  geom_boxplot() + theme_bw()
tree_site_height

#Plot tree canopy radius by site
tree_site_canopy <- ggplot(trees, aes(x=Site, y=CanopyRadius, fill=Site)) + 
  geom_boxplot() + theme_bw()
tree_site_canopy

#Plot DBH class by site
## TODO Try to do relative abundance
tree_site_dbh <- ggplot(subset(m_trees, variable=="DBHclass"), aes(Site, fill=factor(value))) +
  geom_bar(width=0.5)
tree_site_dbh

#Plot shrub size by site
## TODO Try to do relative abundance
shrub_site_size <- ggplot(shb, aes(x=size_class, weight=num_indivs, fill = Site)) + geom_bar() +
  facet_wrap(~ Site) + theme_bw() + theme(axis.text.x=element_text(angle=60, vjust=0.5)) 
shrub_site_size
