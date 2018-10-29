function [nNodes, Y, mappingTerminal2Node, PhA, PhB, PhC, homesPerNode]=loadTopologyIEEE37(DSSObj)
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

keySet = {'sourcebus.1','sourcebus.2','sourcebus.3','799.1','799.2','799.3','709.1','709.2','709.3','775.1','775.2','775.3','701.1','701.2','701.3','702.1','702.2','702.3','705.1','705.2','705.3','713.1','713.2','713.3','703.1','703.2','703.3','727.1','727.2','727.3','730.1','730.2','730.3','704.1','704.2','704.3','714.1','714.2','714.3','720.1','720.2','720.3','742.1','742.2','742.3','712.1','712.2','712.3','706.1','706.2','706.3','725.1','725.2','725.3','707.1','707.2','707.3','724.1','724.2','724.3','722.1','722.2','722.3','708.1','708.2','708.3','733.1','733.2','733.3','732.1','732.2','732.3','731.1','731.2','731.3','710.1','710.2','710.3','735.1','735.2','735.3','736.1','736.2','736.3','711.1','711.2','711.3','741.1','741.2','741.3','740.1','740.2','740.3','718.1','718.2','718.3','744.1','744.2','744.3','734.1','734.2','734.3','737.1','737.2','737.3','738.1','738.2','738.3','728.1','728.2','728.3','729.1','729.2','729.3','799r.1','799r.2','799r.3'};
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
loadBuses = {'709.1','709.2','709.3','775.1','775.2','775.3','701.1','701.2','701.3','702.1','702.2','702.3','705.1','705.2','705.3','713.1','713.2','713.3','703.1','703.2','703.3','727.1','727.2','727.3','730.1','730.2','730.3','704.1','704.2','704.3','714.1','714.2','714.3','720.1','720.2','720.3','742.1','742.2','742.3','712.1','712.2','712.3','706.1','706.2','706.3','725.1','725.2','725.3','707.1','707.2','707.3','724.1','724.2','724.3','722.1','722.2','722.3','708.1','708.2','708.3','733.1','733.2','733.3','732.1','732.2','732.3','731.1','731.2','731.3','710.1','710.2','710.3','735.1','735.2','735.3','736.1','736.2','736.3','711.1','711.2','711.3','741.1','741.2','741.3','740.1','740.2','740.3','718.1','718.2','718.3','744.1','744.2','744.3','734.1','734.2','734.3','737.1','737.2','737.3','738.1','738.2','738.3','728.1','728.2','728.3','729.1','729.2','729.3'};

% display(setdiff(keySet, loadBuses))

for i=1:length(loadBuses)
    % the number of homes connected to a node is drawn from a uniform
    % distrbution between 5 and 15
    homesPerNode(mappingTerminal2Node(cell2mat(loadBuses(i)))) = randi([5 15],1,1);
end

