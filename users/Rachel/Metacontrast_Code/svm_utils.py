#!/usr/bin/env python
# encoding: utf-8
"""
svm_utils.py

Created by Rachel on 2013-04-18.
Copyright (c) 2013 __MyCompanyName__. All rights reserved.
"""
import numpy as np
import math

# Reads files with one ordered pair (space between x y z) per line
def readData(fileName):
    f = open(fileName)
    data = [] # resets "data"
    for line in f.readlines():
        data.append([])
        for i in line.split():
            data[-1].append(float(i))
    f.close()
    data = np.asarray(data)
    d = data.shape[1] # sets dimension to reflect this dataset
    return data

# Reads class data (0s and 1s must match corresponding data)
def readDataClass(fileName):
    f = open(fileName)
    dataClass = [] # resets "dataClass"
    for line in f.readlines():
        for i in line.split():
            dataClass.append(int(i))
    f.close()
    return dataClass

# gets the average tuple in a list of tuples
def arrayMean(X):
    dim = X.shape
    Xmean = [0]*dim[1] # creates and populates "Xmean"
    for i in range(0, dim[1]):
        Xmean[i] = np.average(X[:, i])
    Xmean = np.asarray(Xmean)
    return Xmean

# returns array with only one class of data point (from dataClass)
def cloud(X, Y, n): # n = 0 or 1 (for the two clouds, respectively)
    dim = X.shape
    Xcloud = []
    for i in range(0, dim[0]):
        if Y[i]==n: Xcloud.append(X[i])
    Xcloud = np.asarray(Xcloud)
    return Xcloud

# Define dot product
def dot_prod(a, b):
    return sum(ai * bi for ai, bi in zip(a, b))
    
# Normalize a vector
def norm(v):
    return v / math.sqrt(dot_prod(v,v))

# Create ~random orthogonal vector to vector v
def makeOrthoVector(v):
    randnumber = .52099932 # Just because I feel like it
    w = [randnumber] * v.shape[0] # This will break later if w is parallel to v
    ortho = w - v * dot_prod(w, v) / dot_prod(v, v)
    if dot_prod(ortho, v) == 0: # I may have confused the math up here... at any rate, this is just to catch an extremely unlikely error
        print "Error: The very unlikely has happened! A randomly produced vector \nis parallel to a specified vector."
    return ortho

# Project a vector v and scale it to a dimension s
def projVector(v, s):
    s = norm(s) # normalizes s
    return dot_prod(v, s)/dot_prod(s, s) #* s # "* s" makes this a std projection

# Projects dataset onto two dimensions
def projectArray(X, v): # dataset X, v is in plane; other basis will be created
    w = makeOrthoVector(v) # this is the other basis
    projX = [0]*X.shape[0] # creates and populates "projX"
    i = 0
    for x in X:
        projX[i]=(projVector(x, v), projVector(x, w))
        i += 1
    return np.asarray(projX)

def classifierAccuracy(testSet, testSetClass, clf, ave0, ave1):
    aveCounter = 0
    for i in range(0, testSet.shape[0]):
        if testSetClass[i] == 0:
            if np.linalg.norm(testSet[i]-ave0) < np.linalg.norm(testSet[i]-ave1):
                aveCounter+=1
        elif testSetClass[i] == 1:
            if np.linalg.norm(testSet[i]-ave0) > np.linalg.norm(testSet[i]-ave1):
                aveCounter+=1
    print "Classifying by Average gives " + str(1.0*aveCounter/testSet.shape[0]*100) + "% accuracy.\n" 

    for i in range(0, testSet.shape[0]):
        print "Classifier guess:" + str(clf.predict(testSet[i])) + '    ' + "Correct answer:" + str(testSetClass[i])
    print "Classifying by SVM gives " + str(clf.score(testSet, testSetClass)*100)+ "% accuracy.\n"

    SVM_acc = clf.score(testSet, testSetClass)*100

    return SVM_acc



