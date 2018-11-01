
%% read data 
clear;
M = xlsread('data/train.csv');
price = M(:,3);
sqft_living = M(:,6);
[m, n] = size(price);
X = [ones(m,1),sqft_living];
Y = price;

%% Stochastic Gradient Descent Training
alpha = 0.000000005;
cita_sg = ones(n+1,1);
for i=1 : m
    y = X(i,:) * cita_sg;
    for j=1:n+1
        cita_sg(j) = cita_sg(j) + alpha * (Y(i) - y) * X(i,j);
    end
end

%% Batch Gradient Descent Training
alpha = 0.000000005;
cita_bg = ones(n+1,1);
old_cita = zeros(n+1,1);
index = 1;
batch = 10;

while true
    for j=1:n+1
        delta = 0;
        for k=1:batch
            if index == m + 1
                index = 1;
            end
            y = X(index,:) * cita_bg;
            delta = delta + (Y(index) - y) * X(index,j);
            index = index+1;
        end
        cita_bg(j) = cita_bg(j) + alpha * delta;
    end
    
    % ≈–∂œ «∑Ò ’¡≤
    if((old_cita(1)-cita_bg(1))^2 < 0.00001 && (old_cita(2)-cita_bg(2))^2 < 0.00001)
        break;
    end
    old_cita = cita_bg;
end

%% Newton°Øs method Training
cita_n = zeros(n+1, 1);
g = inline('1.0 ./ (1.0 + exp(-z))'); 

MAX_ITR = 7;
J = zeros(MAX_ITR, 1);

for i = 1:MAX_ITR
    z = X * cita_n;
    h = g(z);
    grad = (1/m).*X' * (h-Y);
    H = (1/m).*X' * diag(h) * diag(1-h) * X;

    J(i) =(1/m)*sum(-Y.*log(h) - (1-Y).*log(1-h));
    
    cita_n = cita_n - (pinv(H)*grad);
end

%% Normal Equation Training
cita_normal = ((X' * X)^-1) * X' * Y;



%% draw plot
figure;
plot(sqft_living,price,'.');
ylabel('price');
xlabel('sqft_living');
hold on;

plot(sqft_living, X*cita_bg);
hold on;

plot(sqft_living, X*cita_sg);
hold on;

plot(sqft_living, X*cita_normal);
hold on;

plot(sqft_living, X*cita_n);
hold on;

legend('Training data','Batched Gradient Descent','Stochastic Gradient ', 'Normal Equation','Newton method')
hold off;

%% draw train figure
Data_test = xlsread('data/test.csv');
price_real = Data_test(:,3);
sqft_test = Data_test(:,6);
[test_m, test_n] = size(sqft_test);

price_predict_sg = [ones(test_m, 1) sqft_test]*cita_sg;
RMSE_gradient_s = sqrt((1/test_m).* (price_predict_sg - price_real)' * (price_predict_sg - price_real));
disp(RMSE_gradient_s);

price_predict_bg = [ones(test_m, 1) sqft_test]*cita_bg;
RMSE_gradient = sqrt((1/test_m).* (price_predict_bg - price_real)' * (price_predict_bg - price_real));
disp(RMSE_gradient);

price_predict_normal = [ones(test_m, 1) sqft_test]*cita_normal;
RMSE_normal = sqrt((1/test_m).* (price_predict_normal - price_real)' * (price_predict_normal - price_real));
disp(RMSE_normal)

price_predict_newton = [ones(test_m, 1) sqft_test]*cita_n;
RMSE_newton = sqrt((1/test_m).* (price_predict_newton - price_real)' * (price_predict_newton - price_real));
disp(RMSE_newton)