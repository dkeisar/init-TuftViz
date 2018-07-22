classdef LearningHandler
    properties
    end
    methods
        function this = LearningHandler()
            fprintf ("learning handler initialized\n");
        end

        function [updatedWeightVector,algoGuess] = process(this, tufts, labels, weightVector)
            fprintf ("recieved new array of tufts of length %d\n", length(tufts));
            fprintf ("Now let's learn\n");
            weightVector(1) = 0;
            weightVector(2) = 0;
            trainingSet = this.buildTrainingSet(tufts);
            firstPrediction = this.firstGuess(trainingSet, weightVector);
            algoGuess = this.calculateBeliefPropagation(trainingSet, firstPrediction);
            filteredTrainingSet = this.filterLabeledOnly(algoGuess, labels);
            updatedWeightVector = fmin_adam(@(weightVector)labelingMSEGradients(weightVector, filteredTrainingSet(:,3:8), labels(:,2)), weightVector(:,3:8)', 0.01);
            %[updatedWeightVector] = gradientDescentMulti(filteredTrainingSet, labels(:,2), weightVector', 0.01, 20);
            updatedWeightVector=updatedWeightVector';
            updatedWeightVector=[0,0,updatedWeightVector];
        end
        
        function predictions = firstGuess(~, trainingSet, weightVector)
            predictions = zeros(1,length(trainingSet));
            sz = size(trainingSet);
            normalizeSelfWeights = [weightVector(1), weightVector(2), weightVector(3), weightVector(4), 0, 0, 0, 0];
            normalizeSelfWeights = normalizeSelfWeights/norm(normalizeSelfWeights , 1);
            for i=1:sz(1)
                predictions(i) = dot(trainingSet(i,:), normalizeSelfWeights);
            end  
        end
        
        function trainingSet = buildTrainingSet(~, data)
            trainingSet = zeros(length(data), 8);
            for i=1:length(data)
                trainingSet(i,1) = data(i).pixelX;
                trainingSet(i,2) = data(i).pixelY;
                trainingSet(i,3) = data(i).windRelatedAngle;
                trainingSet(i,4) = data(i).straightness;
                trainingSet(i,5) = data(i).neighbor_1;
                trainingSet(i,6) = data(i).neighbor_2;
                trainingSet(i,7) = data(i).neighbor_3;
                trainingSet(i,8) = data(i).neighbor_4;
            end
        end
        
        function answer = calculateBeliefPropagation(~, data, firstPrediction)
            sz = size(data);
            for i = 1:sz(1)
                tuft = data(i,:);
                for j = 5:8
                    neighbour = data(tuft(j),:);
                    tuft(j) = abs(cos((tuft(3) - neighbour(3))*firstPrediction(j)));
                end
                data(i,:) = tuft;
            end
            answer = data;
        end
        
        function filteredData = filterLabeledOnly(~, trainingData, LabeledData)
            szfd = size(trainingData);
            szld = size(LabeledData);
            filteredData = zeros(szld(1), szfd(2));
            for i=1:szld(1)
                filteredData(i,:) = trainingData(LabeledData(i,1),:);
            end
        end
    end
end