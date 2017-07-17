function varargout = pie_charts(varargin)
% PIE_CHARTS MATLAB code for pie_charts.fig
%      PIE_CHARTS, by itself, creates a new PIE_CHARTS or raises the existing
%      singleton*.
%
%      H = PIE_CHARTS returns the handle to a new PIE_CHARTS or the handle to
%      the existing singleton*.
%
%      PIE_CHARTS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PIE_CHARTS.M with the given input arguments.
%
%      PIE_CHARTS('Property','Value',...) creates a new PIE_CHARTS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before pie_charts_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to pie_charts_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help pie_charts

% Last Modified by GUIDE v2.5 24-Jun-2016 21:05:07

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @pie_charts_OpeningFcn, ...
                   'gui_OutputFcn',  @pie_charts_OutputFcn, ...
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


% --- Executes just before pie_charts is made visible.
function pie_charts_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to pie_charts (see VARARGIN)

% Choose default command line output for pie_charts
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes pie_charts wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = pie_charts_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
