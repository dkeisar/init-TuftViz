function varargout = choose_tufts_for_develop(varargin)
% choose_tufts_for_develop MATLAB code for choose_tufts_for_develop.fig
%      choose_tufts_for_develop, by itself, creates a new choose_tufts_for_develop or raises the existing
%      singleton*.
%
%      H = choose_tufts_for_develop returns the handle to a new choose_tufts_for_develop or the handle to
%      the existing singleton*.
%
%      choose_tufts_for_develop('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in choose_tufts_for_develop.M with the given input arguments.
%
%      choose_tufts_for_develop('Property','Value',...) creates a new choose_tufts_for_develop or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before choo?se_tufts_for_ML_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to choose_tufts_for_develop_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help choose_tufts_for_develop

% Last Modified by GUIDE v2.5 20-Jul-2018 16:55:13

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @choose_tufts_for_develop_OpeningFcn, ...
    'gui_OutputFcn',  @choose_tufts_for_develop_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end


if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end


% End initialization code - DO NOT EDIT


% --- Executes just before choose_tufts_for_develop is made visible.
function choose_tufts_for_develop_OpeningFcn(hObject, ~, ...
    trainhandle, bw,xcenter,ycenter,graindata,trainingmat,weightVector,CroppedMask,I)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% trainhandle    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to choose_tufts_for_develop (see VARARGIN)
[Q] = contourmap_drawer_ML(weightVector,trainingmat,CroppedMask,bw,1);
axes(trainhandle.Image);
hold on
imagepos=[0 0 1 1];
contourf(Q,[0:0.01:1],'LineStyle','none');
axis equal

%axes(trainhandle.Image);

imagesc(flipud(bw))
alpha 0.2
hold off

trainhandle.bw=bw;
trainhandle.xcenter=xcenter;
trainhandle.ycenter=ycenter;
trainhandle.graindata=graindata;
% Choose default command line output for choose_tufts_for_develop
trainhandle.output = hObject;

% Update handles structure
guidata(hObject, trainhandle);

% UIWAIT makes choose_tufts_for_develop wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function choose_tufts_for_develop_OutputFcn(~, ~, trainhandle)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = trainhandle.output;


% --- Executes on button press in un_attached_polygon_button.
function un_attached_polygon_button_Callback(~, ~, trainhandle)
% hObject    handle to un_attached_polygon_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global val
fig=figure;
fig.Name='Choose the area of the polygon';
h=croping(trainhandle.bw);
close
counter=1;
for i=1:length(trainhandle.xcenter)
    if ~h(round(trainhandle.ycenter(i)),round(trainhandle.xcenter(i)))
        if isfield(val,'x')
            val.x=[val.x,trainhandle.xcenter(i)];
            val.y=[val.y,trainhandle.ycenter(i)];
            val.label=[val.label,0];
            val.box=[val.box;trainhandle.graindata(i).BoundingBox];
            rect=imrect(gca,trainhandle.graindata(i).BoundingBox);
            setColor(rect,'Red');
            val.tufts(length(val.x))=i;
            counter=counter+1;
        else
            val.x=trainhandle.xcenter(i);
            val.y=trainhandle.ycenter(i);
            val.label=0;
            val.tufts=i;
            val.box=trainhandle.graindata(i).BoundingBox;
            rect=imrect(gca,trainhandle.graindata(i).BoundingBox);
            setColor(rect,'Red');
            counter=counter+1;
        end
    end    
end


% --- Executes on button press in un_attached_tufts_button.
function un_attached_tufts_button_Callback(~, ~, trainhandle)
% hObject    handle to un_attached_tufts_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
trainhandle.backpanel.Title='Click on the relevent tufts, press enter to finish';
global val
[x_point,y_point] = getpts(trainhandle.Image);
counter=1;
for i=1:length(x_point)
    if isfield(val,'x')
        if x_point(i)>trainhandle.Image.XLim(1) && x_point(i)<trainhandle.Image.XLim(2)...
                && y_point(i)>trainhandle.Image.YLim(1) && y_point(i)<trainhandle.Image.YLim(2)
            [~,index]=min(pdist2([x_point(i) y_point(i)]...
                ,[trainhandle.xcenter trainhandle.ycenter]));
            val.x=[val.x,trainhandle.xcenter(index)];
            val.y=[val.y,trainhandle.ycenter(index)];
            val.label=[val.label,0];
            val.tufts(length(val.x))=index;
            val.box=[val.box;trainhandle.graindata(index).BoundingBox];
            rect=imrect(gca,trainhandle.graindata(index).BoundingBox);
            setColor(rect,'Red');
        end
    else
        val.box=trainhandle.graindata(i).BoundingBox;
        [~,index]=min(pdist2([x_point(i) y_point(i)]...
            ,[trainhandle.xcenter trainhandle.ycenter]));
        val.x=trainhandle.xcenter(index);
        val.y=trainhandle.ycenter(index);
        val.label=0;
        val.tufts=index;
        val.box=trainhandle.graindata(index).BoundingBox;
        rect=imrect(gca,trainhandle.graindata(index).BoundingBox);
        setColor(rect,'Red');
    end
    
end




% --- Executes on button press in attached_tufts_button.
function attached_tufts_button_Callback(~, ~, trainhandle)
% hObject    handle to attached_tufts_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
trainhandle.backpanel.Title='Click on the relevent tufts, press enter to finish';
global val
[x_point,y_point] = getpts(trainhandle.Image);
counter=1;
for i=1:length(x_point)
    if isfield(val,'x')
        if x_point(i)>trainhandle.Image.XLim(1) && x_point(i)<trainhandle.Image.XLim(2)...
                && y_point(i)>trainhandle.Image.YLim(1) && y_point(i)<trainhandle.Image.YLim(2)
                        
            [~,index]=min(pdist2([x_point(i) y_point(i)]...
                ,[trainhandle.xcenter trainhandle.ycenter]));
            val.x=[val.x,trainhandle.xcenter(index)];
            val.y=[val.y,trainhandle.ycenter(index)];
            val.label=[val.label,1];
            
            val.tufts(length(val.x))=index;
            val.box=[val.box;trainhandle.graindata(index).BoundingBox];
            rect=imrect(gca,trainhandle.graindata(index).BoundingBox);
            setColor(rect,'Blue');
        end
    else
        val.box=trainhandle.graindata(i).BoundingBox;
        [~,index]=min(pdist2([x_point(i) y_point(i)]...
            ,[trainhandle.xcenter trainhandle.ycenter]));
        val.x=trainhandle.xcenter(index);
        val.y=trainhandle.ycenter(index);
        val.label=1;
        val.tufts=index;
        val.box=trainhandle.graindata(index).BoundingBox;
        rect=imrect(gca,trainhandle.graindata(index).BoundingBox);
        setColor(rect,'Blue');
    end
    
end





% --- Executes on button press in attached_polygon_button.
function attached_polygon_button_Callback(~, ~, trainhandle)
% hObject    handle to attached_polygon_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global val
fig=figure;
fig.Name='Choose the area of the polygon';
h=croping(trainhandle.bw);
close
for i=1:length(trainhandle.xcenter)
    if ~h(round(trainhandle.ycenter(i)),round(trainhandle.xcenter(i)))
        if isfield(val,'x')
            val.x=[val.x,trainhandle.xcenter(i)];
            val.y=[val.y,trainhandle.ycenter(i)];
            val.label=[val.label,1];
            val.box=[val.box;trainhandle.graindata(i).BoundingBox];
            rect=imrect(gca,trainhandle.graindata(i).BoundingBox);
            setColor(rect,'Blue');
            val.tufts(length(val.x))=i;
        else
            val.x=trainhandle.xcenter(i);
            val.y=trainhandle.ycenter(i);
            val.label=1;
            val.box=trainhandle.graindata(i).BoundingBox;
            val.tufts=i;
            imrect(gca,trainhandle.graindata(i).BoundingBox);
        end
    end    
end

    
    
    
    % --- Executes on button press in pushbutton5.
    function pushbutton5_Callback(~, ~, ~)
    % hObject    handle to pushbutton5 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    closereq
