function dat_mat = diff_eq_mat(order,data,type_dat,ini_cond)
% if dat = u1; predictor;starts from previous value/ t-1, no1=0,no=1
%if dat = u; ; sim;statrs from present value/ t, no1=1,no=0
%if dat = y, no1=0,no=1
dat_mat = zeros(length(data),order);
size_data = size(data);
if size_data(2) > 1
    data = data';
end

switch type_dat
    case 'u1'
        no1 = 0;
        no = 1;
    case 'u'
        no1 = 1;
        no = 0;
    case 'y'
        no1 = 0;
        no = 1;
end

lag_dat = ini_cond.*ones(size(data));

for col = 1:order
    lag_dat(col+no:end) = data(1:end-(col-no1));
    dat_mat(:,col) = lag_dat;
    lag_dat = ini_cond.*ones(size(data));
end


end