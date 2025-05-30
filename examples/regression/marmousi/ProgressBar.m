% ProgressBar Class
%
% A versatile progress bar implementation for MATLAB, compatible with 
% MATLAB versions 2017a through 2024a. This class provides both GUI and 
% CLI progress bar interfaces and supports parallel processing with 
% `parfor` loops.
%
% Features:
% - Faster than MATLAB's built-in `waitbar`.
% - Supports both GUI and CLI interfaces.
% - Compatible with `parfor` loops for parallel processing.
% - Displays elapsed and estimated remaining time.
% - Customizable character sets for CLI progress bar.
%
% Usage Examples:
% 1. GUI Progress Bar:
%    ```matlab
%    N = 100;
%    task_name = 'Task name';
%    PB = ProgressBar(N, task_name); % or ProgressBar(N);
%    for n = 1:N
%        pause(0.5); % Loop body
%        PB.count;   % or count(PB)
%    end
%    ```
%
% 2. GUI Progress Bar with `parfor`:
%    ```matlab
%    N = 500;
%    task_name = 'Task name';
%    PB = ProgressBar(N, task_name); % or ProgressBar(N);
%    parfor n = 1:N
%        pause(0.5 * rand); % Loop body
%        count(PB);         % Recommended for `parfor` loops
%    end
%    ```
%
% 3. CLI Progress Bar:
%    ```matlab
%    N = 100;
%    task_name = 'Task name';
%    PB = ProgressBar(N, task_name, 'cli'); % or ProgressBar(N, [], 'cli');
%    for n = 1:N
%        pause(0.5); % Loop body
%        PB.count;   % or count(PB)
%    end
%    ```
%
% 4. CLI Progress Bar with `parfor`:
%    ```matlab
%    N = 500;
%    task_name = 'Task name';
%    PB = ProgressBar(N, task_name, 'cli'); % or ProgressBar(N, [], 'cli');
%    parfor n = 1:N
%        pause(0.5 * rand); % Loop body
%        count(PB);         % Recommended for `parfor` loops
%    end
%    ```
%
% CLI Progress Bar Example Output:
% ```
% |███████████████████████████ 1 min, 18 sec ███████████████████████████|100%
% Task name |██████████████████████████ 8 sec ██████████████████████████|100%
% Task name |███████████████████████████████████████████████            | 80%
% Elapsed: 2 hour, 1 min, Remaining: 30 min
% ```
%
% Constructor:
% - `ProgressBar(N, task_name, ui)`
%   - `N`: Total number of iterations (positive integer).
%   - `task_name`: (Optional) Name of the task (string or character array).
%   - `ui`: (Optional) Interface type, either `'gui'` (default) or `'cli'`.
%
% Methods:
% - `count`: Increment the progress bar by one step. Use `count(PB)` in 
%   `parfor` loops for compatibility.
%
% Properties:
% - `N`: Total number of iterations.
% - `task_name`: Name of the task.
% - `ui_type`: Interface type (`'gui'` or `'cli'`).
% - `counter`: Current progress count.
% - `start_time`: Start time of the progress bar.
% - `end_time`: End time of the progress bar (when completed).
%
% Notes:
% - The CLI progress bar adapts to the terminal width and supports 
%   customizable character sets.
% - The GUI progress bar uses MATLAB's `waitbar` for visualization.
% - The class automatically handles cleanup of GUI resources upon 
%   completion or deletion.
%
% Author:
% - Created: 2023-07-14
% - Edited: 2023-09-28
% - Author: Cho HyunGwang
% - GitHub: https://github.com/elgar328/matlab-code-examples/tree/main/tools/ProgressBar
classdef ProgressBar < handle
    % -------------------- Properties for asynchronous --------------------
    properties (SetAccess = immutable, GetAccess = private)
        Queue = []
    end
    properties (SetAccess = immutable, GetAccess = private, Transient)
        Listener = []
        no_parallel_toolbox
    end
    % ---------------------------- Properties -----------------------------
    properties (SetAccess = private, Transient)
        task_name
        counter = 0
        start_time = []
        end_time
    end
    properties (SetAccess = immutable, GetAccess = private, Transient)
        N                                % final integer
        ui_type                          % 'gui' or 'cli'
        frame_interval_limit = 0.1       % sec
    end
    properties (Access = private, Transient)
        time_info = "";
        ratio = 0;
        int_percent = 0;
    end
    % ------------------------ Properties for GUI -------------------------
    properties (Access = private, Transient)
        bar_ratio = 0;
        prev_count_time
    end
    properties (SetAccess = immutable, Hidden = true, Transient)
        fig_handle
        ratio_resol = 0.01;
    end
    % ------------------------ Properties for CLI -------------------------
    properties (Access = private, Transient)
        bar_n = 0;
    end
    properties (SetAccess = immutable, GetAccess = private, Transient)
        bar_N
        terminal_width = 75
        minimal_terminal_width = 20;
        char_set = {' ','█',' ','|'}; % <----- Character set
    end
    methods
        % -------------------------- Constructor --------------------------
        function obj = ProgressBar(N, task_name, ui)
            if nargin<3, ui = 'gui'; end
            if nargin<2, task_name = ''; end
            validateattributes(N,{'double'},...
                {'scalar','integer','positive','real','finite','nonnan'})
            task_name = must_be_text(task_name);
            mustBeMember(ui,{'gui','cli'})
            obj.N = N;
            addon_list = ver;
            obj.no_parallel_toolbox = ~contains([addon_list.Name], ...
                'parallel computing toolbox','IgnoreCase',true);
            if ~obj.no_parallel_toolbox
                obj.Queue = parallel.pool.DataQueue;
                obj.Listener = afterEach(obj.Queue, @(~) localIncrement(obj));
            end
            obj.ui_type = ui;
            obj.start_time = datetime();
            obj.prev_count_time = datetime();
            switch obj.ui_type
                case 'cli'
                    obj.task_name = check_task_name_cli(obj, task_name);
                    bar_N = obj.terminal_width -4 -2*length(obj.char_set{4});
                    if ~isempty(obj.task_name)
                        bar_N = bar_N -length(obj.char_set{1}) ...
                            -length(obj.task_name);
                    end
                    obj.bar_N = bar_N;
                    update_cli("", true, true);
                case 'gui'
                    obj.task_name = task_name;
                    obj.fig_handle = waitbar(0, '', 'Name', ...
                        sprintf('%d%%  %s',obj.int_percent, obj.task_name));
                    obj.bar_N = 0;
            end
        end
        % ---------------------------- Counter ----------------------------
        function count(obj)
            % The || operator was not used intentionally.
            % Short circuit does not work normally under certain conditions.
            if obj.no_parallel_toolbox
                obj.localIncrement();   % Serial processing
            elseif isempty(getCurrentJob)
                obj.localIncrement();   % Serial processing
            else
                send(obj.Queue, true);  % Parallel processing
            end
        end
    end
    
    methods (Hidden = true)
        % -------------------------- Destructor ---------------------------
        function delete(obj)
            if strcmp(obj.ui_type,'gui')
                delete(obj.fig_handle);
            end
        end
    end
    methods (Access = private)
        % ------------------------- localIncrement ------------------------
        function localIncrement(obj)
            obj.counter = 1 + obj.counter;
            obj.ratio = obj.counter/obj.N;
            if (seconds(datetime()-obj.prev_count_time) < obj.frame_interval_limit) ...
                    && (obj.counter ~= obj.N)
                return
            end
            obj.prev_count_time = datetime();
            switch obj.ui_type
                case 'cli'
                    % ------------------------ CLI ------------------------
                    outdated = false;
                    if obj.int_percent ~= floor(obj.ratio*100)
                        obj.int_percent = floor(obj.ratio*100);
                        outdated = true;
                        if obj.int_percent == 100
                            obj.end_time = datetime();
                        end
                    end
                    new_time_info = get_time_info_string(obj);
                    if ~strcmp(obj.time_info, new_time_info)
                        obj.time_info = new_time_info;
                        outdated = true;
                    end
                    if obj.bar_n ~= floor(obj.bar_N*obj.ratio)
                        obj.bar_n = floor(obj.bar_N*obj.ratio);
                        outdated = true;
                    end
                    if outdated
                        print_progressbar_cli(obj);
                    end
                case 'gui'
                    % ------------------------ GUI ------------------------
                    if obj.int_percent ~= floor(obj.ratio*100)
                        obj.int_percent = floor(obj.ratio*100);
                        obj.fig_handle.Name = ...
                            sprintf('%d%%  %s',obj.int_percent, obj.task_name);
                    end
                    if obj.bar_ratio + obj.ratio_resol <= obj.ratio
                        obj.bar_ratio = obj.ratio;
                        waitbar(obj.bar_ratio, obj.fig_handle)
                    end
                    new_time_info = get_time_info_string(obj);
                    if ~strcmp(obj.time_info, new_time_info)
                        obj.time_info = new_time_info;
                        waitbar(obj.ratio, obj.fig_handle, obj.time_info)
                    end
                    if obj.counter == obj.N
                        obj.end_time = datetime();
                        if ~isempty(obj.task_name)
                            fprintf('%s\n', obj.task_name)
                        end
                        fprintf('%s\n', obj.time_info)
                        obj.delete
                    end
            end
        end
    end
end
% ---------------------------- Local functions ----------------------------
function string_out = duration2string(dur)
if isinf(dur)
    string_out = "Inf";
    return
end
if dur >= days(1)
    string_out = sprintf('%d day, %d hour', ...
        floor(dur/days(1)), floor(hours(mod(dur,days(1)))));
elseif dur >= hours(1)
    string_out = sprintf('%d hour, %d min', ...
        floor(dur/hours(1)), floor(minutes(mod(dur,hours(1)))));
elseif dur >= minutes(1)
    string_out = sprintf('%d min, %d sec', ...
        floor(dur/minutes(1)), floor(seconds(mod(dur,minutes(1)))));
else
    string_out = sprintf('%d sec', floor(dur/seconds(1)));
end
string_out = string(string_out);
end
function time_info = get_time_info_string(obj)
if obj.int_percent == 100
    time_info = "Elapsed: " ...
        + duration2string(datetime() - obj.start_time);
else
    elapsed = datetime() - obj.start_time;
    remain = elapsed/obj.ratio - elapsed;
    time_info = "Elapsed: " + duration2string(elapsed) ...
        + ", Remaining: " + duration2string(remain);
end
end
function print_progressbar_cli(obj)
if isempty(obj.task_name)
    name_string = "";
else
    name_string = string([obj.task_name, obj.char_set{1}]);
end
bar_bound_string = string(obj.char_set{4});
percent_string = string(sprintf('%3d%%', obj.int_percent));
% Bar text
bar_string = [repmat(obj.char_set{2},[1,obj.bar_n]), ...
    repmat(obj.char_set{3},[1,obj.bar_N-obj.bar_n])];
if obj.int_percent == 100
    % finished
    end_flag = true;
    time_info_char = [' ', ...
        string2chars(...
        extractAfter(obj.time_info,"Elapsed: ")), ' '];
    time_info_len = length(time_info_char);
    if time_info_len + 2 <= length(bar_string)
        head_ind = floor((length(bar_string)-time_info_len)/2)+1;
        tail_ind = head_ind + time_info_len -1;
        bar_string(head_ind:tail_ind) = time_info_char;
        second_line = "";
    else
        second_line = obj.time_info + newline;
    end
else
    % on progress
    end_flag = false;
    second_line = obj.time_info + newline;
end
bar_string = string(bar_string);
first_line = ...
    name_string ...
    + bar_bound_string ...
    + bar_string ...
    + bar_bound_string ...
    + percent_string ...
    + newline;
formatted_string = first_line + second_line;
% print out
update_cli(formatted_string, end_flag);
end
function update_cli(string_vec, lock_this_msg, lock_prev_msg)
% string_vec(1) -> std out    (black)
% string_vec(2) -> std error  (red)
% string_vec(3) -> std out    (black)
% string_vec(4) -> std error  (red)
% ...
% Not escaping at \, ', % 
if nargin < 3, lock_prev_msg = false; end
if nargin < 2, lock_this_msg = false; end
assert(isstring(string_vec))
validateattributes(lock_this_msg,{'logical'},{'scalar'})
validateattributes(lock_prev_msg,{'logical'},{'scalar'})
persistent previous_msg_length
if isempty(previous_msg_length)
    previous_msg_length = 0;
end
if lock_prev_msg
    previous_msg_length = 0;
end
backspace_chain = string(repmat(sprintf('\b'),[1,previous_msg_length]));
previous_msg_length = sum(strlength(string_vec));
string_vec(1) = backspace_chain + string_vec(1);
fileid = 1;
for n=1:length(string_vec)
    msg = string_vec(n);
    msg = strrep(msg, '%', '%%');
    msg = strrep(msg, '\', '\\');
    msg = strrep(msg, "'", "''");
    fprintf(fileid, msg);
    switch fileid
        case 1
            fileid = 2;
        case 2
            fileid = 1;
    end
end
if lock_this_msg
    previous_msg_length = 0;
end
end
function task_name = check_task_name_cli(obj, task_name)
if length(task_name) >= (obj.terminal_width - obj.minimal_terminal_width)
    task_name = task_name(1:obj.terminal_width-obj.minimal_terminal_width-1);
    warning('The task name has been truncated due to its length!')
end
end
function output = must_be_text(input)
if isempty(input)
    output = input;
elseif ischar(input)
    assert(size(input,1)==1)
    output = input;
elseif isstring(input)
    assert(isscalar(input))
    output = string2chars(input);
else
    error('task_name must be a text')
end
end
function output = string2chars(input)
output = char(cellstr(input));
end
