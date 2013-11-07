"""
run_svm.py

=========================================
SVM: Maximum margin separating hyperplane
=========================================

Plot the maximum margin separating hyperplane within a two-class
separable dataset using a Support Vector Machines classifier with
linear kernel.

Initial source:
http://scikit-learn.org/dev/auto_examples/svm/plot_separating_hyperplane.html
"""

#print __doc__

import numpy as np
import random
import pylab as pl
import matplotlib.pyplot as plt
import matplotlib.gridspec as gridspec
from sklearn import svm
from sklearn import preprocessing
import math
from matplotlib import pyplot
from mpl_toolkits.mplot3d import Axes3D

import svm_utils as utils



def chunks(l, n):
    """ Yield successive chunks from l.
    """
    output = []
    chunk_size = len(l) / n
    for i in xrange(0, len(l),chunk_size):
        output.append(l[i:i+chunk_size])
    return output

def merge_chunks(c):
    if c:
        return np.vstack(c)
    return c

def main(condNum=0):
    print 'Running SVM'
    # generate random data or use existing data?
    generateData = False
    # run test and train routine?
    testAndTrain = True
    # number of points in clouds 0 and 1 (only works if generateData)
    n0 = 40
    n1 = 40
    # dimensions (only works if generateData)
    d = 13
    # number of training and test partitions
    numsets = 10 # 10 for Meta runs, 84 for OrientLoc
    # FileNames (for !generateData)
    condName = 'SOACode{}'.format(condNum)
    # condName = 'OrientLoc'
    jackknifeType = 'LeaveOneRunOut' # use LeaveOneTrialOut for OrientLoc
    if generateData:
        datafolder = jackknifeType + '/Sim_'+ condName + '/'
    else:
        datafolder = jackknifeType + '/' + condName + '/'
    fileData = 'data_' + condName + '.dat'
    fileDataClass = 'dataClass_' + condName + '.dat'
    # specify plots
    plotClassifierAcc = True
    plotFig1 = True 
    plotByClassifier = True # plots so that classifier plane is ortho to window
    plotByAverage = True # plots so that average plane is ortho to window
    plotXversusY = True # plots dimension x versus dimension y starting at 0
    xdim = 0
    ydim = 1

    # plot both "up" and "down" support planes?
    plotSupportPlanes = True

    # we create n0+n1 separable points in d dimensions and write to files
    if generateData:
        print "Generating Data\n"
        # np.random.seed(1)
        data = np.r_[np.random.randn(n0, d) - [1]*d, np.random.randn(n1, d) + [1]*d]
        a = [0] * n0 + [1] * n1
        # random.shuffle(a)
        dataClass = a

        # dataClass = [0] * n0 + [1] * n1

        # writes data
        f = open(fileData, 'w')
        for i in data:
            for j in i:
                f.write(str(j)+" ")
            f.write("\n")
        f.close()

        # writes category (class) info
        f = open(fileDataClass, 'w')
        for i in dataClass:
            f.write(str(i)+"\n")
        f.close()

    # Read data files
    data = utils.readData(fileData)
    dataClass = utils.readDataClass(fileDataClass)

    # Makes sure data and dataClass have the same number of rows
    if data.shape[0] != np.asarray(dataClass).shape[0]:
        print "Error: data and dataClass are not the same size."
        exit()

    # Split up data for learning and testing
    if data.shape[0]/numsets != data.shape[0]/(1.0*numsets):
        print "Error: data is not divisible by numsets and cannot be split into training/test sets."
    else:
        # writes data into numsets pairs of test + training files (+ class files)
        for k in range(0, numsets):
            f = open(datafolder+'test_'+str(k)+'.dat', 'w') # creates file
            g = open(datafolder+'train_'+str(k)+'.dat', 'w') # creates file
            chunked_data = chunks(data, numsets)
            test_data = chunked_data[k]
            training_data = merge_chunks(chunked_data[0:k]+chunked_data[k+1:])
            for line in test_data:
                line = [str(l) for l in line]
                output=" ".join(line)+"\n"
                f.write(output)

            for line in training_data:
                line = [str(l) for l in line]
                output=" ".join(line)+"\n"
                g.write(output)
            f.close()
            g.close()

        for k in range(0, numsets):
            f = open(datafolder+'test_'+str(k)+'_class.dat', 'w') # creates file
            g = open(datafolder+'train_'+str(k)+'_class.dat', 'w') # creates file
            chunked_data = chunks(dataClass,numsets)
            test_data = chunked_data[k]
            training_data = merge_chunks(chunked_data[0:k]+chunked_data[k+1:])
            str_test_data = [str(l) for l in test_data]
            output="\n".join(str_test_data)
            f.write(output)

            for line in training_data:
                line = [str(l) for l in line]
                output=" ".join(line)+"\n"
                g.write(output)
            f.close()
            g.close()

    classifier_accuracies = []
    # make use of test and train files
    if testAndTrain:
        for testSetNumber in range(numsets):
            data = utils.readData(datafolder+'train_'+str(testSetNumber)+'.dat') # sets "data" to a training set
            dataClass = utils.readDataClass(datafolder+'train_'+str(testSetNumber)+'_class.dat') # gets class info for that set

            ave0 = utils.arrayMean(utils.cloud(data, dataClass, 0))
            ave1 = utils.arrayMean(utils.cloud(data, dataClass, 1))
            # print "ave0", ave0, "\nave1", ave1

            # scaler = preprocessing.StandardScaler().fit(data) # in older versions of sklearn, just 'Scaler'
            scaler = preprocessing.Scaler().fit(data)            
            scaledData = scaler.transform(data) 
            dataMean = np.mean(data,axis=0)
            dataSTD = np.std(data,axis=0)
            # print "Mean of Training Data:" + str(dataMean)
            # print "STD of Training Data:" + str(dataSTD)
            # print "Mean of Scaled Training Data:" + str(np.mean(scaledData,axis=0))
        
            # fit the model
            clf = svm.SVC(kernel='linear')
            clf.fit(scaledData, dataClass)

            # Calculate classifier accuracy on test set
            testData = utils.readData(datafolder+'test_'+str(testSetNumber)+'.dat')
            testDataClass = utils.readDataClass(datafolder+'test_'+str(testSetNumber)+'_class.dat')

            scaledTestData = scaler.transform(testData)
            # manualScaledTestData = (testData-np.tile(dataMean,(8,1)))/np.tile(dataSTD,(8,1))

            # print "Mean of Testing Data:" + str(np.mean(testData,axis=0))
            # print "Mean of Scaled Testing Data:" + str(np.mean(scaledTestData,axis=0))

            classifier_accuracies.append(utils.classifierAccuracy(scaledTestData, testDataClass, clf, ave0, ave1))

            overall_acc = sum(classifier_accuracies)/len(classifier_accuracies)
        print "OVERALL SVM ACCURACY: " + str(overall_acc) + "\n"

    if plotClassifierAcc:
        gs = gridspec.GridSpec(1, 2, width_ratios=[3, 1]) 
        ax1 = plt.subplot(gs[0])
        ax2 = plt.subplot(gs[1])
        # f, (ax1, ax2) = plt.subplots(1, 2, sharey=True)
        ax1.bar(np.arange(numsets)+1, classifier_accuracies, align='center', alpha=0.4)
        ax1.set_xlim(0, numsets+1)
        ax1.set_ylim(0, 90)
        ax1.set_xlabel('train/test set')
        ax1.set_ylabel('classifier accuracy')
        ax2.bar(0, overall_acc, align='center', alpha=0.4)
        ax2.errorbar(0, overall_acc, yerr=np.std(classifier_accuracies)/np.sqrt(numsets), ecolor='k')
        ax2.axhline(y=50, xmin=-1, xmax=1, color='k', linestyle='--')
        ax2.set_xlim(-0.8, 0.8)
        ax2.set_ylim(0, 90)
        ax2.set_xticks([])
        ax2.set_xlabel('overall')
        plt.suptitle('Classifier accuracy, {}'.format(condName))
        plt.savefig(datafolder + 'classifier_acc.png')


        # vector from center of 0s to center of 1s
        deltavector = ave1 - ave0
        center = (ave0 + ave1)/2
        # print "deltavector", deltavector
        # print "center", center



        # get the separating hyperplane
        w = clf.coef_[0]
        a = -w[xdim] / w[ydim] # finds slope
        xx = np.linspace(-5, 5, 3) # creates equidistant x values
        yy = a * xx - (clf.intercept_[0]) / w[ydim] # finds y at those values

        # separating hyperplane for average method
        mAvePlane = -deltavector[xdim]/deltavector[ydim]
        yyAve = mAvePlane * xx + (center[ydim] - mAvePlane*center[xdim])

        # print "\nclf.coef_", clf.coef_
        # print "w", w
        # print "a", a
        # print "xx", xx
        # print "clf.intercept_", (clf.intercept_[0]) / w[ydim]
        # print "yy", yy

        if plotFig1:
            # plot the parallels to the separating hyperplane that pass through the
            # support vectors
            b = clf.support_vectors_[0]
            yy_down = a * xx + (b[ydim] - a * b[xdim])
            b = clf.support_vectors_[-1]
            yy_up = a * xx + (b[ydim] - a * b[xdim])

            ### plot the line, the points, and the nearest vectors to the plane
            pl.figure(2)
            pl.plot(xx, yy)
            pl.plot(xx, yyAve)
            if plotSupportPlanes:
                pl.plot(xx, yy_down, 'k--')
                pl.plot(xx, yy_up, 'k--')
            pl.plot(center[xdim], center[ydim],'g.',markersize=8.0, color='green') # plots average of clouds

            pl.scatter(clf.support_vectors_[:, xdim], clf.support_vectors_[:, ydim],
                       s=80, facecolors='none')
            pl.scatter(scaledData[:, xdim], scaledData[:, ydim], c=dataClass, cmap=pl.cm.Paired)

            pl.axis('tight')
            pl.plot([ave0[xdim], ave1[xdim]], [ave0[ydim], ave1[ydim]])
            svmNoAve = ave1[ydim] - ((ave1[xdim]-ave0[xdim])*-1/a + ave0[ydim])
            pl.plot([ave0[xdim], ave1[xdim]], [ave0[ydim]+svmNoAve/2, ave1[ydim]-svmNoAve/2])
        ### ^ old plot ^
        ### v new plots v

        yyy = np.linspace(-2, 2, 3)
        xxxave = [utils.projVector(center, deltavector)]*3

        # Finds the location of the vertical classifier line
        clfarray=[]
        wnorm=utils.norm(w)
        points=np.linspace(-1, 1, 10000) # creates many points from -1 to 1
        for i in points:
            clfarray.append(wnorm*i) # creates an array of vectors parallel to wnorm
        clfarray = np.asarray(clfarray)
        check1 = clf.predict(clfarray[0])
        check2 = clf.predict(clfarray[0])
        for i in range(0, clfarray.shape[0]): # works down the array and finds first 
            check1 = clf.predict(clfarray[i]) # vector which flips predicted class
            if check1 != check2:
                svmInflection = utils.arrayMean(np.asarray([clfarray[i], clfarray[i-1]])) # approximates inflection point
            check2 = check1
        xxxsvm = [utils.projVector(svmInflection, w)]*3



        # Plot figs
        if plotByAverage:
            pl.figure(3)
            pl.title("Plot by Averages")
            pl.plot(xxxave, yyy)
            projData = utils.projectArray(scaledData, deltavector)
            projSupVecs = utils.projectArray(clf.support_vectors_, deltavector)
            projTestData = utils.projectArray(scaledTestData, deltavector)
            pl.scatter(projSupVecs[:, 0], projSupVecs[:, 1], s=80, facecolors='none')
            pl.scatter(projData[:, 0], projData[:, 1], c=dataClass, cmap=pl.cm.Paired)
            pl.scatter(projTestData[:, 0], projTestData[:, 1],
                       s=80, facecolors='yellow')
            pl.scatter(projTestData[:, 0], projTestData[:, 1],
                       c=testDataClass, cmap=pl.cm.Paired)
            pl.savefig(datafolder+'byaverage.png')

        if plotByClassifier:
            pl.figure(4)
            pl.title("Plot by Classifier")
            pl.plot(xxxsvm, yyy)
            projData2 = utils.projectArray(scaledData, w)
            projSupVecs2 = utils.projectArray(clf.support_vectors_, w)
            projTestData2 = utils.projectArray(scaledTestData, w)
            pl.scatter(projSupVecs2[:, 0], projSupVecs2[:, 1], s=80, facecolors='none')
            pl.scatter(projData2[:, 0], projData2[:, 1], c=dataClass, cmap=pl.cm.Paired)
            pl.scatter(projTestData2[:, 0], projTestData2[:, 1],
                       s=80, facecolors='yellow')
            pl.scatter(projTestData2[:, 0], projTestData2[:, 1],
                       c=testDataClass, cmap=pl.cm.Paired)
            pl.savefig(datafolder+'byclassifier.png')

        if plotXversusY:
            pl.figure(5)
            pl.title("Plot dimension X versus dimension Y")
            pl.scatter(clf.support_vectors_[:, xdim], clf.support_vectors_[:, ydim], s=80, facecolors='none')
            pl.scatter(scaledData[:, xdim], scaledData[:, ydim], c=dataClass, cmap=pl.cm.Paired)
            pl.scatter(scaledTestData[:, xdim], scaledTestData[:, ydim],
                       s=80, facecolors='yellow')
            pl.scatter(scaledTestData[:, xdim], scaledTestData[:, ydim],
                       c=testDataClass, cmap=pl.cm.Paired)
            pl.savefig(datafolder+'xversusy.png')

        pl.show()
        plt.close('all')

if __name__ == '__main__':
    # main(condNum)
    main()
