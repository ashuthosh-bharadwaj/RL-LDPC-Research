% Based on given cluster, find the right set of var nodes and checknodes and commence flooding; 
CNs = clusters{a};
VNs = vns_in_cluster{a};

num_cns = numel(CNs);
num_vns = numel(VNs);

idxmap_C = dictionary(1:num_cns, CNs);
idxmap_V = dictionary(VNs, 1:num_vns);


current = ldpc_registers{a};


% C -> V

for cn_idx = 1:num_cns

    places = BitsinCheck{idxmap_C(cn_idx)};
    current(cn_idx, idxmap_V(places)) = l(places) -  current(cn_idx, idxmap_V(places));

    Mforw = tanh(current(cn_idx, idxmap_V(places))/2);
    product = prod(Mforw);
    Mforw = 2*(product./Mforw);

    % Mforw = Min(current(cn_idx, idxmap_V(places)));
    
    current(cn_idx, idxmap_V(places)) = Mforw;

end


% V -> C

l(VNs) = l(VNs) + sum(current);

ldpc_registers{a} = current; % re-init for self-belief removal


%{ Mforw debug prints 

% fprintf(1,"Before Mforw calc \n\n");

% if ~allfinite(Mforw)
%     fprintf(1,"After tanh( ) \n");
%     fprintf(1,"The cluster is %d \n\n", a);
%     disp(clusters{a})
%     keyboard();
% end


% if ~allfinite(Mforw)
%     fprintf(1,"After atanh of product \n");
%     fprintf(1,"The cluster is %d \n\n", a);
%     disp(clusters{a})
%     keyboard();
% end

%}