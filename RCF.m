function [scBL, fInty] = RCF(data, xmin, xmax)
	%% radius of the circle is 130 1/cm
	%% parameter of Savitzky-Colay filter 3 order, 81 number of side points
	%% James, T. M., Schlösser, M., Lewis, R. J., Fischer, S., Bornschein, B., and Telle, H. H. (2013). Automated
	%%quantitative spectroscopic analysis combining background subtraction, cosmic ray removal, and peak
	%%fitting. Applied spectroscopy, 67(8):949–959.

	%data = load('Raman_test.dat');
	X = data(:,1);
	Inty = data(:,2);

	if(max(X) < xmin | min(X) > xmax)
		msgbox('Data out of range!','Error','error');
    	return;
	end
	if(xmax < xmin)
		return;
	end

	sInty = smooth(Inty, 5);

	n = length(Inty);
	A = sInty';

	% initialize the baseline
	BL = A;

	% define a semi-circle
	R = 130;
	for j = 1:(2*R+1)
	     RC(j) = sqrt(R.^2 - ((j-1)-R).^2) - R;
	end
	% various conditions to subsets of the circle and input
	for i = 1:n
		if i < R+1
			A_sub = A(1:i+R+1);
			RC_sub = RC(R-i+1:2*R+1);
		elseif i >= R+1 & i <= n-R
			A_sub = A((i-R):(i+R));
			RC_sub = RC;
		else
			A_sub = A(i-R : n);
			RC_sub = RC(1:(R+n-i+1));
		end
		BL(i) = min(A_sub - RC_sub);
	end

	scBL = sgolayfilt(BL, 3, 81);
	% f = plot(X, Inty, 'LineWidth', 1.5);
	% hold on
	% f = plot(X, scBL, 'LineWidth', 1.5);
	% hold off

	fInty = A - scBL;
	fInty = fInty';
	%figure; plot(X, fInty)

	% axis tight;
	% xlim([xmin xmax])
 %  	xlabel('Raman Shift (1/cm)', 'FontSize', 11);
 %  	ylabel('Intensity (cps)', 'FontSize', 11);
 %  	set(gca, 'xminortick', 'on');
 %  	grid on;

end