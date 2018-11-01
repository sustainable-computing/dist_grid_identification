%%
clear all
close all

realistic = false;
% realistic = true;

% simLength = 86400;
topoChangeFlag = false;

simLength = 288;
D = 288;
% topoChangeFlag = true;

%transitionTime1 = 50;

transitionTime1 = 261;
transitionTime2 = 300;

% simLength = 500;
% topoChangeFlag = true;
% transitionTime1 = 300;
% transitionTime2 = 400;

% simLength is the length of a simulation

pf = 0.95;
% pf is the constant power factor at each load bus

%%

text = pwd;

% the file that has the dss description:
% dss_path = [text, '\powerflow\IEEE13e1.dss']; % use loadTopologyIEEE13woSwitch
dss_path = [text, '\powerflow\IEEE13e2.dss']; % use loadTopologyIEEE13woSwitch
% dss_path = [text, '\powerflow\123Bus\IEEE123Master1.dss']; % use loadTopologyIEEE123
% dss_path = [text, '\powerflow\34Bus\ieee34Mod1ee.dss']; % use loadTopologyIEEE34
% dss_path = [text, '\powerflow\37Bus\ieee37e.dss']; % use loadTopologyIEEE37
display(dss_path);

[DSSObj, flag] = DSSStartup(dss_path);
% the OpenDSS Object alows interacting with the COM interface
% flag is set when the object is successfully instantiated

if ~flag
    error('Fatal error!\n Failed to create the COM object to interface with OpenDSS');
end
%% Create Distribution Network Topology

if realistic
    [NODES, Y, mappingNode2Terminal, ~, ~, ~, homesPerNode] = loadTopologyIEEE13woSwitch_new(DSSObj);
    % [NODES, Y, mappingNode2Terminal, ~, ~, ~, homesPerNode] = loadTopologyIEEE34(DSSObj);
    % [NODES, Y, mappingNode2Terminal, ~, ~, ~, homesPerNode] = loadTopologyIEEE37(DSSObj);
else
    [NODES, Y, mappingNode2Terminal, ~, ~, ~, homesPerNode] = loadTopologyIEEE13woSwitch(DSSObj);
    % [NODES, Y, mappingNode2Terminal, ~, ~, ~, homesPerNode] = loadTopologyIEEE123(DSSObj);
    % [NODES, Y, mappingNode2Terminal, ~, ~, ~, homesPerNode] = loadTopologyIEEE34(DSSObj);
    % [NODES, Y, mappingNode2Terminal, ~, ~, ~, homesPerNode] = loadTopologyIEEE37(DSSObj);
end

% NODES <= 3*BUSES
% Z is a NODES by NODES admittance matrix
% PhX is a logical selector vector for phase X
% homesPerNode is a vector of size NODES that specifies how many homes
% are connected to each bus in the network

%% Assign Loads to Buses

offset = 1;
if realistic
    % load household demands into matrices Pn and Qn
    load realpower1260homes-1day.mat
    load reactivepower1260homes-1day.mat
    [P, Q] = connectLoads2NodesPQ(Pn, Qn, homesPerNode, offset, offset+simLength-1);
    
    % creates constant complex power load aggregate at the bus level
    % P is a NODES by simLength matrix of real power injection
    % Q is a NODES by simLength matrix of reactive power injection
    clear Pn Qn
else
    % load household demands into matrix Pn
    load homeload-new3days.mat
    [P, Q] = connectLoads2Nodes(Pn, homesPerNode, offset, offset+simLength-1, pf);
    clear Pn
end

%% Select hidden states

h_idx = [];
% h_idx = [1 2];
% h_idx = [30,31,32];               % both loadTopologyIEEE13 and loadTopologyIEEE13woSwitch
% h_idx = [30,31,32,36,37,38];      % loadTopologyIEEE13
% h_idx = [33,34,35];      % loadTopologyIEEE13woSwitch
nh_idx = setdiff(1:NODES,h_idx);
P(h_idx, :) = 0;
Q(h_idx, :) = 0;

%% Power Flow Calculations

V = zeros(NODES, simLength);
% V(:,t) - bus voltage for all phases (complex vector)

I1 = zeros(NODES, simLength);
% I1(:,t) - sender-end current for all phases (complex vector)

I2 = zeros(NODES, simLength);
% I2(:,t) - receiver-end current for all phases (complex vector)

for i=1:simLength
    if i==transitionTime1 && topoChangeFlag
        operateSwitches(123, DSSObj);
        % operateSwitches(13, DSSObj);
        Y1 = constructYMatrix(DSSObj);
    elseif i==transitionTime2 && topoChangeFlag
        operateSwitches(12, DSSObj);
        Y2 = constructYMatrix(DSSObj);
        hasChanged = max(max(abs(Y2-Y1)));
    end
    [V(:,i), I1(:,i), I2(:,i)] = runPF(P(:,i), Q(:,i), mappingNode2Terminal, DSSObj);
%     [V(:,i), I1(:,i), I2(:,i)] = runPF2(mappingNode2Terminal, DSSObj);
    
    
    % run power flow to get bus voltages and current flows in the
    % network
    display(['power flow simulation completed for t = ' num2str(i)])
end

display(['rank of matrix Z = ' num2str(rank(inv(Y)))])
display(['rank of matrix V = ' num2str(rank(V))])

% get power injection at each node
I = I1 + I2;
% zero out small values generated due to numerical error
% I(abs(I)<1e-5) = 0;
display(['rank of matrix I = ' num2str(rank(I))])

VV = V;
II = I;
clear I1 I2

%% Adding noise

% withNoise = true;
withNoise = false;

noiseV = zeros(NODES, simLength);
noiseI = zeros(NODES, simLength);
stdV = zeros(NODES, simLength);
stdI = zeros(NODES, simLength);

V = VV;
I = II;

if withNoise
    relerrV = 0.00000001;
    relerrI = 0.001;
    
    for i=1:NODES
        stdV(i,:) = V(i,:)*relerrV/2.58;
        stdI(i,:) = I(i,:)*relerrI/2.58;
        
%         noiseI(i,:) = awgn(I(i,:),snr_i,'measured');
%         noiseV(i,:) = awgn(V(i,:),snr_v,'measured');

        noiseV(i,:) = normrnd(0, abs(real(stdV(i,:)))+1j*abs(imag(stdV(i,:))), 1, simLength);
        noiseI(i,:) = normrnd(0, abs(real(stdI(i,:)))+1j*abs(imag(stdI(i,:))), 1, simLength);
    end

%     GNV = tempV - V;
%     GNI = tempI - I;

    VV = V;
    II = I;
end

V = V + noiseV;
I = I + noiseI;

%% Validation

% this is to fix the source current injection

if topoChangeFlag
    I_inj = Y*V;
    I(1:3,1:transitionTime1-1) = I_inj(1:3,1:transitionTime1-1);
    I_inj = Y1*V;
    %I(1:3,transitionTime1:transitionTime2-1) = I_inj(1:3,transitionTime1:transitionTime2-1);
    I(1:3,transitionTime1:end) = I_inj(1:3,transitionTime1:end);
    
    %I_inj = Y2*V;
    %I(1:3,transitionTime2:end) = I_inj(1:3,transitionTime2:end);
    
    
    checksum1 = Y*V(:,1:transitionTime1-1)-I(:,1:transitionTime1-1);
    checksum2 = Y1*V(:,transitionTime1:end)-I(:,transitionTime1:end);
    display(max(max(checksum1)))
    display(max(max(checksum2)))
else
    I_inj = Y*V;
    I(1:3,:) = I_inj(1:3,:);
    
    checksum = Y*V-I;
    
%     checksum(abs(checksum)<5e-5)=0;
    display(max(max(checksum)))
end


%power_inj = V.*conj(I);
%power_inj(abs(power_inj)<5e-5)=0;

%S = P+Q*1i;

% checksumS = S(4:NODES,:) + power_inj(4:NODES,:);
% checksumS(abs(checksumS)<5e-5)=0;

% perform singular value decomposition of V 
svdV = svd(V);

clear I_inj

%% Identification with and without hidden states (also high fidelity vs. noisy sensors)

% [Y_est, Y_diff] = runID(V, I, Y, 10000, .8);


% find linearly independent rows of V (and the corresponding buses)
if topoChangeFlag
    [~,idx] = licols(V(:,1:transitionTime1-1)');
else
    [~,idx] = licols(V');
    %idx = idx(2:end);
    
    %idx = [1,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35];
end

%% run Identification

nidx = setdiff(1:NODES,idx);
if topoChangeFlag
    [Y22_est, Y12_est, Y11_est] = postprocessing(V(:,1:transitionTime1-1),I(:,1:transitionTime1-1),idx,nidx,Y,0.000000001);
else
    if withNoise
        [Y22_est, Y12_est, Y11_est] = postprocessing(V(:,1:D),I(:,1:D),idx,nidx,Y,0.0001);
    else
        [Y22_est, Y12_est, Y11_est] = postprocessing(V(:,1:D),I(:,1:D),idx,nidx,Y,0.0001);
    end
end
Y_est  = [Y11_est Y12_est; Y12_est.' Y22_est];

%figure;
% generateHeatmap(abs(Y-Y_est));
% display(norm(Y-Y_est, 'fro'))

generateHeatmap(abs(Y(idx,idx)-Y22_est));
display(max(max(abs(Y(idx,idx)-Y22_est))))
display(norm(Y(idx,idx)-Y22_est, 'fro'))

%generateHeatmap(abs(Y(nidx,idx)-Y12_est));

rel_error = abs(Y(idx,idx)-Y22_est)./abs(Y(idx,idx));
rel_error(find(Y(idx,idx)==0)) = 0;
generateHeatmap(rel_error);

%%
% specify the number of hidden nodes, and tuning parameter lambda

SY = Y(nh_idx,nh_idx) - Y(nh_idx,h_idx)*inv(Y(h_idx,h_idx))*Y(h_idx,nh_idx); %Schur complement 

lambda = 1;
[A, B] = runID_hidden(SY,lambda);

generateHeatmap(abs(Y(nh_idx,nh_idx)-A));

%% Topology Change Detection

searchStartTime = transitionTime1-5;
searchEndTime = transitionTime1+25;
lookback = searchStartTime - 40;
threshold = 1;

for tt=searchStartTime:searchEndTime
    Y_known = Y; % Y_est
    
    difference = max(max(abs(Y_known*V(:,lookback:tt)-I(:,lookback:tt))));
    display(difference)
    
    if difference>threshold
        identifiedTransitionTime = tt;
        break
    end
end
display(identifiedTransitionTime)
%%

lambda = 0.00009;
iter_end = 1;

%Y_known = Y_est;
[DeltaY, NewY, ~] = runDT(V(:,identifiedTransitionTime:searchEndTime), I(:,identifiedTransitionTime:searchEndTime), Y_known, lambda, iter_end);

generateHeatmap(abs(DeltaY));

display(max(max(abs(NewY-Y1))))
display(norm(abs(NewY-Y1),'fro'))
% error = abs(NewY-Y1);
% generateHeatmap(error(idx,idx))

%%
DSSObj.ClearAll;
