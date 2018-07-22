
    % Properties that correspond to app components
    properties (Access = public)
        UIFigure            matlab.ui.Figure
        AlphaKnobLabel      matlab.ui.control.Label
        AlphaKnob           matlab.ui.control.Knob
        SigmaKnobLabel      matlab.ui.control.Label
        SigmaKnob           matlab.ui.control.Knob
        SharpnessKnobLabel  matlab.ui.control.Label
        SharpnessKnob       matlab.ui.control.Knob
        ContrastKnobLabel   matlab.ui.control.Label
        ContrastKnob        matlab.ui.control.Knob
        UIAxes              matlab.ui.control.UIAxes
    end

    
    properties (Access = private)
        autoUpdate % Description
    end
    
    methods (Access = private)
        
        function results = autoupdate(app)
            IA=app.UIFigure
            B= locallapfilt(app.UIAxes, app.SigmaKnob.Value, app.AlphaKnob.Value);
            
        end
        
    end
    

    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            imshow('frame343.jpg','Parent',app.UIAxes);
            app.autoUpdate = 1 ;
        end

        % Value changed function: AlphaKnob
        function AlphaKnobValueChanged(app, event)
            Alpha = app.AlphaKnob.Value;
            if app.autoUpdate
                autoupdate(app)
            end
        end

        % Size changed function: UIFigure
        function UIFigureSizeChanged(app, event)
            position = app.UIFigure.Position;
            
        end

        % Value changed function: SigmaKnob
        function SigmaKnobValueChanged(app, event)
            Sigma = app.SigmaKnob.Value;
            if app.autoUpdate
                autoupdate(app)
            end
            
        end

        % Value changed function: SharpnessKnob
        function SharpnessKnobValueChanged(app, event)
            Sharp = app.SharpnessKnob.Value;
            if app.autoUpdate
                autoupdate(app)
            end
            
        end
    end

    % App initialization and construction
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure
            app.UIFigure = uifigure;
            app.UIFigure.Position = [100 100 1174 749];
            app.UIFigure.Name = 'UI Figure';
            app.UIFigure.SizeChangedFcn = createCallbackFcn(app, @UIFigureSizeChanged, true);

            % Create AlphaKnobLabel
            app.AlphaKnobLabel = uilabel(app.UIFigure);
            app.AlphaKnobLabel.HorizontalAlignment = 'center';
            app.AlphaKnobLabel.Position = [606 56 36 22];
            app.AlphaKnobLabel.Text = 'Alpha';

            % Create AlphaKnob
            app.AlphaKnob = uiknob(app.UIFigure, 'continuous');
            app.AlphaKnob.Limits = [0 1];
            app.AlphaKnob.MajorTicks = [0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1];
            app.AlphaKnob.ValueChangedFcn = createCallbackFcn(app, @AlphaKnobValueChanged, true);
            app.AlphaKnob.Position = [593 112 60 60];

            % Create SigmaKnobLabel
            app.SigmaKnobLabel = uilabel(app.UIFigure);
            app.SigmaKnobLabel.HorizontalAlignment = 'center';
            app.SigmaKnobLabel.Position = [82 56 40 22];
            app.SigmaKnobLabel.Text = 'Sigma';

            % Create SigmaKnob
            app.SigmaKnob = uiknob(app.UIFigure, 'continuous');
            app.SigmaKnob.Limits = [0 1];
            app.SigmaKnob.MajorTicks = [0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1];
            app.SigmaKnob.ValueChangedFcn = createCallbackFcn(app, @SigmaKnobValueChanged, true);
            app.SigmaKnob.Position = [72 112 60 60];

            % Create SharpnessKnobLabel
            app.SharpnessKnobLabel = uilabel(app.UIFigure);
            app.SharpnessKnobLabel.HorizontalAlignment = 'center';
            app.SharpnessKnobLabel.Position = [420 56 63 22];
            app.SharpnessKnobLabel.Text = 'Sharpness';

            % Create SharpnessKnob
            app.SharpnessKnob = uiknob(app.UIFigure, 'continuous');
            app.SharpnessKnob.ValueChangedFcn = createCallbackFcn(app, @SharpnessKnobValueChanged, true);
            app.SharpnessKnob.Position = [421 112 60 60];

            % Create ContrastKnobLabel
            app.ContrastKnobLabel = uilabel(app.UIFigure);
            app.ContrastKnobLabel.HorizontalAlignment = 'center';
            app.ContrastKnobLabel.Position = [259 56 51 22];
            app.ContrastKnobLabel.Text = 'Contrast';

            % Create ContrastKnob
            app.ContrastKnob = uiknob(app.UIFigure, 'continuous');
            app.ContrastKnob.Position = [254 112 60 60];

            % Create UIAxes
            app.UIAxes = uiaxes(app.UIFigure);
            title(app.UIAxes, 'Title')
            app.UIAxes.Position = [32 254 1095 479];
        end
    end

    methods (Access = public)

        % Construct app
        function app = app1

            % Create and configure components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
