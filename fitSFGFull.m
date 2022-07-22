function fitSFGFull = fitSFGFull(x,y,Guesses,phase,NRWL,NRWidth,NRAmp)
    numberOfPeaks = numel(Guesses);
    clear fitFunc;
    centralIR = 3000;
    fitFunc = 'abs(A*exp(-((x-B)/C)^2)';

    %fitFunc = sprintf('abs(A*exp(-((x-B)/C)^2)*(exp(1i*%f)',phase);
    
    %Remove spikes
    y = medfilt1(y,3);

    [maximum,element] = max(y);
    guessIRCentral = x(element);
    

    
    
    for it=1:numberOfPeaks
       peakString = sprintf('+ exp(1i*%f) * (I%d/(x-k%d-w%d*i))',phase,it,it,it);

       % peakString = sprintf('+ (I%d/(-x+k%d-w%d*i)  )   ',it,it,it);
        fitFunc = strcat(fitFunc,peakString);
    end
    


    fitFunc = strcat(fitFunc,')^2');
    
    %fitFunc = strcat(fitFunc,'))^2');

    fitFuncType = fittype(fitFunc);
    options = fitoptions(fitFuncType);
    options.lower(1) = sqrt(NRAmp) * 0.2;
    options.upper(1) = sqrt(NRAmp) * 1.2;

    options.StartPoint(1) = sqrt(NRAmp);
    options.lower(2) = NRWL-20;%guessIRCentral - 100;
    options.upper(2) = NRWL+20;%guessIRCentral + 100;
    options.StartPoint(2) = NRWL;%guessIRCentral;
    options.lower(3) = sqrt(2)*(NRWidth)-5;
    options.upper(3) = sqrt(2)*(NRWidth)+5;
    options.StartPoint(3) = sqrt(NRWidth);
    
    for it=1:numberOfPeaks
        intensity = 3 + it;
        wavelength = 3 + it + numberOfPeaks;
        width = 3 + it + numberOfPeaks * 2;
        options.lower(intensity) = 0;
        options.lower(wavelength) = Guesses(it) - 10;
        options.lower(width) = 2;
        options.upper(intensity) = inf;%10*maximum^2;
        options.upper(wavelength) = Guesses(it) + 10;
        options.upper(width) = 50;
        options.StartPoint(intensity) = maximum;
        options.StartPoint(wavelength) = Guesses(it) - 5 + rand() * 10;
        options.StartPoint(width) = 5;
    end
    
    resultFit = fit(x,y,fitFunc,options)
    
    
    % Extract just the peaks
    coefficients = coeffvalues(resultFit);
    
    wavelengths = zeros(numberOfPeaks,1);
    intensities = zeros(numberOfPeaks,1);
    widths = zeros(numberOfPeaks,1);
    
    fittedPeaks = struct([]);
    
    for it=1:numberOfPeaks
        intensities(it) = coefficients(3 + it);
        wavelengths(it) = coefficients(3 + it + numberOfPeaks);
        widths(it) = coefficients(3 + it + numberOfPeaks * 2);
        
        fittedPeak = zeros(length(x),1);
        
        for jt=1:length(x)
            fittedPeak(jt) = abs((intensities(it)/(x(jt) - wavelengths(it) - 1i*widths(it))))^2;
        end
        fitSim = struct('Wavenumber',x,'Data',fittedPeak,'Intensity',intensities(it),'Frequency',wavelengths(it),'Width',widths(it));
        fittedPeaks = [fittedPeaks,fitSim];
    end
    if numberOfPeaks > 1        % Only bother sorting if there's multiple peaks
        peakTable = struct2table(fittedPeaks);
        peakTable = sortrows(peakTable,'Frequency');    
        fittedPeaks = table2struct(peakTable);
    end

    for it=1:length(x)
        backgroundNR(it) = abs(resultFit.A * exp(-((x(it) - resultFit.B)/resultFit.C)^2))^2;
    end
    % End extract
    
    hold on;
    plotOutput = plot(resultFit,x,y);
    plotOutput(2).LineWidth = 1;
    plotOutput(2).LineStyle = "-";
    plotOutput(1).MarkerEdgeColor = 'black';
    plotOutput(1).MarkerFaceColor = 'black';

    area(x,backgroundNR,'FaceColor','black','FaceAlpha',0.1,'LineStyle','none');
    xlim([resultFit.B-200,resultFit.B+200 ])
    legendText = {'Data'};
    legendText{2} = 'Fit';
    legendText{3} = 'NR Background';
    colours = hsv(numberOfPeaks);
    for it=1:numberOfPeaks
        a = area(fittedPeaks(it).Wavenumber,(7/10)*maximum*fittedPeaks(it).Data/max(max([fittedPeaks.Data])),'FaceColor',colours(it,:),'LineWidth',1,'EdgeColor',colours(it,:));
        a.FaceAlpha = 0.25;
        legendText{it+3} = sprintf('I = %2.2f, k = %d (%d) cm^{-1}', round(fittedPeaks(it).Intensity,2),round(fittedPeaks(it).Frequency),round(fittedPeaks(it).Width));
        legend(legendText)
    end
    ax = gca;
    
    ax.LineWidth = 1;
    ax.FontSize = 12;
    box on;
    xlabel('IR Wavenumber / cm^{-1}');
    hold off;
    fitSFGFull = fittedPeaks;
end
