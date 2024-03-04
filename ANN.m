clc
clear

%% ANN
Input = readtable('Book1.xlsx','Sheet','Sheet2');
Output = readtable('Book1.xlsx','Sheet','Sheet3');

it = Input(1:size(Input,1),1:floor(0.7*size(Input,2)));
tt = Output(1:size(Output,1),1:floor(0.7*size(Output,2)));

iv = Input(1:size(Input,1),floor(0.7*size(Input,2))+1:end);
tv = Output(1:size(Output,1),floor(0.7*size(Output,2))+1:end);

maxHn = input('max Hn :');
maxEpoch = input('max Epoch :');

ot = cell(maxHn,maxEpoch/10);
ov = cell(maxHn,maxEpoch/10);
%otest = cell(maxHn,maxEpoch/10);
RMSEtrain = cell(maxHn,maxEpoch/10);
RMSEverification = cell(maxHn,maxEpoch/10);
%RMSEtest = cell(maxHn,maxEpoch/10);
DCtrain = cell(maxHn,maxEpoch/10);
DCverification = cell(maxHn,maxEpoch/10);
%DCtest = cell(maxHn,maxEpoch/10);
TR = cell(maxHn,maxEpoch/10);
NET = cell(maxHn,maxEpoch/10);
VOLtrain=cell(maxHn,maxEpoch/10);
VOLverification=cell(maxHn,maxEpoch/10);

for epoch = 10:10:maxEpoch
    for Hn = 1:maxHn
        net = newff(it,tt,Hn,{'tansig' 'tansig'},'trainlm');
        net = init(net);
        net.divideFcn = '';
%         net.divideParam.trainRatio  =  70/100;
%         net.divideParam.valRatio  =  30/100;
%         net.divideParam.testRatio  =  15/100;
        net.trainParam.epochs = epoch;
        net.trainParam.show = NaN;
        [net,tr,ot{Hn,epoch/10}] = train(net,it,tt);
        NET{Hn,epoch/10} = net;
        TR{Hn,epoch/10} = tr;
        ov{Hn,epoch/10} = sim(net,iv);
        ov1 = ov{Hn,epoch/10}; ov1 = ov1(:); ov1 = ov1';
        ot1 = ot{Hn,epoch/10}; ot1 = ot1(:); ot1 = ot1';
        tt1 = tt(:); tt1 = tt1';
        tv1 = tv(:); tv1 = tv1';
        RMSEtrain{Hn,epoch/10} = sqrt(mean((ot1-tt1).^2,2));
        RMSEverification{Hn,epoch/10} = sqrt(mean((ov1-tv1).^2,2));
        DCtrain{Hn,epoch/10} = 1-RMSEtrain{Hn,epoch/10}.^2./var(tt1,1,2);
        DCverification{Hn,epoch/10} = 1-RMSEverification{Hn,epoch/10}.^2./var(tv1,1,2);

    end
end      

DCtrain = cell2mat(DCtrain);
DCverification = cell2mat(DCverification);
RMSEtrain = cell2mat(RMSEtrain);
RMSEverification = cell2mat(RMSEverification);

o = 0;
[DCmaxVerification,idx_DC] = max(DCverification(:));
[hn_DC,epoch_DC] = ind2sub(size(DCverification),idx_DC);

while DCtrain(hn_DC,epoch_DC) < DCverification(hn_DC,epoch_DC)
    DCtrain(hn_DC,epoch_DC) = 0; DCverification(hn_DC,epoch_DC) = 0;
    [DCmaxVerification,idx_DC] = max(DCverification(:));
    [hn_DC,epoch_DC] = ind2sub(size(DCverification),idx_DC);
    o = o+1;
end

DCmaxTrain = DCtrain(hn_DC,epoch_DC);

RMSE_DCmaxVerification = RMSEverification(hn_DC,epoch_DC);
RMSE_DCmaxTrain = RMSEtrain(hn_DC,epoch_DC);
RMSE_VOLminVerification = RMSEverification(hn_V,epoch_V);
RMSE_VOLminTrain = RMSEtrain(hn_V,epoch_V);

Max_DC_TimeSeries_Verification=ov{hn_DC,epoch_DC};
Max_DC_TimeSeries_Verification=(Max_DC_TimeSeries_Verification(:))';

Max_DC_TimeSeries_Test=ot{hn_DC,epoch_DC};
Max_DC_TimeSeries_Test=(Max_DC_TimeSeries_Test(:))';

Max_DC_TimeSeries=[Max_DC_TimeSeries_Test Max_DC_TimeSeries_Verification];

figure;
plot(Output(:),'black')
hold on
plot(Max_DC_TimeSeries,'b--')