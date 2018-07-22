function segnetationvideoseperation(ImageTune)
% This function gets the user video, dividing it into frames. Each frame
%  then is tuned by the parameters difined by the user. Later it send each
%  image for segmentaton and map drawing and saves those images into a
%  video (AVI)

for img = 1:10:ImageTune.OriginalVideo.NumberOfFrames;  %for each frame
    %devide into frames and read them
    I = read(ImageTune.OriginalVideo, img);
    %make the frame B&W, crop and mask 
    I=rgb2gray(I);
    I(ImageTune.Mask)=256;
    I = imcrop(I, ImageTune.CropFrame);
    %tune the frame by the parameters difined by the user
    try
    I(:,:,:)=I(:,:,:)*(50^log((ImageTune.BrightnessKnob.Value+0.5)));
    I= locallapfilt(I, ImageTune.SigmaKnob.Value, ImageTune.AlphaKnob.Value);
    I = imadjust(I,[ImageTune.LowInSlider.Value ImageTune.HighInSlider.Value],[],...
        ImageTune.GammaKnob.Value);
    I=imsharpen(I,'Radius',ImageTune.RadiusSlider.Value,...
        'Amount',ImageTune.SharpnessstrengthKnob.Value,...
        'Threshold',ImageTune.ThresholdSlider.Value);
    end
    %segment the frame
    matlab_seg(I,ImageTune,"streamlines");
    % save the figure as frame and close it
    frame=getframe(gcf);
    close(gcf)
        
    % write the video and for the first frame initielize it
        if img==1
            v = VideoWriter('strealined_video','Uncompressed AVI');
            open(v);
            writeVideo(v,frame);writeVideo(v,frame);
        else
            writeVideo(v,frame);writeVideo(v,frame);
        end
        
        % saving a bach of pictures
        
        % filename=strcat('frame',num2str(img),'_tuned.jpg');
        % saveas(fig,filename);
end
close(v)


end

