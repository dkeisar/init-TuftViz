function [weightVectors,miniweightVectors] = ...
    Main_ML_develop(imageTune,weightVectors,miniweightVectors)
%%
% Main ML Training func
WindAngle=imageTune.FlowAngle;

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
[bw,seglabeled] = matlab_seg(I,imageTune);
[h,l]=size(bw);
graindata = regionprops(seglabeled,'basic');

len=length(graindata);
xcenter=zeros(len,1);ycenter=zeros(len,1);     %initialize
for i=1:len
    %extract center and orientation
    Center=graindata(i).Centroid;
    
    %classify to the x and y location
    xcenter(i)=Center(1); ycenter(i)=Center(2);
end
MinorAxisLength=regionprops(seglabeled,'MinorAxisLength');
MajorAxisLength=regionprops(seglabeled,'MajorAxisLength');
Orientation=regionprops(seglabeled,'Orientation');
trainingSet.length=MajorAxisLength;

for i=1:length(xcenter)
    trainingSet(i).pixelX=xcenter(i)/l; trainingSet(i).pixelY=ycenter(i)/h;
    trainingSet(i).straightness=(1-MinorAxisLength(i).MinorAxisLength...
        /MajorAxisLength(i).MajorAxisLength);
end

Min_Dis_1=Inf;Min_Dis_2=Inf;Min_Dis_3=Inf;Min_Dis_4=Inf;
for i=1:length(xcenter)
    for j=1:length(xcenter)
        if i~=j
            Dis=pdist2([xcenter(i) ycenter(i)],[xcenter(j) ycenter(j)]);
            if Dis<Min_Dis_1
                Min_Dis_1=Dis;
                trainingSet(i).neighbor_1=j;
            elseif Dis<Min_Dis_2
                Min_Dis_2=Dis;
                trainingSet(i).neighbor_2=j;
            elseif Dis<Min_Dis_3
                Min_Dis_3=Dis;
                trainingSet(i).neighbor_3=j;
            elseif Dis<Min_Dis_4
                Min_Dis_4=Dis;
                trainingSet(i).neighbor_4=j;
            end
        end
    end
    Min_Dis_1=Inf;Min_Dis_2=Inf;Min_Dis_3=Inf;Min_Dis_4=Inf;
end
%calculate the angle
for i=1:length(Orientation)
    trainingSet(i).windRelatedAngle=deg2rad((WindAngle-...
        Orientation(i).Orientation));
end
meanweightVector=mean(weightVectors);
meanminiweightVector=mean(miniweightVectors);
weightVector=meanweightVector;
miniweightVector=meanminiweightVector;

lh=LearningHandler;
[trainingmat,windangles] = lh.buildTrainingSet(trainingSet);
firstPrediction = zeros(1,length(trainingmat));

for i=1:sz(1)
                 firstPrediction(i) = dot(trainingSet(i,:), miniweightVector);
end
             

trainingmat = lh.calculateBeliefPropagation(trainingmat, firstPrediction,windangles);

[tuftSet,tuftLabel,Orientation]=create_develop(seglabeled,bw,...
    WindAngle,trainingmat,weightVector,imageTune.CropFrame,I)


%% Create the training set
% create the traing set
[tuftSet,tuftLabel,Orientation]=create_training_set_main(seglabeled,bw,deg2rad(WindAngle));

% 
% %calculate the angle
% for i=1:length(Orientation)
%     tuftSet(i).windRelatedAngle=deg2rad((WindAngle-...
%         Orientation(i).Orientation));
% end

% this func should start BP and get back the train matrix
[weightVector,tuftMat] =lh.process(tuftSet,tuftLabel,weightVector);

%Orientations=Orientation; %if we want to guess wind diraction
weightVectors=[weightVectors;weightVector];
miniweightVectors=[miniweightVectors;miniweightVector];
meanweightVector=mean(weightVectors);
meanminiweightVector=mean(miniweightVectors);
weightVector=meanweightVector;
miniweightVector=meanminiweightVector;

%contourmap_drawer_ML(weightVector,tuftMat,imageTune.CroppedMask,I)
end
