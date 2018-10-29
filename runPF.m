function [V, I_1, I_2] = runPF(P, Q, terminal2Node, DSSObj)
% FUNCTION runPF: perform steady state power flow calculation and return
% complex bus voltage and current

% INPUT:
% P: a vector of size NODES containing real power injection
% Q: a vector of size NODES containing reactive power injection
% mappingTerminal2Bus: bidirectional mapping between nodes and buses
% (including phase identifier)
% DSSObj: a DSS Object

% OUTPUT:
% V: a vector of size NODES containing complex voltage at each node
% I_1: a vector of size NODES containing sending-end complex current at each node
% I_2: a vector of size NODES containing receiving-end complex current at each node

% Define the text interface
DSSText = DSSObj.Text;

%Reference the circuit for the interface
DSSCircuit = DSSObj.ActiveCircuit;
DSSSolution= DSSCircuit.Solution;

nNodes = length(terminal2Node.keys);

nodeList = terminal2Node.keys;
phaseIndex = ['a', 'b', 'c'];

for ind=1:nNodes
    currentKey = cell2mat(nodeList(ind));
    currentNode = terminal2Node(currentKey);
    
    if P(currentNode)~=0
        [busNumber, remain] = strtok(currentKey,'.');
        phaseNumber = str2double(strtok(remain,'.'));
        DSSText.Command = ['Edit Load.' busNumber phaseIndex(phaseNumber) ' kW=' num2str(P(currentNode)/1000) ' kvar=' num2str(Q(currentNode)/1000)];
        %DSSText.Command = ['New Load.' busNumber phaseIndex(phaseNumber) ' Bus1=' currentKey ' Phases=1 Conn=Delta kW=' num2str(P(currentNode)/1000) ' kvar=' num2str(Q(currentNode)/1000)];
    end
end

DSSText.Command = 'vsource.source.enabled = yes';

%DSSText.Command = 'Clear';
%DSSText.Command='Solve mode=snap'

% perform power flow calculation
DSSSolution.Solve;

% check if a solution is found
if DSSSolution.Converged
    % get bus voltages
    vckt = DSSCircuit.YNodeVarray;
    vckt_len = length(vckt);
    V = vckt(1:2:vckt_len)+1i*vckt(2:2:vckt_len);
    
    % sender-end currents
    I_1 = zeros(1,nNodes);
    
    % receiving-end currents
    I_2 = zeros(1,nNodes);
    
    lelem = DSSCircuit.Lines.First;
    while lelem>0
        DeviceIndex = DSSCircuit.SetActiveElement(['Line.' DSSCircuit.Lines.Name]);
        
        % get buses that are connected by a given line
        blist = DSSCircuit.CktElements(int32(DeviceIndex)).BusNames;
        %display(blist)
        
        % extract the sender node name
        senderBus = strtok(blist{1},'.');
        
        % extract the receiver node name
        receiverBus = strtok(blist{2},'.');
        
        % extract currents passing through the line (real and img components)
        CArray = DSSCircuit.CktElements(int32(DeviceIndex)).Currents;
        % this returns real and img parts of current flow for each phase in A (once from sender to receiver then from receiver to sender)
        
        OArray = DSSCircuit.CktElements(int32(DeviceIndex)).NodeOrder;
        
        for p=1:length(CArray)/4
            % get complex current at the sending-end
            I_1(terminal2Node([senderBus '.' num2str(OArray(p))])) = I_1(terminal2Node([senderBus '.' num2str(OArray(p))])) + CArray(2*p-1) + CArray(2*p)*1j;
            % display(['inserting ' num2str(CArray(2*p-1)) '+j' num2str(CArray(2*p)) ' into I1(' int2str(terminal2Node([senderBus '.' num2str(OArray(p))])) '): bus ' senderBus])
        end
        for p=1+length(CArray)/4:length(CArray)/2
            % write complex current at the receiving-end
            I_2(terminal2Node([receiverBus '.' num2str(OArray(p))])) = I_2(terminal2Node([receiverBus '.' num2str(OArray(p))])) + CArray(2*p-1) + CArray(2*p)*1j;
            % display(['inserting ' num2str(CArray(2*p-1)) '+j' num2str(CArray(2*p)) ' into I2(' int2str(terminal2Node([receiverBus '.' num2str(OArray(p))])) '): bus ' receiverBus])
        end
        
        lelem = DSSCircuit.Lines.Next;
    end
    
    telem = DSSCircuit.Transformers.First;
    while telem>0
        DeviceIndex = DSSCircuit.SetActiveElement(['Transformer.' DSSCircuit.Transformers.Name]);
        
        % get buses that are connected by a given line
        blist = DSSCircuit.CktElements(int32(DeviceIndex)).BusNames;
        %display(blist)
        
        % extract the sender node name
        senderBus = strtok(blist{1},'.');
        
        % extract the receiver node name
        receiverBus = strtok(blist{2},'.');
        
        % extract currents passing through the line (real and img components)
        CArray = DSSCircuit.CktElements(int32(DeviceIndex)).Currents;
        %display(CArray)
        % this returns real and img parts of current flow for each phase in A (once from sender to receiver then from receiver to sender)
        
        OArray = DSSCircuit.CktElements(int32(DeviceIndex)).NodeOrder;
        if any(OArray==0)
            for p=1:length(CArray)/4-1
                % get complex current at the sending-end
                I_1(terminal2Node([senderBus '.' num2str(OArray(p))])) = I_1(terminal2Node([senderBus '.' num2str(OArray(p))])) + CArray(2*p-1) + CArray(2*p)*1j;
                % display(['inserting ' num2str(CArray(2*p-1)) '+j' num2str(CArray(2*p)) ' into I1(' int2str(terminal2Node([senderBus '.' num2str(OArray(p))])) '): bus ' senderBus])
            end
            for p=1+length(CArray)/4:length(CArray)/2-1
                % write complex current at the receiving-end
                I_2(terminal2Node([receiverBus '.' num2str(OArray(p))])) = I_2(terminal2Node([receiverBus '.' num2str(OArray(p))])) + CArray(2*p-1) + CArray(2*p)*1j;
                % display(['inserting ' num2str(CArray(2*p-1)) '+j' num2str(CArray(2*p)) ' into I2(' int2str(terminal2Node([receiverBus '.' num2str(OArray(p))])) '): bus ' receiverBus])
            end
        else % no neutral conductor
            for p=1:length(CArray)/4
                % get complex current at the sending-end
                I_1(terminal2Node([senderBus '.' num2str(OArray(p))])) = I_1(terminal2Node([senderBus '.' num2str(OArray(p))])) + CArray(2*p-1) + CArray(2*p)*1j;
                % display(['inserting ' num2str(CArray(2*p-1)) '+j' num2str(CArray(2*p)) ' into I1(' int2str(terminal2Node([senderBus '.' num2str(OArray(p))])) '): bus ' senderBus])
            end
            for p=1+length(CArray)/4:length(CArray)/2
                % write complex current at the receiving-end
                I_2(terminal2Node([receiverBus '.' num2str(OArray(p))])) = I_2(terminal2Node([receiverBus '.' num2str(OArray(p))])) + CArray(2*p-1) + CArray(2*p)*1j;
                % display(['inserting ' num2str(CArray(2*p-1)) '+j' num2str(CArray(2*p)) ' into I2(' int2str(terminal2Node([receiverBus '.' num2str(OArray(p))])) '): bus ' receiverBus])
            end
        end
        
        telem = DSSCircuit.Transformers.Next;
    end
    
    %Compute power factor
    % ARPower = DSSCircuit.totalPower;
    % powerfactor = -ARPower(1)/sqrt(ARPower(1)^2 + ARPower(2)^2);
    
    % disconnect all loads so that we can compute the admittance matrix in
    % the next iteration without considering the shunt admittances
    for ind=1:nNodes
        currentKey = cell2mat(nodeList(ind));
        currentNode = terminal2Node(currentKey);

        if P(currentNode)~=0
            [busNumber, remain] = strtok(currentKey,'.');
            phaseNumber = str2double(strtok(remain,'.'));
            DSSText.Command = ['Edit Load.' busNumber phaseIndex(phaseNumber) ' kW=0 kvar=0'];
        end
    end
else
    display('did not converge')
    error('Fatal error!\n OpenDSS was unable to solve PF!');
end
