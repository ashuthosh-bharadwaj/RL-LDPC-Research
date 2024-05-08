from utils import *
import matlab
import numpy as np
import scipy as sp
import networkx as nx 
import matlab.engine


MATLAB = matlab.engine.start_matlab()
MATLAB.eval("addpath('LDPC_Matlab'); cd 'LDPC_Matlab'; setup; ",nargout=0)

Z = int(MATLAB.workspace['Z'])

h_submatrix = np.array(MATLAB.workspace['H'], dtype=int)
m,n = np.shape(h_submatrix)

H = SubMatrix2PCM(h_submatrix, Z)
M,N = np.shape(H)
h = sp.sparse.csr_array(H)
G = nx.bipartite.from_biadjacency_matrix(h)


K =  6
a = list(nx.simple_cycles(G,K))
a = [cyc for cyc in a if len(cyc) == K]
b = []
for cyc in a:
    if cyc[0] >= M:
        b.append(cyc[1:] + [cyc[0]])
    else:
        b.append(cyc)

# checknodes per cluster
z = 2

clusters = cluster_form(z,K_cycles=b,K=K, M=M)

num_clusters = len(clusters)

# clusters already a dictionary 
vns_in_cluster = {cluster_idx: NeighborVN(cluster, G, M) for cluster_idx, cluster in clusters.items()}

MATLAB.workspace['num_clusters'] = matlab.int64(num_clusters)

# create cell arrays for irregular sets of check nodes/ bit nodes 
MATLAB.eval("clusters = cell(num_clusters,1);", nargout=0)
MATLAB.eval("vns_in_cluster = cell(num_clusters,1);", nargout=0)

for i in range(num_clusters):
    MATLAB.eval("clusters" + "{" + str(i+1) + "} = " + str(clusters[i]) + "+ 1;", nargout=0) 
    MATLAB.eval("vns_in_cluster" + "{" + str(i+1) + "} = " + str(vns_in_cluster[i]) + "+ 1;", nargout=0)

MATLAB.eval("save('./Datasets/LDPC_init.mat')",nargout=0)
MATLAB.eval("load('./Datasets/LC_dataset.mat')",nargout=0)