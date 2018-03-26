files = list.files('db/rgb', recursive = TRUE, full.names= TRUE)

classes= unlist( lapply(strsplit(files, '[/]'), function(x){
  x[[3]]
  
}))
labels = as.numeric( as.factor(classes))

data = data.frame('file' = files, 'class'= classes, 'label' = labels)

saveRDS(data, 'db/data.rds')