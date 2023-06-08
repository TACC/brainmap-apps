#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Feb 13 17:11:50 2023

@author: louiszhang
"""



import pandas as pd
import numpy as np
import random
import matplotlib.pyplot as plt
from random import choices
from scipy.stats import ks_2samp
import math
from IPython.display import display


    

class NullStudyGenerator:
    
    def __init__(self, filename, numStudies=None):
        print('generated')
        self.filename = filename
        self.numStudies = numStudies
        self.df = None
        self.reference = None
        self.simFoci = None
        self.simSizes = None
        self.dfNull = None

    def generate_null_studies(self,newFile=False):
        if self.df is None:
            self.read_data_file()
            self.find_num_studies()
        self._generate_null_studies_df()
        self._write_to_file(newFile)
        
    def read_data_file(self):
        with open(self.filename, 'r', encoding='latin-1') as file:
            # Initialize variables
            data = []
            studyID = 0
            subjects = 0
            self.reference = ''
            
            # Loop through each line in the file
            for line in file:
                # Strip any leading/trailing whitespace
                line = line.strip()
                
                # Check if line starts with "// Reference="
                if line.startswith('// Reference='):
                    self.reference = line.replace('// Reference=', '')
                # Check if line starts with "// Subjects="
                elif line.startswith('// Subjects='):
                    # Extract the name and subjects from the line
                    parts = line.split('=')
                    subjects = int(parts[1])
                    studyID+=1
                elif not line.startswith('//'):
                    # Extract the x,y,z coordinates from the line
                    if line.strip():
                        coords = line.split('\t')
                        x = float(coords[0])
                        y = float(coords[1])
                        z = float(coords[2])

                        # Add the data to the list
                        data.append([studyID, subjects, x, y, z])

        # Create a pandas dataframe from the data list
        self.df = pd.DataFrame(data, columns=['studyID', 'count', 'x', 'y', 'z'])
        
    def _generate_null_studies_df(self):
        subjectsPerStudy = self.df.groupby('studyID')['count'].mean()
        fociPerStudy = self.df.groupby('studyID')['count'].count()
        self.simFoci = self._inverse_transform(fociPerStudy, self.numStudies)
        self.simSizes = self._inverse_transform(subjectsPerStudy, self.numStudies)

        dfNull = pd.DataFrame(columns=['subjects', 'numFoci', 'coordinates'])
        dfNull['numFoci'] = list(self.simFoci.sample(frac=1))
        dfNull['subjects'] = self.simSizes
        dfNull = self._expand_dataframe(dfNull)
        dfCoordinates = pd.read_csv('within_' + self.reference + '.txt', header=None, names=['coordinates'])
        dfNull['coordinates'] = dfCoordinates['coordinates'].sample(n=dfNull.shape[0]).values

        self.dfNull = dfNull
    
    def _write_to_file(self, newFile):
        
        if newFile==False:
            file = open(self.filename[:-4] + 'Null.txt', 'w')
            grouped = self.dfNull.groupby(level=0)
    
            for name, group in grouped:
                file.write('// Null Study_' + str(name) + '\n')
                file.write('// Subjects=' + str(int(group['subjects'].mean())) + '\n')
                for index, row in group.iterrows():
                    file.write(str(row['coordinates']) + '\n')
                file.write('\n')
            file.close()
        else:
            data=None
            with open(self.filename,'r',encoding='latin-1') as file:
                data=file.read()
            with open(self.filename.split('.')[0]+'noise_study_'+str(self.numStudies)+'.txt','w') as new_file:
                new_file.write(data)
            with open(self.filename.split('.')[0]+'noise_study_'+str(self.numStudies)+'.txt','a') as new_file:
                grouped=self.dfNull.groupby(level=0)
                for name,group in grouped:
                    new_file.write('// Null Study_'+str(name)+'\n')
                    new_file.write('// Subjects=' + str(int(group['subjects'].mean())) + '\n')
                    for index, row in group.iterrows():
                        new_file.write(str(row['coordinates']) + '\n')
                    new_file.write('\n')
        
    
    def _inverse_transform(self, lst, upper):
        counts = lst.value_counts()
        pdf = counts / counts.sum()
        pdf.sort_index(inplace=True)
        cdf = np.cumsum(pdf)
        unique=cdf.index.values
        sizes=np.linspace(0,1,num=upper)
        simSizes=pd.Series([],dtype='float64')
        
        for i in sizes:
            difference=cdf-i
            difference[difference<0]=2
            simSizes[len(simSizes)]=unique[difference.argmin()]
        return simSizes
    
    def find_num_studies(self):
        if not self.numStudies:
            print('Unique studies',self.df['studyID'].nunique())
            self.numStudies=math.ceil(self.df['studyID'].nunique()*.3)
            self.minStudies=math.floor(self.df['studyID'].nunique()*0.06)

    def _expand_dataframe(self, df):
        expanded_rows = []
        for index, row in df.iterrows():
            for i in range(int(row['numFoci'])):
                new_row = row.copy()
                new_row['numFoci'] = int(row['numFoci'])
                expanded_rows.append(new_row)
        expanded_df = pd.DataFrame(expanded_rows)
        return expanded_df


#testing only
    def generatePlot(self):
        print(self.simSizes)
        print(self.simFoci)
        subjectsPerStudy = self.df.groupby('studyID')['count'].mean()
        fociPerStudy = self.df.groupby('studyID')['count'].count()
        display(self.df)
        fig, axs = plt.subplots(2, 3, figsize=(10, 5),dpi=200)
        plt.subplots_adjust(hspace=.5,wspace=1)
        
        axs[0,0].hist(subjectsPerStudy, bins=range(int(subjectsPerStudy.min()),int(subjectsPerStudy.max())))
        axs[0,0].set_title("Subjects/Study Distribution n="+str(len(subjectsPerStudy)))
        axs[0,1].hist(self.simSizes, bins=range(int(subjectsPerStudy.min()),int(subjectsPerStudy.max())))
        axs[0,1].set_title("Psuedorandom Subjects/Study n="+str(len(self.simSizes)))
        
        axs[1,0].hist(fociPerStudy, bins=range(fociPerStudy.min(),fociPerStudy.max()))
        axs[1,0].set_title("Foci/Study Distribution n="+str(len(fociPerStudy)))
        axs[1,1].hist(self.simFoci, bins=range(fociPerStudy.min(),fociPerStudy.max()))
        axs[1,1].set_title("Psuedorandom Foci/Study n="+str(len(self.simSizes)))
        fig.suptitle("Psuedorandom v.s Random Comparison", fontsize=16)
        
        axs[0,2].set_title("Random Subjects/Study n="+str(len(self.simSizes)))
        axs[0,2].hist(np.random.choice(subjectsPerStudy, size=len(self.simSizes)), bins=range(int(subjectsPerStudy.min()),int(subjectsPerStudy.max())))
        axs[1,2].set_title("Random Foci/Study n="+str(len(self.simSizes)))
        axs[1,2].hist(np.random.choice(fociPerStudy,size=len(self.simFoci)),bins=range(fociPerStudy.min(),fociPerStudy.max()))

        plt.show()

    def generatePlot2(self):
        print(self.simSizes)
        print(self.simFoci)
        subjectsPerStudy = self.df.groupby('studyID')['count'].mean()
        fociPerStudy = self.df.groupby('studyID')['count'].count()
        fig, axs = plt.subplots(2, 3, figsize=(10, 5),dpi=200)
        plt.subplots_adjust(hspace=.5)
        
        axs[0,0].hist(subjectsPerStudy, bins=30)
        axs[0,0].set_title("Original Subjects/Study n="+str(len(subjectsPerStudy)))
        axs[0,1].hist(np.random.choice(subjectsPerStudy,size=26), bins=30)
        axs[0,1].set_title("Sampled Subjects/Study n="+str(len(self.simSizes)))
        
        
        
        axs[1,0].hist(fociPerStudy, bins=30)
        axs[1,0].set_title("Original Foci/Study n="+str(len(fociPerStudy)))
        axs[1,1].hist(np.random.choice(fociPerStudy, size=26), bins=30)
        axs[1,1].set_title("Sampled Foci/Study n="+str(len(self.simFoci)))
        fig.suptitle("Random Noise Study Generation Demo", fontsize=16)
        
        
        plt.show()

       



