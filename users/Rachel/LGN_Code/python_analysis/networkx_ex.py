def plot_diff_allnet_graph(Alldata,corroutdir,tms_roi,roi_names,co_nodes,fp_nodes):
    """ Make a graph showing the differences in connectivity across the entire network
    """

    binds = [1,2]
    nets = ['co','fp']

    plt.figure(figsize=(8,8))
    plt.suptitle('TMS to: %s' %tms_roi)

    #how to do the graph:
    do_tstat = True
    thresh = 2.06 #abs thresh for graph (either t or fisher-r, depending on do_tstat), 0 = no thresh
    #p(boncorr,18 tests,27subs,2tails)<0.05 - 0.0028, t=3.3
    #p(uncorr,27 subs,2tails)<0.05 - t=2.06

    nn=0
    for bind in binds:

        cmat = dict(); cmat_se = dict()
        for n,net in enumerate(nets):
            
            #Arrange the matrix of data
            temp = Alldata[tms_roi][net][:,bind,:,:] - Alldata[tms_roi][net][:,0,:,:]
            cmat[net] = stats.nanmean(temp,axis=0)
            cmat_se[net] = util.nanste(temp,axis=0)
            #cmat_se[net] = np.triu(cmat_se[net],k=1) 
            #butil.fill_diagonal(cmat_se[net],0)

            #make into a t-stat map if called upon
            if do_tstat:
                cmat[net] = cmat[net]/cmat_se[net]
                nweight = 2
            else:
                nweight = 25

            cmat[net] = np.triu(cmat[net],k=1) #zero out values below the diagonal
            butil.fill_diagonal(cmat[net],0) #zero out the diagonal

            
            #Make a graph object
            G1 = nx.Graph(weighted = True)
            G1 = nx.from_numpy_matrix(cmat[net],G1)

            #set up labels and partition
            if net == 'co_fp':
                nnod = np.shape(temp)[1] + np.shape(temp)[2]
                nod_labels = dict(zip(range(nnod),roi_names))
            elif net == 'co':
                nnod = np.shape(temp)[1]
                nod_labels = dict(zip(range(nnod),roi_names[co_nodes]))
            elif net == 'fp':
                nnod = np.shape(temp)[1]
                nod_labels = dict(zip(range(nnod),roi_names[fp_nodes]))

            pos = nx.circular_layout(G1)

            #Make the subplot
            nn+=1
            plt.subplot(2,2,nn)
            plt.title('%s, block%s-pre' %(net,bind))
            plt.axis('off')

            #add nodes to the plot
            nx.draw_networkx_nodes(G1,pos,alpha=0.5,node_color='w')

            #add a star next to the tms-ed ROI
            if tms_roi == 'Aifo':
                if (net == 'co') or (net=='co_fp'):
                    tms_roi_ind = np.where(roi_names == 'L_aIfO')[0]
                    nx.draw_networkx_nodes(G1,pos,nodelist=tms_roi_ind,alpha=1,node_color='y',node_shape='*')
            elif tms_roi == 'Dlpfc':
                if (net == 'fp') or (net == 'co_fp'):
                    tms_roi_ind = np.where(roi_names == 'L_PFC')[0] - len(co_nodes)
                    nx.draw_networkx_nodes(G1,pos,nodelist=tms_roi_ind,alpha=1,node_color='y',node_shape='*')            

            #draw positive edges
            evals_pos = np.array([d['weight'] for (u,v,d) in G1.edges(data=True) if d['weight']>thresh])
            e_pos = [(u,v) for (u,v,d) in G1.edges(data=True) if d['weight']>thresh]
            #for en,e_p in enumerate(e_pos):
            #    nx.draw_networkx_edges(G1,pos,edgelist=e_p,width=evals_pos[en]*nweight,edge_color='r',
            #                           alpha = aweight*evals_pos[en])
            nx.draw_networkx_edges(G1,pos,edgelist=e_pos,width=evals_pos*nweight,alpha=1,edge_color='r')
            
            #draw negative edges
            evals_neg = np.array([d['weight'] for (u,v,d) in G1.edges(data=True) if d['weight']<-1*thresh])
            e_neg = [(u,v) for (u,v,d) in G1.edges(data=True) if d['weight']<-1*thresh]
            #for en,e_n in enumerate(e_neg):
            #    nx.draw_networkx_edges(G1,pos,edgelist=e_n,width=evals_neg[en]*nweight,edge_color='b',
            #                           alpha = aweight*evals_neg[en])
            nx.draw_networkx_edges(G1,pos,edgelist=e_neg,width=evals_neg*-1*nweight,alpha=1,edge_color='b')

            #draw labels
            nx.draw_networkx_labels(G1,pos,nod_labels,font_size=8,font_weight='bold')

    if do_tstat:
        figname = '%snetgraph_mags_%stms_tstat_th%s.pdf' %(corroutdir,tms_roi,thresh)
    else:
        figname = '%snetgraph_mags_%stms_th%s.pdf' %(corroutdir,tms_roi,thresh)
    
    plt.savefig(figname)
    plt.close()
    #plt.show()

def plot_diff_allnet_singlegraph(data,corroutdir,tms_roi,roi_names,co_nodes,fp_nodes):
    """ Make a graph showing the differences in connectivity across the entire network
    """

    binds = [1,2]
    nets = ['co','fp','co_fp']

    plt.figure(figsize=(16,8))
    plt.suptitle('TMS to: %s' %tms_roi)

    #how to do the graph:
    do_tstat = False
    thresh = 0 #abs thresh for graph (either t or fisher-r, depending on do_tstat), 0 = no thresh

    nn=0
    for bind in binds:

        #Arrange the matrix of data
        temp = data[tms_roi][:,bind,:,:] - data[tms_roi][:,0,:,:]
        cmat_orig = stats.nanmean(temp,axis=0)
        cmat_se = util.nanste(temp,axis=0)

        if do_tstat:
            cmat_orig = cmat_orig/cmat_se
            nweight = 2
        else:
            nweight = 15
            aweight = 3

        #format the matrix
        cmat_orig = np.triu(cmat_orig,k=1) #zero out values below the diagonal
        butil.fill_diagonal(cmat_orig,0) #zero out the diagonal

        for net in nets:

            #select network from matrix, make all else 0
            cmat0 = np.zeros(cmat_orig.shape)
            cmat = np.zeros(cmat_orig.shape)
            if net=='co':
                cmat0[co_nodes,:] = cmat_orig[co_nodes,:]
                cmat[:,co_nodes] = cmat0[:,co_nodes]
            elif net=='fp':
                cmat0[fp_nodes,:] = cmat_orig[fp_nodes,:]
                cmat[:,fp_nodes] = cmat0[:,fp_nodes]
            elif net=='co_fp':
                cmat0[co_nodes,:] = cmat_orig[co_nodes,:]
                cmat[:,fp_nodes] = cmat0[:,fp_nodes]

            
            #make a graph object
            G1 = nx.Graph(weighted = True)
            G1 = nx.from_numpy_matrix(cmat,G1)

            #make a fake graph object to use for position info
            Gfakeco = nx.Graph(weighted = True)
            Gfakeco = nx.from_numpy_matrix(np.zeros((len(co_nodes),len(co_nodes))),Gfakeco)
            Gfakefp = nx.Graph(weighted = True)
            Gfakefp = nx.from_numpy_matrix(np.zeros((len(fp_nodes),len(fp_nodes))),Gfakefp)

            #set up labels and partitions
            nnod = len(co_nodes) + len(fp_nodes)
            nod_labels = dict(zip(range(nnod),roi_names))

            #get the positions
            #pos = nx.circular_layout(G1)
            pos_co = nx.circular_layout(Gfakeco)
            pos_fp = nx.circular_layout(Gfakefp)
            pos_all = pos_co
            for fn in fp_nodes:
                pos_all[fn] = pos_fp[fn-len(co_nodes)]
                pos_all[fn] = pos_all[fn] + np.array([2, 0])


            #start plotting
            nn+=1
            plt.subplot(2,3,nn)
            plt.title('block%s-pre' %bind)
            plt.axis('off')

            #add nodes
            nx.draw_networkx_nodes(G1,pos_all,nodelist=co_nodes,node_color='w')
            nx.draw_networkx_nodes(G1,pos_all,nodelist=fp_nodes,node_color='w')

            #could add a star next to TMS'ed node? See other code

            #draw positive edges
            evals_pos = np.array([d['weight'] for (u,v,d) in G1.edges(data=True) if d['weight']>thresh])
            e_pos = [(u,v) for (u,v,d) in G1.edges(data=True) if d['weight']>thresh]
            #nx.draw_networkx_edges(G1,pos_all,edgelist=e_pos,width=evals_pos*nweight,alpha=1,edge_color='r')
            for e,e_p in enumerate(e_pos):
                aval = evals_pos[e]*aweight
                if aval > 1:
                    aval = 1
                nx.draw_networkx_edges(G1,pos_all,edgelist=[e_p],width=evals_pos[e]*nweight,
                                       edge_color='r',alpha=aval)


            #draw negative edges
            evals_neg = np.array([d['weight'] for (u,v,d) in G1.edges(data=True) if d['weight']<-1*thresh])
            e_neg = [(u,v) for (u,v,d) in G1.edges(data=True) if d['weight']<-1*thresh]
            #nx.draw_networkx_edges(G1,pos_all,edgelist=e_neg,width=evals_neg*-1*nweight,alpha=1,edge_color='b')
            for e,e_n in enumerate(e_neg):
                aval = evals_neg[e]*-1*aweight
                if aval > 1:
                    aval = 1
                nx.draw_networkx_edges(G1,pos_all,edgelist=[e_n],width=evals_neg[e]*-1*nweight,
                                       edge_color='b',alpha=aval)

            #draw labels
            nx.draw_networkx_labels(G1,pos_all,nod_labels,font_size=8,font_weight='bold')

    if do_tstat:
        figname = '%snetgraphsingle_mags_%stms_tstat_th%s.pdf' %(corroutdir,tms_roi,thresh)
    else:
        figname = '%snetgraphsingle_mags_%stms_th%s.pdf' %(corroutdir,tms_roi,thresh)

    #plt.show()
    #1/0

    plt.savefig(figname)
    plt.close()
    #plt.show()
