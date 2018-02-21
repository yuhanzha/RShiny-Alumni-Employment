library(dplyr)
library(ggmap)
library(tools)
########################################################################
dat0 <- read.csv("../output/columbia statistics 2012-2017 processed4.csv")

colname <- colnames(dat0)

ny.vect <- as.vector(as.character(unlist(dat0 %>%
  filter(grepl(".*New\\sYork.*",job_location) |
         grepl(".*NJ.*",job_location)) %>%
  select(job_location))))

boston.vect <- as.vector(as.character(unlist(dat0 %>%
  filter(grepl(".*Boston.*",job_location)) %>%
  select(job_location))))

la.vect <- as.vector(as.character(unlist(dat0 %>%
  filter(grepl(".*Los\\sAngeles.*",job_location)) %>%
  select(job_location))))

chicago.vect <- as.vector(as.character(unlist(dat0 %>%
  filter(grepl(".*Chicago.*",job_location)) %>%
  select(job_location))))

sf.vect <- as.vector(as.character(unlist(dat0 %>%
  filter(grepl(".*San\\sFrancisco.*",job_location)) %>%
  select(job_location))))

bk.vect <- as.vector(as.character(unlist(dat0 %>%
    filter(grepl(".*Bangkok.*",job_location)) %>%
    select(job_location))))


world.citi <- world.cities %>%
  filter(!(name == "San Jose" & country.etc != "USA")) %>%
  filter(!(name == "Boston" & country.etc != "USA")) %>%
  filter(!(name == "Columbus" & pop != 741677)) %>%
  filter(!(name == "Toledo" & country.etc != "USA")) %>%
  filter(!(name == "Dallas" & country.etc != "USA")) %>%
  filter(!(name == "San Jose" & country.etc != "USA")) %>%
  filter(!(name == "Los Angeles" & country.etc != "USA")) %>%
  filter(!(name == "Delhi" & country.etc != "India")) %>%
  filter(!(name == "Kingston" & country.etc != "Canada")) %>%
  filter(!(name == "Newark" & pop != 281378)) %>%
  filter(!(name == "Providence" & country.etc != "USA")) %>%
  filter(!(name == "Hyderabad" & country.etc != "India")) %>%
  filter(!(name == "Cambridge" & country.etc != "USA")) %>%
  filter(!(name == "San Diego" & country.etc != "USA")) %>%
  filter(!(name == "Santa Clara" & country.etc != "USA")) %>%
  filter(!(name == "Bombay" & country.etc != "India")) %>%
  filter(!(name == "London" & country.etc != "UK")) %>%
  filter(!(name == "Lafayette" & pop!= 112317)) %>%
  filter(!(name == "Magoula" & pop!= 4354)) %>%
  
  filter(!(name == "San Francisco" & country.etc != "USA")) 


world.citi$name <- tolower(world.citi$name)

dat <- dat0 %>%                         
  mutate(job_loc = ifelse(job_location %in% ny.vect, 
                          "New York", as.character(job_location))) %>%
  mutate(job_loc = ifelse(job_loc %in% boston.vect, 
                          "Boston", as.character(job_loc))) %>%
  mutate(job_loc = ifelse(job_loc %in% la.vect, 
                          "Los Angeles", as.character(job_loc))) %>%
  mutate(job_loc = ifelse(job_loc %in% chicago.vect, 
                          "Chicago", as.character(job_loc))) %>%
  mutate(job_loc = ifelse(job_loc %in% sf.vect, 
                          "San Francisco", as.character(job_loc))) %>%
  mutate(job_loc = ifelse(job_loc %in% bk.vect, 
                          "Bangkok", as.character(job_loc))) %>%
  mutate(job_loc = gsub(",.*", "", job_loc)) %>%
  mutate(job_loc = gsub("\\/.*", "", job_loc)) %>%
  mutate(job_loc = gsub("^\\s*", "", job_loc)) %>%
  mutate(job_loc = toTitleCase(job_loc)) %>%
  mutate(job_loc = tolower(job_loc))%>%
  left_join(world.citi, by = c("job_loc" = "name")) %>%
  select(colname, job_loc, lat, long)  %>%
  rename(end_lat = lat, end_long = long) 


place.stat <- dat %>%
  filter(!is.na(end_lat))%>%
  mutate(count = 1) %>%
  group_by(job_loc) %>%
  summarise(count = sum(count)) %>%
  ungroup() %>%
  mutate(job_loc = tolower(job_loc))%>%
  left_join(world.citi, by = c("job_loc" = "name")) %>% 
  mutate(job_loc = toTitleCase(job_loc)) %>%
  mutate(area_and_num = paste0(count, " at ", job_loc)) %>%
#  mutate(count = ifelse(count <10, count*10, count)) %>%
  filter(job_loc != "China") %>%
  select(job_loc, lat, long, count, area_and_num) %>%
  mutate(major = "Statistics")

  
people.stat <- dat %>%
  filter(!is.na(end_lat)) %>%
  mutate(start_lat = 40.67, start_long = -73.94) %>%
  select(major, job_loc, end_lat, end_long,
         start_lat, start_long) %>%
  mutate(major = "Statistics")

  



dat0.cs <- read.csv("../output/cucsms2012.csv")
#colnames(dat0.cs) <- colnames(dat0)
# CS data
#na.vec <- unique(dat.cs %>% filter(is.na(lat)) %>% select(city))
palo.vec <- c("menlo park", "menlopark", "mountain view", "mountainview", "redwood shores", "burlingame")
delhi.vec <- c("new delhi", "bengaluru", "ahmedabad", "chennai", "kolkata")


dat0.cs$city <- tolower(dat0.cs$city)

dat.cs <- dat0.cs %>% 
  mutate(city = gsub("\\s*$", "", city)) %>%
  mutate(city = ifelse(city %in% palo.vec, "palo alto", city)) %>%
  mutate(city = ifelse(city == "mumbai", "bombay", city)) %>%
  mutate(city = ifelse(city == "west lafayette", "lafayette", city)) %>%
  mutate(city = ifelse(city == "taiwan", "taipei", city)) %>%
  mutate(city = ifelse(city == "urbana-champaign", "chicago", city)) %>%
  mutate(city = ifelse(city == "athen", "athens", city)) %>%
  mutate(city = ifelse(city == "san francisco bay", "san francisco", city)) %>% 
  mutate(city = ifelse(city %in% delhi.vec, "delhi", city)) %>%  
  mutate(city = ifelse(city == "murray hill", "new york", city)) %>%  
  mutate(city = ifelse(city == "rochester", "new york", city)) %>%  
  left_join(world.citi, by = c("city" = "name")) 


place.cs <- dat.cs %>%
  filter(!is.na(lat)) %>%
  mutate(count = 1) %>%
  group_by(city) %>%
  summarise(count = sum(count)) %>%
  ungroup() %>%
  mutate(city = tolower(city))%>%
  left_join(world.citi, by = c("city" = "name")) %>% 
  mutate(city = toTitleCase(city)) %>%
  mutate(area_and_num = paste0(count, " at ", city)) %>%
#  mutate(count = ifelse(count <10, count*10, count)) %>%
  select(city, lat, long, count, area_and_num) %>%
  mutate(major = "Computer Science")

people.cs <- dat.cs %>%
  filter(!is.na(lat)) %>%
  rename(end_lat = lat, end_long = long, major = eduField) %>%
  mutate(start_lat = 40.67, start_long = -73.94) %>%
  select(major, city, end_lat, end_long,
         start_lat, start_long) %>%
  mutate(major = "Computer Science")

colnames(place.cs) <- colnames(place.stat)
colnames(people.cs) <- colnames(people.stat)

place.all <- rbind(place.cs, place.stat) %>% mutate(major = "Both included")
people.all <- rbind(people.cs, people.stat) %>% mutate(major = "Both included") 




all.split <- split(place.all, place.all$job_loc)
mean.func <- function(df) {
  return(sum(df$count))
}
all.p <- data.frame(sapply(all.split, mean.func)) 
all.pe <- all.p %>%
  mutate(job_loc = tolower(as.character(rownames(all.p)))) %>%
  left_join(world.citi, by = c("job_loc" = "name")) %>% 
  rename(count = sapply.all.split..mean.func.) %>%
  mutate(job_loc = toTitleCase(job_loc)) %>%
  mutate(area_and_num = paste0(count, " at ", job_loc)) %>%
  select(job_loc, lat, long, count, area_and_num) %>%
  mutate(major =  "Both included") 
  
  
place <- rbind(place.cs, place.stat, all.pe)%>% mutate(count = ifelse(count <=2, count*10, 
                                                               ifelse(count<=8, count*4, 
                                                               ifelse(count <=10, count*4, count))))
people <- rbind(people.cs, people.stat, people.all)  

place$X <- rownames(place)
people$X <- rownames(people)



write.csv(place, file = "../output/place.csv")
write.csv(people, file = "../output/people.csv")
