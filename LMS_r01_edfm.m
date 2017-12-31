clear 

close all

A = load('r08_edfm.mat');  
B = load('r08_edfm.mat');
d = A.val(1,:);
d_T = d';
input_channel = 3;  % this is where you change the input channel
noisy_sig = B.val(input_channel,:);
noisy_sig_T = noisy_sig';

Fs = 1000;
Ts = 1/Fs;
order = 4000;       %this is where you can adjust the order
mu = 0.99;            %this is where you can adjust mu (0.4 < mu < 0.99)

lms = dsp.LMSFilter(order + 1, 'StepSize', mu, 'Method', 'Normalized LMS', 'WeightsOutputPort', true);
[mu_max, mu_min] = maxstep(lms, noisy_sig)
[y,e,w] = step(lms, noisy_sig_T, d_T);

figure(1)
plot(noisy_sig(1:2000))
title('noisy signal')
xlabel('time(ms)')
ylabel('Voltage(microvolts)')

figure(2)
plot(d(1:2000))
title('desired output')
xlabel('time(ms)')
ylabel('Voltage(microvolts)')

figure(3)
plot(y(1:2000))
title('filtered signal')
xlabel('time(ms)')
ylabel('Voltage(microvolts)')

figure(4)
plot(e(1:2000))
title('error')
xlabel('time(ms)')
ylabel('Voltage(microvolts)')

[qrs_amp_raw , qrs_i_raw , delay] = pan_tompkin(y,Fs,1);
[qrs_amp_raw2 , qrs_i_raw2 , delay2] = pan_tompkin(d,Fs,1);

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
bpm_abdomen = (60*1000)/mean_loc           
bpm_direct = (60*1000)/mean_loc2