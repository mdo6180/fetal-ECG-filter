clear 
close all

A = load('ecgca998_edfm.mat');
[num_rows, num_columns] = size(A.val);

Thorax_total = sum(A.val(1:2,:));   %adding rows 1 and 2 together
mECG = Thorax_total.*(1/2); %finding average of the two thoracic signals
mECG = mECG.*(1000);    %convert mECG from mV to uV

ab_total = sum(A.val(3:(num_rows - 1),:));
fECG_noise = ab_total.*(1/(num_rows-3));
%fECG_noise = fECG_noise.*(.001);

%ground = A.val(7,:);
%ground = ground';

%d_T = mECG';
d_T = fECG_noise';
%noisy_sig_T = fECG_noise';
X_T = mECG';

Fs = 1000;
Ts = 1/Fs;
order = 4000;       %this is where you can adjust the order
mu = .99;            %this is where you can adjust mu (0.4 < mu < 0.99)

lms = dsp.LMSFilter(order+1, 'StepSize', mu, 'Method', 'Normalized LMS', 'WeightsOutputPort', true);

[y,e,w] = step(lms, X_T, d_T);
fECG_filtered = -e; %for some reason, the fetal heartbeat is the negative of the error signal 

%[y1,e2,w2] = step(lms,fECG_filtered,ground);
figure(1)
%plot(fECG_noise(1:2000))
%title('mECG + fECG')
plot(mECG(1:2000))
title('x(n) = mECG')
xlabel('time(ms)')
ylabel('uV')

figure(2)
%plot(mECG(1:2000))
%title('mECG')
plot(fECG_noise(1:2000))
title('d(n) = mECG + fECG')
xlabel('time(ms)')
ylabel('uV')

figure(3)
plot(y(1:2000))
%title('filtered signal (mECG)')
title('y(n)')
xlabel('time(ms)')
ylabel('uV')

figure(4)
plot(fECG_filtered(1:3000))
%plot(e2(1:2000))
title('error (fECG)')
xlabel('time(ms)')
ylabel('uV')

[qrs_amp_raw , qrs_i_raw , delay] = pan_tompkin(fECG_filtered,Fs,1);
%[qrs_amp_raw , qrs_i_raw , delay] = pan_tompkin(e2,Fs,1);
[qrs_amp_raw2 , qrs_i_raw2 , delay2] = pan_tompkin(mECG,Fs,1);

total_loc = 0;
for i = 2:length(qrs_i_raw)
    range = abs(qrs_i_raw(1,i) - qrs_i_raw(1,i-1));
    total_loc = total_loc + range;
end

total_loc2 = 0;
for i = 2:length(qrs_i_raw2)
    range2 = abs(qrs_i_raw2(1,i) - qrs_i_raw2(1,i-1));
    total_loc2 = total_loc2 + range2;
end

mean_loc = total_loc/(length(qrs_i_raw) - 1); 
mean_loc2 = total_loc2/(length(qrs_i_raw2) - 1); 
bpm_fetus = (60*1000)/mean_loc           
bpm_maternal = (60*1000)/mean_loc2