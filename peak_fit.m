
%% Matlab in Chemical Engineering at CMU
%% permaLink = http://matlab.cheme.cmu.edu/2012/06/22/curve-fitting-to-get-overlapping-peak-areas/;

function [xp, peak, pars] = peak_fit(data, xmin, xmax, parguess)

    x = data(:,1);
    intensity = data(:,2);
    ind = find(intensity < 0);
    intensity(ind) = 0;

    ind_min = find(x >=xmin, 1);
    ind_max = find(x <=xmax, 1, 'last');

    xp = x(ind_min:ind_max);
    yp = intensity(ind_min:ind_max);

    % fit with non-linear fitting
    pars = nlinfit(xp, yp, @one_peak, parguess);
    peak = one_peak(pars, xp);


    function f = one_peak(pars,x)
       
        x0 = pars(1);  % peak position
        r = pars(2);  % FWHM 
        I = pars(3);
        f = I*r.^2./((r.^2 + (x-x0).^2)); % wikipedia Cauchy distribution

    end

end
