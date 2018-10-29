function [nNodes, Y, mappingTerminal2Node, PhA, PhB, PhC, homesPerNode]=loadTopologyIEEE34(DSSObj)
% FUNCTION loadTopology: parse the topology config file and use values
% to initialize variables

% INPUT:
% DSSObj: OpenDSS COM Object used to obtain Ymatrix for the specified model

% OUTPUT:
% nNodes: the number of nodes
% Y: the three-phase nodal admittance matrix
% mappingTerminal2Node: mapping from bus names to node indices
% PhX: a logical vector showing whether a node is connected to phase X
% homesPerNode: the number of homes connected downstream of each node

%Reference the circuit for the interface
DSSCircuit = DSSObj.ActiveCircuit;

% Topology
NodeList = DSSCircuit.YNodeOrder;
nNodes = length(NodeList);

keySet = {'sourcebus.1','sourcebus.2','sourcebus.3','800.1','800.2','800.3','802.1','802.2','802.3','806.1','806.2','806.3','808.1','808.2','808.3','810.2','812.1','812.2','812.3','814.1','814.2','814.3','814r.1','814r.2','814r.3','850.1','850.2','850.3','816.1','818.1','816.2','816.3','824.1','824.2','824.3','820.1','822.1','826.2','828.1','828.2','828.3','830.1','830.2','830.3','854.1','854.2','854.3','832.1','832.2','832.3','858.1','858.2','858.3','834.1','834.2','834.3','860.1','860.2','860.3','842.1','842.2','842.3','836.1','836.2','836.3','840.1','840.2','840.3','862.1','862.2','862.3','844.1','844.2','844.3','846.1','846.2','846.3','848.1','848.2','848.3','852r.1','852r.2','852r.3','888.1','888.2','888.3','856.2','852.1','852.2','852.3','864.1','838.2','890.1','890.2','890.3'};
valueArray = 1:nNodes;

mappingTerminal2Node = containers.Map(keySet,valueArray);

PhA = zeros(1,nNodes);
PhB = zeros(1,nNodes);
PhC = zeros(1,nNodes);

% DSSText.Command = 'vsource.source.enabled = no';
% lelem = DSSCircuit.Loads.First;
% while lelem>0
%     DSSText.Command = ['Load.' cellstr(DSSCircuit.Loads.Name) '.enabled = no'];
%     lelem = DSSCircuit.Loads.Next;
% end
    
LoadBusNamesArray = [];
LoadBusRealLoadArray = [];
LoadBusReactiveLoadArray = [];

lelem = DSSCircuit.Loads.First;
while lelem>0
    LoadBusNamesArray = [LoadBusNamesArray,cellstr(DSSCircuit.Loads.Name)];
    LoadBusRealLoadArray = [LoadBusRealLoadArray;num2cell(DSSCircuit.Loads.kW)];
    LoadBusReactiveLoadArray = [LoadBusReactiveLoadArray;num2cell(DSSCircuit.Loads.kvar)];
    
    DSSText.Command = ['Edit Load.' cellstr(DSSCircuit.Loads.Name) ' kW=0'  ' kVAR=0'];
    lelem = DSSCircuit.Loads.Next;
end

% polyphase nodal admittace matrix
Y = constructYMatrix(DSSObj);

% lelem = DSSCircuit.Loads.First;
% while lelem>0
%     DSSText.Command = ['Load.' cellstr(DSSCircuit.Loads.Name) '.enabled = yes'];
%     lelem = DSSCircuit.Loads.Next;
% end

for i=1:length(LoadBusNamesArray)
    DSSText.Command = ['Edit Load.' LoadBusNamesArray(i) ' kW=' num2str(cell2mat(LoadBusRealLoadArray(i))) ' kvar=' num2str(cell2mat(LoadBusReactiveLoadArray(i)))];
end

% Loads
homesPerNode = zeros(1,nNodes);
loadBuses = {'802.1','802.2','802.3','806.1','806.2','806.3','808.1','808.2','808.3','810.2','812.1','812.2','812.3','814.1','814.2','814.3','850.1','850.2','850.3','816.1','818.1','816.2','816.3','824.1','824.2','824.3','820.1','822.1','826.2','828.1','828.2','828.3','830.1','830.2','830.3','854.1','854.2','854.3','832.1','832.2','832.3','858.1','858.2','858.3','834.1','834.2','834.3','860.1','860.2','860.3','842.1','842.2','842.3','836.1','836.2','836.3','840.1','840.2','840.3','862.1','862.2','862.3','844.1','844.2','844.3','846.1','846.2','846.3','848.1','848.2','848.3','888.1','888.2','888.3','856.2','852.1','852.2','852.3','864.1','838.2','890.1','890.2','890.3'};

% display(setdiff(keySet, loadBuses))

for i=1:length(loadBuses)
    % the number of homes connected to a node is drawn from a uniform
    % distrbution between 5 and 15
    homesPerNode(mappingTerminal2Node(cell2mat(loadBuses(i)))) = randi([5 15],1,1);
end
