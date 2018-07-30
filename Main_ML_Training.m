function [weightVectors,miniweightVectors] = ...
    Main_ML_Training(imageTune,noOfImages,weightVectors,miniweightVectors)
%%
% Main ML Training func
WindAngle=imageTune.FlowAngle;
%%
for img=1:noOfImages %for each frame
    %% tune the image and segment it
    %devide into frames and read them
    I = read(imageTune.OriginalVideo, ...
        round(rand(1)*imageTune.OriginalVideo.NumberOfFrames));%read random frame
   %make the frame B&W, crop and mask
    I=rgb2gray(I);
    I(imageTune.Mask)=256;
    I = imcrop(I, imageTune.CropFrame);
    %tune the frame by the parameters difined by the user
    I(:,:,:)=I(:,:,:)*(50^log((imageTune.BrightnessKnob.Value+0.5)));
    try
        I= locallapfilt(I, imageTune.SigmaKnob.Value, imageTune.AlphaKnob.Value);
    end
    I = imadjust(I,[imageTune.LowInSlider.Value imageTune.HighInSlider.Value],[],...
        imageTune.GammaKnob.Value);
    I=imsharpen(I,'Radius',imageTune.RadiusSlider.Value,...
        'Amount',imageTune.SharpnessstrengthKnob.Value,...
        'Threshold',imageTune.ThresholdSlider.Value);
    %segment the frame
    [bw,labeled] = matlab_seg(I,imageTune);
    
    %% Create the training set
    % create the traing set
    [tuftSet,tuftLabel,Orientation]=create_training_set_main(labeled,bw,deg2rad(WindAngle));
    
    %calculate the angle
    for i=1:length(Orientation)
        tuftSet(i).windRelatedAngle=deg2rad((WindAngle-...
            Orientation(i).Orientation));
    end
    if ~exist('weightVector')
        noOfFeatures=9;
        miniweightVector=zeros(1,noOfFeatures);
        weightVector=zeros(1,noOfFeatures);%ones(1,noOfFeatures)/noOfFeatures;
    else
        if size(weightVectors,1)>1
            meanweightVector=mean(weightVectors);
            meanminiweightVector=mean(miniweightVectors);
            weightVector=meanweightVector;
            miniweightVector=meanminiweightVector;
        end
    end
    lh=LearningHandler;
    % this func should start BP and get back the train matrix
    [weightVector,tuftMat,miniweightVector] =lh.process(tuftSet,...
        tuftLabel,weightVector,miniweightVector);
    [h,l]=size(bw);
    maxClusters = 5;
    labelDistanceFactor = 4;
    calcCluster(tuftMat,h,l, maxClusters, labelDistanceFactor);
    if img==1 && noOfImages>1
        tuftVectors=tuftMat;
        tuftLabels=tuftLabel;
        weightVectors=weightVector;
        meanweightVector=weightVector;
        miniweightVectors=miniweightVector;
        meanminiweightVector=miniweightVectors;
        %Orientations=Orientation; %if we want to guess wind diraction
    else
        weightVectors=[weightVectors;weightVector];
        miniweightVectors=[miniweightVectors;miniweightVector];
        meanweightVector=mean(weightVectors);
        meanminiweightVector=mean(miniweightVectors);
        weightVector=meanweightVector;
        miniweightVector=meanminiweightVector;
    end
    
    contourmap_drawer_ML(weightVector,tuftMat,imageTune.CroppedMask,I);
end

end