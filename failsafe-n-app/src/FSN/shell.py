#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Feb 16 22:24:26 2023

@author: louiszhang
"""

#added for testing
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D

import numpy as np
from GenerateNullLouis import NullStudyGenerator
import pandas as pd
from IPython.display import display
from sklearn.neighbors import KNeighborsClassifier
from sklearn.metrics.pairwise import euclidean_distances

#generates text file to be inputed by user into ALE
def generateNewFile(filepath, data):
    directory="/".join(filepath.split('/')[:-1])
    filename=filepath.split('/')[-1]
    #extract data from null study file
    with open(filepath[:-4]+"Null.txt",'r') as null_file:
        dataNull=null_file.read()
    #create new file
    with open(directory+"/"+filename[:-4]+'temp.txt', 'w') as temp_file:
        temp_file.write(data)
    #append null studies to new file
    with open(directory+"/"+filename[:-4]+'temp.txt', 'a') as temp_file:
        temp_file.write('\n\n'+dataNull)

#Input: knn classifier and number of clusters that were present in original ALE file. Users are asked to input the location of the new ALE output
#Output: a list whose length corresponds to the number of clusters. Clusters that were detected in the new ALE file are saved as 1, otherwise clusters that were eliminated are saved as 0
def compareClusters(knn,numClusters,original):
    filepath = input('Enter filepath for xls sheet: ')
   
    newdf = pd.read_csv(filepath, delimiter='\t')
    if newdf.empty:
        return np.zeros(numClusters)
    clusters=knn.predict(newdf[['x','y','z']])
    
    path=filepath.split('.')[0]
    distances=euclidean_distances(newdf[['x','y','z']],original[['x','y','z']]).min(axis=1)
    newdf['predicted clusters']=clusters
    newdf['distances']=distances
# =============================================================================
#     newdf=newdf[newdf['distances']<5]
# =============================================================================
    newdf.to_csv(path+str('.csv'),index=False)
    lst=np.zeros(numClusters)
    lst[np.unique(newdf['predicted clusters'])-1]=1
    return lst
    

#takes in a a row from testdf, returns true if FSN is determined to be greater than the upper bound, lower than the lower bound, or if FSN has been found   
#also writes the FSN into a text file
def checkCompleted(values,filepath,clusterNum):
    valuesLst=values.tolist()
    directory="/".join(filepath.split('/')[:-1])
    filename=filepath.split('/')[-1]
    if valuesLst[0]==0:
        with open(directory+'/'+filename[:-4]+'FSN.txt','a') as file:
            file.write('Cluster #'+str(clusterNum)+' FSN number: '+'<'+str(values.index[0])+'\n')
        return True
    if valuesLst[-1]==1:
        with open(directory+'/'+filename[:-4]+'FSN.txt','a') as file:
            file.write('Cluster #'+str(clusterNum)+' FSN number: '+'>'+str(values.index[-1])+'\n')
        return True
    for i in range(len(valuesLst)-1):
        if valuesLst[i]==1 and valuesLst[i+1]==0:
            with open(directory+'/'+filename[:-4]+'FSN.txt','a') as file:
                file.write('Cluster #'+str(clusterNum)+' FSN number: '+str(i+values.index[0]+1)+'\n')
            return True
    return False

#takes in a row from testdf which contains the values for all possible addednull studies. returns the minimum of null studies to be added and the maximum
def minMax(row):
    #find minStudies: the index of the largest value tested that is smaller than the FSN
    temp=row.where(row==1)
    minStudies=temp.last_valid_index()
    #find maxStudies: the index of the smallest value tested that is larger than the FSN
    temp=row.where(row==0)
    maxStudies=temp.first_valid_index()

    if minStudies==None:
        minStudies=row.index[0]
    if maxStudies==None:
        maxStudies=row.index[-1]
    return minStudies, maxStudies

#takes in a row from testdf and removes all 1s following the first 0
def correctdf(series):
    if 0 in series.values:
        series=series.reset_index(drop=True)
        idx=series[series==0].index.min()
        series.iloc[idx+1:]=0
    return series
        

def main():
    filepath = '/Users/louiszhang/Documents/GitHub/ALE-FailSafe-N/EickhoffHBM09.txt'
    clustersdf = pd.read_csv('/Users/louiszhang/Documents/GitHub/ALE-FailSafe-N/EickhoffHBM09_C01_1k_peaks.xls',delimiter='\t')
    num_clusters = clustersdf['Cluster #'].nunique()
    
    grouped=clustersdf.groupby('Cluster #')
    
    #train KNN classifier on x y z coordinates. set the nearest neighbors to the minimum number of foci per cluster
    knn=KNeighborsClassifier(n_neighbors=grouped.size().min())
    knn.fit(clustersdf[['x','y','z']],clustersdf['Cluster #'])

    
    #generates a null.txt file that contains ceil(.3k) null studies
    nullStudy = NullStudyGenerator(filepath)
    nullStudy.generate_null_studies()
    
    #reads in original ALE file to allow creation of temp file without modifying the original file
    with open(filepath,'r') as original_file:
        data=original_file.read()

    #create testdf that contains each of the values to be tested
    minStudies=nullStudy.minStudies
    maxStudies=nullStudy.numStudies
    columnNames=list(range(minStudies, maxStudies+1))
    columnNames.insert(0,'cluster')
    testdf=pd.DataFrame(columns=columnNames)
    testdf['cluster']=np.arange(1,num_clusters+1)
    testdf.set_index('cluster', inplace=True)
    
# =============================================================================
#     #added for testing
#     fig=plt.figure(dpi=200,figsize=(6,6))
#     ax=fig.add_subplot(111,projection='3d')
#     cmap = plt.cm.get_cmap('hsv', len(clustersdf['Cluster #'].unique()))
#     colors = [cmap(i) for i in range(len(clustersdf['Cluster #'].unique()))]
#     for name, groups in clustersdf.groupby('Cluster #'):
#         ax.scatter(groups['x'], groups['y'], groups['z'], label=name, color=colors[int(name)-1])
# 
# 
#     ax.set_xlabel('X')
#     ax.set_ylabel('Y')
#     ax.set_zlabel('Z')
#     ax.legend()
#     
#     # Show the plot
#     plt.show()
#     nullStudy.generatePlot()
# =============================================================================
    #run iterative binary search while storing previous results in testdf.
    for i in range(num_clusters):
        
        row=testdf.iloc[i]
        minStudies,maxStudies=minMax(row)
        while not checkCompleted(row,filepath,i+1):
            print('which row: ',i)
            mid=(minStudies+maxStudies)//2
            if not testdf[mid].isna().all():
                mid+=1
            nullStudy.numStudies=mid
            print('added null:',nullStudy.numStudies)
            print('min studies to add:',minStudies)
            print('max studies to add:',maxStudies)
            nullStudy.generate_null_studies()
            generateNewFile(filepath, data)
            comparison=compareClusters(knn,num_clusters,clustersdf)
            testdf[nullStudy.numStudies]=comparison
            
            if comparison[i]==0:
                maxStudies=nullStudy.numStudies-1
            else:
                minStudies=nullStudy.numStudies+1
            row=testdf.iloc[i]
            testdf=testdf.apply(correctdf,axis=1,result_type='broadcast')
            display(testdf[nullStudy.numStudies])
            display(testdf)
    testdf.to_csv('data.txt',sep='\t',index=False)
                

    

if __name__=='__main__':
    main()