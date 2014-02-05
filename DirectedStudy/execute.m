function execute()
%{
   Execute function for controller design GUI
%}

%Find handles for all objects
h_analysis = findobj('Tag','AnalysisBox');
h_type = findobj('Tag','TypeBox');
h_settle = findobj('Tag','SettleTime');
h_overshoot = findobj('Tag','PO');
h_sample = findobj('Tag','SampleTime');
h_num = findobj('Tag','NumBox');
h_den = findobj('Tag','DenBox');
h_control = findojb('Tag','Controller');

%Get info from each object
analysis = get(h_analysis , 'String');
type = get(h_type,'String');
settle = str2double( get(h_settle,'String'));
po = str2double( get(h_overshoot,'String'));
sample = str2double( get(h_sample,'String'));
num = str2num( get(h_num,'String'));
den = str2num( get(h_den,'String'));


end

