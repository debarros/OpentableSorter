#Functions
library(XML)
library(RCurl)
library(stringr)

GetPage = function(url){
  x = getURI(url)
  page = htmlParse(x)
  x2 = gsub(pattern = "\n           ",replacement = "",x = x)
  
  ## Get names of restaurants
  y = data.frame(NameStart = unlist(gregexpr(pattern = 'rest-name">',x2))) + 11
  NameEnds = unlist(gregexpr(pattern = '</a>',x2)) -1
  for (i in 1:nrow(y)){
    y$NameEnd[i] = min(NameEnds[which(NameEnds > y$NameStart[i])])
  }
  
  ## Get types of cuisine
  TypeStart = unlist(gregexpr(pattern = '<div class="rest-row-meta">',x2)) + 27
  TypeEnd = unlist(gregexpr(pattern = '<i>|</i>',x2))-1
  for (i in 1:nrow(y)){
    y$TypeStart[i] = min(TypeStart[which(TypeStart > y$NameEnd[i])])
    y$TypeEnd[i] = min(TypeEnd[which(TypeEnd > y$TypeStart[i])])
  }
  
  ## Get locations of restaurants
  PlaceStart = unlist(gregexpr(pattern = '<i>|</i>',x2)) + 9
  PlaceEnd = unlist(gregexpr(pattern = '<div class="ab-testing-hide">',x2))-1
  for (i in 1:nrow(y)){
    y$PlaceStart[i] = min(PlaceStart[which(PlaceStart > y$TypeEnd[i])])
    y$PlaceEnd[i] = min(PlaceEnd[which(PlaceEnd > y$PlaceStart[i])])
  }
  
  ## Get Descriptions of restaurants
  DescStart = unlist(gregexpr(pattern = '<div class="rest-promo-message">',x2))+35
  DescEnds = unlist(gregexpr(pattern = '</div>',x2))-3
  for (i in 1:nrow(y)){
    y$DescStart[i] = min(DescStart[which(DescStart > y$PlaceEnd[i])])
    y$DescEnd[i] = min(DescEnds[which(DescEnds > y$DescStart[i])])
  }
  
  ## Get text of names, places, types, and descriptions
  y$name = substring(x2,y$NameStart,y$NameEnd)
  y$place = substring(x2,y$PlaceStart,y$PlaceEnd)
  y$type = substring(x2,y$TypeStart,y$TypeEnd)
  y$desc = substring(x2,y$DescStart,y$DescEnd)
  
  #remove unnecessay columns
  y = y[,c(9:12)]
  
  #Fix ampersands and other funny characters in restaurant names
  y$name = gsub(pattern = "&amp;", replacement = "&", x = y$name, ignore.case = TRUE)
  y$name = gsub(pattern = "&#233;", replacement = "e", x = y$name, ignore.case = TRUE)
  y$name = gsub(pattern = "&#39;", replacement = "'", x = y$name, ignore.case = TRUE)
  
  #Remove html line breaks in descriptions
  y$desc = gsub(pattern = "<br>", replacement = "", x = y$desc, ignore.case = TRUE)
  
  return(y)
} #end of GetPage function


#Remove unacceptable locations
SubSet1 = function (DiningSet, LocationInput){
  DiningSet = DiningSet[which(DiningSet$place %in% LocationInput),] #Subset by acceptable locations
  rownames(DiningSet) <- seq(length=nrow(DiningSet)) #Reset rownames  
  return(DiningSet)
}


#Remove undesired food types
SubSet2 = function (DiningSet1, FareInput){
  DiningSet1 = DiningSet1[which(DiningSet1$type %in% FareInput),] #Subset by acceptable cuisine
  rownames(DiningSet1) <- seq(length=nrow(DiningSet1)) #Reset rownames  
  return(DiningSet1)
}


#Remove rows that don't have bottomless or unlimited in the description
SubSet3 = function (DiningSet2, BeverageInput){
  if (BeverageInput){
    DiningSet2 = DiningSet2[which(grepl(pattern = "unlimited", DiningSet2$desc, ignore.case = TRUE) | grepl(pattern = "bottomless", DiningSet2$desc, ignore.case = TRUE)),]
    rownames(DiningSet2) <- seq(length=nrow(DiningSet2))} #Reset rownames  
  return(DiningSet2)
}