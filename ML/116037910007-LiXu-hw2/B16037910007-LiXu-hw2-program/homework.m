
%% read data 
clear;
M = xlsread('data/train.csv');
N = xlsread('data/test.csv');

%%
Y = M(:,58);
index_c1 = find(Y==0);
index_c2 = find(Y==1);
Y_c1 = length(index_c1);
Y_c2 = length(index_c2);
total_count = Y_c1+Y_c2;
part_c1 = M(index_c1,:);
part_c2 = M(index_c2,:);

mu_c1 = sum(part_c1)/Y_c1;
mu_c2 = sum(part_c2)/Y_c2;

cita_c1 = zeros(1,58);
cita_c2 = zeros(1,58);
for i=1:Y_c1
    linei = part_c1(i)-mu_c1;
    for j=1:57
        cita_c1(j)=cita_c1(j)+ linei(j)*linei(j);
    end
end
cita_c1 = cita_c1/(Y_c1-1);
for i=1:Y_c2
    linei = part_c2(i)-mu_c2;
    for j=1:57
        cita_c2(j)=cita_c2(j)+ linei(j)*linei(j);
    end
end
cita_c2 = cita_c2/(Y_c2-1);

%%
[test_case,col] = size(N);
right_count = 0;
res = zeros(test_case,1);
for i=1:test_case
    rate1 = Y_c1/total_count;
    rate2 = Y_c2/total_count;
    for j = 1:57
        rate1 = rate1*exp(-power((N(i,j)-mu_c1(j)),2)/(2*cita_c1(j)))/sqrt(2*pi*cita_c1(j));
        rate2 = rate2*exp(-power((N(i,j)-mu_c2(j)),2)/(2*cita_c2(j)))/sqrt(2*pi*cita_c2(j));
    end
    if rate1>rate2
        res(i) = 0;
        if N(i,58)==0
            right_count = right_count+1;
        end
    else
        res(i) = 1;
        if N(i,58)==1
            right_count = right_count+1;
        end
    end
end
accuracy = right_count/test_case;
fprintf('Accuracy: %f\n',accuracy);
