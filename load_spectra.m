[spectraToLoad,path] = uigetfile('*.asc','MultiSelect','On');
if exist('spectra','var') == 0
    sprintf('No spectra array exists, creating one, one sec...')
    spectra = struct([]);
    spectraNormalisedtoBG = struct([]);
    spectraNormalisedtoHeight = struct([]);
end
firstNewIndex = length(spectra) + 1;
for i = 1:length(spectraToLoad)
    tempSpec = importdata(strcat(path,spectraToLoad{i}));
    spectrum = struct('wavenumber',tempSpec(:,1),'data',tempSpec(:,2),'name',spectraToLoad(i));
    spectrumNormalisedtoBG = struct('wavenumber',tempSpec(:,1),'data',(tempSpec(:,2)/tempSpec(1,2) - 1),'scaledBy',tempSpec(1,2)-1,'name',spectraToLoad(i));
    [maxHeight,maxEl] = max(tempSpec(:,2));
    tempSpecNormHeight = (tempSpec(:,2) - tempSpec(1,2))/maxHeight;
    spectrumNormalisedtoHeight = struct('wavenumber',tempSpec(:,1),'data',tempSpecNormHeight,'scaledBy',maxHeight,'name',spectraToLoad(i));
    spectra = [spectra, spectrum];
    spectraNormalisedtoBG = [spectraNormalisedtoBG, spectrumNormalisedtoBG];
    spectraNormalisedtoHeight = [spectraNormalisedtoHeight, spectrumNormalisedtoHeight];
end
clear spectraToLoad path;
lastNewIndex = length(spectra) + 1;
sprintf('Added %d new spectra',lastNewIndex - firstNewIndex)
for i = firstNewIndex:lastNewIndex - 1
    hold on;
    plot(spectraNormalisedtoHeight(i).wavenumber,spectraNormalisedtoHeight(i).data + i,'DisplayName',strcat(spectraNormalisedtoHeight(i).name, ' /', num2str(spectraNormalisedtoHeight(i).scaledBy)),LineWidth=2)
    legend
end
spectraToExport = zeros(length(spectraNormalisedtoHeight(1).wavenumber),0);
