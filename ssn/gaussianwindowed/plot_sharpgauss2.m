function [output]=plot_sharpgauss2(cell,cellname,varargin)
% PLOT_SHARPGAUSS - Plot size tuning for sharp/gaussian windowing
% 
%    Plots the raw data and fit results for the regular and MLE-smoothed
%    responses to sharp and gaussian windows.
%

prefix = {'SP F0 ', 'SP F1 '};
names = {'MLE gauss ', 'MLE sharp '};
cols = 'bg';
fft_freq = {}; fft_coeffs = {};
ssm_params = [];
fft_params = [];
ssmfit_freq = [];
ssmfit_coeffs = [];

b = ssn_simpleorcomplex(cell,cellname);
k_ = 1;
if b==1,
	k_ = 2;
end;

p_ = 1;
for k=k_
	for j=1:length(names),
		resp = findassociate(cell,[prefix{k} names{j} 'SZ Response curve'],'','');
		fitssm =  findassociate(cell,[prefix{k} names{j} 'SZ SSM Fit'],'','');
		fitdog =  findassociate(cell,[prefix{k} names{j} 'SZ DOG Fit'],'','');
		[fft_freq{k,j},fft_coeffs{k,j}] = ssn_fft(cell,cellname,[prefix{k} names{j}]);


		subplot(2,2,p_);
		h2 = myerrorbar(resp.data(1,:),resp.data(2,:),resp.data(4,:),'k-');
		delete(h2(2));
		hold on;
		plot(fitssm.data(1,:),fitssm.data(2,:),'r-');
		plot(fitdog.data(1,:),fitdog.data(2,:),'b-');

		ssmfitparamsassoc = findassociate(cell,[prefix{k} names{j} 'SZ SSM Fit Params'],'','');

		ssm_params(1,j,1) = ssmfitparamsassoc.data(7);
		ssm_params(1,j,2) = ssmfitparamsassoc.data(8);
		ssm_params(1,j,3) = ssmfitparamsassoc.data(4);

		x = 300*fitssm.data(1,:)/max(fitssm.data(1,:));
		[ssmfit_coeffs{k,j},ssmfit_freq{k,j}] = fouriercoeffs(fitssm.data(2,7:end),mean(diff(x)));

		ssm_params(1,j,2),
		f0 = findclosest(ssmfit_freq{k,j},10e-3);
		f1 = findclosest(ssmfit_freq{k,j},0.025);

		fft_params(1,j) = max(abs(ssmfit_coeffs{k,j}(f0:f1)));

		if p_==1,
			title({cellname, [' ' prefix{k} names{j}(1:end-1) ' r=' num2str(ssm_params(1,j,3)*exp(133*ssm_params(1,j,1)),2)]},'interp','none');
		else,
			title([prefix{k} names{j}(1:end-1) ' r=' num2str(ssm_params(1,j,3)*exp(133*ssm_params(1,j,1)),2)]);
		end;
		box off;
		p_ = p_ + 2;

		subplot(2,2,2);
		hold on;
		plot(fft_freq{k,j},abs(fft_coeffs{k,j}),[cols(j) 'o-']);
		if j==2, title({['gauss is blue,mn=' num2str(fft_params(1,1))], ['sharp is green,mn=' num2str(fft_params(1,2))]}); end;
		xlabel('SZSF (cycles/deg)');
		ylabel('Abs FFT');

		subplot(2,2,4);
		hold on;
		plot(ssmfit_freq{k,j},abs(ssmfit_coeffs{k,j}), [cols(j) 's--']);
	end;
end;

output = workspace2struct;
return;

 % plot the stimuli

stim_gauss = findassociate(cell,['Contrast/length gauss stimsize'],'','');
stim_sharp = findassociate(cell,['Contrast/length sharp stimsize'],'','');

max_gauss = 3*max(stim_gauss.data.thelengths);
sigma_gauss = 0.33*max_gauss/sqrt(8*log(2));

x_gauss_positions = stim_gauss.data.x_center(1) + 3*0.5*(-max_gauss:max_gauss);
x_gauss_stimstrength = exp(-( (x_gauss_positions-stim_gauss.data.x_center(1)).^2)/(2*sigma_gauss^2));
x_gauss_stimstrength(find(x_gauss_positions>800 | x_gauss_positions<0)) = 0;

y_gauss_positions = stim_gauss.data.y_center(1) + 3*0.5*(-max_gauss:max_gauss);
y_gauss_stimstrength = exp(-( (y_gauss_positions-stim_gauss.data.y_center(1)).^2)/(2*sigma_gauss^2));
y_gauss_stimstrength(find(y_gauss_positions>600 | y_gauss_positions<0)) = 0;

max_sharp = max(stim_sharp.data.thelengths);

x_sharp_positions = stim_sharp.data.x_center(1) + 0.5*(-max_sharp:max_sharp);
x_sharp_stimstrength = 1 * ones(size(x_sharp_positions));
x_sharp_stimstrength(find(x_sharp_positions<0 | x_sharp_positions>800)) = 0;

y_sharp_positions = stim_sharp.data.y_center(1) + 0.5*(-max_sharp:max_sharp);
y_sharp_stimstrength = 1 * ones(size(y_sharp_positions));
y_sharp_stimstrength(find(y_sharp_positions>600 | y_sharp_positions<0)) = 0;

subplot(2,2,4);
plot(x_gauss_positions,4+x_gauss_stimstrength,'b');
hold on;
plot(y_gauss_positions,0+y_gauss_stimstrength,'r');
plot(x_sharp_positions,2+y_sharp_stimstrength,'b');
plot(y_sharp_positions,-2+y_sharp_stimstrength,'r');

axis([-100 900 -3 5]);

ylabel('Stimulus strength');
xlabel('Position');
box off;

output = workspace2struct;
