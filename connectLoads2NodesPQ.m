function [P,Q] = connectLoads2NodesPQ(Pn, Qn, homesPerNode, startIndex, endIndex)
% FUNCTION connectLoads2Nodes: creates real and reactive power injection vectors

% INPUT:
% Pn: a HOMES by simLength matrix containing individual household loads
% homesPerNode: a vector of size NODES specifying the number of household
% loads aggregated at each bus. Note that sum(homesPerNode) <= HOMES
% startIndex: the start index
% endIndex: the end index
% pf: predefined power factor at each node injecting power

% OUTPUT:
% P: total real power injection for each node
% Q: total reactive power injection for each node

nNodes = length(homesPerNode);
P = zeros(nNodes, endIndex-startIndex+1);
Q = zeros(nNodes, endIndex-startIndex+1);
ind = 1;

for i=1:nNodes
    P(i,:) = sum(Pn(ind:ind+homesPerNode(i)-1,startIndex:endIndex));
    Q(i,:) = sum(Qn(ind:ind+homesPerNode(i)-1,startIndex:endIndex));
    ind = ind + homesPerNode(i);
end
