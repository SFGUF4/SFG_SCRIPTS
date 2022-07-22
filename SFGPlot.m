function SFGPlot = SFGPlot(varargin)
    
    spectra = evalin('base','spectraNormalisedtoHeight');
    figureName = spectra(varargin{1}).name;
    figure('Name',figureName,'Color','w','Renderer','painters','Position',[10 10 1000 1000])
    %figure('Renderer','painters','Position',[10 10 1000 1000])
    numberOfSpectra = nargin;
    if(ischar(varargin{nargin}) == 1)
        numberOfSpectra = nargin - 1;
        if(varargin{nargin} == "R")
            displayMessage = sprintf('Displaying %d raw spectra', numberOfSpectra);
            disp(displayMessage);
            spectra = evalin('base','spectra');
            ylabel('Raw SFG Intensity / Counts');
        elseif(varargin{nargin} == "B")
            displayMessage = sprintf('Displaying %d spectra normalised to background', numberOfSpectra);
            disp(displayMessage);
            spectra = evalin('base','spectraNormalisedtoBG');
            ylabel('BG Normalised SFG Intensity / A.U.');
        else
            displayMessage = sprintf('Displaying %d spectra normalised to height', numberOfSpectra);
            ylabel('Normalised SFG Intensity / Counts');
            disp(displayMessage);
        end
    else
            displayMessage = sprintf('Displaying %d spectra normalised to height', numberOfSpectra);
            ylabel('Normalised SFG Intensity / Counts');
            disp(displayMessage);
    end
    colours = hsv(numberOfSpectra);
    grid on;
    hold on;
    spectraToExport = evalin('base','spectraToExport');
    
    for i = 1:numberOfSpectra
        spectrum = varargin{i};
        legendName = strcat('(',num2str(spectrum),') - ', spectra(spectrum).name);
        plot(spectra(spectrum).wavenumber,spectra(spectrum).data,'Color',colours(i,:),'DisplayName',legendName,LineWidth=1.5)
        spectraToExport(:,2*i - 1) = spectra(spectrum).wavenumber;
        spectraToExport(:,2*i) = spectra(spectrum).data;
    end
    hold off;
    if(nargin>1)
        legend
    end
    %ylim([0 1])
    xlim([2700 3200])
    ax = gca;
    ax.LineWidth = 1;
    ax.FontSize = 12;
    box on;
    xlabel('IR Wavenumber / cm^{-1}');
    SFGPlot = spectraToExport;
end

