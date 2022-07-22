%function DAS = DAS()
    spectra = evalin('base','spectra');
    spectrafigure = uifigure;
    spectrafigure.Color = 'w';
    %spectrafigure.Position(3:4) = [430 320];
    spectrafigure.Position(3:4) = [1200 1000];
    names = {};
    index = [1:length(spectra)];
    for i = 1:length(spectra)
        names{i} = spectra(i).name;
    end
    %ax = uiaxes('Parent',spectrafigure,'Position',[10 10 300 300],'XLim', [2700 3200]);
    ax = uiaxes('Parent',spectrafigure,'Position',[10 10 990 990],'XLim', [2700 3200]);
    tempSpectrum = (spectra(1).data);
    minimumValue = min(spectra(1).data);
    if spectra(1).data(1) >= 1
        tempSpectrum = (spectra(1).data);
        tempSpectrum = (tempSpectrum ./ tempSpectrum(1)) - 1;
    else
        tempSpectrum = spectra(1).data - minimumValue;
    end
    tempSpectrum = medfilt1(tempSpectrum,3);
    [tempMax,tempMaxEl] = max(tempSpectrum);
    fitOutput = struct([]);
    p = plot(ax, spectra(1).wavenumber, tempSpectrum);
    
    ax.XLabel.String = 'IR Wavenumber / cm^{-1}';
    ax.YLabel.String = 'Intensity / Arb. Units';
    ax.Box = 'on';
    ax.XGrid = 'on';
    ax.YGrid = 'on';
    ax.LineWidth = 1;
    p.Color = 'black';
    p.LineWidth = 1;
    spectrafigure.Name = strcat(num2str(1), " - ", spectra(1).name);
    fakeNR = zeros(1,numel(tempSpectrum));
    %dropdown = uidropdown(spectrafigure,'Items',names,'ItemsData',index,'ValueChangedFcn',@(dropdown,event) selection(dropdown,p,ax,spectrafigure,sldNRWL), 'Position', [1000 960 200 20]);
    dropdown = uidropdown(spectrafigure,'Items',names,'ItemsData',index,'Position', [1000 960 200 20]);
    
    peakWL = uieditfield(spectrafigure,'text','Position',[1000 940 200 20],'Value','2851 2878 2915 2934 2967');
    phaseSelectGroup = uibuttongroup(spectrafigure,'Position',[1000 840 200 100],'BackgroundColor','w');
    buttonPhi0 = uiradiobutton(phaseSelectGroup,'Position',[10 80 200 20],'Text','ϕ = 0');
    buttonPhiPiby2 = uiradiobutton(phaseSelectGroup,'Position',[10 60 200 20],'Text','ϕ = π/2');
    buttonPhiPi = uiradiobutton(phaseSelectGroup,'Position',[10 40 200 20],'Text','ϕ = π','Value',1);
    buttonPhi3Piby4 = uiradiobutton(phaseSelectGroup,'Position',[10 20 200 20],'Text','ϕ = 3π/4');
    sldNRWL = uislider(spectrafigure,'Position',[1025 800 150 3],'Limits',[spectra(1).wavenumber(tempMaxEl-150) spectra(1).wavenumber(tempMaxEl+150)],'Value',spectra(1).wavenumber(tempMaxEl));
    sldNRWidth = uislider(spectrafigure,'Position',[1025 760 150 3],'Limits',[0 250],'Value',135);
    sldNRAmp = uislider(spectrafigure,'Position',[1025 720 150 3],'Limits',[0 tempMax*2],'Value',tempMax);



    
    dropdown.ValueChangedFcn = @(dropdown,event) selection(dropdown,p,ax,spectrafigure,sldNRWL,sldNRWidth,sldNRAmp);
    sldNRWL.ValueChangedFcn = @(sldNRWL,event) updateNR(sldNRWL,sldNRWidth,sldNRAmp,fakeNR,dropdown,p,ax,spectrafigure);
    sldNRWidth.ValueChangedFcn = @(sldNRWidth,event) updateNR(sldNRWL,sldNRWidth,sldNRAmp,fakeNR,dropdown,p,ax,spectrafigure);
    sldNRAmp.ValueChangedFcn = @(sldNRAmp,event) updateNR(sldNRWL,sldNRWidth,sldNRAmp,fakeNR,dropdown,p,ax,spectrafigure);
    buttonCH = uibutton(spectrafigure,'push','Position',[1000 650 200 20],'Text','CH','ButtonPushedFcn',@(buttonCH,event) addCH(peakWL));
    buttonFit = uibutton(spectrafigure,'push','Position', [1000 630 200 20], 'ButtonPushedFcn',@(buttonFit,event) fitCurrent(buttonFit,dropdown,peakWL.Value,phaseSelectGroup.SelectedObject.Text,sldNRWL,sldNRWidth,sldNRAmp,fitOutput),'Text','Fit');
    
    
    %end

function selection(dropdown,p,ax,spectrafigure,sldNRWL,sldNRWidth,sldNRAmp)
    selectedvalue = get(dropdown, 'Value');
    spectra = evalin('base','spectra');
    
    
    minimumValue = min(spectra(dropdown.Value).data);
    if spectra(dropdown.Value).data(1) >= 1
        tempSpectrum = (spectra(dropdown.Value).data);
        tempSpectrum = (tempSpectrum ./ tempSpectrum(1)) - 1;
    else
        tempSpectrum = spectra(dropdown.Value).data - minimumValue;
    end
    tempSpectrum = medfilt1(tempSpectrum,3);
    [tempMax,tempMaxEl] = max(tempSpectrum);


    sldNRWL.Limits = [spectra(dropdown.Value).wavenumber(tempMaxEl-150) spectra(dropdown.Value).wavenumber(tempMaxEl+150)];
    sldNRWL.Value = spectra(dropdown.Value).wavenumber(tempMaxEl);

    
    sldNRAmp.Limits = [0 tempMax * 2];
    sldNRAmp.Value = tempMax;
    p = plot(ax,spectra(dropdown.Value).wavenumber,tempSpectrum);
    p.Color = 'black';
    p.LineWidth = 1;
    spectrafigure.Name = strcat(num2str(dropdown.Value)," - ",spectra(dropdown.Value).name);
end

function updateNR(sldNRWL, sldNRWidth, sldNRAmp,fakeNR,dropdown,p,ax,spectrafigure)
    selectedvalue = get(dropdown, 'Value');
    spectra = evalin('base','spectra');


    minimumValue = min(spectra(dropdown.Value).data);
    if spectra(dropdown.Value).data(1) >= 1
        tempSpectrum = (spectra(dropdown.Value).data);
        tempSpectrum = (tempSpectrum ./ tempSpectrum(1)) - 1;
    else
        tempSpectrum = spectra(dropdown.Value).data - minimumValue;
    end
    
    for it=1:length(fakeNR)
        fakeNR(it) = abs(sldNRAmp.Value * exp(-((spectra(dropdown.Value).wavenumber(it) - sldNRWL.Value)/sldNRWidth.Value)^2));
    end

    p = plot(ax,spectra(dropdown.Value).wavenumber,tempSpectrum,spectra(dropdown.Value).wavenumber,fakeNR);
    p(1).Color = 'black';
    p(1).LineWidth = 1;
    spectrafigure.Name = strcat(num2str(dropdown.Value)," - ",spectra(dropdown.Value).name);

end


function fitCurrent = fitCurrent(buttonFit,dropdown,peakWL,phaseText,NRWL,NRWidth,NRAmp,fitOutput)
    spectra = evalin('base','spectra');
    guesses = sscanf(peakWL,'%f');
    numberOfPeaks = length(guesses);
    phase = 0;
    if strcmp(phaseText,'ϕ = 0')
        phase = 0;
    elseif strcmp(phaseText,'ϕ = π/2')
        phase = pi / 2;
    elseif strcmp(phaseText,'ϕ = π')
        phase = pi;
    elseif strcmp(phaseText,'ϕ = 3π/4')
        phase = 3 * pi / 4;
    end
  %  figure
    plotTitle = sprintf('%s - fitted with %d peaks (%s)',spectra(dropdown.Value).name(1:end-4),round(abs(numberOfPeaks)),phaseText);
    
    
    figure('Name',spectra(dropdown.Value).name,'Color','w','Renderer','painters','Position',[10 10 1000 1000])
    title(plotTitle)
    minimumValue = min(spectra(dropdown.Value).data);
    if spectra(dropdown.Value).data(1) >= 1
        tempSpectrum = (spectra(dropdown.Value).data);
        tempSpectrum = (tempSpectrum ./ tempSpectrum(1)) - 1;
    else
        tempSpectrum = spectra(dropdown.Value).data - minimumValue;
    end
    %persistent peakFitResults;
    peakFitResults = fitSFGFull(spectra(dropdown.Value).wavenumber,tempSpectrum,guesses,phase,NRWL.Value,NRWidth.Value,NRAmp.Value);
    fitOutput = [peakFitResults, fitOutput];
    %result = sprintf('Fitted %d',dropdown.Value)
end

function addCH(peakWL)
   peakWL.Value = '2851 2878 2915 2934 2967';
end
