# Jordan Pappas, Richard DiSalvo
# University of Rochester Medical Center, Princeton University
# jordan.pappas@rochester.edu



# coding: utf-8

# # Sums of squares measure (following the R2 formula)

# - sum(squared distances between share predicted and share actual)
#     - where share predicted comes from the cluster the county is classified as, for the n cluster cases
# 
# - sum(squared distances between share predicted and share actual) 
#     - where share predicted comes from the 1 cluster predictions (i.e. the raw averages)
#     
# sum(squared distances between share predicted and share actual)/sum(squared distances between share predicted and share actual)

# ## Preamble

# In[1]:


import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
import os
import random
random.seed(12345)


# In[2]:


#path="/Users/Jordan/Box/ShaleGas/Proj/oldnewdrillingclassify/" # For Jordan
path="D:/Box Sync/ShaleGas/Proj/oldnewdrillingclassify/" # For Richard
os.chdir(path + 'data')

# tmpmat -> actual shares
# dtmp -> predicted shares
# tmp2 -> county cluster classification

spudsbyyear = pd.read_csv('spudsbyyear.csv')
tmpmat = pd.read_csv('tmpmat.csv')

# unweighted
unweighteddtmp1 = pd.read_csv('unweighted1dtmp.csv')
unweighteddtmp2 = pd.read_csv('unweighted2dtmp.csv')
unweighteddtmp3 = pd.read_csv('unweighted3dtmp.csv')
unweighteddtmp4 = pd.read_csv('unweighted4dtmp.csv')
unweighteddtmp5 = pd.read_csv('unweighted5dtmp.csv')
unweighteddtmp6 = pd.read_csv('unweighted6dtmp.csv')
unweighteddtmp7 = pd.read_csv('unweighted7dtmp.csv')
unweighteddtmp8 = pd.read_csv('unweighted8dtmp.csv')
unweighteddtmp9 = pd.read_csv('unweighted9dtmp.csv')
unweighteddtmp10 = pd.read_csv('unweighted10dtmp.csv')

unweightedtmp21 = pd.read_csv('unweighted1tmp2.csv')
unweightedtmp22 = pd.read_csv('unweighted2tmp2.csv')
unweightedtmp23 = pd.read_csv('unweighted3tmp2.csv')
unweightedtmp24 = pd.read_csv('unweighted4tmp2.csv')
unweightedtmp25 = pd.read_csv('unweighted5tmp2.csv')
unweightedtmp26 = pd.read_csv('unweighted6tmp2.csv')
unweightedtmp27 = pd.read_csv('unweighted7tmp2.csv')
unweightedtmp28 = pd.read_csv('unweighted8tmp2.csv')
unweightedtmp29 = pd.read_csv('unweighted9tmp2.csv')
unweightedtmp210 = pd.read_csv('unweighted10tmp2.csv')

# weighted
weighteddtmp1 = pd.read_csv('weighted1dtmp.csv')
weighteddtmp2 = pd.read_csv('weighted2dtmp.csv')
weighteddtmp3 = pd.read_csv('weighted3dtmp.csv')
weighteddtmp4 = pd.read_csv('weighted4dtmp.csv')
weighteddtmp5 = pd.read_csv('weighted5dtmp.csv')
weighteddtmp6 = pd.read_csv('weighted6dtmp.csv')
weighteddtmp7 = pd.read_csv('weighted7dtmp.csv')
weighteddtmp8 = pd.read_csv('weighted8dtmp.csv')
weighteddtmp9 = pd.read_csv('weighted9dtmp.csv')
weighteddtmp10 = pd.read_csv('weighted10dtmp.csv')

weightedtmp21 = pd.read_csv('weighted1tmp2.csv')
weightedtmp22 = pd.read_csv('weighted2tmp2.csv')
weightedtmp23 = pd.read_csv('weighted3tmp2.csv')
weightedtmp24 = pd.read_csv('weighted4tmp2.csv')
weightedtmp25 = pd.read_csv('weighted5tmp2.csv')
weightedtmp26 = pd.read_csv('weighted6tmp2.csv')
weightedtmp27 = pd.read_csv('weighted7tmp2.csv')
weightedtmp28 = pd.read_csv('weighted8tmp2.csv')
weightedtmp29 = pd.read_csv('weighted9tmp2.csv')
weightedtmp210 = pd.read_csv('weighted10tmp2.csv')


# ## Analysis

# In[3]:


def sse_calculator(n,weight):
    unweighted_ls = []
    weighted_ls = []
    
    for i in range(1,n+1):
            
        if weight == 'unweighted':
            if i == 1:
                df1 = unweighteddtmp1
                df2 = unweightedtmp21
            if i == 2:
                df1 = unweighteddtmp2
                df2 = unweightedtmp22
            if i == 3:
                df1 = unweighteddtmp3
                df2 = unweightedtmp23
            if i == 4:
                df1 = unweighteddtmp4
                df2 = unweightedtmp24
            if i == 5:
                df1 = unweighteddtmp5
                df2 = unweightedtmp25
            if i == 6:
                df1 = unweighteddtmp6
                df2 = unweightedtmp26
            if i == 7:
                df1 = unweighteddtmp7
                df2 = unweightedtmp27
            if i == 8:
                df1 = unweighteddtmp8
                df2 = unweightedtmp28
            if i == 9:
                df1 = unweighteddtmp9
                df2 = unweightedtmp29
            if i == 10:
                df1 = unweighteddtmp10
                df2 = unweightedtmp210
        
        elif weight == 'weighted':
            if i == 1:
                df1 = weighteddtmp1
                df2 = weightedtmp21
            if i == 2:
                df1 = weighteddtmp2
                df2 = weightedtmp22
            if i == 3:
                df1 = weighteddtmp3
                df2 = weightedtmp23
            if i == 4:
                df1 = weighteddtmp4
                df2 = weightedtmp24
            if i == 5:
                df1 = weighteddtmp5
                df2 = weightedtmp25
            if i == 6:
                df1 = weighteddtmp6
                df2 = weightedtmp26
            if i == 7:
                df1 = weighteddtmp7
                df2 = weightedtmp27
            if i == 8:
                df1 = weighteddtmp8
                df2 = weightedtmp28
            if i == 9:
                df1 = weighteddtmp9
                df2 = weightedtmp29
            if i == 10:
                df1 = weighteddtmp10
                df2 = weightedtmp210

        predicted_df = pd.merge(df1, df2, how='right', left_on='cluster', right_on='clust')
        predicted_df = pd.merge(predicted_df, spudsbyyear, how ='left', left_on=['STATE','COUNTY','year'],right_on=['STATE','COUNTY','spudyear'])
        predicted_df['sqdiff'] = np.square(predicted_df['y'] - predicted_df['lambdas'])
        sseclust = sum(predicted_df['sqdiff'])
        
        if weight == 'unweighted':
            unweighted_ls.append(sseclust)
        elif weight == 'weighted':
            weighted_ls.append(sseclust)
            
    if weight == 'unweighted':
        return unweighted_ls[n-1]/unweighted_ls[0]
    elif weight == 'weighted':
        return weighted_ls[n-1]/weighted_ls[0]


# In[4]:


num_clusters = 10
unweighted_sse_ls = []
weighted_sse_ls = []
for i in range(1, num_clusters+1):
    print(sse_calculator(i,'unweighted'))
    unweighted_sse_ls.append(sse_calculator(i,'unweighted'))
for i in range(1, num_clusters+1):
    print(sse_calculator(i,'weighted'))
    weighted_sse_ls.append(sse_calculator(i,'weighted'))


# In[5]:


os.chdir(path + 'output')


# In[12]:


plt.plot(np.arange(1, num_clusters+1, 1), unweighted_sse_ls, 'o-', color='black')
plt.xlabel("Number of Clusters")
plt.ylabel("Sum of Squares Error Ratio")
plt.xticks(list(range(1, num_clusters+1)))
plt.yticks([0.4,0.5,0.6,0.7,0.8,0.9,1.0])
plt.title("Scree Plot")

plt.savefig('ScreePlotUnWtd.png')
plt.show()

plt.close()


# In[13]:


plt.plot(np.arange(1, num_clusters+1, 1), weighted_sse_ls, 'o-', color='black')
plt.xlabel("Number of Clusters")
plt.ylabel("Sum of Squares Error Ratio")
plt.yticks([0.4,0.5,0.6,0.7,0.8,0.9,1.0])
plt.title("Scree Plot")

plt.savefig('ScreePlotWtd.png')
plt.show()

plt.close()

