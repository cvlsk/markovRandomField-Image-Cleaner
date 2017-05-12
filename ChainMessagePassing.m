% Demo for chain-based message passing
% Boston Univeristy
% For the students in CS 542 Machine Learning

%-----------------------------------------------------------------------------------------
% 0. Set the parameter numbers
%-----------------------------------------------------------------------------------------
% the number of nodes
N = 10;

% the number of states
K = 36;

% the coefficients for data term
lambda_data = 0.04;

% the coefficients for the smoothness term
lambda_smooth= 0.04;

% the potential function
mPotentialFunc = 'L1';

%-----------------------------------------------------------------------------------------
% 1. Setup the potential function
%-----------------------------------------------------------------------------------------
% data is the observed random value
if exist('data','var')~=1
    y = [repmat(6,[1,N/2]), repmat(30,[1,N/2])];
    data = y + randn(1,N)*2;
end

% define uniary potentials
switch mPotentialFunc
    case 'L2'
        P = -lambda_data * (repmat(data,[K,1]) - repmat((1:K)',[1,N])).^2;
    case 'L1'
        P = -lambda_data * abs(repmat(data,[K,1]) - repmat((1:K)',[1,N]));
end

foo = repmat(1:K,[K,1]);
Dist = abs(foo - foo');
% define pair-wise potentials
for i = 1:N-1
    switch mPotentialFunc
        case 'L2'
            Psi{i} = -lambda_smooth*Dist.^2;
        case 'L1'
            Psi{i} = -lambda_smooth*Dist;
    end
    %Psi{i} = -lambda_smooth*min(abs(foo-foo'),10);
end

% compose the potentials
for i = 1:N-1
    Psi{i} = repmat(P(:,i),[1,K]) + Psi{i};
end
Psi{N-1} = repmat(P(:,N)',[K, 1]) + Psi{N-1};

%-----------------------------------------------------------------------------------------
% 2. Message passing
%-----------------------------------------------------------------------------------------
% forward and backward messages
fm = cell(1,N-1);
bm = cell(1,N-1);
for i = 1:N
    fm{i} = zeros(1,K);
    bm{i} = zeros(1,K)';
end

% energy
fm{1} = log(sum(exp(Psi{1}),1));
bm{N} = log(sum(exp(Psi{N-1}),2));

fm0 = fm;
bm0 = bm;
% loop; for a chain 1 time is ok, but multiple times are requires for a loopy graph
for k = 1:1
    % forward message passing
    for i = 2:N-1
        fm{i} = log(sum(exp(repmat(fm0{i-1}',[1,K]) + Psi{i}),1));
        fm{i} = fm{i} - min(fm{i});
    end
    % backward message passing
    for i = N-1:-1:2
        bm{i} = log(sum(exp(repmat(bm0{i+1}',[K,1]) + Psi{i-1}),2));
        bm{i} = bm{i} - min(bm{i});
    end
    fm0 = fm;
    bm0 = bm;
end

%-----------------------------------------------------------------------------------------
% 3. Compute marginals
%-----------------------------------------------------------------------------------------
marginal = cell(1,N);
for i = 1:N
    marginal{i} = zeros(1,K);
end
for i = 1:N
    if i >1
        marginal{i} = marginal{i} + fm{i-1};
    end
    if i<N
        marginal{i} = marginal{i} + bm{i+1}';
    end
    marginal{i} = exp(marginal{i} - min(marginal{i}));
    % normalize the marginal
    marginal{i} = marginal{i}/sum(marginal{i});
end

Marginals = zeros(K,N);
DataOnly = zeros(K,N);
for i = 1:N
    Marginals(:,i) = marginal{i}';
    DataOnly(:,i) = exp(P(:,i));
    DataOnly(:,i) = DataOnly(:,i) / sum(DataOnly(:,i));
end

%-----------------------------------------------------------------------------------------
% 4. Output results
%-----------------------------------------------------------------------------------------
subfolder = 'pdf0';
if exist(subfolder,'dir')~=7
    mkdir(subfolder);
end
% save histogram
% for i = 1:N
%     saveHHistogram(fullfile(subfolder,['initial_' num2str(i) '.pdf']),DataOnly(:,i),'b');
%     saveHHistogram(fullfile(subfolder,['marginal_' num2str(i) '.pdf']),Marginals(:,i),'r');
% end

% get the expectation of each point
for i = 1:N
    % expectation
    % idx(i) = sum((1:K).*marginal{i});
    % maximum
    [~,idx(i)] = max(marginal{i});
end
figure;plot(y,'g--','LineWidth',2);hold on;plot(data,'b-o','LineWidth',2);plot(idx,'r-d','LineWidth',2);
set(gca,'FontSize',20,'LineWidth',2);
xlim([1,N]);
ylim([1,K]);
legend('Ground truth','Observed','Estimated','Location','SouthEast');
saveTightFigure(gcf,fullfile(subfolder,'Denoising.pdf'));
