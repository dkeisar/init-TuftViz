function [weightVector] = ...
    Main_ML_Training(imageTune,noOfImages)
% Main ML Training func
WindAngle=imageTune.FlowAngle;
noOfImages=5 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% delete!!!!!!
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
    [tuftSet,tuftLabel,Orientation]=create_training_set(labeled,bw);
    
    %calculate the angle
    for i=1:length(Orientation)
        tuftSet(i).windRelatedAngle=abs(cos(deg2rad((WindAngle-...
            Orientation(i).Orientation))));
    end
    if img==1
        noOfFeatures=8;
        weightVector=ones(1,noOfFeatures)/noOfFeatures;
    end
    lh=LearningHandler;
    % this func should start BP and get back the train matrix
    [weightVector,tuftMat] =lh.process(tuftSet,tuftLabel,weightVector);
    if img==1
        tuftVectors=tuftMat;
        tuftLabels=tuftLabel;
        weightVectors=weightVector;
        meanweightVector=weightVector;
        %Orientations=Orientation; %if we want to guess wind diraction
    else
        tuftVectors=[tuftVectors;tuftMat];
        tuftLabels=[tuftLabels;tuftLabel];
        weightVectors=[weightVectors;weightVector];
        meanweightVector=mean(weightVectors);
        weightVector=weightVector;
    end
    
    contourmap_drawer_ML(weightVector,tuftMat,imageTune.CroppedMask,I)
end

end