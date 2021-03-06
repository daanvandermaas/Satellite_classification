#a linear stack of layers
source('packages.r')


######Parameters

#read in file with labels and file names
data = readRDS( file.path(path,'data.rds' )) 
#data = data[data$label %in% c(1,2,8),]
data$label = as.numeric(as.factor(data$label))

#split in train and test
split = sample(x =  c(1:nrow(data)), size = round(0.8*nrow(data)) )
train = data[split,]
test = data[-split,]


clas = as.integer(length(unique(data$label)))#number of classes
h = as.integer(64) #heigth image
w = as.integer(64) #width image

max_pred = 0.5
#####

model<-keras_model_sequential()

#configuring the Model

model %>%  
  layer_conv_2d(filter=32, kernel_size=c(3,3),padding="same",    input_shape=c(64,64,3) ) %>%  
  layer_activation("relu") %>%  
  layer_conv_2d(filter=32 ,kernel_size=c(3,3))  %>%  layer_activation("relu") %>%
  layer_max_pooling_2d(pool_size=c(2,2)) %>%  
  layer_dropout(0.25) %>%
  layer_conv_2d(filter=32 , kernel_size=c(3,3),padding="same") %>% layer_activation("relu") %>%  layer_conv_2d(filter=32,kernel_size=c(3,3) ) %>%  layer_activation("relu") %>%  
  layer_max_pooling_2d(pool_size=c(2,2)) %>%  
  layer_dropout(0.25) %>%
  layer_flatten() %>%  
  layer_dense(512) %>%  
  layer_activation("relu") %>%  
  layer_dropout(0.5) %>%  
  layer_dense(clas) %>%  
  layer_activation("softmax") 

opt<-optimizer_adam( lr= 0.0001 , decay = 1e-6 )

model %>%
  compile(loss="categorical_crossentropy", optimizer=opt, metrics = "accuracy")


#model$load_weights('db/models/model1' , by_name=FALSE)



#Train the network
for (i in 1:20000) {
  
  #lees 50 random plaatjes in
  data_class = select_files(data = train, num = 10)
  batch_labels = onehot(data_class[[2]], clas = clas)
  batch_files= data_class[[1]]

  model$fit( x= batch_files, y= batch_labels, batch_size = dim(batch_files)[1], epochs = 1L  )
  

  
  if(i %% 100 == 0){
    data_class = select_files(data = test, num = 10)
    batch_labels = onehot(data_class[[2]], clas = clas)
    batch_files= data_class[[1]]
    
    pred = model$evaluate( x= batch_files, y= batch_labels , steps = 1L )
  print( paste('Accuracy is', pred[[2]]))
  
  if(pred[[2]]> max_pred){
  #save model
  model$save_weights( 'db/models/model1' )
  max_pred = pred[[2]]
    }
  
   }
  
}
  
  
  