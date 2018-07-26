function [trainingSet,tuftLabel,Orientations]=create_training_set_main(labeled,bw,WindAngle)

graindata = regionprops(labeled,'basic');

len=length(graindata);
xcenter=zeros(len,1);ycenter=zeros(len,1);     %initialize
for i=1:len
    %extract center and orientation
    Center=graindata(i).Centroid;
    
    %classify to the x and y location
    xcenter(i)=Center(1); ycenter(i)=Center(2);
end
global val;
val=[];
choose_tufts_for_ML(bw,xcenter,ycenter,graindata)
uiwait (gcf)
x_point=val.x;
[x_point,ia,ic] = unique(x_point,'last');
y_point=val.y(ia);
labels=val.label(ia);
tuft=val.tufts(ia);
box=val.box(ia,:);
val=[]; clear val;
[h,l]=size(bw);

MinorAxisLength=regionprops(labeled,'MinorAxisLength');
MajorAxisLength=regionprops(labeled,'MajorAxisLength');
Orientations=regionprops(labeled,'Orientation');
tuftLabel=[tuft;labels]';
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
image= regionprops(labeled,'Image');
%% calculate angle of the second half of the tuft
% for i=1:length(xcenter)
%    [h,l]=size(image(i));
%    relativearealength=l/abs(cos(WindAngle))
%    
% end
end

