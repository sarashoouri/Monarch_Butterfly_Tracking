# **mSAIL: Milligram-Scale Multi-Modal Sensor & Analytics Monitoring Platform for Monarch Butterfly Migration Tracking**
## Light Training Data:
The light data for 2018, 2019, 2020 are stored on [./Light_Data](https://github.com/sarashoouri/Monarch_Butterfly_Tracking/tree/main/Light_Data) . Volunteer data coordinates are intentionally made inaccurate in the resolution of 10km and we will gradually populate more data as we get permission from volunteers. 
## Generate the training and testing data for neural network
* In order to generate the training data, you need to simply run the [Generate_trainset_light.m](https://github.com/sarashoouri/Monarch_Butterfly_Tracking/blob/main/Preprocessing_light_code/Generate_trainset_light.m).

* In order to generate the testing data, you need to simply run the [Generate_testset_light.m](https://github.com/sarashoouri/Monarch_Butterfly_Tracking/blob/main/Preprocessing_light_code/Generate_testset_light.m).

## Neural network models:
Neural network models are located in [./Model_codes](https://github.com/sarashoouri/Monarch_Butterfly_Tracking/tree/main/Model_codes). It includes both python and Jupyter notebook versions. You can simply run the [Mobicom_Temp.ipynb](https://github.com/sarashoouri/Monarch_Butterfly_Tracking/blob/main/Model_codes/Mobicom_Temp.ipynb)  and [Mobicom_light.ipynb](https://github.com/sarashoouri/Monarch_Butterfly_Tracking/blob/main/Model_codes/Mobicom_light.ipynb) to generate the heatmap results.

## Heatmap and Visualization:

[Heatmap_Mobicom.m](https://github.com/sarashoouri/Monarch_Butterfly_Tracking/blob/main/Heatmap_Mobicom.m) and [Visualization_Sampling.m](https://github.com/sarashoouri/Monarch_Butterfly_Tracking/blob/main/Visualization_Sampling.m) contain the codes to generate the localization results from the heatmaps generated from the NN models. They also include the codes to generate the following pictures.
* Heatmap results:
![alt text](https://github.com/sarashoouri/Monarch_Butterfly_Tracking/blob/main/Images/Heatmap.png)

* Absolute Mean Error:
![alt text](https://github.com/sarashoouri/Monarch_Butterfly_Tracking/blob/main/Images/Result.png)


## Contanct Information:
**The platform as a whole as well as individual chips are available at cost to academic researchers. 
If you have any questions, please contact the following emails: hunseok@umich.edu , inhee.lee@pitt.edu , and blaauw@umich.edu .**

