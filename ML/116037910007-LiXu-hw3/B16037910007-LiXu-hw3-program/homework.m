
%% read data 
clear;
Data = xlsread('data/data.csv');
[total_size, features] = size(Data);
Data_D = Data(2292:3096,:);
Data_O = Data(10724:11476,:);
Data_X = Data(17694:18480,:);

[size_D,] = size(Data_D);
train_size_D = floor(size_D * 0.7);
test_size_D = size_D-train_size_D;
TrainData_D = Data_D(1:train_size_D,:);
TestData_D = Data_D(train_size_D:size_D,:);

[size_O,] = size(Data_O);
train_size_O = floor(size_O * 0.7);
test_size_O = size_O-train_size_O;
TrainData_O = Data_O(1:train_size_O,:);
TestData_O = Data_O(train_size_O:size_O,:);

[size_X,] = size(Data_X);
train_size_X = floor(size_X * 0.7);
test_size_X = size_X-train_size_X;
TrainData_X = Data_X(1:train_size_X,:);
TestData_X = Data_X(train_size_X:size_X,:);

TrainData_DO = [TrainData_D; TrainData_O];
TrainData_XO = [TrainData_X; TrainData_O];
TestData_DO = [TestData_D; TestData_O];
TestData_XO = [TestData_X; TestData_O];
%% Relief feature choose
%calculate DO
citaDO = zeros(features,1);
citaXO = zeros(features,1);
for i = 1:features
    for x = 1:train_size_D
        %find nh
        nh = 1;
        for j = union(1:x-1,x+1:train_size_D)
            if TrainData_D(x,i) == TrainData_D(j,i)
                nh = 0;
            end
        end
        citaDO(i)=citaDO(i)-nh*nh;
        nm = 1;
        for j = 1:train_size_O
            if TrainData_D(x,i) == TrainData_O(j,i)
                nm = 0;
            end
        end
        citaDO(i)=citaDO(i)+nm*nm;
    end
    
    for x = 1:train_size_O
        %find nh
        nh = 1;
        for j = union(1:x-1,x+1:train_size_O)
            if TrainData_O(x,i) == TrainData_O(j,i)
                nh = 0;
            end
        end
        citaDO(i)=citaDO(i)-nh*nh;
        nm = 1;
        for j = 1:train_size_D
            if TrainData_O(x,i) == TrainData_D(j,i)
                nm = 0;
            end
        end
        citaDO(i)=citaDO(i)+nm*nm;
    end
end

%calculate XO
for i = 1:features
    for x = 1:train_size_X
        %find nh
        nh = 1;
        for j = union(1:x-1,x+1:train_size_X)
            if TrainData_X(x,i) == TrainData_X(j,i)
                nh = 0;
            end
        end
        citaXO(i)=citaXO(i)-nh*nh;
        nm = 1;
        for j = 1:train_size_O
            if TrainData_X(x,i) == TrainData_O(j,i)
                nm = 0;
            end
        end
        citaXO(i)=citaXO(i)+nm*nm;
    end
    
    for x = 1:train_size_O
        %find nh
        nh = 1;
        for j = union(1:x-1,x+1:train_size_O)
            if TrainData_O(x,i) == TrainData_O(j,i)
                nh = 0;
            end
        end
        citaXO(i)=citaXO(i)-nh*nh;
        nm = 1;
        for j = 1:train_size_X
            if TrainData_O(x,i) == TrainData_X(j,i)
                nm = 0;
            end
        end
        citaXO(i)=citaXO(i)+nm*nm;
    end
end

%%
featureDO = [6,8,9,10,13];
featureXO = [8,9,10,11,13];
features = 5;
node = 6;

study_rate = 0.005;
cita_do = rand(1,1)/5;
yita_do = rand(1,node)/5;
w_do = rand(node,1)/5;
v_do = rand(features,node)/5;

cita_xo = rand(1,1)/5;
yita_xo = rand(1,node)/5;
w_xo = rand(node,1)/5;
v_xo = rand(features,node)/5;

times = 200; %最大迭代次数
f = @(x)1.0 ./ (1.0 + exp(-x));

%trainint D and O
for i=1:times
    for xid = 1:train_size_D+train_size_O
        x = (TrainData_DO(xid,featureDO));
        if xid <= train_size_D
            y = 0;
        else
            y = 1;
        end
        output1 = f(x*v_do-yita_do);
        yhat = f(output1*w_do-cita_do);
        g = yhat*(1-yhat)*(y-yhat);
        e = output1.*(1-output1)*sum(w_do.*g);
        delta_w = study_rate*g.*output1';
        w_do = w_do+delta_w;
        delta_cita = -study_rate*g;
        cita_do = cita_do +delta_cita;
        delta_v = study_rate*(x'*e);
        v_do = v_do+delta_v;
        delta_yita = -study_rate*e;
        yita_do = yita_do+delta_yita;
        if(sum(abs(delta_w)<0.0001)==node)
            break;
        end
    end
end

%trainint X and O
for i=1:times
    for xid = 1:train_size_X+train_size_O
        x = (TrainData_XO(xid,featureXO));
        if xid <= train_size_X
            y = 0;
        else
            y = 1;
        end
        output1 = f(x*v_xo-yita_xo);
        yhat = f(output1*w_xo-cita_xo);
        g = yhat*(1-yhat)*(y-yhat);
        e = output1.*(1-output1)*sum(w_xo.*g);
        delta_w = study_rate*g.*output1';
        w_xo = w_xo+delta_w;
        delta_cita = -study_rate*g;
        cita_xo = cita_xo +delta_cita;
        delta_v = study_rate*(x'*e);
        v_xo = v_xo+delta_v;
        delta_yita = -study_rate*e;
        yita_xo = yita_xo+delta_yita;
        if(sum(abs(delta_w)<0.0001)==node)
            break;
        end
    end
end

%% test D and O
count = 0;
for xid = 1:test_size_D+test_size_O
    x = (TestData_DO(xid,featureDO));
    if xid <= test_size_D
        y = 0;
    else
        y = 1;
    end
    output1 = f(x*v_do-yita_do);
    yhat = f(output1*w_do-cita_do);
    if(yhat>0.5)
        yhat = 1;
    else
        yhat = 0;
    end
    if(yhat == y)
        count = count+1;
    end
end
rate = count/(test_size_D(1)+test_size_O(1));
disp('accuracy rate between D and O:');
disp(rate);

%% test X and O
count = 0;
for xid = 1:test_size_X+test_size_O
    x = (TestData_XO(xid,featureXO));
    if xid <= test_size_X
        y = 0;
    else
        y = 1;
    end
    output1 = f(x*v_do-yita_do);
    yhat = f(output1*w_do-cita_do);
    if(yhat>0.5)
        yhat = 1;
    else
        yhat = 0;
    end
    if(yhat == y)
        count = count+1;
    end
end
rate = count/(test_size_X(1)+test_size_O(1));
disp('accuracy rate between X and O:');
disp(rate);

