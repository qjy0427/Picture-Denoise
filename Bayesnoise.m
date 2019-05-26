clear all
clc

h = 1;
beta = 10;
eta = 5;

% Read the noisy image for denoising, and change pixels to 1 or -1
image = imread('Bayesnoise_textbook.png');
gray = rgb2gray(image);
X = 2 * imbinarize(gray) - 1; % Create X & Y
Y = X;

[rows, cols] = size(Y);

best_acc = []; % Matrix for storing accuracies
best_img = {}; % Cells for storing matrices
count = 0; % Count iterations
sign = 1; % Sign for continuing
while(sign)
    
    sign = 0; % Sign for stopping
    count = count + 1; % Count the number of iterations
    
    for i = 1:rows
       for j = 1:cols
           
           x = X(i,j);
           y = Y(i,j);

           up = 0;
           down = 0;
           left = 0;
           right = 0;
           
           % Get the value of each neighbor if exists
           if(i > 1)
               up = X(i-1, j);
           end

           if(i < rows)
               down = X(i+1, j);
           end

           if(j > 1)
               left = X(i, j-1); 
           end

           if(j < cols)
               right = X(i, j+1);
           end
           
           % Energy function
           E1 = h * x;
           E2 = h * (-x);

           E1 = E1 - beta * (x * (up + down + left + right));
           E2 = E2 - beta * ((-x) * (up + down + left + right));

           E1 = E1 - eta * x * y;
           E2 = E2 - eta * (-x) * y;

           % If the energy becomes lower, flip it
           if(E2 < E1)
                X(i,j) = -x;
                
                % Stop when no more change can be made
                sign = 1;
           end
       end
    end
    
    % Compare with the noise free picture
    image = imread('Bayes_textbook.png');
    gray = rgb2gray(image);
    result = 2 * imbinarize(gray) - 1;
    accuracy = length(find(result == X))/(rows * cols);
    disp(['For the No. ',num2str(count),' iteration, the accuracy is ',num2str(accuracy,10)]);
    best_acc = [best_acc, accuracy];
    best_img = [best_img, X];
    
end

disp(['Total number of iterations: ',num2str(count)]);

% Obtain the best results
m = max(best_acc);
num = find(m == best_acc);
disp(['The highest accuracy is ',num2str(m),' which was obtained in the No. ',num2str(num(1)),' iteration.'])
X = best_img{num};

% Add color
RGB = cat(3, 242 * uint8(X), 211 * uint8(X), 124 * uint8(X));
imshow(RGB);
imwrite(RGB,'Bayes_denoised.png');