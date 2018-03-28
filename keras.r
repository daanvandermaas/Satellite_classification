#a linear stack of layers
surce('packages.r')

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






#Train the network
for (i in 1:20000) {
  
  #lees 50 random plaatjes in
  data_class = select_files(data = train, num = 2)
  batch_labels = onehot(data_class[[2]], clas = 3)
  batch_files= data_class[[1]]
  
  model$fit( x= batch_files, y= batch_labels, batch_size = dim(batch_files)[1], epochs = 1L  )
  

  
  if(i %% 100){
    data_class = select_files(data = test, num = 100)
    batch_labels = onehot(data_class[[2]], clas = 3)
    batch_files= data_class[[1]]
    
    pred = model$evaluate( x= batch_files, y= batch_labels , steps = 1L )
  print( paste('Accuracy', pred[[2]]))
   }
  
}
  
  
  