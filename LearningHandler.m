classdef LearningHandler
    properties
    end
    methods
        function this = LearningHandler()
            fprintf ("learning handler initialized\n");
        end
        
        function [updatedWeightVector,algoGuess,miniweightVector] = process(this, tufts,...
                labels, weightVector,miniweightVector)
            fprintf ("recieved new array of tufts of length %d\n", length(tufts));
            fprintf ("Now let's learn\n");
            [trainingSet,windangles] = this.buildTrainingSet(tufts);
            [firstPrediction,miniweightVector] = this.firstGuess(trainingSet, miniweightVector,labels);
            algoGuess = this.calculateBeliefPropagation(trainingSet, firstPrediction,windangles);
            filteredTrainingSet = this.filterLabeledOnly(algoGuess, labels);
            updatedWeightVector = fmin_adam(@(weightVector)labelingMSEGradients(weightVector, filteredTrainingSet(:,3:9), labels(:,2)), weightVector(:,3:9)', 0.01);
            %[updatedWeightVector] = gradientDescentMulti(filteredTrainingSet, labels(:,2), weightVector', 0.01, 20);
            updatedWeightVector=updatedWeightVector';
            updatedWeightVector=[0,0,updatedWeightVector];
        end
        
        function [predictions,updatedminiweightVector]= firstGuess(~, trainingSet, miniweightVector,labels)
            predictions = zeros(1,length(trainingSet));
            sz = size(trainingSet);
            trainingSet(:,6:9)=0;
            %             normalizeSelfWeights = [weightVector(1:5), 0, 0, 0, 0];
            if norm(miniweightVector(:,3:9))>0
                miniweightVector = miniweightVector/norm(miniweightVector(:,3:5) , 1);
            end
            updatedminiweightVector = fmin_adam(@(miniweightVector)labelingMSEGradients(miniweightVector,...
                trainingSet(labels(:,1),3:9), labels(:,2)), miniweightVector(:,3:9)', 0.1);
            updatedminiweightVector=updatedminiweightVector';
            updatedminiweightVector = updatedminiweightVector/norm(updatedminiweightVector(1:3) , 1);
            updatedminiweightVector=[0,0,updatedminiweightVector];
            for i=1:sz(1)
                predictions(i) = dot(trainingSet(i,:), updatedminiweightVector);
            end
        end
        
        function [trainingSet,windangles] = buildTrainingSet(~, data)
            trainingSet = zeros(length(data), 9);
            for i=1:length(data)
                try trainingSet(i,1) = data(i).pixelX;
                end
                try trainingSet(i,2) = data(i).pixelY;
                end
                try trainingSet(i,3) = abs(cos(data(i).windRelatedAngle));
                    windangles(i)=data(i).windRelatedAngle;
                end
                try trainingSet(i,4) = data(i).straightness;
                end
                try trainingSet(i,5) = data(i).length;
                end
                try trainingSet(i,6) = data(i).neighbor_1;
                end
                try trainingSet(i,7) = data(i).neighbor_2;
                end
                try trainingSet(i,8) = data(i).neighbor_3;
                end
                try trainingSet(i,9) = data(i).neighbor_4;
                end
            end
        end
        
        function data = calculateBeliefPropagation(~, data, firstPrediction,windangles)
            for i = 1:size(data,1)
                tuft = windangles(i);
                neighbours= data(i,6:9);
                for j = 1:4
                    neighbour = windangles(neighbours(j));
                    neighbours(j) = abs(cos((tuft - neighbour)))*firstPrediction(neighbours(j));
                end
                data(i,6:9) = neighbours(1:4);
            end
            
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