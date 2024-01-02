import numpy as np
import scipy as sp
import networkx as nx 

def cyc_shift_iden(k,z):
    I = np.eye(z)
    I_1 = I[:, z-1].reshape((z,1))
    I_1 = np.append(I_1, I[:,0:z-1], axis=1)

    if k == -1:
        return np.zeros((z,z))
    elif k == 0:
        return I
    else: 
        return np.linalg.matrix_power(I_1,k)
    
    
def BitsinCheck(layer, z, row_num):
    bitnodes = []
    for SubMatrixCol, SubMatrixVal in enumerate(layer):
        if SubMatrixVal == -1:
            continue
        elif SubMatrixVal == 0:
            bitnodes.append(z*SubMatrixCol + ((row_num)%z))
        else:
            bitnodes.append(z*SubMatrixCol + ((row_num + SubMatrixVal-1)%z) + 1)
    
    return bitnodes


def incrementor(prev_bitnodes,z):
    next_bitnodes = []
    for b in prev_bitnodes:
        quotient, remainder = b//z, b%z
        next_pos = (remainder + 1)%z
        next_bitnodes.append(z*quotient + next_pos)
    
    return next_bitnodes


def min_algo(x):
    y = abs(x)
    min1 = np.min(y)
    min1_pos = np.argmin(y)

    y[min1_pos] = np.inf
    min2 = min(y)

    w = min1*np.ones(len(x),)
    w[min1_pos] = min2

    parity = np.prod(np.sign(x))
    w = w*parity*np.sign(x)

    return w         


def SubMatrix2PCM(SubMatrix, z):
    m,n = shape(SubMatrix)
    
    H = cyc_shift_iden(SubMatrix[0,0],z)
    for idx in range(1,n): 
        H = append(H, cyc_shift_iden(SubMatrix[0,idx],z),1)

    for i in range(1,m): 
        g = cyc_shift_iden(SubMatrix[i,0],z)
        for idx in range(1,n): 
            g = append(g, cyc_shift_iden(SubMatrix[i,idx],z),1)
        H = append(H,g,0)
    return H


def int_m(l):
    fin = 0
    for i in l:
        fin = 2*fin + i
    return fin


def Unionise(A):
    Union = set()
    for _ ,value_list in A.items():
        for value in value_list:
            Union.add(value)
    return Union 


def Histogramize(A,size):
    Hist = zeros((size,))
    Set_invert = {i:[] for i in range(size)}

    for key,value_list in A.items():
        for value in value_list:
            Set_invert[value].append(key)
            Hist[value] += 1
    
    return Hist, Set_invert


# Cycle maximised cluster formation
def cluster_form(z, K_cycles, K, M):
    x = 1
    Clusters = {}
    e = 0
    C = {}

    for cyc in K_cycles:
        S_x = [cyc[i] for i in range(K) if not i%2]
        C.update({(x-1):S_x})
        x += 1

    Hist, Set_invert = Histogramize(C,M) 

    for cyc in K_cycles:
        # getting c_star such that:
            # c_star \in CNs \ all CNs already in clusters
            # c_star = argmax histogram(CNs \ all CNs already in clusters)

        Cluster_union = Unionise(Clusters)

        Remaining = CN - Cluster_union
        if len(Remaining) == 0:
            break        
        
        cn_list = [x for x in Remaining]
        c_star = cn_list[argmax(Hist[cn_list])]

        Union_SK = {}
        for k in Set_invert[c_star]:
            Union_SK.update({k:C[k]})

        _C_ = Unionise(Union_SK) - Cluster_union
        sorted_C_ = sorted(_C_)

        if len(_C_) >= z:
            new_cluster_list = [sorted_C_[x] for x in range(z)]
            Clusters.update({e:new_cluster_list})
            e += 1             
        else:
            _C_bar = sorted(CN - Cluster_union.union(_C_))
            _C_bar = set(_C_bar[:z-len(_C_)])
            new_cluster_list = sorted(_C_bar.union(_C_))
            Clusters.update({e:new_cluster_list})
            e += 1

    return Clusters