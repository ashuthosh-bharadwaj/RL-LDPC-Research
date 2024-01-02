from utils import *
import matlab
import numpy as np
import scipy as sp
import networkx as nx 
import matlab.engine
MATLAB = matlab.engine.start_matlab()



MATLAB.eval("addpath('./LDPC_M'); cd './LDPC_M/'; setup;",nargout=0)
Z = int(MATLAB.workspace['z'])


h_submatrix = array(MATLAB.workspace['H'], dtype=int)
m,n = shape(h_submatrix)
H = SubMatrix2PCM(h_submatrix, Z)
M,N = shape(H)
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

# creating all checknodes 
CN = set()
for i in range(M):
    CN.add(i)

clusters = cluster_form(z,K_cycles=b,K=K, M=M)